@isTest
public with sharing class ConvertToZkHazmatTest {
	@TestSetup
	static void iniTestData() {
		// HZPSKU: 100190

		Hazmat_Chemical__c hazmatChemical = new Hazmat_Chemical__c();
		hazmatChemical.Chemical_Name__c = 'ACETONE'; // HZMCHM/HZCTXT --- what ZK Object/Field?
		// hazmatChemical.Sequence_Number__c =
		// hazmatChemical.SKU_Component__c =
		hazmatChemical.SKU_Number__c = 123;
		// hazmatChemical.Transportation_Mode__c =

		Hazmat_Item__c hazmatItem = new Hazmat_Item__c();
		// hazmatItem.Authorization__c =
		hazmatItem.Flash_Point__c = ''; // HZMSKU/HZSFP --- what ZK Object/Field?
		hazmatItem.Flash_Point_UOM__c = ''; // HZMSKU/HZSFPU --- what ZK Object/Field?
		hazmatItem.Hazard_Class__c = '2.1'; // HZMSKU/HZSCLS --- what ZK Object/Field?
		// hazmatItem.Identification_Number__c =
		// hazmatItem.Kit_Flag__c =
		// hazmatItem.Net_Explosive_Quantity__c =
		// hazmatItem.NOS_Flag__c =
		hazmatItem.ORM_D_Item__c = 'Y';
		// hazmatItem.Packing_Group__c =
		// hazmatItem.Quantity__c =
		// hazmatItem.SKU_Component__c =
		hazmatItem.SKU_Number__c = 123;
		// hazmatItem.Subsidiary_Class__c =
		// hazmatItem.UOM__c =

		Hazmat_Proper_Name__c hazmatProperName = new Hazmat_Proper_Name__c();
		hazmatProperName.Proper_Name__c = 'AEROSOLS'; // HZMPSN/HZPTXT --- what ZK Object/Field?
		// hazmatProperName.Sequence_Number__c =
		// hazmatProperName.SKU_Component__c =
		hazmatProperName.SKU_Number__c = 123;
		// hazmatProperName.Transportation_Mode__c =

		Hazmat_Transportation__c hazmatTransportation = new Hazmat_Transportation__c();
		// hazmatTransportation.Additional_Shipping_Fee__c =
		// hazmatTransportation.Carrier_Type__c =
		// hazmatTransportation.Container_Type__c =
		// hazmatTransportation.Hazard_Type__c =
		// hazmatTransportation.Labeling_Instructions__c =
		// hazmatTransportation.Marking_Instructions__c =
		// hazmatTransportation.Maximum_Container_Units__c =
		// hazmatTransportation.Maximum_Container_Volume__c =
		// hazmatTransportation.Packing_Instructions__c =
		// hazmatTransportation.Review_Date__c =
		// hazmatTransportation.Reviewed_By__c =
		hazmatTransportation.SKU_Number__c = 123;
		// hazmatTransportation.Transportation_Reviewed__c =
		// hazmatTransportation.Transportation_Type__c =
		// hazmatTransportation.UOM_for_Units__c =
		// hazmatTransportation.UOM_for_Volume__c =

		insert hazmatProperName;
		insert hazmatTransportation;
		insert hazmatItem;
		insert hazmatChemical;
	}

	static testMethod void testMethod1() {
		Test.startTest();
		Database.executeBatch(new ConvertToZkHazmatBatch(), 200);
		Test.stopTest();
	}

	static testMethod void testMethod2() {
		Test.startTest();
		Database.executeBatch(new ClearZkHazmatBatch());
		Test.stopTest();
	}
}