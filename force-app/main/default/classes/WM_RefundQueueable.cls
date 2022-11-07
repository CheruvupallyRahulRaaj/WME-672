public class WM_RefundQueueable implements Queueable,Database.AllowsCallouts {

    private  WM_TransactionWrapper wrpRequest;   
   
    public WM_RefundQueueable (WM_TransactionWrapper reqst){
        this.wrpRequest = reqst;
    } 
    
    public void execute(QueueableContext context){
        	System.debug('context:'+context);
            HttpRequest req = new HttpRequest();    
            req =  AurusService.aurusTransaction(this.wrpRequest);
            req.setEndpoint('callout:AurusRefund');
        	req.setTimeout(60000);
           HttpResponse res = null;
           Integer HTTPSUCESSRESPONSECODE = 200;
           Double refundAmount= this.wrpRequest.amt;
           String  opsId = this.wrpRequest.authObject.OrderPaymentSummaryId;
        
            Http http = new Http();
            OrderPaymentSummary orderPaymentSummaryObj = Database.query('SELECT Id, OrderSummaryId ,RefundedAmount__c FROM OrderPaymentSummary WHERE Id =:opsId');
               String  orderSumId = orderPaymentSummaryObj.OrderSummaryId;                
                 System.debug('orderPaymentSummaryObj:'+orderPaymentSummaryObj);
        
            try {
                res = http.send(req);
                system.debug('vdebug:req:'+req);
                system.debug('vdebug:res:'+res);
               System.debug('res.getStatusCode():'+res.getStatusCode());
                if (res.getStatusCode() == HTTPSUCESSRESPONSECODE) {
                    
                    if(orderPaymentSummaryObj!= null){
                        System.debug('orderPaymentSummaryObj.RefundedAmount__c:'+orderPaymentSummaryObj.RefundedAmount__c);
                         // set default value for Refunded Amount _c field
                      if(orderPaymentSummaryObj.RefundedAmount__c == null)
                         orderPaymentSummaryObj.RefundedAmount__c = 0.0;
                        
                     orderPaymentSummaryObj.RefundedAmount__c += refundAmount;
                     Database.update(orderPaymentSummaryObj);
                        
                    }else{
                        ProcessException pe = new ProcessException(AttachedToId= orderSumId, OrderSummaryId= orderSumId, Message= 'Unable to Refund Payment', Description = 'Unable to Refund Payment of'+refundAmount, Category = 'Refund');
                         insert pe;
                    }
                    
                } else {
                 ProcessException pe = new ProcessException(AttachedToId= orderSumId, OrderSummaryId= orderSumId, Message= 'Unable to Refund Payment', Description = 'Unable to Refund Payment of'+refundAmount, Category = 'Refund');
                         insert pe;
                }
            } catch(CalloutException ce) {
                    system.debug('vdebugce::'+ce.getMessage());
                  ProcessException pe = new ProcessException(AttachedToId= orderSumId, OrderSummaryId= orderSumId, Message= 'Unable to Refund Payment', Description = 'Unable to Refund Payment of'+refundAmount, Category = 'Refund');
                         insert pe;
            }
    }
    
}