@isTest(SeeAllData=true) 
public class WM_PickupItems_CancelItemsTest { 
    // @istest static void testSendEmailForCancelandReturn(){
    //to create order summary
    public static Account acc = TestDataFactory.createAccountRecord();
    public static SalesChannel sChannl = TestDataFactory.createSalesChannel();
    public static Pricebook2 pricBook = TestDataFactory.createPricebook();
    public static  Order ordr = TestDataFactory.createOrderRecord(pricBook, acc, sChannl);
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
    //public static FulFillmentOrder updatedFulFillmntOrdr =TestDataFactory.updateFulfillmentOrder(fulFillmntOrdrIds[0],invId);
    public static e_GiftCard__c giftCard = TestDataFactory.createGiftCard(orderSumId);
    public static String fulFillmntOrderIds = [SELECT AccountId,BOPIS__c,Destination_Location__c,FulfilledToAddress,FulfilledToCity,FulfilledToCountry,FulfilledToEmailAddress,FulfilledToGeocodeAccuracy,FulfilledToLatitude,FulfilledToLongitude,FulfilledToName,FulfilledToPhone,FulfilledToPostalCode,FulfilledToShippingStreet2__c,FulfilledToShippingStreet3__c,FulfilledToShippingStreet4__c,FulfilledToState,FulfilledToStreet,FulfillmentOrderNumber,GrandTotalAmount,hazardousMaterial__c,Id,InvoiceId,IsDeleted,IsReship,IsSuspended,ItemCount,JDAFulfillmentOrderNumber__c,JSON_sent_to_TIBCO__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,My_FulFillment_Location__c,OrderId,OrderSummaryId,OwnerId,Product__c,Re_trials_for_Fulfill_Items__c,Status,StatusCategory,TotalAmount,TotalDeliveryAmount,TotalDeliveryAmtWithTax,TotalDeliveryTaxAmount,TotalProductAmount,TotalTaxAmount,Type FROM FulfillmentOrder Where ordersummaryId =:orderSumId limit 1].Id;
    //public static String orderChange = [SELECT ChangeOrderItemId,ChangeType,CreatedById,CreatedDate,Id,IsDeleted,IsPreFulfillment,LastModifiedById,LastModifiedDate,OrderItemSummaryChangeNumber,OrderItemSummaryId,OrderSummaryId,Reason,SystemModstamp FROM OrderItemSummaryChange Where ordersummaryId =:orderSumId limit 1].Id;
    @IsTest
    static void test1() {
        ConnectApi.ChangeItemInputRepresentation input = new ConnectApi.ChangeItemInputRepresentation();
        input.orderItemSummaryId = orderItemSumId;
        //input.Status = 'Cancelled';
        input.quantity = 1;
        //input.reason = '30';
        input.shippingReductionFlag = false;
        ConnectApi.ChangeInputRepresentation changeInput = new ConnectApi.ChangeInputRepresentation();
        changeInput.changeItems = new List<ConnectApi.ChangeItemInputRepresentation>{input};
            //ConnectApi.SubmitReturnOutputRepresentation output =  ConnectApi.OrderSummary.submitReturn(orderSumId,changeInput);
        //String creditMemoId = TestDataFactory.createCreditMemoRecord(output.changeOrderId,orderSumId);       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WM_PickupItems_CancelItems.getCancelReason(fulFillmntOrderIds, '101');
        Test.stopTest();
    }
    @IsTest
    static void test2() {
        ConnectApi.ChangeItemInputRepresentation input = new ConnectApi.ChangeItemInputRepresentation();
        input.orderItemSummaryId = orderItemSumId;
        input.quantity = 1;
        input.reason = '30';
        //input.Status = 'Fulfilled';
        input.shippingReductionFlag = false;
        ConnectApi.ChangeInputRepresentation changeInput = new ConnectApi.ChangeInputRepresentation();
        changeInput.changeItems = new List<ConnectApi.ChangeItemInputRepresentation>{input};
            //ConnectApi.SubmitReturnOutputRepresentation output =  ConnectApi.OrderSummary.submitReturn(orderSumId,changeInput);
        //String creditMemoId = TestDataFactory.createCreditMemoRecord(output.changeOrderId,orderSumId);       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WM_PickupItems_CancelItems.getPickupItems(fulFillmntOrderIds);
        Test.stopTest();
    }
    
}