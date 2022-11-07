public class CreditMemoBatchApex implements Database.Batchable<String>, Database.AllowsCallouts { 
    
    public Iterable<string> start(Database.BatchableContext bc){ 
        String dt = '2021-09-03 00:00:00';
        DateTime refDate = DateTime.valueOf(dt);
        List<CreditMemo> invList = new List<CreditMemo>();
        if(!test.isRunningTest()){
            invList = [Select Id,CreditMemoServiceFlag__c,Available_for_Service_Request__c,ReferenceEntityId from CreditMemo where CreditMemoServiceFlag__c=false and Available_for_Service_Request__c=true and CreatedDate>:refDate and Failed_Refund__c=false ];
    }
    else{
            invList = [Select Id,CreditMemoServiceFlag__c,Available_for_Service_Request__c,ReferenceEntityId from CreditMemo where CreditMemoServiceFlag__c=false and Available_for_Service_Request__c=true and CreatedDate>:refDate and Failed_Refund__c=false  limit 5];
        }
       
        Map<String,List<String>> mapOfordrSummaryIdWithInvoice = new Map<String,List<String>>();
        for(CreditMemo inv:invList){
            if(mapOfordrSummaryIdWithInvoice.containsKey(inv.ReferenceEntityId)){
                List<String> tempList = mapOfordrSummaryIdWithInvoice.get(inv.ReferenceEntityId);
                tempList.add(inv.Id);
                mapOfordrSummaryIdWithInvoice.put(inv.ReferenceEntityId,tempList);
            }
            else{
                mapOfordrSummaryIdWithInvoice.put(inv.ReferenceEntityId,new List<String>{inv.Id});    
            }
            
        }
        
        List<String> removeInvoiceIds = new List<String>();
        List<ProcessException> proExceptionList = [Select Id,OrderSummaryId from ProcessException where Category='Refund' and OrderSummaryId In:mapOfordrSummaryIdWithInvoice.keySet()];
        for(ProcessException pE:proExceptionList){
            if(mapOfordrSummaryIdWithInvoice.containskey(pE.OrderSummaryId)){
                removeInvoiceIds.addAll(mapOfordrSummaryIdWithInvoice.get(pE.OrderSummaryId));
            }
        }
        
        list<String> invoiceIds = new List<String>();
        for(CreditMemo inv:invList){
            if(!removeInvoiceIds.contains(inv.id)){
            invoiceIds.add(inv.Id);     
            }
                
        }
        return invoiceIds;
        
    }     
    public void execute(Database.BatchableContext bc, List<String> scope){
        WM_CreditMemoService.callCreditMemoService(scope);
        
    }     
    public void finish(Database.BatchableContext bc){   
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String dt = '2021-09-03 00:00:00';
        DateTime refDate = DateTime.valueOf(dt);
        List<CreditMemo> failedCrditMemo = new List<CreditMemo>();
        if(!test.isRunningTest()){
            failedCrditMemo = [SELECT Id, CreatedDate, JDAInvoiceCreditNumber__r.InvoiceCredNum__c, Last_Logged_Service_Error__c,
                                            CreditMemoServiceFlag__c FROM CreditMemo where CreditMemoServiceFlag__c = false and Available_for_Service_Request__c = true and CreatedDate>:refDate]; 
        }
        else{               
            failedCrditMemo = [SELECT Id, CreatedDate, JDAInvoiceCreditNumber__r.InvoiceCredNum__c, Last_Logged_Service_Error__c,
            CreditMemoServiceFlag__c FROM CreditMemo where CreditMemoServiceFlag__c = false and Available_for_Service_Request__c = true and CreatedDate>:refDate limit 5]; 
        }  
            
        if(failedCrditMemo.size()>0){
            
            String[] toAddresses = new String[]{};//address need to send, custom setting email addresses
                List<EmailAddresses__c> emailAddresses = [SELECT Id, EmailAddress__c, name FROM EmailAddresses__c];
            for(EmailAddresses__c eml: emailAddresses ){
                toAddresses.add(eml.EmailAddress__c);
            }
            mail.setToAddresses(toAddresses);
            //mail.setReplyTo('test@test.com'); // Add here your email address
            mail.setSenderDisplayName('Credit Memo Batch Failure from '+ System.Label.OrgName);//+ custom setting with orgname 
            
            mail.setSubject('Failed Credit Memo Records');
            String finalBodyForEmail = '';
            for(Integer i=0;i<failedCrditMemo.size();i++){
                String bodyPart1 = String.valueOf(i+1)+'.) '+' The Credit Memo number '+failedCrditMemo[i].JDAInvoiceCreditNumber__r.InvoiceCredNum__c;
                String bodyPart2 = ' failed with the error '+ failedCrditMemo[i].Last_Logged_Service_Error__c+ '\n' ;
                finalBodyForEmail = finalBodyForEmail+bodyPart1+bodyPart2;
            }
            mail.setPlainTextBody(finalBodyForEmail);
            Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
        }
    } 
}