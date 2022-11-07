public class WM_ShipmentConfirmationTriggeredSend {
    
    public class msgInput {
        @InvocableVariable(required=true)
        public String sShipmentId;
        
        
    }
    
    public class msgOutput {
        @InvocableVariable(required=true)
        public String strmsg;
    }
    
    @future(callout=true)
    public static void sendEmail(List<String> shipmentIds){
        List<WM_ShipmentConfirmationTriggeredSend.msgInput> msgInputList = new List<WM_ShipmentConfirmationTriggeredSend.msgInput>();
        for(String sId: shipmentIds){               
            WM_ShipmentConfirmationTriggeredSend.msgInput m = new WM_ShipmentConfirmationTriggeredSend.msgInput();
            m.sShipmentId = sId;
            msgInputList.add(m);
        }
        List<msgOutput> output = sendTGiftCardTriggeredSend(msgInputList);
    }
    
    @InvocableMethod(label = 'Invoke Shipment Confirmation MC Email test') 
    public static List<msgOutput> sendTGiftCardTriggeredSend(List<msgInput> msgInputs) {
        
        //ConnectApi.OrganizationSettings orgSettings = ConnectApi.Organization.getSettings();
        String sAmountCurrencySymbol = '$';
        system.debug(sAmountCurrencySymbol);
        //String sAmountCurrencyCode = OrgSettings.features.defaultCurrencyIsoCode;
        String sAmountCurrencyCode = 'USD';
        
        SCCFileLogger logger = SCCFileLogger.getInstance();
        List<msgOutput> msgOutputs = new List<msgOutput>();
        msgOutput msgOutput = new msgOutput(); 
        
        for (msgInput msgInput : msgInputs) {
            
            if(msgInput.sShipmentId != null ){
                
              Map<String,Object> jsonMap = WM_TransactionalEmails.getAccessToken();
                String  storelink = WM_TransactionalEmails.sfmcStoreHomeLinkRetail;
                if(jsonMap.containsKey('access_token')) {
                    system.debug('******Get Access Token: '+(String)jsonMap.get('access_token'));
                    String token = (String)jsonMap.get('access_token');     
                    
                    //Get Data to Populate Send
                    List<Shipment> ShipmentList = [SELECT Id, FulfillmentOrderId, TrackingNumber FROM Shipment Where Id =: msgInput.sShipmentId];
                    system.debug('*****************' +ShipmentList);
                    if(ShipmentList.size()>0){
                        List<FulfillmentOrder> FulfillmentOrderList = [Select Id,OrderSummary.CreatedDate,OrderSummary.OrderNumber,FulfilledToAddress,
                                                                       FulfilledToName,FulfilledToStreet, FulfilledToCity,OrderSummary.OriginalOrderId,
                                                                       FulfilledToState, FulfilledToPostalCode, FulfilledToCountry, 
                                                                       FulfilledToShippingStreet2__c, FulfilledToShippingStreet3__c, 
                                                                       FulfilledToShippingStreet4__c,AccountId,Type,
                                                                       Order_Delivery_Group_Summary__r.DeliverToLocation__r.ExternalReference  
                                                                       From FulfillmentOrder where id =:ShipmentList[0].FulfillmentOrderId];
                        
                        if(FulfillmentOrderList.size()>0){
                            List<OrderSummary> OrderSummaryList = [Select Id,AccountId,GrandTotalAmount,SalesChannelId,SalesChannel.SalesChannelName,OrderNumber,BillingEmailAddress,BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry From OrderSummary where id =:FulfillmentOrderList[0].OrderSummaryId];
                            if(OrderSummaryList.size()>0){
                                List<Account> AccountList = [Select Id, Name From Account where id =:OrderSummaryList[0].AccountId];     
                                if(AccountList.size()>0){  
                                    system.debug('*****************' +AccountList);
                                    system.debug('*****************' +OrderSummaryList);
                                    system.debug('*****************' +FulfillmentOrderList);
                                    system.debug('*****************' +ShipmentList); 
                                    // Determine StoreLink value
                                    List<SalesChannel> SalesChannelList = [Select Id,SalesChannelName From Saleschannel where id =: OrderSummaryList[0].SalesChannelId]; 
                                    if(SalesChannelList.size()>0){
                                        if(SalesChannelList[0].SalesChannelName != null ){  
                                            if(SalesChannelList[0].SalesChannelName == 'WestMarinePro' ){    
                                                storelink = WM_TransactionalEmails.sfmcStoreHomeLinkPro;
                                            }else{
                                                storelink = WM_TransactionalEmails.sfmcStoreHomeLinkRetail;
                                            }  
                                        }
                                    }  
                                    system.debug('*****************' +SalesChannelList);  
                                    system.debug('*****************' +storelink);          
                                    // Marketing Cloud Send  
                                    HttpRequest sreq = new HttpRequest();
                                    sreq.setMethod('POST');
                                    sreq.setHeader('Content-Type','application/json');
                                    //String url = 'https://mc7m-v93xjbl2s-kmzgzj37jsrp8.rest.marketingcloudapis.com/messaging/v1/messageDefinitionSends/key:ShipmentConfirmation/send';
                                    //sreq.setEndpoint(url);
                                    sreq.setEndpoint('callout:MarketingCloudAPI');
                                    sreq.setHeader('Authorization','Bearer ' + token );
                                    String payload = '{ ';
                                    payload +=  '"To": { ';
                                    payload +=  '"Address": "' + OrderSummaryList[0].BillingEmailAddress + '",'; 
                                    payload +=  '"SubscriberKey": "' + OrderSummaryList[0].BillingEmailAddress + '",';
                                    payload +=  '"ContactAttributes": { ';
                                    payload +=  '"SubscriberAttributes": { ';
                                    payload +=  '"EmailAddress": "' + OrderSummaryList[0].BillingEmailAddress + '",';
                                    payload +=  '"OrderNumber": "' + OrderSummaryList[0].OrderNumber + '",';       
                                    payload +=  '"TrackingNumber": "' + ShipmentList[0].TrackingNumber + '",';  
                                    payload +=  '"SiteID": "' + OrderSummaryList[0].SalesChannel.SalesChannelName + '",';
                                    payload +=  '"ShipmentID": "' + ShipmentList[0].Id + '",';
                                    payload +=  '"StoreHomeLink": "' + storelink + '",';
                                    payload +=  '"AmountCurrencyCode": "' + sAmountCurrencyCode + '",';
                                    payload +=  '"AccountName": "' + AccountList[0].Name + '"}}}, ';
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
                                    
                                    for(FulfillmentOrder fO:FulfillmentOrderList){
                                        Map<String,Object> mapOfFulFillmentOrder = new Map<String,Object>();
                                        if(WM_Utils.getString(fO.Order_Delivery_Group_Summary__r.DeliverToLocation__r.ExternalReference)!=null){
                                            mapOfFulFillmentOrder.put('OrderType','StorePickUp');
                                        }
                                        else{
                                            mapOfFulFillmentOrder.put('OrderType','Shipped'); 
                                        }
                                        if(WM_Utils.getString(fO.OrderSummary.OrderNumber)!=null){
                                            mapOfFulFillmentOrder.put('OriginaOrderNumber',WM_Utils.getString(fO.OrderSummary.OrderNumber));
                                        }
                                        if(WM_Utils.getString(fO.OrderSummary.CreatedDate)!=null){
                                            mapOfFulFillmentOrder.put('OrderDate',WM_Utils.getStringForDateTime(fO.OrderSummary.CreatedDate));
                                        }
                                        if(WM_Utils.getString(fO.FulfilledToStreet)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToAddressLine1', WM_Utils.getString(fO.FulfilledToStreet));             
                                        }
                                        if(WM_Utils.getString(fO.FulfilledToShippingStreet2__c)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToAddressLine2', WM_Utils.getString(fO.FulfilledToShippingStreet2__c));             
                                        }
                                        if(WM_Utils.getString(fO.FulfilledToShippingStreet3__c)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToAddressLine3', WM_Utils.getString(fO.FulfilledToShippingStreet3__c));             
                                        }
                                        if(WM_Utils.getString(fO.FulfilledToShippingStreet4__c)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToAddressLine4', WM_Utils.getString(fO.FulfilledToShippingStreet4__c));             
                                        }
                                        if(WM_Utils.getString(fO.FulfilledToCountry)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToCountry', WM_Utils.getString(fO.FulfilledToCountry));             
                                        }
                                        if(WM_Utils.getString(fO.FulfilledToCity)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToCity', WM_Utils.getString(fO.FulfilledToCity));             
                                        }
                                        if(WM_Utils.getString(fO.FulfilledToState)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToState', WM_Utils.getString(fO.FulfilledToState));             
                                        }
                                        if(WM_Utils.getString(fO.FulfilledToPostalCode)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToPostalCode', WM_Utils.getString(fO.FulfilledToPostalCode));             
                                        }
                                        if(WM_Utils.getString(fO.FulfilledToName)!=null){
                                            mapOfFulFillmentOrder.put('FulfilledToName', WM_Utils.getString(fO.FulfilledToName));             
                                        }
                                        if(WM_Utils.getString(fO.Order_Delivery_Group_Summary__r.DeliverToLocation__r.ExternalReference)!=null){
                                            mapOfFulFillmentOrder.put('DestinationStore', WM_Utils.getString(fO.Order_Delivery_Group_Summary__r.DeliverToLocation__r.ExternalReference));             
                                        }
                                        Order ordr = WM_ServiceHelper.getOrder(fO.OrderSummary.OriginalOrderId); 
                                        Account acc =  WM_ServiceHelper.getAccount(fO.AccountId);
                                        Map<String,String> mapOfBillToAddress = new Map<String,String>();
                                        
                                        if( WM_Utils.getString(acc.AccountNumber)!=null){
                                            mapOfBillToAddress.put('bill_to_customer_nbr', WM_Utils.getString(acc.AccountNumber));
                                        }
                                        if( WM_Utils.getString(acc.Salutation__pc)!=null){
                                            mapOfBillToAddress.put('bill_to_prefix', WM_Utils.getString(acc.Salutation__pc));
                                        }
                                        if( WM_Utils.getString(acc.FirstName)!=null){
                                            mapOfBillToAddress.put('bill_to_fname', WM_Utils.getString(acc.FirstName));
                                        }
                                        if( WM_Utils.getString(acc.MiddleName)!=null){
                                            mapOfBillToAddress.put('bill_to_initial', WM_Utils.getString(acc.MiddleName));
                                        }
                                        if( WM_Utils.getString(acc.LastName)!=null){
                                            mapOfBillToAddress.put('bill_to_lname', WM_Utils.getString(acc.LastName));
                                        }
                                        if( WM_Utils.getString(acc.Suffix__pc)!=null){
                                            mapOfBillToAddress.put('bill_to_suffix', WM_Utils.getString(acc.Suffix__pc));
                                        }
                                        if( WM_Utils.getString(acc.Name)!=null){
                                            mapOfBillToAddress.put( 'bill_to_company', WM_Utils.getString(acc.Name));
                                        }
                                        if( WM_Utils.getString(ordr.BillingStreet)!=null){
                                            mapOfBillToAddress.put('bill_to_addr1', WM_Utils.getString(ordr.BillingStreet));
                                        }
                                        if( WM_Utils.getString(acc.BillingCity)!=null){
                                            mapOfBillToAddress.put('bill_to_city', WM_Utils.getString(ordr.BillingCity));
                                        }
                                        if( WM_Utils.getString(acc.BillingState)!=null){
                                            mapOfBillToAddress.put('bill_to_state', WM_Utils.getString(ordr.BillingState));
                                        }
                                        if( WM_Utils.getString(acc.BillingPostalCode)!=null){
                                            mapOfBillToAddress.put('bill_to_postal_code', WM_Utils.getString(ordr.BillingPostalCode));
                                        }
                                        if( WM_Utils.getString(acc.BillingCountry)!=null){
                                            mapOfBillToAddress.put('bill_to_country', WM_Utils.getString(ordr.BillingCountry));
                                        }
                                        if( WM_Utils.getString(ordr.BillingEmailAddress)!=null){
                                            mapOfBillToAddress.put('email_address', WM_Utils.getString(ordr.BillingEmailAddress));
                                        }
                                        mapOfFulFillmentOrder.put('CustomerBillToAddress',mapOfBillToAddress);
                                        listOfFullFillmentOrders.add(mapOfFulFillmentOrder);
                                        fulfillmentOrderIds.add(fO.Id);
                                    }
                                    List<FulfillmentOrderLineItem> fulfillmentLineOrderItems =  [SELECT Quantity, TotalPrice, Description,
                                                                                                 FulfillmentOrderId,Product2.ProductCode 
                                                                                                 FROM FulfillmentOrderLineItem where FulfillmentOrderId In:fulfillmentOrderIds];
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
                                    
                                    msgOutput.strmsg = 'Email was sent';
                                    msgOutputs.add(msgOutput);
                                    
                                }}}
                        
                    }else{       
                        msgOutput.strmsg = 'Triggered Send was not Authorized' ;
                        msgOutputs.add(msgOutput);
                    }
                }
            }
            
        }
        
        system.debug('*******END Return***************' + msgOutputs);
        return msgOutputs; 
    }
    
    
    
    
}