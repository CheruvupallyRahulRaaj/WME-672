global without sharing class SOMUtil {
    public SOMUtil() {

    }
    global static List<SOMErrorLog__c> insertErrLog(List<SOMErrorLog__c> listLog, String methodName, String errMsg, 
                                                     String severity, String recordId, String sObjName){
        Boolean write2ErrLog = true; // this should be controlled by custom setting or custom metadata, for now just make it work!                                                         
        if(write2ErrLog){// Only add records to the error log if explicitly set to do so.
            SOMErrorLog__c log = new SOMErrorLog__c();
            if(String.isEmpty(severity)){
                log.Severity__c = 'DEBUG';
            }else{
                log.Severity__c = severity;
            }
            log.MethodName__c = methodName;
            log.ErrMsg__c = errmsg;
            log.RecordId__c = recordId;
            log.ObjectName__c = sObjName;
            listLog.add(log);
        }
        return listLog;
    }    
}