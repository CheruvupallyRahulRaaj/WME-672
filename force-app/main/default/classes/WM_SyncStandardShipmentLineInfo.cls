public class WM_SyncStandardShipmentLineInfo implements Queueable {
    String sShipmentId;
    
    @future
    public static void SyncStandardShipmentLineInfo(String sShipmentId) {
    	WM_SyncStandardShipmentLineInfo queueableSync = new WM_SyncStandardShipmentLineInfo(sShipmentId);     
        queueableSync.execute(null);
    }  
    
    public WM_SyncStandardShipmentLineInfo(String shipmentId) {
        this.sShipmentId = shipmentId;
    }
    
    public void execute(QueueableContext context) {
		if(sShipmentId != null ){
            
            List<zkmulti__MCCustoms_Item__c> mcCustomItemList = [SELECT Name, zkmulti__Packed_Quantity__c,Fulfillment_Order_Product__c,
                                                                 Fulfillment_Order_Product__r.FulfillmentOrderLineItemNumber  FROM zkmulti__MCCustoms_Item__c WHERE zkmulti__Shipment__c = :sShipmentId]; 
            if(mcCustomItemList.size() > 0) {
                Integer count = 0;
                String JsonString = '{"LineInfo":[';
                for (zkmulti__MCCustoms_Item__c customlines :mcCustomItemList) {
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
                List<Shipment> stdShipmentList = [SELECT id, ZShipment__c, LineInfo__c, Weight__c FROM Shipment WHERE ZShipment__c = :sShipmentId];                    
                if(stdShipmentList.size() > 0) {
                    For (Shipment s: stdShipmentList) {
                        s.ZShipment__c = sShipmentId;
                        s.LineInfo__c = JsonString;
                    	s.Status = 'Shipped';
                        updateShipment.add(s);
                    } 
                    update  updateShipment;
                    
                }
            }       
            
        }     
    }
}