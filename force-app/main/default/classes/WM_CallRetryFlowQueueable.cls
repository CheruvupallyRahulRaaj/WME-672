public class WM_CallRetryFlowQueueable implements Queueable,Database.AllowsCallouts {

    private List<String> shipmentIdsToProcess;
    private String flowApiName;
    private Integer i;
    
    public WM_CallRetryFlowQueueable(String flowName,List<String> shipmentIds, Integer currentIndex){
     this.shipmentIdsToProcess = shipmentIds;
     this.flowApiName = flowName;
     this.i = currentIndex;
    }
    
    public void execute(QueueableContext context) {
                 String inputVariablesJSON = '{"ShipmentId" :"'+shipmentIdsToProcess[i]+'"}';
        Map<String,Object> inputVariablesMap = (Map<String,Object>)JSON.deserializeUntyped(inputVariablesJSON);
        Flow.Interview subflow;
         subflow = Flow.Interview.createInterview(flowApiName, inputVariablesMap);
        subflow.start();
        if(i<shipmentIdsToProcess.size()){
             System.enqueueJob(new WM_CallRetryFlowQueueable(flowApiName,shipmentIdsToProcess,i+1));
        }
        
    }

}