global class ScheduleReEvaluateFlow implements Schedulable {
    global void execute(SchedulableContext ctx) {
        List<OrderDeliveryGroupSummary> ordrDelgrpSumList = new List<OrderDeliveryGroupSummary>();
          if(!test.isRunningTest()){
     	ordrDelgrpSumList = [SELECT Id, PartiallyFulfilled__c,
                                                          OrderSummaryId FROM OrderDeliveryGroupSummary where PartiallyFulfilled__c=true and
                                                          OrderSummary.Hold_Re_evaluation__c = false  order by createddate desc];
          }
        else{
            ordrDelgrpSumList = [SELECT Id, PartiallyFulfilled__c,
                                                          OrderSummaryId FROM OrderDeliveryGroupSummary where PartiallyFulfilled__c=true and
                                                          OrderSummary.Hold_Re_evaluation__c = false order by createddate desc limit 1];
            system.debug('ordrDelgrpSumList ' + ordrDelgrpSumList);
            
        }
        if(ordrDelgrpSumList.size()>0){
             System.enqueueJob(new WM_CallReEvalFlow(0,ordrDelgrpSumList));
        } 
       
    }
}