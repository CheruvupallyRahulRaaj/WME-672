public class ObjectWrapperForCreditMemo {
    
    public CreditMemo creditMemoObj = new CreditMemo();
    public Account accnt = new Account();
    public List<OrderItemSummary> ordrItemSummaryList = new List<OrderItemSummary>();
    public Map<String,OrderItemSummary> mapOfCreditMemoLineWithOrderItemSummary = new Map<String,OrderItemSummary>();
    public List<OrderPaymentSummary> ordrPaySumList = new List<OrderPaymentSummary>();
    public List<AggregateResult> invoiceLineList = new List<AggregateResult>();
    public Map<String,Address__c> parentAddressMap = new Map<String,Address__c>();
    public Map<String,AlternativePaymentMethod> mapOfAlternatePayment = new Map<String,AlternativePaymentMethod>();
    public Map<String,CardPaymentMethod> mapOfCardPayment = new Map<String,CardPaymentMethod>();
    public Map<String,DigitalWallet> mapOfDigitalWalletPayment = new Map<String,DigitalWallet>();
    public Map<String,List<e_GiftCard__c>> mapOfGiftCardsWithOrderItemSum = new Map<String,List<e_GiftCard__c>>();
    public Decimal freightTaxAmt = 0;
    public String giftCardNumber = '';
    
}