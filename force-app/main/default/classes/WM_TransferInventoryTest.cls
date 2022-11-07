@isTest
public class WM_TransferInventoryTest {
    @IsTest(SeeAllData=true)
     public static void testCreateTransfersForFulfillmentGroups() {
        List<WM_TransferInventory.Request> requests = new List<WM_TransferInventory.Request>();
        WM_TransferInventory.createTransfersForFulfillmentGroups(requests);
        
        WM_TransferInventory.Request request = new WM_TransferInventory.Request();
        requests.add(request);
        WM_TransferInventory.createTransfersForFulfillmentGroups(requests);
        
        request.locationGroupExternalReference = 'WM';
        //create two line items
        List<OrderItemSummary> orderItems = new List<OrderItemSummary>();
        request.lineItems = orderItems;
        
        OrderItemSummary item1 = new OrderItemSummary();
        item1.QuantityOrdered = 2;
        item1.Name = 'Item1';
        orderItems.add(item1);
        
        OrderItemSummary item2 = new OrderItemSummary();
        item2.QuantityOrdered = 3;
        item2.Name = 'Item2';
        orderItems.add(item2);
        
        //create 2 fulfillment order representations
        List<Schema.Location> locations = new List<Schema.Location>();
        request.locations = locations;
        Schema.Location miLocation = new Schema.Location();
        miLocation.ExternalReference = 'MI';
        miLocation.Name = 'MI Store';
        miLocation.LocationType = 'Store';
        miLocation.preferredShipComplete__c = false;
        miLocation.latitude = 42.48895134820102;
        miLocation.longitude = -83.08447553977496;
        insert miLocation;
        locations.add(miLocation);
        
        Schema.Location moLocation = new Schema.Location();
        moLocation.ExternalReference = 'MO';
        moLocation.LocationType = 'Store';
        moLocation.Name = 'MO Store';
        moLocation.preferredShipComplete__c = false;
        moLocation.latitude = 38.726435377678285;
        moLocation.longitude = -90.30526908680135;
        insert moLocation;
        locations.add(moLocation);

        List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
        request.fulfillmentGroups = fulfillmentGroups;
        
        ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroup1 = new ConnectApi.FulfillmentGroupInputRepresentation();
        fulfillmentGroups.add(fulfillmentGroup1);
        fulfillmentGroup1.fulfilledFromLocationId = miLocation.Id;
        fulfillmentGroup1.fulfillmentType = 'Store/Hub to Home';
        fulfillmentGroup1.orderItemSummaries = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
        ConnectApi.OrderItemSummaryInputRepresentation group1Item1 = new ConnectApi.OrderItemSummaryInputRepresentation();
 		group1Item1.quantity = 2;
        group1Item1.orderItemSummaryId = 'Item1';
        fulfillmentGroup1.orderItemSummaries.add(group1Item1);
        ConnectApi.OrderItemSummaryInputRepresentation group1Item2 = new ConnectApi.OrderItemSummaryInputRepresentation();
 		group1Item2.quantity = 2;
        group1Item2.orderItemSummaryId = 'Item2';
        fulfillmentGroup1.orderItemSummaries.add(group1Item2);
        
        ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroup2 = new ConnectApi.FulfillmentGroupInputRepresentation();
        fulfillmentGroups.add(fulfillmentGroup2);
        fulfillmentGroup2.fulfilledFromLocationId = moLocation.Id;
        fulfillmentGroup2.fulfillmentType = 'Store/Hub to Home';
        fulfillmentGroup2.orderItemSummaries = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
        ConnectApi.OrderItemSummaryInputRepresentation group2Item2 = new ConnectApi.OrderItemSummaryInputRepresentation();
 		group2Item2.quantity = 1;
        group2Item2.orderItemSummaryId = 'Item2';
        fulfillmentGroup2.orderItemSummaries.add(group2Item2);
        
        //Should be valid result with 3 transfer requests
         List<WM_TransferInventory.Response> responses = WM_TransferInventory.createTransfersForFulfillmentGroups(requests);
       System.assertEquals(1,responses.size(), 'Should be 1 response');
        System.assertEquals(3,responses[0].transferReservationInput.transferRecords.size(), 'Should be 3 transfer records');
        System.assertEquals(miLocation.ExternalReference, responses[0].transferReservationInput.transferRecords[0].toLocationIdentifier);
        System.assertEquals('WM', responses[0].transferReservationInput.transferRecords[0].fromLocationGroupIdentifier);
        System.assertEquals(2, responses[0].transferReservationInput.transferRecords[0].quantity);
        System.assertEquals(miLocation.ExternalReference, responses[0].transferReservationInput.transferRecords[1].toLocationIdentifier);
        System.assertEquals('WM', responses[0].transferReservationInput.transferRecords[1].fromLocationGroupIdentifier);
        System.assertEquals(2, responses[0].transferReservationInput.transferRecords[1].quantity);
        System.assertEquals(moLocation.ExternalReference, responses[0].transferReservationInput.transferRecords[2].toLocationIdentifier);
        System.assertEquals('WM', responses[0].transferReservationInput.transferRecords[2].fromLocationGroupIdentifier);
        System.assertEquals(1, responses[0].transferReservationInput.transferRecords[2].quantity);
    }
}