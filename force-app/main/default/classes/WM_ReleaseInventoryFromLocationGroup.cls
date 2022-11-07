public class WM_ReleaseInventoryFromLocationGroup {
@InvocableMethod(label='Create release inventory requests for items')
    public static List<Response> createTransfersForFulfillmentGroups(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request request : requests) {
            Response response = new Response();
            responses.add(response);
            
            if (request.canceledInput == null) {
                continue;
            }
    
            
            ConnectApi.OCIReleaseReservationInputRepresentation releaseRequest = new ConnectApi.OCIReleaseReservationInputRepresentation();
            
            //Create map for sku
            Map<String, String> itemIdToSKUMap = new Map<String, String>();
            List<Id> orderItemSummaryIds = new List<Id>();
            for(ConnectApi.ChangeItemInputRepresentation lineItem:request.canceledInput.changeItems){
                 orderItemSummaryIds.add(lineItem.orderItemSummaryId);
            }
            
            List<OrderItemSummary> orderItemSummaries = [Select Id,StockKeepingUnit from OrderItemSummary where Id IN:orderItemSummaryIds];
            for (OrderItemSummary item : orderItemSummaries) {
                itemIdToSKUMap.put(item.Id, item.StockKeepingUnit);
            }
                        
            
            
            //Create transfers as applicable
            List<ConnectApi.OCIReleaseReservationSingleInputRepresentation> singleInputRepresentations = new List<ConnectApi.OCIReleaseReservationSingleInputRepresentation>();
                for(ConnectApi.ChangeItemInputRepresentation lineItem:request.canceledInput.changeItems){
                    ConnectApi.OCIReleaseReservationSingleInputRepresentation singleInputRepresentation = new ConnectApi.OCIReleaseReservationSingleInputRepresentation();
                    singleInputRepresentation.locationGroupIdentifier = request.locationGroupExternalReference;
                    singleInputRepresentation.stockKeepingUnit = itemIdToSKUMap.get(lineItem.orderItemSummaryId);
                    singleInputRepresentation.quantity = lineItem.quantity;
                    singleInputRepresentation.actionRequestId = IASUtility.NewGuid()[0];
                    singleInputRepresentation.externalRefId = request.locationGroupExternalReference;
                    singleInputRepresentations.add(singleInputRepresentation);
                }
            
            
            releaseRequest.releaseRecords = singleInputRepresentations;
            System.debug(releaseRequest);
            response.releaseReservationInput = releaseRequest;
        }
            
        return responses;
    }
        
    //class for request
    public class Request {
        @InvocableVariable
        public ConnectApi.ChangeInputRepresentation canceledInput;
        @InvocableVariable
        public String locationGroupExternalReference;
    }
    
    public class Response {
        @InvocableVariable
		public ConnectApi.OCIReleaseReservationInputRepresentation releaseReservationInput;
    }
}