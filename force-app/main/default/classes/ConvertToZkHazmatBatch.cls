public with sharing class ConvertToZkHazmatBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
  // Database.executeBatch(new ConvertToZkHazmatBatch(), 200);

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator([SELECT SKU_Number__c FROM Hazmat_Proper_Name__c]);
  }

  public void execute(Database.BatchableContext BC, List<Hazmat_Proper_Name__c> scope) {
    // throw new ConvertToZkHazmatException('Required Hazardous Information Missing. Contact Service Desk');
    executeCore(scope);
  }

  /*
        List<Hazmat_Proper_Name__c> scope = [SELECT SKU_Number__c FROM Hazmat_Proper_Name__c WHERE SKU_Number__c = 8846891];
        ConvertToZkHazmatBatch.executeCore(scope);
    */
  public static void executeCore(List<Hazmat_Proper_Name__c> scope) {
    Set<Decimal> skus = new Set<Decimal>();

    List<Decimal> dupSkus = new List<Decimal>();

    for (Hazmat_Proper_Name__c hazmatProperName : scope) {
      if (hazmatProperName.SKU_Number__c != null) {
        if (skus.contains(hazmatProperName.SKU_Number__c)) {
          dupSkus.add(hazmatProperName.SKU_Number__c);
        }
        skus.add(hazmatProperName.SKU_Number__c);
      }
    }

    if (!dupSkus.isEmpty()) {
      throw new ConvertToZkHazmatException('Duplicate SKU in Hazmat Proper Name: ' + String.join(dupSkus, ', '));
    }

    Map<Decimal, Hazmat_Proper_Name__c> hazmatProperNameMap = new Map<Decimal, Hazmat_Proper_Name__c>();
    Map<Decimal, Hazmat_Chemical__c> hazmatChemicalMap = new Map<Decimal, Hazmat_Chemical__c>();
    Map<Decimal, Hazmat_Transportation__c> hazmatTransportationMap = new Map<Decimal, Hazmat_Transportation__c>();
    Map<Decimal, List<Hazmat_Item__c>> hazmatItemsMap = new Map<Decimal, List<Hazmat_Item__c>>();

    for (Hazmat_Proper_Name__c hazmatProperName : [
      SELECT SKU_Number__c, Proper_Name__c
      FROM Hazmat_Proper_Name__c
      WHERE SKU_Number__c IN :skus
    ]) {
      hazmatProperNameMap.put(hazmatProperName.SKU_Number__c, hazmatProperName);
    }

    for (Hazmat_Chemical__c hazmatChemical : [
      SELECT SKU_Number__c
      FROM Hazmat_Chemical__c
      WHERE SKU_Number__c IN :skus
    ]) {
      hazmatChemicalMap.put(hazmatChemical.SKU_Number__c, hazmatChemical);
    }

    for (Hazmat_Transportation__c hazmatTransportation : [
      SELECT SKU_Number__c, UOM_for_Units__c, Packing_Instructions__c
      FROM Hazmat_Transportation__c
      WHERE SKU_Number__c IN :skus AND Carrier_Type__c = 'SPKG'
    ]) {
      if (hazmatTransportationMap.containsKey(hazmatTransportation.SKU_Number__c)) {
        dupSkus.add(hazmatTransportation.SKU_Number__c);
      }
      hazmatTransportationMap.put(hazmatTransportation.SKU_Number__c, hazmatTransportation);
    }

    if (!dupSkus.isEmpty()) {
      throw new ConvertToZkHazmatException(
        'Duplicate SKU in Hazmat Transportation: ' + String.join(dupSkus, ', ')
      );
    }

    for (Hazmat_Item__c hazmatItem : [
      SELECT
        SKU_Number__c,
        Hazard_Class__c,
        Packing_Group__c,
        Quantity__c,
        UOM__c,
        Identification_Number__c,
        ORM_D_Item__c
      FROM Hazmat_Item__c
      WHERE SKU_Number__c IN :skus
    ]) {
      if (!hazmatItemsMap.containsKey(hazmatItem.SKU_Number__c)) {
        hazmatItemsMap.put(hazmatItem.SKU_Number__c, new List<Hazmat_Item__c>());
      }
      hazmatItemsMap.get(hazmatItem.SKU_Number__c).add(hazmatItem);
    }

    List<zkmulti__HazMatDetails__c> newHazMatDetails = new List<zkmulti__HazMatDetails__c>();
    List<zkmulti__HazMatCommodity__c> newHazMatCommodites = new List<zkmulti__HazMatCommodity__c>();
    Map<String, List<zkmulti__HazMatCommodity__c>> newHazMatCommoditeMap = new Map<String, List<zkmulti__HazMatCommodity__c>>();
    List<zkmulti__DangerousGoodsDetails__c> dangerousGoodsDetails = new List<zkmulti__DangerousGoodsDetails__c>();

    String emergencyContactNumber = '8004518346';
    String offeror = '2282';
    String packagingType = 'FIBREBOARD BOX';

    for (Decimal sku : skus) {
      if (hazmatProperNameMap.containsKey(sku)) {
        zkmulti__HazMatDetails__c hazMatDetails = new zkmulti__HazMatDetails__c();
        hazMatDetails.Name =
          hazmatProperNameMap.get(sku).Proper_Name__c +
          ' ' +
          hazmatProperNameMap.get(sku).SKU_Number__c;
        hazMatDetails.zkmulti__EmergencyContactNumber__c = emergencyContactNumber;
        hazMatDetails.zkmulti__Offeror__c = offeror;
        hazMatDetails.zkmulti__PackagingCount__c = 1;
        //hazMatDetails.zkmulti__PackagingCountUnits__c = hazmatTransportationMap.get(sku).UOM_for_Units__c;
        //Commented above line and added nullcheck below *Manohar*
        hazMatDetails.zkmulti__PackagingCountUnits__c =  hazmatTransportationMap.containsKey(sku)? hazmatTransportationMap.get(sku).UOM_for_Units__c:'';

        //hazMatDetails.zkmulti__PackagingInstructionCode__c = String.valueOf(
        //  hazmatTransportationMap.get(sku).Packing_Instructions__c
        //);

        // Commented above line and added nullcheck below *Manohar*
        hazMatDetails.zkmulti__PackagingInstructionCode__c =hazmatTransportationMap.containsKey(sku)? String.valueOf(
          hazmatTransportationMap.get(sku).Packing_Instructions__c):'';

        hazMatDetails.zkmulti__PackagingType__c = packagingType;

        System.debug('sku: ' + sku);
        if (hazmatItemsMap.containsKey(sku)) {
          System.debug('sku: ' + hazmatItemsMap.get(sku).size());

          for (Hazmat_Item__c hazmatItem : hazmatItemsMap.get(sku)) {
            zkmulti__HazMatCommodity__c hazMatCommodity = new zkmulti__HazMatCommodity__c();
            hazMatCommodity.zkmulti__HazardClass__c = hazmatItem.Hazard_Class__c; //HAZARD_CLASS_MAP.get(hazmatItem.Hazard_Class__c);

            hazMatCommodity.Name =
              hazmatProperNameMap.get(sku).Proper_Name__c +
              ' ' +
              hazmatProperNameMap.get(sku).SKU_Number__c;
            hazMatCommodity.zkmulti__ProperShippingName__c = hazmatProperNameMap.get(sku).Proper_Name__c;
            hazMatCommodity.zkmulti__PackingGroup__c = hazmatItem.Packing_Group__c;
            hazMatCommodity.zkmulti__QuantityAmount__c = 1;
            hazMatCommodity.zkmulti__QuantityAmountUnits__c = 'LBS';
            hazMatCommodity.zkmulti__RegulatoryId__c = hazmatItem.Identification_Number__c;

            newHazMatCommodites.add(hazMatCommodity);

            if (!newHazMatCommoditeMap.containsKey(hazMatDetails.Name)) {
              newHazMatCommoditeMap.put(hazMatDetails.Name, new List<zkmulti__HazMatCommodity__c>());
            }
            newHazMatCommoditeMap.get(hazMatDetails.Name).add(hazMatCommodity);

            if (String.isNotBlank(hazmatItem.ORM_D_Item__c) && hazmatItem.ORM_D_Item__c == 'Y') {
              zkmulti__DangerousGoodsDetails__c dg = new zkmulti__DangerousGoodsDetails__c();
              dg.Name =
                hazmatProperNameMap.get(sku).Proper_Name__c +
                ' ' +
                hazmatProperNameMap.get(sku).SKU_Number__c;
              dg.zkmulti__EmergencyContactNumber__c = emergencyContactNumber;
              dg.zkmulti__PackagingCount__c = hazmatItem.Quantity__c;
              dg.zkmulti__PackagingCountUnits__c = 'LBS';
              dangerousGoodsDetails.add(dg);
            }
          }

          hazMatDetails.zkmulti__PackagingCount__c = newHazMatCommoditeMap.get(hazMatDetails.Name).size();
          newHazMatDetails.add(hazMatDetails);
        }
      }
    }

    insert newHazMatCommodites;
    insert newHazMatDetails;
    insert dangerousGoodsDetails;

    Map<String, Id> detNameIdMap = new Map<String, Id>();
    for (zkmulti__HazMatDetails__c newHazMatDetail : newHazMatDetails) {
      detNameIdMap.put(newHazMatDetail.Name, newHazMatDetail.Id);
    }

    Map<Id, List<Id>> detailCommoditeIdMap = new Map<Id, List<Id>>();

    for (String hzDetailName : newHazMatCommoditeMap.keySet()) {
      Id iid = detNameIdMap.get(hzDetailName);
      if (!detailCommoditeIdMap.containsKey(iid)) {
        detailCommoditeIdMap.put(iid, new List<Id>());
      }
      for (zkmulti__HazMatCommodity__c hzCom : newHazMatCommoditeMap.get(hzDetailName)) {
        detailCommoditeIdMap.get(iid).add(hzCom.Id);
      }
    }

    List<zkmulti__HazMatContainer__c> newHazMatContainers = new List<zkmulti__HazMatContainer__c>();
    for (Id hzDetailId : detailCommoditeIdMap.keySet()) {
      // if (newHazMatCommoditeMap.get(hzDetail) != null) {
      for (Id hzComId : detailCommoditeIdMap.get(hzDetailId)) {
        zkmulti__HazMatContainer__c newHazMatContainer = new zkmulti__HazMatContainer__c();
        newHazMatContainer.zkmulti__HazMatCommodity__c = hzComId;
        newHazMatContainer.zkmulti__HazMatDetails__c = hzDetailId;
        System.debug('newHazMatContainer: ' + newHazMatContainer);
        newHazMatContainers.add(newHazMatContainer);
      }
      // }
    }

    insert newHazMatContainers;

    System.debug(dangerousGoodsDetails);
    System.debug(newHazMatCommodites);
    System.debug(newHazMatDetails);
    System.debug(newHazMatContainers);
  }

  Map<String, String> HAZARD_CLASS_MAP = new Map<String, String>{
    '1.4G' => 'Explosives 1.4G',
    '1.4S' => 'Explosives 1.4S',
    '1.5' => 'Blasting Agent',
    '1.6' => 'Explosive',
    '2' => 'UN1950 Ocean',
    '2.1' => 'Flammable Gas',
    '2.2' => 'Non-Flammable Gas',
    '3' => 'Flammable Liquid',
    '4.1' => 'Flammable Solid',
    '4.2' => 'Spontaneously Combustible',
    '4.3' => 'Dangerous When Wet',
    '5.1' => 'Oxidizer',
    '5.2' => 'Organic Peroxide',
    '5.1' => 'Poison',
    '8' => 'Corrosive',
    '9' => 'Class 9'
  };

  public void finish(Database.BatchableContext BC) {
  }

  public class HazMatInfo {
  }

  public class ConvertToZkHazmatException extends Exception {
  }
}