@isTest(SeeAllData=true)
private class WM_ShipmentConfirmationTriggeredSendTest {
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
    public static String invId = TestDataFactory.createInvoiceRecord(fulFillmntOrdrIds[0]);
    public static FulFillmentOrder fOrder = TestDataFactory.updateFulfillmentOrder(fulFillmntOrdrIds[0],invId);
    public static Shipment ship = createShipment(fulFillmntOrdrIds);
    
	private static testMethod void test1() {
	    Shipment ship = [SELECT Id, FulfillmentOrderId FROM Shipment LIMIT 1];
	    
	    FulfillmentOrder FulfillmentOrderList = [Select Id,OrderSummaryId From FulfillmentOrder where id = :ship.FulfillmentOrderId LIMIT 1];
	    
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ShipmentResponseGenerator());
       ScheduleShipmentConfirmationEmail ref = new ScheduleShipmentConfirmationEmail();
        Datetime workTime = System.now().addMinutes(1);
        String sch = '0 0 23 * * ?';
        try{
        System.schedule('ScheduleShipmentConfirmationEmail', sch, ref);
        }
        catch(Exception e){
            system.debug('Exception occurred '+e);
        }
        Test.stopTest();
	}
	
	
	public class ShipmentResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('POST', req.getMethod());
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requestId":"ef99c9ef-c307-4e75-90ad-8aac093dd7b7","responses":[{"recipientSendId":"ef99c9ef-c307-4e75-90ad-8aac093dd7b7","hasErrors":false,"messages":["Queued"]}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public static Shipment createShipment(List<String> fulFillmntOrdrIds) {
        System.debug('====Test FulFill Order====' + fulFillmntOrdrIds);
        Shipment ship = new Shipment(
            TrackingNumber = '123456789',
            ShipToName = 'John Doe',
            FulfillmentOrderId = fulFillmntOrdrIds[0]
        );
        insert ship;
        return ship;
    }

}