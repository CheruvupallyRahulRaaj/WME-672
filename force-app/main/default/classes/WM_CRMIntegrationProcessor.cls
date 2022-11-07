public class WM_CRMIntegrationProcessor  {
    public static final Decimal divider = 50;
    public static void handlingTheChunkSizeLogic(List<Id> sObjectIds,String actnType){
        
        Decimal result = (Decimal)(sObjectIds.size()/divider);
        Integer numberOfChunks = (Integer)result.round(System.RoundingMode.CEILING);
        system.debug('numberOfChunks '+numberOfChunks);
        List<List<Id>> listOfChunks = new List<List<Id>>();
        for(Integer i=1;i<=numberOfChunks;i++){
            if(i!=numberOfChunks){
                system.debug('entered if');
                List<Id> sObjectIdsPerChunk = new List<Id>();
                for(Integer j=(i-1)*50;j<i*50;i++){
                    sObjectIdsPerChunk.add(sObjectIds[j]);
                }
                listOfChunks.add(sObjectIdsPerChunk);
            }
            else{
                system.debug('entered else');
                List<Id> sObjectIdsPerChunk = new List<Id>();
                for(Integer j=(i-1)*50;j<sObjectIds.size();j++){
                    sObjectIdsPerChunk.add(sObjectIds[j]);
                }
                listOfChunks.add(sObjectIdsPerChunk);  
            }
        }
        // At max -> size of listOfChunks can be 50 with this approach
        for(List<Id> chunk : listOfChunks){
            system.debug('Chunk '+chunk);
            System.debug('Limits Get Queuable Jobs' + Limits.getQueueableJobs());
            if( Limits.getQueueableJobs() == 0) {      
                System.debug('Sending ActionType:' + actnType);
                System.enqueueJob(new WM_CRMIntegrationQueueable(chunk,actnType,0));
            }
        }
        
    }
    
}