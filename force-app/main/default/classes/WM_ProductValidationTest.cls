@isTest(SeeAllData=true) 
private class WM_ProductValidationTest {
    /*@testSetup
    private static void createTestData() {
         Product2 product = new Product2(
            Name = 'Test Product',
            ProductCode = 'Test Product Code',
            IsActive = true
        );
        insert product;*/
        
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
    
    
    @isTest
    private static void testProductValidation1() {
        String accessToken = '';
        
        Product2 product = [SELECT Id, ProductCode FROM Product2 LIMIT 1];
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ProductExistsResponseGenerator());
            WM_ProductValidation.isProductExist(product.ProductCode, orderItemSumId);
            // Get Id from Commerce Cloud populated Json Map
            // String isExists = 'true';
                  
                    
            //             Boolean bdropshipi = true;
            //             Boolean bwestAdvantageProducti = false;
            //             Boolean bphysicalGiftCardi = false;
            //             System.assertEquals(bdropshipi, true);
            //             System.assertEquals(bwestAdvantageProducti, false);
            //             System.assertEquals(bphysicalGiftCardi, false);
            //             Product2 oiToBeUpdate = new Product2(
            //             Id = '01t5C000003uxCuQAI', 
            //             Productcode = '1000000000',
            //             StockKeepingUnit = '100000cscsc',
            //             Description = 'This is a great description',
            //             Name = 'This is a great description',
            //             weight__c = '10.0',
            //             vendorNumber__c = '12345',
            //             dropship__c = true,
            //             westAdvantageProduct__c = false,
            //             physicalGiftCard__c = true
            //         );
                    
            //         update oiToBeUpdate;
            //         System.debug('=====oiToBeUpdate====' + oiToBeUpdate);
                
            //WM_ProductValidation.isProductExist(product.ProductCode);
        Test.stopTest(); 
         
    }
    
    @isTest
    private static void testProductValidation2() {
       Product2 product = [SELECT Id, ProductCode FROM Product2 LIMIT 1];
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ProductNotExistsResponseGenerator());
            WM_ProductValidation.isProductExist(product.ProductCode, orderItemSumId);
        Test.stopTest(); 
    }
    
    @isTest
    private static void testProductValidation3() {
       Product2 product = [SELECT Id, ProductCode FROM Product2 LIMIT 1];
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ProductExceptionResponseGenerator());
            WM_ProductValidation.isProductExist(product.ProductCode, orderItemSumId);
        Test.stopTest(); 
    }
    
    public class ProductNotExistsResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('GET', req.getMethod());
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id":"test123","c_weight":"10","c_vendorNumber":"123","c_dropship":"true","c_westAdvantageProduct":"true","c_giftCardProduct":"true"}');
            res.setStatusCode(404);
            return res;
        }
    }
    
    public class ProductExistsResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            Product2 product = [SELECT Id, ProductCode FROM Product2 LIMIT 1];
            
            System.assertEquals('GET', req.getMethod());
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
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
   
    
    // @isTest
    // private static void testIfs() { 
    //  Test.startTest(); 
    //         Boolean bdropship = true;
    //         Boolean bwestAdvantageProduct = false;
    //         Boolean bphysicalGiftCard = false;
    //         System.assertEquals(bdropship, true);
    //         System.assertEquals(bwestAdvantageProduct, false);
    //         System.assertEquals(bphysicalGiftCard, false);
    //          Product2 oiToBeUpdate = new Product2(
    //                     Id = '01t5C000003uxCuQAI', 
    //                     Productcode = '1000000000',
    //                     StockKeepingUnit = '100000cscsc',
    //                     Description = 'This is a great description',
    //                     Name = 'This is a great description',
    //                     weight__c = '10.0',
    //                     vendorNumber__c = '12345',
    //                     dropship__c = true,
    //                     westAdvantageProduct__c = false,
    //                     physicalGiftCard__c = true
    //                 );
                    
    //                 update oiToBeUpdate;
            
    // Test.stopTest(); 
    // }
}