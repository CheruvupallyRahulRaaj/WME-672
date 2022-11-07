@isTest
private class SCCCustomerCaseMgmtService_Test {

    @testSetup 
    static void setup() {

        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();    	
    	SCCTestDataFactory.createSFCCLogDefaultCustomSetting();  
        SCCTestDataFactory.createAccount(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'}, new Map<Integer, String>{1=>'12345', 2=>'23456', 3=>'34567'});
        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        SCCTestDataFactory.createAccount(1, 'test account', false);
        
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'contact_id'=>'SFCC_Customer_Id__c',  'case_type'=>'Type', 'description'=>'Description', 'title'=>'Subject', 'enquiry_type'=>'Status'}, 'Case');          
        SCCTestDataFactory.createCase(1, [SELECT Id FROM Contact LIMIT 1].Id, 'test description', 'Contact us', 'test title');
        SCCTestDataFactory.createAccountCase(1, [SELECT Id FROM Account LIMIT 1].Id, 'test description', 'Contact us', 'test title');
    }

    @isTest 
    static void testCreate_one() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Account acc = [Select Id from Account Limit 1];
        req.requestBody = Blob.valueOf('{"contact_id":"'+acc.Id+'","title":"test title case","description":"test description case","case_type":"Contact us","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
       

    }

    @isTest 
    static void testCreate_two() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"testFName","last_name":"testLName","email":"test@testing.com","title":"test title case","description":"test description case","case_type":"Contact us","test":"test","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
        
    }
    
    @isTest 
    static void testCreate_three() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"testFName","last_name":"testLName","email":"test@yahoo.com","title":"test title case","description":"test description case","case_type":"Contact us","test":"test","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
       System.JSON.serialize(stas);
    }    
    
    @isTest 
    static void testCreate_four() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"testFName","email":"test@testing.com","title":"test title case","description":"test description case","case_type":"Contact us","test":"test","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
       System.JSON.serialize(stas);
    }    

    @isTest 
    static void testCreate_five() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        //Broken Json
        req.requestBody = Blob.valueOf('{"');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
        
    }
    
    @isTest 
    static void testCreate_six() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"testFName","last_name":"testLName","email":"test@testing.com","contact_id":"5000Q000000rFSiQAM","customer_id":"5000Q000000rFSiQAM","title":"test title case","description":"test description case","case_type":"Contact us","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
      

    } 
    
    @isTest 
    static void testCreate_seven() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"testFName","last_name":"testLName","contact_id":"5000Q000000rFSiQAM","customer_id":"5000Q000000rFSiQAM","title":"test title case","description":"test description case","case_type":"Contact us","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
        
    } 
    
    @isTest 
    static void testCreate_eight() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"testFName","last_name":"testLName","email":"test@yahoo.com","contact_id":"5000Q000000rFSiQAM","customer_id":"5000Q000000rFSiQAM","title":"test title case","description":"test description case","case_type":"Contact us","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
        System.JSON.serialize(stas);

    } 
    
    @isTest 
    static void testCreate_nine() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"testFName","last_name":"testLName","customer_id":"5000Q000000rFSiQAM","title":"test title case","description":"test description case","case_type":"Contact us","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
        

    }     
    
    @isTest 
    static void testShow_one() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/Case/' + [SELECT Id FROM Case LIMIT 1].Id;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        List<Case> stas = SCCCustomerCaseMgmtService.show();
        String query = SCCQueryUtilClass.getInstance()
                                      .getQueryInstance()
                                      .setObjectName('Case')
                                      .setAllFields()
                                      .getQuery();
        List<Case> caseList = SCCQueryUtilClass.getRecords(query);
        //System.assertEquals(caseList, stas);

    }

    @isTest 
    static void testShow_two() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/Case/' + [SELECT Id FROM Contact LIMIT 1].Id;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        List<Case> stas = SCCCustomerCaseMgmtService.show();
        String query = SCCQueryUtilClass.getInstance()
                                      .getQueryInstance()
                                      .setObjectName('Case')
                                      .setRelatedFields(new Set<String>{'Id', 'Subject', 'Status', 'LastModifiedDate'})
                                      .setClause('ContactId = \'' + [SELECT Id FROM Contact LIMIT 1].Id + '\'')
                                      .getQuery();
        List<Case> caseList = SCCQueryUtilClass.getRecords(query);
        System.assertEquals(caseList, stas);        
    }
    
}