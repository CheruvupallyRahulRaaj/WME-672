@isTest 
public class LocationsForLocationGroupTest {
    @isTest static void testNoLocationGroups() {
        List<LocationsForLocationGroup.Response> responses = LocationsForLocationGroup.getLocations(new List<SalesChannel>());
        
        System.assertEquals(0, responses.size(), 'No results if no input');
    }
    
    @isTest static void testNoData() {
        List<SalesChannel> salesChannels = new List<SalesChannel>();
        SalesChannel salesChannel = new SalesChannel();
        salesChannel.Type__c = 'Pro';
		salesChannel.LocationGroupName__c = 'LGROUP';
        salesChannels.add(salesChannel);
        
        List<LocationsForLocationGroup.Response> responses = LocationsForLocationGroup.getLocations(salesChannels);
        
        System.assertEquals(1, responses.size(), '1 response');
        System.assertEquals(0, responses[0].locations.size(), '0 results');
        System.assertEquals(null, responses[0].firstLocationId);
    }

    @isTest static void testWithData() {
        //setup test data
        LocationGroup lgroup = new LocationGroup();
        lgroup.LocationGroupName = 'LGROUP';
        insert lgroup;
        
        List<Schema.Location> locationsInput = new List<Schema.Location>();

        Schema.Location miLocation = new Schema.Location();
        miLocation.Name = 'MI';
        miLocation.ExternalReference = 'MI';
        miLocation.LocationType = 'Warehouse';
        miLocation.preferredShipComplete__c = false;
        miLocation.latitude = 42.48895134820102;
        miLocation.longitude = -83.08447553977496;
        locationsInput.add(miLocation);
        
        Schema.Location moLocation = new Schema.Location();
        moLocation.Name = 'MO';
        moLocation.ExternalReference = 'MO';
        moLocation.LocationType = 'Store';
        moLocation.preferredShipComplete__c = false;
        moLocation.IsInternational__c = true;
        moLocation.latitude = 38.726435377678285;
        moLocation.longitude = -90.30526908680135;
        locationsInput.add(moLocation);

        insert locationsInput;
        
        List<LocationGroupAssignment> assignments = new List<LocationGroupAssignment>();
        LocationGroupAssignment miAssignment = new LocationGroupAssignment();
        miAssignment.LocationGroupId = lgroup.Id;
        miAssignment.LocationId = miLocation.Id;
        assignments.add(miAssignment);
        LocationGroupAssignment moAssignment = new LocationGroupAssignment();
        moAssignment.LocationGroupId = lgroup.Id;
        moAssignment.LocationId = moLocation.Id;
        assignments.add(moAssignment);
        
        insert assignments;
        
        //lookup locations based on group
        List<SalesChannel> salesChannels = new List<SalesChannel>();
        SalesChannel salesChannel = new SalesChannel();
        salesChannel.Type__c = 'Retail';
		salesChannel.LocationGroupName__c = 'LGROUP';
        salesChannels.add(salesChannel);
        
        List<LocationsForLocationGroup.Response> responses = LocationsForLocationGroup.getLocations(salesChannels);
        
        System.assertEquals(1, responses.size(), '1 response');
        System.assertEquals(2, responses[0].locations.size(), '2 results');
        System.assertEquals(1, responses[0].internationalLocations.size(), '1 results');
        System.assertEquals(2, responses[0].allLocations.size(), '2 results');
    }
}