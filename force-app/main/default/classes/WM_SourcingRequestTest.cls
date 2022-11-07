@isTest
public class WM_SourcingRequestTest {
    @isTest static void testDetermineClosestLocation() {
		WM_SourcingRequest request = new WM_SourcingRequest();
        
        //Setup locations 
        List<Schema.Location> locationsInput = new List<Schema.Location>();
        request.locations = locationsInput;

        Schema.Location miLocation = new Schema.Location();
        miLocation.ExternalReference = 'MI';
        miLocation.LocationType = 'Store';
        miLocation.preferredShipComplete__c = false;
        miLocation.latitude = 42.48895134820102;
        miLocation.longitude = -83.08447553977496;
        miLocation.State__c = 'MI';
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
        
        //Setup delivery location 
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup();
        orderDeliveryGroup.DeliverToState = 'ON';
        orderDeliveryGroup.DeliverToCountry = 'CA';
        orderDeliveryGroup.DeliverToLatitude = 42.285540252126964; 
        orderDeliveryGroup.DeliverToLongitude = -82.94011815689667;
        request.deliveryGroup = orderDeliveryGroup;
        
        Schema.location closestLocation = request.determineClosestLocation(locationsInput, westLocation);
        System.assertEquals(miLocation.Id, closestLocation.Id, 'Result should be MI');
    }
    
    @isTest static void testSetStoredValues() {
		WM_SourcingRequest request = new WM_SourcingRequest();
        
        request.locationsFromOCI = new List<ConnectApi.OCILocationAvailabilityOutputRepresentation>();
        
        //create two line items
        List<OrderItemSummary> orderItems = new List<OrderItemSummary>();
        request.lineItems = orderItems;
        
        OrderItemSummary item1 = new OrderItemSummary();
        item1.QuantityOrdered = 2;
        item1.QuantityAllocated = 1;
        item1.QuantityCanceled = 0;
        item1.Name = 'item1';
        item1.truckFreight__c = true;
        item1.hazardousMaterial__c = true;
        orderItems.add(item1);
        
        OrderItemSummary item2 = new OrderItemSummary();
        item2.QuantityOrdered = 3; 
        item2.QuantityAllocated = 1;
        item2.QuantityCanceled = 0;
        item2.Name = 'item2';
        orderItems.add(item2);
        
        //Setup locations 
        List<Schema.Location> locationsInput = new List<Schema.Location>();
        request.locations = locationsInput;
        request.allLocations = locationsInput;

        Schema.Location miLocation = new Schema.Location();
        miLocation.ExternalReference = 'MI';
        miLocation.LocationType = 'Store';
        miLocation.preferredShipComplete__c = false;
        miLocation.latitude = 42.48895134820102;
        miLocation.longitude = -83.08447553977496;
        miLocation.State__c = 'MI';
        miLocation.isHazmat__c = true;
        miLocation.isTruckFreight__c = true;
        locationsInput.add(miLocation);
        
        Schema.Location prLocation = new Schema.Location();
        prLocation.ExternalReference = 'PR';
        prLocation.LocationType = 'Store';
        prLocation.preferredShipComplete__c = false;
        prLocation.latitude = 42.48895134820102;
        prLocation.longitude = -83.08447553977496;
        prLocation.State__c = 'PR';
        prLocation.isHazmat__c = true;
        prLocation.isTruckFreight__c = true;
        locationsInput.add(prLocation);

        Schema.Location akLocation = new Schema.Location();
        akLocation.ExternalReference = 'AK';
        akLocation.LocationType = 'Store';
        akLocation.preferredShipComplete__c = false;
        akLocation.latitude = 42.48895134820102;
        akLocation.longitude = -83.08447553977496;
        akLocation.State__c = 'AK';
        akLocation.isHazmat__c = true;
        akLocation.isTruckFreight__c = true;
        locationsInput.add(akLocation);

        Schema.Location hiLocation = new Schema.Location();
        hiLocation.ExternalReference = 'HI';
        hiLocation.LocationType = 'Store';
        hiLocation.preferredShipComplete__c = false;
        hiLocation.latitude = 42.48895134820102;
        hiLocation.longitude = -83.08447553977496;
        hiLocation.State__c = 'HI';
        hiLocation.isHazmat__c = true;
        hiLocation.isTruckFreight__c = true;
        locationsInput.add(hiLocation);

        Schema.Location eastLocation = new Schema.Location();
        eastLocation.ExternalReference = 'EAST';
        eastLocation.LocationType = 'Warehouse';
        eastLocation.preferredShipComplete__c = true;
        eastLocation.latitude = 40.78714087590433;
        eastLocation.longitude = -74.07624895032352;
        eastLocation.isHazmat__c = true;
        eastLocation.isTruckFreight__c = true;
        locationsInput.add(eastLocation);
        
        Schema.Location westLocation = new Schema.Location();
        westLocation.ExternalReference = 'WEST';
        westLocation.LocationType = 'Warehouse';
        westLocation.preferredShipComplete__c = true;
        westLocation.latitude = 34.11019398997387;
        westLocation.longitude = -118.20311326724908;
        westLocation.isHazmat__c = false;
        westLocation.isTruckFreight__c = true;
        locationsInput.add(westLocation);
        
        //Setup delivery location 
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup();
        orderDeliveryGroup.DeliverToState = 'ON';
        orderDeliveryGroup.DeliverToCountry = 'CA';
        orderDeliveryGroup.DeliverToLatitude = 42.285540252126964; 
        orderDeliveryGroup.DeliverToLongitude = -82.94011815689667;
        request.deliveryGroup = orderDeliveryGroup;
        
        Map<String,Schema.Location> storeMap = request.getStoreMap();
        Map<String,Schema.Location> primaryMap = request.getPrimaryLocationMap();
        System.assertEquals(1, storeMap.size(), 'Store map should be 1');
        System.assertEquals(1, primaryMap.size(), 'Primary map should be 2');
    }
}