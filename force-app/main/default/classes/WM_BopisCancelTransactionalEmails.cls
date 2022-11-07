public class WM_BopisCancelTransactionalEmails {
    public static String  sfmcClientId     = WM_WebServiceDetails__c.getValues('sfmcClientId').WM_ApiKey__c;
    public static String  sfmcClientSecret = WM_WebServiceDetails__c.getValues('sfmcClientSecret').WM_ApiKey__c;
    public static String  sfmcAccountId    = WM_WebServiceDetails__c.getValues('sfmcAccountId').WM_ApiKey__c;
    public static String  sfmcStoreHomeLinkRetail    = WM_WebServiceDetails__c.getValues('sfmcStoreHomeLinkRetail').WM_ApiKey__c;
    public static String  sfmcStoreHomeLinkPro    = WM_WebServiceDetails__c.getValues('sfmcStoreHomeLinkPro').WM_ApiKey__c;
    public static String  storelink = sfmcStoreHomeLinkRetail;  // Default
    
    @InvocableMethod(label='EmailForCancelBOPISOrder')
    public static void emailForCancel(List<Id> fulfillmentIds){
        // sendEmailForCancelBOPIS(ordrSumIds[0],false,true);
        sendEmailForCancelBOPIS(fulfillmentIds[0],false,true);
    }

    @future(callout = true)
    public static void sendEmailForCancelBOPIS(String fulfillmentId, Boolean returnOrder, Boolean cancelOrder){
        Map<String,Object> jsonMap = WM_TransactionalEmails.getAccessToken();
        String  storelink = WM_TransactionalEmails.sfmcStoreHomeLinkRetail;
        String sAmountCurrencySymbol = '$';
        system.debug(sAmountCurrencySymbol);
        String sAmountCurrencyCode = 'USD';
        system.debug('sAmountCurrencyCode '+sAmountCurrencyCode);
        if(jsonMap.containsKey('access_token')) {
            system.debug('******Get Access Token: '+(String)jsonMap.get('access_token'));
            String token = (String)jsonMap.get('access_token');
            List<FulFillmentOrder> lstFulfillmentOrders = [Select OrderSummaryId,Type From FulfillmentOrder WHERE Id = :fulfillmentId];
            Id ordrSumId = lstFulfillmentOrders[0].OrderSummaryId;  
            
            List<OrderSummary> OrderSummaryList = [Select Id,AccountId,GrandTotalAmount,SalesChannelId,
                                                   SalesChannel.SalesChannelName,OrderNumber,BillingEmailAddress,
                                                   BillingStreet, BillingCity, BillingState, BillingPostalCode,
                                                   BillingCountry From OrderSummary where id =:ordrSumId];
            OrderItemSummaryChange ordrItemSumChange = [SELECT Id, Reason FROM OrderItemSummaryChange where orderSummaryId =:ordrSumId limit 1];
            if(OrderSummaryList.size()>0){
                List<Account> AccountList = [Select Id, Name From Account where id =:OrderSummaryList[0].AccountId];     
                if(AccountList.size()>0){  
                    system.debug('*****************' +AccountList);
                    system.debug('*****************' +OrderSummaryList);
                    // Determine StoreLink value
                    List<SalesChannel> SalesChannelList = [Select Id,SalesChannelName From Saleschannel where id =: OrderSummaryList[0].SalesChannelId]; 
                    if(SalesChannelList.size()>0){
                        if(SalesChannelList[0].SalesChannelName != null ){  
                            if(SalesChannelList[0].SalesChannelName == 'WestMarinePro' ){    
                                storelink = sfmcStoreHomeLinkPro;
                            }else{
                                storelink = sfmcStoreHomeLinkRetail;
                            }  
                        }
                    }          
                    // Marketing Cloud Send  
                    HttpRequest sreq = new HttpRequest();
                    sreq.setMethod('POST');
                    sreq.setHeader('Content-Type','application/json');
                    String url ;
                    if(returnOrder){
                        //url = 'https://mc7m-v93xjbl2s-kmzgzj37jsrp8.rest.marketingcloudapis.com/messaging/v1/messageDefinitionSends/key:ReturnOrder/send';
                        sreq.setEndpoint('callout:MarketingCloudForReturn');
                    }
                    if(cancelOrder){
                        //url = 'https://mc7m-v93xjbl2s-kmzgzj37jsrp8.rest.marketingcloudapis.com/messaging/v1/messageDefinitionSends/key:CancelOrder/send';
                        sreq.setEndpoint('callout:MarketingCloudForCancel');
                    }
                    //sreq.setEndpoint(url);
                    sreq.setHeader('Authorization','Bearer ' + token );
                    String payload = '{ ';
                    payload +=  '"To": { ';
                    payload +=  '"Address": "' + OrderSummaryList[0].BillingEmailAddress + '",'; 
                    payload +=  '"SubscriberKey": "' + OrderSummaryList[0].BillingEmailAddress + '",';
                    payload +=  '"ContactAttributes": { ';
                    payload +=  '"SubscriberAttributes": { ';
                    payload +=  '"EmailAddress": "' + OrderSummaryList[0].BillingEmailAddress + '",';
                    payload +=  '"OrderNumber": "' + OrderSummaryList[0].OrderNumber + '",';       
                    //payload +=  '"TrackingNumber": "' + ShipmentList[0].TrackingNumber + '",';  
                    payload +=  '"SiteID": "' + OrderSummaryList[0].SalesChannel.SalesChannelName + '",';
                    //payload +=  '"ShipmentID": "' + ShipmentList[0].Id + '",';
                    payload +=  '"StoreHomeLink": "' + storelink + '",';
                    payload +=  '"AmountCurrencyCode": "' + sAmountCurrencyCode + '",';
                    payload +=  '"AccountName": "' +  AccountList[0].Name + '",';
                    payload +=  '"ReasonCode": "' + ordrItemSumChange.Reason + '"}}}, ';                    
                    payload +=  '"OPTIONS": { ';
                    payload +=  '"RequestType": "ASYNC" }}';
                    system.debug('Payload  '+payload);
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(payload);
                    Map<String,Object> to = (Map<String,Object>)m.get('To');
                    Map<String,Object> ContactAttributes = (Map<String,Object>)to.get('ContactAttributes');
                    Map<String,Object> SubscriberAttributes = (Map<String,Object>)ContactAttributes.get('SubscriberAttributes');
                    Map<String,Object> OrderDetailsJSON = new Map<String,Object>();
                    List<String> fulfillmentOrderIds = new List<String>();
                    List<Map<String,Object>> listOfFullFillmentOrders = new List<Map<String,Object>>();
                    OrderDetailsJSON.put('FulFillmentOrders',listOfFullFillmentOrders);

                    OrderDetailsJSON.put('bopis','true');
                    OrderDetailsJSON.put('shipmentType',lstFulfillmentOrders[0].Type);

                    List<OrderItemSummary> orderLineItems =  [SELECT Id, Name, ProductCode, QuantityCanceled, 
                    UnitPrice,TotalTaxAmount,TotalPrice,
                    OriginalOrderItem.TotalPrice,QuantityReturned,(SELECT Id, Reason FROM OrderItemSummaries) FROM OrderItemSummary
                                                              where OrderSummaryId =:ordrSumId and (QuantityCanceled!=0 Or QuantityReturned!=0)];
                    List<Map<String,Object>> listOfOrderItems = new List<Map<String,Object>>();

                    List<OrderSummary> lstOrderSummaries = [
                        SELECT 
                            BillingStreet,
                            BillingCity,
                            BillingState,
                            BillingPostalCode,
                            BillingCountry,
                            BillingPhoneNumber,
                            Account.AccountNumber,
                            Account.Salutation__pc,
                            Account.FirstName,
                            Account.MiddleName,
                            Account.LastName,
                            Account.Suffix__pc,
                            Account.Name,
                            BillingEmailAddress
                        FROM
                            OrderSummary
                        WHERE Id = :ordrSumId
                    ];
                    OrderSummary orderSummaryRec = null;
                    if(lstOrderSummaries.size()==1){
                        orderSummaryRec = lstOrderSummaries[0];
                    }
                    Map<String,String> mapOfBillToAddress = new Map<String,String>();

                    if( WM_Utils.getString(orderSummaryRec.Account.AccountNumber)!=null){
                        mapOfBillToAddress.put('bill_to_customer_nbr', WM_Utils.getString(orderSummaryRec.Account.AccountNumber));
                    }
                    if( WM_Utils.getString(orderSummaryRec.Account.Salutation__pc)!=null){
                        mapOfBillToAddress.put('bill_to_prefix', WM_Utils.getString(orderSummaryRec.Account.Salutation__pc));
                    }
                    if( WM_Utils.getString(orderSummaryRec.Account.FirstName)!=null){
                        mapOfBillToAddress.put('bill_to_fname', WM_Utils.getString(orderSummaryRec.Account.FirstName));
                    }
                    if( WM_Utils.getString(orderSummaryRec.Account.MiddleName)!=null){
                        mapOfBillToAddress.put('bill_to_initial', WM_Utils.getString(orderSummaryRec.Account.MiddleName));
                    }
                    if( WM_Utils.getString(orderSummaryRec.Account.LastName)!=null){
                        mapOfBillToAddress.put('bill_to_lname', WM_Utils.getString(orderSummaryRec.Account.LastName));
                    }
                    if( WM_Utils.getString(orderSummaryRec.Account.Suffix__pc)!=null){
                        mapOfBillToAddress.put('bill_to_suffix', WM_Utils.getString(orderSummaryRec.Account.Suffix__pc));
                    }
                    if( WM_Utils.getString(orderSummaryRec.Account.Name)!=null){
                        mapOfBillToAddress.put( 'bill_to_company', WM_Utils.getString(orderSummaryRec.Account.Name));
                    }
                    if( WM_Utils.getString(orderSummaryRec.BillingStreet)!=null){
                        mapOfBillToAddress.put('bill_to_addr1', WM_Utils.getString(orderSummaryRec.BillingStreet));
                    }
                    if( WM_Utils.getString(orderSummaryRec.BillingCity)!=null){
                        mapOfBillToAddress.put('bill_to_city', WM_Utils.getString(orderSummaryRec.BillingCity));
                    }
                    if( WM_Utils.getString(orderSummaryRec.BillingState)!=null){
                        mapOfBillToAddress.put('bill_to_state', WM_Utils.getString(orderSummaryRec.BillingState));
                    }
                    if( WM_Utils.getString(orderSummaryRec.BillingPostalCode)!=null){
                        mapOfBillToAddress.put('bill_to_postal_code', WM_Utils.getString(orderSummaryRec.BillingPostalCode));
                    }
                    if( WM_Utils.getString(orderSummaryRec.BillingCountry)!=null){
                        mapOfBillToAddress.put('bill_to_country', WM_Utils.getString(orderSummaryRec.BillingCountry));
                    }
                    if( WM_Utils.getString(orderSummaryRec.BillingEmailAddress)!=null){
                        mapOfBillToAddress.put('email_address', WM_Utils.getString(orderSummaryRec.BillingEmailAddress));
                    }
                    if( WM_Utils.getString(orderSummaryRec.BillingEmailAddress)!=null){
                        mapOfBillToAddress.put('phone_number', WM_Utils.getString(orderSummaryRec.BillingPhoneNumber));
                    }
                    OrderDetailsJSON.put('CustomerBillToAddress',mapOfBillToAddress);
                    
                    Decimal orderTotal = 0;
                    Decimal salesTaxTotal = 0;
                    Decimal subTotal = 0;

                    for(OrderItemSummary oitem:orderLineItems){
                        Map<String,Object> mapOfItems = new Map<String,Object>();
                        if(WM_Utils.getString(oitem.Name)!=null){
                            mapOfItems.put('Name',WM_Utils.getString(oitem.Name));
                        }
                        if(WM_Utils.getString(oitem.OriginalOrderItem.TotalPrice)!=null){
                            mapOfItems.put('TotalPrice',WM_Utils.getString(oitem.OriginalOrderItem.TotalPrice));
                        }
                        if(returnOrder){
                            if(WM_Utils.getString(oitem.QuantityReturned)!=null){
                                mapOfItems.put('Quantity',WM_Utils.getString(oitem.QuantityReturned));
                            } 
                        }
                        else if(cancelOrder){
                            if(WM_Utils.getString(oitem.QuantityCanceled)!=null){
                                mapOfItems.put('Quantity',WM_Utils.getString(oitem.QuantityCanceled));
                            }    
                        }
                        
                        if(WM_Utils.getString(oitem.ProductCode)!=null){
                            mapOfItems.put('ProductId',WM_Utils.getString(oitem.ProductCode));
                        }
                        if(WM_Utils.getString(oitem.OrderItemSummaries[0].Reason)!=null){
                            
                            mapOfItems.put('ReasonCode',WM_Utils.getString(oitem.OrderItemSummaries[0].Reason));
                        }

                        if( WM_Utils.getString(oitem.UnitPrice)!=null){
                            subTotal +=oitem.UnitPrice;
                        }
                        if( WM_Utils.getString(oitem.TotalTaxAmount)!=null){
                            salesTaxTotal += oitem.TotalTaxAmount;
                        }
                        if( WM_Utils.getString(oitem.TotalPrice)!=null){
                            orderTotal += oitem.TotalPrice;
                        }
                        // mapOfItems.put('Totals',mapOfTotals);
                        // OrderDetailsJSON.put('Totals',mapOfTotals);

                        listOfOrderItems.add(mapOfItems);
                    }
                    
                    Map<String,String> mapOfTotals = new Map<String,String>();
                    mapOfTotals .put('subtotal', String.valueOf(subTotal));
                    mapOfTotals .put('sales_tax', String.valueOf(salesTaxTotal));
                    mapOfTotals .put('order_total', String.valueOf(orderTotal));
                    OrderDetailsJSON.put('Totals',mapOfTotals);


                    List<Map<String,String>> listOfPayments = new List<Map<String,String>>();
                    List<OrderPaymentSummary> lstPaymentSummaries = [
                        SELECT
                            Id,
                            PaymentMethodId
                        FROM OrderPaymentSummary 
                        WHERE OrderSummaryId = :ordrSumId
                    ];

                    Set<Id> alternativePayments = new Set<ID>();
                    Set<Id> cardPayments = new Set<ID>();
                    Set<Id> digitalWallets = new Set<ID>();
                    for(OrderPaymentSummary ordPaymentSummary : lstPaymentSummaries){
                        string keyPrefixOfPaymentMethodID = String.valueOf(ordPaymentSummary.PaymentMethodId).substring(0,3);
                        if(String.ValueOf(ordPaymentSummary.PaymentMethodId).startsWith('8Z7')){
                            alternativePayments.add(ordPaymentSummary.PaymentMethodId);
                        }
                        else if(String.ValueOf(ordPaymentSummary.PaymentMethodId).startsWith('03O')){
                            cardPayments.add(ordPaymentSummary.PaymentMethodId);
                        }
                        else if( keyPrefixOfPaymentMethodID!=null && keyPrefixOfPaymentMethodID == DigitalWallet.SObjectType.getDescribe().getKeyPrefix()){
                            digitalWallets.add(ordPaymentSummary.PaymentMethodId);
                        }
                    }

                    if(cardPayments.size() > 0){

                        List<CardPaymentMethod> lstCardPayments = [
                            SELECT
                                CardType,
                                CardLastFour,
                                ExpiryMonth,
                                ExpiryYear
                            FROM
                                CardPaymentMethod
                            WHERE 
                                ID IN :cardPayments
                        ];

                        for(CardPaymentMethod card : lstCardPayments){
                            Map<String,String> mapOfCardPayments = new Map<String,String>();
                            if(WM_Utils.getString(card.CardType)!=null){
                                mapOfCardPayments.put('type',WM_Utils.getString(card.CardType));
                            }
                            if(WM_Utils.getString(card.CardLastFour)!=null){
                                mapOfCardPayments.put('number',WM_Utils.getString(card.CardLastFour));
                            }
                            if(WM_Utils.getString(card.ExpiryMonth)!=null){
                                mapOfCardPayments.put('expiryMonth',WM_Utils.getString(card.ExpiryMonth));
                            }
                            if(WM_Utils.getString(card.ExpiryYear)!=null){
                                mapOfCardPayments.put('expiryYear',WM_Utils.getString(card.ExpiryYear));
                            }
                            listOfPayments.add(mapOfCardPayments);
                        }
                    }
                    if(alternativePayments.size() > 0){

                        List<AlternativePaymentMethod> lstAlternativeMethods = [
                            SELECT
                                giftCardNumber__c,
                                gcExpiry__c
                            FROM
                                AlternativePaymentMethod
                            WHERE 
                                ID IN :alternativePayments
                        ];

                        for(AlternativePaymentMethod altPayment : lstAlternativeMethods){
                            Map<String,String> mapOfAlternatePayments = new Map<String,String>();
                            mapOfAlternatePayments.put('type','giftcard');
                            if(WM_Utils.getString(altPayment.giftCardNumber__c)!=null){
                                mapOfAlternatePayments.put('number',WM_Utils.getString(altPayment.giftCardNumber__c));
                            }
                            if(WM_Utils.getString(altPayment.giftCardNumber__c)!=null){
                                mapOfAlternatePayments.put('gcExpiry__c',WM_Utils.getString(altPayment.giftCardNumber__c));
                            }
                            listOfPayments.add(mapOfAlternatePayments);
                        }
                    }
                    if(digitalWallets.size() > 0){
                        List<DigitalWallet> lstDigitalWallets = [
                            SELECT
                                Type
                            FROM
                                DigitalWallet
                            WHERE 
                                ID IN :digitalWallets
                        ];

                        for(DigitalWallet wallet : lstDigitalWallets){
                            Map<String,String> mapOfDigitalWallets = new Map<String,String>();
                            if(WM_Utils.getString(wallet.Type)!=null){
                                mapOfDigitalWallets.put('type',WM_Utils.getString(wallet.Type));
                            }
                            listOfPayments.add(mapOfDigitalWallets);
                        }
                    }
                    OrderDetailsJSON.put('Payment',listOfPayments);
                    
                  
                    OrderDetailsJSON.put('LineItems',listOfOrderItems);
                    SubscriberAttributes.put('OrderDetailsJSON', JSON.serialize(OrderDetailsJSON));
                    ContactAttributes.put('SubscriberAttributes',SubscriberAttributes);
                    to.put('ContactAttributes',ContactAttributes);  
                    m.put('To',to);
                    String finalJSON = JSON.serializePretty(m);
                    system.debug('Final JSON '+finalJSON);
                    sreq.setBody(finalJSON);
                    Http shttps = new Http();
                    HTTPResponse sres = shttps.send(sreq);
                    system.debug('*************************Email Send :'+sres.getBody());    
                    
                }}
            
        }
        
    }
}