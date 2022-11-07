public class WM_ReleaseInventoryForNonInventory {
@InvocableMethod(label='Create release inventory requests for items')
    public static List<Response> createTransfersForFulfillmentGroups(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request request : requests) {
            Response response = new Response();
            responses.add(response);
            
            if (request.orderItemSummaries == null || request.orderItemSummaries.size()==0) {
                continue;
            }
    
            
            ConnectApi.OCIReleaseReservationInputRepresentation releaseRequest = new ConnectApi.OCIReleaseReservationInputRepresentation();
            
  
            //Create transfers as applicable
            List<ConnectApi.OCIReleaseReservationSingleInputRepresentation> singleInputRepresentations = new List<ConnectApi.OCIReleaseReservationSingleInputRepresentation>();
                for(OrderItemSummary lineItem:request.orderItemSummaries){
                    ConnectApi.OCIReleaseReservationSingleInputRepresentation singleInputRepresentation = new ConnectApi.OCIReleaseReservationSingleInputRepresentation();
                    singleInputRepresentation.locationGroupIdentifier = request.locationGroupExternalReference;
                    singleInputRepresentation.stockKeepingUnit = lineItem.StockKeepingUnit;
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
        public List<OrderItemSummary> orderItemSummaries;
        @InvocableVariable
        public String locationGroupExternalReference;
    }
    
    public class Response {
        @InvocableVariable
		public ConnectApi.OCIReleaseReservationInputRepresentation releaseReservationInput;
    }
}