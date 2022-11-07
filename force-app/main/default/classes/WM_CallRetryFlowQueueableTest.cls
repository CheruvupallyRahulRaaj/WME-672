@IsTest(SeeAllData=true)
public class WM_CallRetryFlowQueueableTest  {
    public static String CRON_EXP = '0 0 0 28 12 ? 2022';
    @IsTest
    public static void WM_CallRetryFlowQueueable() {
        
        Test.startTest();
        List <Shipment>  ShipmentTestList = new   List <Shipment> ();
        string fo1 = createfulFillmntOrdr();
        Shipment s1 = new Shipment( ShipToName = 'Shorouq Ghan' ,Unique_Fulfillment_Order__c = fo1, Description  ='ship1' , Fulfill_Item_Success__c = false ,  Transfer_Reservation_Success__c = false, FulfillmentOrderId= fo1);
        s1.LineInfo__c = '{"LineInfo":[{"carton_line_nbr":1,"pick_line_nbr":1,"qty_packed":1,"qty_shipped":1}]}';
        ShipmentTestList.add(s1);
        insert ShipmentTestList;
        System.debug('SHipmentObj:'+ ShipmentTestList);
        Test.stopTest();
        
        String jobId = System.schedule('OCI Re-trial',CRON_EXP,new WM_ScheduleOCICallRetrials());
        
    }
    @IsTest
    Public static String createfulFillmntOrdr() {
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
        String orderSumId = TestDataFactory.createOrderSummaryRecord(od);
        Schema.Location locatn= TestDataFactory.createLocation();
        string fo1;
        List<String> fulFillmntOrdrIds1 = TestDataFactory.createFulfillmentOrder(orderSumId,acc.Id,locatn.Id);
        if(fulFillmntOrdrIds1.size() > 0 ) {
            fo1 = fulFillmntOrdrIds1[0]; 
        } 
        return fo1;
    }
  
    
}