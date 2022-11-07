/** 
 * Author : Perfaware
 * This class is implements Batchable interface to send BOPIS reminder emails.
 * This is invoked from ScheduleBopisReminderEmail.cls
 * Added as part of WME-82
*/

global class WM_BatchForBopisEmailReminder implements Database.Batchable<String>,Database.AllowsCallouts {
    
    global Iterable<String> start(Database.BatchableContext BC) {
         String query;
        //DateTime offsetHoursAgo = System.now().addMinutes(-10);
        //system.debug('***System Time 48 hours ago***' +offsetHoursAgo);
        String  offsetHoursRetail = Offset_for_Email_Reminder_List__c.getValues('BOPISReminderRetail').Time_Offset__c;
        System.debug ('Integer value ::' +Integer.valueOf(offsetHoursRetail));
        DateTime offsetHoursAgoRetail = System.now().addHours(Integer.valueOf(offsetHoursRetail));
        system.debug('***System Time Retail offset hours ago***' +offsetHoursAgoRetail);
        
        String  offsetHoursPro = Offset_for_Email_Reminder_List__c.getValues('BOPISReminderPro').Time_Offset__c;
        System.debug ('Integer value ::' +Integer.valueOf(offsetHoursPro));
        DateTime offsetHoursAgoPro = System.now().addHours(Integer.valueOf(offsetHoursPro));
        system.debug('***System Time Pro offset hours ago***' +offsetHoursAgoPro);
        
        String  offMaxCount = Offset_for_Email_Reminder_List__c.getValues('MaxReminderEmailCount').Time_Offset__c;
        Integer iMaxCount=Integer.valueOf(offMaxCount);
        System.debug ('Max Reminder Count::' +Integer.valueOf(offMaxCount));
        
        if(!Test.isRunningTest()){  
         //query = 'Select Id,Status,WM_Initial_Mail_Sent__c, WM_Email_Sent_Date_Time__c, BOPIS__c from FulfillmentOrder where BOPIS__c = true AND WM_Initial_Mail_Sent__c=true AND Status=\'Pickpack\' AND ((OrderSummary.SalesChannel.SalesChannelName=\'WestMarine\' AND WM_Email_Sent_Date_Time__c<= :offsetHoursAgoRetail) OR (OrderSummary.SalesChannel.Type__c=\'Pro\' AND WM_Email_Sent_Date_Time__c<= :offsetHoursAgoPro))';
           query = 'Select Id,Status,WM_Initial_Mail_Sent__c, WM_Email_Sent_Date_Time__c, BOPIS__c from FulfillmentOrder where BOPIS__c = true AND WM_Initial_Mail_Sent__c=true AND Status=\'Pickpack\' AND (WM_ReminderEmailCount__c =null OR WM_ReminderEmailCount__c < :iMaxCount) AND  ((OrderSummary.SalesChannel.SalesChannelName=\'WestMarine\' AND WM_Email_Sent_Date_Time__c<= :offsetHoursAgoRetail) OR (OrderSummary.SalesChannel.Type__c=\'Pro\' AND WM_Email_Sent_Date_Time__c<= :offsetHoursAgoPro))';
        }
        else{
        query = 'Select Id,Status,BOPIS__c from FulfillmentOrder where BOPIS__c = true AND Status=\'Pickpack\' limit 3';
       
        }
            List<FulfillmentOrder> fulfillorders = Database.query(query);
            system.debug('***Fulfillment Orders List Size***' + fulfillorders.size());
            List<String> fulfillIds = new List<String>();   
            if(fulfillorders.size()>0){
           for(FulfillmentOrder fOrd:fulfillorders){
               System.debug('@@@@ FO Id '+fOrd.Id);
              fulfillIds.add(fOrd.Id);
              System.debug('@@@@ List of Ids '+fulfillIds);
           }
            }
           return fulfillIds;
       }
       global void execute(Database.BatchableContext BC, List<String> scope) {
         WM_BopisEmailReminderHelper.emailForPickup(scope);            
       }          
       
       global void finish(Database.BatchableContext BC) {
        
       }
   }