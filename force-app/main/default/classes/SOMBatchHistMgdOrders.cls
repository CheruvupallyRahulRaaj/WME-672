/**
 * @author gvansteeter
 * @version 1.4
 * @created 2020.12.08
 * @modified 2020.01.07
 * @changes
 * -------------------------------------------------------------------------------------------------------------------
 * Ver    Date         Modified by   Purpose
 * 1.1    2020.12.08   gvansteeter   Initial development.
 * 1.2    2020.12.21   gvansteeter   Added error handling to set Orders that failed on OrderSummary generation to 
 *                                   revert Status = 'Draft' and HistoricalOrderProcStatus__c = 'Not Processed'
 * 1.3    2020.12.28   gvansteeter   Added new error logging functionality (SOMErrorLog__c, SOMHistOrderbatchProcErr__c,
 *                                   SOMUtil.insertErrorLog(List<SOMErrorLog__c> listErrorLog, String errMsg))
 * 1.4    2020.01.07   gvansteeter   Completely rewrote the execute class to use the ConnectApi call instead of 
 *                                   depending on the flow. If Order.isHistMgd__c is true, then create managed OS, otherwise
 *                                   creae unmanaged OS.
 * Description: ======================================================================================================
 *   BatchApex to automatically update Order.Status = 'Activated' and then execute a call to 
 *   ConnectApi.OrderSummaryCreation.createOrderSummary() to generate OrderSummaries for 
 *   historical orders that are in "Draft" status and historical status is "Not Processed". Errors during process 
 *   execution are written to custom object SOMHistOrdBatchProcErr__c as a related list to Order, and Order is reverted
 *   to "Draft"/"Not Processed" status.  Successful OrdSummry generation results in historical order batch status
 *   updated to "Processed".
 * Development notes: ================================================================================================
 * Dependencies:
 *  1) Order.isHistorical__c checkbox default = false
 *  2) Order.HistoricalOrderProcStatus__c picklist ('Not Processed'>'Working'>'Processed')
 *  3) Order.isHistMgd__c checkbox default = false. True means create a Managed Order Summary.
 *  3) SOMHistOrdBatchProcErr__c custom sObject to record errors during batch processing.
 *     FIELDNAME          DATATYPE           COMMENTS
 *     OrderID__c         Lookup(Order)      Links the record to the Order
 *     Error_Message__c   LongTextArea(32k)  Contains the error message returned by the flow     
 *  4) SOMUtil.insertErrorLog(List<SOMErrorLog__c>, String errMsg)          
 */                             
