/**
 * The class to get the instance of a service based on the request type
 * 
 * The class stores the instance of each service statically to implement singleton pattern
 */ 
public class TransactionServiceAdapter {
    //private Attribute to implement singleton pattern for all service classes
    private static  WM_AuthorizationTransactionService  authTxnService;
    private static  WM_CaptureTransactionService  captureTxnService;
    private static  WM_RefundTransactionService  refRefundTxnService;
    
    /**
     * Static method that returns the instance of a service based on the request type
     */ 
    public static WM_AbstractTransactionService getServiceInstance(commercepayments.paymentGatewayContext gatewayContext){
        commercepayments.RequestType requestType;
        requestType= gatewayContext.getPaymentRequestType();
        //Authorization Service
        if (requestType == commercepayments.RequestType.Authorize) {
            if(authTxnService ==null )
            {
                 authTxnService = new WM_AuthorizationTransactionService(gatewayContext);
            }
            return  authTxnService;
        }
        //Capture Service
        else if ( requestType == commercepayments.RequestType.Capture) {
            if(captureTxnService ==null )
            {
                 captureTxnService = new WM_CaptureTransactionService(gatewayContext);
            }
            return  captureTxnService;
        }
        //Referenced Refund Service
        else if ( requestType == commercepayments.RequestType.ReferencedRefund) {
            if(refRefundTxnService ==null )
            {
                 refRefundTxnService = new WM_RefundTransactionService(gatewayContext);
            }
            return  refRefundTxnService;
        }
        // Add new transaction services here
        else {
            return null;
        }
    }
}