@isTest(SeeAllData=true) 
private class WM_ProductValidationFlowTest {
    
   /* @testSetup
    private static void createTestData() {
        Account acc = TestDataFactory.createAccountRecord();
        
        Product2 product = new Product2(
            Name = 'Test Product',
            ProductCode = 'Test Product Code',
            IsActive = true
        );
        insert product;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;

        PricebookEntry pbEntry          =   TestDataFactory.createPricebookEntry(product, standardPricebook);
        SalesChannel sChannl            =   TestDataFactory.createSalesChannel();
        Order ordr                      =   TestDataFactory.createOrderRecord(standardPricebook, acc, sChannl);
        OrderDeliveryMethod odMethod    =   TestDataFactory.createOrderDeliveryMethod();
        OrderDeliveryGroup odGrp        =   TestDataFactory.createOrderDeliveryGroupRecord(odMethod, ordr);
        OrderItem ordItem               =   TestDataFactory.createOrderItemRecord(product, odGrp, ordr, pbEntry);
    }*/
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
    
	private static testMethod void productExistsTest() {
	    Product2 prod = [SELECT Id, ProductCode, StockKeepingUnit FROM Product2 LIMIT 1];
	    OrderItem ordItem = [SELECT Id FROM OrderItem LIMIT 1];
        List<WM_ProductValidationFlow.ProductInput> ProductInputs = new List<WM_ProductValidationFlow.ProductInput>();
        
        WM_ProductValidationFlow.ProductInput prodInput = new WM_ProductValidationFlow.ProductInput();
        // prodInput.srecordId = ordItem.Id;
        prodInput.srecordId = orderItemSumId;
        prodInput.sproductCode = prod.ProductCode;
        ProductInputs.add(prodInput);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ProductExistsResponseGenerator());
            WM_ProductValidationFlow.getProductValidation(ProductInputs);
        Test.stopTest();
	}
	
	private static testMethod void productExceptionTest() {
	    Product2 prod = [SELECT Id, ProductCode, StockKeepingUnit FROM Product2 LIMIT 1];
	    OrderItem ordItem = [SELECT Id FROM OrderItem LIMIT 1];
	    
        List<WM_ProductValidationFlow.ProductInput> ProductInputs = new List<WM_ProductValidationFlow.ProductInput>();
        
        WM_ProductValidationFlow.ProductInput prodInput = new WM_ProductValidationFlow.ProductInput();
        // prodInput.srecordId = ordItem.Id;
        prodInput.srecordId = orderItemSumId;
        prodInput.sproductCode = prod.ProductCode;
        ProductInputs.add(prodInput);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ProductExceptionResponseGenerator());
            WM_ProductValidationFlow.getProductValidation(ProductInputs);
        Test.stopTest();
	}
	
	private static testMethod void productNotExistsTest() {
	    Product2 prod = [SELECT Id, ProductCode, StockKeepingUnit FROM Product2 LIMIT 1];
	    OrderItem ordItem = [SELECT Id FROM OrderItem LIMIT 1];
	    
        List<WM_ProductValidationFlow.ProductInput> ProductInputs = new List<WM_ProductValidationFlow.ProductInput>();
        
        WM_ProductValidationFlow.ProductInput prodInput = new WM_ProductValidationFlow.ProductInput();
        // prodInput.srecordId = ordItem.Id;
        prodInput.srecordId = orderItemSumId;
        prodInput.sproductCode = prod.ProductCode;
        ProductInputs.add(prodInput);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ProductNotExistsResponseGenerator());
            WM_ProductValidationFlow.getProductValidation(ProductInputs);
        Test.stopTest();
	}
	
	private static testMethod void productCodeMissingTest() {
	   // OrderItem ordItem = [SELECT Id FROM OrderItem LIMIT 1];
	    Product2 prod = [SELECT Id, ProductCode, StockKeepingUnit FROM Product2 LIMIT 1];
	    
        List<WM_ProductValidationFlow.ProductInput> ProductInputs = new List<WM_ProductValidationFlow.ProductInput>();
        
        WM_ProductValidationFlow.ProductInput prodInput = new WM_ProductValidationFlow.ProductInput();
        // prodInput.srecordId = ordItem.Id;
        prodInput.srecordId = prod.Id;
        prodInput.sproductCode = null;
        ProductInputs.add(prodInput);
        
        Test.startTest();
            WM_ProductValidationFlow.getProductValidation(ProductInputs);
        Test.stopTest();
	}
	
	public class ProductExistsResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            Product2 product = [SELECT Id, ProductCode, StockKeepingUnit FROM Product2 LIMIT 1];
            
            System.assertEquals('GET', req.getMethod());
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            // res.setBody('{"count":2,"data":[{"brand":"Creative","id":"' + product.ProductCode + '","min_order_quantity":1,"name":"Creative ZEN V Digital Media Player","orderable":true,"page_description":"testpaedescription","page_keywords":"Creative","page_title":"Creative ZEN V Digital Media Player","price":71.99,"price_per_unit":71.99,"primary_category_id":"electronics-digital-media-players","short_description":"Test Short Description","step_quantity":1,"type":{"item":true},"unit_measure":"each","unit_quantity":1,"c_mediaFormat":["0010","0020","0030","0040"],"c_memorySize":"1GB","c_tabDescription":"test description"}],"total":1}');
            res.setBody('{"id":"' + product.ProductCode + '","name":"test product","c_weight":"10","c_vendorNumber":"123","c_dropship":"true","c_westAdvantageProduct":"true","c_giftCardProduct":"true"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class ProductExceptionResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            Product2 product = [SELECT Id, ProductCode, StockKeepingUnit FROM Product2 LIMIT 1];
            
            System.assertEquals('GET', req.getMethod());
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            // res.setBody('{"count":2,"data":[{"brand":"Creative","id":"' + product.ProductCode + '","min_order_quantity":1,"name":"Creative ZEN V Digital Media Player","orderable":true,"page_description":"testpaedescription","page_keywords":"Creative","page_title":"Creative ZEN V Digital Media Player","price":71.99,"price_per_unit":71.99,"primary_category_id":"electronics-digital-media-players","short_description":"Test Short Description","step_quantity":1,"type":{"item":true},"unit_measure":"each","unit_quantity":1,"c_mediaFormat":["0010","0020","0030","0040"],"c_memorySize":"1GB","c_tabDescription":"test description"}],"total":1}');
            res.setBody('{"id":"' + product.ProductCode + '","c_weight":"10","c_vendorNumber":"123","c_dropship":"true","c_westAdvantageProduct":"true","c_giftCardProduct":"true"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class ProductNotExistsResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('GET', req.getMethod());
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            // res.setBody('{"count":2,"data":[{"brand":"Creative","id":"Test","min_order_quantity":1,"name":"Creative ZEN V Digital Media Player","orderable":true,"page_description":"test page description","page_keywords":"Creative","page_title":"Creative ZEN V Digital Media Player","price":71.99,"price_per_unit":71.99,"primary_category_id":"electronics-digital-media-players","short_description":"Test Short Description","step_quantity":1,"type":{"item":true},"unit_measure":"each","unit_quantity":1,"c_mediaFormat":["0010","0020","0030","0040"],"c_memorySize":"1GB","c_tabDescription":"test description"}],"total":1}');
            res.setBody('{"id":"test123","c_weight":"10","c_vendorNumber":"123","c_dropship":"true","c_westAdvantageProduct":"true","c_giftCardProduct":"true"}');
            res.setStatusCode(404);
            return res;
        }
    }
}