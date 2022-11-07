/**
* @description       : Test Class for WM_PickOutService class
* @author            : schauhan@liveareacx.com
* @last modified on  : 02-09-2021
* @last modified by  : schauhan@liveareacx.com
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   01-14-2021   schauhan@liveareacx.com   Initial Version
**/

// seeAllData is set to true because ConnectApi methods are not supported in data siloed tests.
@isTest(SeeAllData=true) 
public class WM_PickOutServiceTest {
    @IsTest
    static void testPickOut() {
        Account acc = TestDataFactory.createAccountRecord();
        Address__c add = TestDataFactory.createAddress(acc.ID);
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
        system.debug('order '+od);
        String orderSumId = TestDataFactory.createOrderSummaryRecord(od);
        String orderItemSumId = [select Id,QuantityFulFilled,QuantityAllocated,QuantityReturned,QuantityOrdered  
                                           from OrderItemSummary where OrderSummaryId=:orderSumId limit 1].Id;
        Schema.Location locatn= TestDataFactory.createLocation();
        List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId,acc.Id,locatn.Id);
        e_GiftCard__c giftCard = TestDataFactory.createGiftCard(orderSumId);
        //Account acc1 = TestDataFactory.CreateBusinAccount(acc.ID);
        
        Test.startTest();
        //Mocking the response for the REST callout     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WM_PickOutService.pickOutService(fulFillmntOrdrIds);
        Test.stopTest();
    } 
    
    @IsTest
    static void testPickOut1() {
        Account Acc = new Account();        
        Acc.Name = 'Naveen';
        Acc.AccountNumber = '10416913';
        Acc.Type = 'Business';
        Acc.Email__c = 'test1@gmail.com';
        insert Acc;
        Account Acc1 = new Account();        
        Acc1.Name = 'Naveen';
        Acc1.AccountNumber = '10416913';
        Acc1.Type = 'Business';
        Acc1.ParentId = Acc.Id;
        insert Acc1;
        Address__c add = TestDataFactory.createAddress(Acc.ID);

        List <Address__c> AddUpdate = [Select id, Phone__c, wmPreferredAddress__c from Address__c Where id = :add.id];      
                                       update AddUpdate; 
        SalesChannel sChannl = TestDataFactory.createSalesChannel();
        Pricebook2 pricBook = TestDataFactory.createPricebook();
        Order ordr = TestDataFactory.createOrderRecord(pricBook, Acc1, sChannl);
        Product2 prd = TestDataFactory.createProduct2Record();
        PricebookEntry pbEntry = TestDataFactory.createPricebookEntry(prd,pricBook);
        PaymentGateway payGateway = TestDataFactory.createPaymentGatewayRecord();
        CardPaymentMethod cpm = TestDataFactory.createCardPaymentMethodRecord(payGateway,Acc1);
        OrderDeliveryMethod odMethod = TestDataFactory.createOrderDeliveryMethod();
        OrderDeliveryGroup odGrp = TestDataFactory.createOrderDeliveryGroupRecord(odMethod,ordr);
        OrderAdjustmentGroup ordAdjGrp = TestDataFactory.createOrderAdjustmentGroup(ordr);
        PaymentGroup payGrp = TestDataFactory.createPaymentGroup(ordr);
        PaymentAuthorization payAuth =  TestDataFactory.createPaymentAuthorizationRecord(payGateway,cpm,Acc1,payGrp);
        OrderItem ordItem =  TestDataFactory.createOrderItemRecord(prd,odGrp,ordr,pbEntry);
        OrderItemAdjustmentLineItem ordItmAdjLineItem = TestDataFactory.createOrderItemAdjustmentLineItem(ordItem,ordAdjGrp);
        OrderItemTaxLineItem ordItmTaxLineItm = TestDataFactory.createOrderItemTaxLineItem(ordItem,ordItmAdjLineItem);
        Order od = TestDataFactory.updateOrderStatus(ordr);
        system.debug('order '+od);
        String orderSumId = TestDataFactory.createOrderSummaryRecord(od);
        String orderItemSumId = [select Id,QuantityFulFilled,QuantityAllocated,QuantityReturned,QuantityOrdered  
                                           from OrderItemSummary where OrderSummaryId=:orderSumId limit 1].Id;
        Schema.Location locatn= TestDataFactory.createLocation();
        List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId,Acc1.Id,locatn.Id);
        e_GiftCard__c giftCard = TestDataFactory.createGiftCard(orderSumId);
        //Account acc1 = TestDataFactory.CreateBusinAccount(acc.ID);
        
        Test.startTest();
        //Mocking the response for the REST callout     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WM_PickOutService.pickOutService(fulFillmntOrdrIds);
        Test.stopTest();
    } 


    // manohar  changes start
    @IsTest
    static void testPickOut2() {
        Account acc = TestDataFactory.createAccountRecord();
        Address__c add = TestDataFactory.createAddress(acc.ID);
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
        system.debug('order '+od);
        String orderSumId = TestDataFactory.createOrderSummaryRecord(od);
        String orderItemSumId = [select Id,QuantityFulFilled,QuantityAllocated,QuantityReturned,QuantityOrdered  
                                           from OrderItemSummary where OrderSummaryId=:orderSumId limit 1].Id;
        Schema.Location locatn= TestDataFactory.createLocation();
        List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId,acc.Id,locatn.Id);
            e_GiftCard__c giftCard = TestDataFactory.createGiftCard(orderSumId);
        //Account acc1 = TestDataFactory.CreateBusinAccount(acc.ID);
        list<fulfillmentOrder> fulfillmentOrderList  =[select  id ,type  from fulfillmentOrder  where  id in :fulFillmntOrdrIds limit 2 ];
       list<id> fullorderIds = new list<id>();
        if(!fulfillmentOrderList.isEmpty()){
               for (fulfillmentOrder fl:fulfillmentOrderList){
                 fl.type='Special';
                 fullorderIds.add(fl.id);
               }
               update fulfillmentOrderList;
        }
         
        Test.startTest();
        //Mocking the response for the REST callout     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WM_PickOutService.pickOutService(fullorderIds);
        Test.stopTest();
    } 
   // manaohar  changes  end
}