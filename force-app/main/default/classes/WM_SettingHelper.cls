public class WM_SettingHelper {
    public static Integer configuredBatchSize;
    public static Boolean debugMode;
    public static Integer reEvalTimeLimit;
    static{
        configuredBatchSize = 50;
        debugMode = FALSE;
        reEvalTimeLimit = 5;
        List<WM_Setting__mdt> wM_Settings = WM_Setting__mdt.getAll().values();
        if(wM_Settings != null && wM_Settings.size() > 0){
            if(wM_Settings[0].ReEval_Job_Batch_Size__c !=null && wM_Settings[0].ReEval_Job_Batch_Size__c > 0 ){
                configuredBatchSize = wM_Settings[0].ReEval_Job_Batch_Size__c.intValue();
            }
            if(wM_Settings[0].ReEval_Time_Limit_In_Minutes__c !=null && wM_Settings[0].ReEval_Time_Limit_In_Minutes__c > 0 ){
                reEvalTimeLimit = wM_Settings[0].ReEval_Time_Limit_In_Minutes__c.intValue();
            }
            if(wM_Settings[0].Debug_Mode__c !=null){
                debugMode = wM_Settings[0].Debug_Mode__c;
            }
        }

    }
}