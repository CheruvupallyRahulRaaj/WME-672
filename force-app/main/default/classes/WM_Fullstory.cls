public with sharing class WM_Fullstory {

    @AuraEnabled
    public static Boolean getEnabled() {
        try {
            return [SELECT Enabled__c FROM WM_Tools_Configuration__c WHERE Name = 'Fullstory' LIMIT 1].Enabled__c;
        } catch (QueryException e) {
            System.debug('Missing fullstory configuration');
        }
        return false;
    }

    @AuraEnabled
    public static string getSessions(string channel, string email) {
        if (String.isBlank(email)) {
            throw new CalloutException('No email provided');
        }
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        if (channel == 'WestMarine') {
            req.setEndpoint('callout:Fullstory_API_WestMarine/sessions/v2?email=' + email);
        } else if (channel == 'WestMarinePro') {
            req.setEndpoint('callout:Fullstory_API_WestMarinePro/sessions/v2?email=' + email);
        } else {
            throw new CalloutException('Unknown channel: ' + channel);
        }
        req.setHeader('Authorization', '{!$Credential.UserName} {!$Credential.Password}');
        req.setMethod('GET');
        HttpResponse resp = http.send(req);
        return resp.getBody();
    }

    @AuraEnabled
    public static string getChannelName(string recordId) {
        try {
            return [SELECT SalesChannelName FROM SalesChannel WHERE id =: recordId LIMIT 1].SalesChannelName;
        } catch (QueryException e) {
            throw new QueryException('No sales channel with id: ' + recordId);
        }
    }
}