public class WM_ReevalQueueableFlowV2 implements Queueable,Database.AllowsCallouts {
    private List<Id> ordrDeliveryGroupIds;
    public WM_ReevalQueueableFlowV2(List<Id> OrderDeliveryGroupIds){
        Boolean debugMode = WM_SettingHelper.debugMode;
        if(debugMode){
            System.debug('AAA: CCC:  enqueuedJobSize: ' + OrderDeliveryGroupIds.size());
            for(ID odgId : OrderDeliveryGroupIds){
                System.debug('AAA: CCC:ODGID:' + odgId);
            }
        }
        this.ordrDeliveryGroupIds = OrderDeliveryGroupIds;
    }
    
    public void execute(QueueableContext context) {
        try{
            Boolean debugMode = WM_SettingHelper.debugMode;
            List<OrderDeliveryGroup> lstOrderDeliveryGroups = new List<OrderDeliveryGroup>();
            for(Id recordId : ordrDeliveryGroupIds){
                System.debug('AAA: ODGID: ' + recordId);
                OrderDeliveryGroup odg = new OrderDeliveryGroup();
                odg.Id = recordId;
                odg.Execute_Re_evaluate__c = TRUE;
                lstOrderDeliveryGroups.add(odg);
            }
            Database.SaveResult[] srList = Database.update(lstOrderDeliveryGroups, false);
            for(Database.SaveResult sr : srList){
                if(debugMode){
                    if(sr.isSuccess()){
                        System.debug('AAA: ID Updated Successfully:' + sr.getId());
                    }
                    else{
                        for(Database.Error err: sr.getErrors()){
                            System.debug('AAA: Error:' + sr.getId() + ' : ' + err.getMessage());
                        }
                    }
                }
            }

            Integer reEvalTimeLimt = WM_SettingHelper.reEvalTimeLimit;
            String uniqueName = 'Reeval Check ' + Datetime.now().getTime();
            ScheduleReEevalProcessCheckFlag a = new ScheduleReEevalProcessCheckFlag(new Set<Id>(ordrDeliveryGroupIds));
            System.scheduleBatch(a, uniqueName, reEvalTimeLimt);
        }
        catch(Exception e){           
        }
    }
}