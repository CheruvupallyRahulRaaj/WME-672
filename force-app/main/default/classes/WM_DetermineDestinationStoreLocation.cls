public class WM_DetermineDestinationStoreLocation {
    @InvocableMethod(label='Determine Destination Stores')
    public static List<Response> determineDestinationStores(List<Request> requestList) {
        List<Response> destinationLocationIds = new List<Response>();
        
        for (Request request : requestList) {
            Response response = new Response();
            destinationLocationIds.add(response);
            Schema.Location location = getDestinationStore(request.deliveryGroup, request.locations);
            if (location != null) {
	            response.deliverToLocationId = location.Id;
            }
        }
        
        return destinationLocationIds;
    }
    
    public static Schema.Location getDestinationStore(OrderDeliveryGroup deliveryGroup, List<Schema.Location> locations) {
        Schema.Location location = null;
       
        Map<String, Schema.Location> storeMapByRef = getStoreRefMap(locations);
        
        if (deliveryGroup.fromStoreId__c != null && storeMapByRef.containsKey(deliveryGroup.fromStoreId__c)) {
            //we are just going to get what we can from this store
            location = storeMapByRef.get(deliveryGroup.fromStoreId__c);
        }
        
        return location;
    }
    
    
    //create map for store phones
    private static Map<String, Schema.Location> getStoreRefMap(List<Schema.Location> locations) {
        Map<String, Schema.Location> storeRefMap = new Map<String, Schema.Location>();
        
        for (Schema.Location thisLocation : locations) {
            if ((thisLocation.LocationType == 'Store' || thisLocation.LocationType == 'HUB' || thisLocation.LocationType == 'Hub') && thisLocation.ExternalReference != null) {
                storeRefMap.put(thisLocation.ExternalReference, thisLocation);
            }
        }
        
        return storeRefMap;
    }
    
    //class for response
    public class Response {
        @InvocableVariable
        public String deliverToLocationId;
    }
    
    //class for request
    public class Request {
        @InvocableVariable
        public OrderDeliveryGroup deliveryGroup;
        @InvocableVariable
        public List<Schema.Location> locations;
    }
    
}