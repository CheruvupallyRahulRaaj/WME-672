public class WM_FilteredLocations {
    @InvocableMethod(label = 'Get Filtered Locations')
    public static List<Response>  getFilteredLocations(List<Request> request){
        System.debug('Request ==>'+ request[0].allLocations.size());
        System.debug('Request ==>'+ request[0].orderDeliveryGroupSummaryId);
        List<Schema.Location> finalLocationsList = new List<Schema.Location>();
        Set<Id> setOfLocationId = new Set<Id>();
        List<Response> filteredLocations = new List<Response>();
        String orderdeliveryGrpId = request[0].orderDeliveryGroupSummaryId;
        List<FulfillmentOrder> fo = [SELECT id, FulfilledFromLocationId FROM FulFillmentOrder WHERE Order_Delivery_Group_Summary__c =: orderdeliveryGrpId];
        
        if(fo.size() == 0) {
            Response res = new Response();
            res.locations = request[0].allLocations;
            filteredLocations.add(res);
            System.debug('filteredLocations ==>'+ filteredLocations.size());
            return filteredLocations;
        }
        for(FulfillmentOrder f : fo){
        	setOfLocationId.add(f.FulfilledFromLocationId);
        }
        
        for(Schema.Location loc : request[0].allLocations){
            if(!setOfLocationId.contains(loc.Id)){
                finalLocationsList.add(loc);
            }
        }
        Response res = new Response();
        res.locations = finalLocationsList;
        filteredLocations.add(res);
        System.debug('filteredLocations ==>'+ filteredLocations.size());
        return filteredLocations;
        /*List<FulfillmentOrder> fulfillmentOrderList = new List<FulfillmentOrder>();
        List<Schema.Location> allLocations = new List<Schema.Location>();
        List<Response> filteredLocations = new List<Response>();
        List<List<Response>> filteredLocationsToBeReturned = new List<List<Response>>();
        List<Schema.Location> finalLocationsList = new List<Schema.Location>();
        Set<FulfillmentOrder> fulfilledLocations = new Set<FulfillmentOrder>();
        for(Request req : request){
            fulfillmentOrderList = req.fulfillmentOrder;
            allLocations = req.allLocations;
        }
        System.debug('fulfillmentOrderList ==>'+ fulfillmentOrderList);
        System.debug('allLocations ==>'+ allLocations);
        for(FulfillmentOrder f : fulfillmentOrderList){
            fulfilledLocations.add(f);
        }
        System.debug('fulfilledLocations ==>'+ fulfilledLocations);
        for(Schema.Location loc : allLocations){
            for(FulfillmentOrder ord : fulfilledLocations){
                if(ord.FulfilledFromLocationId != loc.Id){
                    finalLocationsList.add(loc);
                }
            }
        }
        
        Response res = new Response();
        res.locations = finalLocationsList;
        filteredLocations.add(res);
        System.debug('filteredLocations ==>'+ filteredLocations.size());
        return filteredLocations;
        //filteredLocationsToBeReturned.add(filteredLocations);
        //return filteredLocationsToBeReturned;*/
        
    }

    public class Request{
        @InvocableVariable(label='List of all locations' required=true)
        @AuraEnabled public List<Schema.Location> allLocations; 

        @InvocableVariable(label='List of Fulfillment order' required=false)
        @AuraEnabled public List<FulfillmentOrder> fulfillmentOrder;
        
		@InvocableVariable(label='Order Delivery Group Summary Id' required=true)
        public Id orderDeliveryGroupSummaryId;        
    }

    public class Response{
        @InvocableVariable
        @AuraEnabled public List<Schema.Location> locations;
    }
}