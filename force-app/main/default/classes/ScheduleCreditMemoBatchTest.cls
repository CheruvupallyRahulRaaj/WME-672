@isTest
public class ScheduleCreditMemoBatchTest {
    static testMethod void myTestMethod() {        
        test.starttest();
        ScheduleCreditMemoBatch myClass = new ScheduleCreditMemoBatch ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }
}