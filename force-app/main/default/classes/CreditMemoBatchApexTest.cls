@isTest(SeeAllData=true)
public class CreditMemoBatchApexTest {
    static testMethod void testMethod1() 
    {
        
       /* Account acc = TestDataFactory.createAccountRecord();
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
        List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId,acc.Id,locatn.Id); */
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
      /*  ScheduleCreditMemoBatch obj = new ScheduleCreditMemoBatch();
              Datetime workTime = System.now().addMinutes(1);
        String sch = '0 0 23 * * ?'; */
        try{
    //    System.schedule('ScheduleCreditMemoBatch', sch, obj);

        CreditMemoBatchApex invB = new CreditMemoBatchApex();
        Database.executeBatch(invB,5);

        }
        catch(Exception e){
            system.debug('Exception occurred '+e);
        }
        
        Test.stopTest();
        
    }
    
}