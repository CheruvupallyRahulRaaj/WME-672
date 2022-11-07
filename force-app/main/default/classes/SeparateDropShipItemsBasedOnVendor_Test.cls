@isTest(SeeAllData=true) 
public class SeparateDropShipItemsBasedOnVendor_Test {
    
   		public static Account acc = TestDataFactory.createAccountRecord();
        public static SalesChannel sChannl = TestDataFactory.createSalesChannel();
        public static Pricebook2 pricBook = TestDataFactory.createPricebook();
        public static Order ordr = TestDataFactory.createOrderRecord(pricBook, acc, sChannl);
        public static Product2 prd = TestDataFactory.createProduct2Record();
        public static PricebookEntry pbEntry = TestDataFactory.createPricebookEntry(prd,pricBook);
        public static PaymentGateway payGateway = TestDataFactory.createPaymentGatewayRecord();
        public static CardPaymentMethod cpm = TestDataFactory.createCardPaymentMethodRecord(payGateway,acc);
        public static OrderDeliveryMethod odMethod = TestDataFactory.createOrderDeliveryMethod();
        public static OrderDeliveryGroup odGrp = TestDataFactory.createOrderDeliveryGroupRecord(odMethod,ordr);
        public static OrderAdjustmentGroup ordAdjGrp = TestDataFactory.createOrderAdjustmentGroup(ordr);
        public static PaymentGroup payGrp = TestDataFactory.createPaymentGroup(ordr);
        public static PaymentAuthorization payAuth =  TestDataFactory.createPaymentAuthorizationRecord(payGateway,cpm,acc,payGrp);
        public static OrderItem ordItem =  TestDataFactory.createOrderItemRecord(prd,odGrp,ordr,pbEntry);
        public static OrderItemAdjustmentLineItem ordItmAdjLineItem = TestDataFactory.createOrderItemAdjustmentLineItem(ordItem,ordAdjGrp);
        public static OrderItemTaxLineItem ordItmTaxLineItm = TestDataFactory.createOrderItemTaxLineItem(ordItem,ordItmAdjLineItem);
        public static Order od = TestDataFactory.updateOrderStatus(ordr);
        public static String orderSumId = TestDataFactory.createOrderSummaryRecord(od);
        public static Schema.Location locatn= TestDataFactory.createLocation();
        public static List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId,acc.Id,locatn.Id);
              
        @IsTest
    	static void test1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<OrderItemSummary> ordrItems = [Select Id,vendorNumber__c,OrderSummaryId,Quantity   from OrderItemSummary where OrderSummaryId =:orderSumId];
            List<string> orderitemsumid = new List<string>();
            for(OrderItemSummary ordrsumitem:ordrItems){
                orderitemsumid.add(ordrsumitem.Id);
            }
       SeparateDropShipItemsBasedOnVendor.separateDropShipitems(new List<List<String>>{orderitemsumId});
        Test.stopTest();
        }
     

}