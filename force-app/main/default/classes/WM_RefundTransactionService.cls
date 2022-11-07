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
public class WM_RefundTransactionService extends WM_AbstractTransactionService{
    protected commercepayments.ReferencedRefundRequest referencedRefund;
    
    
    public WM_RefundTransactionService(commercepayments.paymentGatewayContext gatewayContext){
        super(gatewayContext);
        this.referencedRefund = (commercepayments.ReferencedRefundRequest)gatewayContext.getPaymentRequest();
    }
    

    
    public override HttpRequest buildRequest(){
        system.debug('referencedRefund '+referencedRefund);
        HttpRequest req = new HttpRequest();   
        Boolean IS_MULTICURRENCY_ORG = UserInfo.isMultiCurrencyOrganization();
        Payment paymentObj = WM_TransactionHelper.getPaymentObjectForRefund(referencedRefund.paymentId, IS_MULTICURRENCY_ORG); 
        Account accObject = WM_TransactionHelper.getAccountObject(paymentObj.AccountId); 
        PaymentAuthorization authObject = WM_TransactionHelper.getAuthObjectForCapture(paymentObj.PaymentAuthorizationId, IS_MULTICURRENCY_ORG); 
      //  CardPaymentMethod cpm = (CardPaymentMethod)WM_TransactionHelper.getCardPaymentMethod(paymentObj.PaymentMethodId);
        
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
        
        String  orderSumId = ((OrderPaymentSummary)WM_TransactionHelper.getOrderPaymentSummary(authObject.OrderPaymentSummaryId)).OrderSummaryId;
        String salesChannelName =  ((OrderSummary)WM_ServiceHelper.getOrderSummary(orderSumId)).SalesChannel.Saleschannelname;
        List<OrderItemSummary> orderItemSumList = (List<OrderItemSummary>)WM_TransactionHelper.geOrderItemSummary(orderSumId);
        List<OrderItem> orderProductList = new List<OrderItem>();
        List<OrderDeliveryGroup> orderDelGrpList = new List<OrderDeliveryGroup>();
        List<Product2> prodList = new List<Product2>();
        for(OrderItemSummary oim:orderItemSumList){
            OrderItem orderProduct = (OrderItem)WM_TransactionHelper.getOrderItem(oim.OriginalOrderItemId);
            OrderDeliveryGroup orderDelGrp = (OrderDeliveryGroup)WM_TransactionHelper.getOrderDeliveryGroup(orderProduct.OrderDeliveryGroupId);
            Product2 prod = (Product2)WM_TransactionHelper.getProduct(orderProduct.Product2Id);
            orderProductList.add(orderProduct);
            orderDelGrpList.add(orderDelGrp);
            prodList.add(prod);
        }
        Integer countOfOrderItem = orderProductList.size();
        
       
        Integer  invoiceCount = Database.countQuery('select count() from Invoice where ReferenceEntityId=:orderSumId');
        String transType = WMConstants.RefundTransactionType;

        /*WM_TransactionWrapper wrp = new WM_TransactionWrapper(accObject,referencedRefund.amount,transType,authObject,cpm,
        orderItemSumList,orderProductList,orderDelGrpList,prodList,invoiceCount,paymentObj,countOfOrderItem,salesChannelName);*/
        
        WM_TransactionWrapper wrp = null;
        if(cpm != null){
            wrp = new WM_TransactionWrapper(accObject,referencedRefund.amount,transType,authObject,cpm, orderItemSumList,orderProductList,orderDelGrpList,prodList,invoiceCount,paymentObj,countOfOrderItem,salesChannelName);
        }
        else if(dw != null){
            wrp = new WM_TransactionWrapper(accObject,referencedRefund.amount,transType,authObject,dw, orderItemSumList,orderProductList,orderDelGrpList,prodList,invoiceCount,paymentObj,countOfOrderItem,salesChannelName);
        }
        
        req =  AurusService.aurusTransaction(wrp);
        return req;
    }
    
    public override commercepayments.GatewayResponse buildResponse(HttpResponse response) {
        commercepayments.ReferencedRefundResponse refundResponse = new commercepayments.ReferencedRefundResponse();
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
                salesforceResultCode= SUCCESS_SALESFORCE_RESULT_CODE.name();
                
                // Successful gateway response
                Map<String,String> refDetails = new Map<String,String>();
                refDetails.put('TransactionSequenceNumber',transSeqNumber );
                refDetails.put('method', responseCode);
                
                refundResponse.setGatewayReferenceDetails(JSON.Serialize(refDetails));
                refundResponse.setGatewayResultCode(responseCode);
                refundResponse.setGatewayResultCodeDescription(responseText);
                refundResponse.setGatewayReferenceNumber(transactionId);
            } else {
                salesforceResultCode= DECLINE_SALESFORCE_RESULT_CODE.name();
                refundResponse.setGatewayResultCodeDescription(responseCode);
                refundResponse.setGatewayResultCodeDescription(responseText);
            }
            
            refundResponse.setSalesforceResultCodeInfo(getSalesforceResultCodeInfo(salesforceResultCode));
        } else {
            String message = '';
            return new commercepayments.GatewayErrorResponse(statusCode, message);
        }
        refundResponse.setAmount(totalAmount);
        refundResponse.setGatewayDate(System.now());
        
        return refundResponse;
    }
}