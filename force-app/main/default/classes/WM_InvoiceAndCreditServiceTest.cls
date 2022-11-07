/**
* @description       : 
* @author            : npendyala@liveareacx.com
* @last modified on  : 
* @last modified by  : schauhan@liveareacx.com
* Modifications Log 
* Ver   Date         Author        Modification
*
**/

// seeAllData is set to true because ConnectApi methods are not supported in data siloed tests.
@IsTest(SeeAllData=true)
public class WM_InvoiceAndCreditServiceTest {
    

    // Creating Test Data 
    // @testSetup cannot be used along with (SeeAllData=true), therefore utilized constructors that can be accessed in different test methods.
    public static Account acc = TestDataFactory.createAccountRecord();
    //public static ObjectWrapper Obj = new ObjectWrapper();
    //public static WM_InvoiceCreditMemoWrapper cmw = new WM_InvoiceCreditMemoWrapper();
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
    public static String orderItemSumId = [select Id,QuantityFulFilled,QuantityAllocated,QuantityReturned,QuantityOrdered  
                                           from OrderItemSummary where OrderSummaryId=:orderSumId limit 1].Id;
    public static Schema.Location locatn= TestDataFactory.createLocation();
    public static List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId,acc.Id,locatn.Id);   
    public static String invId = TestDataFactory.createInvoiceRecord(fulFillmntOrdrIds[0]);
    //public static String credId = TestDataFactory.createCreditMemoRecord(orderSumId);
    public static FulFillmentOrder updatedFulFillmntOrdr =TestDataFactory.updateFulfillmentOrder(fulFillmntOrdrIds[0],invId);
    //public static BackgroundOperation bkOprtn = [SELECT Id, Name, CreatedDate, Status, Error FROM BackgroundOperation where Status='Complete' limit 1];
    //public static BackgroundOperation bkOprtn2 = [SELECT Id, Name, CreatedDate, Status, Error FROM BackgroundOperation where Status='Error' limit 1];
    
    @IsTest
    static void testInvoice() {
              
        Test.startTest();
        //Mocking the response for the REST callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       // WM_JSONGeneratorForInvoice.formtheJSONBody(Obj, cmw);
        InvoiceBatchApex invB = new InvoiceBatchApex();
        Database.executeBatch(invB);
        Test.stopTest();


    }    
    @IsTest
    static void testInvoiceStoreToStore() {
        Test.startTest();
        //Mocking the response for the REST callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WM_InvoiceServiceStoretoStore.callInvoiceService(new List<String> {fulFillmntOrdrIds[0]});
        Test.stopTest();
    }

}