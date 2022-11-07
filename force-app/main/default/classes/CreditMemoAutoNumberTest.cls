@isTest(SeeAllData=true)
public class CreditMemoAutoNumberTest {
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
    public static String orderItemSumId = [select Id,QuantityFulFilled,QuantityAllocated,QuantityReturned,QuantityOrdered  
                                           from OrderItemSummary where OrderSummaryId=:orderSumId limit 1].Id;
    public static Schema.Location locatn= TestDataFactory.createLocation();
    public static List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId,acc.Id,locatn.Id);   
    public static String invId = TestDataFactory.createInvoiceRecord(fulFillmntOrdrIds[0]);
    public static FulFillmentOrder updatedFulFillmntOrdr =TestDataFactory.updateFulfillmentOrder(fulFillmntOrdrIds[0],invId);
    public static e_GiftCard__c giftCard = TestDataFactory.createGiftCard(orderSumId);
    @IsTest
    static void testCreditMemo() {
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
        //Mocking the response for the REST callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WM_CreditMemoService.callCreditMemoService(new List<Id> {creditMemoId});
        Test.stopTest();
    }
    
}