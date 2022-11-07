global class WM_ScheduleTransferInventory implements Schedulable {
    global void execute(SchedulableContext ctx) {
        
        List<FulfillmentOrder> fulfilOrderList = new List<FulfillmentOrder>();
        String dt = '2021-11-11 00:00:00';
        DateTime refDate = DateTime.valueOf(dt);
        TransferInventory__c maaxReTrials = [SELECT Id,NAME, Maximum_Number_of_Re_trials_for_Transfer__c FROM TransferInventory__c limit 1];
        fulfilOrderList = [SELECT Id, Status,Tranfered_Inventory__c,Type,
                           Re_trials_for_Tranfer_Inventory__c FROM FulfillmentOrder where Status = 'Pending Transfer' and Scheduler_Flag__c=true and (Type = 'Store/Hub To Store' OR Type ='Store/Hub to Home' OR Type = 'Warehouse to Store' OR Type ='Warehouse to Home')
                           and Re_trials_for_Tranfer_Inventory__c <:maaxReTrials.Maximum_Number_of_Re_trials_for_Transfer__c  
                           and Tranfered_Inventory__c = false  and createddate >:refDate ];
        
        for(FulfillmentOrder fulfil: fulfilOrderList ){
            
            fulfil.Re_trials_for_Tranfer_Inventory__c = fulfil.Re_trials_for_Tranfer_Inventory__c+1;
            
        }
        update fulfilOrderList;
    }
}