@isTest
private class WM_ShipCompleteSourcingTest {
    @isTest static void testNoResults() {
        List<WM_SourcingRequest> requestList = new List<WM_SourcingRequest>();
        
        //Empty list
        List<Schema.Location> locations = WM_ShipCompleteSourcing.getLocationId(requestList);
        System.assertEquals(0, locations.size(), 'Results are not empty');
        
        //null input or output 
        WM_SourcingRequest request = new WM_SourcingRequest();
        requestList.add(request);
		locations = WM_ShipCompleteSourcing.getLocationId(requestList);
        System.assertEquals(1, locations.size(), 'Results are not 1');
        System.assertEquals(null, locations[0], 'Should be null with invalid results');
        
        List<ConnectAPI.OCILocationAvailabilityOutputRepresentation> locationsFromOCI = new List<ConnectAPI.OCILocationAvailabilityOutputRepresentation>();
        List<Schema.Location> locationsInput = new List<Schema.Location>();
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup();
        orderDeliveryGroup.DeliverToState = 'MI';
        orderDeliveryGroup.DeliverToCountry = 'US';
        orderDeliveryGroup.DeliverToLatitude = 42.48895134820102;
        orderDeliveryGroup.DeliverToLongitude = -83.08447553977496;
        
        //locations null
        request.locations = null;
        request.locationsFromOCI = locationsFromOCI;
		locations = WM_ShipCompleteSourcing.getLocationId(requestList);
        System.assertEquals(1, locations.size(), 'Results are not 1');
        System.assertEquals(null, locations[0], 'Should be null with invalid results');

        //locations empty
        request.locations = locationsInput;
        request.allLocations = locationsInput;
        request.locationsFromOCI = locationsFromOCI;
		locations = WM_ShipCompleteSourcing.getLocationId(requestList);
        System.assertEquals(1, locations.size(), 'Results are not 1');
        System.assertEquals(null, locations[0], 'Should be null with invalid results');
        
        //OrderDeliveryGroup still null and locations not empty
        Schema.Location testLocation = new Schema.Location();
        testLocation.ExternalReference = '760';
        testLocation.LocationType = 'Warehouse';
        testLocation.preferredShipComplete__c = true;
        locationsInput.add(testLocation);
        System.assertEquals(1, locations.size(), 'Results are not 1');
        System.assertEquals(null, locations[0], 'Should be null with invalid results');
    }
    
    @isTest static void testResultsProximityOnlyNoInventory() {
        List<WM_SourcingRequest> requestList = new List<WM_SourcingRequest>();
        WM_SourcingRequest request = new WM_SourcingRequest();
        requestList.add(request);
        
        //Setup two ship complete locations and one not 
        List<Schema.Location> locationsInput = new List<Schema.Location>();
        request.locations = locationsInput;
        request.allLocations = locationsInput;

        Schema.Location miLocation = new Schema.Location();
        miLocation.ExternalReference = 'MI';
        miLocation.LocationType = 'Store';
        miLocation.preferredShipComplete__c = false;
        miLocation.latitude = 42.48895134820102;
        miLocation.longitude = -83.08447553977496;
        locationsInput.add(miLocation);
        
        Schema.Location eastLocation = new Schema.Location();
        eastLocation.ExternalReference = 'EAST';
        eastLocation.LocationType = 'Warehouse';
        eastLocation.preferredShipComplete__c = true;
        eastLocation.latitude = 40.78714087590433;
        eastLocation.longitude = -74.07624895032352;
        locationsInput.add(eastLocation);
        
        Schema.Location westLocation = new Schema.Location();
        westLocation.ExternalReference = 'WEST';
        westLocation.LocationType = 'Warehouse';
        westLocation.preferredShipComplete__c = true;
        westLocation.latitude = 34.11019398997387;
        westLocation.longitude = -118.20311326724908;
        locationsInput.add(westLocation);
        
        //Setup delivery location outside of US 
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup();
        orderDeliveryGroup.DeliverToState = 'ON';
        orderDeliveryGroup.DeliverToCountry = 'CA';
        orderDeliveryGroup.DeliverToLatitude = 42.285540252126964; 
        orderDeliveryGroup.DeliverToLongitude = -82.94011815689667;
        request.deliveryGroup = orderDeliveryGroup;

        //Location should be EAST and not MI though store closest
        List<Schema.Location> locations = WM_ShipCompleteSourcing.getLocationId(requestList);
        System.assertEquals(1, locations.size(), 'Results should be one');
        System.assertEquals('EAST', locations[0].ExternalReference, 'Result should be the EAST location');
        
        //Change delivery location
        orderDeliveryGroup.DeliverToState = 'BC';
        orderDeliveryGroup.DeliverToCountry = 'CA';
        orderDeliveryGroup.DeliverToLatitude = 49.32012722997818; 
        orderDeliveryGroup.DeliverToLongitude = -123.09285932400054;
        
        //Location should be WEST
        locations = WM_ShipCompleteSourcing.getLocationId(requestList);
        System.assertEquals(1, locations.size(), 'Results should be one');
        System.assertEquals('WEST', locations[0].ExternalReference, 'Result should be the WEST location');
    }
    
