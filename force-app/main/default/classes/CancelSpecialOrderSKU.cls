public class CancelSpecialOrderSKU {
    @AuraEnabled
    public static OrderItemSummary getOrderItemSummary(Id OrderItemProductId){
    	return [SELECT Id,ProductCode,specialOrder__c,Special_Order_SKU__c,Status,StockKeepingUnit FROM OrderItemSummary WHERE Id = :OrderItemProductId LIMIT 1];
        
    }
    
}