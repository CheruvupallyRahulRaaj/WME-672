({
	doInit : function(cmp, event, helper) {
        var action = cmp.get("c.checkForcertificateLookupNumber");
        action.setParams({ accID : cmp.get("v.recordId") });
        console.log("v.recordID",cmp.get("v.recordId"));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.showButton",response.getReturnValue());
                }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
		
	},
   openTab : function(component, event, helper) {
        helper.certificateLookupDetails( component );
    },
    closeModel: function(component, event, helper) {
         
        component.set("v.isOpen", false);
    },
})