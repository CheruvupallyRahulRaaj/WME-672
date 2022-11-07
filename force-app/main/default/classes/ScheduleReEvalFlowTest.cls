@isTest(SeeAllData=true) 
public class ScheduleReEvalFlowTest {
    
    /*public static Account acc = TestDataFactory.createAccountRecord();
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
    
    static testMethod void reEvaluateFlw() {
        List<OrderDeliveryGroupSummary> orderDeliveryGroupSummaryList = [SELECT Id,PartiallyFulfilled__c FROM OrderDeliveryGroupSummary WHERE OrderSummaryId =: orderSumId];
        orderDeliveryGroupSummaryList[0].PartiallyFulfilled__c = true;
        update orderDeliveryGroupSummaryList[0];
        Test.startTest();
        ScheduleReEvaluateFlow ref = new ScheduleReEvaluateFlow();
        Datetime workTime = System.now().addMinutes(1);
        String sch = '0 0 23 * * ?';
        try{
            System.schedule('ScheduleReEvaluateFlow', sch, ref);
        }
        catch(Exception e){
            system.debug('Exception occurred '+e);
        }
        
        Test.stopTest();
    }*/
}