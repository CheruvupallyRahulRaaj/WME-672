public class SCCShoppingCartAuraController {

    
    static SCCFileLogger logger = SCCFileLogger.getInstance();
    
    	@AuraEnabled
	public static String getSFCCCustomerId(String recordId, String objectName) {
        SCCCommerceCloudConnect.logger = logger;
       return getSFCCCustomerIdById(recordId, objectName, logger)==SCCCommerceCloudConnect.defaultCustomerId?null:getSFCCCustomerIdById(recordId, objectName, logger);
    }
    
	@AuraEnabled
	public static String getAccessToken(String recordId, String objectName) {
        SCCCommerceCloudConnect.logger = logger;
        String customerAuthToken = null;
        try{
            String agentAccessToken = SCCCommerceCloudConnect.connectToCommerceCloud();
            logger.debug('SCCShoppingCartAuraController', 'getAccessToken : '+ agentAccessToken); 
            if(agentAccessToken!=null && agentAccessToken!='' && objectName == 'Account'){
                customerAuthToken = SCCCommerceCloudConnect.getCustomerAuthToken(agentAccessToken, getSFCCCustomerIdById(recordId, objectName, logger)); 
            } else if(agentAccessToken!=null && agentAccessToken!='' && objectName == 'Contact'){
                customerAuthToken = SCCCommerceCloudConnect.getProCustomerAuthToken(agentAccessToken, getSFCCCustomerIdById(recordId, objectName, logger)); 
            }
          else if(agentAccessToken!=null && agentAccessToken!='' && objectName == 'OrderSummary'){
                customerAuthToken = SCCCommerceCloudConnect.getProCustomerAuthToken(agentAccessToken, getSFCCCustomerIdById(recordId, objectName, logger)); 
            }
            logger.debug('SCCShoppingCartAuraController', 'getAccessToken-customerAuthToken : '+ customerAuthToken);     
            return customerAuthToken;
        }catch(Exception e){
            logger.error('SCCShoppingCartAuraController.getAccessToken', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());  
            return customerAuthToken;
        }finally{
            logger.flush();
        }
	}

	@AuraEnabled
	public static String getStoreSessionURL() {
        String storeSessionURL = null;
        //storeSessionURL = SCCCommerceCloudConnect.siteBaseUrl+'/s/'+SCCCommerceCloudConnect.siteId+'/dw/shop/v22_4/sessions';
        storeSessionURL = SCCCommerceCloudConnect.wmSessionId;
        system.debug('%%$$getStoreSessionURL'+ storeSessionURL);
        return storeSessionURL;
	}

	@AuraEnabled
	public static String getStoreFrontURL() {
        String storeFrontURL = null;
        storeFrontURL = SCCCommerceCloudConnect.siteIdNew;
        system.debug('%%$$Site ID New'+ SCCCommerceCloudConnect.siteIdNew);
        //storeFrontURL = SCCCommerceCloudConnect.siteBaseUrl +'/on/demandware.store/Sites-' + SCCCommerceCloudConnect.siteId +'-Site/';
        system.debug('%%$$StoreFrontURL'+ storeFrontURL);
        return storeFrontURL;
	}

	@AuraEnabled
	public static String getProStoreSessionURL() {
        String storeSessionURL = null;
        //storeSessionURL = SCCCommerceCloudConnect.siteBaseUrl+'/s/'+SCCCommerceCloudConnect.proSiteId+'/dw/shop/v22_4/sessions';
        storeSessionURL = SCCCommerceCloudConnect.wmProSessionId;
        system.debug('%%$$getProStoreSessionURL'+ storeSessionURL);
        return storeSessionURL;
	}

	@AuraEnabled
	public static String getProStoreFrontURL() {
        String storeFrontURL = null;
        storeFrontURL = SCCCommerceCloudConnect.proSiteIdNew;
        //storeFrontURL = SCCCommerceCloudConnect.siteBaseUrl +'/on/demandware.store/Sites-' + SCCCommerceCloudConnect.proSiteId +'-Site/';
        system.debug('%%$$storeFrontURL'+ storeFrontURL);
        return storeFrontURL;
	}
    
    @AuraEnabled
	public static String getOrderSummaryURL(String recordId) {
        system.debug('==RecId :'+recordId);
        List<OrderSummary> orderSummaryList = [SELECT Id, SalesChannelId, OriginalOrderId, Account.IsPersonAccount FROM OrderSummary where id =:recordId LIMIT 1];
        if(orderSummaryList!= null && !orderSummaryList.isEmpty()){
            if(orderSummaryList[0].Account.IsPersonAccount){
                return getStoreSessionURL();
            }
            else{
                return getProStoreSessionURL();
            }
            //orderSummaryURL = SCCCommerceCloudConnect.
            // +'/on/demandware.store/Sites-' + orderSummaryList[0].SalesChannelId +'-Site/'+ SCCCommerceCloudConnect.replaceOrderPath + orderSummary.OriginalOrderId;
        }
            //system.debug('%%$$orderSummaryURL'+ orderSummaryURL);
        return '';
	}
    
    @AuraEnabled
	public static String getOrderSummaryStoreFrontURL(String recordId) {
        List<OrderSummary> orderSummaryList = [SELECT Id, SalesChannelId, OriginalOrderId, Account.IsPersonAccount,Contact__c  FROM OrderSummary where id =:recordId LIMIT 1];
        if(orderSummaryList!= null && !orderSummaryList.isEmpty()){       
             if(orderSummaryList[0].Account.IsPersonAccount){
                return getStoreFrontURL();
            }
            else{
                return getProStoreFrontURL();
            }
            // orderSummaryStoreFrontURL = SCCCommerceCloudConnect.siteBaseUrl +'/on/demandware.store/Sites-' + orderSummaryList[0].SalesChannelId +'-Site/'+ SCCCommerceCloudConnect.replaceOrderPath + orderSummary.OriginalOrderId;
       
        }
           // system.debug('%%$$orderSummaryStoreFrontURL'+ orderSummaryStoreFrontURL);
        return '';
	}
    
	private static String getSFCCCustomerIdById(Id recordId, String objectName, SCCFileLogger logger) {

	String result = null;
	Case[] records;
	Account account;
    Contact contact;
        
	if(SCCUtilityClass.isPersonAccountEnabled()){
            logger.debug('SCCShoppingCartAuraController.getSFCCCustomerIdById', 'Person accoun enabled. getting SFCC Customer id from person account');
            if(objectName == 'Account'){ //b2c case: use siteId
                account = [SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc FROM Account WHERE Id = :recordId]; 
                if(account != null) {
                    result = account.SFCC_Customer_Id__pc;
                }
            }else if(objectName == 'Case'){
                records = [SELECT Id, Account.Id, Account.SFCC_Customer_Id__pc, Account.SFCC_Customer_Number__pc, ContactEmail FROM Case WHERE Id = :recordId]; 
                if(!records.isEmpty()) {
                    result = records[0].Account.SFCC_Customer_Id__pc;
                }
            }else if(objectName == 'Contact') { //b2b case: use new b2bSiteId
                contact = [SELECT Id, SFCC_Customer_Id__c, SFCC_Customer_Number__c, Email FROM Contact WHERE Id = :recordId];
                if (contact != null) {
                    result = contact.SFCC_Customer_Id__c;
                }            
            }
        else if(objectName == 'OrderSummary'){
             List<OrderSummary> orderSummaryList = [SELECT Id, SalesChannelId, OriginalOrderId, Account.IsPersonAccount,AccountId,Contact__c FROM OrderSummary where id =:recordId LIMIT 1];
        if(orderSummaryList!= null && !orderSummaryList.isEmpty()){       
             if(orderSummaryList[0].Account.IsPersonAccount){
                     account = [SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc FROM Account WHERE Id = :orderSummaryList[0].AccountId]; 
                if(account != null) {
                    result = account.SFCC_Customer_Id__pc;
                }
            }
            else{
                // confirm the below query
                contact = [SELECT Id, SFCC_Customer_Id__c, SFCC_Customer_Number__c, Email,AccountId  FROM Contact WHERE Id = :orderSummaryList[0].Contact__c limit 1];
                if (contact != null) {
                    result = contact.SFCC_Customer_Id__c;
                }       
            }
        }
        }
        }else{
            //Person account is not enabled, Service connector code for OOBO is not supported for these orgs
	    logger.debug('SCCShoppingCartAuraController.getSFCCCustomerIdById', 'Person account in not enabled. getting SFCC Customer id from person account');
            records = [SELECT Id, Contact.Id, Contact.SFCC_Customer_Id__c, Contact.SFCC_Customer_Number__c, ContactEmail FROM Case WHERE Id = :recordId];
            if (!records.isEmpty()) {
                result = records[0].Contact.SFCC_Customer_Id__c;
            }            
        }
        
        if (result == null) {
            result = SCCCommerceCloudConnect.defaultCustomerId;
        }
        
        logger.debug('SCCShoppingCartAuraController.getSFCCCustomerIdById','Returning SFCC Customer ID: '+result);
		return result;
	}


	@AuraEnabled
	public static String getOOBOURL() {
        return SCCCommerceCloudConnect.OOBOUrl;
	}

	@AuraEnabled
	public static String getProOOBOURL() {
        return SCCCommerceCloudConnect.OOBOProURL;
	}
}