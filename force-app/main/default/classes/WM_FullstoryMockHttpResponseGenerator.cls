@isTest
global class WM_FullstoryMockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        JSONGenerator bodyJson = JSON.createGenerator(true);
        bodyJson.writeStartObject();
        bodyJson.writeFieldName('sessions');
        bodyJson.writeStartArray();
        bodyJson.writeStartObject();
        bodyJson.writeStringField('userId', 'u123456789123456');
        bodyJson.writeStringField('sessionId', 's12345678912345');
        bodyJson.writeStringField('createdTime', '1659374393');
        bodyJson.writeStringField('fsUrl', 'https://app.fullstory.com/ui/o-xxxxxx-na1/session/u123456789123456:s12345678912345');
        bodyJson.writeEndObject();
        bodyJson.writeEndArray();
        bodyJson.writeEndObject();
        res.setBody(bodyJson.getAsString());
        res.setStatusCode(200);
        return res;
    }
}