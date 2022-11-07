public class WM_ReturnOrderEmail {
 @InvocableMethod(label='EmailForReturnOrder')
    public static void emailForReturn(List<Id> ordrSumIds){
        WM_TransactionalEmails.sendEmailForCancelandReturn(ordrSumIds[0],true,false);
    }
}