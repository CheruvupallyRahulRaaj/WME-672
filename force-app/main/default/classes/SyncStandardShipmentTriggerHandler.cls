public with sharing class SyncStandardShipmentTriggerHandler {
   
   public static void beforeInsert(list<zkmulti__MCShipment__c>ShippmentList){

    set<id>fullFillorderSet = new set<id>();
    for(zkmulti__MCShipment__c ship:ShippmentList){
        if(string.isNotBlank(ship.Fulfillment_Order__c)){
            fullFillorderSet.add(ship.Fulfillment_Order__c);
        }
    }

   
    Map<Id, FulfillmentOrder> masterMap = new Map<Id, FulfillmentOrder>([select  id,Status  from  FulfillmentOrder  where id in :fullFillorderSet  and Status!='Packing']);
            for(zkmulti__MCShipment__c sp:ShippmentList){
                   if(masterMap.containsKey(sp.Fulfillment_Order__c)){
                    sp.addError(system.label.Shipment_New_Record_Error);
                   }

            }
   } 
}