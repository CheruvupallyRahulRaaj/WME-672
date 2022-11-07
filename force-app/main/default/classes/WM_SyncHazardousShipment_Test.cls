@IsTest(SeeAllData=true)
public class WM_SyncHazardousShipment_Test {
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
    public static zkmulti__MCShipment__c shipment = createShipment(fulFillmntOrdrIds);
    public static zkmulti__MCCustoms_Item__c shipmentitem = createShipmentItem(shipment);
    public static Shipment shipments = createShipments(shipment);
    
    private static testMethod void test1() {
        WM_SyncHazardousShipment.createHazardousShipments(fulFillmntOrdrIds[0]);
    }
    
    public static zkmulti__MCShipment__c createShipment(List<String> fulFillmntOrdrIds) {
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

    public static zkmulti__MCCustoms_Item__c createShipmentItem(zkmulti__MCShipment__c shipment) {
        zkmulti__MCCustoms_Item__c shipmentItem = new zkmulti__MCCustoms_Item__c(
            zkmulti__Shipment__c = shipment.ID,
            zkmulti__Packed_Quantity__c = 1
        );
        insert shipmentItem;
        return shipmentItem;
    }

    public static Shipment createShipments(zkmulti__MCShipment__c shipment){
        Shipment shp = new Shipment(
            LineInfo__c = '{"LineInfo":[{"pick_line_nbr":1,"qty_shipped":1}]}',
            Weight__c=12,
            ShipToName = 'test');
        insert shp;
        return shp;
    }
}