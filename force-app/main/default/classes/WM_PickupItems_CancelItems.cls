public class WM_PickupItems_CancelItems {
    @AuraEnabled
    public static void getCancelReason(Id fulfillmentOrderId, String pickListVal){
        List<FulFillmentOrder> lstFulfillmentOrders = [Select OrderSummaryId,Type,Status,madmobile_Status__c From FulfillmentOrder WHERE Id = :fulfillmentOrderId];
        Id ordrSumId = lstFulfillmentOrders[0].OrderSummaryId;
        lstFulfillmentOrders[0].Status = 'Cancelled';
        lstFulfillmentOrders[0].CancelReason__c = pickListVal;
        //List<OrderItemSummaryChange> orderChange Select id from apexlog= [SELECT ChangeOrderItemId,ChangeType,CreatedById,CreatedDate,Id,IsDeleted,IsPreFulfillment,LastModifiedById,LastModifiedDate,OrderItemSummaryChangeNumber,OrderItemSummaryId,OrderSummaryId,Reason,SystemModstamp FROM OrderItemSummaryChange WHERE OrderSummaryId =:ordrSumId];
        //for(OrderItemSummaryChange oitems:orderChange){
          //  oitems.Reason = pickListVal;
            //if(orderChange.size()>0){
              //  orderChange[0].Reason = pickListVal;
           // }
        //}
        //insert orderChange;
        update lstFulfillmentOrders;
    }
    @AuraEnabled
    public static void getPickupItems(Id fulfillmentOrderId){
        List<FulFillmentOrder> lstFulfillmentOrders = [Select OrderSummaryId,Status,madmobile_Status__c,Type From FulfillmentOrder WHERE Id = :fulfillmentOrderId];
        if(lstFulfillmentOrders[0].madmobile_Status__c=='READY_FOR_PICKUP'){
            lstFulfillmentOrders[0].Status = 'Fulfilled';
            lstFulfillmentOrders[0].madmobile_Status__c='COMPLETED';
            update lstFulfillmentOrders;
        }
       
    }

    @AuraEnabled
    public static FulFillmentOrder getFulfillment(Id fulfillmentOrderId){
        // Added FulfilledFromLocation.LocationType field for Ticket 5140
        // Added BOPIS__c field for WME-60
        return [Select OrderSummaryId,Type, Status,BOPIS__c,FulfilledFromLocation.LocationType,DeliveryMethod.Description,(SELECT id,Status from FulfillmentOrderShipments) From FulfillmentOrder WHERE Id = :fulfillmentOrderId LIMIT 1];
        
    }
    
}