public class ReEvalFirstBatch implements Queueable{
    private List<ReEval_Data__c> lstNewReEvalData;
    public ReEvalFirstBatch(List<ReEval_Data__c> data){
        lstNewReEvalData = data;
    }
    public void execute(QueueableContext context){
        Boolean debugMode = WM_SettingHelper.debugMode;
        Database.insert(lstNewReEvalData,false);
        List<Id> lstOrderDeliveryGroupIds = new List<Id>();
        List<ReEval_Data__c> lstData = [Select OrderDeliveryGroupID__c From ReEval_Data__c WHERE Is_Processed__c = FALSE AND BatchNumber__c = 1];
        if(debugMode){
            System.debug('AAA: Size Of ReevalData:' + lstData.size());
        }
        for(ReEval_Data__c record : lstData){
            lstOrderDeliveryGroupIds.add(record.OrderDeliveryGroupID__c);
            if(debugMode){
                System.debug('ODG ID: ' + record.OrderDeliveryGroupID__c);
            }
        }
        if(lstOrderDeliveryGroupIds.size()>0){
            Id jobId = System.enqueueJob(new WM_ReevalQueueableFlowV2(lstOrderDeliveryGroupIds));
            if(debugMode){
                System.debug('Job ID: ' + jobId);
            }
        }

    }
}