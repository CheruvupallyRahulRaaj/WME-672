@IsTest(SeeAllData=true)
public class WM_BatchForBopisEmailReminderTest {

   public static testmethod void meth1() {
        //to create order summary
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
        Schema.Location locatn= TestDataFactory.createLocation();
        List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId,acc.Id,locatn.Id);
        e_GiftCard__c eGiftCard = TestDataFactory.createGiftCard(orderSumId);
       
        
        /*
        WM_BatchForBopisEmailReminder obj1 = new WM_BatchForBopisEmailReminder();
        DataBase.executeBatch(obj1); 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ScheduleBopisReminderEmail obj = new ScheduleBopisReminderEmail();
        Datetime workTime = System.now().addMinutes(1);
        String sch = '0 * * * *';
        try{
        System.schedule('ScheduleBopisReminderEmail', sch, obj);
        }
        catch(Exception e){
            system.debug('Exception occurred '+e);
        }*/
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WM_BatchForBopisEmailReminder invB = new WM_BatchForBopisEmailReminder();
        Database.executeBatch(invB);

        Test.stopTest();
        }
}