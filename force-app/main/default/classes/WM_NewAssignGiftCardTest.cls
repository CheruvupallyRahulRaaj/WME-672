@isTest(SeeAllData=true)
public class WM_NewAssignGiftCardTest {
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
        e_GiftCard__c gftCrd = TestDataFactory.createGiftCard(orderSumId);
        OrderItemSummary orderItemSumId = [select Id,QuantityFulFilled,QuantityAllocated,QuantityReturned,QuantityOrdered  
                                                 from OrderItemSummary where OrderSummaryId=:orderSumId limit 1];
        Test.startTest();  
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WM_NewAssignGiftCard.assignGiftCards(new List<OrderItemSummary>{orderItemSumId});
        Test.stopTest();
        
    }
}