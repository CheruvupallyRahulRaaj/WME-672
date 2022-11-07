public class SchedulePickoutBatch implements Schedulable {
    
    //This is a test comment
    public void execute(SchedulableContext ctx) {
        PickoutBatch invB = new PickoutBatch();
        Database.executeBatch(invB,5);
    }
}