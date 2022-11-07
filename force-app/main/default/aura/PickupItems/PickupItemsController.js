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
   doInit: function(component, event, helper) {
       helper.helperMethod(component, event);
       var pickselected1 =component.get("v.optionspick"); 
       console.log('optionspick'+pickselected1);
    },
  
   savePickupItemsDetails: function(component, event, helper) {
      debugger;
      component.set("v.showModal", false);
      var recordId = component.get("v.recordId");
        console.log('recordId--->>> ' + recordId);
        //alert(recordId);
        var action = component.get("c.getPickupItems");
        action.setParams({fulfillmentOrderId : recordId});
        action.setCallback(this, function(response) {
           var state = response.getState();
           if (state === "SUCCESS") {
               var allValues = response.getReturnValue();
              console.log('allValues--->>> ' + JSON.stringify(allValues));
               component.set("v.mydata", allValues);
               $A.get('e.force:refreshView').fire();
               component.set("v.showModal", false);
               component.set("v.showModalforCancel", false);
               //window.location.reload();
               helper.helperMethod(component, event);
            }else {console.log('response value' +response.getReturnValue());

            }
        });
        $A.enqueueAction(action);
   },
   
    onControllerFieldChange : function(component, event, helper){
        debugger;
      var pickselected = component.find("PicklistId").get("v.value"); 
      
          var recordId = component.get("v.recordId");
        //var fields = event.getParam('fields');
        //var country = fields.Status;
        console.log('pickselected--->>> ' + pickselected);
        console.log('pickselected--->>> ' + recordId);
        //alert(pickselected);
        // Added  changes  by  Manohar start
        if(pickselected === 'asdfasdfasdfasf'){
           component.set('v.errmsg','Please select Reason for Cancel');
     }
     else{
     // Added  changes  by  Manohar End 
              var action = component.get("c.getCancelReason");
        action.setParams({fulfillmentOrderId : recordId, pickListVal : pickselected });
        action.setCallback(this, function(response) {
           var state = response.getState();
           console.log('state+++++' +state);
           if (state === "SUCCESS") {
               var allValues = response.getReturnValue();
              console.log('allValues--->>> ' + JSON.stringify(allValues));
               component.set("v.mydata", allValues);
               $A.get('e.force:refreshView').fire();
               component.set("v.showModal", false);
               component.set("v.showModalforCancel", false);
            }else {console.log('response value' +response.getReturnValue());

            }
        });
        $A.enqueueAction(action);
     
    } // Added else closed bracket by Manohar
    }
    
    
})