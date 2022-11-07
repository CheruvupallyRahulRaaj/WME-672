/**
 * @description       : 
 * @author            : schauhan@liveareacx.com
 * @group             : 
 * @last modified on  : 01-12-2021
 * @last modified by  : schauhan@liveareacx.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   01-12-2021   schauhan@liveareacx.com   Initial Version
**/
@isTest
public class AuthorizationRequestTest {
  /*  @isTest static void testAuthorizationCalloutFailure() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AuthorizationFailedResponseGenerator());
        PaymentGatewayHelper.getAuthorize();
    }
    
    @isTest static void testAuthorizationCalloutSuccess() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AuthorizationSuccessResponseGenerator());
        PaymentGatewayHelper.getAuthorize();
    }
    
    
    public class AuthorizationFailedResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('https://utgapi.shift4test.com/api/rest/v1/transactions/authorization', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"result":[{"error":{"longText":"Card  for Merchant Id 0000000000 not found ENGINE02CE","primaryCode":1000,"shortText":"INVALID"},"server":{"name":"UT00000000"}}]}');
            res.setStatusCode(400);
            return res;
        }
    }
    
    public class AuthorizationSuccessResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('https://utgapi.shift4test.com/api/rest/v1/transactions/authorization', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"result": [{"dateTime": "2018-06-21T09:18:23.283-07:00","amount": {"cashback": 20,"surcharge": 5,"tax": 15,"tip": 20,"total": 160'+
                        '},"card": {"entryMode": "E","number": "XXXXXXXXXXXX4111", "present": "Y","token": {"value": "4111t67z9qbn9j1y"'+
                        '},"type": "MC"},"clerk": {"numericId": 1576},"merchant": {"mid": 301030},"receipt": ['+
                        '{ "key": "AmountAuthorized","printName": "9F02","printValue": "000000000444"'+
                        '},{"key": "ApplicationIdentifier","printName": "AID","printValue": "A0000000041010"'+
                        '},{"key": "ApplicationLabel","printValue": "MasterCard"},'+
                        '{"key": "CVMResults","printName": "9F34","printValue": "1E0300"},'+
                        '{"key": "CardEntryMode","printName": "ENTRY METHOD","printValue": "CHIP"},'+
                        '{"key": "CardholderVerificationMethod","printName": "CVM","printValue": "SIGN"},'+
                        '{"key": "MaskedPAN","printValue": "XXXXXXXXXXXX4111"},'+
                        '{"key": "PANSequenceNumber","printName": "5F34","printValue": "01"},'+
                        '{"key": "SignatureRequired","printValue": "Y"},'+
                        '{ "key": "TerminalVerificationResults","printName": "TVR","printValue": "0820000000"},'+
                        '{ "key": "TransactionResponse","printName": "Response","printValue": "APPROVED"},'+
                        '{ "key": "TransactionStatusIndicator","printName": "TSI","printValue": "C800"},'+
                        '{ "key": "UnpredictableNumber","printName": "9F37","printValue": "C5BF918D"}],"server":'+
                        '{"name": "U2API01CE"},"transaction": {"authorizationCode": "OK253W","authSource": "E","invoice": "192029","responseCode": "A","saleFlag": "S"}}]}'
                       );
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest static void testAccessTokeCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AccessTokenResponseGenerator());
        PaymentGatewayHelper.getAccessToken();
        Shift4AccessToken__c Shift4AccessToken = [SELECT Id, Name, AccessToken__c FROM Shift4AccessToken__c where Name = 'Shift4AccessToken'];

    }
    
    
    public class AccessTokenResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('callout:Shift4/api/rest/v1/credentials/accesstoken', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"result":[{"credential":{"accessToken":"EA79FB05-3AA7-4500-AF9A-XYZTEST","device":{"capability":"magstripe"}}}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest static void testCardTokenCalloutFailure() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new getCardTokenFailedResponseGenerator());
       // PaymentGatewayHelper.getCardToken();
    }
    
    @isTest static void testCardTokenCalloutSuccess() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CardTokenSuccessResponseGenerator());
       // PaymentGatewayHelper.getCardToken();
    }
    
     public class getCardTokenFailedResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('https://utgapi.shift4test.com/api/rest/v1/tokens/add', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"result":[{"error":{"longText":"Card  for Merchant Id 0000000000 not found ENGINE02CE","primaryCode":1000,"shortText":"INVALID"},"server":{"name":"UT00000000"}}]}');
            res.setStatusCode(400);
            return res;
        }
    }
    
     public class CardTokenSuccessResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('https://utgapi.shift4test.com/api/rest/v1/tokens/add', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"result": [{"dateTime": "2018-06-21T09:18:23.283-07:00","amount": {"cashback": 20,"surcharge": 5,"tax": 15,"tip": 20,"total": 160'+
                        '},"card": {"entryMode": "E","number": "XXXXXXXXXXXX4111", "present": "Y","token": {"value": "4111t67z9qbn9j1y"'+
                        '},"type": "MC"},"clerk": {"numericId": 1576},"merchant": {"mid": 301030},"receipt": ['+
                        '{ "key": "AmountAuthorized","printName": "9F02","printValue": "000000000444"'+
                        '},{"key": "ApplicationIdentifier","printName": "AID","printValue": "A0000000041010"'+
                        '},{"key": "ApplicationLabel","printValue": "MasterCard"},'+
                        '{"key": "CVMResults","printName": "9F34","printValue": "1E0300"},'+
                        '{"key": "CardEntryMode","printName": "ENTRY METHOD","printValue": "CHIP"},'+
                        '{"key": "CardholderVerificationMethod","printName": "CVM","printValue": "SIGN"},'+
                        '{"key": "MaskedPAN","printValue": "XXXXXXXXXXXX4111"},'+
                        '{"key": "PANSequenceNumber","printName": "5F34","printValue": "01"},'+
                        '{"key": "SignatureRequired","printValue": "Y"},'+
                        '{ "key": "TerminalVerificationResults","printName": "TVR","printValue": "0820000000"},'+
                        '{ "key": "TransactionResponse","printName": "Response","printValue": "APPROVED"},'+
                        '{ "key": "TransactionStatusIndicator","printName": "TSI","printValue": "C800"},'+
                        '{ "key": "UnpredictableNumber","printName": "9F37","printValue": "C5BF918D"}],"server":'+
                        '{"name": "U2API01CE"},"transaction": {"authorizationCode": "OK253W","authSource": "E","invoice": "192029","responseCode": "A","saleFlag": "S"}}]}'
                       );
            res.setStatusCode(200);
            return res;
        }
    }*/
}