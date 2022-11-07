public class ScheduleBackOrderEmail implements Schedulable {
 public void execute(SchedulableContext ctx) {
        EmailService backOrderEmail = new EmailService();
        Database.executeBatch(backOrderEmail,25);
    }
}