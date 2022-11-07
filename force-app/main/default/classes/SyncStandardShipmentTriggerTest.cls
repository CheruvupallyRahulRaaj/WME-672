@IsTest(SeeAllData=true)
private class SyncStandardShipmentTriggerTest {
    public static Account acc = TestDataFactory.createAccountRecord();
    public static Address__c add = TestDataFactory.createAddress(acc.ID);
    public static SalesChannel sChannl = TestDataFactory.createSalesChannel();
    public static Pricebook2 pricBook = TestDataFactory.createPricebook();
    public static Order ordr = TestDataFactory.createOrderRecord(pricBook, acc, sChannl);
    public static Product2 prd = TestDataFactory.createProduct2Record();
    public static PricebookEntry pbEntry = TestDataFactory.createPricebookEntry(prd,pricBook);
    public static OrderDeliveryMethod odMethod = TestDataFactory.createOrderDeliveryMethod();
    public static OrderDeliveryGroup odGrp = TestDataFactory.createOrderDeliveryGroupRecord(odMethod,ordr);
    public static OrderItem ordItem =  TestDataFactory.createOrderItemRecord(prd,odGrp,ordr,pbEntry);
    public static Order od = TestDataFactory.updateOrderStatus(ordr);
    public static String orderSumId = TestDataFactory.createOrderSummaryRecord(od);
    public static Schema.Location locatn= TestDataFactory.createLocation();
    public static List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId,acc.Id,locatn.Id);   
    // public static String invId = TestDataFactory.createInvoiceRecord(fulFillmntOrdrIds[0]);
    // public static zkmulti__MCShipment__c shipment = createShipment(fulFillmntOrdrIds);
    
	private static testMethod void test1() {
        zkmulti__MCShipment__c shipment = createShipment(fulFillmntOrdrIds);
	}
	
	public static zkmulti__MCShipment__c createShipment(List<String> fulFillmntOrdrIds) {
        System.debug('====Test FulFill Order====' + fulFillmntOrdrIds);
        zkmulti__MCShipment__c shipment = new zkmulti__MCShipment__c(
            zkmulti__Carrier__c = 'FedEx',
            zkmulti__Tracking_Number__c = '123456789',
            zkmulti__Ship_Date__c = Date.today().addDays(5),
            Fulfillment_Order__c = fulFillmntOrdrIds[0],
            zkmulti__Recipient_Name__c = 'Test Shipment'
        );
        insert shipment;
        return shipment;
    }
}