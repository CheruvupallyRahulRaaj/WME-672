public class WM_CallReEvalFlow implements Queueable,Database.AllowsCallouts {
 private List<OrderDeliveryGroupSummary> ordrDeliveryGroupSumList;
 private Integer currentIndex;   
    public WM_CallReEvalFlow(Integer currIndex,List<OrderDeliveryGroupSummary> ordrDelGrpSumList){
        this.ordrDeliveryGroupSumList = ordrDelGrpSumList;
        this.currentIndex = currIndex;
    }
    
     public void execute(QueueableContext context) {
         try{
         Flow.Interview subflow;
         Map<String,String> inputVariablesMap = new Map<String,String>();
         inputVariablesMap.put('OrderDelGrpSummaryId',ordrDeliveryGroupSumList.get(currentIndex).Id);
         inputVariablesMap.put('OrderSummaryId',ordrDeliveryGroupSumList.get(currentIndex).OrderSummaryId);
         subflow = Flow.Interview.createInterview('WM_Re_evaluate_FulFillment_Order_Flow', inputVariablesMap);
             if(!test.isRunningTest()){
                subflow.start();    
             }
        
        if(currentIndex+1<ordrDeliveryGroupSumList.size()){
           System.enqueueJob(new WM_CallReEvalFlow(currentIndex+1,ordrDeliveryGroupSumList));  
         }
         }
         catch(Exception e){           
             system.debug('Exception occured for the Order Del Grp Summary Id '+ ordrDeliveryGroupSumList.get(currentIndex).Id + ' '+e);
         if(currentIndex+1<ordrDeliveryGroupSumList.size()){
           System.enqueueJob(new WM_CallReEvalFlow(currentIndex+1,ordrDeliveryGroupSumList));  
         }   
         }
         
 
         
     }
     }