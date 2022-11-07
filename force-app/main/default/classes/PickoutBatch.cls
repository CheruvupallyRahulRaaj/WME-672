public class PickoutBatch implements Database.Batchable<Id>, Database.AllowsCallouts {
    public Iterable<Id> start(Database.BatchableContext bc){ 
        String dt = '2021-09-03 00:00:00';
        DateTime refDate = DateTime.valueOf(dt);

        String enddateStr = '2022-08-26 00:00:00';
        DateTime endDate = DateTime.valueOf(enddateStr);
        
        Map<Id,FulFillmentOrder> fulfillmentOrders = new Map<Id,FulFillmentOrder>([
            SELECT Id 
            FROM FulfillmentOrder 
            WHERE 
                status = 'Assigned' 
            AND 
                FulfilledFromLocation.LocationType = 'Warehouse' 
            AND 
                CreatedDate>:refDate
            AND
                CreatedDate < :endDate
            LIMIT 100
            ]);
        return new List<Id>(fulfillmentOrders.keySet());
    }     
    public void execute(Database.BatchableContext bc, List<String> scope){
        WM_NewPickOutService.pickOutService(scope);
        
    }     
    public void finish(Database.BatchableContext bc){   
    } 
}