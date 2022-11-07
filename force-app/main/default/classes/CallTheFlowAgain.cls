public class CallTheFlowAgain {

    
     @InvocableMethod(label = 'Call Flow Again')
    public static void callSubflow(FlowInput[] inputs) {
        
        for(FlowInput input : inputs) {
            startFlow(
                input.flowApiName,
                input.flowNamespace,
                input.inputVariablesJSON
            );
        }
    }
    
     static void startFlow(String flowApiName, String namespace, String inputVariablesJSON) {
        if(String.isEmpty(namespace)) {
          System.enqueueJob(new WM_CallFlowQueueable(inputVariablesJSON,flowApiName));
        } else {
           System.enqueueJob(new WM_CallFlowQueueable(inputVariablesJSON,flowApiName,namespace));
        }
    }
    
    public class FlowInput {
        @InvocableVariable(label='JSON of Input Variables')
        public String inputVariablesJSON;

        @InvocableVariable(label='Flow API name' description='Make sure the flow is active.')
        public String flowApiName;

        @InvocableVariable(label='Flow Namespace' description='Leave blank if the flow does not have a namespace.')
        public String flowNamespace;
    }

}