public class WM_InvoiceServiceStoSQueueable implements Queueable,Database.AllowsCallouts {
    private List<String> ordrFulfillmntIds;
    public WM_InvoiceServiceStoSQueueable(List<String> fulFillIds){
        this.ordrFulfillmntIds = fulFillIds;
    }
    public void execute(QueueableContext context) {
        system.debug('called  from WM_InvoiceServiceStoSQueueable');
        if(ordrFulfillmntIds.size()>0){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String apiKey = WM_WebServiceDetails__c.getValues('InvoiceApiKey').WM_ApiKey__c;
            
            request.setMethod('POST'); 
            request.setHeader('Content-Type','application/json');
            request.setHeader('api_key',apiKey); 
            request.setEndpoint('callout:InvoiceServiceStoreToStore');
            FulfillmentOrder fulfillmentOrder = new FulfillmentOrder();
            OrderDeliveryMethod ordrDelMethod = new OrderDeliveryMethod();
            OrderDeliveryGroupSummary ordrDelGrpSum = new OrderDeliveryGroupSummary();    
            OrderSummary ordrSummary = new OrderSummary();
            Order orderObj = new Order();
            Account acc = new Account();
            SalesChannel salesChannl = new SalesChannel();
            Integer lineNumber = 1;
            List<OrderPaymentSummary> ordrPaySumList = new List<OrderPaymentSummary>();
            List<FulfillmentOrderLineItem> fullfillmentOrderLineItemList = new List<FulfillmentOrderLineItem>();
            List<Shipment> shipmentList = new List<Shipment>();
            fulfillmentOrder = WM_ServiceHelper.getFulfillmentOrder(ordrFulfillmntIds[0]);
            Set<Id> fulFillmntIds = new Set<Id>();
            fulFillmntIds.add(fulfillmentOrder.Id);
            shipmentList = WM_ServiceHelper.getshpment(fulFillmntIds);
            fullfillmentOrderLineItemList =  WM_ServiceHelper.getFulfillmentOrderLineItem(fulFillmntIds);
            if(fulfillmentOrder.DeliveryMethodId!=null){
                ordrDelMethod =  WM_ServiceHelper.getOrderDeliveryMethod(fulfillmentOrder.DeliveryMethodId);
            }
            if(fulfillmentOrder.OrderSummaryId!=null){
                ordrSummary =  WM_ServiceHelper.getOrderSummary(fulfillmentOrder.OrderSummaryId);
            }
            if(fulfillmentOrder.Order_Delivery_Group_Summary__c!=null){
                ordrDelGrpSum  =  WM_ServiceHelper.getOrderDeliveryGrpSummary(fulfillmentOrder.Order_Delivery_Group_Summary__c );
            }
            if(ordrSummary.OriginalOrderId!=null){
                orderObj = WM_ServiceHelper.getOrder(ordrSummary.OriginalOrderId); 
                
            }
            if(fulfillmentOrder.AccountId!=null){
                acc =  WM_ServiceHelper.getAccount(fulfillmentOrder.AccountId);
                
            } 
            if(orderObj.SalesChannelId!=null){
                salesChannl = WM_ServiceHelper.getSalesChannel(orderObj.SalesChannelId);
            }
            Integer seqNumber = 1;
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('InvoiceOut_Request');
            gen.writeStartObject();
            if(WM_Utils.getString(orderObj.OrderReferenceNumber)!=null){
                gen.writeStringField('ihd_order_nbr', WM_Utils.getString(orderObj.OrderReferenceNumber));
            }
            if(WM_Utils.getString(fulfillmentOrder.dummyInvoiceNumberForSTSFS__c )!=null){
                gen.writeStringField('ihd_invoice_nbr', WM_Utils.getString(fulfillmentOrder.dummyInvoiceNumberForSTSFS__c));
            }
            gen.writeFieldName('OrderHeader');
            gen.writeStartObject();
            if( WM_Utils.getString(orderObj.OrderReferenceNumber)!=null){
                gen.writeStringField('ohd_reference_order_nbr', WM_Utils.getString(orderObj.OrderReferenceNumber));
            }
            if( WM_Utils.getString(orderObj.OrderedDate)!=null){
                gen.writeStringField('ohd_order_date', WM_Utils.getStringForDateTimeNoTimeZone(orderObj.OrderedDate));
            }
            if( WM_Utils.getString(orderObj.CreatedDate)!=null){
                gen.writeStringField('ohd_enter_date', WM_Utils.getStringForDateTimeNoTimeZone(orderObj.CreatedDate));
            }
            if( WM_Utils.getString(orderObj.CreatedDate)!=null){
                gen.writeStringField('ohd_enter_time', WM_Utils.getStringForDateTimeNoTimeZone(orderObj.CreatedDate));
            }
            if( WM_Utils.getString(salesChannl.SalesChannelName)!=null){
                gen.writeStringField('ohd_order_channel','I');
            }
            if( WM_Utils.getString(orderObj.associateId__c)!=null){
                gen.writeStringField('ohd_order_type', 'P');
            } else {
                gen.writeStringField('ohd_order_type', 'I');
            }
            if( WM_Utils.getInteger(acc.Sales_Person_Number__c)!=null){
                gen.writeNumberField('ohd_salesman_nbr', WM_Utils.getInteger(acc.Sales_Person_Number__c));
            }
            if( WM_Utils.getString(acc.AccountSource)!=null){
                gen.writeStringField('ohd_invoice_source_code', WM_Utils.getString(acc.AccountSource));
            }
            else{
                gen.writeStringField('ohd_invoice_source_code', '93WEB000A');              
            }
            
            
            
            if(acc.IsPersonAccount && acc.Cust_Payment_Class__c == 'A'){
                gen.writeStringField('ohd_invoice_division_code',WM_Utils.getString(acc.Associate__c));
                gen.writeStringField('ohd_invoice_entity_nbr',WM_Utils.getString(acc.Associate__c));
                
            }
            else if(acc.IsPersonAccount && acc.Cust_Payment_Class__c != 'A'){
                gen.writeStringField('ohd_invoice_division_code', 'Retail');
                gen.writeStringField('ohd_invoice_entity_nbr', 'Retail');
                
            }
            else {
                gen.writeStringField('ohd_invoice_division_code', 'Business');
                gen.writeStringField('ohd_invoice_entity_nbr', 'Business');
            }
            
            if( WM_Utils.getString(acc.Cust_Payment_Class__c)!=null){
                gen.writeStringField('ohd_customer_class', WM_Utils.getString(acc.Cust_Payment_Class__c));
            }
            else{
                gen.writeStringField('ohd_customer_class','R');
            }
            
            
            if( WM_Utils.getString(acc.AccountNumber)!=null){
                gen.writeStringField('ohd_cst_customer_nbr', WM_Utils.getString(acc.AccountNumber));
            }
            
            if( WM_Utils.getString(ordrSummary.associateID__c)!=null){
                gen.writeStringField('ohd_entered_by_user', WM_Utils.getString(ordrSummary.associateID__c));
            }
            
            gen.writeEndObject();
            
            gen.writeFieldName('CustomerSoldTo');
            gen.writeStartObject();          
            
            if(WM_Utils.getString(acc.SoldToNumber__c)!=null){
                gen.writeStringField('sold_to_nbr', WM_Utils.getString(acc.SoldToNumber__c));
            }
            if( WM_Utils.getString(acc.FirstName)!=null){
                gen.writeStringField('sold_to_fname', WM_Utils.getString(acc.FirstName));
            }
            if( WM_Utils.getString(acc.LastName)!=null){
                gen.writeStringField('sold_to_lname', WM_Utils.getString(acc.LastName));
            }
            if( WM_Utils.getString(orderObj.BillingStreet)!=null){
                gen.writeStringField('sold_to_address1', WM_Utils.getString(orderObj.BillingStreet));
            }
            
            if( WM_Utils.getString(orderObj.BillingCity)!=null){
                gen.writeStringField('sold_to_city', WM_Utils.getString(orderObj.BillingCity));
            }     
            if( WM_Utils.getString(orderObj.BillingCountry)!=null){
                gen.writeStringField('sold_to_country', WM_Utils.getString(orderObj.BillingCountry));
            } 
            if( WM_Utils.getString(orderObj.BillingState)!=null){
                gen.writeStringField('sold_to_state', WM_Utils.getString(orderObj.BillingState));
            }
            if( WM_Utils.getString(orderObj.BillingPostalCode)!=null){
                gen.writeStringField('sold_to_zip', WM_Utils.getString(orderObj.BillingPostalCode));
            }
            
            if(acc.IsPersonAccount ){
                if( WM_Utils.getString(acc.PersonEmail)!=null) {
                    gen.writeStringField('sold_to_email_address', WM_Utils.getString(acc.PersonEmail));
                }
                if( WM_Utils.getString(acc.PersonMobilePhone)!=null) {
                    gen.writeStringField('sold_to_day_phone', WM_Utils.getString(acc.PersonMobilePhone));
                    
                }
            }
            else {
                if( WM_Utils.getString(acc.Email__c)!=null) {
                    gen.writeStringField('sold_to_email_address', WM_Utils.getString(acc.Email__c));
                }
                if ( WM_Utils.getString(acc.Phone)!=null) {
                    gen.writeStringField('sold_to_day_phone', WM_Utils.getString(acc.Phone));
                }
            }
            //gen.writeStringField('sold_to_eve_phone','');
            if(acc.Associate__c!= null){
                gen.writeBooleanField('sold_to_associate', acc.Associate__c);
            }
            if( (acc.Associate__c)!=null &&  (acc.AssociateId__c)!=null){
                if(acc.Associate__c ==True){
                    gen.writeStringField('sold_to_alternate_id',WM_Utils.getString(acc.AssociateId__c));
                  }  
                }
                else if(acc.Associate__c ==False){
                    if( (acc.Associate__c)!=null && WM_Utils.getString (acc.loyaltyAccountNumber__c)!=null){
                        gen.writeStringField('sold_to_alternate_id', WM_Utils.getString(acc.loyaltyAccountNumber__c));
                    }
                }
            
            
            gen.writeEndObject();
            
            gen.writeFieldName('InvoiceShipTos');
            gen.writeStartArray();
            gen.writeStartObject();
            if(shipmentList.size()>0){
                if(WM_Utils.getString(shipmentList[0].CreatedDate)!=null){
                    gen.writeStringField('ins_invoice_date', WM_Utils.getStringForDateTimeNoTimeZone(shipmentList[0].CreatedDate));
                }
            }
            gen.writeFieldName('OrderShipTo');
            gen.writeStartObject();
            if(WM_Utils.getString(orderObj.SalesStoreId)!=null){
                gen.writeStringField('ost_broker_delivery_type', WM_Utils.getString(orderObj.SalesStoreId));
            }
            if(WM_Utils.getString(ordrDelGrpSum.fromStoreId__c)!=null){
                gen.writeStringField('ost_destination_store', WM_Utils.getString(ordrDelGrpSum.fromStoreId__c ));
            }
            
            if(WM_Utils.getString(ordrDelMethod.ReferenceNumber)!=null){
                gen.writeStringField('ost_ship_via_code', WM_Utils.getString(ordrDelMethod.ReferenceNumber));
            }
            if(ordrSummary.exchangeOrderNumber__c!=null){
                gen.writeFieldName('OrderMessages');
                gen.writeStartArray();
                gen.writeStartObject();
                
                gen.writeStringField('order_message_text', Label.Messaging_Prefix+''+WM_Utils.getString(ordrSummary.exchangeOrderNumber__c ));
                
                gen.writeEndObject();
                gen.writeEndArray();
            }
            
            gen.writeEndObject();
            
            gen.writeFieldName('CustomerShipTo');
            gen.writeStartObject();
            
            if(WM_Utils.getString(fulfillmentOrder.FulfilledToStreet)!=null){
                gen.writeStringField('order_ship_to_address1', WM_Utils.getString(fulfillmentOrder.FulfilledToStreet));
            }
            if(WM_Utils.getString(fulfillmentOrder.FulfilledToCity)!=null){
                gen.writeStringField('order_ship_to_city', WM_Utils.getString(fulfillmentOrder.FulfilledToCity));
            }
            if(WM_Utils.getString(fulfillmentOrder.FulfilledToCountry)!=null){
                gen.writeStringField('order_ship_to_country_name', WM_Utils.getString(fulfillmentOrder.FulfilledToCountry));
            }
            if(WM_Utils.getString(fulfillmentOrder.FulfilledToState)!=null){
                gen.writeStringField('order_ship_to_state', WM_Utils.getString(fulfillmentOrder.FulfilledToState));
            }
            if(WM_Utils.getString(fulfillmentOrder.FulfilledToPostalCode)!=null){
                gen.writeStringField('order_ship_to_zip', WM_Utils.getString(fulfillmentOrder.FulfilledToPostalCode));
            }
            
            gen.writeEndObject();
            gen.writeFieldName('InvoiceDetails');
            gen.writeStartArray();                       
            Integer invSeqNumber = 1;
            if(fullfillmentOrderLineItemList.size()>0){
                for(FulfillmentOrderLineItem fulfilordLineitem : fullfillmentOrderLineItemList){
                    OrderItem ordrItem =  WM_ServiceHelper.getOrderItem(fulfilordLineitem.OrderItemId);
                    OrderItemSummary orderItemSummary = WM_ServiceHelper.getOrderItemSummary(fulfilordLineitem.OrderItemSummaryId);
                    
                    Product2 prod =  WM_ServiceHelper.getProduct(fulfilordLineitem.Product2Id); 
                    gen.writeStartObject();
                    gen.writeNumberField('idt_line_nbr', WM_Utils.getInteger(invSeqNumber));
                    if(WM_Utils.getString(fulfilordLineitem.FulfillmentOrder.JDAFulfillmentOrderNumber__c)!=null){
                        gen.writeStringField('idt_control_nbr', WM_Utils.getString(fulfilordLineitem.FulfillmentOrder.JDAFulfillmentOrderNumber__c));
                    }
                    if(WM_Utils.getInteger(fulfilordLineitem.Quantity)!=null){
                        gen.writeNumberField('idt_shipped_qty', WM_Utils.getInteger(fulfilordLineitem.Quantity));
                    }
                    if(WM_Utils.getString(fulfilordLineitem.FulfillmentOrder.FulfilledFromLocation.ExternalReference)!=null){
                        system.debug('FulFillment Order Line Item Location   '+fulfilordLineitem.FulfillmentOrder.FulfilledFromLocation);
                        gen.writeStringField('fulfilling_location', WM_Utils.getString(fulfilordLineitem.FulfillmentOrder.FulfilledFromLocation.ExternalReference));
                    }
                    if(shipmentList.size()>0){
                        if(WM_Utils.getString(shipmentList[0].TrackingNumber)!=null){
                            gen.writeStringField('Tracking_Number', WM_Utils.getString(shipmentList[0].TrackingNumber));
                        }}
                    gen.writeFieldName('OrderDetail');
                    gen.writeStartObject();
                    if(WM_Utils.getInteger(orderItemSummary.QuantityOrdered )!=null){
                        gen.writeNumberField('odt_ordered_qty', WM_Utils.getInteger(orderItemSummary.QuantityOrdered));
                    }
                    if(WM_Utils.getInteger(orderItemSummary.QuantityFulfilled)!=null){
                        gen.writeNumberField('odt_shipped_qty', WM_Utils.getInteger(orderItemSummary.QuantityFulfilled));
                    }
                    if(WM_Utils.getString(prod.ProductCode)!=null){
                        gen.writeStringField('odt_item', WM_Utils.getString(prod.ProductCode));
                    }
                    if(WM_Utils.getDouble(orderItemSummary.UnitPrice)!=null){
                        gen.writeNumberField('odt_price',WM_Utils.getDouble(orderItemSummary.UnitPrice) + WM_Utils.getDouble((orderItemSummary.TotalAdjustmentAmount)/(orderItemSummary.Quantity)));
                    }
                    
                    gen.writeEndObject();
                    
                    gen.writeEndObject();  
                    invSeqNumber = invSeqNumber + 1;
                }
            }
            
            gen.writeEndArray();
            String payLoad = gen.getAsString();
            system.debug('payload: '+payLoad);
            
            request.setBody(payLoad);
            request.setTimeout(60000);
            System.debug('request : '+ request);
            HttpResponse response = new HttpResponse();
            response = http.send(request);
            system.debug('getStatusCode ' + response.getStatusCode());            
            system.debug('getBody ' + response.getBody());
            
            if(response.getStatusCode()==200){
                FeedItem post = new FeedItem();
                post.ParentId = ordrFulfillmntIds[0]; 
                
                post.Title = 'The request to Interim Invoice Service was successful';
                post.Body = 'The request to Interim Invoice Service was successful and returned response as   '+response.getBody();
                insert post;
            }
            else{
                FeedItem post = new FeedItem();
                post.ParentId = ordrFulfillmntIds[0]; 
                
                post.Title = 'The request to Interim Invoice Service failed with status code as '+response.getStatusCode() +'at '+String.valueOf(system.now());
                post.Body = response.getBody();
                insert post;
            }
        }
    }
}