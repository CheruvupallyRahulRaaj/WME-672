public class WM_CutLengthInventoryCheck {
    
    @InvocableMethod(label='Get Cut Length Locations')
    // public static List<ConnectApi.OCILocationAvailabilityOutputRepresentation> getCutLengthLocations(List<ConnectApi.OCILocationAvailabilityOutputRepresentation> locations) {
    public static List<WM_CutLengthLocationsResponse> getCutLengthLocations(List<WM_CutLengthLocationsRequest> requestList) {
        WM_CutLengthLocationsRequest request = requestList[0];
        List<WM_CutLengthLocationsResponse> responseList = new List<WM_CutLengthLocationsResponse>();
        WM_CutLengthLocationsResponse response= new WM_CutLengthLocationsResponse();
        response.locations = new List<ConnectApi.OCILocationAvailabilityOutputRepresentation>();
        responseList.add(response);
        Map<String,Decimal> CutLengthProducts = new Map<String,Decimal>();
        for(OrderItemSummary ois : request.orderItemSummaries){
            if(ois.cutLength__c == 'Y'){
                CutLengthProducts.put(ois.StockKeepingUnit,ois.Quantity);
            }
        }

        for(String sku : CutLengthProducts.keySet()){
            System.debug('AAAA:SKU:' + sku + ' Quantity:' + CutLengthProducts.get(sku));
        }



        for(ConnectApi.OCILocationAvailabilityOutputRepresentation location : request.locations){
            System.debug('AAAA:LocationIdentifier:' + location.locationIdentifier);
            if(location.locationIdentifier == '99990') response.locations.add(location);
            for(ConnectApi.OCIInventoryRecordOutputRepresentation invRec  : location.inventoryRecords){
                System.debug('AAAA:SKU:' + invRec.StockKeepingUnit + ' : AVailableToFUlfill:' + invRec.availableToFulfill);
                if(CutLengthProducts.containsKey(invRec.stockKeepingUnit)){
                    Decimal quantity = CutLengthProducts.get(invRec.stockKeepingUnit);
                    if(invRec.availableToFulfill >= quantity){
                        System.debug('AvailableGreaterThanRequested. Adding to Response');
                        response.locations.add(location);
                    }
                }
            }
        }

     /*   for(WM_CutLengthLocationsResponse resp : responseList){
            for(ConnectApi.OCILocationAvailabilityOutputRepresentation location : resp.locations){
                System.debug('AAAA:Response:LocationIdentifier:' + location.locationIdentifier);
                for(ConnectApi.OCIInventoryRecordOutputRepresentation invRec  : location.inventoryRecords){
                    System.debug('AAAA:Response:InventoryRecord:SKU' + invRec.stockKeepingUnit + ' : AvailbleToFulfill:' + invRec.availableToFulfill);
                }
            }

        } */
        return responseList;
    }

    public class WM_CutLengthLocationsRequest {
        @InvocableVariable(label='OCILocations' required=true)
        @AuraEnabled public List<ConnectApi.OCILocationAvailabilityOutputRepresentation> locations; 
        @InvocableVariable(label='Order Product Summaries' required=true)
        @AuraEnabled public List<OrderItemSummary> orderItemSummaries; 
    }

    public class WM_CutLengthLocationsResponse {
        @InvocableVariable(label='OCILocations' required=true)
        @AuraEnabled public List<ConnectApi.OCILocationAvailabilityOutputRepresentation> locations; 
    }
}