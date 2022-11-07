trigger SCCSyncCustomerContactTrigger on Contact(
  before insert,
  before update,
  after insert,
  after update
) {
  List<Id> contactIds = new List<Id>();
  SCCFileLogger logger = SCCFileLogger.getInstance();
  Boolean result;
  try {
    if (Trigger.IsInsert) {
      if (Trigger.IsBefore) {
        for (Contact con : Trigger.new) {
          if (con.IndividualNumber__c == null) {
            // Get the Max Individual Number within parent accountid and either increment it by one or set to 100 if first new Contact
            AggregateResult[] groupedResults = [
              SELECT Max(IndividualNumber__c) maximum
              FROM Contact
              WHERE accountid = :con.accountid
            ];
            Object maxAmount = groupedResults[0].get('maximum');

            Integer iSum = Integer.Valueof(maxAmount);
            if (iSum != null) {
              con.IndividualNumber__c = iSum + 1;
            } else {
              con.IndividualNumber__c = 100;
            }
          }
        }
      }

      if (Trigger.IsAfter) {
        /*    List<Contact> newContact = trigger.new;
         Map<String, Object> postDataMap = new Map<String, Object>();
         Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap(); 
                  for(Integer i = 0; i < newContact.size(); i++) {
                Contact newCon= newContact.get(i);
                // this is avoid calling future method when object updated by webservice from CC.
                if(!newCon.From_SFCC__c){
                    for (String str : fieldMap.keyset()) {
                          postDataMap.put(str, newCon.get(str)); 
                    }
                    if(!postDataMap.isEmpty()){
                        result = SCCContactImpl.postCustProfile(postDataMap, newCon);  
                        
                    } 
                }
            }*/

        for (Contact con : Trigger.new) {
          if (!con.Test_Context__c && !Test.isRunningTest()) {
            contactIds.add(con.Id);
          }
        }

        System.debug('5. handlingChunkSize Action Type: A');
        WM_CRMIntegrationProcessor.handlingTheChunkSizeLogic(contactIds, 'A');
      }
    }
    if (Trigger.IsUpdate) {
      if (Trigger.IsBefore) {
        List<Contact> newContacts = Trigger.new;
        List<Contact> oldContacts = Trigger.old;
        Map<String, Object> patchDataMap = new Map<String, Object>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();

        //WMSA-4914
        //moving this block to after update trigger

        for (Integer i = 0; i < newContacts.size(); i++) {
          Contact newCon = newContacts.get(i);
          Contact oldCon = oldContacts.get(i);
          system.debug('********************' + newCon);
          system.debug('********************' + OldCon);
          newCon.SFCC_update__c = false;
        }

        for (Contact con : Trigger.new) {
          if (!con.Test_Context__c && !Test.isRunningTest()) {
            system.debug('ENtred Con Update');
            contactIds.add(con.Id);
          }
        }
        for (Contact con : Trigger.new) {
          if (con.Test_Context__c) {
            con.Test_Context__c = false;
          }
        }

        System.debug('7. handlingChunkSize Action Type: C');
        WM_CRMIntegrationProcessor.handlingTheChunkSizeLogic(contactIds, 'C');
      }
      if (Trigger.IsAfter) {
        //WMSA-4914
        List<Contact> newContacts = Trigger.new;
        List<Contact> oldContacts = Trigger.old;
        Map<String, Object> patchDataMap = new Map<String, Object>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();
        for (Integer i = 0; i < newContacts.size(); i++) {
          Contact newCon = newContacts.get(i);
          Contact oldCon = oldContacts.get(i);
          system.debug('********************' + newCon);
          system.debug('********************' + OldCon);
          // this is avoid calling future method when object updated by webservice from CC.
          if (
            !newCon.SFCC_update__c && !String.isBlank(newCon.Acc_wmProTier__c)
          ) {
            //Call Commerce Cloud to update
            //If Contact is already synced, send an PATCH request, else send a PUT Request.
            //If SFCC_Customer_Id__c is populated, the contact is already synced
            if(String.IsBlank(newCon.SFCC_Customer_Id__c)){
              result = SCCContactImpl.putCustProfile(newCon);
            }
            else{
              for (String str : fieldMap.keyset()) {
                  logger.debug('SCCSyncCustomerContactTrigger.IsUpdate', 'Field name: '+str +'. New value: ' + newCon.get(str) +'. Old value: '+oldCon.get(str));
                  if(newCon.get(str) != oldCon.get(str) || str.startsWithIgnoreCase('Acc_')) {
                      logger.debug('SCCSyncCustomerContactTrigger.IsUpdate', 'Patching commerce cloud for field '+ str);
                      
                      patchDataMap.put(str, newCon.get(str)); 
                      system.debug('********************'+ str);
                      system.debug('********************'+ patchDataMap);
                  }
              }
              if(!patchDataMap.isEmpty()){
                  //Call Commerce Cloud patch
                  result = SCCContactImpl.patchCustProfile(patchDataMap, newCon);                
              } 
            }
          }
        }
      }
    }
  } catch (Exception e) {
    logger.error(
      'SCCSyncCustomerContactTrigger',
      'Exception message : ' +
      e.getMessage() +
      ' StackTrack ' +
      e.getStackTraceString()
    );
  } finally {
    logger.flush();
  }

}