({
	certificateLookupDetails : function(cmp) {
        
        var action = cmp.get("c.sendCertificateLookupRequest");
        action.setParams({ accID : cmp.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                //alert("From server: " + response.getReturnValue());
				var result = response.getReturnValue();
				console.log('$$Result='+ JSON.stringify(result));
				cmp.set("v.CertificateResMap", result);
                cmp.set("v.isOpen", true);
            }
            else if (state === "INCOMPLETE") {
                // do something
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
    }
})