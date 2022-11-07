public class ScheduleShipmentConfirmationEmail implements Schedulable {
public void execute(SchedulableContext ctx) {
        ShipmentEmailBatch shipmntBatch = new ShipmentEmailBatch();
        Database.executeBatch(shipmntBatch,25);
    }
}