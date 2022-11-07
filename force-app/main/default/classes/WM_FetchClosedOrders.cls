public class WM_FetchClosedOrders {
    public List<OrderSummary> ordSum {set;get;}
    public List<OrderItemSummary> ordItmSum {set;get;}
    public List<CardPaymentMethod> crdPay {set;get;}
    public List<OrderPaymentSummary> ordPaySum {set;get;}
    
    public void fetchOrders(){
        ordSum =[Select Id from OrderSummary where Status='Closed'];
		ordItmSum =[Select Id from OrderItemSummary where Status='Canceled' and OrderSummaryId in: ordSum];
		crdPay =[Select Id from CardPaymentMethod Where CardCategory='CreditCard'];
		ordPaySum =[Select Id from OrderPaymentSummary Where PaymentMethodId in: crdPay and OrderSummaryId in:ordSum];
		

    }

}