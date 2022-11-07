@isTest(SeeAllData=true)
public class WM_ReturnReceivedServiceTest {
    static testmethod void test1() {
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
        system.debug('order '+od);
        String orderSumId = TestDataFactory.createOrderSummaryRecord(od);
        String orderItemSumId = [select Id,QuantityFulFilled,QuantityAllocated,QuantityReturned,QuantityOrdered  
                                 from OrderItemSummary where OrderSummaryId=:orderSumId limit 1].Id;
        Schema.Location locatn= TestDataFactory.createLocation();
        List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId,acc.Id,locatn.Id);
        String invId = TestDataFactory.createInvoiceRecord(fulFillmntOrdrIds[0]);
        FulFillmentOrder updatedFulFillmntOrdr =TestDataFactory.updateFulfillmentOrder(fulFillmntOrdrIds[0],invId);
        ConnectApi.ChangeItemInputRepresentation input = new ConnectApi.ChangeItemInputRepresentation();
        input.orderItemSummaryId = orderItemSumId;
        input.quantity = 1;
        input.reason = '1';
        input.shippingReductionFlag = false;
        ConnectApi.ChangeInputRepresentation changeInput = new ConnectApi.ChangeInputRepresentation();
        changeInput.changeItems = new List<ConnectApi.ChangeItemInputRepresentation>{input};
            ConnectApi.SubmitReturnOutputRepresentation output =  ConnectApi.OrderSummary.submitReturn(orderSumId,changeInput);             
        String creditMemoId = TestDataFactory.createCreditMemoRecord(output.changeOrderId,orderSumId);
        Test.startTest();  
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WM_ReturnReceivedService.returnReceivedService(new List<Id> {creditMemoId});
        Test.stopTest();
        
    }
}