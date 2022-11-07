@isTest(SeeAllData=true)
public class SOMBatchHistMgdOrdersTest {
    public static Account acc = TestDataFactory.createAccountRecord();
    public static Address__c add = TestDataFactory.createAddress(acc.ID);
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
   /* List < Order > insertOrder = new List< Order >();  
    for ( Integer a = 0; a < 3; a++ ) {  
        
        Order ord = new Order( Name = 'Test Order' + String.valueOf( a ), Status = 'Draft' );  
        insertOrder.add( ord );  
        
    }  
    insert insertOrder;*/
    
    @IsTest
    static void testmgdOrder() {
        Test.startTest();
        //Mocking the response for the REST callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        try{
            SOMBatchHistMgdOrders invB = new SOMBatchHistMgdOrders();
            Database.executeBatch(invB,5);
        }
        catch(Exception e){
            system.debug('Exception occurred '+e);
        }
        Test.stopTest();
    }
    
}