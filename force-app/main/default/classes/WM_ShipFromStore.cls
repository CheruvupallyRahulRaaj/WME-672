public class WM_ShipFromStore {
   Public Integer size{set;get;} 
    Public List<FulfillmentOrder> ShipOrders	{set;get;}
 	public WM_ShipFromStore(){
   	size=2000;
    ShipOrders = [SELECT FulfilledToName,FulfillmentOrderNUmber,OrderSummary.OrderNumber,DeliveryMethod.Id,DeliveryMethod.Name,CreatedDate,
                  (SELECT Product_SKU__c,MFG_Name__c,MFG__c,Description,Quantity FROM FulfillmentOrderLineItems WHERE (Not Description LIKE '%Shipping%'))
                  FROM FulfillmentOrder WHERE My_FulFillment_Location__c=true and Status='Assigned' and BOPIS__c=false and (NOT DeliveryMethod.Name LIKE '%VAN%') and (NOT Type='Ship Complete') order by CreatedDate DESC
                      ];
    }
    
}