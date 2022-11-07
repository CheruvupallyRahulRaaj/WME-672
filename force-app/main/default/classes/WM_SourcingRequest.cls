public class WM_SourcingRequest {
    @InvocableVariable(label='List of locations' required=true)
    @AuraEnabled public List<Schema.Location> locations; 
    @InvocableVariable(label='List of all locations' required=true)
    @AuraEnabled public List<Schema.Location> allLocations; 
    @InvocableVariable(label='Order Delivery Group' required=true)
    @AuraEnabled public OrderDeliveryGroup deliveryGroup; 
    @InvocableVariable(label='Is Store Shipment?' required=false)
    @AuraEnabled public Boolean isStoreShipment; 
    @InvocableVariable(label='Location Output from IAS/OCI Get Inventory Request' required=false)
    @AuraEnabled public List<ConnectApi.OCILocationAvailabilityOutputRepresentation> locationsFromOCI;   
    @InvocableVariable(label='Items ordered' required=true)
    @AuraEnabled public List<OrderItemSummary> lineItems;
    
    private Map<String,Decimal> quantityRequiredMap = null;
    private Decimal itemsOrdered = null;
    private Map<String, Schema.Location> storeMap = null;
    private Map<String, Schema.Location> primaryLocationMap = null;
    private Map<String, Schema.Location> allLocationMap = null;
    private Map<String, ConnectApi.OCILocationAvailabilityOutputRepresentation> inventoryReferenceLocationMap = null;
    private Map<String, List<OrderItemSummary>> skuItemsMap = null;
    private Map<String, String> locationIdToRefMap = null;
    
    //Determine items required quantities
    public Map<String,Decimal> getQuantityRequiredMap() {
        if (quantityRequiredMap == null) {
            setStoredValues();
        }
        
        return quantityRequiredMap;
    }
    
    public Decimal getItemsOrdered() {
        if (itemsOrdered == null) {
            setStoredValues();
        }
        
        return itemsOrdered;
    }
    
    //create map for sku to id 
    public Map<String, List<OrderItemSummary>> getSKUItemsMap() {
        if (skuItemsMap == null) {
            skuItemsMap = new Map<String, List<OrderItemSummary>>();
            
            //handle assigned items first because they are processed first
            for (OrderItemSummary item : lineItems) {
                if (item.wmWarehouse__c != null) {
                    //for testing purposes, use name for sku
                    String sku = (item.StockKeepingUnit != null) ? item.StockKeepingUnit : item.Name;
                    if (!skuItemsMap.containsKey(sku)) {
                        skuItemsMap.put(sku, new List<OrderItemSummary>());
                    }
                    skuItemsMap.get(sku).add(item);
                }
            }

            //handle unassigned items 
            for (OrderItemSummary item : lineItems) {
                if (item.wmWarehouse__c == null) {
                    //for testing purposes, use name for sku
                    String sku = (item.StockKeepingUnit != null) ? item.StockKeepingUnit : item.Name;
                    if (!skuItemsMap.containsKey(sku)) {
                        skuItemsMap.put(sku, new List<OrderItemSummary>());
                    }
                    skuItemsMap.get(sku).add(item);
                }
            }            
        }
        
        return skuItemsMap;
    }
    
    public Map<String, Schema.Location> getStoreMap() {
        if (storeMap == null) {
            setStoredValues();
        }
        
        return storeMap;
    }

    public Map<String, Schema.Location> getPrimaryLocationMap() {
        if (primaryLocationMap == null) {
            setStoredValues();
        }
        
        return primaryLocationMap;
    }

    public Map<String, Schema.Location> getAllLocationMap() {
        if (allLocationMap == null) {
            setStoredValues();
        }
        
        return allLocationMap;
    }
    
    public Map<String, String> getLocationIdToRefMap() {
        if (locationIdToRefMap == null) {
            setStoredValues();
        }
        
        return locationIdToRefMap;
    }
    
    public Map<String, ConnectApi.OCILocationAvailabilityOutputRepresentation> getInventoryReferenceLocationMap() {
        if (inventoryReferenceLocationMap == null) {
            setStoredValues();
        }
        
        return inventoryReferenceLocationMap;
    }
        
    //Method to determine closest location from a list
    public Schema.Location determineClosestLocation(List<Schema.Location> fulfillmentLocations, Schema.Location defaultLocation) {
        Schema.Location selectedLocation = defaultLocation;
        Decimal deliverToLatitude = deliveryGroup.DeliverToLatitude;
        Decimal deliverToLongitude = deliveryGroup.DeliverToLongitude;
        if (deliverToLatitude != null && deliverToLongitude != null) {
            Double closestDistance = null;
            deliverToLatitude = deliverToLatitude.stripTrailingZeros();
            deliverToLongitude = deliverToLongitude.stripTrailingZeros();
            System.debug(deliverToLatitude);
            System.debug(deliverToLongitude);
            Location deliverToLocation = Location.newInstance(deliverToLatitude, deliverToLongitude);
            for (Schema.Location fulfillmentLocation : fulfillmentLocations) {
                Double thisDistance = null;
                
                Decimal fulfillmentLocationLatitude = fulfillmentLocation.latitude;
                Decimal fulfillmentLocationLongitude = fulfillmentLocation.longitude;
                if (fulfillmentLocationLatitude != null && fulfillmentLocationLongitude != null) {
                    fulfillmentLocationLatitude = fulfillmentLocationLatitude.stripTrailingZeros();
                    fulfillmentLocationLongitude = fulfillmentLocationLongitude.stripTrailingZeros();
                    System.debug(fulfillmentLocationLatitude);
                    System.debug(fulfillmentLocationLongitude);
                    Location thisLocation = Location.newInstance(fulfillmentLocationLatitude, fulfillmentLocationLongitude);
                    thisDistance = thisLocation.getDistance(deliverToLocation, 'mi');
                }
                
                if (thisDistance != null) {
                    //Check for new best location
                    if (closestDistance == null || thisDistance < closestDistance) {
                        closestDistance = thisDistance;
                        selectedLocation = fulfillmentLocation;
                    }
                }
            }
        }
        
        return selectedLocation;                                                       
    }

    //Set stored values
    private void setStoredValues() {
        quantityRequiredMap = new Map<String,Decimal>();
        itemsOrdered = 0;
        boolean isHazmatOrder = false;
        boolean isTruckFreightOrder = false;
        
        Decimal relevantQuantity = 0;
        for (OrderItemSummary lineItem : lineItems) {
            System.debug('***OIS Size***' +lineItems.size());
            System.debug('***OIS Size***' +lineItem.StockKeepingUnit);
            itemsOrdered += lineItem.QuantityOrdered;
                 
            relevantQuantity = lineItem.QuantityOrdered - lineItem.QuantityAllocated -lineItem.QuantityCanceled;

                //mainly doing this for the test...
            String lineItemKey = (lineItem.StockKeepingUnit != null) ? lineItem.StockKeepingUnit : lineItem.Name;
            if(relevantQuantity!=0){
                if (quantityRequiredMap.containsKey(lineItemKey)) {
                    quantityRequiredMap.put(lineItemKey, quantityRequiredMap.get(lineItemKey) + relevantQuantity);
                } else {
                    quantityRequiredMap.put(lineItemKey, relevantQuantity);
                }
                
            }
            
            if (lineItem.truckFreight__c == true) {
                isTruckFreightOrder = true;
            }
            
            if (lineItem.hazardousMaterial__c == true) {
                isHazmatOrder = true;
            }
        }
        
        storeMap = new Map<String, Schema.Location>();
        primaryLocationMap = new Map<String, Schema.Location>();
        allLocationMap = new Map<String, Schema.Location>();
        locationIdToRefMap = new Map<String, String>();
        Set<String> outsideMainlandStateCodes = getOutsideMainlandSet();
        
         for (Schema.Location location : allLocations) {
            allLocationMap.put(location.ExternalReference, location);
        }    
           
                    
        for (Schema.Location location : locations) {
            if (location.ExternalReference != null) {
                 System.debug('Sourcing Requeest first ---->'+location);
                Map<String, Schema.Location> mapToUse = (location.LocationType == 'Store') ? storeMap : primaryLocationMap;
                if (((isHazmatOrder && location.isHazmat__c) || !isHazmatOrder) && 
                    ((isTruckFreightOrder && location.isTruckFreight__c) || !isTruckFreightOrder)) {
                        if ((deliveryGroup.DeliverToState != 'PR') && (deliveryGroup.DeliverToState != 'HI') && (deliveryGroup.DeliverToState != 'AK')) {
                            //For non PR, HI, or AK deliveries we add *all* primary and contiguous US store locations, which excludes PR, AK, and HI
                            if (location.LocationType != 'Store' || !outsideMainlandStateCodes.contains(location.State__c)) {
                                System.debug('****1st IF****' +location.ExternalReference);
                                System.debug('***MapToUse is***' +mapToUse);
                                mapToUse.put(location.ExternalReference, location);
                            }
                        } else if (location.State__c == deliveryGroup.DeliverToState) {
                            //HI can deliver to HI, PR can deliver to PR, and AK can deliver to AK
                            System.debug('****2nd IF****' +location.ExternalReference);
                            System.debug('***MapToUse is***' +mapToUse);
                            mapToUse.put(location.ExternalReference, location);
                        } else if (deliveryGroup.DeliverToState != 'PR' && location.LocationType != 'Store') {
                            //HI and AK can use any primary location
                            System.debug('****HI/AK****' +location.ExternalReference);
                            System.debug('***MapToUse is***' +mapToUse);
                            mapToUse.put(location.ExternalReference, location);
                            
                        } else if (deliveryGroup.DeliverToState == 'PR' && location.LocationType != 'Store' && !outsideMainlandStateCodes.contains(location.State__c)) {
                            //PR can only use contiguous primary locations
                            System.debug('****4th IF****' +location.ExternalReference);
                            System.debug('***MapToUse is***' +mapToUse);
                            mapToUse.put(location.ExternalReference, location);
                        }
                } 
             
                locationIdToRefMap.put(location.Id, location.ExternalReference);
            }
        }
        System.debug('Final Store Map***' +storeMap.size());
        System.debug('Final Primary Map***' +primaryLocationMap.size());
        if(storeMap.size()>0){
            for(String key: storeMap.keySet()){
                System.debug('ExIdentifierStoreMap: ' + key);
            }
        }
        if(primaryLocationMap.size()>0){
            for(String key: primaryLocationMap.keySet()){
                System.debug('ExIdentifierPrimaryMap: ' + key);
            }
        }
     
        inventoryReferenceLocationMap = new Map<String, ConnectApi.OCILocationAvailabilityOutputRepresentation>();      
        
        for (ConnectApi.OCILocationAvailabilityOutputRepresentation ociLocation : locationsFromOCI) {
            System.debug('AAAA OCI:' + ociLocation);
            System.debug('AAAA ociLocationIdentifier:' + ociLocation.locationIdentifier);
            if (inventoryReferenceLocationMap.containsKey(ociLocation.locationIdentifier)) {
                ConnectApi.OCILocationAvailabilityOutputRepresentation existingLocation = inventoryReferenceLocationMap.get(ociLocation.locationIdentifier);
                existingLocation.inventoryRecords.addAll(ociLocation.inventoryRecords);
            } else {
                inventoryReferenceLocationMap.put(ociLocation.locationIdentifier,ociLocation);
            }
        }
    }
    
    public static Set<String> getOutsideMainlandSet() {
        Set<String> outsideMainlandStateCodes = new Set<String>();
        outsideMainlandStateCodes.add('AK');
        outsideMainlandStateCodes.add('HI');   
        outsideMainlandStateCodes.add('AS');
        outsideMainlandStateCodes.add('GU');
        outsideMainlandStateCodes.add('MP');
        outsideMainlandStateCodes.add('PR');
        outsideMainlandStateCodes.add('VI');
        outsideMainlandStateCodes.add('UM');
        outsideMainlandStateCodes.add('FM');
        outsideMainlandStateCodes.add('MH');
        outsideMainlandStateCodes.add('PW');
        outsideMainlandStateCodes.add('AA');
        outsideMainlandStateCodes.add('AE');
        outsideMainlandStateCodes.add('AP');
        outsideMainlandStateCodes.add('CM');
        outsideMainlandStateCodes.add('CZ');
        outsideMainlandStateCodes.add('NB');
        outsideMainlandStateCodes.add('PI');
        outsideMainlandStateCodes.add('TT');
        
        return outsideMainlandStateCodes;
    }
}