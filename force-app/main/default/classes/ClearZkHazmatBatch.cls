public with sharing class ClearZkHazmatBatch implements Database.Batchable<BatchParameter>, Database.Stateful {
  /*
        Database.executeBatch(new ClearZkHazmatBatch());
    */
  public ClearZkHazmatBatch() {
  }

  public List<BatchParameter> start(Database.BatchableContext bc) {
    List<BatchParameter> params = new List<BatchParameter>();
    params.add(new BatchParameter());
    return params;
  }

  public void execute(Database.BatchableContext BC, List<BatchParameter> scope) {
    List<SObject> records = [SELECT Id FROM zkmulti__DangerousGoodsDetails__c LIMIT 10000];

    if (records == null || records.isEmpty()) {
      records = [SELECT Id FROM zkmulti__HazMatDetails__c LIMIT 10000];
    }

    if (records == null || records.isEmpty()) {
      records = [SELECT Id FROM zkmulti__HazMatCommodity__c LIMIT 10000];
    }

    delete records;
  }

  public void finish(Database.BatchableContext BC) {
    Boolean isContinue = false;
    List<zkmulti__HazMatDetails__c> hzDetails = [SELECT Id FROM zkmulti__HazMatDetails__c LIMIT 1];
    if (!hzDetails.isEmpty()) {
      isContinue = true;
    }

    List<zkmulti__HazMatCommodity__c> hzCommodites = [SELECT Id FROM zkmulti__HazMatCommodity__c LIMIT 1];
    if (!hzCommodites.isEmpty()) {
      isContinue = true;
    }

    List<zkmulti__DangerousGoodsDetails__c> dangerousGoodsDetails = [
      SELECT Id
      FROM zkmulti__DangerousGoodsDetails__c
      LIMIT 1
    ];
    if (!dangerousGoodsDetails.isEmpty()) {
      isContinue = true;
    }

    if (isContinue) {
      Database.executeBatch(new ClearZkHazmatBatch(), 1);
    }
  }

  public class BatchParameter {
  }
}