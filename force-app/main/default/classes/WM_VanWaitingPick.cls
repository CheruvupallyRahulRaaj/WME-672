public class WM_VanWaitingPick {
    Public Integer size{get;set;} 
    Public List<FulfillmentOrder> ShipOrders	{set;get;}
 	public WM_VanWaitingPick(){
   	size=2000;
        ShipOrders = [SELECT FulfilledToName,FulfillmentOrderNUmber,OrderSummary.OrderNumber,DeliveryMethod.Id,DeliveryMethod.Name,CreatedDate,
                      (SELECT Product_SKU__c,MFG_Name__c,MFG__c,Description,Quantity FROM FulfillmentOrderLineItems WHERE (NOT Description LIKE '%Shipping%'))
                       FROM FulfillmentOrder WHERE Status='Assigned' and DeliveryMethod.Name LIKE '%VAN%' and My_FulFillment_Location__c=true and (NOT TYPE= 'Ship Complete')order by CreatedDate DESC
                      ];
    }
   }