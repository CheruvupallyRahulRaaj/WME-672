public class WM_NewInvoiceService {

     @InvocableMethod(label='InvoiceService')
    public static void callInvoiceService (List<String> sObjectIds) {
        List<Invoice> listOfUpdatedInvoices = new List<Invoice>();
        List<Invoice> invoices = [Select Id,BillingAccountId,BillingAccount.Sales_Person_Number__c,BillingAccount.AccountSource,BillingAccount.IsPersonAccount,BillingAccount.Cust_Payment_Class__c,BillingAccount.Associate__c,
                                  BillingAccount.AccountNumber,BillingAccount.associateID__c,BillingAccount.SoldToNumber__c,BillingAccount.Salutation__pc,BillingAccount.FirstName,BillingAccount.LastName,
                                  BillingAccount.Suffix__pc,BillingAccount.Name,BillingAccount.PersonEmail,BillingAccount.PersonMobilePhone,BillingAccount.Email__c,BillingAccount.Phone,
                                  BillingAccount.cst_tax_code__c,BillingAccount.loyaltyAccountNumber__c,BillingAccount.ParentId,BillingAccount.Parent.AccountNumber,BillingAccount.Parent.Salutation__pc,
                                  BillingAccount.Parent.FirstName,BillingAccount.Parent.MiddleName,BillingAccount.Parent.LastName,
                                  BillingAccount.Parent.Suffix__pc,BillingAccount.Parent.Name,BillingAccount.MiddleName,
                                  ReferenceEntityId,BillToContactId ,BillToContact.IndividualNumber__c,
                                  BillToContact.FirstName,BillToContact.LastName,InvoiceServiceFlag__c,InvoiceName__r.InvoiceCredNum__c,
                                  CreatedDate,TotalTaxAmount,TotalAdjustmentAmount,Status,TotalAmountWithTax,Last_Logged_Service_Error__c,                                      
                                  (SELECT Id, Amount,PaymentId,Payment.OrderPaymentSummaryId FROM PaymentLinesInvoice),
                                  (Select Id,ReferenceEntityItemId,
                                   LineAmount,ReferenceEntityItem.Name,Quantity, UnitPrice, ChargeAmount, TaxAmount, AdjustmentAmount, Description, 
                                   InvoiceLineStartDate, InvoiceLineEndDate, ReferenceEntityItemType, ReferenceEntityItemTypeCode, 
                                   Product2Id,Product2.Name,RelatedLineId, Type, TaxName, TaxCode, TaxRate, TaxEffectiveDate, GrossUnitPrice, 
                                   ChargeTaxAmount, ChargeAmountWithTax, AdjustmentTaxAmount, AdjustmentAmountWithTax from InvoiceLines)  
                                  from Invoice where Id In:sObjectIds];
        
        
        
        Map<String,ObjectWrapper> mapofInvoiceWithObjects = new Map<String,ObjectWrapper>();
        Map<String,String> mapOfAccountIdWithInvoiceId = new Map<String,String>();
        Map<String,List<String>> mapOforderSumIdWithInvoiceId = new Map<String,List<String>>();
         Map<String,String> mapOfInvoiceIdWithOrderSumIds = new Map<String,String>();
        Map<String,OrderPaymentSummary> mapOfCPMWithOrderPaymentSummaries = new Map<String,OrderPaymentSummary>();
        Map<String,OrderPaymentSummary> mapOfAPMWithOrderPaymentSummaries = new Map<String,OrderPaymentSummary>();
        Map<String,OrderPaymentSummary> mapOfDWWithOrderPaymentSummaries = new Map<String,OrderPaymentSummary>();
        Map<String,String> mapOfOrderItemSummaryWithInvoice = new Map<String,String>();
        Map<String,String> mapOfParentAccountIds = new Map<String,String>();
        Set<Id> fullfillmentOrderIds = new Set<Id>();
        Set<String> setOfOrderItemSumWitheGift = new Set<String>();
        Map<String,String> mapOforderItemSumWithInvoiceId = new Map<String,String>();
        for(Invoice inv:invoices){
            ObjectWrapper oWrp = new ObjectWrapper();
            oWrp.invoiceObj = inv;
            Decimal amt = 0;
            for(InvoiceLine invLine: inv.InvoiceLines){
                mapOfOrderItemSummaryWithInvoice.put(invLine.ReferenceEntityItemId,inv.Id);
                if(invLine.product2.name == 'Shipping' && invLine.TaxAmount!=null){
                    amt =  amt+(Decimal)invLine.TaxAmount;
                }
            }
            oWrp.freightTaxAmt = amt;
            mapofInvoiceWithObjects.put(inv.Id,oWrp);
            mapOfAccountIdWithInvoiceId.put(inv.BillingAccountId,inv.Id);
            mapOfParentAccountIds.put(inv.BillingAccount.ParentId,inv.BillingAccountId);
            if(mapOforderSumIdWithInvoiceId.containsKey(inv.ReferenceEntityId)){
              List<String> temp =   mapOforderSumIdWithInvoiceId.get(inv.ReferenceEntityId);
                temp.add(inv.Id);
               mapOforderSumIdWithInvoiceId.put(inv.ReferenceEntityId,temp); 
            }
            else{
                mapOforderSumIdWithInvoiceId.put(inv.ReferenceEntityId,new List<String>{inv.Id});
            }
           
            
        }
        
        List<FulFillmentOrder> fOrderList = [Select Id, AccountId, DeliveryMethodId,  FulfillmentOrderNumber,
                                   FulfilledFromLocationId, FulfilledToName, FulfilledToStreet,
                                   FulfilledToCity, FulfilledToState, FulfilledToPostalCode, FulfilledToCountry, FulfilledToLatitude,
                                   FulfilledToLongitude, FulfilledToGeocodeAccuracy, FulfilledToAddress, FulfilledToEmailAddress, 
                                   FulfilledToPhone, ItemCount, Status, StatusCategory, Type, TypeCategory, TotalProductAmount, 
                                   TotalAdjustmentAmount, TotalDeliveryAmount, TotalProductTaxAmount, TotalAdjustmentTaxAmount, 
                                   TotalDeliveryTaxAmount, TotalAmount, TotalTaxAmount, OrderId, OrderSummaryId, 
                                   InvoiceId, GrandTotalAmount, IsSuspended, TotalDeliveryAdjustAmount, TotalDeliveryAdjustTaxAmount,
                                   TaxLocaleType, BillToContactId, TotalProductAmtWithTax, TotalAdjustmentAmtWithTax,
                                   TotalDeliveryAmtWithTax, TotalDeliveryAdjustAmtWithTax,
                                   FulfilledToShippingStreet2__c,FulfilledToShippingStreet3__c,FulfilledToShippingStreet4__c,
                                   van_route__c,van_route_seq_nbr__c,JDAFulfillmentOrderNumber__c,FulfilledFromLocation.ExternalReference,
                                   FulfilledFromLocation.LocationType,
                                   OrderSummary.OriginalOrderId,OrderSummary.associateID__c,
                                   OrderSummary.poNumber__c,OrderSummary.exchangeOrderNumber__c,
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
                                   OrderSummary.OriginalOrder.TotalDeliveryAdjDistAmount from FulfillmentOrder where InvoiceId IN:sObjectIds];
        
              for(FulFillmentOrder fOrdr:fOrderList){
                  fullfillmentOrderIds.add( fOrdr.Id );
            if(mapofInvoiceWithObjects.containsKey(fOrdr.InvoiceId)){
                ObjectWrapper oWrp  =  mapofInvoiceWithObjects.get(fOrdr.InvoiceId);    
                oWrp.listOfFulfillmentOrders.add(fOrdr);
                mapofInvoiceWithObjects.put(fOrdr.InvoiceId,oWrp);
            }
              }
        
        List<FulFillmentOrder> fulfillmentOrderList = [Select Id,InvoiceId,JDAFulfillmentOrderNumber__c,(Select Id,Quantity,UnitPrice,TotalPrice,Quantity_Received__c,Quantity_Credited__c,TotalAdjustmentAmount,TotalTaxAmount,TotalLineAmount,TotalLineTaxAmount,Quantity_Fulfilled__c,
                                                                            OriginalQuantity,OrderItemId,OrderItemSummaryId,Product2Id,OrderItemSummary.QuantityReturned,OrderItemSummary.QuantityOrdered,OrderItemSummary.associatedLoyaltyProducts__c,
                                                                            OrderItemSummary.OrderDeliveryGroupSummary.DeliverToLocation__r.ExternalReference,OrderItemSummary.TotalTaxAmount,OrderItemSummary.AdjustedLineAmount,
                                                                            OrderItemSummary.OrderDeliveryGroupSummary.OrderDeliveryMethod.ReferenceNumber,OrderItemSummary.QuantityFulfilled,OrderItemSummary.TotalAdjustedLineTaxAmount,
                                                                            OrderItemSummary.OrderDeliveryGroupSummary.OrderDeliveryMethod.Description,OrderItemSummary.OrderDeliveryGroupSummary.fromStoreId__c,OrderItemSummary.eGiftCard__c,OrderItemSummary.Type,
                                                                            OrderItemSummary.UnitPrice,OrderItemSummary.TotalPrice,OrderItemSummary.TotalAdjustmentAmount,OrderItemSummary.TotalLineAmount,OrderItemSummary.TotalLineTaxAmount,OrderItemSummary.associatedWarrantyProduct__c,OrderItemSummary.ProductCode,
                                                                            OrderItemSummary.associatedWarrantyPrice__c,OrderItemSummary.dropship__c,OrderItemSummary.associatedWarrantyTaxAmt__c,OrderItemSummary.Special_Order_SKU__c
                                                                            from FulfillmentOrderLineItems where  type = 'Order Product' and Quantity > 0 order by CreatedDate asc)
                                                       ,
                                                       (Select Id,TrackingNumber,CreatedDate from FulfillmentOrderShipments)
                                                       from FulfillmentOrder where Id IN:fullfillmentOrderIds];
        
        for(FulFillmentOrder fOrdr:fulfillmentOrderList){
            if(mapofInvoiceWithObjects.containsKey(fOrdr.InvoiceId)){
                ObjectWrapper oWrp  =  mapofInvoiceWithObjects.get(fOrdr.InvoiceId);    
                oWrp.fulFillmentOrders.add(fOrdr);
                mapofInvoiceWithObjects.put(fOrdr.InvoiceId,oWrp);
            }
            for(FulfillmentOrderLineItem fLineItm :fOrdr.FulfillmentOrderLineItems){
                if(fLineItm.OrderItemSummary.eGiftCard__c){
                    setOfOrderItemSumWitheGift.add(fLineItm.OrderItemSummaryId);
                    mapOforderItemSumWithInvoiceId.put(fLineItm.OrderItemSummaryId,fOrdr.InvoiceId);
                }
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
            ObjectWrapper oWrp  =  mapofInvoiceWithObjects.get(mapOforderItemSumWithInvoiceId.get(ordrItemSumId));    
            oWrp.mapOfGiftCardsWithOrderItemSum = mapofGiftCards; 
            mapofInvoiceWithObjects.put(mapOforderItemSumWithInvoiceId.get(ordrItemSumId),oWrp);  
            
        }
        
        
        List<Account> accList =[Select Id, (Select Id, Salutation__c, Suffix__c, Address_Line_4__c, EmailAddress__c, MailCode__c, MailCodeDesc__c, 
                                            csh_van_route_seq__c, cst_reserve_whs__c, csh_van_route__c,Account__c,ReserveLocation__r.ExternalReference,ReserveLocation__c, 
                                            ActiveAddress__c, wmPreferredAddress__c, Name,First_Name__c,Last_Name__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                                            City__c,Country__c,State__c,Postal_Code__c,Phone__c FROM Addresses__r where wmPreferredAddress__c=true and ActiveAddress__c=true),
                                (Select Id,AccountId__c,State__c,Country__c,Exemption_Certificate__c,
                                 Exemption_Type__c,Expiration_Date__c,Global_Exemption__c  from Tax_Exemptions__r) 
                                from Account where Id IN:mapOfAccountIdWithInvoiceId.keyset()];
        
        
        for(Account acc :accList){
            ObjectWrapper oWrp  =  mapofInvoiceWithObjects.get(mapOfAccountIdWithInvoiceId.get(acc.Id));
            oWrp.accnt = acc;
            mapofInvoiceWithObjects.put(mapOfAccountIdWithInvoiceId.get(acc.Id),oWrp);
        }
        
        List<Address__c> addrList = [Select Id, Salutation__c, Suffix__c, Address_Line_4__c, EmailAddress__c, MailCode__c, MailCodeDesc__c, 
                                     csh_van_route_seq__c, cst_reserve_whs__c, csh_van_route__c,Account__c,ReserveLocation__r.ExternalReference,ReserveLocation__c, 
                                     ActiveAddress__c, wmPreferredAddress__c, Name,First_Name__c,Last_Name__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                                     City__c,Country__c,State__c,Postal_Code__c,Phone__c FROM Address__c where wmPreferredAddress__c=true and ActiveAddress__c=true
                                     and Account__c In:mapOfParentAccountIds.keyset()];
        
        for(Address__c addr:addrList){
            Map<String,Address__c> mapOfAddressesForParentAccount = new Map<String,Address__c>();
            mapOfAddressesForParentAccount.put(addr.Account__c,addr);
            ObjectWrapper oWrp  =  mapofInvoiceWithObjects.get(mapOfAccountIdWithInvoiceId.get(mapOfParentAccountIds.get(addr.Account__c))); 
            oWrp.parentAddressMap = mapOfAddressesForParentAccount;
            mapofInvoiceWithObjects.put(mapOfAccountIdWithInvoiceId.get(mapOfParentAccountIds.get(addr.Account__c)),oWrp); 
        }
        
        
        List<OrderPaymentSummary> ordrPaySumList = [Select Id,Type,Method,CapturedAmount,OrderSummaryId,
                                                    Delivery_Tax_Amount__c, paymentmethodid,      
                                                    (Select Id, PaymentAuthorizationNumber,loyaltyDetails__c,loyaltyDetailsOMS__c,redeemedCerts__c, giftCardNumber__c,
                                                     gcExpiry__c,gcAuthCode__c,FutureTerms__c from PaymentAuthorizations) from OrderPaymentSummary
                                                    where OrderSummaryId IN :mapOforderSumIdWithInvoiceId.keyset() order by createddate asc];
        for(OrderPaymentSummary ordPaySum:ordrPaySumList){
            for(String invId:mapOforderSumIdWithInvoiceId.get(ordPaySum.OrderSummaryId)){
            ObjectWrapper oWrp  =  mapofInvoiceWithObjects.get(invId);
            oWrp.ordrPaySumList.add(ordPaySum);
            mapofInvoiceWithObjects.put(invId,oWrp);
            }
           
        }
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
               for(String invId:mapOforderSumIdWithInvoiceId.get(mapOfAPMWithOrderPaymentSummaries.get(altPay.Id).OrderSummaryId)){
            ObjectWrapper oWrp  =  mapofInvoiceWithObjects.get(invId);
            oWrp.mapOfAlternatePayment = mapOfAltPay;
            mapofInvoiceWithObjects.put(invId,oWrp); 
               }
               }
        List<CardPaymentMethod> cardPaymentMethodList = [Select Id,GatewayToken,aurusApprovalCode__c,
                                                         ExpiryMonth,ExpiryYear,aurusPayAPTID__c, aurusPayAPTN__c, aurusPayOOT__c 
                                                         from CardPaymentMethod where Id IN:mapOfCPMWithOrderPaymentSummaries.keyset()];
        
        Map<String,CardPaymentMethod> mapOfCPM = new Map<String,CardPaymentMethod>();
        for(CardPaymentMethod cpm:cardPaymentMethodList){
            
            mapOfCPM.put(mapOfCPMWithOrderPaymentSummaries.get(cpm.Id).Id,cpm);
             for(String invId:mapOforderSumIdWithInvoiceId.get(mapOfCPMWithOrderPaymentSummaries.get(cpm.Id).OrderSummaryId)){
            ObjectWrapper oWrp  =  mapofInvoiceWithObjects.get(invId);
            oWrp.mapOfCardPayment = mapOfCPM;
            mapofInvoiceWithObjects.put(invId,oWrp); 
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
            for(String invId : mapOforderSumIdWithInvoiceId.get(mapOfDWWithOrderPaymentSummaries.get(dw.Id).OrderSummaryId)){
                ObjectWrapper oWrp  =  mapofInvoiceWithObjects.get(invId);
                oWrp.mapOfDigitalWalletPayment = mapOfDW;
                mapofInvoiceWithObjects.put(invId,oWrp); 
            }
        }  
        system.debug('mapofInvoiceWithObjects '+mapofInvoiceWithObjects.keyset());
        List<FeedItem> postList = new list<FeedItem>();
        for(ObjectWrapper oWrp:mapofInvoiceWithObjects.values()){
            try{
                system.debug('**invoice** '+oWrp.invoiceObj);
                 system.debug('**OrderPaymentSummaryForTheInvoices** '+oWrp.ordrPaySumList);
                WM_InvoiceCreditMemoWrapper wrp = new WM_InvoiceCreditMemoWrapper(oWrp.invoiceObj.InvoiceName__r.InvoiceCredNum__c,oWrp.invoiceObj.CreatedDate,oWrp.invoiceObj.TotalTaxAmount,oWrp.invoiceObj.TotalAdjustmentAmount,oWrp.invoiceObj.Status,oWrp.invoiceObj.TotalAmountWithTax,oWrp.invoiceObj.Id);                
                JSONGenerator gen = WM_JSONGeneratorForInvoice.formtheJSONBody(oWrp,wrp);
                String payLoad = gen.getAsString();
                system.debug('payload: '+payLoad);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                String apiKey = WM_WebServiceDetails__c.getValues('InvoiceApiKey').WM_ApiKey__c;
                request.setEndpoint('callout:InvoiceService');                
                request.setMethod('POST'); 
                request.setHeader('Content-Type','application/json');
                request.setHeader('api_key',apiKey); 
                request.setBody(payLoad);
                request.setTimeout(120000);
                System.debug('request : '+ request);
                HttpResponse response = new HttpResponse();
                response = http.send(request);
                system.debug('getStatusCode ' + response.getStatusCode());            
                system.debug('getBody ' + response.getBody());
                if(response.getStatusCode()==200){
                    System.debug('Inside If');
                    Invoice inv = oWrp.invoiceObj;
                    inv.InvoiceServiceFlag__c = true;
                    inv.Last_Logged_Service_Error__c = 'No Error';
                    inv.JSON_sent_to_TIBCO__c = payLoad;
                    listOfUpdatedInvoices.add(inv);
                    system.debug('payload again: '+payLoad);
                     FeedItem post = new FeedItem();                    
                    post.ParentId = oWrp.listOfFulfillmentOrders[0].Id;     
                    post.Title = 'The request to Invoice Service was successful';
                    post.Body = 'The request to Invoice Service was successful';
                    postList.add(post);
                }
                else{
                    Invoice inv = oWrp.invoiceObj;                    
                    inv.InvoiceServiceFlag__c = false;
                    inv.Last_Logged_Service_Error__c = response.getBody() +'Status Code '+response.getStatusCode();
                    listOfUpdatedInvoices.add(inv);
                    FeedItem post = new FeedItem();                    
                    post.ParentId = oWrp.listOfFulfillmentOrders[0].Id;     
                    post.Title = 'The request to Invoice Service failed';
                    post.Body = 'The request to Invoice Service failed with response as  '+ response.getBody()+ 'Status Code '+response.getStatusCode();
                postList.add(post);
                }
                
            }
            catch(Exception e){
                system.debug('Exception occured '+e);
                system.debug('Exception Line  '+e.getStackTraceString());
                system.debug('Exception Line  '+e.getLineNumber());
                system.debug('Exception Line  cause  '+e.getCause());
                Invoice inv = oWrp.invoiceObj;
                inv.InvoiceServiceFlag__c = false;
                inv.Last_Logged_Service_Error__c = e.getMessage() + 'at Line Number '+e.getLineNumber() ;
                FeedItem post = new FeedItem();                    
                post.ParentId = oWrp.listOfFulfillmentOrders[0].Id;     
                post.Title = 'The request to Invoice Service failed';
                post.Body = 'The request to Invoice Service failed  '+ e.getMessage() + ' at Line Number '+e.getLineNumber();
                postList.add(post);
                listOfUpdatedInvoices.add(inv); 
            }
            
        }
          insert postList;
          update listOfUpdatedInvoices;
          system.debug('listOfUpdatedInvoices'+listOfUpdatedInvoices);
    }
}