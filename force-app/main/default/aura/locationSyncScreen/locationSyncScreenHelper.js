({
    displayToaster: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        toastEvent.fire();
    },
    processSync : function(cmp, payload, syncAndSave) {
        var action = (syncAndSave) ? cmp.get("c.processRequest") : cmp.get("c.processLocationAssignments");
        action.setParams({
            "json" : JSON.stringify(payload)
        });

        action.setCallback(this, function(resp) {
            var state = resp.getState();
            var locationSync = cmp.find("locationSync");
            if (state === "SUCCESS") { 
                var resVal = resp.getReturnValue();
                var locSyn = JSON.parse(resVal);
                locationSync.syncData(locSyn);
                if (locSyn.uploadId===null) {
                    this.displayToaster('Location Sync', 'Location assignments were saved, however an error occurred syncing locations to IAS.', 'warning');
                } else {
                    this.displayToaster('Location Sync', 'Locations have successfully been assigned to their groups.', 'success');
                }
                
            } else {
                console.error(resp.getError());
                this.displayToaster('Error!', 'For more information on the error, please refer to the browser developer console.', 'error');
                locationSync.setProcessing(false);
            }
        });
        $A.enqueueAction(action);
    },
    checkLocationSyncStatus : function(cmp, uploadId) {
        var action = cmp.get("c.processCheckSyncStatus");
        action.setParams({
            "uploadId" : uploadId
        });
        action.setCallback(this, function(resp) {
            var state = resp.getState();
            var locationSync = cmp.find("locationSync");
            if (state === "SUCCESS") { 
                var resVal = resp.getReturnValue();
                if (resVal === true) {
                    this.displayToaster('Location Sync', 'Locations are successfuly queued for syncing.', 'success');
                } else {
                    this.displayToaster('Location Sync', 'Locations are still being processed.', 'warning');
                }
                
            } else {
                console.error(resp.getError());
                this.displayToaster('Error!', 'For more information on the error, please refer to the browser developer console.', 'error');
            }
            locationSync.setProcessing(false);
        });
        $A.enqueueAction(action);
    },
    handleObjectSave : function(cmp, obj) {
        var action;
        if (obj.type === 'LocationGroup') {
            action = cmp.get("c.saveLocationGroup");
            action.setParams({
                "name":obj.name,
                "externalReference":obj.externalReference,
                "isEnabled":obj.isEnabled
            });
        } else {
            action = cmp.get("c.saveLocation");
            action.setParams({
                "type":obj.type,
                "name":obj.name,
                "externalReference":obj.externalReference
            });
        }
        action.setCallback(this, function(resp) {
            var state = resp.getState();
            var locationSync = cmp.find("locationSync");
            var returnValue = null;
            if (state === "SUCCESS") { 
                returnValue = resp.getReturnValue();
                var sobject = obj.type === 'LocationGroup' ? obj.type : 'Location';
                this.displayToaster(sobject, sobject + ' was successfully created.', 'success');
            } else {
                console.error(resp.getError());
                this.displayToaster('Error!', 'For more information on the error, please refer to the browser developer console.', 'error');
            }
            locationSync.closeModal(returnValue);
        });
        $A.enqueueAction(action);
    }
})