/**
* @description       :  test class for WM_ServiceHelper
* @author            :  Manohar.Alla@genzeon.com
* @last modified on  :  12-09-2022
* @last modified by  :  Manohar.Alla@genzeon.com
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   12-09-2022   Manohar.Alla@genzeon.com             Initial Version
**/

@IsTest(SeeAllData=true)
public with sharing class WM_ServiceHelperTest {
    
    @istest
    public static void Testmethod1(){
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
        String orderSumId = TestDataFactory.createOrderSummaryRecord(od);
        String orderItemSumId = [select Id,QuantityFulFilled,QuantityAllocated,QuantityReturned,QuantityOrdered  
                                              from OrderItemSummary where OrderSummaryId=:orderSumId limit 1].Id;
        Schema.Location locatn= TestDataFactory.createLocation();
        List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId,acc.Id,locatn.Id);   
        String invId = TestDataFactory.createInvoiceRecord(fulFillmntOrdrIds[0]);
        FulFillmentOrder updatedFulFillmntOrdr =TestDataFactory.updateFulfillmentOrder(fulFillmntOrdrIds[0],invId);
        e_GiftCard__c giftCard = TestDataFactory.createGiftCard(orderSumId);

        set<id> fullforder = new set<id>();
        fullforder.add(fulFillmntOrdrIds[0]);
        FulfillmentOrder fo =  WM_ServiceHelper.getFulfillmentOrder(fulFillmntOrdrIds[0]);
        OrderDeliveryMethod ordm= WM_ServiceHelper.getOrderDeliveryMethod(odMethod.id);
        WM_ServiceHelper.getOrderSummary(orderSumId);
        WM_ServiceHelper.getOrderPaymentSummary(orderSumId);
        WM_ServiceHelper.getFulfillmentOrderLineItem(fullforder);
        WM_ServiceHelper.getOrderItem(ordItem.id);
        Product2 prod=  WM_ServiceHelper.getProduct(prd.id);
        Order order1=  WM_ServiceHelper.getOrder(ordr.id);
        WM_ServiceHelper.getSalesChannel(sChannl.id);
        WM_ServiceHelper.getAccount(acc.id);
        WM_ServiceHelper.getOrderDeliveryGroup(odGrp.id);
        WM_ServiceHelper.getAddress(acc.id);
                WM_ServiceHelper.getOrderItemSummary(orderItemSumId);
        WM_ServiceHelper.getTaxExemptions(acc.id);
        WM_ServiceHelper.getshpment(fullforder);

        // create  credit  memo
    
        ConnectApi.ChangeItemInputRepresentation input = new ConnectApi.ChangeItemInputRepresentation();
        input.orderItemSummaryId = orderItemSumId;
        input.quantity = 1;
        input.reason = '1';
        input.shippingReductionFlag = false;
        ConnectApi.ChangeInputRepresentation changeInput = new ConnectApi.ChangeInputRepresentation();
        changeInput.changeItems = new List<ConnectApi.ChangeItemInputRepresentation>{input};
            ConnectApi.SubmitReturnOutputRepresentation output =  ConnectApi.OrderSummary.submitReturn(orderSumId,changeInput);
        String creditMemoId = TestDataFactory.createCreditMemoRecord(output.changeOrderId,orderSumId);
        WM_ServiceHelper.getCreditMemo(creditMemoId);
        system.assertEquals(fulFillmntOrdrIds[0],fo.id);
        system.assertEquals(prd.id,prod.id);
        system.assertEquals(ordr.id,order1.id);
        system.assertEquals(odMethod.id,ordm.id);

    }


}