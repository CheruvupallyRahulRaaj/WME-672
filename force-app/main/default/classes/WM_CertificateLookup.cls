/*Author : npendyala@liveareacx.com
* Class : WM_CertificateLookup
* Purpose : 
* Date : 
* @last modified on  : 
* @last modified by  : 
* */
public class WM_CertificateLookup 
{
    @AuraEnabled
    Public static boolean checkForcertificateLookupNumber(string accID)
    {
        Boolean isLoyalitycertificateLookupNumberPresent = false;
        List<Account> accRecList =[Select Id, loyaltyAccountNumber__c From Account where Id=:accID  Limit 1];
        if(!string.isBlank(accRecList[0].loyaltyAccountNumber__c) )
        {
            isLoyalitycertificateLookupNumberPresent = true;
            return isLoyalitycertificateLookupNumberPresent;
        }
        return isLoyalitycertificateLookupNumberPresent;
    } 
     @AuraEnabled
    public static Map<String,Object> sendCertificateLookupRequest(Id accID){
        List<Account> accRecList =[Select Id, loyaltyAccountNumber__c From Account where Id=:accID  Limit 1];
        string accountCertificateNumber = string.valueof(accRecList[0].loyaltyAccountNumber__c);
        String responseBody = certificateLookupServiceCallout(accountCertificateNumber);
        System.debug('$$$responseBody='+responseBody);
        Map<String, Object> CertificateResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.debug('$$$CertificateResponseMap='+CertificateResponseMap);
        return CertificateResponseMap;
    }

    
        
    public static void certificateLookupService(Id accID){
        List<Account> accRecList =[Select Id, loyaltyAccountNumber__c From Account where Id=:accID  Limit 1];
        string Certificate = string.valueof(accRecList[0].loyaltyAccountNumber__c);
        certificateLookupServiceCallout(Certificate);
        
    }
    public static string certificateLookupServiceCallout(string Certificate)
    {
        HttpRequest http_request = new HttpRequest();
        //getting custom setting api key
        string apiKey = WM_WebServiceDetails__c.getValues('CertLookup').WM_ApiKey__c;
        //getting url from named credentials
        string endPointurl = 'callout:CertificateLookup?id='+Certificate; 
        http_request.setEndpoint(endPointurl);
        http_request.setMethod('GET');
        http_request.setHeader('api_key',apiKey); 
        http_request.setHeader('Content-Type', 'application/json');
        HttpResponse http_response = new HttpResponse();
        system.debug('http_response' + http_response);
        Http httpInstance = new Http();
        http_response = httpInstance.send(http_request);
        system.debug('getStatusCode ' + http_response.getStatusCode());
        
        if(http_response.getStatusCode()==200)
        {
            JSONParser responseJSON= JSON.createParser(http_response.getBody());
            system.debug('responseJSON ' + http_response.getBody());
            return http_response.getBody();
        }else {
            return null;
        }
        
        
    }
}