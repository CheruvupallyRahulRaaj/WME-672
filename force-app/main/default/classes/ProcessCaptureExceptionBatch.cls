public class ProcessCaptureExceptionBatch implements Database.Batchable<SObject> {
    private PaymentGateway paymentGateway = NULL;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,Message,Category,OrderSummaryId FROM ProcessException where 
											Category = 'Payment' and Message = 'Unable to Capture Payment']);
        
        /*return Database.getQueryLocator([SELECT Id,Message,Category,OrderSummaryId FROM ProcessException where 
                                         Category = 'Payment' and Message = 'Unable to Capture Payment' and Id IN ('2Pe5C0000004CJwSAM','2Pe5C0000004CJmSAM')]);*/
    }
    
    
    public void execute(Database.BatchableContext bc, List<ProcessException> processExceptionList){
        system.debug('processExceptionList:'+processExceptionList);
        Set<Id> orderSummaryIds = new Set<Id>();
        Map<Id,Id> orderSummaryMap = new Map<Id,Id>();
        List<OrderSummary> orderSummaryList = new List<OrderSummary>();
        List<Invoice> updateInvoice = new List<Invoice>();
        for(ProcessException pe : processExceptionList) {
            orderSummaryIds.add(pe.OrderSummaryId);
        }
        for(OrderSummary os : [Select id,AccountId,(SELECT TYPEOF PaymentMethod WHEN CardPaymentMethod THEN CardCategory END FROM OrderPaymentSummaries),(Select id,Failed_Capture__c,InvoiceServiceFlag__c,TotalAmount from Invoices WHERE Failed_Capture__c = TRUE) from OrderSummary where Id IN: orderSummaryIds]) {
            if(os.OrderPaymentSummaries!= NULL && os.OrderPaymentSummaries.size()!=1) continue;
            if(os.OrderPaymentSummaries[0].PaymentMethod== NULL || os.OrderPaymentSummaries[0].PaymentMethod.get('CardCategory') != 'CreditCard') continue;
            orderSummaryMap.put(os.Id,os.OrderPaymentSummaries[0].Id);
            orderSummaryList.add(os);
        }
        system.debug('orderSummaryMap:'+orderSummaryMap);
        system.debug('orderSummaryList:'+orderSummaryList);
         Map<Id,PaymentAuthorization> paymentAuthMap = new Map<Id,PaymentAuthorization>();
        for(PaymentAuthorization pa: [Select id,OrderPaymentSummaryId from PaymentAuthorization where OrderPaymentSummaryId IN: orderSummaryMap.Values()]) {
            paymentAuthMap.put(pa.OrderPaymentSummaryId,pa);
        }
        //paymentGateway = [Select Id,PaymentGatewayName from PaymentGateway where PaymentGatewayName = 'SalesforceAdapter' limit 1];
        List<Payment> paymentRecordsInsert = new List<Payment>();
        List<PaymentLineInvoice> paymentInvoiceLineRecordsInsert = new List<PaymentLineInvoice>();
        set<Id> paymentInvoiceLineIds = new set<Id>();
        List<PaymentWrapper> lstWrappers = new List<PaymentWrapper>();
        for(OrderSummary os : orderSummaryList) {
            for(Invoice inv : os.Invoices){
                Payment pr = createPaymentMethodRecord(paymentAuthMap,os,inv);
                PaymentLineInvoice pli = createInvoiceLineRecord(pr,inv.Id);
                PaymentWrapper wrapper = new PaymentWrapper();
                wrapper.paymentRecord = pr;
                wrapper.paymentLineInvoiceRecord= pli;
                paymentRecordsInsert.add(pr);
                lstWrappers.add(wrapper);
            }
        }
        system.debug('paymentRecordsInsert:'+paymentRecordsInsert);
        if(paymentRecordsInsert.size() > 0) {
            insert paymentRecordsInsert;
        }
        for(PaymentWrapper wrapper : lstWrappers){
            Id paymentId = wrapper.paymentRecord.Id;
            if(paymentId != null){
                wrapper.paymentLineInvoiceRecord.PaymentId = paymentId;
                paymentInvoiceLineRecordsInsert.add(wrapper.paymentLineInvoiceRecord);
            }
        }
        if(paymentInvoiceLineRecordsInsert.size()>0){
            insert paymentInvoiceLineRecordsInsert;
        }
        
        List<Invoice> lstInvoices = new List<Invoice>();
        for(PaymentWrapper wrapper : lstWrappers){
            if(wrapper.paymentLineInvoiceRecord.Id !=null){
                Invoice inv = new Invoice();
                inv.Id = wrapper.PaymentLineInvoiceRecord.InvoiceId;
                inv.Failed_Capture__c= FALSE;
                inv.InvoiceServiceFlag__c = TRUE;
                lstInvoices.add(inv);
            }
        }
        List<Id> succesfulUpdatedInvoiceIds = new List<Id>();
        if(lstInvoices.size() > 0) {
            //update lstInvoices;
            Database.SaveResult[] lsr = Database.update(lstInvoices,false);
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted:' + sr.getId());
                    succesfulUpdatedInvoiceIds.add(sr.getId());
                } 
            }
            List<Id> successfulOrderSummaryIds = new List<Id>();
            for(Invoice inv : [Select id,InvoiceName__r.InvoiceCredNum__c,ReferenceEntityId from Invoice where id IN: succesfulUpdatedInvoiceIds]) {
                system.debug('InvoiceCredNum__c:'+inv.InvoiceName__r.InvoiceCredNum__c);
                successfulOrderSummaryIds.add(inv.ReferenceEntityId);
            }
            List<ProcessException> delRecs = [Select id from ProcessException where OrderSummaryId IN: successfulOrderSummaryIds];
            system.debug('delRecs:'+delRecs);
            if(delRecs.size() > 0) {
                delete delRecs;
            }
        }
        
    } 
    
    Private Payment createPaymentMethodRecord(Map<Id,PaymentAuthorization> paymentAuthMap,orderSummary os,Invoice invoiceRecord) {
        system.debug('createPaymentMethodRecord:');
        Payment insertPayment = new Payment();
        insertPayment.Amount = invoiceRecord.TotalAmount;
        insertPayment.OrderPaymentSummaryId = os.OrderPaymentSummaries[0].Id;
        insertPayment.Type = 'Capture';
        insertPayment.Status = 'Processed';
        if(paymentAuthMap.containsKey(os.OrderPaymentSummaries[0].Id)) {
            insertPayment.PaymentAuthorizationId = paymentAuthMap.get(os.OrderPaymentSummaries[0].Id).id;
        }
        insertPayment.PaymentMethodId = (ID)os.OrderPaymentSummaries[0].PaymentMethod.get('Id');
        insertPayment.ProcessingMode = 'External';
        insertPayment.AccountId = os.AccountId;
        return insertPayment;
    }    
    
    Private PaymentLineInvoice createInvoiceLineRecord(Payment paymentR,Id invoiceId) {
        system.debug('createInvoiceLineRecord:');
        PaymentLineInvoice insertPaymentInvoiceLine = new PaymentLineInvoice();
        insertPaymentInvoiceLine.PaymentId = paymentR.Id;
        insertPaymentInvoiceLine.InvoiceId = invoiceId;
        insertPaymentInvoiceLine.Amount = paymentR.Amount;
        insertPaymentInvoiceLine.Type = 'Applied';
        //TODO: Has Been Applied: 'No'
        return insertPaymentInvoiceLine;
    }    
    public void finish(Database.BatchableContext bc){   
        
    }
    
    public class PaymentWrapper{
        public Payment paymentRecord;
        public PaymentLineInvoice paymentLineInvoiceRecord;
	}
}