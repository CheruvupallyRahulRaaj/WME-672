@isTest
public class ScheduleBopisReminderEmailTest {
    static testMethod void myTestMethod() {        
        test.startTest();
        List<Offset_for_Email_Reminder_List__c> custlist= new List<Offset_for_Email_Reminder_List__c>();
        Offset_for_Email_Reminder_List__c mycust1=new Offset_for_Email_Reminder_List__c ();
        mycust1.Name='BOPISReminderRetail';
        mycust1.Time_Offset__c='-48';
        
        Offset_for_Email_Reminder_List__c mycust2=new Offset_for_Email_Reminder_List__c ();
        mycust2.Name='BOPISReminderPro';
        mycust2.Time_Offset__c='-48';
        
        Offset_for_Email_Reminder_List__c mycust3=new Offset_for_Email_Reminder_List__c ();
        mycust3.Name='MaxReminderEmailCount';
        mycust3.Time_Offset__c='5';
        
        custlist.add(mycust1);
        custlist.add(mycust2);
        custlist.add(mycust3);
        
        insert custlist;
           
        ScheduleBopisReminderEmail myClass = new ScheduleBopisReminderEmail();   
        String chron = '0 0 0 * * ?';        
        System.schedule('ScheduleBopisReminderEmail', chron, myClass);
        test.stopTest();
    }
}