global class ScheduleReEevalProcessCheckFlag implements Database.Batchable<sObject>{
    Set<Id> OrderDeliveryGroupIds = null;
    global ScheduleReEevalProcessCheckFlag(Set<Id> ordrDeliveryGroupIds){
        OrderDeliveryGroupIds = ordrDeliveryGroupIds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT ID,OrderDeliveryGroupID__c ,Is_Processed__c,Is_Error__c  From ReEval_Data__c WHERE Is_Processed__c = FALSE AND OrderDeliveryGroupId__c IN :OrderDeliveryGroupIds');
    }

    public void execute(Database.BatchableContext BC,List<ReEval_Data__c> scope){
        Boolean debugMode = WM_SettingHelper.debugMode;
        for(ReEval_Data__c record : scope){
            if(debugMode){
                System.debug('AAA:' + record.Id + ' ODGID:' + record.OrderDeliveryGroupID__c + ' :Is_Processed__c:' + record.Is_Processed__c + ' : IsError:' + record.Is_Error__c);
            }
            record.Is_Processed__c = TRUE;
            record.Is_Error__c = TRUE;
        }

        if(scope.size()>0){
            update scope;
            if(debugMode){
                System.debug('AAA: Updated Scope');
            }
        }
    }
    public void finish(Database.BatchableContext BC){ }
}