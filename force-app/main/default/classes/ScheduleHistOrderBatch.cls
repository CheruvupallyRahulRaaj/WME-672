public class ScheduleHistOrderBatch implements Schedulable {

    public void execute(SchedulableContext ctx) {
        SOMBatchHistMgdOrders obj = new SOMBatchHistMgdOrders();
        Database.executeBatch(obj,100);
    }
}