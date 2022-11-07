public with sharing class GenerateManifestController {
	public String orderDeliveryMethodID;
	public List<zkmulti__MCShipment__c> shipments { get; private set; }

	//System.debug('Hello');
	public GenerateManifestController() {
		this.orderDeliveryMethodID = ApexPages.currentPage().getParameters().get('id');
		if (String.isNotBlank(this.orderDeliveryMethodID)) {
			this.orderDeliveryMethodID = this.orderDeliveryMethodID.left(15);
		}
	}

	public void doInit() {
		this.shipments = [
			SELECT
				Name,
				Fulfillment_Order__r.Account.AccountNumber,
				Fulfillment_Order__r.Account.Name,
                Fulfillment_Order__r.OrderSummary.OrderNumber,
				zkmulti__Recipient_Phone__c,
				ZK_Route_Seq__c,
				ZK_Order_Delivery_Method__c,
				zkmulti__Shipmate_Preference__r.Name
			FROM zkmulti__MCShipment__c
			WHERE ZK_Order_Delivery_Method__c = :this.orderDeliveryMethodID AND Manifested__c = FALSE
		];
	}

	public String getHeaderText() {
		OrderDeliveryMethod order = [
			SELECT Name
			FROM OrderDeliveryMethod
			WHERE Id = :this.orderDeliveryMethodID
			LIMIT 1
		];
		return order.Name;

		// if (!this.shipments.isEmpty()) {
		// 	if (this.shipments[0].zkmulti__Shipmate_Preference__r != null) {
		// 		return this.shipments[0].zkmulti__Shipmate_Preference__r.Name;
		// 	}
		// }
		// return '';
	}

	public String getToday() {
		Date d = Date.today();
		String year = '' + d.year();
		// year = year.right(2);
		Integer day = d.day();
		Integer month = d.month();
		return month + '/' + day + '/' + year;
	}
}