/**
 * This class is the adapter for Aurus payment gateway
 * 
 * The adapter forms the Http request, makes the gateway call 
 * and parse the response into the correct type of gatewayResponse
 * 
 * The adapter has only read access to database
 * 
 * The class needs to implement processRequest which gets called from the core service
 */
public class SalesforceAdapter implements commercepayments.PaymentGatewayAdapter,Database.AllowsCallouts {
    
    /**
     * Function to process transaction requests
     * This is the entry point for the Aurus adapter class
     */
    public commercepayments.GatewayResponse processRequest(commercepayments.paymentGatewayContext gatewayContext){
        commercepayments.RequestType requestType;
        system.debug('Entered Salesforce adapter :');
        if(gatewayContext==null) {
           system.debug('gatewayContextvalue '+String.valueOf(gatewayContext));
           return new commercepayments.GatewayErrorResponse('500','Gateway context cannot be null');
        }
        //Get the instance of service based on the request type
        WM_AbstractTransactionService service = TransactionServiceAdapter.getServiceInstance(gatewayContext);
        system.debug('service value:'+service);
        if(service!=null){
          return service.execute();
           
        } else {
            return new commercepayments.GatewayErrorResponse('600','Service not found');
        }
            
    }
}