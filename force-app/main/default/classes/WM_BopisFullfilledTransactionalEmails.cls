public class WM_BopisFullfilledTransactionalEmails {
    public static String  sfmcClientId     = WM_WebServiceDetails__c.getValues('sfmcClientId').WM_ApiKey__c;
    public static String  sfmcClientSecret = WM_WebServiceDetails__c.getValues('sfmcClientSecret').WM_ApiKey__c;
    public static String  sfmcAccountId    = WM_WebServiceDetails__c.getValues('sfmcAccountId').WM_ApiKey__c;
    public static String  sfmcStoreHomeLinkRetail    = WM_WebServiceDetails__c.getValues('sfmcStoreHomeLinkRetail').WM_ApiKey__c;
    public static String  sfmcStoreHomeLinkPro    = WM_WebServiceDetails__c.getValues('sfmcStoreHomeLinkPro').WM_ApiKey__c;
    public static String  storelink = sfmcStoreHomeLinkRetail;  // Default
    
    @InvocableMethod(label='EmailForFullfilledOrder')
    public static void emailForFullfilled(List<Id> fulfillmentIds){
        sendEmailForPickedUp(fulfillmentIds[0]);
    }

    // public static Map<String,Object> getAccessToken (){
    //     // Get Custom Settings for Marketing Cloud Auth
        
    //     // Marketing Cloud Authenticate to access token             
    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint('callout:MarketingCloud');
    //     req.setMethod('POST');
    //     req.setHeader('Content-Type','application/json');
    //     req.setHeader('Authorization','Bearer Token'); 
    //     req.setHeader('Connection','keep-alive'); 
    //     String sbody = '{"grant_type":"client_credentials",';
    //     sbody += '"client_id":"' + sfmcClientId + '",';
    //     sbody += '"client_secret":"' + sfmcClientSecret + '",';
    //     sbody += '"scope":null,';
    //     sbody += '"account_id":"' + sfmcAccountId + '"}';
    //     req.setBody(sbody);  
    //     Http https = new Http();
    //     HTTPResponse res = new HTTPResponse();
    //     if(!Test.isRunningTest()) {
    //         res = https.send(req);    
    //     } else {
    //         res.setStatusCode(200);
    //         res.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsImtpZCI6IjQiLCJ2ZXIiOiIxIiwidHlwIjoiSldUIn0.eyJhY2Nlc3NfdG9rZW4iOiJZYzh1bmtvUWM1TGROZWlHeDlQeUVmMVciLCJjbGllbnRfaWQiOiJxaXpnbng0cGZlaWh6andraHRuODg3dHEiLCJlaWQiOjUxNDAwNjAxOSwic3RhY2tfa2V5IjoiUzExIiwicGxhdGZvcm1fdmVyc2lvbiI6MiwiY2xpZW50X3R5cGUiOiJTZXJ2ZXJUb1NlcnZlciJ9.-YPQrEG-zYxI3ZxuD9qo16mWw02jVPQZOW3FD86eUlI.QGbnU9n001BgyuXtpyMdN53cFLzNZsD0AFtAcuPZmYYBfGEiYT8qfQYqncmfrikMme_QLFUKeNqm81J9tGFshjFf7CvC-9VesZe1o8n3VFIyM9j0CGww9wOGe27srMilvhaXQML9Sp4Zcnq-VNURr54AS4CId33FLvQoO39ncQXOEOSyXxS","token_type":"Bearer","expires_in":1079,"scope":"offline saved_content_read saved_content_write email_read email_send email_write push_read push_send push_write web_publish web_read web_write list_and_subscribers_read list_and_subscribers_write data_extensions_read data_extensions_write file_locations_read file_locations_write tracking_events_read marketing_cloud_connect_read marketing_cloud_connect_write marketing_cloud_connect_send tracking_events_write","soap_instance_url":"https://mc7m-v93xjbl2s-kmzgzj37jsrp8.soap.marketingcloudapis.com/","rest_instance_url":"https://mc7m-v93xjbl2s-kmzgzj37jsrp8.rest.marketingcloudapis.com/"}');
    //     }
    //     system.debug('MC-Access : '+res.getBody());
    //     // Map return
    //     Map<string, Object> jsonMap = (Map<string, Object>)JSON.deserializeUntyped(res.getBody());
    //     System.debug('*************************************##%%%%jsonMap='+jsonMap);
    //     return jsonMap;
    // }

    public static void sendEmailForPickedUp(string fulFillmentOrderId){
        Map<String,Object> jsonMap = WM_TransactionalEmails.getAccessToken();
        String  storelink = WM_TransactionalEmails.sfmcStoreHomeLinkRetail;
        if(jsonMap.containsKey('access_token')) {
            system.debug('******Get Access Token: '+(String)jsonMap.get('access_token'));
            String token = (String)jsonMap.get('access_token');     
            HttpRequest sreq = new HttpRequest();
            sreq.setMethod('POST');
            sreq.setHeader('Content-Type','application/json');
            //String url = 'https://mc7m-v93xjbl2s-kmzgzj37jsrp8.rest.marketingcloudapis.com/messaging/v1/messageDefinitionSends/key:StorePickupConfirmation/send';
            sreq.setEndpoint('callout:MarketingCloudForpickupConfirmation');                       
            //sreq.setEndpoint(url);
            
            sreq.setHeader('Authorization','Bearer ' + token );


            List<FulFillmentOrder> fulFillmentOrderRecords = [
                SELECT 
                    Id, 
                    FulfilledFromLocation.Name,
                    OrderSummary.Id,
                    OrderSummary.BillingEmailAddress,
                    OrderSummary.OrderNumber,
                    OrderSummary.SalesChannel.SalesChannelName,
                    OrderSummary.CreatedDate,
                    Account.Name,
                    Order_Delivery_Group_Summary__r.DeliverToLocation__r.ExternalReference,
                    FulfilledToStreet,
                    FulfilledToShippingStreet2__c,
                    FulfilledToShippingStreet3__c,
                    FulfilledToShippingStreet4__c,
                    FulfilledToCountry,
                    FulfilledToCity,
                    FulfilledToState,
                    FulfilledToPostalCode,
                    FulfilledToName,
                    Account.AccountNumber,
                    Account.Salutation__pc,
                    Account.FirstName,
                    Account.MiddleName,
                    Account.LastName,
                    Account.Suffix__pc,
                    OrderSummary.BillingStreet,
                    OrderSummary.BillingCity,
                    OrderSummary.BillingState,
                    OrderSummary.BillingPostalCode,
                    OrderSummary.BillingCountry,
                    OrderSummary.BillingPhoneNumber,
                    TotalProductAmount,
                    TotalDeliveryAmount,
                    TotalTaxAmount,
                    GrandTotalAmount
                FROM FulFillmentOrder 
                WHERE 
                    Id = :fulFillmentOrderId
            ];
            if(fulFillmentOrderRecords.size() == 1){
                FulFillmentOrder fulFillmentOrderRec = fulFillmentOrderRecords[0];
                string ordrSumId = fulFillmentOrderRec.OrderSummaryId;

                if(fulFillmentOrderRec.OrderSummary.SalesChannel.SalesChannelName == 'WestMarinePro' ){    
                    storelink = WM_TransactionalEmails.sfmcStoreHomeLinkPro;
                }else{
                    storelink = WM_TransactionalEmails.sfmcStoreHomeLinkRetail;
                }  

                String payload = '{ ';
                payload +=  '"To": { ';
                payload +=  '"Address": "' + fulFillmentOrderRec.OrderSummary.BillingEmailAddress + '",'; 
                payload +=  '"SubscriberKey": "' + fulFillmentOrderRec.OrderSummary.BillingEmailAddress + '",';
                payload +=  '"ContactAttributes": { ';
                payload +=  '"SubscriberAttributes": { ';
                payload +=  '"EmailAddress": "' + fulFillmentOrderRec.OrderSummary.BillingEmailAddress + '",';
                payload +=  '"OrderNumber": "' + fulFillmentOrderRec.OrderSummary.OrderNumber + '",';       
                // payload +=  '"TrackingNumber": "' + sWrp.shipmentObj.TrackingNumber + '",';  
                payload +=  '"SiteID": "' + fulFillmentOrderRec.OrderSummary.SalesChannel.SalesChannelName + '",';
                // payload +=  '"ShipmentID": "' + sWrp.shipmentObj.Id + '",';
                payload +=  '"StoreHomeLink": "' + storelink + '",';
                payload +=  '"AmountCurrencyCode": "' + 'USD' + '",';
                payload +=  '"AccountName": "' + fulFillmentOrderRec.Account.Name + '"}}}, ';
                payload +=  '"OPTIONS": { ';
                payload +=  '"RequestType": "ASYNC" }}';
                system.debug('Payload  '+payload);

                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(payload);
                Map<String,Object> to = (Map<String,Object>)m.get('To');
                Map<String,Object> ContactAttributes = (Map<String,Object>)to.get('ContactAttributes');
                Map<String,Object> SubscriberAttributes = (Map<String,Object>)ContactAttributes.get('SubscriberAttributes');
                Map<String,Object> OrderDetailsJSON = new Map<String,Object>();
                List<Map<String,Object>> listOfFullFillmentOrders = new List<Map<String,Object>>();
                Map<String,Object> mapOfFulFillmentOrder = new Map<String,Object>();
                if(WM_Utils.getString(fulFillmentOrderRec.Order_Delivery_Group_Summary__r.DeliverToLocation__r.ExternalReference)!=null){
                    mapOfFulFillmentOrder.put('OrderType','StorePickUp');
                }
                else{
                    mapOfFulFillmentOrder.put('OrderType','Shipped'); 
                }
                if(WM_Utils.getString(fulFillmentOrderRec.FulfilledFromLocation.Name)!=null){
                    mapOfFulFillmentOrder.put('StoreId',WM_Utils.getString(fulFillmentOrderRec.FulfilledFromLocation.Name));
                }
                if(WM_Utils.getString(fulFillmentOrderRec.OrderSummary.OrderNumber)!=null){
                    mapOfFulFillmentOrder.put('OriginaOrderNumber',WM_Utils.getString(fulFillmentOrderRec.OrderSummary.OrderNumber));
                }
                if(WM_Utils.getString(fulFillmentOrderRec.OrderSummary.CreatedDate)!=null){
                    mapOfFulFillmentOrder.put('OrderDate',WM_Utils.getStringForDateTime(fulFillmentOrderRec.OrderSummary.CreatedDate));
                }
                if(WM_Utils.getString(fulFillmentOrderRec.FulfilledToStreet)!=null){
                    mapOfFulFillmentOrder.put('FulfilledToAddressLine1', WM_Utils.getString(fulFillmentOrderRec.FulfilledToStreet));             
                }
                if(WM_Utils.getString(fulFillmentOrderRec.FulfilledToShippingStreet2__c)!=null){
                    mapOfFulFillmentOrder.put('FulfilledToAddressLine2', WM_Utils.getString(fulFillmentOrderRec.FulfilledToShippingStreet2__c));             
                }
                if(WM_Utils.getString(fulFillmentOrderRec.FulfilledToShippingStreet3__c)!=null){
                    mapOfFulFillmentOrder.put('FulfilledToAddressLine3', WM_Utils.getString(fulFillmentOrderRec.FulfilledToShippingStreet3__c));             
                }
                if(WM_Utils.getString(fulFillmentOrderRec.FulfilledToShippingStreet4__c)!=null){
                    mapOfFulFillmentOrder.put('FulfilledToAddressLine4', WM_Utils.getString(fulFillmentOrderRec.FulfilledToShippingStreet4__c));             
                }
                if(WM_Utils.getString(fulFillmentOrderRec.FulfilledToCountry)!=null){
                    mapOfFulFillmentOrder.put('FulfilledToCountry', WM_Utils.getString(fulFillmentOrderRec.FulfilledToCountry));             
                }
                if(WM_Utils.getString(fulFillmentOrderRec.FulfilledToCity)!=null){
                    mapOfFulFillmentOrder.put('FulfilledToCity', WM_Utils.getString(fulFillmentOrderRec.FulfilledToCity));             
                }
                if(WM_Utils.getString(fulFillmentOrderRec.FulfilledToState)!=null){
                    mapOfFulFillmentOrder.put('FulfilledToState', WM_Utils.getString(fulFillmentOrderRec.FulfilledToState));             
                }
                if(WM_Utils.getString(fulFillmentOrderRec.FulfilledToPostalCode)!=null){
                    mapOfFulFillmentOrder.put('FulfilledToPostalCode', WM_Utils.getString(fulFillmentOrderRec.FulfilledToPostalCode));             
                }
                if(WM_Utils.getString(fulFillmentOrderRec.FulfilledToName)!=null){
                    mapOfFulFillmentOrder.put('FulfilledToName', WM_Utils.getString(fulFillmentOrderRec.FulfilledToName));             
                }
                if(WM_Utils.getString(fulFillmentOrderRec.Order_Delivery_Group_Summary__r.DeliverToLocation__r.ExternalReference)!=null){
                    mapOfFulFillmentOrder.put('DestinationStore', WM_Utils.getString(fulFillmentOrderRec.Order_Delivery_Group_Summary__r.DeliverToLocation__r.ExternalReference));             
                }
                Map<String,String> mapOfBillToAddress = new Map<String,String>();
                
                if( WM_Utils.getString(fulFillmentOrderRec.Account.AccountNumber)!=null){
                    mapOfBillToAddress.put('bill_to_customer_nbr', WM_Utils.getString(fulFillmentOrderRec.Account.AccountNumber));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.Account.Salutation__pc)!=null){
                    mapOfBillToAddress.put('bill_to_prefix', WM_Utils.getString(fulFillmentOrderRec.Account.Salutation__pc));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.Account.FirstName)!=null){
                    mapOfBillToAddress.put('bill_to_fname', WM_Utils.getString(fulFillmentOrderRec.Account.FirstName));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.Account.MiddleName)!=null){
                    mapOfBillToAddress.put('bill_to_initial', WM_Utils.getString(fulFillmentOrderRec.Account.MiddleName));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.Account.LastName)!=null){
                    mapOfBillToAddress.put('bill_to_lname', WM_Utils.getString(fulFillmentOrderRec.Account.LastName));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.Account.Suffix__pc)!=null){
                    mapOfBillToAddress.put('bill_to_suffix', WM_Utils.getString(fulFillmentOrderRec.Account.Suffix__pc));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.Account.Name)!=null){
                    mapOfBillToAddress.put( 'bill_to_company', WM_Utils.getString(fulFillmentOrderRec.Account.Name));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.OrderSummary.BillingStreet)!=null){
                    mapOfBillToAddress.put('bill_to_addr1', WM_Utils.getString(fulFillmentOrderRec.OrderSummary.BillingStreet));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.OrderSummary.BillingCity)!=null){
                    mapOfBillToAddress.put('bill_to_city', WM_Utils.getString(fulFillmentOrderRec.OrderSummary.BillingCity));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.OrderSummary.BillingState)!=null){
                    mapOfBillToAddress.put('bill_to_state', WM_Utils.getString(fulFillmentOrderRec.OrderSummary.BillingState));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.OrderSummary.BillingPostalCode)!=null){
                    mapOfBillToAddress.put('bill_to_postal_code', WM_Utils.getString(fulFillmentOrderRec.OrderSummary.BillingPostalCode));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.OrderSummary.BillingCountry)!=null){
                    mapOfBillToAddress.put('bill_to_country', WM_Utils.getString(fulFillmentOrderRec.OrderSummary.BillingCountry));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.OrderSummary.BillingEmailAddress)!=null){
                    mapOfBillToAddress.put('email_address', WM_Utils.getString(fulFillmentOrderRec.OrderSummary.BillingEmailAddress));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.OrderSummary.BillingEmailAddress)!=null){
                    mapOfBillToAddress.put('phone_number', WM_Utils.getString(fulFillmentOrderRec.OrderSummary.BillingPhoneNumber));
                }
                mapOfFulFillmentOrder.put('CustomerBillToAddress',mapOfBillToAddress);

                Map<String,String> mapOfTotals = new Map<String,String>();
                if( WM_Utils.getString(fulFillmentOrderRec.TotalProductAmount)!=null){
                    mapOfTotals .put('subtotal', WM_Utils.getString(fulFillmentOrderRec.TotalProductAmount));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.TotalDeliveryAmount)!=null){
                    mapOfTotals .put('shipping', WM_Utils.getString(fulFillmentOrderRec.TotalDeliveryAmount));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.TotalTaxAmount)!=null){
                    mapOfTotals .put('sales_tax', WM_Utils.getString(fulFillmentOrderRec.TotalTaxAmount));
                }
                if( WM_Utils.getString(fulFillmentOrderRec.GrandTotalAmount)!=null){
                    mapOfTotals .put('order_total', WM_Utils.getString(fulFillmentOrderRec.GrandTotalAmount));
                }
                mapOfFulFillmentOrder.put('Totals',mapOfTotals);

                
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
                mapOfFulFillmentOrder.put('Payment',listOfPayments);

                


                listOfFullFillmentOrders.add(mapOfFulFillmentOrder);

                List<FulfillmentOrderLineItem> fulfillmentLineOrderItems =  [
                    SELECT 
                        Quantity,
                        TotalPrice,
                        Description,
                        FulfillmentOrderId,
                        Product2.ProductCode
                    FROM 
                        FulfillmentOrderLineItem 
                    WHERE 
                        FulfillmentOrderId = :fulFillmentOrderId
                ];
                List<Map<String,String>> listOfFulfillmentOrderLineItems = new List<Map<String,String>>();
                for(FulfillmentOrderLineItem fL:fulfillmentLineOrderItems){
                    Map<String,String> mapOfFulfillmentOrderLineItem = new Map<String,String>();
                    if(WM_Utils.getString(fL.Description)!=null){
                        mapOfFulfillmentOrderLineItem.put('Name',WM_Utils.getString(fL.Description));
                    }
                    if(WM_Utils.getString(fL.TotalPrice)!=null){
                        mapOfFulfillmentOrderLineItem.put('TotalPrice',WM_Utils.getString(fL.TotalPrice));
                    }
                    if(WM_Utils.getString(fL.Quantity)!=null){
                        mapOfFulfillmentOrderLineItem.put('Quantity',WM_Utils.getString(fL.Quantity));
                    }
                    if(WM_Utils.getString(fL.Product2.ProductCode)!=null){
                        mapOfFulfillmentOrderLineItem.put('ProductId',WM_Utils.getString(fL.Product2.ProductCode));
                    }
                    listOfFulfillmentOrderLineItems.add(mapOfFulfillmentOrderLineItem);
                }
                OrderDetailsJSON.put('FulFillmentOrders',listOfFullFillmentOrders);
                OrderDetailsJSON.put('LineItems',listOfFulfillmentOrderLineItems);
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
            }
        }
    }
}