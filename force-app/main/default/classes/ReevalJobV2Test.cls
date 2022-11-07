@isTest
public class ReevalJobV2Test {
    @isTest
    static void testReevalTrigger() {        
        ReEval_Data__c record = new ReEval_Data__c();
        record.Is_Processed__c = FALSE;
        record.BatchNumber__c = 1;
        insert record;

        record.Is_Processed__c = TRUE;
        update record;
    }
}