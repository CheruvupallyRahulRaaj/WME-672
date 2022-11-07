({
	getSpecialOrderData : function(component, event, helper) {
        // Set isModalOpen attribute to false  
        var recordId = component.get("v.recordId");
      //component.set("v.showModal", true);
      var action = component.get("c.getOrderItemSummary");
        action.setParams({orderItemSummaryId : recordId});
        action.setCallback(this, function(response) {
           var state = response.getState();
           if (state === "SUCCESS") {
               //var allValues = response.getReturnValue();
               var orderProductItem = response.getReturnValue();
               component.set("v.Status", orderProductItem.Status);
               // Added Fulfillment.FulfilledFromLocation.LocationType condition for 5140
               if(Fulfillment.ProductCode === 'special-order-name'){
                  component.set("v.showCancel", false);
               }
               else{
                  component.set("v.showCancel", true);
               }
              console.log('allValues--->>> ' + JSON.stringify(Fulfillment));
              console.log('allValues--->>> ' + Fulfillment.Status);
               //component.set("v.mydata", allValues);
                component.set("v.showModalforCancel", false);
            }else {console.log('response value' +response.getReturnValue());

            }
        });
        $A.enqueueAction(action);
    }
})