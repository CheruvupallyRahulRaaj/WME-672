public class WM_CutLengthSourcing {
    
    @InvocableMethod(label='Cut Length Sourcing')
    public static List<Schema.Location> getLocationId(List<WM_SourcingRequest> requestList) {
        List<Schema.Location> locationList = new List<Schema.Location>();
        for (WM_SourcingRequest request: requestList) {
            //check for a bad request
            if (request.locations == null || request.locations.size() == 0 || request.deliveryGroup == null) {
                locationList.add(null); //no response
                continue;
            }

            //Loop Through OCI Locations. Debug Only

            for (ConnectApi.OCILocationAvailabilityOutputRepresentation ociLocation : request.locationsFromOCI) {
                for(ConnectApi.OCIInventoryRecordOutputRepresentation invRec : ociLocation.inventoryRecords){
                    System.debug('AAA: SKU: ' + invRec.StockKeepingUnit + ' -- ' + invRec.availableToFulfill);
                }
            }

            Map<String,Decimal> quantityRequiredMap = new Map<String,Decimal>();

            for (OrderItemSummary lineItem : request.lineItems) {

                System.debug('AAA: LineItemSKU:' + lineItem.StockKeepingUnit);
                System.debug('AAA: LineItem Quantity Ordered:' + lineItem.QuantityOrdered);
                Decimal relevantQuantity = lineItem.QuantityOrdered;

                String lineItemKey = (lineItem.StockKeepingUnit != null) ? lineItem.StockKeepingUnit : lineItem.Name;
                if(relevantQuantity!=0){
                    if (quantityRequiredMap.containsKey(lineItemKey)) {
                        System.debug('AAA Putting: ' + lineItemKey + ' Quantity: ' +  quantityRequiredMap.get(lineItemKey) + relevantQuantity);
                        quantityRequiredMap.put(lineItemKey, quantityRequiredMap.get(lineItemKey) + relevantQuantity);
                    } else {
                        System.debug('AAA Putting New: ' + lineItemKey + ' Quantity: ' +  relevantQuantity);
                        quantityRequiredMap.put(lineItemKey, relevantQuantity);
                    }
                    
                }
            }
             
            //Fall back if everything else fails, return first location provided
            Schema.Location selectedLocation = request.locations[0];
            System.debug('Default Location: ' + selectedLocation.Id);
            
            //outside mainland using ASCII and USPS standards
            Set<String> outsideMainlandStateCodes = WM_SourcingRequest.getOutsideMainlandSet();
            
            //special case: inside mainland US
            if (request.deliveryGroup.DeliverToCountry == 'US' && 
                !outsideMainlandStateCodes.contains(request.deliveryGroup.DeliverToState) && 
                request.locationsFromOCI != null && request.locationsFromOCI.size() > 0 && request.lineItems != null) {
                    //Determine items required quantities
                    // Map<String,Decimal> quantityRequiredMap = request.getQuantityRequiredMap();
                    System.debug('Quantity Required Map:' + quantityRequiredMap);
                    Decimal itemsOrdered = request.getItemsOrdered();
                    System.debug('AAA: Items Ordered: ' + itemsOrdered);
                    Map<String, Schema.Location> storeMap = request.getStoreMap();
                    
                    //Determine stores with full inventory
                    List<Schema.Location> fullInventoryStores = new List<Schema.Location>();
                    
                    for (ConnectApi.OCILocationAvailabilityOutputRepresentation ociLocation : request.locationsFromOCI) {
                        System.debug('AAA: Location Identifier:' + ociLocation.locationIdentifier);
                        Decimal availableAtLocation = 0;
                        
                        for (ConnectApi.OCIInventoryRecordOutputRepresentation inventoryRecord : ociLocation.inventoryRecords) {
                            System.debug('AAA: Inventory Record Stock Keeping Unit:' + inventoryRecord.stockKeepingUnit);
                            Decimal requestedAmountForSku = quantityRequiredMap.get(inventoryRecord.stockKeepingUnit);
                            System.debug('AAA: Requested Amount for SKU:' + requestedAmountForSku);
                            
                            //check for inventory at this location
                            if (requestedAmountForSku != null) {
                                System.debug('AAA: Available to Fulfill at Location:' + inventoryRecord.availableToFulfill);
                                availableAtLocation += Math.min(requestedAmountForSku, inventoryRecord.availableToFulfill);
                                System.debug('AAA: Now Available at Location:' + availableAtLocation);
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
            
        }
        return locationList;
    }
}