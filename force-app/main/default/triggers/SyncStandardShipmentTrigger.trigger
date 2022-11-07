trigger SyncStandardShipmentTrigger on zkmulti__MCShipment__c (before insert,after insert) {
    if(trigger.isInsert) {
       
        List<zkmulti__MCShipment__c> recordsNewList = trigger.new;             // New ZenCraft Shipments
        Map<Id, zkmulti__MCShipment__c> recordsNewMap = trigger.newMap;        // Map new Records              
        
        if(recordsNewList.size() > 0) {
            Map<Id, Shipment> mcShipmentIdToStandardShipmentMap = new Map<Id, Shipment>();    // Map for Standard Shipment Object
            Set<Id> orderSummaryIdSet = new Set<Id>();
            List<FulfillmentOrder> fulfillmentOrdersToUpdate = new List<FulfillmentOrder>();
            
            // Get FulFillment Order Information
            List<zkmulti__MCShipment__c> mcShipmentList = [
                SELECT Id, Fulfillment_Order__c, Fulfillment_Order__r.OrderSummaryId,Fulfillment_Order__r.hazardousMaterial__c, Fulfillment_Order__r.DeliveryMethodId 
                FROM zkmulti__MCShipment__c WHERE Id IN :recordsNewList
            ];
            
            if(mcShipmentList.size() > 0) {                 
                for(zkmulti__MCShipment__c mcShipment : mcShipmentList) {
                    // To Get a DeliverToLatitude and DeliverToLongitude from OrderDeliveryGroupSummary using OrderSummaryId in FulFillment Order
                    orderSummaryIdSet.add(mcShipment.Fulfillment_Order__r.OrderSummaryId);
                }
                 
                Map<Id, OrderDeliveryGroupSummary> orderSummaryIdToOrderDeliveryGroupSummaryMap = new Map<Id, OrderDeliveryGroupSummary>();
                if(orderSummaryIdSet.size() > 0) {
                    Map<Id, OrderDeliveryGroupSummary> orderDeliveryGroupSummaryMap = new Map<Id, OrderDeliveryGroupSummary> ([
                        SELECT OrderSummaryId, DeliverToLatitude, DeliverToLongitude, EmailAddress 
                        FROM OrderDeliveryGroupSummary 
                        WHERE OrderSummaryId IN :orderSummaryIdSet
                    ]);
                     
                    
                    if(orderDeliveryGroupSummaryMap.size() > 0) {
                        for(OrderDeliveryGroupSummary odgs : orderDeliveryGroupSummaryMap.values()) {
                            orderSummaryIdToOrderDeliveryGroupSummaryMap.put(odgs.OrderSummaryId, odgs);
                        }
                    }
                }
                
               // Loop through Zencraft Shipment and create Standard Shipping record
                for(zkmulti__MCShipment__c mcShipment : mcShipmentList) {
                    if(!mcShipment.Fulfillment_Order__r.hazardousMaterial__c){
                        Shipment shipmentRecord = new Shipment();
                        // Assign OrderSummaryId - From Query
                        shipmentRecord.OrderSummaryId = mcShipment.Fulfillment_Order__r.OrderSummaryId;
                        
                        // Assign DeliveryMethodId - From Query
                        shipmentRecord.DeliveryMethodId = mcShipment.Fulfillment_Order__r.DeliveryMethodId;
                        
                        // Assign ShipToLatitude and ShipToLongitude
                        if(orderSummaryIdToOrderDeliveryGroupSummaryMap.size() > 0 && orderSummaryIdToOrderDeliveryGroupSummaryMap.containsKey(shipmentRecord.OrderSummaryId)) {
                            OrderDeliveryGroupSummary odgRecord = orderSummaryIdToOrderDeliveryGroupSummaryMap.get(shipmentRecord.OrderSummaryId);
                            shipmentRecord.ShipToLatitude = odgRecord.DeliverToLatitude;
                            shipmentRecord.ShipToLongitude = odgRecord.DeliverToLongitude;
                        
                            // We do not have a value to lookup DeliverToId, unless it's an employee with Salesforce credentials 
                        // shipmentRecord.DeliveredToId = odgRecord.something
                        }
                        // Get the updated ZenCraft shipment record to assign a values in standard shipment record
                        zkmulti__MCShipment__c newMCShipment = recordsNewMap.get(mcShipment.Id);       
                        // Assign Direct Related Mapping from Zencraft Shipment to Standard Shipment - From New Trigger Record
                        shipmentRecord.External_Id__c = newMCShipment.Id;
                        shipmentRecord.ZShipment__c = newMCShipment.Id;                                       
                        shipmentRecord.FulfillmentOrderId = newMCShipment.Fulfillment_Order__c;
                        shipmentRecord.OwnerId = newMCShipment.OwnerId;
                        shipmentRecord.Description = newMCShipment.Name;
                        shipmentRecord.ShipToName = newMCShipment.zkmulti__Recipient_Name__c;
                        shipmentRecord.ShipFromCity = newMCShipment.zkmulti__Sender_City__c;
                        shipmentRecord.ShipFromCountry = newMCShipment.zkmulti__Sender_Country__c;
                        shipmentRecord.ShipFromPostalCode = newMCShipment.zkmulti__Sender_Zip_Postal_Code__c;
                        shipmentRecord.ShipFromState = newMCShipment.zkmulti__Sender_State_Province__c;
                        shipmentRecord.ShipFromStreet = newMCShipment.zkmulti__Sender_Street__c;
                        shipmentRecord.shippingDeliveryNotes__c = newMCShipment.zkmulti__DeliveryInstructions__c;
                        shipmentRecord.ShipToCity = newMCShipment.zkmulti__Recipient_City__c;
                        shipmentRecord.ShipToCountry = newMCShipment.zkmulti__Recipient_Country__c;
                        shipmentRecord.ShipToPostalCode = newMCShipment.zkmulti__Recipient_Zip_Postal_Code__c;
                        shipmentRecord.ShipToState = newMCShipment.zkmulti__Recipient_State_Province__c;
                        shipmentRecord.ShipToStreet = newMCShipment.zkmulti__Recipient_Street__c;
                        shipmentRecord.TrackingNumber = newMCShipment.zkmulti__Tracking_Number__c;
                        shipmentRecord.ActualDeliveryDate = newMCShipment.zkmulti__Delivery_Date__c;  
                        shipmentRecord.ExpectedDeliveryDate = newMCShipment.zkmulti__Delivery_Date__c; 
                        shipmentRecord.Provider = newMCShipment.zkmulti__Carrier__c;
                        
                        System.enqueueJob(new WM_SyncStandardShipmentLineInfo(newMCShipment.Id));
                        //System.enqueueJob(new WM_SyncStandardShipmentHazardous(newMCShipment.Id));
                        //this is the future, doesn't work when calling the future for invoice
    //                    WM_SyncStandardShipmentLineInfo.SyncStandardShipmentLineInfo(newMCShipment.Id);
                        
                        // Added Standard Shipment in Map with External Id as a unique key
                        mcShipmentIdToStandardShipmentMap.put(shipmentRecord.External_Id__c, shipmentRecord);
                        
                        
                        FulfillmentOrder fo = new FulfillmentOrder();
                        fo.Id = shipmentRecord.FulfillmentOrderId;
                        fo.Status = 'Pickpack';
                        fulfillmentOrdersToUpdate.add(fo);
                    }
                }
                
                if(mcShipmentIdToStandardShipmentMap.size() > 0 && !Test.isRunningTest()) {                
                    upsert mcShipmentIdToStandardShipmentMap.values() External_Id__c;
                    update fulfillmentOrdersToUpdate;
                }
            }
        }
      
    }

//  get the  custom metadata Records  for  Shipment  Object
 Trigger_Configurations__mdt shipTriggerMDT = Trigger_Configurations__mdt.getInstance('Shipment_Trigger');  
 
if(trigger.isbefore && trigger.isInsert&& shipTriggerMDT.Before_Insert__c){
    SyncStandardShipmentTriggerHandler.beforeInsert(trigger.new);
    
}
      
}