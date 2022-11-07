global class ScheduleSTSReminderEmail implements Schedulable {
  public void execute(SchedulableContext ctx) {
        WM_BatchForSTSEmailReminder eSTSReminderEmail = new WM_BatchForSTSEmailReminder();
        Database.executeBatch(eSTSReminderEmail,25);
    }
}