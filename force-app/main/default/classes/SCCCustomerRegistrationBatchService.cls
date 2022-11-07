/**
* Rest Service class for post contact informations' details => Customer Registration
* 
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-02 
*/
@RestResource(urlMapping='/Contact/Registration/Batch/*')
global with sharing class SCCCustomerRegistrationBatchService {
    
    /**
* This is the method using on "POST" requests
* @return SCCCustomerRegResponse.
*/
    @HttpPost
    global static List<SCCCustomerRegResponse> create() {
        SCCFileLogger logger = SCCFileLogger.getInstance();
        List<SCCCustomerRegResponse> response;
        
        try{
            RestRequest request = RestContext.request;
            system.debug('===='+request.requestBody.toString()); 
            List<Object> jsonList= (List<Object>)System.JSON.deserializeUntyped( request.requestBody.toString()); 
            Map<String, Object> jsonMap = (Map<String, Object>)(jsonList[0]);
            System.debug('V###jsonMap='+jsonMap);
            System.debug('V###SCCUtilityClass.isPersonAccountEnabled()='+SCCUtilityClass.isPersonAccountEnabled());
            System.debug('V###jsonMap.get(site_id)'+jsonMap.get('site_id'));
            System.debug('V###SCCCommerceCloudConnect.siteId'+SCCCommerceCloudConnect.siteId);
            response = createOrMatchRecord(request, logger);
            
        }catch(Exception e){
            system.debug('getMessage'+ e.getMessage());
            logger.error('SCCCustomerRegistrationBatchService.create', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            response = new List<SCCCustomerRegResponse>();
            response.add(SCCCustomerRegResponse.createError(e));
            return response;            
        }finally{
            logger.flush();
        }
        system.debug('Response**  '+response);
        return response;
    }
    
    
    public static List<SCCCustomerRegResponse> createOrMatchRecord(RestRequest request, SCCFileLogger logger){
        SCCCommerceCloudConnect.logger = logger;
        List<SCCCustomerRegResponse> respList = new List<SCCCustomerRegResponse>();  
        List<Id> recordIds = new List<Id>();
        try {
            Map<String, SObject> fieldMappings = SCCUtilityClass.getAllCustomSettingValues('Account', logger);
            Map<String, SObject> contactFieldMappings = SCCUtilityClass.getAllCustomSettingValues('Contact', logger);
            system.debug('###&&'+JSON.deserializeUntyped(request.requestBody.toString()));
            List<Object> jsonDataList = (List<Object>)System.JSON.deserializeUntyped(request.requestBody.toString());
            for (Object jsonData : jsonDataList)
            {
                Map<String, Object> jsonMap = (Map<String, Object>)jsonData;
                try	{
                    
                    String query = SCCQueryUtilClass.getInstance()
                        .getQueryInstance()
                        .setObjectName('Contact')
                        .setRelatedFields(new Set<String>{'Id', 'Email', 'SFCC_Customer_Id__c', 'SFCC_Customer_Number__c','IsPersonAccount'})
                        .setClause('Email = \'' + (String)jsonMap.get('email') + '\'')
                        .getQuery();
                    List<Contact> contactList = (List<Contact>)SCCQueryUtilClass.getRecords(query);
                    
                    if(!contactList.isEmpty()) {
                        if(contactList[0].IsPersonAccount){
                            String query2 = SCCQueryUtilClass.getInstance()
                                .getQueryInstance()
                                .setObjectName('Account')
                                .setRelatedFields(new Set<String>{'Id', 'PersonEmail', 'SFCC_Customer_Id__pc', 'SFCC_Customer_Number__pc','loyaltyAccountNumber__c'})
                                .setClause('PersonEmail = \'' + (String)jsonMap.get('email') + '\'')
                                .getQuery();
                            List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query2);
                            Account record = (Account)SCCUtilityClass.initializeObject(jsonMap, 'Account', fieldMappings, logger);
                            record.From_SFCC__pc = true;
                            system.debug('!!record'+ record);
                            record = SCCUtilityClass.additionalFieldsforAccount(record, jsonMap);
                            system.debug('!!accountList'+ accountList);
                            logger.debug('SCCCustomerRegistrationBatchService.createOrMatchRecord', 'Updating existing account: '+record);
                            record.Id = accountList[0].Id;
                            record.Contact_Status__pc  = 'Updated';
                            record.SFCC_update__c = true; 
                            system.debug('!!record'+ record.Contact_Status__pc);
                            system.debug('!!record'+ record.SFCC_update__c);
                            system.debug('!!record'+ record.Name);
                            system.debug('!!record'+ record);
                            
                            Database.upsert(record, true);
                            recordIds.add(record.Id);
                            respList.add(SCCCustomerRegResponse.createResponse(record));
                        }
                        else{
                          Contact record = (Contact)SCCUtilityClass.initializeObject(jsonMap, 'Contact', contactFieldMappings, logger);
                        record.From_SFCC__c = true;
                        record = SCCUtilityClass.additionalFieldsforContact(record, jsonMap);
                        system.debug('!!contactList'+ contactList);
                        logger.debug('SCCCustomerRegistrationBatchService.createOrMatchRecord', 'Updating existing contact: '+contactList);
                        record.Id = contactList[0].Id;
                        record.Contact_Status__c  = 'Updated';
                        //system.debug('!!record'+ record.RecordTypeId);
                        system.debug('!!record'+ record.Contact_Status__c);
                        system.debug('!!record'+ record);
                        Database.upsert(record, true);
                        recordIds.add(record.Id);
                        respList.add(SCCCustomerRegResponse.createResponse(record));   
                        }
                       
                    }
                 else{
                            Account record = (Account)SCCUtilityClass.initializeObject(jsonMap, 'Account', fieldMappings, logger);
                            system.debug('###record'+ record);
                            record.From_SFCC__pc = true;
                            record = SCCUtilityClass.additionalFieldsforAccount(record, jsonMap);
                            system.debug('###record'+ record);
                            logger.debug('SCCCustomerRegistrationBatchService.createOrMatchRecord', 'Creating new person account: '+ record);
                            RecordType recordType = SCCUtilityClass.getPersonAccountRecordType('Person Account'); 
                            record.RecordTypeId = recordType.Id;
                            record.Contact_Status__pc  = 'Created';
                            system.debug('!!record'+ record);
                            Database.upsert(record, true);
                            recordIds.add(record.Id);
                            respList.add(SCCCustomerRegResponse.createResponse(record));
                        }
                        
                    }    
                    
                catch(Exception e) {
                    logger.error('SCCCustomerRegistrationBatchService.createOrMatchRecord', 'Exception message : '
                                 + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
                    respList.add(SCCCustomerRegResponse.createError((String)jsonMap.get('customer_no'), e));               
                }
            }
            SCCCommerceCloudConnect.synchroniseObjectFutureBatch(recordIds);
            return respList;
        } catch(Exception e) {
            RestContext.response.statusCode = 500;
            logger.error('SCCCustomerRegistrationBatchService.createOrMatchRecord', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            respList.add(SCCCustomerRegResponse.createError(e));
            return respList;
        }    	
    }
    
    /* Not needed
public static List<SCCCustomerRegResponse> createContactRecord(RestRequest request, SCCFileLogger logger){
SCCCommerceCloudConnect.logger = logger;
List<SCCCustomerRegResponse> respList = new List<SCCCustomerRegResponse>(); 
Map<String, SObject> fieldMappings = SCCUtilityClass.getAllCustomSettingValues('Contact', logger);
try {
List<Object> jsonDataList = (List<Object>)System.JSON.deserializeUntyped(request.requestBody.toString());
for (Object jsonData : jsonDataList)
{
try {
Map<String, Object> jsonMap = (Map<String, Object>)jsonData;
String query = SCCQueryUtilClass.getInstance()
.getQueryInstance()
.setObjectName('Contact')
.setRelatedFields(new Set<String>{'Id', 'Email', 'SFCC_Customer_Id__c', 'SFCC_Customer_Number__c'})
.setClause('Email = \'' + (String)jsonMap.get('email') + '\'')
.getQuery();
List<Contact> contactList = (List<Contact>)SCCQueryUtilClass.getRecords(query);
Contact record = (Contact)SCCUtilityClass.initializeObject(jsonMap, 'Contact', fieldMappings, logger);
record.From_SFCC__c = true;
record = SCCUtilityClass.additionalFieldsforContact(record, jsonMap);
if(!contactList.isEmpty()) {
system.debug('!!contactList'+ contactList);
logger.debug('SCCCustomerRegistrationBatchService.createContactRecord', 'Updating existing contact: '+contactList);
record.Id = contactList[0].Id;
record.Contact_Status__c  = 'Updated';
//system.debug('!!record'+ record.RecordTypeId);
system.debug('!!record'+ record.Contact_Status__c);
}else{
logger.debug('SCCCustomerRegistrationBatchService.createContactRecord', 'Creating new contact');
record.Contact_Status__c  = 'Created';
system.debug('!!record'+ record.Contact_Status__c);

}
Database.upsert(record, true);
SCCCommerceCloudConnect.scheduleIt(record.Id);
respList.add(SCCCustomerRegResponse.createResponse(record));
} catch(Exception e) {
system.debug('===============e.getMessa: '+e.getMessage());
logger.error('SCCCustomerRegistrationBatchService.createContactRecord', 'Exception message : '
+ e.getMessage() + ' StackTrack '+ e.getStackTraceString());
respList.add(SCCCustomerRegResponse.createError(e));               
}
}
return respList;
} catch(Exception e) {
RestContext.response.statusCode = 500;
logger.error('SCCCustomerRegistrationBatchService.createContactRecord', 'Exception message : '
+ e.getMessage() + ' StackTrack '+ e.getStackTraceString());
respList.add(SCCCustomerRegResponse.createError(e));
return respList;
}
}*/
}