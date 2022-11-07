/**
 * @description       : 
 * @author            : schauhan@liveareacx.com
 * @group             : 
 * @last modified on  : 01-12-2021
 * @last modified by  : schauhan@liveareacx.com
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   01-07-2021   schauhan@liveareacx.com   Initial Version 
**/
public class AurusService {


  public static HttpRequest aurusTransaction(WM_TransactionWrapper wrp) {  
      String origAurusPayTicket = '';
      //Http http = new Http();
      HttpRequest request = new HttpRequest();
      if(wrp.transactionType!='06'){
              request.setEndpoint('/aurus-adsdk-web-service/auruspay/adsdk/authtransaction');
      }
  
      request.setMethod('POST'); 
      request.setHeader('Content-Type','application/json');
      TransactionRequestObj tranReqObj = new TransactionRequestObj();
      TransactionRequestObj.TransRequest transReq = new  TransactionRequestObj.TransRequest();
      List<TransactionRequestObj.Level3Product> l3ProdList = new List<TransactionRequestObj.Level3Product>();
      for(Integer i=0; i <(wrp.orderProduct).size(); i++){
          TransactionRequestObj.Level3Product l3Prod = new TransactionRequestObj.Level3Product();
          l3Prod.L3ProductDescription = WM_Utils.getString(wrp.prod[i].Description);
          l3Prod.L3UnitOfMeasure = WM_Utils.getString(wrp.prod[i].QuantityUnitOfMeasure);
          l3Prod.L3FreightAmount = '';
          l3Prod.L3ProductTaxRate = '';
          l3Prod.L3OrderRefNumber = WM_Utils.getString(wrp.orderProduct[i].OrderItemNumber);
          l3Prod.L3ClassID = '';
          l3Prod.L3ProductQuantity = WM_Utils.getString(wrp.orderProduct[i].Quantity);
          l3Prod.L3OtherAmount = '';
          l3Prod.L3ProductDiscount = '';
          l3Prod.L3ProductCode = WM_Utils.getString(wrp.prod[i].ProductCode);
          l3Prod.L3ProductUnitPrice = WM_Utils.getString(wrp.orderProduct[i].UnitPrice);
          l3Prod.L3ProductTax = WM_Utils.getString(wrp.orderProduct[i].TotalLineTaxAmount);
          l3Prod.L3ProductTotalAmount = WM_Utils.getString(wrp.orderProduct[i].TotalLineAmount);
          l3Prod.L3ProductName = WM_Utils.getString(wrp.prod[i].Name);
          l3Prod.L3DepartmentID = '';
          l3Prod.L3TarriffAmount = '';
          l3Prod.L3ProductSeqNo = '';
          l3Prod.L3GiftWrapAmount = '';
          l3Prod.L3MonogramAmount = '';
          l3ProdList.add(l3Prod);
      }
      
  
      TransactionRequestObj.Level3Products l3Prods = new TransactionRequestObj.Level3Products();
      l3Prods.Level3Product = l3ProdList;
      TransactionRequestObj.Level3ProductsData l3ProdsData = new TransactionRequestObj.Level3ProductsData();
      l3ProdsData.Level3Products = l3Prods;
      l3ProdsData.Level3ProductCount =  WM_Utils.getString((wrp.orderProduct).size());
  
      TransactionRequestObj.BillingAddress billAddr = new  TransactionRequestObj.BillingAddress();
      billAddr.BillingAddressLine1 = '';
      billAddr.BillingAddressLine2 = '';
      if(wrp.cpm!=null){
        billAddr.BillingCountry = WM_Utils.getString(wrp.cpm.PaymentMethodCountry);
        billAddr.BillingEmailId = WM_Utils.getString(wrp.cpm.Email);
        billAddr.BillingCity = WM_Utils.getString(wrp.cpm.PaymentMethodCity);
        billAddr.BillingMobileNumber = WM_Utils.getString(wrp.cpm.Phone);
        billAddr.BillingFirstName = WM_Utils.getString(wrp.cpm.CardHolderFirstName);
        billAddr.BillingLastName = WM_Utils.getString(wrp.cpm.CardHolderLastName);
        billAddr.BillingZip = WM_Utils.getString(wrp.cpm.PaymentMethodpostalcode);
        billAddr.BillingState = WM_Utils.getString(wrp.cpm.PaymentMethodState);
      }
      else if(wrp.dw != null){
        billAddr.BillingCountry = WM_Utils.getString(wrp.dw.PaymentMethodCountry);
        billAddr.BillingEmailId = WM_Utils.getString(wrp.dw.Email);
        billAddr.BillingCity = WM_Utils.getString(wrp.dw.PaymentMethodCity);
        billAddr.BillingMobileNumber = WM_Utils.getString(wrp.dw.Phone);
        // billAddr.BillingFirstName = WM_Utils.getString(wrp.dw.NickName);
        // billAddr.BillingLastName =  WM_Utils.getString(wrp.dw.NickName);
        billAddr.BillingZip = WM_Utils.getString(wrp.dw.PaymentMethodpostalcode);
        billAddr.BillingState = WM_Utils.getString(wrp.dw.PaymentMethodState);
      }
     
  
      TransactionRequestObj.ECOMMInfo ecomminf = new  TransactionRequestObj.ECOMMInfo();
      //ecomminf.OneTimeToken = WM_Utils.getString(wrp.cpm.GatewayToken);
      // In DEV, PRO and RETAIL config are same for AURUS
      if(wrp.channelName!=null){
             ecomminf.StoreId = WM_Utils.getString((AurusConfig__c.getValues(wrp.channelName)).StoreId__c);
      ecomminf.CardIdentifier = '';
      ecomminf.MerchantIdentifier = WM_Utils.getString((AurusConfig__c.getValues(wrp.channelName)).MerchantIdentifier__c);
      if(wrp.cpm!=null){
        ecomminf.OneOrderToken = WM_Utils.getString(wrp.cpm.aurusPayOOT__c);
      }
      else if(wrp.dw!=null){
        ecomminf.OneOrderToken = WM_Utils.getString(wrp.dw.aurusPayOOT__c);
      }
     ecomminf.TerminalId = WM_Utils.getString((AurusConfig__c.getValues(wrp.channelName)).TerminalId__c );
      }
  
      
  
      TransactionRequestObj.SettlementInfo settlInf = new  TransactionRequestObj.SettlementInfo();
      settlInf.TransactionDescription = '';
      settlInf.PromotionCode = '';
      settlInf.InCircleAmount = '';
      settlInf.MerchantTransactionCode = '';
      settlInf.SalesCheckNumber = '';
      settlInf.CreditPlan = '';
  
  
      TransactionRequestObj.TransAmountDetails transAmtDts = new TransactionRequestObj.TransAmountDetails();
      transAmtDts.TaxAmount = '';
      transAmtDts.ProductTotalAmount =  WM_Utils.getString(wrp.amt);
      transAmtDts.Discount = '';
      transAmtDts.TransactionTotal = WM_Utils.getString(wrp.amt);
  
      TransactionRequestObj.ShippingAddress shpAddr = new TransactionRequestObj.ShippingAddress();
      shpAddr.ShippingAddressLine1 = '';
      shpAddr.ShippingEmailId = '';
      shpAddr.ShippingMiddleName= '';
      shpAddr.ShippingFirstName= '';
      shpAddr.ShippingZip= '';
      shpAddr.ShippingCountry= '';
      shpAddr.ShippingCity= '';
      shpAddr.ShippingState= '';
      shpAddr.ShippingMobileNumber= '';
      shpAddr.ShippingAddressLine2= '';
      shpAddr.ShippingLastName= '';
      
      TransactionRequestObj.Tag tag1= new TransactionRequestObj.Tag();
      tag1.Key = 'ProcessorReturnAci';
      tag1.Value = '';
      TransactionRequestObj.Tag tag2= new TransactionRequestObj.Tag();
      tag2.Key = 'ProcessorAuthSourceCode';
      tag2.Value = '';
      TransactionRequestObj.Tag tag3= new TransactionRequestObj.Tag();
      tag3.Key = 'ProcessorResponseCode';
      tag3.Value = '';
      TransactionRequestObj.Tag tag4= new TransactionRequestObj.Tag();
      tag4.Key = 'ProcessorApprovalCode';
      tag4.Value = '';
      TransactionRequestObj.Tag tag5= new TransactionRequestObj.Tag();
      tag5.Key = 'ProcessorAvsResultCode';
      tag5.Value = '';
      TransactionRequestObj.Tag tag6= new TransactionRequestObj.Tag();
      tag6.Key = 'ProcessorTransIdentifier';
      tag6.Value = '';
      TransactionRequestObj.Tag tag7= new TransactionRequestObj.Tag();
      tag7.Key = 'ProcessorValidationCode';
      tag7.Value = '';
      TransactionRequestObj.Tag tag8= new TransactionRequestObj.Tag();
      tag8.Key = 'ProcessorCommercialCardIndicator';
      tag8.Value = '';
      TransactionRequestObj.Tag tag9= new TransactionRequestObj.Tag();
      tag9.Key = 'ProcessorSpendQualifierIndicator';
      tag9.Value = '';
      TransactionRequestObj.Tag tag10= new TransactionRequestObj.Tag();
      tag10.Key = 'ProcessorMasterCardTic';
      tag10.Value = '';
      TransactionRequestObj.Tag tag11= new TransactionRequestObj.Tag();
      tag11.Key = 'ProcessorAcquirerReferenceNumber';
      tag11.Value = '';
      TransactionRequestObj.Tag tag12= new TransactionRequestObj.Tag();
      tag12.Key = 'ProcessorCreditPlan';
      tag12.Value = '';
      TransactionRequestObj.Tag tag13= new TransactionRequestObj.Tag();
      tag13.Key = 'ProcessorPromoCode';
      tag13.Value = '';
      TransactionRequestObj.Tag tag14= new TransactionRequestObj.Tag();
      tag14.Key = 'ProcessorSalesDate';
      tag14.Value = '';
      TransactionRequestObj.Tag tag15= new TransactionRequestObj.Tag();
      tag15.Key = 'ProcessorDeliveryDate';
      tag15.Value = '';
      TransactionRequestObj.Tag tag16= new TransactionRequestObj.Tag();
      tag16.Key = 'ProcessorSalesRepID';
      tag16.Value = '';
      TransactionRequestObj.Tag tag17= new TransactionRequestObj.Tag();
      tag17.Key = 'ProcessorTransTime';
      tag17.Value = '';
      TransactionRequestObj.Tag tag18= new TransactionRequestObj.Tag();
      tag18.Key = 'ProcessorMerchantTransCode';
      tag18.Value = '';
      TransactionRequestObj.Tag tag19= new TransactionRequestObj.Tag();
      tag19.Key = 'ProcessorModelNumber';
      tag19.Value = '';
      TransactionRequestObj.Tag tag20= new TransactionRequestObj.Tag();
      tag20.Key = 'ProcessorProductNumber';
      tag20.Value = '';
      TransactionRequestObj.Tag tag21= new TransactionRequestObj.Tag();
      tag21.Key = 'ProcessorMiscIndicator';
      tag21.Value = '';
      TransactionRequestObj.Tag tag22= new TransactionRequestObj.Tag();
      tag22.Key = 'ProcessorSalescheckNumber';
      tag22.Value = '';
      TransactionRequestObj.Tag tag23= new TransactionRequestObj.Tag();
      tag23.Key = 'ProcessorPurchaseOrderNum';
      tag23.Value = '';
      TransactionRequestObj.Tag tag24= new TransactionRequestObj.Tag();
      tag24.Key = 'ProcessorTransactionDesc';
      tag24.Value = '';
      TransactionRequestObj.Tag tag25= new TransactionRequestObj.Tag();
      tag25.Key = 'ProcessorModelYear';
      tag25.Value = '';
      TransactionRequestObj.Tag tag26= new TransactionRequestObj.Tag();
      tag26.Key = 'ProcessorRnn';
      tag26.Value = '';
  
      List<TransactionRequestObj.Tag> tagList = new List<TransactionRequestObj.Tag>();
      tagList.add(tag1);
      tagList.add(tag2);
      tagList.add(tag3);
      tagList.add(tag4);
      tagList.add(tag5);
      tagList.add(tag6);
      tagList.add(tag7);
      tagList.add(tag8);
      tagList.add(tag9);
      tagList.add(tag10);
      tagList.add(tag11);
      tagList.add(tag12);
      tagList.add(tag13);
      tagList.add(tag14);
      tagList.add(tag15);
      tagList.add(tag16);
      tagList.add(tag17);
      tagList.add(tag18);
      tagList.add(tag19);
      tagList.add(tag20);
      tagList.add(tag21);
      tagList.add(tag22);
      tagList.add(tag23);
      tagList.add(tag24);
      tagList.add(tag25);
      tagList.add(tag26);
  
      TransactionRequestObj.Tags tags = new TransactionRequestObj.Tags();
      tags.Tag = tagList;
  
      TransactionRequestObj.AdditionalTags addTags = new TransactionRequestObj.AdditionalTags();
      addTags.Tags = tags;
  
      transReq.PONumber = WMConstants.EmptyString;
      transReq.ClerkID = WMConstants.EmptyString;
      transReq.TransactionType = wrp.transactionType;
      if(wrp.cpm!=null){
        transReq.OrigAurusPayTicketNum  =  WM_Utils.getString(wrp.cpm.aurusPayAPTN__c);
      }
      else if(wrp.dw !=null){
        transReq.OrigAurusPayTicketNum  =  WM_Utils.getString(wrp.dw.aurusPayAPTN__c);
      }
      transReq.ProcessingMode  =  WMConstants.ProcessingMode1;
      if(wrp.transactionType!='02'){
            transReq.PostAuthSequenceNo  = WM_Utils.getString(wrp.seqCount);
      }
   if(wrp.channelName!=null){  
      transReq.CorpID = WM_Utils.getString((AurusConfig__c.getValues(wrp.channelName)).CorpID__c);
   }
      //transReq.ProcessorToken = WM_Utils.getString(wrp.cpm.GatewayToken);
      transReq.Level3ProductsData = l3ProdsData;
      transReq.LanguageIndicator = WMConstants.LanguageIndicator;
      transReq.BillingAddress = billAddr;
      transReq.CurrencyCode = WMConstants.CurrencyCode;
      if(wrp.transactionType!='02'){
       transReq.PostAuthCount = WM_Utils.getString(wrp.countOfOrderItem);
       }
       // Added new code for WME-203
      if(wrp.transactionType=='05'){
        transReq.PostAuthCount = '99';
       }
       // end of new code for WME-203

      if(wrp.cpm!=null){
        transReq.CardType = WM_Utils.getString(wrp.cpm.CardType);
      }
      // else if(wrp.dw != null){
      //   transReq.CardType = WM_Utils.getString(wrp.dw.Type);
      // }
      if(wrp.transactionType!='02'){
        
        if(wrp.cpm!=null){
           transReq.OrigTransactionIdentifier = WM_Utils.getString(wrp.cpm.aurusPayAPTID__c);
        }
        else if(wrp.dw!=null){
           transReq.OrigTransactionIdentifier = WM_Utils.getString(wrp.dw.aurusPayAPTID__c);
        }
      }
      if(wrp.transactionType=='02'){
           transReq.OrigTransactionIdentifier = WM_Utils.getString(wrp.paymentObj.GatewayRefNumber);
      }
      if(wrp.cpm!=null){
        if(WM_Utils.getString(wrp.cpm.ExpiryMonth).getChars().size()>1){
        transReq.CardExpiryDate =  WM_Utils.getString(wrp.cpm.ExpiryMonth)+WM_Utils.getString(wrp.cpm.ExpiryYear).substring(2);
        }
        else{
          transReq.CardExpiryDate =  '0'+WM_Utils.getString(wrp.cpm.ExpiryMonth)+WM_Utils.getString(wrp.cpm.ExpiryYear).substring(2);
          
        }
      }
      // WME-212 Code modifications start
      //transReq.InvoiceNumber = '';
      string orderSummaryNumber = '';
      if(wrp.orderProduct != null && wrp.orderProduct.size() > 0){
        List<OrderSummary> lstOrderSummaries = [
          SELECT
            Id,
            OrderNumber
          FROM
            OrderSummary
          WHERE OriginalOrderId in (SELECT OrderId FROM OrderItem WHERE Id=:wrp.orderProduct[0].Id)
        ];
        if(lstOrderSummaries !=null && lstOrderSummaries.size()>0){
          orderSummaryNumber = lstOrderSummaries[0].OrderNumber;
        }
      }
      transReq.InvoiceNumber = orderSummaryNumber;
      if(wrp.dw!=null && String.isNotBlank(wrp.invoiceCreditNumber)){
        transReq.InvoiceNumber = wrp.invoiceCreditNumber;
      }
      // WME -212 Code modifications end
      transReq.KI = WMConstants.EmptyString;
      transReq.TransactionDate = WM_Utils.getCurrentDateString();
      transReq.SubTransType = WMConstants.EmptyString;
      transReq.ReferenceNumber = WMConstants.EmptyString;
      transReq.ECOMMInfo = ecomminf;
      transReq.ApprovalCode = WMConstants.EmptyString;
      transReq.PODate = WMConstants.EmptyString;
      transReq.TransactionTime = WM_Utils.getCurrentTimeString();   
      transReq.ThirdPartyURL = WMConstants.EmptyString;
      transReq.SettlementInfo = settlInf;
      transReq.TransAmountDetails = transAmtDts;
      transReq.ShippingAddress = shpAddr;
      transReq.AdditionalTags = addTags;   
      transReq.WalletIdentifier = WMConstants.EmptyString;
      if(wrp.cpm!=null){
        transReq.AurusPayTicketNum = WM_Utils.getString(wrp.cpm.aurusPayAPTN__c);
      }
      else{
        transReq.AurusPayTicketNum = WM_Utils.getString(wrp.dw.aurusPayAPTN__c);
      }
      
      tranReqObj.TransRequest = transReq;
      String payLoad = JSON.serialize(tranReqObj);
  
      
      System.debug('payLoad '+payLoad);   
      request.setBody(payLoad);
      System.debug(request); 
      return request;
  }
  
  }