public class WM_ReevalQueueableFlow implements Queueable,Database.AllowsCallouts {
    private List<OrderDeliveryGroup> ordrDeliveryGroupList;
    private Integer currentIndex;   
    private Integer listSize;   
    public WM_ReevalQueueableFlow(Integer currIndex,Integer lstIndex,List<OrderDeliveryGroup> ordrDelGrpList){
        this.ordrDeliveryGroupList = ordrDelGrpList;
        this.currentIndex = currIndex;
        this.listSize = lstIndex;
    }
    
    public void execute(QueueableContext context) {
        try{
            List<OrderDeliveryGroup> tempList = new List<OrderDeliveryGroup>();
            for(Integer i=currentIndex;i<listSize;i++){
                tempList.add(ordrDeliveryGroupList[i]);
            }
            update tempList;
            
            if(listSize<ordrDeliveryGroupList.size() && ordrDeliveryGroupList.size()<=listSize+50){
                System.enqueueJob(new WM_ReevalQueueableFlow(listSize,ordrDeliveryGroupList.size(),ordrDeliveryGroupList));  
            }   
            else if(listSize<ordrDeliveryGroupList.size() && ordrDeliveryGroupList.size()>listSize+50){
                System.enqueueJob(new WM_ReevalQueueableFlow(listSize,listSize+50,ordrDeliveryGroupList));         
            }
        }
        catch(Exception e){           
            system.debug('Exception occured for the Order Del Grp Id '+ ordrDeliveryGroupList.get(currentIndex).Id + ' '+e);
            if(listSize<ordrDeliveryGroupList.size() && ordrDeliveryGroupList.size()<=listSize+50){
                System.enqueueJob(new WM_ReevalQueueableFlow(listSize,ordrDeliveryGroupList.size(),ordrDeliveryGroupList));  
            }   
            else if(listSize<ordrDeliveryGroupList.size() && ordrDeliveryGroupList.size()>listSize+50){
                System.enqueueJob(new WM_ReevalQueueableFlow(listSize,listSize+50,ordrDeliveryGroupList));         
            }  
        }
        
        
        
    }
}