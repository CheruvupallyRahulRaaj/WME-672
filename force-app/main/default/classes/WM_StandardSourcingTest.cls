@isTest
private class WM_StandardSourcingTest { 
    @isTest static void testNoResults() {
        List<WM_SourcingRequest> requestList = new List<WM_SourcingRequest>();
        
        //Empty list
        List<WM_StandardSourcing.Response> responses = WM_StandardSourcing.getFulfillmentGroups(requestList);
        System.assertEquals(0, responses.size(), 'Results are not empty');
        
        //null input or output  
        WM_SourcingRequest request = new WM_SourcingRequest();
        requestList.add(request);
        responses = WM_StandardSourcing.getFulfillmentGroups(requestList);
        System.assertEquals(1, responses.size(), 'Results are not 1');
        System.assertEquals(0, responses[0].fulfillmentGroups.size(), 'Fulfillment groups are not empty');
        
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
        responses = WM_StandardSourcing.getFulfillmentGroups(requestList);
        System.assertEquals(1, responses.size(), 'Results are not 1');
        System.assertEquals(0, responses[0].fulfillmentGroups.size(), 'Fulfillment groups are not empty');
        System.assert(!responses[0].fullyAllocated, 'Should not be fully allocated');

        //locations empty
        request.locations = locationsInput;
        request.allLocations = locationsInput;
        responses = WM_StandardSourcing.getFulfillmentGroups(requestList);
        System.assertEquals(1, responses.size(), 'Results are not 1');
        System.assertEquals(0, responses[0].fulfillmentGroups.size(), 'Fulfillment groups are not empty');
        System.assert(!responses[0].fullyAllocated, 'Should not be fully allocated');
        
        //OrderDeliveryGroup still null and locations not empty
        Schema.Location testLocation = new Schema.Location();
        testLocation.ExternalReference = '760';
        testLocation.LocationType = 'Warehouse';
        testLocation.preferredShipComplete__c = true;
        locationsInput.add(testLocation);
        responses = WM_StandardSourcing.getFulfillmentGroups(requestList);
        System.assertEquals(1, responses.size(), 'Results are not 1');
        System.assertEquals(0, responses[0].fulfillmentGroups.size(), 'Fulfillment groups are not empty');
        System.assert(!responses[0].fullyAllocated, 'Should not be fully allocated');
        
        //No inventory anywhere but everything passed
        ConnectApi.OCILocationAvailabilityOutputRepresentation miInventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        miInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        miInventory.locationIdentifier = 'MI';
        locationsFromOCI.add(miInventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation miItem1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        miItem1.availableToFulfill = 0;
        miItem1.stockKeepingUnit = 'item1';
        miInventory.inventoryRecords.add(miItem1);
        request.isStoreShipment = false;
        
        //create line item
        List<OrderItemSummary> orderItems = new List<OrderItemSummary>();
        request.lineItems = orderItems;
        OrderItemSummary item1 = new OrderItemSummary();
        item1.QuantityOrdered = 2;
        item1.QuantityAllocated = 1;
        item1.QuantityCanceled = 0;
        item1.Name = 'item1';
        orderItems.add(item1);
        
        request.deliveryGroup = orderDeliveryGroup;
        responses = WM_StandardSourcing.getFulfillmentGroups(requestList);
        System.assertEquals(1, responses.size(), 'Results are not 1');
        System.assertEquals(0, responses[0].fulfillmentGroups.size(), 'Fulfillment groups are not empty');
        System.assert(!responses[0].fullyAllocated, 'Should not be fully allocated');
        

    }
    
    @isTest static void testPredefinedLocations() {
        List<WM_SourcingRequest> requestList = new List<WM_SourcingRequest>();
        WM_SourcingRequest request = new WM_SourcingRequest();
        request.isStoreShipment = true;
        requestList.add(request);
        
        //Setup store and warehouse locations
        List<Schema.Location> locationsInput = new List<Schema.Location>();
        request.locations = locationsInput;
        request.allLocations = locationsInput;

        Schema.Location miLocation = new Schema.Location();
        miLocation.ExternalReference = 'MI';
        miLocation.Name = 'MI Store';
        miLocation.LocationType = 'Store';
        miLocation.Phone__c = '734-555-1212';
        miLocation.preferredShipComplete__c = false;
        miLocation.latitude = 42.48895134820102;
        miLocation.longitude = -83.08447553977496;
        insert miLocation;
        locationsInput.add(miLocation);

        Schema.Location war13Location = new Schema.Location();
        war13Location.ExternalReference = '13';
        war13Location.Name = 'Warehouse13';
        war13Location.LocationType = 'Warehouse';
        war13Location.preferredShipComplete__c = true;
        war13Location.latitude = 42.48895134820102;
        war13Location.longitude = -83.08447553977496;
        insert war13Location;
        locationsInput.add(war13Location);        
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup();
        orderDeliveryGroup.DeliverToState = 'MI';
        orderDeliveryGroup.DeliverToCountry = 'US';
        OrderDeliveryGroup.PhoneNumber = '(734) 555-1212';  //Testing different formats
        orderDeliveryGroup.DeliverToLatitude = 42.66373780347178; 
        orderDeliveryGroup.DeliverToLongitude = -83.87917869508622;
        request.deliveryGroup = orderDeliveryGroup; 

        //create two line items
        List<OrderItemSummary> orderItems = new List<OrderItemSummary>();
        request.lineItems = orderItems;
        
        OrderItemSummary item1 = new OrderItemSummary();
        item1.QuantityOrdered = 2;
        item1.QuantityAllocated = 1;
        item1.QuantityCanceled = 0;
        item1.Name = 'item1';
        item1.wmWarehouse__c = 'MI';
        orderItems.add(item1);
        
        OrderItemSummary item2 = new OrderItemSummary();
        item2.QuantityOrdered = 3;
        item2.QuantityAllocated = 1;
        item2.QuantityCanceled = 0;
        item2.Name = 'item2';
        item2.wmWarehouse__c = '13';
        orderItems.add(item2);
        
        //create inventory results for unrelated location (should not consider inventory)
        List<ConnectApi.OCILocationAvailabilityOutputRepresentation> ociLocations = 
            new List<ConnectApi.OCILocationAvailabilityOutputRepresentation>();
        request.locationsFromOCI = ociLocations;
        
        ConnectApi.OCILocationAvailabilityOutputRepresentation wa14Inventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        wa14Inventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        wa14Inventory.locationIdentifier = '14';
        ociLocations.add(wa14Inventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation wa14Item1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        wa14Item1.availableToFulfill = 100;
        wa14Item1.stockKeepingUnit = 'item1';
        wa14Inventory.inventoryRecords.add(wa14Item1);

        List<WM_StandardSourcing.Response> responses = WM_StandardSourcing.getFulfillmentGroups(requestList);
        System.assertEquals(1, responses.size(), 'Results are not 1');
        System.assertEquals(2, responses[0].fulfillmentGroups.size(), 'Fulfillment groups are not 2');
        System.assertEquals(miLocation.Id, responses[0].fulfillmentGroups[0].fulfilledFromLocationId , 'Fulfillment location id wrong');
        System.assertEquals('Store/Hub To Store',responses[0].fulfillmentGroups[0].fulfillmentType , 'Fulfillment type wrong');
        System.assertEquals(1, responses[0].fulfillmentGroups[0].orderItemSummaries.size(), 'items are not 1');
        System.assertEquals(1, responses[0].fulfillmentGroups[0].orderItemSummaries[0].quantity, 'item 1 qty not 1');
        System.assertEquals('item1', responses[0].fulfillmentGroups[0].orderItemSummaries[0].orderItemSummaryId, 'item 1 Id not item 1');
 
        System.assertEquals(war13Location.Id, responses[0].fulfillmentGroups[1].fulfilledFromLocationId , 'Fulfillment location id wrong');
        System.assertEquals('Warehouse to Store',responses[0].fulfillmentGroups[1].fulfillmentType , 'Fulfillment type wrong');
        System.assertEquals(1, responses[0].fulfillmentGroups[1].orderItemSummaries.size(), 'items are not 1');
        System.assertEquals(2, responses[0].fulfillmentGroups[1].orderItemSummaries[0].quantity, 'item 2 qty not 3');
        System.assertEquals('item2', responses[0].fulfillmentGroups[1].orderItemSummaries[0].orderItemSummaryId, 'item 2 Id not item 2');
    }

    @isTest static void testSameStore() {
        List<WM_SourcingRequest> requestList = new List<WM_SourcingRequest>();
        WM_SourcingRequest request = new WM_SourcingRequest();
        request.isStoreShipment = true;
        requestList.add(request);
        
        //Setup same store location
        List<Schema.Location> locationsInput = new List<Schema.Location>();
        request.locations = locationsInput;
        request.allLocations = locationsInput;

        Schema.Location miLocation = new Schema.Location();
        miLocation.ExternalReference = 'MI';
        miLocation.Name = 'MI Store';
        miLocation.LocationType = 'Store';
        miLocation.Phone__c = '734-555-1212';
        miLocation.preferredShipComplete__c = false;
        miLocation.latitude = 42.48895134820102;
        miLocation.longitude = -83.08447553977496;
        insert miLocation;
        locationsInput.add(miLocation);
        
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup();
        orderDeliveryGroup.DeliverToState = 'MI';
        orderDeliveryGroup.DeliverToCountry = 'US';
        OrderDeliveryGroup.PhoneNumber = '(734) 555-1212';  //Testing different formats
        orderDeliveryGroup.DeliverToLatitude = 42.66373780347178; 
        orderDeliveryGroup.DeliverToLongitude = -83.87917869508622;
        orderDeliveryGroup.fromStoreId__c = 'MI';
        request.deliveryGroup = orderDeliveryGroup;

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
                
        //create inventory results for store 
        List<ConnectApi.OCILocationAvailabilityOutputRepresentation> ociLocations = 
            new List<ConnectApi.OCILocationAvailabilityOutputRepresentation>();
        request.locationsFromOCI = ociLocations;
        
        ConnectApi.OCILocationAvailabilityOutputRepresentation miInventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        miInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        miInventory.locationIdentifier = 'MI';
        ociLocations.add(miInventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation miItem1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        miItem1.availableToFulfill = 1;
        miItem1.stockKeepingUnit = 'item1';
        miInventory.inventoryRecords.add(miItem1);
        ConnectApi.OCIInventoryRecordOutputRepresentation miItem2 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        miItem2.availableToFulfill = 5;
        miItem2.stockKeepingUnit = 'item2';
        miInventory.inventoryRecords.add(miItem2);
        
        List<WM_StandardSourcing.Response> responses = WM_StandardSourcing.getFulfillmentGroups(requestList);
        System.assertEquals(1, responses.size(), 'Results are not 1');
        System.assertEquals(1, responses[0].fulfillmentGroups.size(), 'Fulfillment groups are not 1');
        System.assertEquals(miLocation.Id, responses[0].deliverToLocationId, 'Deliver to location id wrong');
        System.assertEquals(miLocation.Id, responses[0].fulfillmentGroups[0].fulfilledFromLocationId , 'Fulfillment location id wrong');
        System.assertEquals('Store/Hub To Store',responses[0].fulfillmentGroups[0].fulfillmentType , 'Fulfillment type wrong');
        System.assertEquals(2, responses[0].fulfillmentGroups[0].orderItemSummaries.size(), 'items are not 2');
        System.assertEquals(1, responses[0].fulfillmentGroups[0].orderItemSummaries[0].quantity, 'item 1 qty not 1');
        System.assertEquals(2, responses[0].fulfillmentGroups[0].orderItemSummaries[1].quantity, 'item 2 qty not 3');
        System.assertEquals('item1', responses[0].fulfillmentGroups[0].orderItemSummaries[0].orderItemSummaryId, 'item 1 Id not item 1');
        System.assertEquals('item2', responses[0].fulfillmentGroups[0].orderItemSummaries[1].orderItemSummaryId, 'item 2 Id not item 2');
        
        //test no inventory available
        miItem1.availableToFulfill = 0;
        miItem2.availableToFulfill = 0;
        responses = WM_StandardSourcing.getFulfillmentGroups(requestList);
        System.assertEquals(1, responses.size(), 'Results are not 1');
        System.assertEquals(0, responses[0].fulfillmentGroups.size(), 'Fulfillment groups are not 0');
    }

    @isTest static void testSameStoreAndPrimaryLocations() {
        List<WM_SourcingRequest> requestList = new List<WM_SourcingRequest>();
        WM_SourcingRequest request = new WM_SourcingRequest();
        request.isStoreShipment = true;
        requestList.add(request);
        
        //Setup same store location
        List<Schema.Location> locationsInput = new List<Schema.Location>();
        request.locations = locationsInput;
        request.allLocations = locationsInput;

        Schema.Location miLocation = new Schema.Location();
        miLocation.ExternalReference = 'MI';
        miLocation.Name = 'MI Store';
        miLocation.LocationType = 'Store';
        miLocation.Phone__c = '734-555-1212';
        miLocation.preferredShipComplete__c = false;
        miLocation.latitude = 42.48895134820102;
        miLocation.longitude = -83.08447553977496;
        insert miLocation;
        locationsInput.add(miLocation);
        
        //Setup primary locations
        Schema.Location war13Location = new Schema.Location();
        war13Location.ExternalReference = '13';
        war13Location.Name = 'Warehouse13';
        war13Location.LocationType = 'Warehouse';
        war13Location.preferredShipComplete__c = true;
        war13Location.latitude = 42.48895134820102;
        war13Location.longitude = -83.08447553977496;
        insert war13Location;
        locationsInput.add(war13Location);

        Schema.Location war14Location = new Schema.Location();
        war14Location.ExternalReference = '14';
        war14Location.Name = 'Warehouse14';
        war14Location.LocationType = 'Warehouse';
        war14Location.preferredShipComplete__c = true;
        war14Location.latitude = 42.48895134820102;
        war14Location.longitude = -83.08447553977496;
        insert war14Location;
        locationsInput.add(war14Location);

        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup();
        orderDeliveryGroup.DeliverToState = 'MI';
        orderDeliveryGroup.DeliverToCountry = 'US';
        OrderDeliveryGroup.PhoneNumber = '(734) 555-1212';  //Testing different formats
        orderDeliveryGroup.DeliverToLatitude = 42.66373780347178; 
        orderDeliveryGroup.DeliverToLongitude = -83.87917869508622;
        orderDeliveryGroup.fromStoreId__c = 'MI';
        request.deliveryGroup = orderDeliveryGroup;

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
        item2.QuantityAllocated = 0;
        item2.QuantityCanceled = 0;
        item2.Name = 'item2';
        orderItems.add(item2);
                
        //create inventory results for store and warehouses
        List<ConnectApi.OCILocationAvailabilityOutputRepresentation> ociLocations = 
            new List<ConnectApi.OCILocationAvailabilityOutputRepresentation>();
        request.locationsFromOCI = ociLocations;
        
        ConnectApi.OCILocationAvailabilityOutputRepresentation miInventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        miInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        miInventory.locationIdentifier = 'MI';
        ociLocations.add(miInventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation miItem2 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        miItem2.availableToFulfill = 2;
        miItem2.stockKeepingUnit = 'item2';
        miInventory.inventoryRecords.add(miItem2);
        
        ConnectApi.OCILocationAvailabilityOutputRepresentation waInventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        waInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        waInventory.locationIdentifier = '13';
        ociLocations.add(waInventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation waItem1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        waItem1.availableToFulfill = 100;
        waItem1.stockKeepingUnit = 'item1';
        waInventory.inventoryRecords.add(waItem1);
        ConnectApi.OCIInventoryRecordOutputRepresentation waItem2 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        waItem2.availableToFulfill = 100;
        waItem2.stockKeepingUnit = 'item2';
        waInventory.inventoryRecords.add(waItem2);

        ConnectApi.OCILocationAvailabilityOutputRepresentation wa14Inventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        wa14Inventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        wa14Inventory.locationIdentifier = '14';
        ociLocations.add(wa14Inventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation wa14Item1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        wa14Item1.availableToFulfill = 100;
        wa14Item1.stockKeepingUnit = 'item1';
        wa14Inventory.inventoryRecords.add(wa14Item1);
        
        List<WM_StandardSourcing.Response> responses = WM_StandardSourcing.getFulfillmentGroups(requestList);
        System.assertEquals(1, responses.size(), 'Results are not 1');
        System.assertEquals(2, responses[0].fulfillmentGroups.size(), 'Fulfillment groups are not 2');
        System.assertEquals(miLocation.Id, responses[0].fulfillmentGroups[0].fulfilledFromLocationId , 'MI Fulfillment location id wrong');
        System.assertEquals('Store/Hub To Store',responses[0].fulfillmentGroups[0].fulfillmentType , 'MI Fulfillment type wrong');
        System.assertEquals('Warehouse to Store',responses[0].fulfillmentGroups[1].fulfillmentType , 'WA Fulfillment type wrong');
        System.assertEquals(1, responses[0].fulfillmentGroups[0].orderItemSummaries.size(), 'items are not 1');
        System.assertEquals(2, responses[0].fulfillmentGroups[1].orderItemSummaries.size(), 'items are not 2');
        System.assertEquals(2, responses[0].fulfillmentGroups[0].orderItemSummaries[0].quantity, 'item 2 qty not 2');
        System.assertEquals(1, responses[0].fulfillmentGroups[1].orderItemSummaries[0].quantity, 'item 1 qty not 2');
        System.assertEquals(1, responses[0].fulfillmentGroups[1].orderItemSummaries[1].quantity, 'item 2 qty not 1');
        System.assertEquals('item1', responses[0].fulfillmentGroups[1].orderItemSummaries[0].orderItemSummaryId, 'item 1 Id not item 1');
        System.assertEquals('item2', responses[0].fulfillmentGroups[1].orderItemSummaries[1].orderItemSummaryId, 'item 2 Id not item 2');
        System.assertEquals('item2', responses[0].fulfillmentGroups[0].orderItemSummaries[0].orderItemSummaryId, 'item 2 Id not item 2');
        
        //test reduced inventory in warehouse 13, should go to all three locations
        waItem1.availableToFulfill = 1;
        responses = WM_StandardSourcing.getFulfillmentGroups(requestList);
        System.assertEquals(1, responses.size(), 'Results are not 1');
        System.assertEquals(2, responses[0].fulfillmentGroups.size(), 'Fulfillment groups are not 2');
        System.assertEquals('item1', responses[0].fulfillmentGroups[1].orderItemSummaries[0].orderItemSummaryId, 'item 1 Id not item 1');
        System.assertEquals(1, responses[0].fulfillmentGroups[1].orderItemSummaries[0].quantity, 'item 1 qty not 1');
    }
    
    @isTest static void testStoreShipComplete() {
        List<WM_SourcingRequest> requestList = new List<WM_SourcingRequest>();
        WM_SourcingRequest request = new WM_SourcingRequest();
        request.isStoreShipment = false;
        requestList.add(request);
        
        //Setup store location
        List<Schema.Location> locationsInput = new List<Schema.Location>();
        request.locations = locationsInput;
        request.allLocations = locationsInput;

        Schema.Location miLocation = new Schema.Location();
        miLocation.ExternalReference = 'MI';
        miLocation.Name = 'MI Store';
        miLocation.LocationType = 'Store';
        miLocation.Phone__c = '734-555-1212';
        miLocation.preferredShipComplete__c = false;
        miLocation.latitude = 42.48895134820102;
        miLocation.longitude = -83.08447553977496;
        insert miLocation;
        locationsInput.add(miLocation);
        
        //Setup primary locations
        Schema.Location war13Location = new Schema.Location();
        war13Location.ExternalReference = '13';
        war13Location.Name = 'Warehouse13';
        war13Location.LocationType = 'Warehouse';
        war13Location.preferredShipComplete__c = true;
        war13Location.latitude = 42.48895134820102;
        war13Location.longitude = -83.08447553977496;
        insert war13Location;
        locationsInput.add(war13Location);

        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup();
        orderDeliveryGroup.DeliverToState = 'MI';
        orderDeliveryGroup.DeliverToCountry = 'US';
        OrderDeliveryGroup.PhoneNumber = '(734) 555-1212';  
        orderDeliveryGroup.DeliverToLatitude = 42.66373780347178; 
        orderDeliveryGroup.DeliverToLongitude = -83.87917869508622;
        request.deliveryGroup = orderDeliveryGroup;

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
        
        //create inventory results for store and warehouses
        List<ConnectApi.OCILocationAvailabilityOutputRepresentation> ociLocations = 
            new List<ConnectApi.OCILocationAvailabilityOutputRepresentation>();
        request.locationsFromOCI = ociLocations;
        
        ConnectApi.OCILocationAvailabilityOutputRepresentation miInventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        miInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        miInventory.locationIdentifier = 'MI';
        ociLocations.add(miInventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation miItem1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        miItem1.availableToFulfill = 10;
        miItem1.stockKeepingUnit = 'item1';
        miInventory.inventoryRecords.add(miItem1);
        ConnectApi.OCIInventoryRecordOutputRepresentation miItem2 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        miItem2.availableToFulfill = 10;
        miItem2.stockKeepingUnit = 'item2';
        miInventory.inventoryRecords.add(miItem2);
        
        ConnectApi.OCILocationAvailabilityOutputRepresentation waInventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        waInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        waInventory.locationIdentifier = '13';
        ociLocations.add(waInventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation waItem2 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        waItem2.availableToFulfill = 100;
        waItem2.stockKeepingUnit = 'item2';
        waInventory.inventoryRecords.add(waItem2);

        ConnectApi.OCILocationAvailabilityOutputRepresentation wa14Inventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        wa14Inventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        wa14Inventory.locationIdentifier = '14';
        ociLocations.add(wa14Inventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation wa14Item2 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        wa14Item2.availableToFulfill = 100;
        wa14Item2.stockKeepingUnit = 'item2';
        wa14Inventory.inventoryRecords.add(wa14Item2);
        
        List<WM_StandardSourcing.Response> responses = WM_StandardSourcing.getFulfillmentGroups(requestList);
        System.assertEquals(1, responses.size(), 'Results are not 1');
        System.assertEquals(1, responses[0].fulfillmentGroups.size(), 'Fulfillment groups are not 1');
        System.assertEquals(null, responses[0].deliverToLocationId, 'Deliver to should not be set');
        System.assertEquals(miLocation.Id, responses[0].fulfillmentGroups[0].fulfilledFromLocationId , 'MI Fulfillment location id wrong');
        System.assertEquals('Store/Hub to Home',responses[0].fulfillmentGroups[0].fulfillmentType , 'MI Fulfillment type wrong');
        System.assertEquals(2, responses[0].fulfillmentGroups[0].orderItemSummaries.size(), 'items are not 1');
        System.assertEquals(1, responses[0].fulfillmentGroups[0].orderItemSummaries[0].quantity, 'item 1 qty not 2');
        System.assertEquals(2, responses[0].fulfillmentGroups[0].orderItemSummaries[1].quantity, 'item 2 qty not 1');
        System.assertEquals('item1', responses[0].fulfillmentGroups[0].orderItemSummaries[0].orderItemSummaryId, 'item 1 Id not item 1');
        System.assertEquals('item2', responses[0].fulfillmentGroups[0].orderItemSummaries[1].orderItemSummaryId, 'item 2 Id not item 2');
    }
        
    @isTest static void testStoreShipAndProximity() {
        List<WM_SourcingRequest> requestList = new List<WM_SourcingRequest>();
        WM_SourcingRequest request = new WM_SourcingRequest();
        request.isStoreShipment = false;
        requestList.add(request);
        
        //Setup store locations
        List<Schema.Location> locationsInput = new List<Schema.Location>();
        request.locations = locationsInput;
        request.allLocations = locationsInput;

        Schema.Location miLocation = new Schema.Location();
        miLocation.ExternalReference = 'MI';
        miLocation.Name = 'MI Store';
        miLocation.LocationType = 'Store';
        miLocation.Phone__c = '734-555-1212';
        miLocation.preferredShipComplete__c = false;
        miLocation.latitude = 42.48895134820102;
        miLocation.longitude = -83.08447553977496;
        insert miLocation;
        locationsInput.add(miLocation);
 
        Schema.Location moLocation = new Schema.Location();
        moLocation.ExternalReference = 'MO';
        moLocation.LocationType = 'Store';
        moLocation.Name = 'MO Store';
        moLocation.preferredShipComplete__c = false;
        moLocation.Phone__c = '734-555-1111';
        moLocation.latitude = 38.726435377678285;
        moLocation.longitude = -90.30526908680135;
        insert moLocation;
        locationsInput.add(moLocation);

        //Setup primary locations
        Schema.Location war13Location = new Schema.Location();
        war13Location.ExternalReference = '13';
        war13Location.Name = 'Warehouse13';
        war13Location.LocationType = 'Warehouse';
        war13Location.preferredShipComplete__c = true;
        war13Location.latitude = 42.48895134820102;
        war13Location.longitude = -80.08447553977496;
        insert war13Location;
        locationsInput.add(war13Location);

        Schema.Location war14Location = new Schema.Location();
        war14Location.ExternalReference = '14';
        war14Location.Name = 'Warehouse14';
        war14Location.LocationType = 'Warehouse';
        war14Location.preferredShipComplete__c = true;
        war14Location.latitude = 42.48895134820102;
        war14Location.longitude = -70.08447553977496;
        insert war14Location;
        locationsInput.add(war14Location);

        Schema.Location war15Location = new Schema.Location();
        war15Location.ExternalReference = '15';
        war15Location.Name = 'Warehouse15';
        war15Location.LocationType = 'Warehouse';
        war15Location.preferredShipComplete__c = true;
        war15Location.latitude = 42.48895134820102;
        war15Location.longitude = -60.08447553977496;
        insert war15Location;
        locationsInput.add(war15Location);

        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup();
        orderDeliveryGroup.DeliverToState = 'MI';
        orderDeliveryGroup.DeliverToCountry = 'US';
        OrderDeliveryGroup.PhoneNumber = '(734) 555-1212';  
        orderDeliveryGroup.DeliverToLatitude = 42.66373780347178; 
        orderDeliveryGroup.DeliverToLongitude = -83.57917869508622;
        request.deliveryGroup = orderDeliveryGroup;

        //create two line items
        List<OrderItemSummary> orderItems = new List<OrderItemSummary>();
        request.lineItems = orderItems;
        
        OrderItemSummary item1 = new OrderItemSummary();
        item1.QuantityOrdered = 4;
        item1.QuantityAllocated = 1;
        item1.QuantityCanceled = 0;
        item1.Name = 'item1';
        orderItems.add(item1);
        
        OrderItemSummary item2 = new OrderItemSummary();
        item2.QuantityOrdered = 9;
        item2.QuantityAllocated = 2;
        item2.QuantityCanceled = 1;
        item2.Name = 'item2';
        orderItems.add(item2);
        
        //create inventory results for stores and warehouses
        List<ConnectApi.OCILocationAvailabilityOutputRepresentation> ociLocations = 
            new List<ConnectApi.OCILocationAvailabilityOutputRepresentation>();
        request.locationsFromOCI = ociLocations;
        
        //Give both stores inventory for both items, testing tie and confirming logic for primary first
        ConnectApi.OCILocationAvailabilityOutputRepresentation miInventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        miInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        miInventory.locationIdentifier = 'MI';
        ociLocations.add(miInventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation miItem1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        miItem1.availableToFulfill = 10;
        miItem1.stockKeepingUnit = 'item1';
        miInventory.inventoryRecords.add(miItem1);
        ConnectApi.OCIInventoryRecordOutputRepresentation miItem2 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        miItem2.availableToFulfill = 1;
        miItem2.stockKeepingUnit = 'item2';
        miInventory.inventoryRecords.add(miItem2);
        
        ConnectApi.OCILocationAvailabilityOutputRepresentation moInventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        moInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        moInventory.locationIdentifier = 'MO';
        ociLocations.add(moInventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation moItem1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        moItem1.availableToFulfill = 10;
        moItem1.stockKeepingUnit = 'item1';
        moInventory.inventoryRecords.add(moItem1);
        ConnectApi.OCIInventoryRecordOutputRepresentation moItem2 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        moItem2.availableToFulfill = 1;
        moItem2.stockKeepingUnit = 'item2';
        moInventory.inventoryRecords.add(moItem2);
        
        //Give warehouses inventory only on item 2, and only enough so we hit all three in order
        ConnectApi.OCILocationAvailabilityOutputRepresentation waInventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        waInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        waInventory.locationIdentifier = '13';
        ociLocations.add(waInventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation waItem2 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        waItem2.availableToFulfill = 3;
        waItem2.stockKeepingUnit = 'item2';
        waInventory.inventoryRecords.add(waItem2);

        ConnectApi.OCILocationAvailabilityOutputRepresentation wa14Inventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        wa14Inventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        wa14Inventory.locationIdentifier = '14';
        ociLocations.add(wa14Inventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation wa14Item2 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        wa14Item2.availableToFulfill = 2;
        wa14Item2.stockKeepingUnit = 'item2';
        wa14Inventory.inventoryRecords.add(wa14Item2);        

        ConnectApi.OCILocationAvailabilityOutputRepresentation wa15Inventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        wa15Inventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        wa15Inventory.locationIdentifier = '15';
        ociLocations.add(wa15Inventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation wa15Item2 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        wa15Item2.availableToFulfill = 1;
        wa15Item2.stockKeepingUnit = 'item2';
        wa15Inventory.inventoryRecords.add(wa15Item2);

        //test this call, which should return 3 warehouses plus best store by proximity (MI) (4 total)
        List<WM_StandardSourcing.Response> responses = WM_StandardSourcing.getFulfillmentGroups(requestList);
        System.assertEquals(1, responses.size(), 'Results are not 1');
        System.assertEquals(4, responses[0].fulfillmentGroups.size(), 'Fulfillment groups are not 4');
        System.assertEquals(war13Location.Id, responses[0].fulfillmentGroups[0].fulfilledFromLocationId , 'Warehouse 13 Fulfillment location id wrong');
        System.assertEquals(war14Location.Id, responses[0].fulfillmentGroups[1].fulfilledFromLocationId , 'Warehouse 14 Fulfillment location id wrong');
        System.assertEquals(war15Location.Id, responses[0].fulfillmentGroups[2].fulfilledFromLocationId , 'Warehouse 15 Fulfillment location id wrong');
        System.assertEquals(miLocation.Id, responses[0].fulfillmentGroups[3].fulfilledFromLocationId , 'MI Store Fulfillment location id wrong');
        System.assertEquals('Warehouse to Home',responses[0].fulfillmentGroups[0].fulfillmentType , 'Warhouse Fulfillment type wrong');
        System.assertEquals('Warehouse to Home',responses[0].fulfillmentGroups[1].fulfillmentType , 'Warhouse Fulfillment type wrong');
        System.assertEquals('Warehouse to Home',responses[0].fulfillmentGroups[2].fulfillmentType , 'Warhouse Fulfillment type wrong');
        System.assertEquals('Store/Hub to Home',responses[0].fulfillmentGroups[3].fulfillmentType , 'MI Fulfillment type wrong');
        System.assertEquals(1, responses[0].fulfillmentGroups[0].orderItemSummaries.size(), 'items are not 1');
        System.assertEquals(1, responses[0].fulfillmentGroups[1].orderItemSummaries.size(), 'items are not 1');
        System.assertEquals(1, responses[0].fulfillmentGroups[2].orderItemSummaries.size(), 'items are not 1');
        System.assertEquals(1, responses[0].fulfillmentGroups[3].orderItemSummaries.size(), 'items are not 1');
        System.assertEquals(3, responses[0].fulfillmentGroups[0].orderItemSummaries[0].quantity, 'item 1 qty not 3');
        System.assertEquals(2, responses[0].fulfillmentGroups[1].orderItemSummaries[0].quantity, 'item 2 qty not 2');
        System.assertEquals(1, responses[0].fulfillmentGroups[2].orderItemSummaries[0].quantity, 'item 1 qty not 1');
        System.assertEquals(3, responses[0].fulfillmentGroups[3].orderItemSummaries[0].quantity, 'item 2 qty not 3');
        System.assertEquals('item2', responses[0].fulfillmentGroups[0].orderItemSummaries[0].orderItemSummaryId, 'item 2 Id not item 2');
        System.assertEquals('item2', responses[0].fulfillmentGroups[1].orderItemSummaries[0].orderItemSummaryId, 'item 2 Id not item 2');
        System.assertEquals('item2', responses[0].fulfillmentGroups[2].orderItemSummaries[0].orderItemSummaryId, 'item 2 Id not item 2');
        System.assertEquals('item1', responses[0].fulfillmentGroups[3].orderItemSummaries[0].orderItemSummaryId, 'item 1 Id not item 1');
    }
}