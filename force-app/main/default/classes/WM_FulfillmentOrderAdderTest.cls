@isTest 
public class WM_FulfillmentOrderAdderTest {
    @isTest static void testAddItemsToFirstFulfillmentGroup() {
        List<ConnectApi.FulfillmentGroupInputRepresentation> fgList = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
        fgList.add(new ConnectApi.FulfillmentGroupInputRepresentation());
        fgList.add(new ConnectApi.FulfillmentGroupInputRepresentation());
        fgList[0].orderItemSummaries = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
        fgList[0].orderItemSummaries.add(new ConnectApi.OrderItemSummaryInputRepresentation());
        fgList[0].orderItemSummaries[0].quantity = 1;
        fgList[0].orderItemSummaries[0].orderItemSummaryId = 'Item1';
        fgList[1].orderItemSummaries = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
        fgList[1].orderItemSummaries.add(new ConnectApi.OrderItemSummaryInputRepresentation());
        fgList[1].orderItemSummaries[0].quantity = 1;
        fgList[1].orderItemSummaries[0].orderItemSummaryId = 'Item2';
        
        List<ConnectApi.OrderItemSummaryInputRepresentation> shippingItems = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
        shippingItems.add(new ConnectApi.OrderItemSummaryInputRepresentation());
        shippingItems[0].orderItemSummaryId = 'Shipping1';
        shippingItems[0].quantity = 2;
        WM_FulfillmentOrderAdder.Request request = new WM_FulfillmentOrderAdder.Request();
        request.fulfillmentGroups = fgList;
        request.lineItems = shippingItems;
        List<WM_FulfillmentOrderAdder.Request> requests = new List<WM_FulfillmentOrderAdder.Request>();
        requests.add(request);
        
        List<WM_FulfillmentOrderAdder.Response> responses = WM_FulfillmentOrderAdder.addItemsToFirstFulfillmentGroup(requests);
        System.assertEquals(1, responses.size(), 'Should be 1 response');
        System.assertEquals(2, responses[0].fulfillmentGroups.size(),'Should be 2 fulfillment groups');
        System.assertEquals(2, responses[0].fulfillmentGroups[0].orderItemSummaries.size(), 'Should have added shipments to first FG');
        System.assertEquals(2, fgList[0].orderItemSummaries.size(), 'Should be same FG');
        System.assertEquals('Shipping1', responses[0].fulfillmentGroups[0].orderItemSummaries[1].orderItemSummaryId, 'Should have added shipments to first FG: id');
        System.assertEquals(2, responses[0].fulfillmentGroups[0].orderItemSummaries[1].quantity, 'Should have added shipments to first FG: quantity');
    }
}