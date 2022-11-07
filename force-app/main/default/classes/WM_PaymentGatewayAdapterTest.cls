/**
* @description       : 
* @author            : schauhan@liveareacx.com
* @group             : 
* @last modified on  : 01-13-2021
* @last modified by  : schauhan@liveareacx.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   01-13-2021   schauhan@liveareacx.com   Initial Version
**/
@isTest(SeeAllData=true)
private class WM_PaymentGatewayAdapterTest {
    
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
    public static String orderPaySumId = [Select Id from OrderPaymentSummary where OrderSummaryId=:orderSumId limit 1].Id;
    public static PaymentAuthorization payAuth2 = TestDataFactory.updatePaymentAuthorization(payAuth,orderPaySumId);
    public static Payment paymnt = TestDataFactory.createPaymentRecord(cpm.Id,payAuth.Id,orderPaySumId);
    
    public static Schema.Location locatn= TestDataFactory.createLocation();
    public static String orderItemSumId = [select Id,QuantityFulFilled,QuantityAllocated,QuantityReturned,QuantityOrdered  
                                           from OrderItemSummary where OrderSummaryId=:orderSumId limit 1].Id;
    public static List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId,acc.Id,locatn.Id);   
    public static String invId = TestDataFactory.createInvoiceRecord(fulFillmntOrdrIds[0]);
    public static FulFillmentOrder updatedFulFillmntOrdr =TestDataFactory.updateFulfillmentOrder(fulFillmntOrdrIds[0],invId);
    
    @isTest
    static void testAuthorization() {
        commercepayments.AuthorizationRequest request = new commercepayments.AuthorizationRequest(100);
        request.accountId =  acc.Id;
        commercepayments.AuthApiPaymentMethodRequest paymentReq = new commercepayments.AuthApiPaymentMethodRequest();
        request.paymentMethod = paymentReq;
        Test.startTest();
        commercepayments.PaymentGatewayContext context = new commercepayments.PaymentGatewayContext((commercepayments.PaymentGatewayRequest) request, commercepayments.RequestType.Authorize);
        SalesforceAdapter adapter = new SalesforceAdapter();
        Test.setMock(HttpCalloutMock.class, new AurusMockHttpResponse());
        commercepayments.GatewayResponse response = adapter.processRequest(context);
        System.assertNotEquals(null, response);
        Test.stopTest();
    }
    
    @isTest
    static void testProcessRequestCapture() {
        commercepayments.CaptureRequest request = new commercepayments.CaptureRequest(100, payAuth2.Id);
        request.accountId = acc.Id;
        Test.startTest();
        commercepayments.PaymentGatewayContext context = new commercepayments.PaymentGatewayContext((commercepayments.PaymentGatewayRequest) request, commercepayments.RequestType.Capture);
        SalesforceAdapter adapter = new SalesforceAdapter();
        Test.setMock(HttpCalloutMock.class, new AurusMockHttpResponse());
        commercepayments.GatewayResponse response = adapter.processRequest(context);
        System.assertNotEquals(null, response);
        Test.stopTest();
    }
     @isTest
    static void testProcessRequestMockCapture() {
        commercepayments.CaptureRequest request = new commercepayments.CaptureRequest(100, payAuth2.Id);
        request.accountId = acc.Id;
        Test.startTest();
        commercepayments.PaymentGatewayContext context = new commercepayments.PaymentGatewayContext((commercepayments.PaymentGatewayRequest) request, commercepayments.RequestType.Capture);
        MockAdapter adapter = new MockAdapter();
        Test.setMock(HttpCalloutMock.class, new AurusMockHttpResponse());
        commercepayments.GatewayResponse response = adapter.processRequest(context);
        System.assertNotEquals(null, response);
        Test.stopTest();
    }
    
    @isTest
    static void testNullContext() {
        commercepayments.AuthorizationRequest request = new commercepayments.AuthorizationRequest(100);
        Test.startTest();
        commercepayments.PaymentGatewayContext context = new commercepayments.PaymentGatewayContext((commercepayments.PaymentGatewayRequest) request, commercepayments.RequestType.Authorize);
        SalesforceAdapter adapter = new SalesforceAdapter();
        Test.setMock(HttpCalloutMock.class, new AurusMockHttpResponse());
        commercepayments.GatewayResponse response = adapter.processRequest(context);
        System.assertNotEquals(null, response);
        Test.stopTest(); 
    }
    
    @isTest
    static void testNullService() {
        commercepayments.PaymentGatewayContext context = null;
        SalesforceAdapter adapter = new SalesforceAdapter();
        Test.setMock(HttpCalloutMock.class, new AurusMockHttpResponse());
        commercepayments.GatewayResponse response = adapter.processRequest(context);
        System.assertNotEquals(null, response);
    }
    
    @isTest
    static void testProcessRequestRefund() {
        commercepayments.ReferencedRefundRequest request = new commercepayments.ReferencedRefundRequest(100, paymnt.Id);
        request.accountId = acc.Id;
        paymnt.AccountId = acc.Id;
        update paymnt;
        Test.startTest();
        commercepayments.PaymentGatewayContext context = new commercepayments.PaymentGatewayContext((commercepayments.PaymentGatewayRequest) request, commercepayments.RequestType.ReferencedRefund);
        SalesforceAdapter adapter = new SalesforceAdapter();
        Test.setMock(HttpCalloutMock.class, new AurusMockHttpResponse());
        commercepayments.GatewayResponse response = adapter.processRequest(context);
        WM_RefundCustomRequest.Request req = new WM_RefundCustomRequest.Request();
        req.amount = 10;
        req.paymentId = paymnt.Id;
        WM_RefundCustomRequest.processRefund(new List<WM_RefundCustomRequest.Request> {req});
        System.assertNotEquals(null, response);
        Test.stopTest();
    } 
    
    @isTest
    static void testProcessVoid() {
        List<Id> paymentAuthIds = new List<Id>();
        paymentAuthIds.add(payAuth2.Id);
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new AurusMockHttpResponse());
        WM_VoidTransactionService.voidTransaction(paymentAuthIds);
        Test.stopTest();
    } 
    
    
    @isTest
    static void testException() {
        commercepayments.ReferencedRefundRequest request = new commercepayments.ReferencedRefundRequest(100, paymnt.Id);
        commercepayments.PaymentGatewayContext context = new commercepayments.PaymentGatewayContext((commercepayments.PaymentGatewayRequest) request, commercepayments.RequestType.ReferencedRefund);
        SalesforceAdapter adapter = new SalesforceAdapter();
        Test.setMock(HttpCalloutMock.class, new AurusMockHttpResponse());
        commercepayments.GatewayResponse response = adapter.processRequest(context);
        System.assertNotEquals(null, response);
    } 
    
    
}