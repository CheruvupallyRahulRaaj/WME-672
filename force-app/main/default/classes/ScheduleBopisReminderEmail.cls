global class ScheduleBopisReminderEmail implements Schedulable {
  public void execute(SchedulableContext ctx) {
        WM_BatchForBopisEmailReminder eBopisReminderEmail = new WM_BatchForBopisEmailReminder();
        Database.executeBatch(eBopisReminderEmail,25);
    }
}