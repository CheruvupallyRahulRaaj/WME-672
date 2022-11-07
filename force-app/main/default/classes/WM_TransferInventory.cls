public class WM_TransferInventory {
    @InvocableMethod(label='Create transfer inventory requests for items')
    public static List<Response> createTransfersForFulfillmentGroups(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request request : requests) {
            Response response = new Response();
            
            
            if (request.lineItems == null || request.lineItems.size() == 0 || request.fulfillmentGroups == null) {
                continue;
            }
            
            //create and add inventory transfers for fulfillment groups
            ConnectApi.OCITransferReservationInputRepresentation transferRequest = new ConnectApi.OCITransferReservationInputRepresentation();
            
            //Create map for sku
            Map<String, String> itemIdToSKUMap = new Map<String, String>();
            
            for (OrderItemSummary item : request.lineItems) {
                if (item.Id == null) {
                  itemIdToSKUMap.put(item.Name, item.Name);  
                } else {
                  itemIdToSKUMap.put(item.Id, item.StockKeepingUnit);	  
                } 
            }
            
            system.debug('****request.fulfillmentGroups**** '+request.fulfillmentGroups);
            //create map for locations
            Map<String, String> locationIdToExternalReferenceMap = new Map<String, String>();
            
            for (Schema.Location location : request.locations) {
                locationIdToExternalReferenceMap.put(location.Id, location.ExternalReference);
            }
            Map<String,String> mapOfFulFillmentOrderwithLineItems = new Map<String,String>();
            
            
            List<ConnectApi.OCITransferReservationSingleInputRepresentation> singleInputRepresentations = new List<ConnectApi.OCITransferReservationSingleInputRepresentation>();
            
            for (ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroup : request.fulfillmentGroups) {
                String toLocationIdentifier = locationIdToExternalReferenceMap.get(fulfillmentGroup.fulfilledFromLocationId);
                for (ConnectApi.OrderItemSummaryInputRepresentation itemSummary : fulfillmentGroup.orderItemSummaries) {
                    if (itemIdToSKUMap.containsKey(itemSummary.orderItemSummaryId)) {
                        ConnectApi.OCITransferReservationSingleInputRepresentation singleInputRepresentation = new ConnectApi.OCITransferReservationSingleInputRepresentation();
                        singleInputRepresentation.fromLocationGroupIdentifier = request.locationGroupExternalReference;
                        singleInputRepresentation.toLocationIdentifier = toLocationIdentifier;
                        singleInputRepresentation.stockKeepingUnit = itemIdToSKUMap.get(itemSummary.orderItemSummaryId);
                        singleInputRepresentation.quantity = itemSummary.quantity;
                        singleInputRepresentation.actionRequestId = IASUtility.NewGuid()[0];
                        singleInputRepresentation.externalRefId = toLocationIdentifier;
                        singleInputRepresentations.add(singleInputRepresentation);
                    }
                }
            }
            transferRequest.transferRecords = singleInputRepresentations;
            ConnectApi.OCITransferReservationInputRepresentation transferReservatnInput = new ConnectApi.OCITransferReservationInputRepresentation();
            transferReservatnInput = transferRequest;
            response.transferReservationInput = transferReservatnInput;
            responses.add(response);
            
        }
        return responses;
    }
    //class for request
    public class Request {
        @InvocableVariable
        public List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups;
        @InvocableVariable
        public List<OrderItemSummary> lineItems;
        @InvocableVariable
        public List<Schema.Location> locations;
        @InvocableVariable
        public String locationGroupExternalReference;
        @InvocableVariable
        public List<String> fulfillmentOrderIds;
    }
    
    public class Response {
        @InvocableVariable
        public ConnectApi.OCITransferReservationInputRepresentation transferReservationInput;
    }
}