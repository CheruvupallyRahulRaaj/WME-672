public  class LocationsForLocationGroup {
    @InvocableMethod(label='Get locations for location group')
    public static List<Response> getLocations(List<SalesChannel> salesChannels) {
        List<Response> responses = new List<Response>();
        //"System.debug('Hello');
        //list through all salesChannels (typically one)
        for (SalesChannel salesChannel : salesChannels) {
            String locationGroup = salesChannel.locationGroupName__c;
            List<Schema.Location> locationsForGroup;
            if (salesChannel.Type__c == 'Pro') {
                locationsForGroup = 
                    [select Priority,externalreference,locationtype,preferredShipComplete__c,latitude,longitude,phone__c,IsInternational__c,State__c,isHazmat__c,isTruckFreight__c 
                    from location where ReachedMaximumPro__c = FALSE AND (id in 
                    (select locationid from locationgroupassignment where locationgroup.locationgroupname = :locationGroup)) order by locationtype];
            } else {
                locationsForGroup = 
                    [select Priority,externalreference,locationtype,preferredShipComplete__c,latitude,longitude,phone__c,IsInternational__c,State__c,isHazmat__c,isTruckFreight__c 
                    from location where ReachedMaximumRetail__c = FALSE AND (id in 
                    (select locationid from locationgroupassignment where locationgroup.locationgroupname = :locationGroup)) order by locationtype];
            }
            
            List<Schema.Location> internationalLocations = new List<Schema.Location>();
            
            for (Schema.Location fulfillmentLocation : locationsForGroup) {
                if (fulfillmentLocation.IsInternational__c) {
                    internationalLocations.add(fulfillmentLocation);
                }
            }
            
            Response response = new Response();
            response.locations = locationsForGroup;
            response.internationalLocations = internationalLocations;
            response.allLocations = [select Priority,externalreference,locationtype,preferredShipComplete__c,latitude,longitude,phone__c,IsInternational__c,State__c,isHazmat__c,isTruckFreight__c 
                    from location where (id in 
                    (select locationid from locationgroupassignment where locationgroup.locationgroupname = :locationGroup)) order by locationtype];
            if (locationsForGroup.size() > 0) {
                response.firstLocationId = locationsForGroup.get(0).Id;
            }
            responses.add(response);
        }
        
        return responses;
    }
    
        
    public class Response {
        @InvocableVariable
        public List<Schema.Location> allLocations;
        @InvocableVariable
        public List<Schema.Location> locations;
        @InvocableVariable
        public List<Schema.Location> internationalLocations;
        @InvocableVariable
        public String firstLocationId;
    }
}