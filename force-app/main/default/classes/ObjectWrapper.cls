public class ObjectWrapper {

    public Invoice invoiceObj = new Invoice();
    public List<FulFillmentOrder> fulFillmentOrders = new List<FulFillmentOrder>();
    public Account accnt = new Account();
    public List<OrderPaymentSummary> ordrPaySumList = new List<OrderPaymentSummary>();
    public Map<String,Address__c> parentAddressMap = new Map<String,Address__c>();
    public Map<String,AlternativePaymentMethod> mapOfAlternatePayment = new Map<String,AlternativePaymentMethod>();
    public Map<String,CardPaymentMethod> mapOfCardPayment = new Map<String,CardPaymentMethod>();
    public Map<String,DigitalWallet> mapOfDigitalWalletPayment = new Map<String,DigitalWallet>();
    public Map<String,List<e_GiftCard__c>> mapOfGiftCardsWithOrderItemSum = new Map<String,List<e_GiftCard__c>>();
    public List<FulFillmentOrder> listOfFulfillmentOrders = new List<FulFillmentOrder>();
    public Decimal freightTaxAmt = 0;
}