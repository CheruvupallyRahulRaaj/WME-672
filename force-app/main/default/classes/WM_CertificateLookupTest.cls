/*Author : npendyala@liveareacx.com
* Class : WM_CertificateLookupTest
* Purpose : 
* Date : 
* @last modified on  : 
* @last modified by  : 
* */
@isTest(seealldata=false)
public class WM_CertificateLookupTest
{
@testSetup static void testData() 
    {
        Account Acc = new Account();
		Acc.Name = WMConstants.Name;
        Acc.loyaltyAccountNumber__c = '123456';
        Acc.Test_Context__c = true;
		insert Acc; 
   
    WM_WebServiceDetails__c custsetting = new WM_WebServiceDetails__c();
    custsetting.Name = 'CertLookup';
    custsetting.WM_ApiKey__c = 'CertLookup';
    insert custsetting;
     }
    
    @isTest static void CertificateLookupTestMethod()
    {
        Account accRec=[Select id,loyaltyAccountNumber__c From Account Limit 1];
        Test.setMock(HttpCalloutMock.class, new certificateLookupResponseGenerator()); 
        test.startTest();
        WM_CertificateLookup.certificateLookupService(accRec.Id);
        WM_CertificateLookup.checkForcertificateLookupNumber(accRec.Id);
        WM_CertificateLookup.sendCertificateLookupRequest(accRec.Id);
        test.stopTest();
        
    }
    public class certificateLookupResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String jsonInput = '{"CertificateDetails":{"ID":"6681201","PrimaryID":"6681201","LastName":"HAISTEN","FirstName":"ALBERT","certRecord":[{}],"ResponseCode":0,"ResponseMsg":"Successful"}}';
            
            res.setHeader('Content-Type', 'application/json');
            res.setBody(jsonInput);
            res.setStatusCode(200);
            return res;
        }
    }
}