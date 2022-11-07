@isTest(SeeAllData=true)
public class WM_ShipmentLineInfoTest {
    @isTest public static void testProcessShipmentLineInfo() {
        
        Account acc = TestDataFactory.createAccountRecord();
        SalesChannel sChannl = TestDataFactory.createSalesChannel();
        Pricebook2 pricBook = TestDataFactory.createPricebook();
        Order ordr = TestDataFactory.createOrderRecord(pricBook, acc, sChannl);
        Product2 prd = TestDataFactory.createProduct2Record();
        PricebookEntry pbEntry = TestDataFactory.createPricebookEntry(prd,pricBook);
        PaymentGateway payGateway = TestDataFactory.createPaymentGatewayRecord();
        CardPaymentMethod cpm = TestDataFactory.createCardPaymentMethodRecord(payGateway,acc);
        OrderDeliveryMethod odMethod = TestDataFactory.createOrderDeliveryMethod();
        OrderDeliveryGroup odGrp = TestDataFactory.createOrderDeliveryGroupRecord(odMethod,ordr);
        OrderAdjustmentGroup ordAdjGrp = TestDataFactory.createOrderAdjustmentGroup(ordr);
        PaymentGroup payGrp = TestDataFactory.createPaymentGroup(ordr);
        PaymentAuthorization payAuth =  TestDataFactory.createPaymentAuthorizationRecord(payGateway,cpm,acc,payGrp);
        OrderItem ordItem =  TestDataFactory.createOrderItemRecord(prd,odGrp,ordr,pbEntry);
        OrderItemAdjustmentLineItem ordItmAdjLineItem = TestDataFactory.createOrderItemAdjustmentLineItem(ordItem,ordAdjGrp);
        OrderItemTaxLineItem ordItmTaxLineItm = TestDataFactory.createOrderItemTaxLineItem(ordItem,ordItmAdjLineItem);
        Order od = TestDataFactory.updateOrderStatus(ordr);
        String orderSumId = TestDataFactory.createOrderSummaryRecord(od);
        Schema.Location locatn= TestDataFactory.createLocation();
        List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId,acc.Id,locatn.Id);
        
        //test no requests
        List<WM_ShipmentLineInfo.Request> requests = new List<WM_ShipmentLineInfo.Request>();
        
        List<WM_ShipmentLineInfo.Response> results = WM_ShipmentLineInfo.processShipmentLineInfo(requests);
        System.assertEquals(0, results.size(), 'Should be no results');
        
        WM_ShipmentLineInfo.Request request = new WM_ShipmentLineInfo.Request();
        requests.add(request);
        
        //test no lines
        request.fulfillmentOrderItems = new List<ConnectApi.FulfillmentOrderLineItemInputRepresentation>();
        request.potentialFulfillmentReservations = new List<ConnectApi.OCIFulfillReservationSingleInputRepresentation>();
        results = WM_ShipmentLineInfo.processShipmentLineInfo(requests);
        System.assertEquals(1, results.size(), 'Should be 1 result');
        System.assertEquals(null, results[0].fulfillmentOrderItemsToCancel, 'Should be a null list');
        
        //test bad JSON requests
        request.lineInfoResult = 'blah{';
        ConnectApi.FulfillmentOrderLineItemInputRepresentation lineItemRep1 = new ConnectApi.FulfillmentOrderLineItemInputRepresentation();
        lineItemRep1.fulfillmentOrderLineItemId = 'item1';
        lineItemRep1.quantity = 2;
        request.fulfillmentOrderItems.add(lineItemRep1);
        
        ConnectApi.FulfillmentOrderLineItemInputRepresentation lineItemRep2 = new ConnectApi.FulfillmentOrderLineItemInputRepresentation();
        lineItemRep2.fulfillmentOrderLineItemId = 'item2';
        lineItemRep2.quantity = 4;
        request.fulfillmentOrderItems.add(lineItemRep2);
        
        ConnectApi.OCIFulfillReservationSingleInputRepresentation reservation1 = new ConnectApi.OCIFulfillReservationSingleInputRepresentation();
        reservation1.quantity = 2;
        reservation1.stockKeepingUnit = 'item1';
        request.potentialFulfillmentReservations.add(reservation1);
        
