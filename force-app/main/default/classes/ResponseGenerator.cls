@isTest
        
          public class ResponseGenerator implements HttpCalloutMock {
          public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('POST', req.getMethod());
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requestId":"ef99c9ef-c307-4e75-90ad-8aac093dd7b7","responses":[{"recipientSendId":"ef99c9ef-c307-4e75-90ad-8aac093dd7b7","hasErrors":false,"messages":["Queued"]}]}');
            res.setStatusCode(200);
            return res;
       
    }
    
}