    @isTest static void testResultsUSMainlandWithInventory() {
        List<WM_SourcingRequest> requestList = new List<WM_SourcingRequest>();
        WM_SourcingRequest request = new WM_SourcingRequest();
        requestList.add(request);
        
        //Setup two ship complete locations and two stores 
        List<Schema.Location> locationsInput = new List<Schema.Location>();
        request.locations = locationsInput;
        request.allLocations = locationsInput;

        Schema.Location miLocation = new Schema.Location();
        miLocation.ExternalReference = 'MI';
        miLocation.LocationType = 'Store';
        miLocation.preferredShipComplete__c = false;
        miLocation.latitude = 42.48895134820102;
        miLocation.longitude = -83.08447553977496;
        locationsInput.add(miLocation);
        
        Schema.Location moLocation = new Schema.Location();
        moLocation.ExternalReference = 'MO';
        moLocation.LocationType = 'Store';
        moLocation.preferredShipComplete__c = false;
        moLocation.latitude = 38.726435377678285;
        moLocation.longitude = -90.30526908680135;
        locationsInput.add(moLocation);

        Schema.Location eastLocation = new Schema.Location();
        eastLocation.ExternalReference = 'EAST';
        eastLocation.LocationType = 'Warehouse';
        eastLocation.preferredShipComplete__c = true;
        eastLocation.latitude = 40.78714087590433;
        eastLocation.longitude = -74.07624895032352;
        locationsInput.add(eastLocation);
        
        Schema.Location westLocation = new Schema.Location();
        westLocation.ExternalReference = 'WEST';
        westLocation.LocationType = 'Warehouse';
        westLocation.preferredShipComplete__c = true;
        westLocation.latitude = 34.11019398997387;
        westLocation.longitude = -118.20311326724908;
        locationsInput.add(westLocation);
        
        //Setup delivery location inside US 
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup();
        orderDeliveryGroup.DeliverToState = 'MI';
        orderDeliveryGroup.DeliverToCountry = 'US';
        orderDeliveryGroup.DeliverToLatitude = 42.66373780347178; 
        orderDeliveryGroup.DeliverToLongitude = -83.87917869508622;
        request.deliveryGroup = orderDeliveryGroup;
        
        //No inventory info? Default to previous logic
        List<Schema.Location> locations = WM_ShipCompleteSourcing.getLocationId(requestList);
        System.assertEquals(1, locations.size(), 'Results should be one');
        System.assertEquals('EAST', locations[0].ExternalReference, 'Result should be the EAST location');
        
        //create two line items
        List<OrderItemSummary> orderItems = new List<OrderItemSummary>();
        request.lineItems = orderItems;
        
        OrderItemSummary item1 = new OrderItemSummary();
        item1.QuantityOrdered = 2;
        item1.QuantityAllocated = 1;
        item1.QuantityCanceled = 0;
        item1.Name = 'item1';
        orderItems.add(item1);
        
        OrderItemSummary item2 = new OrderItemSummary();
        item2.QuantityOrdered = 3;
        item2.QuantityAllocated = 1;
        item2.QuantityCanceled = 0;
        item2.Name = 'item2';
        orderItems.add(item2);
        
        //create inventory results for store locations
        List<ConnectApi.OCILocationAvailabilityOutputRepresentation> ociLocations = 
            new List<ConnectApi.OCILocationAvailabilityOutputRepresentation>();
        request.locationsFromOCI = ociLocations;
        
        ConnectApi.OCILocationAvailabilityOutputRepresentation miInventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
		miInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        miInventory.locationIdentifier = 'MI';
		ociLocations.add(miInventory);

        //Make sure we are okay without specific inventory records and without location results
        locations = WM_ShipCompleteSourcing.getLocationId(requestList);
        System.assertEquals(1, locations.size(), 'Results should be one');
        System.assertEquals('EAST', locations[0].ExternalReference, 'Result should be the EAST location');
        
        ConnectApi.OCILocationAvailabilityOutputRepresentation moInventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
		moInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        moInventory.locationIdentifier = 'MO';
		ociLocations.add(moInventory);

        //set no stores have available inventory, should still be EAST
        ConnectApi.OCIInventoryRecordOutputRepresentation miItem1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        miItem1.availableToFulfill = 1;
        miItem1.stockKeepingUnit = 'item1';
        miInventory.inventoryRecords.add(miItem1);
        ConnectApi.OCIInventoryRecordOutputRepresentation miItem2 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        miItem2.availableToFulfill = 1;
        miItem2.stockKeepingUnit = 'item2';
        miInventory.inventoryRecords.add(miItem2);
        ConnectApi.OCIInventoryRecordOutputRepresentation moItem1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        moItem1.availableToFulfill = 1;
        moItem1.stockKeepingUnit = 'item1';
        moInventory.inventoryRecords.add(moItem1);
        ConnectApi.OCIInventoryRecordOutputRepresentation moItem2 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        moItem2.availableToFulfill = 1;
        moItem2.stockKeepingUnit = 'item2';
        moInventory.inventoryRecords.add(moItem2);

        locations = WM_ShipCompleteSourcing.getLocationId(requestList);
        System.assertEquals(1, locations.size(), 'Results should be one');
        System.assertEquals('EAST', locations[0].ExternalReference, 'Result should be the EAST location');
        
        //let MO store have complete inventory but not mainland
        moItem1.availableToFulfill = 10;
        moItem2.availableToFulfill = 10;
        orderDeliveryGroup.DeliverToState = 'HI';

        locations = WM_ShipCompleteSourcing.getLocationId(requestList);
        System.assertEquals(1, locations.size(), 'Results should be one');
        System.assertEquals('EAST', locations[0].ExternalReference, 'Result should be the EAST location');

        //change state back, now MO store
        orderDeliveryGroup.DeliverToState = 'MI';
        locations = WM_ShipCompleteSourcing.getLocationId(requestList);
        System.assertEquals(1, locations.size(), 'Results should be one');
        System.assertEquals('EAST', locations[0].ExternalReference, 'Result should be the EAST location');
        
        //Give MI inventory, now it is closer
        miItem1.availableToFulfill = 10;
        miItem2.availableToFulfill = 10;
        locations = WM_ShipCompleteSourcing.getLocationId(requestList);
        System.assertEquals(1, locations.size(), 'Results should be one');
        System.assertEquals('EAST', locations[0].ExternalReference, 'Result should be the MI location');
    }    
}