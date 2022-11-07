public class WM_CallCancelDisItemsFlowQueueable implements Queueable,Database.AllowsCallouts {

    private List<Id> OPSIdsToProcess;
    private String flowApiName;
    private Integer i;
    
    public WM_CallCancelDisItemsFlowQueueable(String flowName,List<String> OPSIds, Integer currentIndex){
     this.OPSIdsToProcess = OPSIds;
     this.flowApiName = flowName;
     this.i = currentIndex; //Need to check the usage.
    }
    
    public void execute(QueueableContext context) {
        //String inputVariablesJSON = '{"ZeroOISIds" :"'+OPSIdsToProcess[i]+'"}';
        //Map<String,Object> inputVariablesMap = (Map<String,Object>)JSON.deserializeUntyped(inputVariablesJSON);
        //System.debug('Input Variables Map :: ' +inputVariablesMap);
        Map<String,List<Id>> inputVariablesMap = new Map<String, List<Id>>();
        inputVariablesMap.put('ZeroOISIds' , OPSIdsToProcess);
        System.debug('Input Variables Map :: ' +inputVariablesMap);
        Flow.Interview subflow;
        subflow = Flow.Interview.createInterview(flowApiName, inputVariablesMap);
        subflow.start();
        System.debug('Flow is invoked :: ' +subflow);
   //     if(i<OPSIdsToProcess.size()){
     //       System.debug('Enqueue Job Again since size is > 0');
       //      System.enqueueJob(new WM_CallCancelDisItemsFlowQueueable(flowApiName,OPSIdsToProcess,i+1));
        //}
        
    }

}