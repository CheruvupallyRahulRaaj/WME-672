/**
 * @description       : 
 * @author            : schauhan@liveareacx.com
 * @group             : 
 * @last modified on  : 01-14-2021
 * @last modified by  : schauhan@liveareacx.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   01-08-2021   schauhan@liveareacx.com   Initial Version
**/
public class WM_AuthorizationTransactionService extends WM_AbstractTransactionService{

    
    protected commercepayments.AuthorizationRequest authRequest;
    
    
    public WM_AuthorizationTransactionService(commercepayments.paymentGatewayContext gatewayContext){
        super(gatewayContext);
            this.authRequest = (commercepayments.AuthorizationRequest)gatewayContext.getPaymentRequest();
    }
    

    
    public override HttpRequest buildRequest(){
        HttpRequest req = new HttpRequest();
        commercepayments.CardPaymentMethodRequest  cmpReqObj = (commercepayments.CardPaymentMethodRequest)authRequest.paymentMethod.cardPaymentMethod; 
        Account accObject = WM_TransactionHelper.getAccountObject(authRequest.accountId); 
        String transType = WMConstants.AuthorizationTransactionType;
        CardPaymentMethod cpm = (CardPaymentMethod)WM_TransactionHelper.getCardPaymentMethodWithAccountId(authRequest.accountId);
        //DigitalWallet dw = (DigitalWallet)WM_TransactionHelper.getDigitalWalletWithAccountId(authRequest.accountId);
        //WM_TransactionWrapper wrp = new WM_TransactionWrapper(accObject,authRequest.amount,transType,cpm);
        DigitalWallet dw = NULL;
        WM_TransactionWrapper wrp = NULL;
        if(cpm == NULL) {
            dw = (DigitalWallet)WM_TransactionHelper.getDigitalWalletWithAccountId(authRequest.accountId);
            wrp = new WM_TransactionWrapper(accObject,authRequest.amount,transType,dw);
        } else {
            wrp = new WM_TransactionWrapper(accObject,authRequest.amount,transType,cpm);
        }
        req =  AurusService.aurusTransaction(wrp);
        return req;
    }
    
    public override commercepayments.GatewayResponse buildResponse(HttpResponse response) {
        commercepayments.AuthorizationResponse authResponse = new commercepayments.AuthorizationResponse();
        commercepayments.PaymentMethodTokenizationResponse paymentMethodTokenizationResponse = new commercepayments.PaymentMethodTokenizationResponse();
        String salesforceResultCode = null;
        String statusCode = String.valueOf(response.getStatusCode());
        String authorizationCode='';
        String responseCode='';
        String responseText = '';
        String transactionId='';
        Integer totalAmount = 0;
        
        /*JSONParser parser = JSON.createParser(response.getBody());
        while(parser.nextToken()!=null){
            if(parser.getText()=='authorizationCode'){
                parser.nextToken();
                authorizationCode = parser.getText();
                system.debug('authorizationCode:'+authorizationCode);
            }
            else if(parser.getText()=='responseCode'){
                parser.nextToken();
                responseCode = parser.getText();
                system.debug('responseCode:'+responseCode);
            }
            else if(parser.getText()=='total'){
                parser.nextToken();
                totalAmount = parser.getIntegerValue();
                system.debug('totalAmount:'+totalAmount);
            }
            else if(parser.getText()=='transactionId'){
                parser.nextToken();
                transactionId = parser.getText();
                system.debug('transactionId:'+transactionId);
            }
        }*/
        // Checks the transaction status
        if (null != response) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());   
            Map<String,Object> transResponseMap = (Map<String,Object>) responseMap.get('TransResponse');
            Map<String,Object> transDetailsDataMap = (Map<String,Object>) transResponseMap.get('TransDetailsData');
            Map<String,Object> transDetailDataMap = (Map<String,Object>) transDetailsDataMap.get('TransDetailData');
            responseCode = String.valueOf(transDetailDataMap.get('ResponseCode'));
            responseText = String.valueOf(transDetailDataMap.get('ResponseText'));
            if ('00000'== responseCode) {
                salesforceResultCode= SUCCESS_SALESFORCE_RESULT_CODE.name();
                
                // Successful gateway response
                Map<String,String> refDetails = new Map<String,String>();
                refDetails.put('processor_authorization_code',authorizationCode );
                refDetails.put('method', responseCode);
                
                authResponse.setGatewayReferenceDetails(JSON.Serialize(refDetails));
                authResponse.setGatewayResultCode(responseCode);
                authResponse.setGatewayResultCodeDescription(responseText);
                authResponse.setGatewayReferenceNumber(transactionId);
            } else {
                salesforceResultCode= DECLINE_SALESFORCE_RESULT_CODE.name();
                authResponse.setGatewayResultCodeDescription(responseCode);
                authResponse.setGatewayResultCodeDescription(responseText);
            }
            
            authResponse.setSalesforceResultCodeInfo(getSalesforceResultCodeInfo(salesforceResultCode));
        } else {
            String message = '';
            return new commercepayments.GatewayErrorResponse(statusCode, message);
        }
        authResponse.setAmount(totalAmount);
        authResponse.setGatewayDate(System.now());
        paymentMethodTokenizationResponse.setGatewayToken(getRandomNumber(8)+getRandomNumber(8));
        authResponse.setPaymentMethodTokenizationResponse(paymentMethodTokenizationResponse);
        return authResponse;
    }
     private String getRandomNumber(integer stringLength){
        final integer MAX = integer.valueOf(Math.pow(10,stringLength) - 1);
        return String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(stringLength,'0');
    }
}