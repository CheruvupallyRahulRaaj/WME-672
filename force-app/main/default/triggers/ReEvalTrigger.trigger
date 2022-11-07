trigger ReEvalTrigger on  ReEval_Data__c(after update) {
    Boolean debugMode = WM_SettingHelper.debugMode;

    if(Trigger.isAfter && Trigger.isUpdate){
        if(debugMode){
            for(ReEval_Data__c record : Trigger.new){
                System.debug('AAA: ReevalRecord for Update:' + record.Id + ' ODGID:' + record.OrderDeliveryGroupID__c + ' : IsProcessedNew:' + record.Is_Processed__c + ' :IsProcessedOld:' + Trigger.oldMap.get(record.Id).Is_Processed__c);
            }
        }
        Map<Integer,Set<ID>> processedBatches = new Map<Integer,Set<ID>>();
        for(ReEval_Data__c record : Trigger.new){
            if(debugMode){
                String debugString = String.format('BBB: New Record Processed Record: ReevalID: {0}, ODG ID: {1}, BatchNumber: {2}, IsProcessed: {3}', new List<String>{record.Id, record.OrderDeliveryGroupID__c,String.valueOf(record.BatchNumber__c), String.valueOf(record.Is_Processed__c)});
                System.debug(debugString);
            }
            ReEval_Data__c oldRecord = Trigger.oldMap.get(record.Id);
            if(debugMode){
                string debugString = String.format('BBB: Old Record Processed Record: ReevalID: {0}, ODG ID: {1}, BatchNumber: {2}, IsProcessed: {3}', new List<String>{oldRecord.Id, oldRecord.OrderDeliveryGroupID__c,String.valueOf(oldRecord.BatchNumber__c), String.valueOf(oldRecord.Is_Processed__c)});
                System.debug(debugString);
            }
            if(oldRecord.Is_Processed__c == FALSE && record.Is_Processed__c == TRUE){
                if(!processedBatches.containsKey(Integer.valueOf(record.BatchNumber__c))){
                    processedBatches.put(Integer.valueOf(record.BatchNumber__c), new Set<ID>());
                }
                processedBatches.get(Integer.valueOf(record.BatchNumber__c)).add(record.OrderDeliveryGroupID__c);
            }
        }
        if(processedBatches.size()==0) return;
        //get the Greatest BatchNumber
        List<Integer> lstBatchNumbers = new List<Integer>(processedBatches.keySet());
        lstBatchNumbers.sort();
        Integer lastBatch = lstBatchNumbers[lstBatchNumbers.size()-1];

        //Now Check if there are any records in the ReEvalDAta which are not yet processed
        List<ReEval_Data__c> lstExistingData = [Select Id From ReEval_Data__c WHERE Is_Processed__c = FALSE AND BatchNumber__c = :lastBatch FOR UPDATE];
        if(debugMode){
            System.debug('AAA: Yet To Process:' + lstExistingData.size());
        }
        if(lstExistingData.size()==0){
            if(debugMode){
                System.debug('AAA: Nothing To Process:');
            }
            //Now Get Data to be processed
            try{
                Map<ID,CronTrigger> mapCronTrigger = new Map<Id,CronTrigger>([SELECT ID FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Reeval Check%'  AND State = 'WAITING']);
                for(Id cronId : mapCronTrigger.keyset()){
                    System.abortJob(cronId);
                }
            }
            catch(Exception ex){
                if(debugMode){
                    System.debug('Job Already aborted or does not exist');
                }
            }
            Integer newBatch = lastBatch + 1;
            List<Id> lstOrderDeliveryGroupIds = new List<Id>();
            List<ReEval_Data__c> lstData = [Select Id,OrderDeliveryGroupID__c From ReEval_Data__c WHERE Is_Processed__c = FALSE AND BatchNumber__c = :newBatch];
            for(ReEval_Data__c record : lstData){
                lstOrderDeliveryGroupIds.add(record.OrderDeliveryGroupID__c);
            }
            if(lstOrderDeliveryGroupIds.size()>0){
                Id jobId = System.enqueueJob(new WM_ReevalQueueableFlowV2(lstOrderDeliveryGroupIds));

                if(debugMode){
                    System.debug('BBB: New Job ID: ' + jobId);
                }
            }
        }
    }
}