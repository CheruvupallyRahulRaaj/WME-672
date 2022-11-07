@isTest(SeeAllData=true)  
private class WM_OrderDeliveryGroupGEOLookupTest {   
public static Account acc = TestDataFactory.createAccountRecord();
    public static Address__c add = TestDataFactory.createAddress(acc.ID);
    public static SalesChannel sChannl = TestDataFactory.createSalesChannel();
    public static Pricebook2 pricBook = TestDataFactory.createPricebook();
    public static Order ordr = TestDataFactory.createOrderRecord(pricBook, acc, sChannl);
    public static Product2 prd = TestDataFactory.createProduct2Record(); 
    public static PricebookEntry pbEntry = TestDataFactory.createPricebookEntry(prd,pricBook);
    public static OrderDeliveryMethod odMethod = TestDataFactory.createOrderDeliveryMethod();
    public static OrderDeliveryGroup odGrp = TestDataFactory.createOrderDeliveryGroupRecord(odMethod,ordr);

 private static testMethod void test1() {
        List<WM_OrderDeliveryGroupGEOLookup.FlowInput> FlowInputs = new List<WM_OrderDeliveryGroupGEOLookup.FlowInput>();
        WM_OrderDeliveryGroupGEOLookup.FlowInput fi = new WM_OrderDeliveryGroupGEOLookup.FlowInput();
        fi.srecordId = odGrp.Id;
        FlowInputs.add(fi);
        
        WM_OrderDeliveryGroupGEOLookup.getGeoLatlong(FlowInputs);
    }
      static testMethod void updateRecords() {
        List<OrderDeliveryGroupSummary> orderDeliveryGroupSummaryList = [SELECT Id,PartiallyFulfilled__c FROM OrderDeliveryGroupSummary Limit 1];
        orderDeliveryGroupSummaryList[0].PartiallyFulfilled__c = false;
        update orderDeliveryGroupSummaryList[0];
      }
}