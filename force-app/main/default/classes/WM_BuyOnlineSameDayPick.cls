public class WM_BuyOnlineSameDayPick {
	Public Integer size{get;set;} 
    Public List<FulfillmentOrder> ShipOrders	{set;get;}
    public WM_BuyOnlineSameDayPick(){
   	size=2000;
        ShipOrders =[SELECT FulfilledToName,FulfillmentOrderNUmber,OrderSummary.OrderNumber,DeliveryMethod.Id,DeliveryMethod.Name,CreatedDate,
                     (SELECT Product_SKU__c,MFG_Name__c,MFG__c,Description,Quantity FROM FulfillmentOrderLineItems WHERE (NOT Description LIKE '%Shipping%'))
                       FROM FulfillmentOrder WHERE My_FulFillment_Location__c=true and BOPIS__c=true and Status='Assigned'  order by CreatedDate DESC
                      ];
    }
     
    
}