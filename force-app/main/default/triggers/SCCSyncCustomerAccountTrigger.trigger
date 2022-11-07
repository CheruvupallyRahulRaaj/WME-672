trigger SCCSyncCustomerAccountTrigger on Account (after insert, before update,after update) {
    List<Id> accountIds = new List<Id>();
    List<Id> specificAccountIds = new List<Id>();
    SCCFileLogger logger = SCCFileLogger.getInstance();
    Boolean result;
    try{    
        if(trigger.IsInsert){
            
            /*   List<Account> newAccount = trigger.new;
Map<String, Object> postDataMap = new Map<String, Object>();
Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap(); 
for(Integer i = 0; i < newAccount.size(); i++) {
Account newAcc= newAccount.get(i);
// this is avoid calling future method when object updated by webservice from CC.
if(!newAcc.From_SFCC__pc){
for (String str : fieldMap.keyset()) {
postDataMap.put(str, newAcc.get(str)); 
}
if(!postDataMap.isEmpty()){
result = SCCAccountImpl.postCustProfile(postDataMap, newAcc);  

} 
}
}  */
            
            
            // Get all New Accounts added 
            List<Account> updateAccountList = new List<Account>();
            List<Account> AccountList = trigger.new;
            
            If (AccountList.Size() > 0) {
                for(Account acct: AccountList) {
                    // If Account Number is Blank, update the Account Number with the Auto-Generated CustomerNumber__c
                    if(String.isBlank(acct.AccountNumber)) {  
                        Account tempAccount = new Account();
                        tempAccount.Id = acct.Id;
                        tempAccount.AccountNumber = acct.CustomerNumber__c ;
                        updateAccountList.add(tempAccount);
                    }  
                    if(!acct.Test_Context__c && !Test.isRunningTest() && !String.isBlank(acct.AccountNumber)){
                        accountIds.add(acct.Id);
                    }
                    
                    
                } 
                if(!Test.isRunningTest()){
                    system.debug('accountIds '+accountIds);
                    System.debug('3. handlingChunkSize Action Type: A');
                    WM_CRMIntegrationProcessor.handlingTheChunkSizeLogic(accountIds,'A');   
                }
                if(updateAccountList.size() > 0) {
                    update updateAccountList;    
                }
            }
            
            
            
            
        }
        
        
        if(trigger.IsUpdate) {
            if(trigger.IsBefore){
                List<contact> ConUpdtList = new list<contact>();
                for(account acc:trigger.old){
                    if(acc.IsPersonAccount == false){
                        list<contact> conlist = [select id,AccountId,Contact_Status__c from contact where AccountId =:acc.id and SFCC_Customer_Id__c != null];
                        for (Contact contactToModify : conlist) {
                            Contact contactForList = new contact();
                            contactForList.Contact_Status__c = 'Updated';
                            contactForList.Id = contactToModify.Id;
                            ConUpdtList.add(contactForList);
                        }
                    }
                }
                update ConUpdtList;
                
                List<Account> newAccounts = trigger.new;
                List<Account> oldAccounts = trigger.old;
                Map<String, Object> patchDataMap = new Map<String, Object>();
                Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap(); 
                for(Integer i = 0; i < newAccounts.size(); i++) {
                    Account newAcc = newAccounts.get(i);
                    Account oldAcc = oldAccounts.get(i);
                    // this is avoid calling future method when object updated by webservice from CC.
                    if((!newAcc.SFCC_update__c) || (newAcc.loyaltyAccountNumber__c!=null && oldAcc.SFCC_Customer_Id__pc==null && newAcc.SFCC_Customer_Id__pc!=null)){
                        for (String str : fieldMap.keyset()) {
                            logger.debug('SCCSyncCustomerAccountTrigger.IsUpdate', 'Field name: '+str +'. New value: ' + newAcc.get(str) +'. Old value: '+oldAcc.get(str));
                            if((newAcc.get(str) != oldAcc.get(str)) || str=='loyaltyaccountnumber__c'){
                                logger.debug('SCCSyncCustomerAccountTrigger.New not equal to Old', 'Patching commerce cloud for field '+ str);
                                patchDataMap.put(str, newAcc.get(str)); 
                            }
                        }
                        if(!patchDataMap.isEmpty()){
                            //Call Commerce Cloud patch
                            logger.debug('SCCSyncCustomerAccountTrigger.calling', 'Patching commerce cloud for field '+ patchDataMap);
                            result = SCCAccountImpl.patchCustProfile(patchDataMap, newAcc);  
                            
                        } 
                    }
                    newAcc.SFCC_update__c = false;
                }
                
                User currentUser = [SELECT Id, ProfileId, Profile.Name,Name FROM User where Id=:UserInfo.getUserId() limit 1];
                if(currentUser.Profile.Name !='System Administrator' && 
                   currentUser.Profile.Name !='SCC Integration User' && currentUser.Name!='Platform Integration User'){
                       List<Id> accountIdsWithPrefAddress = new list<Id>(); 
                       Map<Id,Boolean> mapOfPrefferedAccount = new Map<Id,Boolean>();
                       for(Address__c adr :  [SELECT Id, wmPreferredAddress__c, Account__c FROM Address__c where Account__c In:Trigger.new and wmPreferredAddress__c=true]){
                           accountIdsWithPrefAddress.add(adr.Account__c);
                       }
                       
                       for(Account ac : Trigger.new){
                           
                           if (String.isBlank(trigger.oldMap.get(ac.Id).AccountNumber) && ac.AccountNumber != null && !ac.Test_Context__c){
                               // insertion scenario so don't do anything
                           }
                           else{
                               for(Id accId:accountIdsWithPrefAddress){
                                   if(ac.Id==accId)  {
                                       mapOfPrefferedAccount.put(accId,true);
                                   }          
                               }  
                           }
                           
                       }
                       if(mapOfPrefferedAccount.size()>0){
                                 for(Account acc : Trigger.new){
                           
                           if(!mapOfPrefferedAccount.containsKey(acc.Id)){
                               acc.addError('This account does not have a preffered address. Please add a preferred address');
                           }
                       }
                       }
                 
                   }
                for(Account acc: Trigger.new) {
                    system.debug('Entered');
                    system.debug('oldMapValues++++++++'+trigger.oldMap.get(acc.Id).AccountNumber);
                    system.debug('newMapValues++++++++'+ acc.AccountNumber);
                    if (String.isBlank(trigger.oldMap.get(acc.Id).AccountNumber) && acc.AccountNumber != null && !acc.Test_Context__c){
                        specificAccountIds.add(acc.Id);
                    }
                    else if(!acc.Test_Context__c){
                        accountIds.add(acc.Id);
                        system.debug('accountIds+++'+accountIds);
                    }
                    
                }
                for(Account acc: Trigger.new) {
                    if(acc.Test_Context__c){
                        acc.Test_Context__c = false;
                    }
                }
                if(!Test.isRunningTest()){
                    
                    system.debug('accountIds '+accountIds);
                    system.debug('specificAccountIds+++'+specificAccountIds);
                    if(specificAccountIds.size()>0){
                        System.debug('1. handlingChunkSize Action Type: A');
                        WM_CRMIntegrationProcessor.handlingTheChunkSizeLogic(specificAccountIds,'A');
                    }
                    if(accountIds.size()>0){
                        System.debug('2. handlingChunkSize Action Type: C');
                        WM_CRMIntegrationProcessor.handlingTheChunkSizeLogic(accountIds,'C');     
                    }
                    
                }
                
            }
            if(trigger.IsAfter){
                
                
            }
            
        }
    }catch(Exception e){
        logger.error('SCCSyncCustomerAccountTrigger', 'Exception message : '
                     + e.getMessage() + ' StackTrack '+ e.getStackTraceString());           
    }finally{
        logger.flush();
    } 
    
}