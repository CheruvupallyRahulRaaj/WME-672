({
    onClick : function(component, event, helper) {
        component.set("v.isModalOpen",true);
        var flow = component.find("flowData");
        var inputVariables = [
            {
                name : 'recordId',
                type : 'String',
                value : component.get("v.recordId")
            }
        ];
        flow.startFlow("Chg_SpecialOrderProduct",inputVariables);
    },
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
    closeModalOnFinish : function(component, event, helper) {
        // Set isModalOpen attribute to false  
        if(event.getParam('status') === "FINISHED") {
            component.set("v.isModalOpen", false);
        }
    }
    
})