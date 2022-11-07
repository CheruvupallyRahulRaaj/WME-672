public class SeparateDropShipItemsBasedOnVendor {
    @InvocableMethod(label='SeparateDropShipItemsBasedOnVendor')
    public static List<Response> separateDropShipitems(List<List<String>> listOfIds){
        Map<String,List<OrderItemSummary>> mapOfVendorNumbersWithItems = new  Map<String,List<OrderItemSummary>>();
        List<Response> responses = new List<Response>();
        List<OrderItemSummary> ordrItems = [Select Id,vendorNumber__c,OrderSummaryId,Quantity   from OrderItemSummary where Id IN:listOfIds[0]];  
        for(OrderItemSummary oitemSum:ordrItems){
            if(mapOfVendorNumbersWithItems.containsKey(oitemSum.vendorNumber__c)){
                List<OrderItemSummary> tempList = mapOfVendorNumbersWithItems.get(oitemSum.vendorNumber__c);
                tempList.add(oitemSum);
                mapOfVendorNumbersWithItems.put(oitemSum.vendorNumber__c,tempList);
            }
            else{
                mapOfVendorNumbersWithItems.put(oitemSum.vendorNumber__c,new List<OrderItemSummary>{oitemSum});
            }
        }
        List<Schema.Location> locationsForGroup = 
                [select externalreference,locationtype,preferredShipComplete__c,latitude,longitude,phone__c from location where id in 
                 (select locationid from locationgroupassignment where locationgroup.locationgroupname ='WM') order by locationtype];
        String defaultLocationId = locationsForGroup.get(0).Id;
                    List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
           
            for(String k:mapOfVendorNumbersWithItems.keySet()){
                List<ConnectApi.OrderItemSummaryInputRepresentation> oitemList = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
                for(OrderItemSummary oitemSum:mapOfVendorNumbersWithItems.get(k)){
                    ConnectApi.OrderItemSummaryInputRepresentation oitem = new ConnectApi.OrderItemSummaryInputRepresentation();
                    oitem.quantity = oitemSum.Quantity;
                    oitem.orderItemSummaryId =    oitemSum.Id;
                    oitemList.add(oitem);      
                }
                 ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroup = new ConnectApi.FulfillmentGroupInputRepresentation();
                fulfillmentGroup.fulfilledFromLocationId = defaultLocationId;
                fulfillmentGroup.fulfillmentType = 'Drop Ship';
                fulfillmentGroup.orderItemSummaries = oitemList;
                fulfillmentGroups.add(fulfillmentGroup);
                system.debug(' oitemList** '+oitemList);
            }
        Response response = new Response();
        system.debug('newFulfillmentGroups '+fulfillmentGroups);
        response.newFulfillmentGroups = fulfillmentGroups;
        responses.add(response);
        return responses;
    }
    
    public class Response {
        @InvocableVariable
        public List<ConnectApi.FulfillmentGroupInputRepresentation> newFulfillmentGroups;
    }
}