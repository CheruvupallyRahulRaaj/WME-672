global class PostGiftCardService implements Database.Batchable<String>,Database.AllowsCallouts {
    
 global Iterable<String> start(Database.BatchableContext BC) {
        DateTime refDate = Datetime.valueOf('2021-09-23 00:00:00');
        String query;
     if(!Test.isRunningTest()){  
      query = 'SELECT Id, Confirmation_Email_Sent__c,Issued__c from e_GiftCard__c  where  Issued__c =true and Confirmation_Email_Sent__c=false and LastModifiedDate>:refDate';
     }
     else{
     query = 'SELECT Id, Confirmation_Email_Sent__c,Issued__c from e_GiftCard__c  where  Issued__c =true and Confirmation_Email_Sent__c=false and LastModifiedDate>:refDate limit 10';
    
     }
         List<e_GiftCard__c> egiftcards =Database.query(query);
           List<String> giftcardIds = new List<String>();
        for(e_GiftCard__c eGf:egiftcards){
           giftcardIds.add(eGf.Id);
        }
        return giftcardIds;
     
    }
    global void execute(Database.BatchableContext BC, List<String> scope) {
      WM_TransactionalEmails.sendEmailForGiftCard(scope);        
    }   
    
    global void finish(Database.BatchableContext BC) {
     
    }
}