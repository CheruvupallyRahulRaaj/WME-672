public class WM_FulfillmentOrderAdder {
    @InvocableMethod(label='Add items to first Fulfillment Group')
    public static List<Response> addItemsToFirstFulfillmentGroup(List<Request> requestList) {
		List<Response> responses = new List<Response>();
        
        for (Request request : requestList) {
            Response response = new Response();
            responses.add(response);
            response.fulfillmentGroups = request.fulfillmentGroups;

            for(ConnectApi.FulfillmentGroupInputRepresentation fg : request.fulfillmentGroups){
                System.debug('AAA: fulfilledFromLocationID:' + fg.fulfilledFromLocationId);
                System.debug('AAA: fulfillmentType:' + fg.fulfillmentType);
                for(ConnectApi.OrderItemSummaryInputRepresentation oisir : fg.orderItemSummaries){
                    System.debug('AAA: oisir: orderItemSummaryId:' + oisir.orderItemSummaryId);
                    System.debug('AAA: oisir: quantity:' + oisir.quantity);
                }
            }
            
            if (request.fulfillmentGroups.size() > 0 && request.lineItems.size() > 0) {
            	ConnectApi.FulfillmentGroupInputRepresentation firstFulfillmentGroup = request.fulfillmentGroups[0]; 
                firstFulfillmentGroup.orderItemSummaries.addAll(request.lineItems);
            }
        }
        
        return responses;
    }
    
    //class for request
    public class Request {
        @InvocableVariable(required=true)
        public List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups;
    	@InvocableVariable(required=true)
    	public List<ConnectApi.OrderItemSummaryInputRepresentation> lineItems;
    }
    
    //class for response
    public class Response {
        @InvocableVariable
        public List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups;
    }
}