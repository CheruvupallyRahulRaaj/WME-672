@isTest
public class ScheduleHistOrderBatchTest {
        static testMethod void myTestMethod() {        
        test.starttest();
        ScheduleHistOrderBatch myClass = new ScheduleHistOrderBatch ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }
    static testMethod void myTestfailure() {        
        test.starttest();
        ScheduleHistOrderBatch myClass = new ScheduleHistOrderBatch ();   
        String chron = '0 0 20 * * ?';        
        system.schedule('Test failure', chron, myClass);
        test.stopTest();
    }

}