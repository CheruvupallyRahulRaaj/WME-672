/*Author : schauhan@liveareacx.com
 * Class : AurusMockHttpResponse
 * Purpose : Creating a Mock Response Class for Http Callout for Aurus Service
 * Date : 10th Feb'2021
 * 
 * */

@isTest
global class AurusMockHttpResponse implements HttpCalloutMock {
    // Implement the interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
       // System.assertEquals('/aurus-adsdk-web-service/auruspay/adsdk/authtransaction', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"TransResponse":{"CCTID":"06","POSID":"01","APPID":"04","TransDetailsData":{"TransDetailData":{"ResponseCode":"00000","ResponseText":"Approved"}}}}');
        res.setStatusCode(200);
        return res;
    }
}