public class WM_ShipCompleteSourcing {
    @InvocableMethod(label='Get Ship Complete Location')
    public static List<Schema.Location> getLocationId(List<WM_SourcingRequest> requestList) {
        List<Schema.Location> locationList = new List<Schema.Location>();
        for (WM_SourcingRequest request: requestList) {
            //check for a bad request
            if (request.locations == null || request.locations.size() == 0 || request.deliveryGroup == null) {
                locationList.add(null); //no response
                continue;
            }
             
            //Fall back if everything else fails, return first location provided
            Schema.Location selectedLocation = request.locations[0];
            
            //outside mainland using ASCII and USPS standards
            Set<String> outsideMainlandStateCodes = WM_SourcingRequest.getOutsideMainlandSet();
            
            //special case: inside mainland US
            if (request.deliveryGroup.DeliverToCountry == 'US' && 
                !outsideMainlandStateCodes.contains(request.deliveryGroup.DeliverToState) && 
                request.locationsFromOCI != null && request.locationsFromOCI.size() > 0 && request.lineItems != null) {
                    //Determine items required quantities
                    Map<String,Decimal> quantityRequiredMap = request.getQuantityRequiredMap();
                    Decimal itemsOrdered = request.getItemsOrdered();
                    Map<String, Schema.Location> storeMap = request.getStoreMap();
                    
                    //Determine stores with full inventory
                    List<Schema.Location> fullInventoryStores = new List<Schema.Location>();
                    
                    for (ConnectApi.OCILocationAvailabilityOutputRepresentation ociLocation : request.locationsFromOCI) {
                        Decimal availableAtLocation = 0;
                        
                        for (ConnectApi.OCIInventoryRecordOutputRepresentation inventoryRecord : ociLocation.inventoryRecords) {
                            Decimal requestedAmountForSku = quantityRequiredMap.get(inventoryRecord.stockKeepingUnit);
                            
                            //check for inventory at this location
                            if (requestedAmountForSku != null) {
                                availableAtLocation += Math.min(requestedAmountForSku, inventoryRecord.availableToFulfill);
                            }
                        }
                        
                        //check if this location has all the items
                        if (availableAtLocation == itemsOrdered && storeMap.containsKey(ociLocation.locationIdentifier)) {
                            fullInventoryStores.add(storeMap.get(ociLocation.locationIdentifier));
                        }
                    }
                    
                    
                    //we have a US store which can fulfill them all, using closest
                    if (fullInventoryStores.size() > 0) {
	                    Schema.Location bestStoreLocation = request.determineClosestLocation(fullInventoryStores, fullInventoryStores[0]);
                        locationList.add(bestStoreLocation);
                        continue;
                    }
                }
            
            //Find ship complete locations
            List<Schema.Location> shipCompleteLocations = new List<Schema.Location>();
            for (Schema.Location location : request.locations) {
                if (location.preferredShipComplete__c) {
                    shipCompleteLocations.add(location);
                    selectedLocation = location; //default is now a ship complete location
                }
            }
            
            //Find closest ship complete location
            selectedLocation = request.determineClosestLocation(shipCompleteLocations, selectedLocation);
            
            locationList.add(selectedLocation);
        } 
        return locationList;
    }
}