        ConnectApi.OCIFulfillReservationSingleInputRepresentation reservation2 = new ConnectApi.OCIFulfillReservationSingleInputRepresentation();
        reservation1.quantity = 4;
        reservation1.stockKeepingUnit = 'item2';
        request.potentialFulfillmentReservations.add(reservation2);
        
        results = WM_ShipmentLineInfo.processShipmentLineInfo(requests);
        System.assertEquals(1, results.size(), 'Should be 1 result');
        System.assertEquals(null, results[0].fulfillmentOrderItemsToCancel, 'Should be a null list');
        
        //good JSON but outside of range
        request.lineInfoResult = '{"LineInfo":[{"carton_line_nbr":123,"pick_line_nbr":nan,"qty_shipped":1}]}';
        results = WM_ShipmentLineInfo.processShipmentLineInfo(requests);
        System.assertEquals(1, results.size(), 'Should be 1 result');
        System.assertEquals(null, results[0].fulfillmentOrderItemsToCancel, 'Should be a null list');
        
        //good JSON with multiple lines        
        request.lineInfoResult = '{"LineInfo":[{"carton_line_nbr":123,"pick_line_nbr":1,"qty_shipped":1},{"carton_line_nbr":123,"pick_line_nbr":2,"qty_shipped":1}]}';
        request.locationExternalReference = '860';
        List<FulfillmentOrderLineItem> fulfillmnentOrderLineItems = [Select Id from FulfillmentOrderLineItem where FulfillmentOrderId In:fulFillmntOrdrIds ];
        List<String> fulfillmentOrderLineItemIds = new List<String>();
        for(FulfillmentOrderLineItem fOLineItem:fulfillmnentOrderLineItems){
            fulfillmentOrderLineItemIds.add(fOLineItem.Id);
        }
        request.fulfillmentOrderLineItemIds = fulfillmentOrderLineItemIds;
            
            results = WM_ShipmentLineInfo.processShipmentLineInfo(requests);
        System.assertEquals(1, results.size(), 'Should be 1 result');
        System.assertEquals(0, results[0].fulfillmentOrderItemsToCancel.size(), '0 Should be the same number in list');
        System.assertEquals(1, results[0].remainingFulfillmentReservations.size(), 'Should be the same number in list');
        System.assertEquals(1, results[0].remainingFulfillmentReservations[0].quantity, 'item 1 should have 1');
        
        //good JSON with line removed
        lineItemRep1.quantity = 2;
        lineItemRep2.quantity = 4;
        request.lineInfoResult = '{"LineInfo":[{"carton_line_nbr":123,"pick_line_nbr":1,"qty_shipped":2},{"carton_line_nbr":123,"pick_line_nbr":2,"qty_shipped":1}]}';
        results = WM_ShipmentLineInfo.processShipmentLineInfo(requests);
        System.assertEquals(1, results.size(), 'Should be 1 result');
        System.assertEquals(0, results[0].fulfillmentOrderItemsToCancel.size(), 'Should be 2 item');
        System.assertEquals(1, results[0].remainingFulfillmentReservations.size(), 'Should be 1 item');
        System.assertEquals(2, results[0].remainingFulfillmentReservations[0].quantity, 'item 1 should have 2');
        
        //makes sure empty JSON cancels all items
        lineItemRep1.quantity = 2;
        lineItemRep2.quantity = 4;
        request.lineInfoResult = '{}';
        results = WM_ShipmentLineInfo.processShipmentLineInfo(requests);
        System.assertEquals(1, results.size(), 'Should be 1 result');
        System.assertEquals(2, results[0].fulfillmentOrderItemsToCancel.size(), 'Should be the same number in list');
        System.assertEquals(2, results[0].fulfillmentOrderItemsToCancel[0].quantity, 'item 1 should have 2');
        System.assertEquals(4, results[0].fulfillmentOrderItemsToCancel[1].quantity, 'item 2 should have 4');
        System.assertEquals(0, results[0].remainingFulfillmentReservations.size(), 'Should be an empty list');
    }
}