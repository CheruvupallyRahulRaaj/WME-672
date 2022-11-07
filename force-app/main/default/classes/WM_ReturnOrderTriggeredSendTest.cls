@isTest(SeeAllData=true)
private class WM_ReturnOrderTriggeredSendTest {

public static Account acc = TestDataFactory.createAccountRecord();
  /*  public static Address__c add = TestDataFactory.createAddress(acc.ID);
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
    
	private static testMethod void test() {
        OrderSummary os = [SELECT Id FROM OrderSummary WHERE Id = :orderSumId LIMIT 1];
	    
        List<WM_ReturnOrderTriggeredSend.msgInput> msgInputList = new List<WM_ReturnOrderTriggeredSend.msgInput>();
        
        WM_ReturnOrderTriggeredSend.msgInput msgInput = new WM_ReturnOrderTriggeredSend.msgInput();
        msgInput.sOrderSummaryId = os.Id;
        msgInputList.add(msgInput);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ReturnOrderResponseGenerator());
            WM_ReturnOrderTriggeredSend.sendTGiftCardTriggeredSend(msgInputList);
        Test.stopTest();
	}
	
	public class ReturnOrderResponseGenerator implements HttpCalloutMock {
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
*/
}