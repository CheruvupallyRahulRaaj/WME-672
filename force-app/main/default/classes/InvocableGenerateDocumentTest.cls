@isTest(SeeAllData=true)
public with sharing class InvocableGenerateDocumentTest {
	static testMethod void test_1() {
		Account acc = TestDataFactory.createAccountRecord();
		SalesChannel sChannl = TestDataFactory.createSalesChannel();
		Pricebook2 pricBook = TestDataFactory.createPricebook();
		Order ordr = TestDataFactory.createOrderRecord(pricBook, acc, sChannl);
		Product2 prd = TestDataFactory.createProduct2Record();
		PricebookEntry pbEntry = TestDataFactory.createPricebookEntry(prd, pricBook);
		PaymentGateway payGateway = TestDataFactory.createPaymentGatewayRecord();
		CardPaymentMethod cpm = TestDataFactory.createCardPaymentMethodRecord(payGateway, acc);
		OrderDeliveryMethod odMethod = TestDataFactory.createOrderDeliveryMethod();
		OrderDeliveryGroup odGrp = TestDataFactory.createOrderDeliveryGroupRecord(odMethod, ordr);
		OrderAdjustmentGroup ordAdjGrp = TestDataFactory.createOrderAdjustmentGroup(ordr);
		PaymentGroup payGrp = TestDataFactory.createPaymentGroup(ordr);
		PaymentAuthorization payAuth = TestDataFactory.createPaymentAuthorizationRecord(payGateway, cpm, acc, payGrp);
		OrderItem ordItem = TestDataFactory.createOrderItemRecord(prd, odGrp, ordr, pbEntry);
		OrderItemAdjustmentLineItem ordItmAdjLineItem = TestDataFactory.createOrderItemAdjustmentLineItem(
			ordItem,
			ordAdjGrp
		);
		OrderItemTaxLineItem ordItmTaxLineItm = TestDataFactory.createOrderItemTaxLineItem(ordItem, ordItmAdjLineItem);
		Order od = TestDataFactory.updateOrderStatus(ordr);
		String orderSumId = TestDataFactory.createOrderSummaryRecord(od);
		Schema.Location locatn = TestDataFactory.createLocation();
		List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId, acc.Id, locatn.Id);
		Id fulfillmentOrderId = fulFillmntOrdrIds[0];

		FulfillmentOrder order = [SELECT DeliveryMethodId FROM FulfillmentOrder WHERE Id = :fulfillmentOrderId LIMIT 1];
		order.DeliveryMethodId = odMethod.Id;
		update order;

		zkmulti__MCShipment__c shipment = new zkmulti__MCShipment__c();
		shipment.Fulfillment_Order__c = fulfillmentOrderId;
		shipment.Manifested__c = false;
		insert shipment;

		Test.startTest();

		List<InvocableGenerateDocument.DocumentParameter> params = new List<InvocableGenerateDocument.DocumentParameter>();
		InvocableGenerateDocument.DocumentParameter param = new InvocableGenerateDocument.DocumentParameter();
		param.orderDeliveryMethodID = odMethod.Id;
		params.add(param);

		InvocableGenerateDocument.generateManifest(params);

		Test.stopTest();

		List<zkmulti__MCShipment__c> shipments = [
			SELECT Manifested__c, zkmulti__Mod_Key__c
			FROM zkmulti__MCShipment__c
			WHERE Id = :shipment.Id
		];

		for (zkmulti__MCShipment__c ship : shipments) {
			System.assertEquals(true, ship.Manifested__c);
		}

		ShowFilesController ctrl = new ShowFilesController(new ApexPages.StandardController(odMethod));
		ctrl.getFiles();
	}

	static testMethod void test_2() {
		Account acc = TestDataFactory.createAccountRecord();
		SalesChannel sChannl = TestDataFactory.createSalesChannel();
		Pricebook2 pricBook = TestDataFactory.createPricebook();
		Order ordr = TestDataFactory.createOrderRecord(pricBook, acc, sChannl);
		Product2 prd = TestDataFactory.createProduct2Record();
		PricebookEntry pbEntry = TestDataFactory.createPricebookEntry(prd, pricBook);
		PaymentGateway payGateway = TestDataFactory.createPaymentGatewayRecord();
		CardPaymentMethod cpm = TestDataFactory.createCardPaymentMethodRecord(payGateway, acc);
		OrderDeliveryMethod odMethod = TestDataFactory.createOrderDeliveryMethod();
		OrderDeliveryGroup odGrp = TestDataFactory.createOrderDeliveryGroupRecord(odMethod, ordr);
		OrderAdjustmentGroup ordAdjGrp = TestDataFactory.createOrderAdjustmentGroup(ordr);
		PaymentGroup payGrp = TestDataFactory.createPaymentGroup(ordr);
		PaymentAuthorization payAuth = TestDataFactory.createPaymentAuthorizationRecord(payGateway, cpm, acc, payGrp);
		OrderItem ordItem = TestDataFactory.createOrderItemRecord(prd, odGrp, ordr, pbEntry);
		OrderItemAdjustmentLineItem ordItmAdjLineItem = TestDataFactory.createOrderItemAdjustmentLineItem(
			ordItem,
			ordAdjGrp
		);
		OrderItemTaxLineItem ordItmTaxLineItm = TestDataFactory.createOrderItemTaxLineItem(ordItem, ordItmAdjLineItem);
		Order od = TestDataFactory.updateOrderStatus(ordr);
		String orderSumId = TestDataFactory.createOrderSummaryRecord(od);
		Schema.Location locatn = TestDataFactory.createLocation();
		List<String> fulFillmntOrdrIds = TestDataFactory.createFulfillmentOrder(orderSumId, acc.Id, locatn.Id);
		Id fulfillmentOrderId = fulFillmntOrdrIds[0];

		FulfillmentOrder order = [SELECT DeliveryMethodId FROM FulfillmentOrder WHERE Id = :fulfillmentOrderId LIMIT 1];
		order.DeliveryMethodId = odMethod.Id;
		update order;

		zkmulti__MCShipment__c shipment = new zkmulti__MCShipment__c();
		shipment.Fulfillment_Order__c = fulfillmentOrderId;
		shipment.Manifested__c = false;
		insert shipment;

		Test.startTest();
		GenerateManifestController ctrl = new GenerateManifestController();
		String odMethodId = odMethod.Id;
		ctrl.orderDeliveryMethodID = odMethodId.left(15);
		ctrl.doInit();
		ctrl.getToday();
		ctrl.getHeaderText();

		Test.stopTest();
	}
}