public class WM_ShipCompletePick {
    Public Integer size{get;set;} 
    Public List<FulfillmentOrder> ShipOrders	{set;get;}
    public WM_ShipCompletePick(){
   	size=2000;
        ShipOrders= [SELECT FulfilledToName,FulfillmentOrderNUmber,OrderSummary.OrderNumber,DeliveryMethod.Id,DeliveryMethod.Name,CreatedDate,
                     (SELECT Product_SKU__c,MFG_Name__c,MFG__c,Description,Quantity FROM FulfillmentOrderLineItems WHERE (Not Description LIKE '%Shipping%'))
                       FROM FulfillmentOrder WHERE My_FulFillment_Location__c=true and Status='Assigned' and BOPIS__c=false and Type='Ship Complete' order by CreatedDate DESC
                      ];
    }
     
}