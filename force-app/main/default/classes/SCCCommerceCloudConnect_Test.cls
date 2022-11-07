@isTest
public class SCCCommerceCloudConnect_Test {

    @testSetup
    static void setup() {

        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        SCCTestDataFactory.createAccount(1, 'test account', false);
        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();

        //Added the following sample record data *Manohar*
        SFCC_Client_AccessKey__c accessKey  = new SFCC_Client_AccessKey__c();
        accessKey.Name=	'Access Key Configuration';
        accessKey.AccessKey__c='9sE-.BGM,So?U!JKy~,Y~o6z{%iR3mC?Xo#yc(iH';
        accessKey.Username__c=	'sfcc-nonproduction@westmarine.com';
        insert accessKey;
        
        //Added the following sample record data *Manohar*
        SFCCConfiguration__c con = new SFCCConfiguration__c();
        con.name = 'WestMarine';
        con.Time__c=1.0;
        con.SFCC_WM_URL__c='https://dev-wm-sfcc.westmarine.com';
        con.SFCC_WMPRO_URL__c='https://dev-wmpro-sfcc.westmarine.com';
        con.WMPro_Session_URL__c='https://dev-wmpro-sfcc.westmarine.com/dw/shop/v22_4/sessions';
        con.OOBO_WM_Pro_URL__c='https://dev-wmpro-sfcc.westmarine.com/on/demandware.store/Sites-WestMarinePro-Site/en_US/Login-Logout';
        con.OOBO_WM_URL__c='https://dev-wm-sfcc.westmarine.com/on/demandware.store/Sites-WestMarine-';
        con.SFCC_Default_Customer_Id__c='ab10Ah5ZwvnJ6b8oMIqQ5tkICQ';
        insert con;

        //SCCTestDataFactory.createOrder(5, [SELECT Id FROM Account LIMIT 1].Id, System.today(), 'Draft', '12345', [SELECT Id FROM Contact LIMIT 1].Id);
    }

