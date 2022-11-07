global class EmailService implements Database.Batchable<String>,Database.AllowsCallouts {
    
    global Iterable<String> start(Database.BatchableContext BC) {
        String statusValue = 'ORDERED';
        String typeValue = 'Delivery Charge';
        DateTime refDate = Datetime.valueOf('2021-09-03 00:00:00');
        String query;
          if(!Test.isRunningTest()){ 
         query = 'SELECT Id, EmailAddress,GiftMessage,IsGift,DeliverToName,PartiallyFulfilled__c,(Select Id,Status,LastEmailSent__c,Type From OrderItemSummaries where Status =:statusValue AND Type!=:typeValue  AND  ( LastEmailSent__c = null Or LastEmailSent__c = NEXT_N_DAYS:30 )) FROM OrderDeliveryGroupSummary where  PartiallyFulfilled__c = true and createddate>:refDate';
          }
        else{
           query = 'SELECT Id, EmailAddress,GiftMessage,IsGift,DeliverToName,PartiallyFulfilled__c,(Select Id,Status,LastEmailSent__c,Type From OrderItemSummaries where Status =:statusValue AND Type!=:typeValue  AND  ( LastEmailSent__c = null Or LastEmailSent__c = NEXT_N_DAYS:30 )) FROM OrderDeliveryGroupSummary where  PartiallyFulfilled__c = true and createddate>:refDate limit 10';
          
        }
              List<OrderDeliveryGroupSummary> ordrDelGrpSumList =Database.query(query);
           List<String> ordrItemSumids = new List<String>();
        for(OrderDeliveryGroupSummary ordDelGrpSum:ordrDelGrpSumList){
            for(OrderItemSummary ordrItemSum:ordDelGrpSum.OrderItemSummaries){
                ordrItemSumids.add(ordrItemSum.Id);
            }
        }
        return ordrItemSumids;
     
    }
    global void execute(Database.BatchableContext BC, List<String> scope) {
      WM_TransactionalEmails.sendEmailForBackOrder(scope);        
    }   
    
    global void finish(Database.BatchableContext BC) {
     
    }
    
}