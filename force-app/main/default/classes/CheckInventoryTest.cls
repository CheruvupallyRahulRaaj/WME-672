@isTest(SeeAllData=true) 
public class CheckInventoryTest {
   @isTest static void testNoResults() {
        List<CheckInventory> requestList = new List<CheckInventory>();
 
        CheckInventory request = new CheckInventory();
        requestList.add(request);
      
        List<ConnectAPI.OCILocationAvailabilityOutputRepresentation> locationsFromOCI = new List<ConnectAPI.OCILocationAvailabilityOutputRepresentation>();
        List<Schema.Location> locationsInput = new List<Schema.Location>();
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup();
        orderDeliveryGroup.DeliverToState = 'MI';
        orderDeliveryGroup.DeliverToCountry = 'US';
        orderDeliveryGroup.DeliverToLatitude = 42.48895134820102;
        orderDeliveryGroup.DeliverToLongitude = -83.08447553977496;
        
 
        
        //OrderDeliveryGroup still null and locations not empty
        Schema.Location testLocation = new Schema.Location();
        testLocation.ExternalReference = '760';
        testLocation.LocationType = 'Warehouse';
        testLocation.preferredShipComplete__c = true;
        locationsInput.add(testLocation);
        
        //No inventory anywhere but everything passed
        ConnectApi.OCILocationAvailabilityOutputRepresentation miInventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
		miInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        miInventory.locationIdentifier = 'MI';
		locationsFromOCI.add(miInventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation miItem1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        miItem1.availableToFulfill = 0;
        miItem1.stockKeepingUnit = 'item1';
        miInventory.inventoryRecords.add(miItem1);
        
        //create line item
        List<OrderItemSummary> orderItems = new List<OrderItemSummary>();
        OrderItemSummary item1 = new OrderItemSummary();
        item1.QuantityOrdered = 2;
        item1.QuantityAllocated = 1;
        item1.QuantityCanceled = 0;
        item1.Name = 'item1';
        orderItems.add(item1);
        

       
    }
    
}