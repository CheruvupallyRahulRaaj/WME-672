/*Author : npendyala@liveareacx.com
* Class : WM_MemberLookupTest
* Purpose : 
* Date : 
* @last modified on  : 
* @last modified by  : 
* */
@isTest(seealldata=false)
public class WM_MemberLookupTest 
{
    @testSetup static void testData() 
    {
        Account Acc = new Account();
		Acc.Name = WMConstants.Name;
        Acc.loyaltyAccountNumber__c = '123456';
        Acc.cst_exempt_certificate__c = '123456';
        Acc.Test_Context__c = true;
		insert Acc;
        WM_WebServiceDetails__c custsetting = new WM_WebServiceDetails__c();
        custsetting.Name = 'Memberlookup';
        custsetting.WM_ApiKey__c = 'Memberlookup';
        insert custsetting;
     
    
    }
    @isTest static void memberLookupTestMethod()
    {
        Account accRec=[Select id,loyaltyAccountNumber__c From Account Limit 1];
        Test.setMock(HttpCalloutMock.class, new MemberLookupResponseGenerator());
        test.startTest();
        WM_MemberLookup.memberLookupService(accRec.Id);
        WM_MemberLookup.sendMemberDetailsLookupRequest(accRec.Id);
        WM_MemberLookup.checkForLoyalityNumber(accRec.Id);
        test.stopTest();
    }
    public class MemberLookupResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String jsonInput = '{"MemberDetails":{"ID":"6732456","PrimaryID":"6732456","LastName":"FOOKS","FirstName":"ROBERT","AddressLine1":"16 CONSTITUTION AVE","AddressLine2":"","City":"ANNAPOLIS","State":"MD","Zip":"21401","Country":"US","EnrollmentDate":"2003-09-02","MemberType":"SILVER","MemberStatus":"ACTIVE","MemberLevel":"WM FREE","MemberLevelDate":"2015-11-01","DuesExpDate":"2015-09-30","TowingExpDate":"2014-09-30","RoadExpDate":"0001-01-01","CertLastIssuedDate":"2014-07-10","Points":0.0,"PointsLifetime":5808.0,"PointsRedeemed":5550.0,"ResponseCode":0.0,"ResponseMsg":"Successful"}}';
            
            res.setHeader('Content-Type', 'application/json');

            res.setBody(jsonInput);
            res.setStatusCode(200);
            return res;
        }
    }
}