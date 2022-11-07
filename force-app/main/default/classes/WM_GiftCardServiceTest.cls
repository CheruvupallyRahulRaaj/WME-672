@isTest(SeeAllData=true)
public class WM_GiftCardServiceTest {
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
        String orderItemSumId = [select Id,QuantityFulFilled,QuantityAllocated,QuantityReturned,QuantityOrdered  
                                           from OrderItemSummary where OrderSummaryId=:orderSumId limit 1].Id;
        Test.startTest();  
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WM_GiftCardService.giftCardService(new List<Id> {gftCrd.Id});
        List<String> temp = new List<String>{orderItemSumId};
        WM_GiftCard.assignGiftCards(new List<List<String>>{temp});
        //WM_NewAssignGiftCard.assignGiftCardsnew (new List<orderItemSumId>{temp});
       // WM_NewAssignGiftCard.assignGiftCards(orderItemSumId);
        Test.stopTest();
        
    }
}