global class WM_ScheduleOCICallRetrials implements Schedulable {
    global void execute(SchedulableContext ctx) {
         String shipmintId;
         String orderSumId;
         String  fulFillFlowApiName = 'WM_Re_trial_For_FulfillItem';
         String  transferResFlowApiName = 'WM_Re_trial_For_Transfer_Reservation';
         List<String> fulFillOrderIds =  new list<string>();
         List<String> shipmentIds_PE = new List<String> ();
         List<ProcessException> processExcepList =  new list<ProcessException>();
         Set<string> processExcepList_Fulfill = new Set<string> ();
         Set<string> processExcepList_Transfer = new Set<string> ();
        String dt = '2021-12-09 00:00:00';
        DateTime refDate = DateTime.valueOf(dt);
         // Get  the  max number for retry
         TransferInventory__c transferInventObject =[SELECT Id, Maximum_Number_of_Re_trials_for_Transfer__c FROM TransferInventory__c];
         Double maxNumRetry= transferInventObject.Maximum_Number_of_Re_trials_for_Transfer__c;
          // Get the shipment objects which eligible for retry
          List<Shipment> shipment_List =  [SELECT id, FulfillmentOrderId, OrderSummaryId, Re_trials_For_Fulfill_Items__c, Re_trials_For_Transfer_Reservation__c, Fulfill_Item_Success__c, Transfer_Reservation_Success__c FROM Shipment where (Fulfill_Item_Success__c = false OR Transfer_Reservation_Success__c = False) AND FulfillmentOrderId != null and createddate>:refDate order by createddate desc];
          
          for(Shipment ship: shipment_List) {
			  fulFillOrderIds.add(ship.FulfillmentOrderId);
              shipmentIds_PE.add(ship.id);
			}
          List<FulfillmentOrder> fulfillOrder_list = [select Id,OrderSummaryId from FulfillmentOrder WHERE id in :fulFillOrderIds];
          Map<Id, FulfillmentOrder> fulfillOrdersObj = new Map<Id, FulfillmentOrder>(FulfillOrder_list);
        
          // Get process exception which associates with shipment records
          List<ProcessException> processExcepList_Shipmnt =  [SELECT Id, Shipment__c, Category FROM ProcessException  WHERE Shipment__c in :shipmentIds_PE];
          for(ProcessException pe: processExcepList_Shipmnt) {
             if(pe.Category == 'Fulfillment') {
                 processExcepList_Fulfill.add(pe.Shipment__c);
             } else if(pe.Category == 'Transfer Inventory') {
                 processExcepList_Transfer.add(pe.Shipment__c);
             }
          }
        
        List<String> listOfprocessFulfillShipmentIds = new List<String>();
        List<String> listOfprocessTransferShipmentIds = new List<String>();
			for(Shipment ship: shipment_List) {
                shipmintId = ship.id;
                orderSumId = fulfillOrdersObj.get(ship.FulfillmentOrderId).OrderSummaryId;
                // Retry Fullfill Item
               if(!processExcepList_Fulfill.contains(ship.Id) && !ship.Fulfill_Item_Success__c) {
                    // Set default value for 'Re_trials_For_Fulfill_Items__c' field
                    if(ship.Re_trials_For_Fulfill_Items__c == null) {
                       ship.Re_trials_For_Fulfill_Items__c = 0.0;
                    }
                    if(ship.Re_trials_For_Fulfill_Items__c < maxNumRetry) {
                        listOfprocessFulfillShipmentIds.add(shipmintId);
                        //callRe_trialflow(fulFillFlowApiName, shipmintId);
                        ship.Re_trials_For_Fulfill_Items__c += 1.0;
    
                    } else {
                        ProcessException pe = new ProcessException(AttachedToId= ship.FulfillmentOrderId, OrderSummaryId= orderSumId, Shipment__c= ship.Id, Message= 'Unable to Fullfill Payment', Description = 'Unable to Fullfill Payment', Category = 'Fulfillment');
                             processExcepList.add(pe);
                     }
                 }
               
                 // Retry Transfer Reservation
              if(!processExcepList_Transfer.contains(ship.Id) && !ship.Transfer_Reservation_Success__c) {
                    // Set default value for 'Re_trials_For_Transfer_Reservation__c' field
                    if(ship.Re_trials_For_Transfer_Reservation__c == null) {
                       ship.Re_trials_For_Transfer_Reservation__c = 0.0;
                    }
                    if(ship.Re_trials_For_Transfer_Reservation__c < maxNumRetry) {
                         listOfprocessTransferShipmentIds.add(shipmintId);
                        //callRe_trialflow(transferResFlowApiName, shipmintId);
                        ship.Re_trials_For_Transfer_Reservation__c += 1.0;
    
                    } else {
                        ProcessException pe = new ProcessException(AttachedToId= ship.FulfillmentOrderId, OrderSummaryId= orderSumId, Shipment__c= ship.Id, Message= 'Unable to Transfer Inventory Reservation from Location to Location group', Description = 'Unable to Transfer Inventory Reservation from Location to Location group', Category = 'Transfer Inventory');
                             processExcepList.add(pe);
                     }
                } 
            
          }
        
        if(listOfprocessTransferShipmentIds.size()>0){
            callRe_trialflow(transferResFlowApiName,listOfprocessTransferShipmentIds);
        }
           if(listOfprocessFulfillShipmentIds.size()>0){
            callRe_trialflow(fulFillFlowApiName,listOfprocessFulfillShipmentIds);
        }
             Database.update(shipment_List);
          if(processExcepList.size() > 0) {
             Database.insert(processExcepList);
          }
    
    }  
     public static void callRe_trialflow(String flowApiName, List<String> shipmentIds) {
          System.enqueueJob(new WM_CallRetryFlowQueueable(flowApiName,shipmentIds,0));
     }  
    

}