public class WM_DiscountAddedProcess {
    @InvocableMethod(label = 'Calculate Total Discount Adjustment')
    public static void process(List<Id> CreditMemoIds) {
        for(Id cmId : CreditMemoIds){
            System.debug('AAA: CreditMemoId:' + cmId);
        }
    }
}