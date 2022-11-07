@isTest
public class CheckATFFromInventoryTest {
@isTest static void testmeth1() {

        List<CheckATFFromInventory.WM_ATFLocationsRequest> requestList = new List<CheckATFFromInventory.WM_ATFLocationsRequest>();
        CheckATFFromInventory.WM_ATFLocationsRequest request = new CheckATFFromInventory.WM_ATFLocationsRequest();
        requestList.add(request);
    
        List<OrderItemSummary> orderItems = new List<OrderItemSummary>();
        request.orderItemSummaries = orderItems;
        
        
        OrderItemSummary item1 = new OrderItemSummary();
        item1.QuantityOrdered = 2;
        item1.QuantityAllocated = 1;
        item1.QuantityCanceled = 0;
        item1.Name = 'item1';
        item1.sku_status__c='D';
        item1.backorderable__c=false;
        item1.Quantity=1;
        orderItems.add(item1);
        
        String SKU=item1.stockkeepingunit;

        request.currectSKUInLoop=SKU;
        

        List<ConnectApi.OCILocationAvailabilityOutputRepresentation> ociLocations = 
        new List<ConnectApi.OCILocationAvailabilityOutputRepresentation>();
        request.locations = ociLocations;
        
        ConnectApi.OCILocationAvailabilityOutputRepresentation miInventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        miInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        miInventory.locationIdentifier = 'MI';
        ociLocations.add(miInventory);    
           
        ConnectApi.OCIInventoryRecordOutputRepresentation miItem1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        miItem1.availableToFulfill = 0;
        miItem1.stockKeepingUnit = 'item1';
        miInventory.inventoryRecords.add(miItem1);
       
        
        List<CheckATFFromInventory.Response> responses = CheckATFFromInventory.checkATFFromGetInventoryOutput(requestList);
        

}
@isTest static void testmeth2() {
        List<CheckATFFromInventory.WM_ATFLocationsRequest> requestList = new List<CheckATFFromInventory.WM_ATFLocationsRequest>();
        CheckATFFromInventory.WM_ATFLocationsRequest request = new CheckATFFromInventory.WM_ATFLocationsRequest();
        requestList.add(request);
    
        List<OrderItemSummary> orderItems = new List<OrderItemSummary>();
        request.orderItemSummaries = orderItems;
        
        
        OrderItemSummary item1 = new OrderItemSummary();
        item1.QuantityOrdered = 2;
        item1.QuantityAllocated = 1;
        item1.QuantityCanceled = 0;
        item1.Name = 'item1';
        item1.sku_status__c='D';
        item1.backorderable__c=false;
        item1.Quantity=1;
        orderItems.add(item1);
        
        String SKU=item1.stockkeepingunit;

        request.currectSKUInLoop=SKU;
        

     List<ConnectApi.OCILocationAvailabilityOutputRepresentation> ociLocations = 
            new List<ConnectApi.OCILocationAvailabilityOutputRepresentation>();
        request.locations = ociLocations;
        
        ConnectApi.OCILocationAvailabilityOutputRepresentation miInventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        miInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        miInventory.locationIdentifier = 'MI';
        ociLocations.add(miInventory);    
    

        ConnectApi.OCIInventoryRecordOutputRepresentation moItem1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        moItem1.availableToFulfill = 1;
        moItem1.stockKeepingUnit = 'item1';
        miInventory.inventoryRecords.add(moItem1);

        
         List<CheckATFFromInventory.Response> responses = CheckATFFromInventory.checkATFFromGetInventoryOutput(requestList);
        

}
@isTest static void testmeth3() {
        List<CheckATFFromInventory.WM_ATFLocationsRequest> requestList = new List<CheckATFFromInventory.WM_ATFLocationsRequest>();
        CheckATFFromInventory.WM_ATFLocationsRequest request = new CheckATFFromInventory.WM_ATFLocationsRequest();
        requestList.add(request);
    
        List<OrderItemSummary> orderItems = new List<OrderItemSummary>();
        request.orderItemSummaries = orderItems;
        
        
        OrderItemSummary item1 = new OrderItemSummary();
        item1.QuantityOrdered = 2;
        item1.QuantityAllocated = 1;
        item1.QuantityCanceled = 0;
        item1.Name = 'item1';
        item1.Quantity=1;
        orderItems.add(item1);
        
        String SKU=item1.stockkeepingunit;

        request.currectSKUInLoop=SKU;


     List<ConnectApi.OCILocationAvailabilityOutputRepresentation> ociLocations = 
            new List<ConnectApi.OCILocationAvailabilityOutputRepresentation>();
        request.locations = ociLocations;  
    
        ConnectApi.OCILocationAvailabilityOutputRepresentation moInventory = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        moInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        moInventory.locationIdentifier = 'MO';
        ociLocations.add(moInventory);

        //set no stores have available inventory, should still be EAST

        ConnectApi.OCIInventoryRecordOutputRepresentation moItem1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        moItem1.availableToFulfill = 1;
        moItem1.stockKeepingUnit = 'item1';
        moInventory.inventoryRecords.add(moItem1);
        
         List<CheckATFFromInventory.Response> responses = CheckATFFromInventory.checkATFFromGetInventoryOutput(requestList);
        

}
@isTest static void testmeth4() {
        List<WM_AssignNonZeroSKUs.WM_AssignRequest> requestList = new List<WM_AssignNonZeroSKUs.WM_AssignRequest>();
        WM_AssignNonZeroSKUs.WM_AssignRequest request = new WM_AssignNonZeroSKUs.WM_AssignRequest();
        requestList.add(request);
        
        List<String> cancelList = new List<String>();
    
        List<OrderItemSummary> orderItems = new List<OrderItemSummary>();
        request.orderItemSummaries = orderItems;

        
        
        OrderItemSummary item1 = new OrderItemSummary();
        item1.QuantityOrdered = 2;
        item1.QuantityAllocated = 1;
        item1.QuantityCanceled = 0;
        item1.Name = 'item1';
        item1.Quantity=1;
        orderItems.add(item1);
        
        OrderItemSummary item2 = new OrderItemSummary();
        item2.QuantityOrdered = 2;
        item2.QuantityAllocated = 1;
        item2.QuantityCanceled = 0;
        item2.Name = 'item2';
        item2.Quantity=1;
        orderItems.add(item2);
        
        OrderItemSummary item3 = new OrderItemSummary();
        item3.QuantityOrdered = 2;
        item3.QuantityAllocated = 1;
        item3.QuantityCanceled = 0;
        item3.Name = 'item3';
        item3.Quantity=1;
        orderItems.add(item3);
        
        OrderItemSummary item4 = new OrderItemSummary();
        item4.QuantityOrdered = 2;
        item4.QuantityAllocated = 1;
        item4.QuantityCanceled = 0;
        item4.Name = 'item4';
        item4.Quantity=1;
        orderItems.add(item4);
        
        String SKUItem1= item1.stockkeepingunit;
        String SKUItem2= item2.stockkeepingunit;
        
        cancelList.add(SKUItem1);
        cancelList.add(SKUItem2);
        
        request.cancelSKUList=cancelList;

        List<WM_AssignNonZeroSKUs.Response> responses = WM_AssignNonZeroSKUs.checkifSKUExists(requestList);
        

}
}