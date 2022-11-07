public class WM_CancelDiscontinuedItemsEmails {
    public static String  sfmcClientId     = WM_WebServiceDetails__c.getValues('sfmcClientId').WM_ApiKey__c;
    public static String  sfmcClientSecret = WM_WebServiceDetails__c.getValues('sfmcClientSecret').WM_ApiKey__c;
    public static String  sfmcAccountId    = WM_WebServiceDetails__c.getValues('sfmcAccountId').WM_ApiKey__c;
    public static String  sfmcStoreHomeLinkRetail    = WM_WebServiceDetails__c.getValues('sfmcStoreHomeLinkRetail').WM_ApiKey__c;
    public static String  sfmcStoreHomeLinkPro    = WM_WebServiceDetails__c.getValues('sfmcStoreHomeLinkPro').WM_ApiKey__c;
    public static String  storelink = sfmcStoreHomeLinkRetail;  // Default
    
    @InvocableMethod(label='EmailForCancelDiscontinuedItems')
    public static void emailForCancel(List<Id> orderProductSumIds){
        System.debug('OPS Id in the input :: ' +orderProductSumIds[0]);
        sendEmailForCancelDiscontinuedItems(orderProductSumIds[0],false,true);
    }
    
    /*@InvocableMethod(label='EmailForCancelDiscontinuedItems')
    public static void emailForCancel(List<Id> OPSId){
        sendEmailForCancelDiscontinuedItems(orderSumIds[0],false,true);
    }*/
    
    @future(callout = true)
    public static void sendEmailForCancelDiscontinuedItems(String OPSId, Boolean returnOrder, Boolean cancelOrder){
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
            List<OrderItemSummary> lstOPS = [Select OrderSummaryId,Type From OrderItemSummary WHERE Id = :OPSId];
            Id ordrSumId = lstOPS[0].OrderSummaryId;
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
                        url = 'https://mc7m-v93xjbl2s-kmzgzj37jsrp8.rest.marketingcloudapis.com/messaging/v1/messageDefinitionSends/key:ReturnOrder/send';
                        
                    }
                    if(cancelOrder){
                        url = 'https://mc7m-v93xjbl2s-kmzgzj37jsrp8.rest.marketingcloudapis.com/messaging/v1/messageDefinitionSends/key:CancelOrder/send';
                        
                    }
                    // String url = 'https://mc7m-v93xjbl2s-kmzgzj37jsrp8.rest.marketingcloudapis.com/messaging/v1/messageDefinitionSends/key:ShipmentConfirmation/send';
                    sreq.setEndpoint(url);
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
                    String statusCode = String.valueOf(sres.getStatusCode());
                    
                    if(statusCode!=null && statusCode.startsWith('2'))
                    {
                        system.debug('######Success'+sres.getStatusCode());
                    }
                    else{
                        system.debug('######Failure'+sres.getStatusCode());
                    }
                    
                }}
            
        }
}
}