public with sharing class SOMBatchHistMgdOrders implements Database.Batchable<sObject>, Database.Stateful {
    List<SOMErrorLog__c> listErrorLog = new List<SOMErrorLog__c>();
    static final String ACTIVATED_ORDER_STATUS = 'Activated';
    static final String DRAFT_ORDER_STATUS = 'Draft';
    static final String PROCESSED_HIST_PROC_STATUS = 'Processed';
    static final String NOTPROCESSED_HIST_PROC_STATUS = 'Not Processed';
    static final String WORKING_HIST_PROC_STATUS = 'Working';

    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug(System.LoggingLevel.INFO, 'M:E SOMBatchHistMgdOrders.start');
        listErrorLog = SOMUtil.insertErrLog(listErrorLog, 'SOMBatchHistMgdOrders.start', 'Start', 'DEBUG', null, 'Order');

        return Database.getQueryLocator('SELECT Id, OrderNumber, Name, Type, Status, isHistMgd__c ' +
                                  		'FROM   Order ' +
                                  		'WHERE  isHistorical__c = true ' +
                                        'AND    Status = \'Activated\'' +
                                        'AND    HistoricalOrderProcStatus__c = \'Not Processed\'' +
                                        'ORDER BY createdDate DESC LIMIT 1000' );//SOQL#1
    }//end start
    
    public void execute(Database.BatchableContext bc, List<Order> listOrders){
        System.debug(System.LoggingLevel.INFO, 'M:E SOMBatchHistMgdOrders.execute');
        listErrorLog = SOMUtil.insertErrLog(listErrorLog, 'SOMBatchHistMgdOrders.execute', 'listOrders.size='+listOrders.size(), 'DEBUG', null, 'Order');
        System.debug(System.LoggingLevel.DEBUG, 'SOMBatchHistMgdOrders.execute: listOrders:'+listOrders);
        List<Order> listOrd2Upd = new List<Order>(); // list of order records to update statuses
        List<SOMHistOrdBatchProcErr__c> listBatchProcErr = new List<SOMHistOrdBatchProcErr__c>();   

        listErrorLog = SOMUtil.insertErrLog(listErrorLog, 'SOMBatchHistMgdOrders.execute', 'About to update all of the Orders in listOrders to "Activate/Working status.', 'DEBUG', null, 'Order');
        for(Order theOrder : listOrders){
            theOrder.Status = ACTIVATED_ORDER_STATUS; //Updating order status to 'Activated' will trigger the Create Order Summaries flow.
            theOrder.HistoricalOrderProcStatus__c = WORKING_HIST_PROC_STATUS;
            listOrd2Upd.add(theOrder);
        }// end listOrders for loop
        try{
            update listOrd2Upd; 
            listErrorLog = SOMUtil.insertErrLog(listErrorLog, 'SOMBatchHistMgdOrders.execute', 'update listOrders to Active/Working executed', 'DEBUG', null, 'Order');
        }catch(DmlException de){
            for(Integer i=0;i<de.getNumDml();i++){
                SOMHistOrdBatchProcErr__c theErr = new SOMHistOrdBatchProcErr__c();
                theErr.OrderId__c = de.getDmlId(i);
                theErr.Error_Message__c = de.getDmlMessage(i);
                listBatchProcErr.add(theErr);
                listErrorLog = SOMUtil.insertErrLog(listErrorLog, 'SOMBatchHistMgdOrders.execute', theErr.Error_Message__c, 'HIGH', theErr.OrderId__c, 'Order');
            }
            if(listBatchProcErr.size()>0){
                insert listBatchProcErr;
            }
        }

        List<ConnectApi.ConnectApiException> listApiExc = new List<ConnectApi.ConnectApiException>();
        List<ConnectApi.OrderSummaryOutputRepresentation> listOsOutput = new List<ConnectApi.OrderSummaryOutputRepresentation>();
        List<Order> listFinishedOrders = new List<Order>();
        List<Order> listOrdersWithErrs = new List<Order>();
        
        for(Order o : listOrders){
            Boolean noError = true;
            for(SOMHistOrdBatchProcErr__c err : listBatchProcErr){
                if(o.Id==err.OrderId__c){
                    noError = false;
                }
            }
            if(noError){
                // try to create the order summary!
                ConnectApi.OrderSummaryInputRepresentation input = new ConnectApi.OrderSummaryInputRepresentation();
                input.orderId = o.Id;
                if(o.isHistMgd__c){
                    input.orderLifeCycleType = 'MANAGED';
                }else{
                    input.orderLifeCycleType = 'UNMANAGED';
                }
                //input.name = o.OrderNumber;
                //input.status = ''; 
                try{
                    ConnectApi.OrderSummaryOutputRepresentation output = ConnectApi.OrderSummaryCreation.createOrderSummary(input);
                    listOsOutput.add(output);
                    Order theFinishedOrder = new Order();
                    theFinishedOrder.Id = o.Id;
                    theFinishedOrder.HistoricalOrderProcStatus__c = PROCESSED_HIST_PROC_STATUS;
                    listFinishedOrders.add(theFinishedOrder);
                }catch(ConnectApi.ConnectApiException e){
                    listApiExc.add(e);
                    Order theOrderWithErrs = new Order();
                    theOrderWithErrs.Status = 'Activated';
                    theOrderwithErrs.HistoricalOrderProcStatus__c = NOTPROCESSED_HIST_PROC_STATUS;
                    listOrdersWithErrs.add(theOrderwithErrs);
                    SOMHistOrdBatchProcErr__c theBatchProcErr = new SOMHistOrdBatchProcErr__c();
                    theBatchProcErr.OrderId__c = o.Id;
                    theBatchProcErr.Error_Message__c = e.getErrorCode() + ': ' + e.getMessage();
                    listBatchProcErr.add(theBatchProcErr);
                }
            }
        }// end listOrders loop for order summary creation        

        //update finished orders historical proc status to Processed
        if(listFinishedOrders.size()>0){
            try{
                update listFinishedOrders;
            }catch(DMLException e){
                for(Integer i=0;i<e.getNumDml();i++){
                    System.debug(System.LoggingLevel.ERROR, 'SOMBatchHistMgdOrders.execute: OrderSummary created for Order '+e.getDmlId(i)+
                                ' but unable to update HistoricalOrderProcStatus__c = '+PROCESSED_HIST_PROC_STATUS+': '+e.getDmlMessage(i));
                }
            }
        }

        //udpate orders with errors back to Draft status and Historical Proc Status to Not Processed
        if(listOrdersWithErrs.size()>0){
            try{
                update listOrdersWithErrs;
            }catch(DMLException e){
                for(Integer i=0;i<e.getNumDml();i++){
                    System.debug(System.LoggingLevel.ERROR, 'SOMBatchHistMgdOrders.execute: OrderSummary creation failed for Order '+e.getDmlId(i)+
                                ' and unable to update HistoricalOrderProcStatus__c = '+NOTPROCESSED_HIST_PROC_STATUS +
                                ' and Status = '+DRAFT_ORDER_STATUS +': '+e.getDmlMessage(i));
                }
            }
        }

        // Attach errors records to the orders where errors occurred
        if(listBatchProcErr.size()>0){
            try{
                update listBatchProcErr;
            }catch(DMLException e){
                for(Integer i=0;i<e.getNumDml();i++){
                    System.debug(System.LoggingLevel.ERROR, 'SOMBatchHistMgdOrders.execute: Order '+e.getDmlId(i)+
                                ' had errors but unable to insert Historical Order Batch Processing Error records: '+e.getDmlMessage(i));
                }
            }
        }

        System.debug(System.LoggingLevel.INFO, 'M:X SOMBatchHistMgdOrders.execute');
    }//end execute
    
    public void finish(Database.BatchableContext bc){
        System.debug(System.LoggingLevel.INFO, 'M:E SOMBatchHistMgdOrders.finished');
            // Get the ID of the AsyncApexJob representing this batch job
            // from Database.BatchableContext.
            // Query the AsyncApexJob object to retrieve the current job's information.
            String msg;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            AsyncApexJob a = [SELECT    Id, Status, NumberOfErrors, JobItemsProcessed,
                                        TotalJobItems, CreatedBy.Email
                              FROM      AsyncApexJob 
                              WHERE     Id = :BC.getJobId()];
            // Send an email to the Apex job's submitter notifying of job completion.
            try{
                If (a.TotalJobItems > 0 )
                {
                msg = 'The batch Apex job processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.';
                
                String[] toAddresses = new String[] {a.CreatedBy.Email};//TODO: uncomment this line for deployment into prod.
             //   String[] toAddresses = new String[] {'sharan.nataraj@salesforce.com'};//TODO: comment out this line for deployment into prod.

                mail.setToAddresses(toAddresses);
                mail.setSubject('Historical Managed Order Batch processing ' + a.Status);
                mail.setPlainTextBody(msg);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }catch(Exception e){
                System.debug('SOMBatchHistMgdOrders.finish error sending email: '+mail+'; ErrorMsg='+e.getmessage());
            }

        System.debug(System.LoggingLevel.INFO, 'M:X SOMBatchHistMgdOrders.finished');
    }//end finish
}