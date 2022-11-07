public class InvoiceBatchApex implements Database.Batchable<String>, Database.AllowsCallouts { 
    
    
    public Iterable<string> start(Database.BatchableContext bc){ 
        String dt = '2021-09-03 00:00:00';
        DateTime refDate = DateTime.valueOf(dt);
        List<Invoice> invList = [Select Id,InvoiceServiceFlag__c,ReferenceEntityId  from Invoice where InvoiceServiceFlag__c=false and CreatedDate>:refDate and Failed_Capture__c =false];
        Map<String,List<String>> mapOfordrSummaryIdWithInvoice = new Map<String,List<String>>();
        for(Invoice inv:invList){
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
        List<ProcessException> proExceptionList = [Select Id,OrderSummaryId from ProcessException where Category='Payment' and OrderSummaryId In:mapOfordrSummaryIdWithInvoice.keySet()];
        for(ProcessException pE:proExceptionList){
            if(mapOfordrSummaryIdWithInvoice.containskey(pE.OrderSummaryId)){
                removeInvoiceIds.addAll(mapOfordrSummaryIdWithInvoice.get(pE.OrderSummaryId));
            }
        }
        
        list<String> invoiceIds = new List<String>();
        for(Invoice inv:invList){
            if(!removeInvoiceIds.contains(inv.id)){
            invoiceIds.add(inv.Id);     
            }
                
        }
        return invoiceIds;
    }     
    public void execute(Database.BatchableContext bc, List<String> scope){
        system.debug('scope is '+scope);
        WM_NewInvoiceService.callInvoiceService(scope);
        
    }     
    public void finish(Database.BatchableContext bc){   
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String dt = '2021-09-03 00:00:00';
        DateTime refDate = DateTime.valueOf(dt);
        
        List<Invoice> failedInvoices = [SELECT Id, CreatedDate, InvoiceName__r.InvoiceCredNum__c, Last_Logged_Service_Error__c,
                                        InvoiceServiceFlag__c FROM Invoice where InvoiceServiceFlag__c = false and CreatedDate>:refDate and  Failed_Capture__c =false]; 
        if(failedInvoices.size()>0){
            
            String[] toAddresses = new String[]{};//address need to send, custom setting email addresses
                List<EmailAddresses__c> emailAddresses = [SELECT Id, EmailAddress__c, name FROM EmailAddresses__c];
            for(EmailAddresses__c eml: emailAddresses ){
                toAddresses.add(eml.EmailAddress__c);
            }
            mail.setToAddresses(toAddresses);
            //mail.setReplyTo('test@test.com'); // Add here your email address
            mail.setSenderDisplayName('Invoice Batch Failure from '+ System.Label.OrgName);//+ custom setting with orgname 
            
            mail.setSubject('Failed Invoices');
            String finalBodyForEmail = '';
            for(Integer i=0;i<failedInvoices.size();i++){
                String bodyPart1 = String.valueOf(i+1)+'.) '+' The invoice number '+failedInvoices[i].InvoiceName__r.InvoiceCredNum__c;
                String bodyPart2 = ' failed with the error '+ failedInvoices[i].Last_Logged_Service_Error__c+ '\n' ;
                finalBodyForEmail = finalBodyForEmail+bodyPart1+bodyPart2;
            }
            mail.setPlainTextBody(finalBodyForEmail);
            Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
        }
    } 
}