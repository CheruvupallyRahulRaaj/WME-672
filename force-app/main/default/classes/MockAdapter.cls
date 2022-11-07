/**
* This class is the adapter for Mock payment gateway for Alternate Payment Methods
* e
* 
* The adapter has only read access to database
* 
* The class needs to implement processRequest which gets called from the core service
*/
public class MockAdapter implements commercepayments.PaymentGatewayAdapter {
    
    /**
* Function to process transaction requests
* This is the entry point for the Aurus adapter class
*/
    public commercepayments.GatewayResponse processRequest(commercepayments.paymentGatewayContext gatewayContext){
      commercepayments.RequestType requestType;
        if(gatewayContext==null) {
            return new commercepayments.GatewayErrorResponse('400','Gateway context cannot be null');
        }
        requestType= gatewayContext.getPaymentRequestType();
        if ( requestType == commercepayments.RequestType.Capture) {
            commercepayments.CaptureRequest captureRequest =  (commercepayments.CaptureRequest) gatewayContext.getPaymentRequest();
            commercepayments.CaptureResponse captureResponse = new commercepayments.CaptureResponse();
            captureResponse.setSalesforceResultCodeInfo(new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Success));
            captureResponse.setAmount(captureRequest.amount);
            captureResponse.setGatewayDate(System.now());
            system.debug('Mock Service');
            return captureResponse;
            
        } 

        else {
            return new commercepayments.GatewayErrorResponse('400','Service not found');
        }
        
       
    }
}