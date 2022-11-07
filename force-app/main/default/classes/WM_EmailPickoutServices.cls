public class WM_EmailPickoutServices {
    @InvocableMethod(label='EmailForPickoutcall')
    public static void emailPickoutcall(List<Id> fulfillmentIds){
        // sendEmailForCancelBOPIS(ordrSumIds[0],false,true);
        emailForPickoutFailure(fulfillmentIds[0]);
    }
    //@InvocableMethod(label='EmailForPickoutcall')
    public static void emailForPickoutFailure(String fulfillmentId){
        Map<String,Boolean> mapOfFulFillmentIDWithResult = new Map<String,Boolean>();
        System.debug('inside email class');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String dt = '2021-09-03 00:00:00';
        //DateTime refDate = DateTime.valueOf(dt); 
        List<FulFillmentOrder> failedPickouts = [Select Id,OrderSummaryId,Type From FulfillmentOrder WHERE Id = :fulfillmentId];
        Id ordrSumId = failedPickouts[0].OrderSummaryId;
        List<OrderSummary> OrderSummaryList = [Select Id,AccountId,GrandTotalAmount,SalesChannelId,
                                                   SalesChannel.SalesChannelName,OrderNumber,BillingEmailAddress,
                                                   BillingStreet, BillingCity, BillingState, BillingPostalCode,
                                                   BillingCountry From OrderSummary where id =:ordrSumId];
        if(failedPickouts.size()>0){
            
            String[] toAddresses = new String[]{};//address need to send, custom setting email addresses
                List<EmailAddresses__c> emailAddresses = [SELECT Id, EmailAddress__c, name FROM EmailAddresses__c];
            for(EmailAddresses__c eml: emailAddresses ){
                toAddresses.add(eml.EmailAddress__c);
            }
            mail.setSaveAsActivity( false );
            mail.setToAddresses(toAddresses);
            //mail.setReplyTo('shravanya.padala@genzeon.com'); // Add here your email address
            mail.setSenderDisplayName('Pickout Service Failure from '+ System.Label.OrgName);//+ custom setting with orgname 
            
            mail.setSubject('Failed Pickout services');
            String finalBodyForEmail = '';
            for(Integer i=0;i<failedPickouts.size();i++){
                String bodyPart1 = String.valueOf(i+1)+'.) '+' The Fulfillment number '+failedPickouts[i].Id+' Order Number: '+OrderSummaryList[0].OrderNumber;
                String bodyPart2 = ' failed with the error is: '+ 'Pickout Service Failure'+'\n' ;
                finalBodyForEmail = finalBodyForEmail+bodyPart1+bodyPart2;
            }
            mail.setPlainTextBody(finalBodyForEmail);
            System.debug('mailsssss'+ mail);
            Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
        }
    }
}