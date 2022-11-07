/*Author : npendyala@liveareacx.com
* Class : WM_MemberLookup
* Purpose : 
* Date : 
* @last modified on  : 
* @last modified by  : 
* */
public without sharing class WM_MemberLookup 
{
    @AuraEnabled
    Public static boolean checkForLoyalityNumber(string accID)
    {
        Boolean isLoyalityNumberPresent = false;
         List<Account> accRecList =[Select Id, loyaltyAccountNumber__c From Account where Id=:accID  Limit 1];
        if(!string.isBlank(accRecList[0].loyaltyAccountNumber__c) )
        {
            isLoyalityNumberPresent = true;
            return isLoyalityNumberPresent;
        }
        return isLoyalityNumberPresent;
    }
    
    @AuraEnabled
    public static Map<String,Object> sendMemberDetailsLookupRequest(Id accID){
        List<Account> accRecList =[Select Id, loyaltyAccountNumber__c From Account where Id=:accID  Limit 1];
        string accountLoyalityNumber = string.valueof(accRecList[0].loyaltyAccountNumber__c);
        String responseBody = memberLookupServiceCallout(accountLoyalityNumber);
        System.debug('$$$responseBody='+responseBody);
        Map<String, Object> memberResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.debug('$$$memberResponseMap='+memberResponseMap);
        return memberResponseMap;
    }
    
    public static void memberLookupService(Id accID){
        List<Account> accRecList =[Select Id, loyaltyAccountNumber__c From Account where Id=:accID  Limit 1];
        string accountLoyalityNumber = string.valueof(accRecList[0].loyaltyAccountNumber__c);
        memberLookupServiceCallout(accountLoyalityNumber);
        
    }
    public static string memberLookupServiceCallout(string accountLoyalityNumber)
    {
       
        HttpRequest http_request = new HttpRequest();
        //getting custom setting api key
        string apiKey = WM_WebServiceDetails__c.getValues('Memberlookup').WM_ApiKey__c;
        //getting url from named credentials
        string endPointurl = 'callout:MemberLookup?id='+accountLoyalityNumber;
        system.debug( 'endPointurl '+ endPointurl);
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
            system.debug('responseJSON' + http_response.getBody() );
            return http_response.getBody();
        }else {
            return null;
        }
        
    }
    
}