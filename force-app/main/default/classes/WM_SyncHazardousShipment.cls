public class WM_SyncHazardousShipment {
    @AuraEnabled
    public static void createHazardousShipments(Id fulfillmentOrderId){
        List<zkmulti__MCShipment__c> mcShipmentList = [SELECT Id FROM zkmulti__MCShipment__c WHERE  Fulfillment_Order__c =:fulfillmentOrderId];
        Set<Id> shipmentIds = new Set<Id>();
        List<FulfillmentOrder> fulfillmentOrdersToUpdate = new List<FulfillmentOrder>();
        for(zkmulti__MCShipment__c shp : mcShipmentList){
            shipmentIds.add(shp.Id);
        }
        List<zkmulti__MCCustoms_Item__c> mcCustomItemList = [SELECT Name, zkmulti__Packed_Quantity__c,Fulfillment_Order_Product__c,
                                                                 Fulfillment_Order_Product__r.FulfillmentOrderLineItemNumber  FROM zkmulti__MCCustoms_Item__c WHERE zkmulti__Shipment__c IN:shipmentIds]; 
        
        if(mcCustomItemList.size() > 0) {
            Integer count = 0;
            String JsonString = '{"LineInfo":[';
            for (zkmulti__MCCustoms_Item__c customlines :mcCustomItemList) {
                System.debug('customlines 12 =>'+customlines.Fulfillment_Order_Product__r);
                System.debug('customlines =>'+customlines.Fulfillment_Order_Product__r.FulfillmentOrderLineItemNumber);
                count += 1;   
                if(count > 1) {
                    JsonString += ',';
                }
                String sqty =  String.Valueof(customlines.zkmulti__Packed_Quantity__c) ;
                JsonString += '{"carton_line_nbr":' +WM_Utils.getInteger(customlines.Fulfillment_Order_Product__r.FulfillmentOrderLineItemNumber) + ',"pick_line_nbr":' + WM_Utils.getInteger(customlines.Fulfillment_Order_Product__r.FulfillmentOrderLineItemNumber) + ',"qty_packed":' +  sqty  + ',"qty_shipped":' +  sqty  + '}';  
            }
            JsonString += ']}';
            System.debug('*****************' +JsonString);   

            // Get Weight and Declared Value from Package Record
            List<Shipment> updateShipment = new List<Shipment>();
            List<Shipment> insertShipment = new List<Shipment>();
            List<Shipment> stdShipmentList = [SELECT id, ZShipment__c, LineInfo__c, Weight__c FROM Shipment WHERE ZShipment__c  IN:shipmentIds];                    
            if(stdShipmentList.size() > 0) {
                For (Shipment s: stdShipmentList) {
                    s.ZShipment__c = s.ZShipment__c;
                    s.LineInfo__c = JsonString;
                    s.Status = 'Shipped';
                    updateShipment.add(s);
                } 
                FulfillmentOrder fo = new FulfillmentOrder();
                fo.Id = fulfillmentOrderId;
                fo.Status = 'Pickpack';
                fulfillmentOrdersToUpdate.add(fo);
                update  updateShipment;
                
            }else{
                Shipment s = new Shipment();
                s.LineInfo__c = JsonString;
                s.ShipToName = 'Shipment';
                s.FulfillmentOrderId = fulfillmentOrderId;
                s.Status = 'Shipped';
                insertShipment.add(s);
                insert insertShipment;
                FulfillmentOrder fo = new FulfillmentOrder();
                fo.Id = fulfillmentOrderId;
                fo.Status = 'Pickpack';
                fulfillmentOrdersToUpdate.add(fo);
            }
            if(fulfillmentOrdersToUpdate.size() > 0){
                update fulfillmentOrdersToUpdate;
            }
        }
    }
}