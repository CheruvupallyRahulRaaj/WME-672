@isTest
public class WM_DetermineDestinationStoreLocationTest {
    @isTest static void testDetermineStoreLocation() {
        List<WM_DetermineDestinationStoreLocation.Request> requests = new List<WM_DetermineDestinationStoreLocation.Request>();
        WM_DetermineDestinationStoreLocation.Request request = new WM_DetermineDestinationStoreLocation.Request();
        requests.add(request);
        
        List<Schema.Location> locationsInput = new List<Schema.Location>();
        request.locations = locationsInput;

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
		
        List<WM_DetermineDestinationStoreLocation.Response> responses = WM_DetermineDestinationStoreLocation.determineDestinationStores(requests);
        System.assertEquals(1, responses.size(), 'Results are not 1');
        System.assertEquals(miLocation.Id, responses[0].deliverToLocationId, 'Delivery location id not correct');
    }
}