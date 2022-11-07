@isTest
public class InvoiceBatchApexTest {
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
        List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId,acc.Id,locatn.Id);
          String invId = TestDataFactory.createInvoiceRecord(fulFillmntOrdrIds[0]);
    FulFillmentOrder updatedFulFillmntOrdr =TestDataFactory.updateFulfillmentOrder(fulFillmntOrdrIds[0],invId);*/
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        /*ScheduleInvoiceBatch obj = new ScheduleInvoiceBatch();
              Datetime workTime = System.now().addMinutes(1);
        String sch = '0 0 23 * * ?';*/
        try{
       // System.schedule('ScheduleInvoiceBatch', sch, obj);
       InvoiceBatchApex obj = new InvoiceBatchApex();
       Database.executeBatch(obj,5);
        }
        catch(Exception e){
            system.debug('Exception occurred '+e);
        }
        
        Test.stopTest();
        
    }
}