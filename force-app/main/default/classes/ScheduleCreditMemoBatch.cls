public class ScheduleCreditMemoBatch implements Schedulable {

    public void execute(SchedulableContext ctx) {
        CreditMemoBatchApex invB = new CreditMemoBatchApex();
        Database.executeBatch(invB,5);
    }
}