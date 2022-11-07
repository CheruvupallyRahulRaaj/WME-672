public class PickoutServiceQueueJob implements Queueable,Database.AllowsCallouts{
    Id fulFillmentOrderId = null;
    Integer numberOfRecords = 0;
    public void execute(QueueableContext context){
        if(fulFillmentOrderId==null && numberOfRecords > 0){
            PickoutServiceTemporary a = new PickoutServiceTemporary(numberOfRecords);
            System.enqueueJob(new PickoutServiceQueueJob(numberOfRecords));
        }
        else if(fulFillmentOrderId !=null && numberOfRecords==0){
            PickoutServiceTemporary a = new PickoutServiceTemporary(fulFillmentOrderId);
        }
    }

    public PickoutServiceQueueJob(Integer numberOfRecords){
        this.numberOfRecords = numberOfRecords;
        this.fulFillmentOrderId = null;
    }

    public PickoutServiceQueueJob(Id fulFillmentOrderId){
        this.numberOfRecords = 0;
        this.fulFillmentOrderId = fulFillmentOrderId;

    }
}