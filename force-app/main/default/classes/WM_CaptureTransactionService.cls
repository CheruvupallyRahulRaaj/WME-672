/**
 * @description       : 
 * @author            : schauhan@liveareacx.com
 * @group             : 
 * @last modified on  : 01-14-2021
 * @last modified by  : schauhan@liveareacx.com
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   01-07-2021   schauhan@liveareacx.com   Initial Version
**/
public class WM_CaptureTransactionService extends WM_AbstractTransactionService implements Database.AllowsCallouts{
    protected commercepayments.CaptureRequest captureRequest;
    
    public WM_CaptureTransactionService(commercepayments.paymentGatewayContext gatewayContext) {
        super(gatewayContext);
        this.captureRequest = (commercepayments.CaptureRequest) gatewayContext.getPaymentRequest();
    }
       
 public override HttpRequest buildRequest(){
           HttpRequest req = new HttpRequest();
        Boolean IS_MULTICURRENCY_ORG = UserInfo.isMultiCurrencyOrganization();
        PaymentAuthorization authObject = WM_TransactionHelper.getAuthObjectForCapture(captureRequest.paymentAuthorizationid, IS_MULTICURRENCY_ORG); 
        Account accObject = WM_ServiceHelper.getAccount(authObject.AccountId);

        string keyPrefixOfPaymentMethodID = null;

        CardPaymentMethod cpm = null;
        DigitalWallet dw = null;
        if(authObject.PaymentMethodId!=null){
            keyPrefixOfPaymentMethodID = String.valueOf(authObject.PaymentMethodId).substring(0,3);
        }

        if(keyPrefixOfPaymentMethodID!=null && keyPrefixOfPaymentMethodID == CardPaymentMethod.SObjectType.getDescribe().getKeyPrefix()){
            cpm = (CardPaymentMethod)WM_TransactionHelper.getCardPaymentMethod(authObject.PaymentMethodId);
        }
        else if( keyPrefixOfPaymentMethodID!=null && keyPrefixOfPaymentMethodID == DigitalWallet.SObjectType.getDescribe().getKeyPrefix()){
            dw = (DigitalWallet)WM_TransactionHelper.getDigitalWalletPaymentMethod(authObject.PaymentMethodId);
        }

        system.debug('Auth Object '+authObject);
        String  orderSumId = ((OrderPaymentSummary)WM_TransactionHelper.getOrderPaymentSummary(authObject.OrderPaymentSummaryId)).OrderSummaryId;
     	String salesChannelName =  ((OrderSummary)WM_ServiceHelper.getOrderSummary(orderSumId)).SalesChannel.Saleschannelname;
        List<OrderItemSummary> orderItemSumList = (List<OrderItemSummary>)WM_TransactionHelper.geOrderItemSummary(orderSumId);
        List<OrderItem> orderProductList = new List<OrderItem>();
        List<OrderDeliveryGroup> orderDelGrpList = new List<OrderDeliveryGroup>();
        List<Product2> prodList = new List<Product2>();
     Decimal countOfQuantities =0;
      Decimal countOfFulFilledQuantities =0;
        for(OrderItemSummary oim:orderItemSumList){
            OrderItem orderProduct = (OrderItem)WM_TransactionHelper.getOrderItem(oim.OriginalOrderItemId);
            OrderDeliveryGroup orderDelGrp = (OrderDeliveryGroup)WM_TransactionHelper.getOrderDeliveryGroup(orderProduct.OrderDeliveryGroupId);
            Product2 prod = (Product2)WM_TransactionHelper.getProduct(orderProduct.Product2Id);
            orderProductList.add(orderProduct);
            orderDelGrpList.add(orderDelGrp);
            prodList.add(prod);
            countOfQuantities = oim.Quantity + countOfQuantities;
            countOfFulFilledQuantities = oim.QuantityFulfilled + countOfFulFilledQuantities;
        }
    Integer totalCount = (Integer)countOfQuantities;
        Integer seqCount = [Select Count() from Payment where OrderPaymentSummaryId =:authObject.OrderPaymentSummaryId];
      String addData = String.valueOf(captureRequest.additionalData);
    system.debug('captureRequest '+String.valueOf(captureRequest));
     String invoiceId;
   if(Test.isRunningTest()){
         invoiceId = (String)[Select Id from Invoice limit 1].Id;
     }
     else{
          invoiceId = addData.substring(11, 29);
     }
     
     Integer currentQuantities = (Integer)[Select Id,ItemCount from FulFillmentOrder where InvoiceId=:invoiceId].ItemCount;
     List<Invoice> lstInvoices = [Select ID,Invoice_Credit_Number__c From Invoice WHERE ID = :invoiceId];
     string invoiceCreditNumber = null;
     if(lstInvoices!=null && lstInvoices.size()==1){
        invoiceCreditNumber = lstInvoices[0].Invoice_Credit_Number__c;
     }

     if(countOfQuantities-countOfFulFilledQuantities!=currentQuantities){
         seqCount = seqCount+1;
     }
     else {
          seqCount = seqCount+1;
         totalCount = seqCount;
          
     }
         
        String transType = WMConstants.CaptureTransactionType;
        WM_TransactionWrapper wrp = null;
        if(cpm != null){
            wrp = new WM_TransactionWrapper(accObject,captureRequest.amount,transType,authObject,cpm, orderItemSumList,orderProductList,orderDelGrpList,prodList,seqCount,null,totalCount,salesChannelName);
        }
        else if(dw != null){
            wrp = new WM_TransactionWrapper(accObject,captureRequest.amount,transType,authObject,dw, orderItemSumList,orderProductList,orderDelGrpList,prodList,seqCount,null,totalCount,salesChannelName);
            wrp.invoiceCreditNumber = invoiceCreditNumber;
        }
        req =  AurusService.aurusTransaction(wrp);
        return req;
    }
    
    
    public override commercepayments.GatewayResponse buildResponse(HttpResponse response) {
        commercepayments.CaptureResponse captureResponse = new commercepayments.CaptureResponse();
        String salesforceResultCode = null;
        String statusCode = String.valueOf(response.getStatusCode());
        String transSeqNumber = '';
        String responseCode = '';
        String responseText = '';
        String transactionId = '';
        Double totalAmount = 0;
        // Checks the transaction status
        if (null != response) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());   
            Map<String,Object> transResponseMap = (Map<String,Object>) responseMap.get('TransResponse');
            Map<String,Object> transDetailsDataMap = (Map<String,Object>) transResponseMap.get('TransDetailsData');
            Map<String,Object> transDetailDataMap = (Map<String,Object>) transDetailsDataMap.get('TransDetailData');
            responseCode = String.valueOf(transDetailDataMap.get('ResponseCode'));
            responseText = String.valueOf(transDetailDataMap.get('ResponseText'));
            totalAmount = Double.valueOf(transDetailDataMap.get('TotalApprovedAmount'));
            transactionId = String.valueOf(transDetailDataMap.get('AuruspayTransactionId'));
            transSeqNumber = String.valueOf(transDetailDataMap.get('TransactionSequenceNumber'));
            if ('00000' == responseCode) {
                salesforceResultCode = SUCCESS_SALESFORCE_RESULT_CODE.name();
                
                // Successful gateway response
                Map < String, String > refDetails = new Map < String, String > ();
                refDetails.put('TransactionSequenceNumber', transSeqNumber);
                refDetails.put('method', responseCode);
                
                captureResponse.setGatewayReferenceDetails(JSON.Serialize(refDetails));
                captureResponse.setGatewayResultCode(responseCode);
                captureResponse.setGatewayResultCodeDescription(responseText);
                captureResponse.setGatewayReferenceNumber(transactionId);
                captureResponse.setAmount(totalAmount);
               
               system.debug('Capture Response '+captureResponse);           
            } else {
                salesforceResultCode = DECLINE_SALESFORCE_RESULT_CODE.name();
                captureResponse.setGatewayResultCodeDescription(responseCode);
                captureResponse.setGatewayResultCodeDescription(responseText);
            }
            
            captureResponse.setSalesforceResultCodeInfo(getSalesforceResultCodeInfo(salesforceResultCode));
        } else {
            String message = '';
            return new commercepayments.GatewayErrorResponse(statusCode, message);
        }
        captureResponse.setGatewayDate(System.now());
        return captureResponse;
    }
       
    
}