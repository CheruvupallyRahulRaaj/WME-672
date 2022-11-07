public class WM_TransferInventoryBackToLocationGroup {
  @InvocableMethod(label='Create transfer inventory requests for items')
    public static List<Response> createTransfersForFulfillmentGroups(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request request : requests) {
            Response response = new Response();
            responses.add(response);
            
             if (request.canceledInput == null) {
                continue;
            }
            
            //create and add inventory transfers for fulfillment groups
            ConnectApi.OCITransferReservationInputRepresentation transferRequest = new ConnectApi.OCITransferReservationInputRepresentation();
            
                  //Create map for sku
            Map<String, String> itemIdToSKUMap = new Map<String, String>();
            List<Id> fulFillOrderLineItemIds = new List<Id>();
            for(ConnectApi.FulfillmentOrderLineItemInputRepresentation fulfilLineItem:request.canceledInput.fulfillmentOrderLineItemsToCancel){
                 fulFillOrderLineItemIds.add(fulfilLineItem.fulfillmentOrderLineItemId);
            }
            
            List<FulfillmentOrderLineItem> fulfillmentOrderLineItems = [SELECT Id, OrderItemSummaryId,OrderItemSummary.StockKeepingUnit FROM FulfillmentOrderLineItem where Id IN:fulFillOrderLineItemIds];
            for (FulfillmentOrderLineItem item : fulfillmentOrderLineItems) {
                itemIdToSKUMap.put(item.Id, item.OrderItemSummary.StockKeepingUnit);
            }
            
            
            //Create transfers as applicable
            List<ConnectApi.OCITransferReservationSingleInputRepresentation> singleInputRepresentations = new List<ConnectApi.OCITransferReservationSingleInputRepresentation>();
            for (ConnectApi.FulfillmentOrderLineItemInputRepresentation fulfilLineItem : request.canceledInput.fulfillmentOrderLineItemsToCancel) {
                    ConnectApi.OCITransferReservationSingleInputRepresentation singleInputRepresentation = new ConnectApi.OCITransferReservationSingleInputRepresentation();
                    singleInputRepresentation.fromLocationIdentifier = request.fromLocation.ExternalReference;
                    singleInputRepresentation.toLocationGroupIdentifier = request.locationGroupExternalReference;
                    singleInputRepresentation.stockKeepingUnit = itemIdToSKUMap.get(fulfilLineItem.fulfillmentOrderLineItemId);
                    singleInputRepresentation.quantity = fulfilLineItem.quantity;
                    singleInputRepresentation.actionRequestId = IASUtility.NewGuid()[0];
                    singleInputRepresentation.externalRefId = request.locationGroupExternalReference;
                    singleInputRepresentations.add(singleInputRepresentation);
            }
            
            transferRequest.transferRecords = singleInputRepresentations;
            System.debug(transferRequest);
            response.transferReservationInput = transferRequest;
        }
        
      
            
        return responses;
    }
        
    //class for request
    public class Request {
        @InvocableVariable
        public ConnectApi.FulfillmentOrderLineItemsToCancelInputRepresentation canceledInput;
        @InvocableVariable
        public Schema.Location fromLocation;
        @InvocableVariable
        public String locationGroupExternalReference;
    }
    
    public class Response {
        @InvocableVariable
		public ConnectApi.OCITransferReservationInputRepresentation transferReservationInput;
    }
}