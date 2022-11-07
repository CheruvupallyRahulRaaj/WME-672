public class WM_Debug {
    @InvocableMethod(label='WMDebug')
    public static void debugMethod(List<Request> requestList) {
        
        for (Request request : requestList) {
            ConnectApi.FulfillmentOrderInputRepresentation foir = request.FulFillmentOrderInputRep;
            System.debug('WMDebug_:OrderSummaryId:' + foir.orderSummaryId);
            // System.debug('WMDebug_:OrderDeliveryGroupSummaryId:' + foir.orderDelivery​GroupSummaryId);
            if(foir.fulfillmentGroups !=null){
                System.debug('WMDebug_:FulfillmentGroups....Start:');
                for(ConnectApi.FulfillmentGroupInputRepresentation fgir : foir.fulfillmentGroups){
                    System.debug('WMDebug_:ReferenceId:' + fgir.referenceId);
                    System.debug('WMDebug_:FulfilledFromLocationId:' + fgir.fulfilledFromLocationId);
                    System.debug('WMDebug_:FulfillmentType:' + fgir.fulfillmentType);

                    if(fgir.OrderItemSummaries != null){
                        System.debug('WMDebug_:OrderItemSummaries... Start:');
                        for(ConnectApi.OrderItemSummaryInputRepresentation oisir : fgir.orderItemSummaries){
                            System.debug('WMDebug_:OrderItemSummaryId:' + oisir.orderItemSummaryId);
                            System.debug('WMDebug_:Quantity:' + oisir.quantity);
                        }
                        System.debug('WMDebug_:OrderItemSummaries... Start:');
                    }
                }
                System.debug('WMDebug_:FulfillmentGroups....End');

            }
        }
        
    }
    
    //class for request
    public class Request {
    	@InvocableVariable(required=true)
        public ConnectApi.FulfillmentOrderInputRepresentation FulFillmentOrderInputRep;

    }
}