    @isTest
    static void testScheduleIt_One() {
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test());
        Id recordId = [SELECT Id FROM Account LIMIT 1].Id;
        SCCCommerceCloudConnect.scheduleIt(recordId);
        String ordrePath = SCCCommerceCloudConnect.replaceOrderPath;
        String proSite = SCCCommerceCloudConnect.proSiteId;
        String listId = SCCCommerceCloudConnect.listId;
        String siteBaseUrl = SCCCommerceCloudConnect.siteBaseUrl;
        Integer scheduleTime = SCCCommerceCloudConnect.scheduleTime;
        String sfccClientSecret = SCCCommerceCloudConnect.sfccClientSecret;
		String sfccClientId = SCCCommerceCloudConnect.sfccClientId;
  
	}

    @isTest
    static void testScheduleIt_Two() {
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test());
        Id recordId = [SELECT Id FROM Contact LIMIT 1].Id;
        SCCCommerceCloudConnect.scheduleIt(recordId);
        String listId = SCCCommerceCloudConnect.listId;
        String siteBaseUrl = SCCCommerceCloudConnect.siteBaseUrl;
        Integer scheduleTime = SCCCommerceCloudConnect.scheduleTime;
    }

    @isTest
    static void testScheduleIt_Three() {
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccountDetails'));
        Id recordId = [SELECT Id FROM Account LIMIT 1].Id;
        SCCCommerceCloudConnect.listId = 'RefArch';
        SCCCommerceCloudConnect.siteBaseUrl = 'https://xxxx-dw.demandware.net';
        SCCCommerceCloudConnect.scheduleTime = 1;
        SCCCommerceCloudConnect.scheduleIt(recordId);
	}

    /*@isTest
    static void testScheduleIt_Four() {
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetailsWithoutContact'));
        Id recordId = [SELECT Id FROM Order LIMIT 1].Id;
        SCCCommerceCloudConnect.listId = 'RefArch';
        SCCCommerceCloudConnect.siteBaseUrl = 'https://xxxx-dw.demandware.net';
        SCCCommerceCloudConnect.scheduleTime = 1;
        SCCCommerceCloudConnect.scheduleIt(recordId);
	}*/

    //Added following test method by *Manohar*
    @isTest
    static void testScheduleIt_Four() {
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccountDetails'));
        Id recordId = [SELECT Id FROM Account LIMIT 1].Id;
        SCCCommerceCloudConnect.listId = 'RefArch';
        SCCCommerceCloudConnect.siteBaseUrl = 'https://xxxx-dw.demandware.net';
        SCCCommerceCloudConnect.scheduleTime = 1;
        SCCCommerceCloudConnect.scheduleIt(recordId);
		string  siteId=  SCCCommerceCloudConnect.siteId;
        string  siteIdNew=  SCCCommerceCloudConnect.siteIdNew;
		string  proSiteIdNew=  SCCCommerceCloudConnect.proSiteIdNew;
		string  wmSessionId=  SCCCommerceCloudConnect.wmSessionId;
		string  wmProSessionId=  SCCCommerceCloudConnect.wmProSessionId;
		string  defaultCustomerId=  SCCCommerceCloudConnect.defaultCustomerId;
		string  sfccUsername=  SCCCommerceCloudConnect.sfccUsername;
		string  sfccAccessKey=  SCCCommerceCloudConnect.sfccAccessKey;
        string  OOBOUrl= SCCCommerceCloudConnect.OOBOUrl;
        string  OOBOProURL= SCCCommerceCloudConnect.OOBOProURL;
	}

    //Added following test method by *Manohar*
    @isTest
    static void testconnectToCommerceCloudViaAccessKey(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        Test.startTest();
        SCCCommerceCloudConnect.connectToCommerceCloudViaAccessKey();
        Test.stopTest();
    }

    //Added following test method by *Manohar*
    @isTest
    static void testsynchroniseObjectFuture(){
        Id recordId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.startTest();
        SCCCommerceCloudConnect.synchroniseObjectFuture(recordId);
        Test.stopTest();
    }

    //Added following test method by *Manohar*
    @isTest
    static void testgetProCustomerAuthToken() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAuthAccessToken'));
        SCCCommerceCloudConnect.getProCustomerAuthToken('2016f5bd-59bd-4c06-9233-8d807c8dc613', '2016f5bd59bd4c06');
        Test.stopTest();
	}

    //Added following test method by *Manohar*
    @isTest
    static void testgetCustomerDetailsById() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        string actualValue=SCCCommerceCloudConnect.getCustomerDetailsById('2016f5bd-59bd-4c06-9233-8d807c8dc613', '2016f5bd59bd4c06');
        Test.stopTest();
        string  expectedValue  = '{"_resource_state": "5391ed5a7a479d5e7daacc73177a9215235401a68dc161cff49e50abe7558249",';
                expectedValue +='"_type": "customer","_v": "17.8","birthday": "1981-08-28","c_sscSyncResponseText": ["Successfully Exported"],';
                expectedValue +='"c_sscSyncStatus": "exported","c_sscid": "0011I00000QkVb5QAF", "creation_date": "2018-05-13T17:58:24.000Z", "credentials": {"_type": "credentials","enabled": false,"locked": false,"login": "nirajyadav@gmail606.com"},';
                expectedValue += '"customer_id": "ad5cpbLbK64iOkrhjDaYXibHFS","customer_no": "00030501","email": "nirajyadav@gmail6088.com", "first_name": "Neeraj", "last_login_time": "2018-05-14T12:24:47.000Z","last_modified": "2018-05-25T11:31:38.375Z",';
                expectedValue += '"last_name": "Yadav","last_visit_time": "2018-05-14T12:24:47.000Z","previous_login_time": "2018-05-14T12:24:47.000Z","previous_visit_time": "2018-05-14T12:24:47.000Z"}';
        System.assertEquals(expectedValue, actualValue);
	}

    //Added following test method by *Manohar*
    @isTest
    static void testpatchAddressDetails(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAddress'));
        String reqBody = '{"address_id":"my_home_address""salutation":"","title":"","company_name":"",';
        reqBody += '"first_name":"","second_name":"","last_name":"","postal_code":"","address1":"",';
        reqBody += '"address2":"","city":"","post_box":"","country_code":"","state_code":"","phone":"","suffix":""}';
        Test.startTest();
        SCCCommerceCloudConnect.patchAddressDetails(reqBody, new List<String>{'00030501'}, '','2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

    //Added following test method by *Manohar*
    @isTest
    static void testputCCCustomerProfile(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        String reqBody = '{"_resource_state" : "860cde3040519cce439cd99e209f8a87c3ad0b7e2813edbf6f5501f763b73bd5",';
        reqBody += '"_delete":["fax","phone_mobile"],"birthday":"2011-05-06","email":"dude@demandware.com"}';
        Id recordId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.startTest();
        HttpResponse response=SCCCommerceCloudConnect.putCCCustomerProfile(reqBody, '00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613',recordId);
        Test.stopTest();
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = response.getBody();
        System.debug(response.getBody());
	    string  expectedValue = '{"_resource_state": "5391ed5a7a479d5e7daacc73177a9215235401a68dc161cff49e50abe7558249",';
            expectedValue +='"_type": "customer","_v": "17.8","birthday": "1981-08-28","c_sscSyncResponseText": ["Successfully Exported"],';
            expectedValue +='"c_sscSyncStatus": "exported","c_sscid": "0011I00000QkVb5QAF", "creation_date": "2018-05-13T17:58:24.000Z", "credentials": {"_type": "credentials","enabled": false,"locked": false,"login": "nirajyadav@gmail606.com"},';
            expectedValue += '"customer_id": "ad5cpbLbK64iOkrhjDaYXibHFS","customer_no": "00030501","email": "nirajyadav@gmail6088.com", "first_name": "Neeraj", "last_login_time": "2018-05-14T12:24:47.000Z","last_modified": "2018-05-25T11:31:38.375Z",';
            expectedValue += '"last_name": "Yadav","last_visit_time": "2018-05-14T12:24:47.000Z","previous_login_time": "2018-05-14T12:24:47.000Z","previous_visit_time": "2018-05-14T12:24:47.000Z"}';
        System.assertEquals(expectedValue, actualValue);
        System.assertEquals(200, response.getStatusCode());
    }

    //Added following test method by *Manohar*
    @isTest
    static void testpostCCCustomerProfile(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        String reqBody = '{"_resource_state" : "860cde3040519cce439cd99e209f8a87c3ad0b7e2813edbf6f5501f763b73bd5",';
        reqBody += '"_delete":["fax","phone_mobile"],"birthday":"2011-05-06","email":"dude@demandware.com"}';
        Test.startTest();
        HttpResponse response=SCCCommerceCloudConnect.postCCCustomerProfile(reqBody, '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = response.getBody();
        System.debug(response.getBody());
	    string  expectedValue = '{"_resource_state": "5391ed5a7a479d5e7daacc73177a9215235401a68dc161cff49e50abe7558249",';
            expectedValue +='"_type": "customer","_v": "17.8","birthday": "1981-08-28","c_sscSyncResponseText": ["Successfully Exported"],';
            expectedValue +='"c_sscSyncStatus": "exported","c_sscid": "0011I00000QkVb5QAF", "creation_date": "2018-05-13T17:58:24.000Z", "credentials": {"_type": "credentials","enabled": false,"locked": false,"login": "nirajyadav@gmail606.com"},';
            expectedValue += '"customer_id": "ad5cpbLbK64iOkrhjDaYXibHFS","customer_no": "00030501","email": "nirajyadav@gmail6088.com", "first_name": "Neeraj", "last_login_time": "2018-05-14T12:24:47.000Z","last_modified": "2018-05-25T11:31:38.375Z",';
            expectedValue += '"last_name": "Yadav","last_visit_time": "2018-05-14T12:24:47.000Z","previous_login_time": "2018-05-14T12:24:47.000Z","previous_visit_time": "2018-05-14T12:24:47.000Z"}';
        System.assertEquals(expectedValue, actualValue);
        System.assertEquals(200, response.getStatusCode());
    }

    //Added following test method by *Manohar*
    @isTest
        static void testsynchroniseObjectFutureBatch(){
        Id recordId = [SELECT Id FROM Account LIMIT 1].Id;
        list<id>accId = new list<id>();
        accId.add(recordId);
        Test.startTest();
        SCCCommerceCloudConnect.synchroniseObjectFutureBatch(accId);
        Test.stopTest();
    }

    @isTest
    static void testSearchCustomerByEmail() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('ZeroCustomerSearch'));
        SCCCommerceCloudConnect.searchCustomerByEmail('test@hotmail.com', 'abcedfghij');
        Test.stopTest();
	}

    @isTest
    static void testConnectToCommerceCloud2ProfileOperations() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        SCCCommerceCloudConnect.connectToCommerceCloud2ProfileOperations();
        Test.stopTest();
	}

    @isTest
    static void testGetCustomerAuthToken() {
        SCCCommerceCloudConnect.logger = SCCFileLogger.getInstance();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAuthAccessToken'));
        SCCCommerceCloudConnect.getCustomerAuthToken('2016f5bd-59bd-4c06-9233-8d807c8dc613', '2016f5bd59bd4c06');
        Test.stopTest();
	}

    @isTest
    static void testConnectToCommerceCloud(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        Test.startTest();
        SCCCommerceCloudConnect.connectToCommerceCloud();
        Test.stopTest();
    }

    @isTest
    static void testGetOrderDetails(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));
        Test.startTest();
        //SCCCommerceCloudConnect.getOrderDetails('00001603', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

    @isTest
    static void testGetCustomerDetails(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        Test.startTest();
        SCCCommerceCloudConnect.getCustomerDetails('00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

        @isTest
    static void testnullGetCustomerDetails(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        Test.startTest();
        SCCCommerceCloudConnect.getCustomerDetails('00030501', '');
        Test.stopTest();
    }

	@isTest
    static void testGetAddressDetails(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAddresses'));
        Test.startTest();
        SCCCommerceCloudConnect.getAddressDetails('00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

	@isTest
    static void testPostAddressDetails(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAddress'));
        String reqBody = '{"address_id":"my_home_address""salutation":"","title":"","company_name":"",';
        reqBody += '"first_name":"","second_name":"","last_name":"","postal_code":"","address1":"",';
        reqBody += '"address2":"","city":"","post_box":"","country_code":"","state_code":"","phone":"","suffix":""}';
        Test.startTest();
        SCCCommerceCloudConnect.postAddressDetails(reqBody, new List<String>{'00030501'}, '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

	@isTest
    static void testUpdateCCCustomerProfile_One(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        String reqBody = '{"_resource_state" : "860cde3040519cce439cd99e209f8a87c3ad0b7e2813edbf6f5501f763b73bd5",';
        reqBody += '"_delete":["fax","phone_mobile"],"birthday":"2011-05-06","email":"dude@demandware.com"}';
        Test.startTest();
        SCCCommerceCloudConnect.updateCCCustomerProfile(reqBody, '00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

    @isTest
    static void testPushOrderDetails(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccountDetails'));
        String reqBody = '{"_resource_state" : "847f9c3c5867f641470b3046aeec31f07757991b792d722e10079926f7a289fb","status" : "replaced"}';
        Test.startTest();
        //SCCCommerceCloudConnect.pushOrderDetails(reqBody, '00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

	/*@isTest
    static void testSynchroniseObjectFuture(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));
		Order order = [Select Id from Order limit 1];
        Test.startTest();
        SCCCommerceCloudConnect.synchroniseObjectFuture(order.Id);
        Test.stopTest();
    }*/

}