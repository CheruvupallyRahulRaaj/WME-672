public class WM_TransactionalEmails {
    public static String  sfmcClientId     = WM_WebServiceDetails__c.getValues('sfmcClientId').WM_ApiKey__c;
    public static String  sfmcClientSecret = WM_WebServiceDetails__c.getValues('sfmcClientSecret').WM_ApiKey__c;
    public static String  sfmcAccountId    = WM_WebServiceDetails__c.getValues('sfmcAccountId').WM_ApiKey__c;
    public static String  sfmcStoreHomeLinkRetail    = WM_WebServiceDetails__c.getValues('sfmcStoreHomeLinkRetail').WM_ApiKey__c;
    public static String  sfmcStoreHomeLinkPro    = WM_WebServiceDetails__c.getValues('sfmcStoreHomeLinkPro').WM_ApiKey__c;
    public static String  storelink = sfmcStoreHomeLinkRetail;  // Default
    
    @InvocableMethod(label='EmailForCancelOrder')
    public static void emailForCancel(List<Id> ordrSumIds){
        sendEmailForCancelandReturn(ordrSumIds[0],false,true);
    }
    
    public static Map<String,Object> getAccessToken (){
        // Get Custom Settings for Marketing Cloud Auth
        
        
        // Marketing Cloud Authenticate to access token             
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:MarketingCloud');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization','Bearer Token'); 
        req.setHeader('Connection','keep-alive'); 
        String sbody = '{"grant_type":"client_credentials",';
        sbody += '"client_id":"' + sfmcClientId + '",';
        sbody += '"client_secret":"' + sfmcClientSecret + '",';
        sbody += '"scope":null,';
        sbody += '"account_id":"' + sfmcAccountId + '"}';
        req.setBody(sbody);  
        Http https = new Http();
        HTTPResponse res = new HTTPResponse();
        if(!Test.isRunningTest()) {
            res = https.send(req);    
        } else {
            res.setStatusCode(200);
            res.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsImtpZCI6IjQiLCJ2ZXIiOiIxIiwidHlwIjoiSldUIn0.eyJhY2Nlc3NfdG9rZW4iOiJZYzh1bmtvUWM1TGROZWlHeDlQeUVmMVciLCJjbGllbnRfaWQiOiJxaXpnbng0cGZlaWh6andraHRuODg3dHEiLCJlaWQiOjUxNDAwNjAxOSwic3RhY2tfa2V5IjoiUzExIiwicGxhdGZvcm1fdmVyc2lvbiI6MiwiY2xpZW50X3R5cGUiOiJTZXJ2ZXJUb1NlcnZlciJ9.-YPQrEG-zYxI3ZxuD9qo16mWw02jVPQZOW3FD86eUlI.QGbnU9n001BgyuXtpyMdN53cFLzNZsD0AFtAcuPZmYYBfGEiYT8qfQYqncmfrikMme_QLFUKeNqm81J9tGFshjFf7CvC-9VesZe1o8n3VFIyM9j0CGww9wOGe27srMilvhaXQML9Sp4Zcnq-VNURr54AS4CId33FLvQoO39ncQXOEOSyXxS","token_type":"Bearer","expires_in":1079,"scope":"offline saved_content_read saved_content_write email_read email_send email_write push_read push_send push_write web_publish web_read web_write list_and_subscribers_read list_and_subscribers_write data_extensions_read data_extensions_write file_locations_read file_locations_write tracking_events_read marketing_cloud_connect_read marketing_cloud_connect_write marketing_cloud_connect_send tracking_events_write","soap_instance_url":"https://mc7m-v93xjbl2s-kmzgzj37jsrp8.soap.marketingcloudapis.com/","rest_instance_url":"https://mc7m-v93xjbl2s-kmzgzj37jsrp8.rest.marketingcloudapis.com/"}');
        }
        system.debug('MC-Access : '+res.getBody());
        // Map return
        Map<string, Object> jsonMap = (Map<string, Object>)JSON.deserializeUntyped(res.getBody());
        System.debug('*************************************##%%%%jsonMap='+jsonMap);
        return jsonMap;
    }
    
    public static void sendEmailForCancelandReturn(String ordrSumId, Boolean returnOrder, Boolean cancelOrder){
        // ConnectApi.OrganizationSettings orgSettings = ConnectApi.Organization.getSettings();
        String sAmountCurrencySymbol = '$';
        system.debug(sAmountCurrencySymbol);
        //String sAmountCurrencyCode = OrgSettings.features.defaultCurrencyIsoCode;
        String sAmountCurrencyCode = 'USD';
        system.debug('sAmountCurrencyCode '+sAmountCurrencyCode);
        Map<String,Object> jsonMap = WM_TransactionalEmails.getAccessToken();
        String  storelink = WM_TransactionalEmails.sfmcStoreHomeLinkRetail;
        if(jsonMap.containsKey('access_token')) {
            system.debug('******Get Access Token: '+(String)jsonMap.get('access_token'));
            String token = (String)jsonMap.get('access_token');     
            
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
                    // String url = 'https://mc7m-v93xjbl2s-kmzgzj37jsrp8.rest.marketingcloudapis.com/messaging/v1/messageDefinitionSends/key:ShipmentConfirmation/send';
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
                    List<OrderItemSummary> orderLineItems =  [SELECT Id, Name, ProductCode, QuantityCanceled, 
                    OriginalOrderItem.TotalPrice,QuantityReturned,(SELECT Id, Reason FROM OrderItemSummaries) FROM OrderItemSummary
                                                              where OrderSummaryId =:ordrSumId and (QuantityCanceled!=0 Or QuantityReturned!=0)];
                    List<Map<String,String>> listOfOrderItems = new List<Map<String,String>>();
                    
                    for(OrderItemSummary oitem:orderLineItems){
                        Map<String,String> mapOfItems = new Map<String,String>();
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
                        listOfOrderItems.add(mapOfItems);
                    }
                    
                  
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
   
    public static void sendEmailForGiftCard(List<String> eGiftCardIds){
         List<e_GiftCard__c> listOfUpdatedGiftCards = new List<e_GiftCard__c>();
        //ConnectApi.OrganizationSettings orgSettings = ConnectApi.Organization.getSettings();
        String sAmountCurrencySymbol = '$';
        system.debug(sAmountCurrencySymbol);
        //String sAmountCurrencyCode = OrgSettings.features.defaultCurrencyIsoCode;
        String sAmountCurrencyCode = 'USD';
        Map<String,Object> jsonMap = WM_TransactionalEmails.getAccessToken();
        String  storelink = WM_TransactionalEmails.sfmcStoreHomeLinkRetail;
        if(jsonMap.containsKey('access_token')) {
            system.debug('******Get Access Token: '+(String)jsonMap.get('access_token'));
            String token = (String)jsonMap.get('access_token');     
            HttpRequest sreq = new HttpRequest();
            sreq.setMethod('POST');
            sreq.setHeader('Content-Type','application/json');
            
            //String url = 'https://mc7m-v93xjbl2s-kmzgzj37jsrp8.rest.marketingcloudapis.com/messaging/v1/messageDefinitionSends/key:giftCertificate.sendCertificate/send';
            //sreq.setEndpoint(url);
            sreq.setEndpoint('callout:MarketingCloudForSendGiftCertificate');
            sreq.setHeader('Authorization','Bearer ' + token );
            List<e_GiftCard__c> eGiftCrdList =  [SELECT Id, Order_Summary__c,Order_Summary__r.SalesChannel.SalesChannelName,
                                       Order_Summary__r.orderNumber,Order_Summary__r.Account.Name, Amount__c, gcRecipientName__c, gcRecipientEmail__c,
                                       gcFromName__c, Gift_Card_Number__c, Issued__c, Is_Assigned__c, gcMessage__c FROM e_GiftCard__c where Id In :eGiftCardIds];
            for(e_GiftCard__c eGiftCrd:eGiftCrdList){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            
            
            gen.writeFieldName('To');
            gen.writeStartObject();
            if(WM_Utils.getString(eGiftCrd.gcRecipientEmail__c)!=null){
                gen.writeStringField('Address', WM_Utils.getString(eGiftCrd.gcRecipientEmail__c));
            }
            if(WM_Utils.getString(eGiftCrd.gcRecipientEmail__c)!=null){
                gen.writeStringField('SubscriberKey', WM_Utils.getString(eGiftCrd.gcRecipientEmail__c));
            }
            gen.writeFieldName('ContactAttributes');
            gen.writeStartObject();
            gen.writeFieldName('SubscriberAttributes');
            gen.writeStartObject();
            if(WM_Utils.getString(eGiftCrd.gcRecipientEmail__c)!=null){
                gen.writeStringField('EmailAddress', WM_Utils.getString(eGiftCrd.gcRecipientEmail__c));
            }
            if(WM_Utils.getString(eGiftCrd.Amount__c)!=null){
                gen.writeStringField('Amount', WM_Utils.getString(eGiftCrd.Amount__c));
            }
            if(WM_Utils.getString(sAmountCurrencyCode)!=null){
                gen.writeStringField('AmountCurrencyCode', WM_Utils.getString(sAmountCurrencyCode));
            }
            if(WM_Utils.getString(eGiftCrd.Amount__c)!=null){
                gen.writeStringField('AmountDecimalValue', WM_Utils.getString(eGiftCrd.Amount__c));
            }
            if(WM_Utils.getString(eGiftCrd.Gift_Card_Number__c)!=null){
                gen.writeStringField('GiftCertificateCode', WM_Utils.getString(eGiftCrd.Gift_Card_Number__c));
            }
            if(WM_Utils.getString(eGiftCrd.gcRecipientName__c)!=null){
                gen.writeStringField('RecipientName', WM_Utils.getString(eGiftCrd.gcRecipientName__c));
            }
            if(WM_Utils.getString(eGiftCrd.gcFromName__c)!=null){
                gen.writeStringField('SenderName', WM_Utils.getString(eGiftCrd.gcFromName__c));
            }
            if(WM_Utils.getString(eGiftCrd.gcMessage__c)!=null){
                gen.writeStringField('Message', WM_Utils.getString(eGiftCrd.gcMessage__c));
            }
            if(WM_Utils.getString(storelink)!=null){
                gen.writeStringField('StoreHomeLink', WM_Utils.getString(storelink));
            }
            if(WM_Utils.getString(eGiftCrd.Order_Summary__r.SalesChannel.SalesChannelName)!=null){
                gen.writeStringField('SiteID', WM_Utils.getString(eGiftCrd.Order_Summary__r.SalesChannel.SalesChannelName));
            }
            if(WM_Utils.getString(eGiftCrd.gcRecipientEmail__c)!=null){
                gen.writeStringField('RecipientEmail', WM_Utils.getString(eGiftCrd.gcRecipientEmail__c));
            }
            if(WM_Utils.getString(eGiftCrd.Order_Summary__r.orderNumber)!=null){
                gen.writeStringField('OrderNumber', WM_Utils.getString(eGiftCrd.Order_Summary__r.orderNumber));
            }
            
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeFieldName('OPTIONS');
            gen.writeStartObject();
            gen.writeStringField('RequestType', 'ASYNC');
            gen.writeEndObject();
            gen.writeEndObject();
            String payLoad = gen.getAsString();
            system.debug('payload: '+payLoad);
            sreq.setBody(payLoad);
            Http shttps = new Http();
             HTTPResponse sres = shttps.send(sreq);
                system.debug('*************************Email Send :'+sres.getBody());  
                  if(sres.getStatusCode()==202){
                e_GiftCard__c  eGf = eGiftCrd;
                eGf.Confirmation_Email_Sent__c  = true;
                listOfUpdatedGiftCards.add(eGf);
                  }
            }  
        }
         if(listOfUpdatedGiftCards.size()>0){
         update listOfUpdatedGiftCards;   
        }
    }
    
    
    public static void sendEmailForBackOrder(List<String> ordrItemSumIds ){
        Map<String,Object> jsonMap = WM_TransactionalEmails.getAccessToken();
        String  storelink = WM_TransactionalEmails.sfmcStoreHomeLinkRetail;
        List<OrderItemSummary> listOfUpdatedOrderItemSummaries = new List<OrderItemSummary>();
        if(jsonMap.containsKey('access_token')) {
            system.debug('******Get Access Token: '+(String)jsonMap.get('access_token'));
            String token = (String)jsonMap.get('access_token');     
            HttpRequest sreq = new HttpRequest();
            sreq.setMethod('POST');
            sreq.setHeader('Content-Type','application/json');
            //String url = 'https://mc7m-v93xjbl2s-kmzgzj37jsrp8.rest.marketingcloudapis.com/messaging/v1/messageDefinitionSends/key:BackOrderDev/send';
            //sreq.setEndpoint(url);
            sreq.setEndpoint('callout:MarketingCloudForBackOrder');
            
            
            sreq.setHeader('Authorization','Bearer ' + token );
            List<OrderItemSummary> orderLineItemsList =  [SELECT Id, Name, ProductCode,Quantity,TotalPrice,QuantityOrdered,QuantityAllocated,OrderSummaryId,
                                                          OrderSummary.SalesChannel.SalesChannelName,OrderSummary.OrderNumber,OrderSummary.Account.Name,
                                                          OrderSummary.BillingEmailAddress
                                                          from OrderItemSummary where Id In:ordrItemSumIds];
            
            for(OrderItemSummary ordrItmSum:orderLineItemsList){
                JSONGenerator gen1 = JSON.createGenerator(false);
                gen1.writeStartObject();
                gen1.writeFieldName('LineItems');
                gen1.writeStartArray();
                gen1.writeStartObject();
                if(WM_Utils.getString(ordrItmSum.ProductCode)!=null){
                    gen1.writeStringField('ProductId', WM_Utils.getString(ordrItmSum.ProductCode));
                }
                if(WM_Utils.getDouble(ordrItmSum.QuantityOrdered)!=null){
                    gen1.writeNumberField('Quantity', WM_Utils.getDouble(ordrItmSum.QuantityOrdered - ordrItmSum.QuantityAllocated));
                }
                if(WM_Utils.getDouble(ordrItmSum.TotalPrice)!=null){
                    gen1.writeNumberField('TotalPrice', WM_Utils.getDouble(ordrItmSum.TotalPrice));
                }
                if(WM_Utils.getString(ordrItmSum.Name)!=null){
                    gen1.writeStringField('Name', WM_Utils.getString(ordrItmSum.Name));
                }
                gen1.writeEndObject();
                gen1.writeEndArray();
                gen1.writeFieldName('FulFillmentOrders');
                gen1.writeStartArray();
                gen1.writeEndArray();
                gen1.writeEndObject();
                
                String str = gen1.getAsString();   
                
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeFieldName('OPTIONS');
                gen.writeStartObject();
                gen.writeStringField('RequestType', 'ASYNC');
                gen.writeEndObject();
                gen.writeFieldName('To');
                gen.writeStartObject();
                gen.writeFieldName('ContactAttributes');
                gen.writeStartObject();
                gen.writeFieldName('SubscriberAttributes');
                gen.writeStartObject();
                gen.writeStringField('OrderDetailsJSON',str);
                if(WM_Utils.getString(Account.Name)!=null){
                    gen.writeStringField('AccountName', WM_Utils.getString(ordrItmSum.OrderSummary.Account.Name));
                }
                gen.writeStringField('AmountCurrencyCode', 'USD');
                gen.writeStringField('StoreHomeLink', 'https://pro.westmarine.com');
                gen.writeStringField('ShipmentID', '');
                if(WM_Utils.getString(ordrItmSum.OrderSummary.SalesChannel.SalesChannelName)!=null){
                    gen.writeStringField('SiteID', WM_Utils.getString(ordrItmSum.OrderSummary.SalesChannel.SalesChannelName));
                }
                gen.writeStringField('TrackingNumber', '');
                
                if(WM_Utils.getString(ordrItmSum.OrderSummary.OrderNumber)!=null){
                    gen.writeStringField('OrderNumber', WM_Utils.getString(ordrItmSum.OrderSummary.OrderNumber));
                }
                if(WM_Utils.getString(ordrItmSum.OrderSummary.BillingEmailAddress)!=null){
                    gen.writeStringField('EmailAddress', WM_Utils.getString(ordrItmSum.OrderSummary.BillingEmailAddress));
                }
                gen.writeEndObject();
                gen.writeEndObject();
                if(WM_Utils.getString(ordrItmSum.OrderSummary.BillingEmailAddress)!=null){
                    gen.writeStringField('SubscriberKey', WM_Utils.getString(ordrItmSum.OrderSummary.BillingEmailAddress));
                }
                if(WM_Utils.getString(ordrItmSum.OrderSummary.BillingEmailAddress)!=null){
                    gen.writeStringField('Address', WM_Utils.getString(ordrItmSum.OrderSummary.BillingEmailAddress));
                }
                gen.writeEndObject();
                gen.writeEndObject();    
                String payLoad = gen.getAsString();
                system.debug('payload: '+payLoad);
                sreq.setBody(payLoad);
                Http shttps = new Http();
                HTTPResponse sres = shttps.send(sreq);
                system.debug('*************************Email Send :'+sres.getBody());  
                  if(sres.getStatusCode()==202){
                OrderItemSummary otmSum = ordrItmSum;
                otmSum.LastEmailSent__c  = Date.today();
                listOfUpdatedOrderItemSummaries.add(otmSum);
                  }
            }
        }
        if(listOfUpdatedOrderItemSummaries.size()>0){
         update listOfUpdatedOrderItemSummaries;   
        }
        
    }
    
    public static void sendEmailForShipmentConfirmation(List<String> shipmentIds){
        System.debug('shipmentIds 384 => '+shipmentIds);
         Map<String,Object> jsonMap = WM_TransactionalEmails.getAccessToken();
        String  storelink = WM_TransactionalEmails.sfmcStoreHomeLinkRetail;
        List<Shipment> listOfUpdatedShipments = new List<Shipment>();
        if(jsonMap.containsKey('access_token')) {
            system.debug('******Get Access Token: '+(String)jsonMap.get('access_token'));
            String token = (String)jsonMap.get('access_token');     
            HttpRequest sreq = new HttpRequest();
            sreq.setMethod('POST');
            sreq.setHeader('Content-Type','application/json');
            //String url = 'https://mc7m-v93xjbl2s-kmzgzj37jsrp8.rest.marketingcloudapis.com/messaging/v1/messageDefinitionSends/key:ShipmentConfirmationDev/send';
                                   //sreq.setEndpoint(url);
            sreq.setEndpoint('callout:MarketingCloudAPI');
            
            sreq.setHeader('Authorization','Bearer ' + token );
         Map<String,ShipmentWrapper> mapofShipmentWithObjects = new Map<String,ShipmentWrapper>();
        Map<String,String> fulfillmentOrderIdMap = new Map<String,String>();
      List<Shipment> shipmentList = [SELECT Id, FulfillmentOrderId, TrackingNumber,
                                     FulfillmentOrder.OrderSummary.CreatedDate,FulfillmentOrder.OrderSummary.OrderNumber,FulfillmentOrder.FulfilledToAddress,
                                     FulfillmentOrder.FulfilledToName,FulfillmentOrder.FulfilledToStreet, 
                                     FulfillmentOrder.FulfilledToCity,FulfillmentOrder.OrderSummary.OriginalOrderId,
                                     FulfillmentOrder.FulfilledToState,FulfillmentOrder.FulfilledToPostalCode, FulfillmentOrder.FulfilledToCountry, 
                                     FulfillmentOrder.FulfilledToShippingStreet2__c, FulfillmentOrder.FulfilledToShippingStreet3__c, 
                                     FulfillmentOrder.FulfilledToShippingStreet4__c,FulfillmentOrder.AccountId,FulfillmentOrder.Account.Name,
                                     FulfillmentOrder.Account.AccountNumber,FulfillmentOrder.Type,FulfillmentOrder.Account.Salutation__pc,
                                     FulfillmentOrder.Account.FirstName,FulfillmentOrder.Account.MiddleName,FulfillmentOrder.Account.LastName,
                                     FulfillmentOrder.Account.Suffix__pc,
                                     FulfillmentOrder.Order_Delivery_Group_Summary__r.DeliverToLocation__r.ExternalReference,
                                     FulfillmentOrder.OrderSummary.GrandTotalAmount,FulfillmentOrder.OrderSummary.SalesChannelId,
                                     FulfillmentOrder.OrderSummary.SalesChannel.SalesChannelName,FulfillmentOrder.OrderSummary.BillingEmailAddress,
                                     FulfillmentOrder.OrderSummary.BillingStreet, FulfillmentOrder.OrderSummary.BillingCity, 
                                     FulfillmentOrder.OrderSummary.BillingState, FulfillmentOrder.OrderSummary.BillingPostalCode,
                                     FulfillmentOrder.OrderSummary.BillingCountry,FulfillmentOrder.TotalTaxAmount
                                     FROM Shipment Where Id IN:shipmentIds];
        for(Shipment ship:shipmentList){
              ShipmentWrapper sWrp = new ShipmentWrapper();
            sWrp.shipmentObj = ship;
            mapofShipmentWithObjects.put(ship.Id,sWrp);
            fulfillmentOrderIdMap.put(ship.FulfillmentOrderId,ship.Id);
        }
    List<FulfillmentOrderLineItem> fulfillmentLineOrderItems =  [SELECT Quantity, TotalPrice,TotalTaxAmount, Description,
                                                                                                 FulfillmentOrderId,Product2.ProductCode 
                                                                                                 FROM FulfillmentOrderLineItem where FulfillmentOrderId In:fulfillmentOrderIdMap.keySet()];
              
        for(FulfillmentOrderLineItem fulOrdrLineItm : fulfillmentLineOrderItems){
     if(mapofShipmentWithObjects.containsKey(fulfillmentOrderIdMap.get(fulOrdrLineItm.FulfillmentOrderId))){
                ShipmentWrapper sWrp  =  mapofShipmentWithObjects.get(fulfillmentOrderIdMap.get(fulOrdrLineItm.FulfillmentOrderId));    
                sWrp.fulFillmentOrderLineItems.add(fulOrdrLineItm);
                mapofShipmentWithObjects.put(fulfillmentOrderIdMap.get(fulOrdrLineItm.FulfillmentOrderId),sWrp);
            }
        }

            for(ShipmentWrapper sWrp:mapofShipmentWithObjects.values()){
                  if(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.SalesChannel.SalesChannelName == 'WestMarinePro' ){    
                                                storelink = WM_TransactionalEmails.sfmcStoreHomeLinkPro;
                                            }else{
                                                storelink = WM_TransactionalEmails.sfmcStoreHomeLinkRetail;
                                            }  
                  String payload = '{ ';
                                    payload +=  '"To": { ';
                                    payload +=  '"Address": "' + sWrp.shipmentObj.FulfillmentOrder.OrderSummary.BillingEmailAddress + '",'; 
                                    payload +=  '"SubscriberKey": "' + sWrp.shipmentObj.FulfillmentOrder.OrderSummary.BillingEmailAddress + '",';
                                    payload +=  '"ContactAttributes": { ';
                                    payload +=  '"SubscriberAttributes": { ';
                                    payload +=  '"EmailAddress": "' + sWrp.shipmentObj.FulfillmentOrder.OrderSummary.BillingEmailAddress + '",';
                                    payload +=  '"OrderNumber": "' + sWrp.shipmentObj.FulfillmentOrder.OrderSummary.OrderNumber + '",';       
                                    payload +=  '"TrackingNumber": "' + sWrp.shipmentObj.TrackingNumber + '",';  
                                    payload +=  '"SiteID": "' + sWrp.shipmentObj.FulfillmentOrder.OrderSummary.SalesChannel.SalesChannelName + '",';
                                    payload +=  '"ShipmentID": "' + sWrp.shipmentObj.Id + '",';
                                    payload +=  '"StoreHomeLink": "' + storelink + '",';
                                    payload +=  '"AmountCurrencyCode": "' + 'USD' + '",';
                                    payload +=  '"AccountName": "' + sWrp.shipmentObj.FulfillmentOrder.Account.Name + '"}}}, ';
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
                                        if(WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.TotalTaxAmount)!=null){
                                            mapOfFulFillmentOrder.put('TotalTaxAmount',WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.TotalTaxAmount));
                                        }
                                        if(WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Order_Delivery_Group_Summary__r.DeliverToLocation__r.ExternalReference)!=null){
                                            mapOfFulFillmentOrder.put('OrderType','StorePickUp');
                                        }
                                        else{
                                            mapOfFulFillmentOrder.put('OrderType','Shipped'); 
                                        }
                                        if(WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.OrderNumber)!=null){
                                            mapOfFulFillmentOrder.put('OriginaOrderNumber',WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.OrderNumber));
                                        }
                                        if(WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.CreatedDate)!=null){
                                            mapOfFulFillmentOrder.put('OrderDate',WM_Utils.getStringForDateTime(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.CreatedDate));
                                        }
                                        if(WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToStreet)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToAddressLine1', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToStreet));             
                                        }
                                        if(WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToShippingStreet2__c)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToAddressLine2', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToShippingStreet2__c));             
                                        }
                                        if(WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToShippingStreet3__c)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToAddressLine3', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToShippingStreet3__c));             
                                        }
                                        if(WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToShippingStreet4__c)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToAddressLine4', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToShippingStreet4__c));             
                                        }
                                        if(WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToCountry)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToCountry', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToCountry));             
                                        }
                                        if(WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToCity)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToCity', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToCity));             
                                        }
                                        if(WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToState)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToState', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToState));             
                                        }
                                        if(WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToPostalCode)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToPostalCode', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToPostalCode));             
                                        }
                                        if(WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToName)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToName', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.FulfilledToName));             
                                        }
                                        if(WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Order_Delivery_Group_Summary__r.DeliverToLocation__r.ExternalReference)!=null){
                                            mapOfFulFillmentOrder.put('DestinationStore', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Order_Delivery_Group_Summary__r.DeliverToLocation__r.ExternalReference));             
                                        }
                                        Map<String,String> mapOfBillToAddress = new Map<String,String>();
                                        
                                        if( WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Account.AccountNumber)!=null){
                                            mapOfBillToAddress.put('bill_to_customer_nbr', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Account.AccountNumber));
                                        }
                                        if( WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Account.Salutation__pc)!=null){
                                            mapOfBillToAddress.put('bill_to_prefix', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Account.Salutation__pc));
                                        }
                                        if( WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Account.FirstName)!=null){
                                            mapOfBillToAddress.put('bill_to_fname', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Account.FirstName));
                                        }
                                        if( WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Account.MiddleName)!=null){
                                            mapOfBillToAddress.put('bill_to_initial', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Account.MiddleName));
                                        }
                                        if( WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Account.LastName)!=null){
                                            mapOfBillToAddress.put('bill_to_lname', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Account.LastName));
                                        }
                                        if( WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Account.Suffix__pc)!=null){
                                            mapOfBillToAddress.put('bill_to_suffix', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Account.Suffix__pc));
                                        }
                                        if( WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Account.Name)!=null){
                                            mapOfBillToAddress.put( 'bill_to_company', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.Account.Name));
                                        }
                                        if( WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.BillingStreet)!=null){
                                            mapOfBillToAddress.put('bill_to_addr1', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.BillingStreet));
                                        }
                                        if( WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.BillingCity)!=null){
                                            mapOfBillToAddress.put('bill_to_city', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.BillingCity));
                                        }
                                        if( WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.BillingState)!=null){
                                            mapOfBillToAddress.put('bill_to_state', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.BillingState));
                                        }
                                        if( WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.BillingPostalCode)!=null){
                                            mapOfBillToAddress.put('bill_to_postal_code', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.BillingPostalCode));
                                        }
                                        if( WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.BillingCountry)!=null){
                                            mapOfBillToAddress.put('bill_to_country', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.BillingCountry));
                                        }
                                        if( WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.BillingEmailAddress)!=null){
                                            mapOfBillToAddress.put('email_address', WM_Utils.getString(sWrp.shipmentObj.FulfillmentOrder.OrderSummary.BillingEmailAddress));
                                        }
                                        mapOfFulFillmentOrder.put('CustomerBillToAddress',mapOfBillToAddress);
                                        listOfFullFillmentOrders.add(mapOfFulFillmentOrder);    
                               List<Map<String,String>> listOfFulfillmentOrderLineItems = new List<Map<String,String>>();
                                    for(FulfillmentOrderLineItem fL:sWrp.fulFillmentOrderLineItems){
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
                                    system.debug('*************************Status Code :'+sres.getStatusCode());  
                   if(sres.getStatusCode()==202){
                Shipment shipmnt = sWrp.shipmentObj;
                System.debug('shipmentObj 581 => '+sWrp.shipmentObj);
                shipmnt.Confirmation_Email_Sent__c  = true;
                System.debug('shipmnt 583 => '+shipmnt);
                listOfUpdatedShipments.add(shipmnt);
                  }
                
            }

        }
        System.debug('listOfUpdatedShipments 588 => '+listOfUpdatedShipments);
        if(listOfUpdatedShipments.size()>0){
         update listOfUpdatedShipments;   
        }
    }
}