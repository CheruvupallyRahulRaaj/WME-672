({
    showModel: function(component, event, helper) {
       component.set("v.showModal", true);
    },
    showModalforCancel: function(component, event, helper) {
       component.set("v.showModalforCancel", true);
    },
 
   
    hideModel: function(component, event, helper) {
       component.set("v.showModal", false);
       component.set("v.showModalforCancel", false);
    },
    // doInit: function(component, event, helper) {
    //     helper.helperMethod(component, event);
    //  },
    
     onControllerFieldChange : function(component, event, helper){
         debugger;
         alert("OK Alert");
         component.set("v.showCancel", true);
        //  var pickselected = component.find("PicklistId").get("v.value");
        //  var recordId = component.get("v.recordId");
        //  //var fields = event.getParam('fields');
        //  //var country = fields.Status;
        //  console.log('pickselected--->>> ' + pickselected);
        //  console.log('pickselected--->>> ' + recordId);
        //  //alert(pickselected);
        //  var action = component.get("c.getCancelReason");
        //  action.setParams({fulfillmentOrderId : recordId, pickListVal : pickselected });
        //  action.setCallback(this, function(response) {
        //     var state = response.getState();
        //     if (state === "SUCCESS") {
        //         var allValues = response.getReturnValue();
        //        console.log('allValues--->>> ' + JSON.stringify(allValues));
        //         component.set("v.mydata", allValues);
        //         $A.get('e.force:refreshView').fire();
        //         component.set("v.showModal", false);
        //         component.set("v.showModalforCancel", false);
        //      }else {console.log('response value' +response.getReturnValue());
 
        //      }
        //  });
        //  $A.enqueueAction(action);
     }
 })