trigger SyncAccountBillingAddress on Address__c (before insert, before update, after insert, after update) {
    Boolean result;
    if(trigger.IsInsert){
           
        if(trigger.isbefore){
            
            List<Id> accountIds = new list<Id>(); 
            for(Address__c ad : Trigger.new){
                if (ad.wmPreferredAddress__c) {
                    accountIds.add(ad.Account__c);
                }
            }
            //WME-83
            for(Address__c ad1 : Trigger.new){
                if (trigger.isBefore && trigger.isInsert) {
                    ad1.isNewAddress__c = 'Y';
                }
            }    
            //WME-83
            if(accountIds.Size() > 0 ){
                List<Address__c> addressList = [Select Id, wmPreferredAddress__c, Account__c FROM Address__c WHERE wmPreferredAddress__c = true and Account__c in :accountIds and Id NOT In:Trigger.new]; 
                If(addressList.Size() > 0){
                    
                    for(Address__c adr : addressList){
                        adr.wmPreferredAddress__c = false;
                        adr.LimitFlag__c = true;
                    }
                    system.debug('**addressList for before update**');
                    update addressList;
                    
                }
            } 
        } 
        if(trigger.IsAfter){
       List<Address__c> newAddress = trigger.new;
         Map<String, Object> postDataMap = new Map<String, Object>();
         Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Address__c.fields.getMap(); 
                  for(Integer i = 0; i < newAddress.size(); i++) {
                Address__c newAdd = newAddress.get(i);
                // this is avoid calling future method when object updated by webservice from CC.
                if(!newAdd.from_SFCC__c){
                    for (String str : fieldMap.keyset()) {
                          postDataMap.put(str, newAdd.get(str)); 
                    }
                    if(!postDataMap.isEmpty()){
                        result = SCCAccountImpl.postCustProfileForAddress(postDataMap, newAdd);  
                        
                    } 
                }
                //newAdd.from_SFCC__c = false;
            }     
    }   
        
    }
    if(trigger.IsUpdate) {
        if(trigger.IsBefore){
            //WME-83
            for(Address__c ad2 : Trigger.new){
                if (trigger.isBefore && trigger.IsUpdate) {
                    ad2.isNewAddress__c = 'N';
                }
            } 
            //WME-83
            List<Address__c> newAddress = trigger.new;
            List<Address__c> oldAddress = trigger.old;
            Map<String, Object> patchDataMap = new Map<String, Object>();
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Address__c.fields.getMap(); 
            for(Integer i = 0; i < newAddress.size(); i++) {
                Address__c newAdd = newAddress.get(i);
                Address__c oldAdd = oldAddress.get(i);
                // this is avoid calling future method when object updated by webservice from CC.
                if(!newAdd.from_SFCC__c){
                    for (String str : fieldMap.keyset()) {
                        //logger.debug('SCCSyncCustomerAccountTrigger.IsUpdate', 'Field name: '+str +'. New value: ' + newAcc.get(str) +'. Old value: '+oldAcc.get(str));
                        if(newAdd.get(str) != oldAdd.get(str)){
                            //logger.debug('SCCSyncCustomerAccountTrigger.New not equal to Old', 'Patching commerce cloud for field '+ str);
                            patchDataMap.put(str, newAdd.get(str)); 
                        }
                        if(str=='LimitFlag__c' && newAdd.get(str) == oldAdd.get(str)){
                            newAdd.LimitFlag__c =false;                                 
                        }
                    }
                    if(!patchDataMap.isEmpty()){
                        //Call Commerce Cloud patch
                        // logger.debug('SCCSyncCustomerAccountTrigger.calling', 'Patching commerce cloud for field '+ patchDataMap);
                        result = SCCAccountImpl.patchCustProfileForAddress(patchDataMap, newAdd,String.valueOf(oldAdd.get('Name')));  
                        
                    } 
                }
                newAdd.from_SFCC__c = false;
            }
        }
        
        
        if(trigger.isbefore){
            
            List<Id> accountIds = new list<Id>(); 
            for(Address__c ad : Trigger.new){
                if (ad.wmPreferredAddress__c) {
                    accountIds.add(ad.Account__c);
                }
            }  
            
            if(accountIds.Size() > 0 ){
                List<Address__c> addressList = [Select Id, wmPreferredAddress__c, Account__c FROM Address__c WHERE wmPreferredAddress__c = true and Account__c in :accountIds and Id NOT In:Trigger.new]; 
                If(addressList.Size() > 0){
                    
                    for(Address__c adr : addressList){
                        adr.wmPreferredAddress__c = false;
                        
                    }
                    system.debug('**addressList for before update**');
                    update addressList;
                    
                }
            } 
        }     
    }
    
    if(trigger.IsUpdate) {
    if(trigger.IsAfter){
            List<Id> accountIds = new List<Id>();
            List<Account> updateAccountList = new List<Account>();          // For Account object update
            List<Address__c> AddressList = trigger.new; 
             system.debug('AddressList '+AddressList);// New Inserted and/or Updated Addresses  
            If(AddressList.Size() > 0) {  
                For (Address__c addr: AddressList) {
                    if(!accountIds.contains(addr.Account__c) && !addr.LimitFlag__c){
                         accountIds.add(addr.Account__c);
                    }
                   
                    // Only process Addresses that are Preferred
                    If(addr.wmPreferredAddress__c == true) {
                        // Get the Account record that is associated to the Address__c record  
                        Account acct = new Account();
                        acct.Id = addr.Account__c;
                        acct.BillingStreet = addr.Address_Line_1__c ;
                        acct.BillingStreet2__c = addr.Address_Line_2__c;
                        acct.BillingStreet3__c = addr.Address_Line_3__c;
                        acct.BillingStreet4__c = addr.Address_Line_4__c;   
                        acct.BillingCity = addr.City__c;
                        acct.BillingState = addr.State__c;
                        acct.BillingPostalCode = addr.Postal_Code__c;
                        acct.BillingCountry = addr.Country__c;
                        updateAccountList.add(acct);   // Add updates to List
                    }  
                }
                // Bulk Account update 
                if(updateAccountList.size()>0){
                    update updateAccountList;
                }
                else{
                    
                      if(!Test.isRunningTest() && accountIds.size()>0){
                          WM_CRMIntegrationProcessor.handlingTheChunkSizeLogic(accountIds,'C');   
                        }
                }
            } 
        }
    }
    if(Trigger.isAfter && Trigger.isInsert){
        List<Id> accountIds = new List<Id>();
        List<Address__c> AddressList = trigger.new; 
        if(AddressList.Size() > 0) {  
            for (Address__c addr: AddressList) {
                if(!accountIds.contains(addr.Account__c) && !addr.LimitFlag__c){
                    accountIds.add(addr.Account__c);
                }
            }
                
            if(!Test.isRunningTest() && accountIds.size()>0){
                WM_CRMIntegrationProcessor.handlingTheChunkSizeLogic(accountIds,'A');   
            }
        } 
    }
    
}