@isTest
public class CreateOrderSummaryController {
	/*@AuraEnabled
    public static String processRequest(String json) {
        String orderId = '';
        orderId = SOMOrderUtility.CreateOrderForOS(json);
        
        return orderId;
    }

    @AuraEnabled
    public static String getAccount(String recordId, string sObjectName) {
        String accountId;

        if (sObjectName == 'Order') {
            accountId = [SELECT Account.Id FROM Order WHERE Id =: recordId LIMIT 1].Account.Id;
        } else if (sObjectName == 'OrderSummary') {
            accountId = [SELECT Account.Id FROM OrderSummary WHERE Id =: recordId LIMIT 1].Account.Id;
        }

        return accountId;
    }
    
    @AuraEnabled
	public static String getOrderSummaryURL(String recordId, String objectName) {
        String orderSummaryURL = '';
        String salesChannel = '';
        String originalOrderId = '';
        
        List<OrderSummary> OrderSummaryList = [SELECT Id, SalesChannelId FROM OrderSummary where id =:originalOrderId];
        orderSummaryURL = SCCCommerceCloudConnect.siteBaseUrl +'/on/demandware.store/Sites-'+ salesChannel+'-Site/'+ SCCCommerceCloudConnect.replaceOrderPath + originalOrderId;
        system.debug('%%$$orderSummaryURL'+ orderSummaryURL);
        return orderSummaryURL;
	}*/
}