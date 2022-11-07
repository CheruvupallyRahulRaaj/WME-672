global with sharing class InvocableGenerateDocument {
	@InvocableMethod(label='Generate Manifest' description='Generate Manifest.')
	global static void generateManifest(List<DocumentParameter> inputList) {
		generateManifestFuture(JSON.serialize(inputList));
	}

	@future(callout=true)
	global static void generateManifestFuture(String input) {
		List<DocumentParameter> inputList = (List<DocumentParameter>) JSON.deserialize(
			input,
			List<DocumentParameter>.class
		);
		List<ContentVersion> conVers = new List<ContentVersion>();
		List<String> zkOrderDeliveryMethodIds = new List<String>();

		String fileName = Datetime.now().format('MM/dd/YYYY HH:mm:ss');
		// System.debug('fileName: ' + fileName);

		for (DocumentParameter docParametr : inputList) {
			PageReference pageRef = new PageReference('/apex/ShipmentsManifest');
			if (String.isNotBlank(docParametr.orderDeliveryMethodID)) {
				pageRef.getParameters().put('id', docParametr.orderDeliveryMethodID);
				zkOrderDeliveryMethodIds.add(docParametr.orderDeliveryMethodID.left(15));

				ContentVersion conVer = new ContentVersion();
				conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
				conVer.PathOnClient = fileName + '.pdf'; // The files name, extension is very important here which will help the file in preview.
				conVer.Title = fileName; // Display name of the files
				conVer.VersionData = Test.isRunningTest() ? Blob.valueOf('test') : pageRef.getContentAsPDF(); // converting your binary string to Blog
				conVers.add(conVer);
			}
		}

		List<zkmulti__MCShipment__c> shipments = [
			SELECT Manifested__c, zkmulti__Mod_Key__c
			FROM zkmulti__MCShipment__c
			WHERE ZK_Order_Delivery_Method__c IN :zkOrderDeliveryMethodIds AND Manifested__c = FALSE
		];

		for (zkmulti__MCShipment__c shipment : shipments) {
			shipment.Manifested__c = true;
			shipment.zkmulti__Mod_Key__c = 'ZKMULTI2016';
		}

		update shipments;

		if (!conVers.isEmpty()) {
			insert conVers;
			List<ContentDocumentLink> conDocLinks = new List<ContentDocumentLink>();

			Map<Id, ContentVersion> conVerMap = new Map<Id, ContentVersion>(
				[SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :conVers]
			);
			for (Integer idx = 0; idx < conVers.size(); idx++) {
				Id cId = conVers.get(idx).Id;
				ContentDocumentLink conDocLink = new ContentDocumentLink();
				conDocLink.LinkedEntityId = inputList.get(idx).orderDeliveryMethodID; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
				conDocLink.ContentDocumentId = conVerMap.get(cId).ContentDocumentId; //ContentDocumentId Id from ContentVersion
				conDocLink.shareType = 'V';
				conDocLink.Visibility = 'AllUsers';
				conDocLinks.add(conDocLink);
			}
			insert conDocLinks;

			System.debug(conDocLinks);
		}
	}

	global class DocumentParameter {
		@InvocableVariable(required=true)
		global String orderDeliveryMethodID;
	}
}