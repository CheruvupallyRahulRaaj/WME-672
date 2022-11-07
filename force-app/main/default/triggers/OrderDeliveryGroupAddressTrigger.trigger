trigger OrderDeliveryGroupAddressTrigger on OrderDeliveryGroup (after insert, after update) {

    system.debug('********Trigger Fired******');
    Set<Id> odgIds = new Set<Id>();
    for (OrderDeliveryGroup odg : Trigger.new) {
        if(!odg.Test_Context__c){
            if (odg.DeliverToLongitude == null || odg.DeliverToLatitude == null ) {
                odgIds.add(odg.id);
            }  
        }
        
    }
    
    if (!odgIds.isEmpty()) {
        LocationCallouts.locationCallout(odgIds);
    }
    
}