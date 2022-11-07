public class WM_CallFlowQueueable implements Queueable,Database.AllowsCallouts {

  private String inputVariablesJSON;
  private String flowApiName;
  private String namespace;
    
     public WM_CallFlowQueueable(String inputJSON, String flowName, String naspace){
        this.inputVariablesJSON = inputJSON;
        this.flowApiName = flowName;
        this.namespace = naspace;
    }
    
      public WM_CallFlowQueueable(String inputJSON, String flowName){
        this.inputVariablesJSON = inputJSON;
        this.flowApiName = flowName;
    }
    
    public void execute(QueueableContext context) {
  Map<String,Object> inputVariablesMap = (Map<String,Object>)JSON.deserializeUntyped(inputVariablesJSON);
        Flow.Interview subflow;
        if(namespace==null) {            
            subflow = Flow.Interview.createInterview(flowApiName, inputVariablesMap);
        } else {
            subflow = Flow.Interview.createInterview(namespace, flowApiName, inputVariablesMap);
        }
        subflow.start();
    }
        
}