({
	helperMethod : function(component, event) {
		var recordId = component.get("v.recordId");
      //component.set("v.showModal", true);
      var action = component.get("c.getFulfillment");
        action.setParams({fulfillmentOrderId : recordId});
        action.setCallback(this, function(response) {
           var state = response.getState();
           if (state === "SUCCESS") {
               //var allValues = response.getReturnValue();
               var Fulfillment = response.getReturnValue();
               component.set("v.Status", Fulfillment.Status);
               // Added Fulfillment.FulfilledFromLocation.LocationType condition for 5140
               if(Fulfillment.Status === 'Cancelled' || Fulfillment.Status === 'Fulfilled' || (Fulfillment.FulfilledFromLocation.LocationType==='Warehouse' && Fulfillment.Type==='Drop Ship' && Fulfillment.DeliveryMethod.Description!='Store Truck') ||(Fulfillment.FulfilledFromLocation.LocationType==='Warehouse' && Fulfillment.Type==='Special' && Fulfillment.DeliveryMethod.Description!='Store Truck') ){
                  component.set("v.showCancel", false);
               }
               else{
                  component.set("v.showCancel", true);
               }
               
               // Added Fulfillment.FulfilledFromLocation.LocationType condition for 5140
               if(Fulfillment.Status === 'Cancelled' || Fulfillment.Status === 'Fulfilled' || Fulfillment.Type === 'Store/Hub to Home' || Fulfillment.Status === 'Assigned' || (Fulfillment.FulfilledFromLocation.LocationType==='Warehouse' && Fulfillment.Type==='Drop Ship' && Fulfillment.DeliveryMethod.Description!='Store Truck') ||(Fulfillment.FulfilledFromLocation.LocationType==='Warehouse' && Fulfillment.Type==='Special' && Fulfillment.DeliveryMethod.Description!='Store Truck') || (Fulfillment.FulfillmentOrderShipments=== undefined && !Fulfillment.BOPIS__c)){
                   component.set("v.showPickup", false);
               }
               else if(Fulfillment.Status === 'Pickpack' && Fulfillment.FulfillmentOrderShipments!= undefined && Fulfillment.FulfillmentOrderShipments[0].Status === 'Received'){
                   component.set("v.showPickup", true);
               }
               else if(Fulfillment.Status === 'Pickpack' && Fulfillment.BOPIS__c){
                  component.set("v.showPickup", true);
                }
               else{
                  component.set("v.showPickup", true);
               }
              
              console.log('allValues--->>> ' + JSON.stringify(Fulfillment));
              console.log('allValues--->>> ' + Fulfillment.Status);
              console.log('Bopis=======>'+Fulfillment.BOPIS__c);
              //alert(Fulfillment.BOPIS__c);
              //alert(Fulfillment.FulfillmentOrderShipments);
              //console.log('shipmentStatus' + Fulfillment.FulfillmentOrderShipments[0].Status);
               //component.set("v.mydata", allValues);
               component.set("v.showModal", false);
               component.set("v.showModalforCancel", false);
            }else {console.log('response value' +response.getReturnValue());

            }
        });
        $A.enqueueAction(action);

	}
})