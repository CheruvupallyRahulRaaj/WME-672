({
    doInit: function(component) {
        component.set("v.getObjectName", component.get('v.sObjectName'));
        component.set("v.getRecordId", component.get('v.recordId'));
    },
    
    afterScriptsLoaded : function(component, event, helper) {
        console.warn('loaded');
        var objectName = component.get('v.sObjectName');
        var recordId = component.get('v.recordId');
        console.log('$$$sObjectName= '+ objectName);
        console.log('$$$recordId= ' + recordId);
        var actionGetSession;
        var actionGetStorefront;
        var actionGetOOBOURL;
        var actionGetOOBOPROURL;

        actionGetOOBOURL = component.get("c.getOOBOURL");
        actionGetOOBOURL.setCallback(this, function (response) {
            if(component.isValid() && response.getState() === 'SUCCESS') {
                component.set("v.OOBOUrl", response.getReturnValue());
            }
        });
        $A.enqueueAction(actionGetOOBOURL);

        actionGetOOBOPROURL = component.get("c.getProOOBOURL");
        actionGetOOBOPROURL.setCallback(this, function (response) {
            if(component.isValid() && response.getState() === 'SUCCESS') {
                component.set("v.OOBOProUrl", response.getReturnValue());
            }
        });
        $A.enqueueAction(actionGetOOBOPROURL);
        
        if (objectName == 'Account') { //Person Account
            actionGetSession = component.get("c.getStoreSessionURL");
        } else if (objectName == 'Contact') { //Contact
            console.warn('Contact URL');
            actionGetSession = component.get("c.getProStoreSessionURL");
        }
            else if (objectName == 'OrderSummary') { //OrderSummary Retail
                //TODO: set the replace order URL
                actionGetSession = component.get("c.getOrderSummaryURL");
                actionGetSession.setParams({ recordId : component.get('v.recordId')});
            }
        
        actionGetSession.setCallback(this, function (response) {
            if(component.isValid() && response.getState() === 'SUCCESS') {
                component.set("v.storeSessionURL", response.getReturnValue());
            }
        });
        $A.enqueueAction(actionGetSession);
        
        if (objectName == 'OrderSummary') { //OrderSummary Pro
            //TODO: set the replace order URL
            actionGetStorefront = component.get("c.getOrderSummaryStoreFrontURL");
            actionGetStorefront.setParams({ recordId : component.get('v.recordId')});
        } else if (objectName == 'Account') { //Person Account
            actionGetStorefront = component.get("c.getStoreFrontURL");
        } else if (objectName == 'Contact') { //Contact
            actionGetStorefront = component.get("c.getProStoreFrontURL");
        } 
        
        actionGetStorefront.setCallback(this, function (response) {
            if(component.isValid() && response.getState() === 'SUCCESS') {
                console.log('storefronturl =>',response.getReturnValue());
                component.set("v.storeFrontURL", response.getReturnValue());
            }
        });
        component.set("v.objectName", objectName);
        $A.enqueueAction(actionGetStorefront);        
    },
    
    openShoppingCart : function(component, event, helper) {
        component.set("v.Spinner", true); 
        var sessionURL;
        var storefrontURL;
        var recordId = component.get('v.recordId');  
        var objectName = component.get('v.sObjectName');
        var sessionURL = component.get('v.storeSessionURL');
        
        var action2 = component.get('c.getSFCCCustomerId');
        action2.setParams({recordId: recordId, objectName: objectName});
        action2.setCallback(this, function (response) {
            if(response.getState() === 'SUCCESS'){
                if(response.getReturnValue()==null){
                    
                    var ooboURL = '';
                    if (objectName == 'Account') { //Person Account
                        ooboURL = component.get('v.OOBOUrl');
                    }
                    else if (objectNamej == 'Contact'){
                        ooboURL = component.get('v.OOBOProUrl');
                    }
                    var res = ooboURL;
                    component.set('v.storeFrontURL',res);
                    var storefrontURL = component.get('v.storeFrontURL');  
                }
                else{
                     var storefrontURL = component.get('v.storeFrontURL');  
                }
                        console.log('$$$objectName= '+objectName);
        console.log('$$$sessionURL= '+sessionURL);
        console.log('$$$storefrontURL= ' + storefrontURL); 
        var action = component.get('c.getAccessToken');
        action.setParams({recordId: recordId, objectName: objectName});
        action.setCallback(this, function (response) {
            console.log('========');
            var token = response.getReturnValue();
            if (component.isValid() && response.getState() === 'SUCCESS' && sessionURL && storefrontURL) {
                console.log('loading...');
                console.warn('Token Value ' + token);
                var $j = jQuery.noConflict();
                $j.ajax({
                    type: 'POST',
                    url: sessionURL,
                    headers: {
                        'Authorization': token,
                    },
                    dataType: 'json',
                    data: {},
                    xhrFields: {
                        withCredentials: true
                    },
                    success: function(responseData, status, xhr) {
                        // Open the storefront URL in a new window
                        component.set("v.Spinner", false);
                        window.open(storefrontURL); 
                    },
                    error: function(request, status, error) {
                        component.set("v.Spinner", false);
                        alert('Cannot Load Storefront, Please Contact Administrator');
                    }
                });                    
            }else {
                console.log('else..loading.stop');
                component.set("v.Spinner", false);
                console.error(response);
            }
        });
        $A.enqueueAction(action);
                
            }
            else {
             
                console.log('else..loading.stop');
                component.set("v.Spinner", false);
                console.error(response);
            }
            
        });
        $A.enqueueAction(action2);

        //var sessionURL = false;
        //var storefrontURL =  false;

    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }    
})