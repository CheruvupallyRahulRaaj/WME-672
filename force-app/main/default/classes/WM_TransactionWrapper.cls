/**
* @description       : 
* @author            : schauhan@liveareacx.com
* @group             : 
* @last modified on  : 01-12-2021
* @last modified by  : schauhan@liveareacx.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   01-12-2021   schauhan@liveareacx.com   Initial Version
**/
public class WM_TransactionWrapper {
    public Account acc {get; set;}
    public Double amt {get; set;}
    public String transactionType {get; set;}
    public PaymentAuthorization authObject {get; set;}
    public CardPaymentMethod cpm  {get; set;}
    public DigitalWallet dw  {get; set;}
    public List<OrderItemSummary> orderItemSum {get; set;}
    public List<OrderItem> orderProduct {get; set;}
    public List<OrderDeliveryGroup> orderDelGrp {get; set;}
    public List<Product2> prod {get; set;}
    public Integer  seqCount {get; set;}
    public Payment paymentObj {get; set;}
    public Integer countOfOrderItem {get; set;}
    public String channelName {get; set;}
    public String invoiceCreditNumber {get; set;}
    
    
    // This is the contructor method. 
    public WM_TransactionWrapper(Account a,Double am, String transType, PaymentAuthorization pA, CardPaymentMethod cp,List<OrderItemSummary> oisList,
                                 List<OrderItem> opList,List<OrderDeliveryGroup> odgList,List<Product2> prdList,Integer iC,Payment pObj, Integer count, String sName)
    {
        acc = a;
        amt = am;
        transactionType = transType;
        authObject = pA;
        cpm = cp;
        orderItemSum = oisList;
        orderProduct = opList;
        orderDelGrp = odgList;
        prod = prdList;
        seqCount = iC;
        paymentObj = pObj;
        countOfOrderItem = count;
        channelName = sName;
        
    }

    public WM_TransactionWrapper(Account a,Double am, String transType, PaymentAuthorization pA, DigitalWallet cp,List<OrderItemSummary> oisList,
                                 List<OrderItem> opList,List<OrderDeliveryGroup> odgList,List<Product2> prdList,Integer iC,Payment pObj, Integer count, String sName)
    {
        acc = a;
        amt = am;
        transactionType = transType;
        authObject = pA;
        dw = cp;
        orderItemSum = oisList;
        orderProduct = opList;
        orderDelGrp = odgList;
        prod = prdList;
        seqCount = iC;
        paymentObj = pObj;
        countOfOrderItem = count;
        channelName = sName;
        
    }
    
    public WM_TransactionWrapper(Account a,Double am, String transType,CardPaymentMethod cp){
        acc = a;
        amt = am;
        transactionType = transType;
        cpm = cp;
    }

    public WM_TransactionWrapper(Account a,Double am, String transType,DigitalWallet cp){
        acc = a;
        amt = am;
        transactionType = transType;
        dw = cp;
    }
    
    
}