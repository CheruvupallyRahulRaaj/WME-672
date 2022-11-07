public class ScheduleInvoiceBatch implements Schedulable {
    
    //This is a test comment
    public void execute(SchedulableContext ctx) {
        InvoiceBatchApex invB = new InvoiceBatchApex();
        Database.executeBatch(invB,5);
    }
}