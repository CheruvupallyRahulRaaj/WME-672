global class ShipmentEmailBatch implements Database.Batchable<String>,Database.AllowsCallouts {
    
 global Iterable<String> start(Database.BatchableContext BC) {
        DateTime refDate = Datetime.valueOf('2021-09-21 00:00:00');
        String statusValue = 'FulFilled';
        String query;
     if(!Test.isRunningTest()){
         query = 'SELECT Id, Confirmation_Email_Sent__c,FulFillmentOrder.Status FROM Shipment where  FulFillmentOrder.Status =:statusValue and Confirmation_Email_Sent__c=false and createddate>:refDate and FulFillmentOrder.type!=\'Store/Hub To Store\'';
     }
     else{
          query = 'SELECT Id, Confirmation_Email_Sent__c,FulFillmentOrder.Status FROM Shipment where  FulFillmentOrder.Status =:statusValue and Confirmation_Email_Sent__c=false and createddate>:refDate and FulFillmentOrder.type!=\'Store/Hub To Store\' limit 10';
     
     }
         List<Shipment> shipments =Database.query(query);
           List<String> shipmentIds = new List<String>();
        for(Shipment ship:shipments){
           shipmentIds.add(ship.Id);
        }
        return shipmentIds;
     
    }
    global void execute(Database.BatchableContext BC, List<String> scope) {
      WM_TransactionalEmails.sendEmailForShipmentConfirmation(scope);        
    }   
    
    global void finish(Database.BatchableContext BC) {
     
    }
}