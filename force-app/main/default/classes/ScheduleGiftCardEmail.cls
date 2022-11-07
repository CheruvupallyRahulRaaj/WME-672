global class ScheduleGiftCardEmail implements Schedulable {
  public void execute(SchedulableContext ctx) {
        PostGiftCardService eGfEmail = new PostGiftCardService();
        Database.executeBatch(eGfEmail,25);
    }
}