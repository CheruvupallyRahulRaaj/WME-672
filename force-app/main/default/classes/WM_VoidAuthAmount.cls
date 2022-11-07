public class WM_VoidAuthAmount {
  @InvocableMethod
  public static void voidTransaction (List<String> paymentAuthorizationIds) {
      system.debug('Test-668:WM_VoidAuthAmount');
      Boolean IS_MULTICURRENCY_ORG = UserInfo.isMultiCurrencyOrganization();
      PaymentAuthorization authObject = WM_TransactionHelper.getAuthObjectForCapture(paymentAuthorizationIds[0], IS_MULTICURRENCY_ORG); 

    //Check if PaymentAuthorization is related to Card Payment OR DigitalWallet. If not return
    List<CardPaymentMethod> lstCardPaymentMethods = [Select ID From CardPaymentMethod WHERE ID = :authObject.PaymentMethodId];
    List<DigitalWallet> lstDigitalWallets = [Select ID From DigitalWallet WHERE ID = :authObject.PaymentMethodId];

    if((lstCardPaymentMethods == null || lstCardPaymentMethods.size()==0) && (lstDigitalWallets == null || lstDigitalWallets.size()==0)) return;

        Account accObject = WM_ServiceHelper.getAccount(authObject.AccountId); 
        System.debug('authObject.PaymentMethodId'+authObject.PaymentMethodId);
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
      OrderPaymentSummary  ordPay = ((OrderPaymentSummary)WM_TransactionHelper.getOrderPaymentSummary(authObject.OrderPaymentSummaryId));
      Double amt = 0;
      Double AuthAmt=ordPay.AuthorizationAmount;
      Double CapAmt=ordPay.CapturedAmount;
      System.debug('Authorization Amount:>>>>>'+AuthAmt);
        System.debug('Captured Amount:>>>>>'+CapAmt);
      // System.debug('Card Type:>>>>>'+cpm.CardCategory);
        if((cpm!=null && cpm.CardCategory=='CreditCard') || dw!=null ){
          if(AuthAmt>CapAmt){
            amt=AuthAmt-CapAmt;
            }
        }
        System.debug('Void Amount:>>>>>'+amt);
       
       if(amt == 0){
           return;
       }
      String  orderSumId = ((OrderPaymentSummary)WM_TransactionHelper.getOrderPaymentSummary(authObject.OrderPaymentSummaryId)).OrderSummaryId;
      List<OrderItemSummary> orderItemSumList = (List<OrderItemSummary>)WM_TransactionHelper.geOrderItemSummary(orderSumId);
      String salesChannelName =  ((OrderSummary)WM_ServiceHelper.getOrderSummary(orderSumId)).SalesChannel.Saleschannelname;
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
      String transType = WMConstants.VoidTransactionType;
      //Double amt = authObject.Amount;

      WM_TransactionWrapper wrp = null;
      if(cpm != null){
        wrp = new WM_TransactionWrapper(accObject,amt,transType,authObject,cpm,orderItemSumList,orderProductList,orderDelGrpList,prodList,invoiceCount,null,countOfOrderItem,salesChannelName);
      }
      else if(dw != null){
        wrp = new WM_TransactionWrapper(accObject,amt,transType,authObject,dw,orderItemSumList,orderProductList,orderDelGrpList,prodList,invoiceCount,null,countOfOrderItem,salesChannelName);
      }

      HttpRequest req =  AurusService.aurusTransaction(wrp);
      //req.setEndpoint('https://uatds42.auruspay.com/aurus-adsdk-web-service/auruspay/adsdk/authtransaction');
      req.setEndpoint('callout:AurusRefund');
      Http  http = new Http();
      HttpResponse res = null;
      res = http.send(req);
      system.debug('Response Body '+res.getBody());
      system.debug('Response status code'+res.getStatusCode());
      if(res.getStatusCode()==200){
           Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());   
          Map<String,Object> transResponseMap = (Map<String,Object>) responseMap.get('TransResponse');
          Map<String,Object> transDetailsDataMap = (Map<String,Object>) transResponseMap.get('TransDetailsData');
          Map<String,Object> transDetailDataMap = (Map<String,Object>) transDetailsDataMap.get('TransDetailData');
         String responseCode = String.valueOf(transDetailDataMap.get('ResponseCode'));
          if ('00000' == responseCode) {
         // authObject.Status = 'Canceled';
         // update authObject;
      }
      }
     
  }
}