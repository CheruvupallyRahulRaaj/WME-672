({
    isObjectValid: function(obj) {
        if (obj.SOMOrderRequest.ProductRequests.length === 0 ||
            $A.util.isEmpty(obj.SOMOrderRequest.name) ||
            $A.util.isEmpty(obj.SOMOrderRequest.email) === '') {
            return false;
        }
        return true;
    },
    isEmpty: function(obj){
        return obj === undefined || obj === null || (typeof obj === 'string' && obj.trim() === '');
    },
    setAccount: function(cmp) {
        var recordId = cmp.get('v.recordId');
        var sObjectName = cmp.get('v.sObjectName');

        if (!$A.util.isEmpty(sObjectName)) {
            // if the referring 
            if (sObjectName === 'Account') {
                cmp.set('v.accountId', recordId);
            } else {
                var action = cmp.get("c.getAccount");
                action.setParams({
                    "recordId": recordId,
                    "sObjectName": sObjectName
                });
                action.setCallback(this, function(resp) {
                    var state = resp.getState();
        
                    if (state === "SUCCESS") {
                        var acctId = resp.getReturnValue();
                        cmp.set('v.accountId', acctId);
                    } else if (state === "ERROR") {
                        console.error(resp.getError()); 
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },
    processRequest: function(cmp) {
        var json = cmp.get("v.payload");
        if (!this.isObjectValid(json)) {
            return;
        }
        
        var action = cmp.get("c.processRequest");
        cmp.set("v.processing", true);
        action.setParams({
            "json" : JSON.stringify(json)
        });
        action.setCallback(this, function(resp) {
            var state = resp.getState();
            var toastEvent = $A.get("e.force:showToast");

            if (state === "SUCCESS") {
                var navService = cmp.find("navService");
                var resVal = resp.getReturnValue();
                var pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        actionName: 'view',
                        recordId: resVal
                    }
                };
                navService.generateUrl(pageReference)
                    .then($A.getCallback(function(url) {
                        // display successful toast message
                        if (url) {
                            toastEvent.setParams({
                                title: "Success!",
                                message: "The order has been created successfully.",
                                mode : 'sticky',
                                messageTemplate: "Order {0} was created! Feel free to navigate to it {1}!",
                                messageTemplateData: [resVal, {
                                    url: url,
                                    label: resVal,
                                }],
                                type: "success"
                            });
                            
                        } else {
                            toastEvent.setParams({
                                title: "Success!",
                                message: "The order has been created successfully.",
                                type: "success"
                            });
                        }
                        toastEvent.fire();
                        cmp.set("v.processing", false);
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        if (dismissActionPanel) {
                            dismissActionPanel.fire();
                        }
                        
                        var createOrderScreen = cmp.find('createOrderScreen');
                        if (createOrderScreen) {
                            createOrderScreen.resetValues();
                        }
                    }), $A.getCallback(function(error) {
                        
                }));

            } else if (state === "ERROR") {
                // display error toast message
                cmp.set("v.processing", false);
                console.error(resp.getError());
                toastEvent.setParams({
                    title: "Error!",
                    message: resp.getError()[0],
                    type: "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})