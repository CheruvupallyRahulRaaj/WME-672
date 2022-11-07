/*Author : schauhan@liveareacx.com
 * Class : MockHttpResponseGenerator
 * Purpose : Creating a Mock Response Class for Http Callout for Pick Out Service
 * Date : 4th Jan'2021
 * 
 * */

@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement the interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('callout:PickOutService', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }
}