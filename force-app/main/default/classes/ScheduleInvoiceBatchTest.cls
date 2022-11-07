@isTest
public class ScheduleInvoiceBatchTest {
    static testMethod void myTestMethod() {        
        test.starttest();
        ScheduleInvoiceBatch myClass = new ScheduleInvoiceBatch ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }
}