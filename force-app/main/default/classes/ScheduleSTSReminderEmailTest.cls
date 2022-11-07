@isTest
public class ScheduleSTSReminderEmailTest {
    static testMethod void myTestMethod() {        
        test.startTest();
         List<Offset_for_Email_Reminder_List__c> custlist= new List<Offset_for_Email_Reminder_List__c>();
        Offset_for_Email_Reminder_List__c mycust1=new Offset_for_Email_Reminder_List__c ();
        mycust1.Name='STSReminderRetail';
        mycust1.Time_Offset__c='-6';
        
        Offset_for_Email_Reminder_List__c mycust2=new Offset_for_Email_Reminder_List__c ();
        mycust2.Name='STSReminderPro';
        mycust2.Time_Offset__c='-6';
        
        Offset_for_Email_Reminder_List__c mycust3=new Offset_for_Email_Reminder_List__c ();
        mycust3.Name='MaxReminderEmailCount';
        mycust3.Time_Offset__c='5';
        
        custlist.add(mycust1);
        custlist.add(mycust2);
        custlist.add(mycust3);
        
        insert custlist;
        
        ScheduleSTSReminderEmail myClass = new ScheduleSTSReminderEmail();   
        String chron = '0 0 0 * * ?';        
        System.schedule('ScheduleSTSReminderEmail', chron, myClass);
        test.stopTest();
    }
}