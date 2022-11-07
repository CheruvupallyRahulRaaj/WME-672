@isTest
public class WM_AbstractTransactionServiceTest {
    @testSetup static void setup() {
        
        //Id RecordTypeIdPersonAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('PersonAccount').getRecordTypeId();
        RecordType recordType =  [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' and SObjectType = 'Account' AND IsPersonType=True Limit 1];
        //Create Account
        Account testAccount = new Account();
        testAccount.FirstName = 'Michael';
        testAccount.LastName = 'Allinger Jr';
        testAccount.type = 'Partner';
        testAccount.Phone = '3333333333';
        testAccount.industry = 'Technology';
        testAccount.recordtypeid = recordType.id;
        testAccount.Test_Context__c = true;
        Insert testAccount;
        
        //Insert Order
        Order testOrder = new Order();
        testOrder.AccountId = testAccount.Id;
        testOrder.EffectiveDate = Date.newInstance(2020, 10, 13);
        testOrder.Status = 'Draft';
        //testOrder.ActivatedDate = Date.newInstance(2020, 10, 13);
        insert testOrder;
        
    }
    
    @isTest static void testCaptureTransactionService() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CaptureTransactionResponseGenerator());
        //update Order status to trigger PaymentGateway
       list<order> updatelist =  [select id,name,status  from order];
        if (!updatelist.isEmpty()){
        Order testOrder = new Order();
        testOrder.EffectiveDate = Date.newInstance(2020, 10, 13);
        testOrder.Status = 'Draft';
         testOrder.id = updatelist[0].id;  
             update testOrder;
        }
       
    }
    
    @isTest static void testRefundTransactionService() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new RefundTransactionResponseGenerator());
        //update Order status to trigger PaymentGateway
        list<order> updatelist =  [select id,name,status  from order];
        if (!updatelist.isEmpty()){
        Order testOrder = new Order();
        testOrder.EffectiveDate = Date.newInstance(2020, 10, 13);
        testOrder.Status = 'Draft';
         testOrder.id = updatelist[0].id;  
             update testOrder;
        }
    }
    
    public class CaptureTransactionResponseGenerator implements HttpCalloutMock {
        commercepayments.PaymentGatewayRequest request;
        String requestType = commercepayments.RequestType.Capture.name();
        //commercepayments.PaymentGatewayContext pgc = new commercepayments.PaymentGatewayContext();
        //CommercePayments.PaymentGatewayContext pgc = new CommercePayments.PaymentGatewayContext(request, requestType);
        
        //WM_PaymentGatewayAdapter wmPGA = new WM_PaymentGatewayAdapter();
       // WM_CaptureTransactionService.buildRequest();
        
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('https://utgapi.shift4test.com/api/rest/v1/transactions/capture', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"result": [{"dateTime": "2018-06-21T09:18:23.283-07:00", "amount": { "cashback": 20,"surcharge": 5,"tax": 15,"tip": 20,"total": 160},'+
                        '"card": {"entryMode": "M","expirationDate": 1230,"levelResult": "2C","number": "XXXXXXXXXXXX1119","present": "Y","type": "VS","balance": {'+
                        '"amount": 24.33},"token": {"serialNumber": "266","value": "1119x920d092j306"}},"customer": {"firstName": "John","lastName": "Smith"},'+
                        '"clerk": {"numericId": 1576},"receipt": [{"key": "ApplicationIdentifier","printName": "AID","printValue": "A0000000031010"},{"key": "TerminalVerificationResults",'+
                        '"printName": "TVR","printValue": "0000008000"},{"key": "IssuerApplicationData","printName": "IAD", "printValue": "06010A03A40002"},{"key": "TransactionStatusIndicator",'+
                        '"printName": "TSI","printValue": "E800"},{ "key": "AuthorizationResponseCode","printName": "ARC","printValue": "00"},{"key": "TransactionCurrencyCode",'+
                        '"printValue": "USD$"},{"key": "ApplicationLabel","printValue": "CREDITO DE VISA"}],"server": {"name": "U2API01CE"},"signature": {"data": "iVBORw0K",'+
                        '"format": "P"},"transaction": {"authorizationCode": "198399","authSource": "E","invoice": "192029","responseCode": "A","saleFlag": "S","amex": {'+
                        '"propertyCode": "21546782948"},"cardOnFile": {"indicator": "02","usageIndicator": "Initial","scheduledIndicator": "Unscheduled","transactionId": "Z62537846172646"'+
                        '}},"universalToken": {"value": "97032276-5944-00000001-16985FD179D"}}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class RefundTransactionResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('https://utgapi.shift4test.com/api/rest/v1/transactions/refund', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"result": [{"dateTime": "2018-06-21T09:18:23.283-07:00", "amount": { "cashback": 20,"surcharge": 5,"tax": 15,"tip": 20,"total": 160},'+
                        '"card": {"entryMode": "M","expirationDate": 1230,"levelResult": "2C","number": "XXXXXXXXXXXX1119","present": "Y","type": "VS","balance": {'+
                        '"amount": 24.33},"token": {"serialNumber": "266","value": "1119x920d092j306"}},"customer": {"firstName": "John","lastName": "Smith"},'+
                        '"clerk": {"numericId": 1576},"receipt": [{"key": "ApplicationIdentifier","printName": "AID","printValue": "A0000000031010"},{"key": "TerminalVerificationResults",'+
                        '"printName": "TVR","printValue": "0000008000"},{"key": "IssuerApplicationData","printName": "IAD", "printValue": "06010A03A40002"},{"key": "TransactionStatusIndicator",'+
                        '"printName": "TSI","printValue": "E800"},{ "key": "AuthorizationResponseCode","printName": "ARC","printValue": "00"},{"key": "TransactionCurrencyCode",'+
                        '"printValue": "USD$"},{"key": "ApplicationLabel","printValue": "CREDITO DE VISA"}],"server": {"name": "U2API01CE"},"signature": {"data": "iVBORw0K",'+
                        '"format": "P"},"transaction": {"authorizationCode": "198399","authSource": "E","invoice": "192029","responseCode": "A","saleFlag": "S","amex": {'+
                        '"propertyCode": "21546782948"},"cardOnFile": {"indicator": "02","usageIndicator": "Initial","scheduledIndicator": "Unscheduled","transactionId": "Z62537846172646"'+
                        '}},"universalToken": {"value": "97032276-5944-00000001-16985FD179D"}}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}