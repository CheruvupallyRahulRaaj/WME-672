({
	hazardousShipment : function(component, event) {
		console.log('record Id =>'+ component.get('v.recordId'));
        var action = component.get("c.createHazardousShipments");
        action.setParams({ "fulfillmentOrderId" : component.get('v.recordId') });
        action.setCallback(this, function(response){
            var state =response.getState();
            if(state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Shipment created successfully!',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                console.log("Success with state: " + state);
            }else{
                console.log("Failed with state: " + state);
                toastEvent.setParams({
                    title : 'Error',
                    message: 'Error Occurred!',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
	}
})