public class WM_RefundCustomRequest implements Database.AllowsCallouts {
    
    
    @InvocableMethod(label='Process Refund via Aurus')
    public static void processRefund(List<Request> requests){
        for(Request reqst: requests){
            System.debug('Entered processRefund');
            Boolean IS_MULTICURRENCY_ORG = UserInfo.isMultiCurrencyOrganization();
            Payment paymentObj = WM_TransactionHelper.getPaymentObjectForRefund(reqst.paymentId, IS_MULTICURRENCY_ORG); 
            Account accObject = WM_TransactionHelper.getAccountObject(paymentObj.AccountId); 
            PaymentAuthorization authObject = WM_TransactionHelper.getAuthObjectForCapture(paymentObj.PaymentAuthorizationId, IS_MULTICURRENCY_ORG); 
            //CardPaymentMethod cpm = (CardPaymentMethod)WM_TransactionHelper.getCardPaymentMethod(paymentObj.PaymentMethodId);
            /*START:- WME-451:Add Pay pal tender into priority listing for returns and discounts */
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
            system.debug('keyPrefixOfPaymentMethodID:'+keyPrefixOfPaymentMethodID);
            system.debug('DigitalWallet:keyPrefixOfPaymentMethodID:'+DigitalWallet.SObjectType.getDescribe().getKeyPrefix());
            /*END:- WME-451:Add Pay pal tender into priority listing for returns and discounts */
            String  orderSumId = ((OrderPaymentSummary)WM_TransactionHelper.getOrderPaymentSummary(authObject.OrderPaymentSummaryId)).OrderSummaryId;
            String salesChannelName =  ((OrderSummary)WM_ServiceHelper.getOrderSummary(orderSumId)).SalesChannel.Saleschannelname;
            List<OrderItemSummary> orderItemSumList = (List<OrderItemSummary>)WM_TransactionHelper.geOrderItemSummary(orderSumId);
            List<OrderItem> orderProductList = new List<OrderItem>();
            List<OrderDeliveryGroup> orderDelGrpList = new List<OrderDeliveryGroup>();
            List<Product2> prodList = new List<Product2>();
            System.debug('orderItemSumList:'+orderItemSumList);
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
            /*WM_TransactionWrapper wrp = new WM_TransactionWrapper(accObject,reqst.amount,transType,authObject,cpm,
orderItemSumList,orderProductList,orderDelGrpList,prodList,invoiceCount,paymentObj,countOfOrderItem,salesChannelName);*/
            /*START:- WME-451:Add Pay pal tender into priority listing for returns and discounts */
            WM_TransactionWrapper wrp = null;
            if(cpm != null){
                wrp = new WM_TransactionWrapper(accObject,reqst.amount,transType,authObject,cpm, orderItemSumList,orderProductList,orderDelGrpList,prodList,invoiceCount,paymentObj,countOfOrderItem,salesChannelName);
            }
            else if(dw != null){
                wrp = new WM_TransactionWrapper(accObject,reqst.amount,transType,authObject,dw, orderItemSumList,orderProductList,orderDelGrpList,prodList,invoiceCount,paymentObj,countOfOrderItem,salesChannelName);
                wrp.invoiceCreditNumber = reqst.invoiceId;
            }
            /*END:- WME-451:Add Pay pal tender into priority listing for returns and discounts */
            WM_RefundQueueable refndJob = new WM_RefundQueueable(wrp);
            system.enqueueJob(refndJob);
        }
        
    }
    
    
    public class Request {
        @InvocableVariable
        public Double amount;
        @InvocableVariable
        public String paymentId;
        @InvocableVariable
        public String invoiceId;
    }
    
}