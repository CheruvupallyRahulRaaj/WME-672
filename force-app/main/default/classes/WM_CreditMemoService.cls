public class WM_CreditMemoService {
    @AuraEnabled
    public integer ReturnAuthorization;
    public static void callCreditMemoService (List<String> sObjectIds) {
        system.debug('callCreditMemoService  called');
        List<CreditMemo> listOfUpdatedCreditMemos = new List<CreditMemo>();
        
        List<CreditMemo> creditMemos = [SELECT Id, DocumentNumber, CreatedDate, BillingAccountId,BillingAccount.Sales_Person_Number__c,BillingAccount.AccountSource,BillingAccount.IsPersonAccount,BillingAccount.Cust_Payment_Class__c,BillingAccount.Associate__c,
                                        BillingAccount.AccountNumber,BillingAccount.associateID__c,BillingAccount.SoldToNumber__c,BillingAccount.Salutation__pc,BillingAccount.FirstName,BillingAccount.LastName,
                                        BillingAccount.Suffix__pc,BillingAccount.Name,BillingAccount.PersonEmail,BillingAccount.PersonMobilePhone,BillingAccount.Email__c,BillingAccount.Phone,
                                        BillingAccount.cst_tax_code__c,BillingAccount.loyaltyAccountNumber__c,BillingAccount.ParentId,BillingAccount.Parent.AccountNumber,BillingAccount.Parent.Salutation__pc,ReturnAuthAssignment__c,
                                        BillingAccount.Parent.FirstName,BillingAccount.Parent.MiddleName,BillingAccount.Parent.LastName,
                                        BillingAccount.Parent.Suffix__pc,BillingAccount.Parent.Name,BillingAccount.MiddleName, ReferenceEntityId, CreditMemoNumber, TotalAmount, 
                                        TotalAmountWithTax, TotalChargeAmount, TotalAdjustmentAmount, TotalTaxAmount, CreditDate, 
                                        Description, Status, BillToContactId,BillToContact.IndividualNumber__c,
                                        BillToContact.FirstName,BillToContact.LastName, Balance, TaxLocaleType, JDAInvoiceCreditNumber__c, JDAInvoiceCreditNumber__r.InvoiceCredNum__c,
                                        Failed_Refund__c, associateID__c, Return_Received__c, Return_Required__c, JDACreditMemoNumber__c, 
                                        Return_Disposition_Code__c, Successfully_Processed__c, TotalAdjustmentAmountWithTax, TotalAdjustmentTaxAmount, 
                                        TotalChargeAmountWithTax, TotalChargeTaxAmount,Credit_Destination__c,
                                        (SELECT Id, AdjustmentAmountWithTax, AdjustmentTaxAmount, ChargeTaxAmount, product2.name,ReferenceEntityItem.Name,
                                         RelatedLineId, TaxName, GrossUnitPrice, ChargeAmountWithTax, ReferenceEntityItemType,RelatedLine.Name, 
                                         ReferenceEntityItemTypeCode, Description, LineAmount, TaxAmount, ChargeAmount, AdjustmentAmount,
                                         TaxRate, TaxCode, Type, StartDate, EndDate, TaxEffectiveDate, ReferenceEntityItemId, Name,Quantity__c,ReturnAuthAssignment__c,
                                         CreatedDate FROM CreditMemoLines)                                        
                                        FROM CreditMemo where Id In :sObjectIds];
        
        Map<String,ObjectWrapperForCreditMemo> mapofCreditMemoWithObjects = new Map<String,ObjectWrapperForCreditMemo>();
        Map<String,String> mapOfAccountIdWithCreditMemoId = new Map<String,String>();
        Map<String,List<String>> mapOforderSumIdWithCreditMemoId = new Map<String,List<String>>();
        Map<String,OrderPaymentSummary> mapOfCPMWithOrderPaymentSummaries = new Map<String,OrderPaymentSummary>();
        Map<String,OrderPaymentSummary> mapOfAPMWithOrderPaymentSummaries = new Map<String,OrderPaymentSummary>();
        Map<String,OrderPaymentSummary> mapOfDWWithOrderPaymentSummaries = new Map<String,OrderPaymentSummary>();
        Map<String,List<String>> mapOfOrderItemSummaryWithCreditMemo = new Map<String,List<String>>();
        Map<String,String> mapOfParentAccountIds = new Map<String,String>();
        Set<String> setOfOrderItemSumWitheGift = new Set<String>();
        for(CreditMemo crM:creditMemos){
            ObjectWrapperForCreditMemo oWrp = new ObjectWrapperForCreditMemo();
            oWrp.creditMemoObj = crM;
            Decimal amt = 0;
            for(CreditMemoLine crmLine: crM.CreditMemoLines){
                if(mapOfOrderItemSummaryWithCreditMemo.containsKey(crM.Id) ){
                 List<String> temp =   mapOfOrderItemSummaryWithCreditMemo.get(crM.Id);
                    if(crmLine.ReferenceEntityItemId!=null){
                        temp.add(crmLine.ReferenceEntityItemId);
                    }                
               mapOfOrderItemSummaryWithCreditMemo.put(crM.Id,temp);    
                }
                else{
                    if(crmLine.ReferenceEntityItemId!=null){
                     mapOfOrderItemSummaryWithCreditMemo.put(crM.Id,new List<String>{crmLine.ReferenceEntityItemId});   
                    }
                    
                }
              
                if(crmLine.product2.name == 'Shipping' && crmLine.TaxAmount!=null){
                    amt =  amt+(Decimal)crmLine.TaxAmount;
                }
            }
            oWrp.freightTaxAmt = amt;
            mapofCreditMemoWithObjects.put(crM.Id,oWrp);
            mapOfAccountIdWithCreditMemoId.put(crM.BillingAccountId,crM.Id);
            mapOfParentAccountIds.put(crM.BillingAccount.ParentId,crM.BillingAccountId);
            
                   if(mapOforderSumIdWithCreditMemoId.containsKey(crM.ReferenceEntityId)){
              List<String> temp =   mapOforderSumIdWithCreditMemoId.get(crM.ReferenceEntityId);
                temp.add(crM.Id);
               mapOforderSumIdWithCreditMemoId.put(crM.ReferenceEntityId,temp); 
            }
            else{
                mapOforderSumIdWithCreditMemoId.put(crM.ReferenceEntityId,new List<String>{crM.Id});
            }
            
        }
        List<String> listOfOrderItemIds = new List<String>();
        for(List<String> listOfstr:mapOfOrderItemSummaryWithCreditMemo.values()){
            for(String str:listOfstr){
                   listOfOrderItemIds.add(str); 
            }
        
        }
        
        system.debug('**mapOforderSumIdWithCreditMemoId** '+mapOforderSumIdWithCreditMemoId);   
        system.debug('**mapOfOrderItemSummaryWithCreditMemo**'+mapOfOrderItemSummaryWithCreditMemo);
        List<OrderItemSummary> ordrItemSums = [SELECT Id, Name, OrderSummaryId,OriginalOrderItem.TotalAdjustmentAmount,
                                               OrderSummary.OriginalOrderId,OrderSummary.associateID__c,
                                               OrderSummary.poNumber__c,OrderSummary.exchangeOrderNumber__c,ReturnAuthorizationField__c,
                                               OrderSummary.OriginalOrder.PoNumber__c,OrderSummary.OriginalOrder.OrderNumber,
                                               OrderSummary.OriginalOrder.OrderedDate,OrderSummary.OriginalOrder.CreatedDate,
                                               OrderSummary.OriginalOrder.TotalAdjustedDeliveryAmount,OrderSummary.OriginalOrder.OrderReferenceNumber,
                                               OrderSummary.OriginalOrder.exchangeOrderNumber__c,OrderSummary.OriginalOrder.SalesChannelId,OrderSummary.OriginalOrder.SalesChannel.SalesChannelName,
                                               OrderSummary.OriginalOrder.Type,OrderSummary.OriginalOrder.BillingEmailAddress,
                                               OrderSummary.OriginalOrder.TotalAdjDeliveryAmtWithTax,
                                               OrderSummary.OriginalOrder.SalesStoreId,OrderSummary.OriginalOrder.TotalTaxAmount,
                                               OrderSummary.OriginalOrder.TotalAdjustedProductAmount,
                                               OrderSummary.OriginalOrder.BillingStreet,OrderSummary.OriginalOrder.BillingCity,
                                               OrderSummary.OriginalOrder.BillingState,OrderSummary.OriginalOrder.BillingPostalCode,
                                               OrderSummary.OriginalOrder.BillingCountry,OrderSummary.OriginalOrder.associateId__c,OrderSummary.OriginalOrder.BillingPhoneNumber,
                                               OrderSummary.OriginalOrder.TotalDeliveryAdjDistAmount,          
                                               OriginalOrderItemId, OrderDeliveryGroupSummaryId,OrderDeliveryGroupSummary.OrderDeliveryMethod.ReferenceNumber,
                                               OrderDeliveryGroupSummary.OrderDeliveryMethod.Description,OrderDeliveryGroupSummary.DeliverToLocation__r.ExternalReference,
                                               ProductCode, StockKeepingUnit, LineNumber, Type, TypeCode,OrderDeliveryGroupSummary.DeliverToName,
                                               OrderDeliveryGroupSummary.DeliverToStreet,OrderDeliveryGroupSummary.DeliverToCity,
                                               OrderDeliveryGroupSummary.DeliverToCountry,OrderDeliveryGroupSummary.fromStoreId__c,OrderDeliveryGroupSummary.DeliverToState,
                                               OrderDeliveryGroupSummary.DeliverToPostalCode,
                                               ReservedAtLocationId, Quantity, ListPrice, UnitPrice, TotalPrice, AdjustedLineAmount, 
                                               TotalAdjustedLineTaxAmount, QuantityAllocated, QuantityCanceled, QuantityOrdered, Status,
                                               QuantityFulfilled, QuantityReturned, TotalTaxAmount, TotalAdjustmentAmount, TotalAdjustmentTaxAmount,
                                               TotalLineAmount, TotalLineTaxAmount, TotalLineAdjustmentAmount, TotalLineAdjustmentTaxAmount, 
                                               TotalAdjustmentDistAmount, TotalAdjustmentDistTaxAmount, ServiceDate, EndDate, Description,
                                               QuantityReturnInitiated, QuantityNetOrdered, QuantityAvailableToCancel, QuantityAvailableToReturn, 
                                               QuantityAvailableToFulfill, GrossUnitPrice, TotalAdjustmentAmtWithTax, AdjustedLineAmtWithTax, 
                                               TotalLineAdjustmentAmtWithTax, TotalAdjustmentDistAmtWithTax, TotalAmtWithTax, TotalLineAmountWithTax,
                                               QuantityShipped, Fulfillment_Location__c, dropship__c, specialOrder__c, westAdvantageProduct__c, 
                                               physicalGiftCard__c, eGiftCard__c, ocationExternalReference__c, dropshipToCustomer__c, dropshipToStore__c, 
                                               unitMeasure__c, vendorNumber__c, taxClassID__c, productForOption__c, associatedWarrantyTaxAmt__c, 
                                               associatedWarrantyProduct__c, associatedWarrantyPrice__c, associatedLoyaltyProducts__c, gcRecipientName__c, 
                                               gcRecipientEmail__c, gcMessage__c, gcFromName__c, gcFromEmail__c, vendorName__c, weight__c, notes__c, 
                                               manufacturerSKU__c, longDescription__c, Special_Order_SKU__c, vendorLocation__c, wmVanRoute__c, wmWarehouse__c,
                                               cscPriceoverrideOption__c, cscPriceoverrideReason__c, LastEmailSent__c , TotalDiscountAdjustmentAmount__c// added by Manohar, WME-128  TotalDiscountAdjustmentAmount__c
                                                FROM OrderItemSummary where Id In:listOfOrderItemIds ];
                                              
                                       


        for(OrderItemSummary ordrItmSum:ordrItemSums){
            for(String crmemoId:mapOfOrderItemSummaryWithCreditMemo.keyset()){
                if(mapOfOrderItemSummaryWithCreditMemo.get(crmemoId).contains(ordrItmSum.Id)){
                     ObjectWrapperForCreditMemo oWrp = mapofCreditMemoWithObjects.get(crmemoId);
                    oWrp.ordrItemSummaryList.add(ordrItmSum);
                    mapofCreditMemoWithObjects.put(crmemoId,oWrp);
                }
            }
            if(ordrItmSum.eGiftCard__c){
                setOfOrderItemSumWitheGift.add(ordrItmSum.Id);  
            }
            
        }


    


        List<e_GiftCard__c> eGiftCardList = [SELECT Id, Gift_Card_Number__c,Order_Product_Summary__c,Order_Product_Summary__r.Id,
                                             Order_Product_Summary__r.OrderSummaryId 
                                             FROM e_GiftCard__c where Order_Product_Summary__c In:setOfOrderItemSumWitheGift];
        
        Map<String,List<e_GiftCard__c>> mapofGiftCards = new Map<String,List<e_GiftCard__c>>();
        for(e_GiftCard__c eGf: eGiftCardList){
            if(mapofGiftCards.containsKey(eGf.Order_Product_Summary__r.Id)){
                List<e_GiftCard__c> tempList = mapofGiftCards.get(eGf.Order_Product_Summary__r.Id);
                tempList.add(eGf);
                mapofGiftCards.put(eGf.Order_Product_Summary__r.Id,tempList);
            }
            else{
                mapofGiftCards.put(eGf.Order_Product_Summary__r.Id,new List<e_GiftCard__c>{eGf});  
            }
            
        }
        
        for(String ordrItemSumId: setOfOrderItemSumWitheGift){
                     for(String crmemoId:mapOfOrderItemSummaryWithCreditMemo.keyset()){
                if(mapOfOrderItemSummaryWithCreditMemo.get(crmemoId).contains(ordrItemSumId)){
                     ObjectWrapperForCreditMemo oWrp = mapofCreditMemoWithObjects.get(crmemoId);
                    oWrp.mapOfGiftCardsWithOrderItemSum = mapofGiftCards;
                    mapofCreditMemoWithObjects.put(crmemoId,oWrp);
                }
            }
            
            
        }
        //Start WME-220
        Set<String> creditMemoIds = new Set<String>();
        
        for(CreditMemo crMs:creditMemos){
            system.debug('creditmemodetailsss'+crMs.DocumentNumber);
            system.debug('creditMemossss'+creditMemos);
            creditMemoIds.add(crms.id);
        }
        List<e_GiftCard__c> eGiftCardLists = [SELECT Gift_Card_Number__c,CreditMemo__c
                                              FROM e_GiftCard__c
                                              WHERE CreditMemo__c IN: creditMemoIds];
                                              
        //system.debug('eGiftCardLists++'+ eGiftCardLists[0].Gift_Card_Number__c);
        //giftCardNumberwithCreditMemo.add(eGiftCardLists[0].Gift_Card_Number__c);
        for(e_GiftCard__c egc : eGiftCardLists ){
            ObjectWrapperForCreditMemo oWrp = mapofCreditMemoWithObjects.get(egc.CreditMemo__c);
            oWrp.giftCardNumber = egc.Gift_Card_Number__c;
        }
        //End WME-220


       

        
        List<Account> accList =[Select Id, (Select Id, Salutation__c, Suffix__c, Address_Line_4__c, EmailAddress__c, MailCode__c, MailCodeDesc__c, 
                                            csh_van_route_seq__c, cst_reserve_whs__c, csh_van_route__c,Account__c,ReserveLocation__r.ExternalReference,ReserveLocation__c, 
                                            ActiveAddress__c, wmPreferredAddress__c, Name,First_Name__c,Last_Name__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                                            City__c,Country__c,State__c,Postal_Code__c,Phone__c FROM Addresses__r where wmPreferredAddress__c=true and ActiveAddress__c=true),
                                (Select Id,AccountId__c,State__c,Country__c,Exemption_Certificate__c,
                                 Exemption_Type__c,Expiration_Date__c,Global_Exemption__c  from Tax_Exemptions__r) 
                                from Account where Id IN:mapOfAccountIdWithCreditMemoId.keyset()];
        
        for(Account acc :accList){
            ObjectWrapperForCreditMemo oWrp  =  mapofCreditMemoWithObjects.get(mapOfAccountIdWithCreditMemoId.get(acc.Id));
            oWrp.accnt = acc;
            mapofCreditMemoWithObjects.put(mapOfAccountIdWithCreditMemoId.get(acc.Id),oWrp);
        }
        
        List<Address__c> addrList = [Select Id, Salutation__c, Suffix__c, Address_Line_4__c, EmailAddress__c, MailCode__c, MailCodeDesc__c, 
                                     csh_van_route_seq__c, cst_reserve_whs__c, csh_van_route__c,Account__c,ReserveLocation__r.ExternalReference,ReserveLocation__c, 
                                     ActiveAddress__c, wmPreferredAddress__c, Name,First_Name__c,Last_Name__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                                     City__c,Country__c,State__c,Postal_Code__c,Phone__c FROM Address__c where wmPreferredAddress__c=true and ActiveAddress__c=true
                                     and Account__c In:mapOfParentAccountIds.keyset()];
        
        for(Address__c addr:addrList){
            Map<String,Address__c> mapOfAddressesForParentAccount = new Map<String,Address__c>();
            mapOfAddressesForParentAccount.put(addr.Account__c,addr);
            ObjectWrapperForCreditMemo oWrp  =  mapofCreditMemoWithObjects.get(mapOfAccountIdWithCreditMemoId.get(mapOfParentAccountIds.get(addr.Account__c))); 
            oWrp.parentAddressMap = mapOfAddressesForParentAccount;
            mapofCreditMemoWithObjects.put(mapOfAccountIdWithCreditMemoId.get(mapOfParentAccountIds.get(addr.Account__c)),oWrp); 
        }
        
        
        List<OrderPaymentSummary> ordrPaySumList = [Select Id,Type,Method,CapturedAmount,OrderSummaryId,
                                                    Delivery_Tax_Amount__c, paymentmethodid,      
                                                    (Select Id, PaymentAuthorizationNumber,loyaltyDetails__c,loyaltyDetailsOMS__c,redeemedCerts__c, giftCardNumber__c,
                                                     gcExpiry__c,gcAuthCode__c from PaymentAuthorizations) from OrderPaymentSummary
                                                    where OrderSummaryId IN :mapOforderSumIdWithCreditMemoId.keyset() order by createddate asc];
        
        for(OrderPaymentSummary ordPaySum:ordrPaySumList){
              for(String crmId:mapOforderSumIdWithCreditMemoId.get(ordPaySum.OrderSummaryId)){
            ObjectWrapperForCreditMemo oWrp  =  mapofCreditMemoWithObjects.get(crmId);
           oWrp.ordrPaySumList.add(ordPaySum);
            mapofCreditMemoWithObjects.put(crmId,oWrp);
            }
        }


    /*    List<AggregateResult> invoiceLineInfo = [SELECT ReferenceEntityItemId,sum(VertexLOM__VertexLineAmount__c) VertexLineAmountTotal,Invoice.ReferenceEntityId ordSumId FROM InvoiceLine where ReferenceEntityItemType = 'Order Product' 
        and ReferenceEntityItemId In:listOfOrderItemIds group by ReferenceEntityItemId,Invoice.ReferenceEntityId];

        for (AggregateResult individualResult : invoiceLineInfo) {
            for(String crmId:mapOforderSumIdWithCreditMemoId.get((id)individualResult.get('ordSumId'))){
          ObjectWrapperForCreditMemo oWrp  =  mapofCreditMemoWithObjects.get(crmId);
          oWrp.invoiceLineList.add(individualResult);
          mapofCreditMemoWithObjects.put(crmId,oWrp);
          }
      } */
   
        
        if(ordrPaySumList.size()>0){   
            for(OrderPaymentSummary ops :ordrPaySumList){
                if(ops.Type!='Unknown'){
                    if(ops.Type == 'PayPal'){
                        mapOfDWWithOrderPaymentSummaries.put(ops.paymentmethodid,ops);
                    }
                    else{
                        mapOfCPMWithOrderPaymentSummaries.put(ops.paymentmethodid,ops);
                    }
                }
                else{
                    mapOfAPMWithOrderPaymentSummaries.put(ops.paymentmethodid,ops);
                }                    
            }   
        }
        
        
        List<AlternativePaymentMethod> altPayList = 
            [SELECT Id, RecordType.Name FROM AlternativePaymentMethod where Id In:mapOfAPMWithOrderPaymentSummaries.keyset()];
               Map<String,AlternativePaymentMethod> mapOfAltPay = new Map<String,AlternativePaymentMethod>();
        for(AlternativePaymentMethod altPay:altPayList){
            
            mapOfAltPay.put(mapOfAPMWithOrderPaymentSummaries.get(altPay.Id).Id,altPay);
               for(String crmId:mapOforderSumIdWithCreditMemoId.get(mapOfAPMWithOrderPaymentSummaries.get(altPay.Id).OrderSummaryId)){
            ObjectWrapperForCreditMemo oWrp  =  mapofCreditMemoWithObjects.get(crmId);
            oWrp.mapOfAlternatePayment = mapOfAltPay;
            mapofCreditMemoWithObjects.put(crmId,oWrp); 
               }
            
        }
        List<CardPaymentMethod> cardPaymentMethodList = [Select Id,GatewayToken,aurusApprovalCode__c,
                                                         ExpiryMonth,ExpiryYear,aurusPayAPTID__c, aurusPayAPTN__c, aurusPayOOT__c 
                                                         from CardPaymentMethod where Id IN:mapOfCPMWithOrderPaymentSummaries.keyset()];
        
           Map<String,CardPaymentMethod> mapOfCPM = new Map<String,CardPaymentMethod>();
        for(CardPaymentMethod cpm:cardPaymentMethodList){
            mapOfCPM.put(mapOfCPMWithOrderPaymentSummaries.get(cpm.Id).Id,cpm);
             for(String crmId:mapOforderSumIdWithCreditMemoId.get(mapOfCPMWithOrderPaymentSummaries.get(cpm.Id).OrderSummaryId)){
            ObjectWrapperForCreditMemo oWrp  =  mapofCreditMemoWithObjects.get(crmId);
            oWrp.mapOfCardPayment = mapOfCPM;
            mapofCreditMemoWithObjects.put(crmId,oWrp); 
             }
            
            
        }

        List<DigitalWallet> digitalWalletPaymentMethodList = [
            SELECT 
                Id,
                GatewayToken,
                aurusApprovalCode__c,
                aurusPayAPTID__c,
                aurusPayAPTN__c,
                aurusPayOOT__c 
            FROM DigitalWallet 
            WHERE Id IN:mapOfDWWithOrderPaymentSummaries.keyset()
        ];
        System.debug('mapOfDWWithOrderPaymentSummaries:' + mapOfDWWithOrderPaymentSummaries.keyset());

        
        Map<String,DigitalWallet> mapOfDW = new Map<String,DigitalWallet>();
        for(DigitalWallet dw : digitalWalletPaymentMethodList){
            mapOfDW.put(mapOfDWWithOrderPaymentSummaries.get(dw.Id).Id,dw);
            for(String crmId : mapOforderSumIdWithCreditMemoId.get(mapOfDWWithOrderPaymentSummaries.get(dw.Id).OrderSummaryId)){
                ObjectWrapperForCreditMemo oWrp  =  mapofCreditMemoWithObjects.get(crmId);
                oWrp.mapOfDigitalWalletPayment = mapOfDW;
                mapofCreditMemoWithObjects.put(crmId,oWrp); 
            }
        }  

        system.debug('mapofCreditMemoWithObjects '+mapofCreditMemoWithObjects.keyset());
       
         List<FeedItem> postList = new list<FeedItem>();
        for(ObjectWrapperForCreditMemo oWrp:mapofCreditMemoWithObjects.values()){
            try{
                WM_InvoiceCreditMemoWrapper wrp = new WM_InvoiceCreditMemoWrapper(oWrp.creditMemoObj.JDAInvoiceCreditNumber__r.InvoiceCredNum__c,oWrp.creditMemoObj.CreatedDate,oWrp.creditMemoObj.TotalTaxAmount,oWrp.creditMemoObj.TotalAdjustmentAmount,oWrp.creditMemoObj.Status,oWrp.creditMemoObj.TotalAmountWithTax,oWrp.creditMemoObj.Id);                
                JSONGenerator gen = WM_JSONGeneratorForCreditMemo.formtheJSONBody(oWrp,wrp);
                String payLoad = gen.getAsString();
                system.debug('payload: '+payLoad);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                String apiKey = WM_WebServiceDetails__c.getValues('InvoiceApiKey').WM_ApiKey__c;
                request.setEndpoint('callout:CreditMemoService');                
                request.setMethod('POST'); 
                request.setHeader('Content-Type','application/json');
                request.setHeader('api_key',apiKey); 
                request.setBody(payLoad);
                request.setTimeout(60000);
                System.debug('request : '+ request);
                HttpResponse response = new HttpResponse();
                response = http.send(request);
                system.debug('getStatusCode ' + response.getStatusCode());            
                system.debug('getBody ' + response.getBody());
                if(response.getStatusCode()==200){
                    CreditMemo crm = oWrp.creditMemoObj;                    
                    crm.CreditMemoServiceFlag__c = true;
                    crm.JSON_sent_to_TIBCO__c = payLoad;
                    crm.Last_Logged_Service_Error__c = 'No Error';
                    FeedItem post = new FeedItem();                    
                    post.ParentId = oWrp.creditMemoObj.ReferenceEntityId;     
                    post.Title = 'The request to Credit Memo Service was successful';
                    post.Body = 'The request to Credit Memo Service was successful';
                    postList.add(post);
                    listOfUpdatedCreditMemos.add(crm);
                }
                else{
                    CreditMemo crm = oWrp.creditMemoObj;
                    crm.Last_Logged_Service_Error__c = response.getBody() +' Status Code '+response.getStatusCode();
                    listOfUpdatedCreditMemos.add(crm);
                    FeedItem post = new FeedItem();                    
                    post.ParentId = oWrp.creditMemoObj.ReferenceEntityId;     
                    post.Title = 'The request to Credit Memo Service failed';
                    post.Body = 'The request to Credit Memo Service failed with response as  '+ response.getBody()+ 'Status Code '+response.getStatusCode();
                    postList.add(post);
                }
                
            }
            catch(Exception e){
                system.debug('Exception occured '+e);
                system.debug('Exception Line  '+e.getLineNumber());
                CreditMemo crm = oWrp.creditMemoObj;
                crm.Last_Logged_Service_Error__c = e.getMessage() + 'at Line Number '+e.getLineNumber() ;
                FeedItem post = new FeedItem();                    
                post.ParentId = oWrp.creditMemoObj.ReferenceEntityId;      
                post.Title = 'The request to Credit Memo Service failed';
                post.Body = 'The request to Credit Memo Service failed  '+ e.getMessage() + ' at Line Number '+e.getLineNumber();
                postList.add(post);
                listOfUpdatedCreditMemos.add(crm); 
            }
            
        }
        insert postList;
        update listOfUpdatedCreditMemos;
    }
}