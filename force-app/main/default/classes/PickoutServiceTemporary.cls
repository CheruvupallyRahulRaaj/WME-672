public class PickoutServiceTemporary {
    public PickoutServiceTemporary(Integer numberOfRecords) {
        String dt = '2021-09-03 00:00:00';
        DateTime refDate = DateTime.valueOf(dt);

        String enddateStr = '2022-08-26 00:00:00';
        DateTime endDate = DateTime.valueOf(enddateStr);

        Map<Id,FulFillmentOrder> fulfillmentOrdersMap = new Map<Id,FulFillmentOrder>([
            SELECT Id 
            FROM FulfillmentOrder 
            WHERE 
                status = 'Assigned' 
            AND 
                FulfilledFromLocation.LocationType = 'Warehouse' 
            AND 
                CreatedDate>:refDate
            AND
                CreatedDate < :endDate
            AND CancelReason__c != '-'
            LIMIT :numberOfRecords
        ]);

        List<Id> fulfillmentOrders = new List<Id>(fulfillmentOrdersMap.keyset());
        process(fulfillmentOrders);
    }

    public PickoutServiceTemporary(List<Id> fulfillmentOrders) {
        process(fulfillmentOrders);
    }

    public PickoutServiceTemporary(Id fulfillmentOrder) {
        List<Id> fulfillmentOrders = new List<Id>();
        fulfillmentOrders.add(fulfillmentOrder);
        process(fulfillmentOrders);
    }

    public void process(List<Id> fulfillmentOrders){
        System.debug('Count of Fulfillment Orders:' + fulfillmentOrders.size());
        for(ID foId : fulfillmentOrders){
            System.debug('BBB FO ID:' + foId);
        }
        List<Id> ordrFulfillmntIds = fulfillmentOrders;
        Map<String,Boolean> mapOfFulFillmentIDWithResult = new Map<String,Boolean>();
        List<FulfillmentOrder>  fulfilList = new list<FulfillmentOrder> ();
        List<Boolean> result = new List<Boolean>();
        for(Id fulfillId : ordrFulfillmntIds){
            try{
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                // retreving the API key which is configured in Custom Settings
                String apiKey = WM_WebServiceDetails__c.getValues('PickOutApiKey').WM_ApiKey__c;
                // Setting appropriate attributes for the request
                request.setEndpoint('callout:PickOutService');
                request.setMethod('POST'); 
                request.setHeader('Content-Type','application/json');
                request.setHeader('api_key',apiKey);   
                // Instantiating the necessary entities which would be utilized in the service
                FulfillmentOrder fulfillmentOrder = new FulfillmentOrder();
                OrderDeliveryMethod ordrDelMethod = new OrderDeliveryMethod();
                OrderDeliveryGroupSummary ordrDelGrpSum = new OrderDeliveryGroupSummary();    
                Schema.Location locatn = new Schema.Location();
                OrderSummary ordrSummary = new OrderSummary();
                Order ordr = new Order();
                SalesChannel salesChannl = new SalesChannel();
                WebStore str = new WebStore();
                Account acc = new Account();
                List<Tax_Exemption__c> TaxExemptnList = new List<Tax_Exemption__c>();
                Integer lineNumber = 1;
                List<OrderPaymentSummary> ordrPaySumList = new List<OrderPaymentSummary>();
                List<FulfillmentOrderLineItem> fulFillmntLineItemList = new List<FulfillmentOrderLineItem>();
                List<Address__c> listOfAddress = new List<Address__c>();
                // Check if the size of the list of order fulfillment Ids is greater than zero.
                if(ordrFulfillmntIds.size()>0){
                    // Retrieving FulFillment Order record from a helper class.
                    fulfillmentOrder = WM_ServiceHelper.getFulfillmentOrder(fulfillId);
                    Set<Id> fulFillmntIds = new Set<Id>();
                    fulFillmntIds.add(fulfillmentOrder.Id);
                    fulFillmntLineItemList =  WM_ServiceHelper.getFulfillmentOrderLineItem(fulFillmntIds);
                    // null check to ensure the code doesn't fail at run time.
                    if(fulfillmentOrder.DeliveryMethodId!=null){
                        ordrDelMethod =  WM_ServiceHelper.getOrderDeliveryMethod(fulfillmentOrder.DeliveryMethodId);
                    }
                    if(fulfillmentOrder.FulfilledFromLocationId!=null){
                        locatn = WM_ServiceHelper.getLocation(fulfillmentOrder.FulfilledFromLocationId);
                    }
                    if(fulfillmentOrder.OrderSummaryId!=null){
                        ordrSummary =  WM_ServiceHelper.getOrderSummary(fulfillmentOrder.OrderSummaryId);
                        ordrPaySumList =  WM_ServiceHelper.getOrderPaymentSummary(fulfillmentOrder.OrderSummaryId);
                    }
                    if(fulfillmentOrder.Order_Delivery_Group_Summary__c!=null){
                        ordrDelGrpSum  =  WM_ServiceHelper.getOrderDeliveryGrpSummary(fulfillmentOrder.Order_Delivery_Group_Summary__c );
                    }
                    if(ordrSummary.OriginalOrderId!=null){
                        ordr = WM_ServiceHelper.getOrder(ordrSummary.OriginalOrderId); 
                    }
                    if(ordr.SalesChannelId!=null){
                        salesChannl = WM_ServiceHelper.getSalesChannel(ordr.SalesChannelId);
                    }
                    if(ordr.SalesStoreId!=null){
                        str = WM_ServiceHelper.getStore(ordr.SalesStoreId);
                    } 
                    if(fulfillmentOrder.AccountId!=null){
                        acc =  WM_ServiceHelper.getAccount(fulfillmentOrder.AccountId);
                        TaxExemptnList = WM_ServiceHelper.getTaxExemptions(fulfillmentOrder.AccountId);
                        listOfAddress = WM_CRMServiceHelper.getAddress(fulfillmentOrder.AccountId);
                    } 
                
                
                    // Instanting the JSONGenerator class to start building the json body for the request.
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    gen.writeFieldName('PickOut_Request');
                    gen.writeStartObject();
                    if(WM_Utils.getString(fulfillmentOrder.JDAFulfillmentOrderNumber__c)!=null){
                        gen.writeStringField('pick_nbr', WM_Utils.getString(fulfillmentOrder.JDAFulfillmentOrderNumber__c));
                    }
                    if(WM_Utils.getString(ordr.poNumber__c)!=null){
                        gen.writeStringField('po_nbr', WM_Utils.getString(ordr.poNumber__c)); 
                    }    
                    if(WM_Utils.getDouble(fulfillmentOrder.TotalProductAmount)!=null){
                        gen.writeNumberField('merch_amt', WM_Utils.getDouble(fulfillmentOrder.TotalProductAmount));
                    }    
                    if(WM_Utils.getDouble(fulfillmentOrder.TotalDeliveryAmount)!=null){
                        gen.writeNumberField('freight_amt', WM_Utils.getDouble(fulfillmentOrder.TotalDeliveryAmount));
                    }    
                    if(WM_Utils.getDouble(fulfillmentOrder.TotalDeliveryAdjustAmount)!=null){
                        gen.writeNumberField('addl_freight_amt', WM_Utils.getDouble(fulfillmentOrder.TotalDeliveryAdjustAmount)); 
                    }
                    if(WM_Utils.getDouble(fulfillmentOrder.TotalAdjustmentAmount)!=null){
                        gen.writeNumberField('addl_charge_amt', WM_Utils.getDouble(fulfillmentOrder.TotalAdjustmentAmount));
                    }    
                    if(WM_Utils.getDouble(fulfillmentOrder.TotalTaxAmount)!=null){
                        gen.writeNumberField('tax_amt', WM_Utils.getDouble(fulfillmentOrder.TotalTaxAmount));
                    }    
                    if(WM_Utils.getDouble(fulfillmentOrder.TotalDeliveryAdjustAmount)!=null){
                        gen.writeNumberField('amt_paid', WM_Utils.getDouble(fulfillmentOrder.TotalDeliveryAdjustAmount));
                    }    
                    if(WM_Utils.getDouble(fulfillmentOrder.GrandTotalAmount)!=null){
                        gen.writeNumberField('total_order_amt', WM_Utils.getDouble(fulfillmentOrder.GrandTotalAmount));  
                    }
                    //gen.writeStringField('balance_due_amt', '');             
                    if(WM_Utils.getString(ordr.OrderReferenceNumber)!=null){
                        gen.writeStringField('order_nbr', WM_Utils.getString(ordr.OrderReferenceNumber));             
                    }
                    if(WM_Utils.getString(acc.AccountNumber)!=null){
                        gen.writeStringField('sold_to_customer_nbr',  WM_Utils.getString(acc.AccountNumber));             
                    }  
                
                    if(acc.IsPersonAccount){
                        if(WM_Utils.getString(fulfillmentOrder.FulFilledToName)!=null){
                            String ShipToName = WM_Utils.getString(fulfillmentOrder.FulFilledToName);
                            String[] nameList = ShipToName.split(' ', 3);
                            if(nameList.size()==2){
                                gen.writeStringField('ship_to_fname', WM_Utils.getString(nameList[0])); 
                                gen.writeStringField('ship_to_lname', WM_Utils.getString(nameList[1]));      
                            }
                            if(nameList.size()==3){
                                gen.writeStringField('ship_to_fname', WM_Utils.getString(nameList[0])); 
                                gen.writeStringField('ship_to_initial', WM_Utils.getString(nameList[1]));   
                                gen.writeStringField('ship_to_lname', WM_Utils.getString(nameList[2])); 
                            }
                            if(nameList.size()==1){
                                gen.writeStringField('ship_to_fname', WM_Utils.getString(nameList[0])); 
                            }
                            
                        }
                    }
                    if(!acc.IsPersonAccount ){
                        if(WM_Utils.getString(fulfillmentOrder.FulFilledToName)!=null){
                            gen.writeStringField('ship_to_company', WM_Utils.getString((fulfillmentOrder.FulFilledToName))); 
                        }      
                    }
                    if(WM_Utils.getString(fulfillmentOrder.FulfilledToStreet)!=null){
                        gen.writeStringField('ship_to_addr1', WM_Utils.getString(fulfillmentOrder.FulfilledToStreet));             
                    }
                    if(WM_Utils.getString(fulfillmentOrder.FulfilledToShippingStreet2__c)!=null){
                        gen.writeStringField('ship_to_addr2', WM_Utils.getString(fulfillmentOrder.FulfilledToShippingStreet2__c));             
                    }
                    if(WM_Utils.getString(fulfillmentOrder.FulfilledToShippingStreet3__c)!=null){
                        gen.writeStringField('ship_to_addr3', WM_Utils.getString(fulfillmentOrder.FulfilledToShippingStreet3__c));             
                    }
                    if(WM_Utils.getString(fulfillmentOrder.FulfilledToShippingStreet4__c)!=null){
                        gen.writeStringField('ship_to_addr4', WM_Utils.getString(fulfillmentOrder.FulfilledToShippingStreet4__c));             
                    }
                    if(WM_Utils.getString(fulfillmentOrder.FulfilledToCountry)!=null){
                        gen.writeStringField('ship_to_country', WM_Utils.getString(fulfillmentOrder.FulfilledToCountry));             
                    }
                    if(WM_Utils.getString(fulfillmentOrder.FulfilledToCity)!=null){
                        gen.writeStringField('ship_to_city', WM_Utils.getString(fulfillmentOrder.FulfilledToCity));             
                    }
                    if(WM_Utils.getString(fulfillmentOrder.FulfilledToState)!=null){
                        gen.writeStringField('ship_to_state', WM_Utils.getString(fulfillmentOrder.FulfilledToState));             
                    }
                    if(WM_Utils.getString(fulfillmentOrder.FulfilledToPostalCode)!=null){
                        gen.writeStringField('ship_to_postal_code', WM_Utils.getString(fulfillmentOrder.FulfilledToPostalCode));             
                    }
                    if(WM_Utils.getString(fulfillmentOrder.FulfilledToPhone)!=null){
                        gen.writeStringField('ship_to_day_phone', WM_Utils.getString(fulfillmentOrder.FulfilledToPhone));             
                    }
                    if(WM_Utils.getString(fulfillmentOrder.FulfilledToEmailAddress)!=null){
                        gen.writeStringField('ship_to_email_address', WM_Utils.getString(fulfillmentOrder.FulfilledToEmailAddress));             
                    }
                    if(WM_Utils.getString(ordrDelMethod.ReferenceNumber)!=null){
                        gen.writeStringField('ship_via', WM_Utils.getString(ordrDelMethod.ReferenceNumber));             
                    }
                    if(WM_Utils.getString(locatn.ExternalReference)!=null){
                        gen.writeStringField('whse', WM_Utils.getString(locatn.ExternalReference));            
                    }
                    if(listOfAddress.size()>0 && ordrDelMethod.ReferenceNumber!='5' &&
                        ordrDelMethod.ReferenceNumber!='14'  &&
                        ordrDelMethod.ReferenceNumber!='6' &&
                        ordrDelMethod.ReferenceNumber!='4' &&
                        ordrDelMethod.ReferenceNumber!='98' &&
                        ordrDelMethod.ReferenceNumber!='15' &&
                        ordrDelMethod.ReferenceNumber!='12' &&
                        ordrDelMethod.ReferenceNumber!='physicalGCMethod' &&
                        ordrDelMethod.ReferenceNumber!='29' &&
                        ordrDelMethod.ReferenceNumber!='3' &&
                        ordrDelMethod.ReferenceNumber!='9' &&
                        ordrDelMethod.ReferenceNumber!='13' &&
                        ordrDelMethod.ReferenceNumber!='002-1' &&
                        ordrDelMethod.ReferenceNumber!='004-1' &&
                        ordrDelMethod.ReferenceNumber!='005-1' &&
                        ordrDelMethod.ReferenceNumber!='006-1' &&
                        ordrDelMethod.ReferenceNumber!='007-1' &&
                        ordrDelMethod.ReferenceNumber!='001-1' &&
                        ordrDelMethod.ReferenceNumber!='SDVN' &&
                        ordrDelMethod.ReferenceNumber!='10' &&
                        ordrDelMethod.ReferenceNumber!='11' &&
                        ordrDelMethod.ReferenceNumber!='23' &&
                        ordrDelMethod.ReferenceNumber!='28' &&
                        ordrDelMethod.ReferenceNumber!='loyaltyGoldShippingMethod' &&
                        ordrDelMethod.ReferenceNumber!='7' &&
                        ordrDelMethod.ReferenceNumber!='2' &&
                        ordrDelMethod.ReferenceNumber!='1'){

                        if(WM_Utils.getString(listOfAddress[0].csh_van_route__c)!=null){
                            gen.writeStringField('van_route', WM_Utils.getString(listOfAddress[0].csh_van_route__c));             
                        }
                        if( WM_Utils.getString(listOfAddress[0].csh_van_route_seq__c)!=null){
                            gen.writeStringField('van_route_seq_nbr',  WM_Utils.getString(listOfAddress[0].csh_van_route_seq__c));             
                        }
                    }
                
                    gen.writeFieldName('CustomerSoldToAddress');
                    gen.writeStartObject();
                    if( WM_Utils.getString(acc.AccountNumber)!=null){
                        gen.writeStringField('sold_to_customer_nbr', WM_Utils.getString(acc.AccountNumber));
                    }
                    if( WM_Utils.getString(acc.Salutation__pc)!=null){
                        gen.writeStringField('sold_to_prefix', WM_Utils.getString(acc.Salutation__pc));
                    }
                    if( WM_Utils.getString(acc.FirstName)!=null){
                        gen.writeStringField('sold_to_fname', WM_Utils.getString(acc.FirstName));
                    }
                    if( WM_Utils.getString(acc.MiddleName)!=null){
                        gen.writeStringField('sold_to_initial', WM_Utils.getString(acc.MiddleName));
                    }
                    if( WM_Utils.getString(acc.LastName)!=null){
                        gen.writeStringField('sold_to_lname', WM_Utils.getString(acc.LastName));
                    }
                    if( WM_Utils.getString(acc.Suffix__pc)!=null){
                        gen.writeStringField('sold_to_suffix', WM_Utils.getString(acc.Suffix__pc));
                    }
                    if( WM_Utils.getString(acc.Name)!=null){
                        gen.writeStringField( 'sold_to_company', WM_Utils.getString(acc.Name));
                    }
                    if( WM_Utils.getString(ordr.BillingStreet)!=null){
                        gen.writeStringField('sold_to_addr1', WM_Utils.getString(ordr.BillingStreet));
                    }
                
                    if( WM_Utils.getString(ordr.BillingCountry)!=null){
                        gen.writeStringField('sold_to_country', WM_Utils.getString(ordr.BillingCountry));
                    }
                    if( WM_Utils.getString(ordr.BillingCity)!=null){
                        gen.writeStringField('sold_to_city', WM_Utils.getString(ordr.BillingCity));
                    }
                    if( WM_Utils.getString(ordr.BillingState)!=null){
                        gen.writeStringField('sold_to_state', WM_Utils.getString(ordr.BillingState));
                    }
                    if( WM_Utils.getString(ordr.BillingPostalCode)!=null){
                        gen.writeStringField('sold_to_postal_code', WM_Utils.getString(ordr.BillingPostalCode));
                    }
                    if( WM_Utils.getString(ordr.BillingPhoneNumber)!=null){
                        gen.writeStringField('sold_to_day_phone', WM_Utils.getString(ordr.BillingPhoneNumber));
                    }
                
                    gen.writeEndObject();
                    gen.writeFieldName('CustomerBillToAddress');
                    gen.writeStartObject();
                    //Pro account first condition (check if parent exist)
                    if(!acc.IsPersonAccount && acc.ParentId!=null){
                        Account parentAccount = WM_ServiceHelper.getAccount(acc.ParentId);
                        List<Address__c> addressList = WM_CRMServiceHelper.getAddress(acc.ParentId);
                        if( WM_Utils.getString(parentAccount.AccountNumber)!=null){
                            gen.writeStringField('bill_to_customer_nbr', WM_Utils.getString(parentAccount.AccountNumber));
                        }
                        if( WM_Utils.getString(parentAccount.Salutation__pc)!=null){
                            gen.writeStringField('bill_to_prefix', WM_Utils.getString(parentAccount.Salutation__pc));
                        }
                        if( WM_Utils.getString(parentAccount.FirstName)!=null){
                            gen.writeStringField('bill_to_fname', WM_Utils.getString(parentAccount.FirstName));
                        }
                        if( WM_Utils.getString(parentAccount.MiddleName)!=null){
                            gen.writeStringField('bill_to_initial', WM_Utils.getString(parentAccount.MiddleName));
                        }
                        if( WM_Utils.getString(parentAccount.LastName)!=null){
                            gen.writeStringField('bill_to_lname', WM_Utils.getString(parentAccount.LastName));
                        }
                        if( WM_Utils.getString(parentAccount.Suffix__pc)!=null){
                            gen.writeStringField('bill_to_suffix', WM_Utils.getString(parentAccount.Suffix__pc));
                        }
                        if( WM_Utils.getString(parentAccount.Name)!=null){
                            gen.writeStringField( 'bill_to_company', WM_Utils.getString(parentAccount.Name));
                        }
                        
                        if(addressList.size()>0){
                            if(WM_Utils.getString(addressList[0].Address_Line_1__c)!=null){
                                gen.writeStringField('bill_to_addr1', WM_Utils.getString(addressList[0].Address_Line_1__c));
                            }
                            if(WM_Utils.getString(addressList[0].Address_Line_2__c)!=null){
                                gen.writeStringField('bill_to_addr2', WM_Utils.getString(addressList[0].Address_Line_2__c));
                            }
                            if(WM_Utils.getString(addressList[0].Address_Line_3__c)!=null){
                                gen.writeStringField('bill_to_addr3', WM_Utils.getString(addressList[0].Address_Line_3__c));
                            }
                            if(WM_Utils.getString(addressList[0].City__c)!=null ){
                                gen.writeStringField('bill_to_city', WM_Utils.getString(addressList[0].City__c));
                            }
                            if(WM_Utils.getString(addressList[0].State__c)!=null){
                                gen.writeStringField('bill_to_state', WM_Utils.getString(addressList[0].State__c));
                            }
                            if(WM_Utils.getString(addressList[0].Postal_Code__c)!=null){
                                gen.writeStringField('bill_to_postal_code', WM_Utils.getString(addressList[0].Postal_Code__c));
                            }
                            if(WM_Utils.getString(addressList[0].Country__c)!=null ) {
                                gen.writeStringField('bill_to_country', WM_Utils.getString(addressList[0].Country__c));
                            }
                        }
                    }
                    //PRetail account
                    else{
                        if( WM_Utils.getString(acc.AccountNumber)!=null){
                            gen.writeStringField('bill_to_customer_nbr', WM_Utils.getString(acc.AccountNumber));
                        }
                        if( WM_Utils.getString(acc.Salutation__pc)!=null){
                            gen.writeStringField('bill_to_prefix', WM_Utils.getString(acc.Salutation__pc));
                        }
                        if( WM_Utils.getString(acc.FirstName)!=null){
                            gen.writeStringField('bill_to_fname', WM_Utils.getString(acc.FirstName));
                        }
                        if( WM_Utils.getString(acc.MiddleName)!=null){
                            gen.writeStringField('bill_to_initial', WM_Utils.getString(acc.MiddleName));
                        }
                        if( WM_Utils.getString(acc.LastName)!=null){
                            gen.writeStringField('bill_to_lname', WM_Utils.getString(acc.LastName));
                        }
                        if( WM_Utils.getString(acc.Suffix__pc)!=null){
                            gen.writeStringField('bill_to_suffix', WM_Utils.getString(acc.Suffix__pc));
                        }
                        if( WM_Utils.getString(acc.Name)!=null){
                            gen.writeStringField( 'bill_to_company', WM_Utils.getString(acc.Name));
                        }
                        if( WM_Utils.getString(ordr.BillingStreet)!=null){
                            gen.writeStringField('bill_to_addr1', WM_Utils.getString(ordr.BillingStreet));
                        }
                        
                        if( WM_Utils.getString(ordr.BillingCity)!=null){
                            gen.writeStringField('bill_to_city', WM_Utils.getString(ordr.BillingCity));
                        }
                        if( WM_Utils.getString(ordr.BillingState)!=null){
                            gen.writeStringField('bill_to_state', WM_Utils.getString(ordr.BillingState));
                        }
                        if( WM_Utils.getString(ordr.BillingPostalCode)!=null){
                            gen.writeStringField('bill_to_postal_code', WM_Utils.getString(ordr.BillingPostalCode));
                        }
                        if( WM_Utils.getString(ordr.BillingCountry)!=null){
                            gen.writeStringField('bill_to_country', WM_Utils.getString(ordr.BillingCountry));
                        }
                    }
                    gen.writeEndObject();
                    gen.writeFieldName('OrderHeader');
                    gen.writeStartObject();
                    if( WM_Utils.getString(ordr.OrderReferenceNumber)!=null){
                        gen.writeStringField('order_nbr', WM_Utils.getString(ordr.OrderReferenceNumber));
                    }
                    if( WM_Utils.getString(ordr.OrderedDate)!=null){
                        gen.writeStringField('order_date', WM_Utils.getStringForDateTimeNoTimeZone(ordr.OrderedDate));
                    }
                    if( WM_Utils.getString(ordr.CreatedDate)!=null){
                        gen.writeStringField('entered_date', WM_Utils.getStringForDateTimeNoTimeZone(ordr.CreatedDate));
                    }
                    if( WM_Utils.getDouble(ordr.TotalAdjustedDeliveryAmount)!=null){
                        gen.writeNumberField('freight_amt', WM_Utils.getDouble(ordr.TotalAdjustedDeliveryAmount));
                    }
                    gen.writeStringField('order_channel', 'I');
                    if (ordr.associateID__c != null) {
                        gen.writeStringField('order_type', 'P');
                    } else {
                        gen.writeStringField('order_type', 'I');
                    }
                    if( WM_Utils.getString(acc.Cust_Payment_Class__c)!=null){
                        gen.writeStringField('customer_class', WM_Utils.getString(acc.Cust_Payment_Class__c));
                    }
                    else{
                        gen.writeStringField('customer_class','R');
                    }
                
                    if( WM_Utils.getString(ordr.BillingEmailAddress)!=null){
                        gen.writeStringField('email_address', WM_Utils.getString(ordr.BillingEmailAddress));
                    }
                    gen.writeEndObject();
                    gen.writeFieldName('OrderShipTo');
                    gen.writeStartObject();
                    if( WM_Utils.getString(ordr.OrderReferenceNumber)!=null){
                        gen.writeStringField('order_nbr', WM_Utils.getString(ordr.OrderReferenceNumber));
                    }
                    if( WM_Utils.getDouble(fulfillmentOrder.TotalAdjustmentAmtWithTax)!=null){
                        gen.writeNumberField('addl_charge_amt',  WM_Utils.getDouble(fulfillmentOrder.TotalAdjustmentAmtWithTax));
                    }
                    if(  WM_Utils.getDouble(fulfillmentOrder.TotalAdjustmentAmtWithTax)!=null){
                        gen.writeNumberField('addl_charge_balance_amt', WM_Utils.getDouble(fulfillmentOrder.TotalAdjustmentAmtWithTax));
                    }
                    if(WM_Utils.getDouble(ordr.TotalAdjustedDeliveryAmount)!=null){
                        gen.writeNumberField('freight_amt', WM_Utils.getDouble(ordr.TotalAdjustedDeliveryAmount));
                    }
                    if(WM_Utils.getDouble(ordr.TotalAdjustedDeliveryAmount)!=null){
                        gen.writeNumberField('freight_balance_amt', WM_Utils.getDouble(ordr.TotalAdjustedDeliveryAmount));
                    }
                    if( WM_Utils.getDouble(ordr.TotalAdjustedProductAmount)!=null){
                        gen.writeNumberField('merch_amt', WM_Utils.getDouble(ordr.TotalAdjustedProductAmount));
                    }
                    if( WM_Utils.getDouble(fulfillmentOrder.TotalProductAmount)!=null){
                        gen.writeNumberField('merch_balance_amt', WM_Utils.getDouble(fulfillmentOrder.TotalProductAmount));
                    }
                    if(TaxExemptnList!=null){
                        if(WM_Utils.getString(TaxExemptnList[0].Exemption_Certificate__c)!=null)
                        {
                            gen.writeStringField('resale_exemption_nbr', WM_Utils.getString(TaxExemptnList[0].Exemption_Certificate__c));
                        }
                    }
                    if(WM_Utils.getDouble(ordr.TotalTaxAmount)!=null){
                        gen.writeNumberField('tax_amt', WM_Utils.getDouble(ordr.TotalTaxAmount));
                    }
                    if( WM_Utils.getDouble(ordr.TotalTaxAmount)!=null){
                        gen.writeNumberField('tax_balance_amt', WM_Utils.getDouble(ordr.TotalTaxAmount));
                    }
                    if(WM_Utils.getDouble(ordr.TotalDeliveryAdjDistAmount)!=null){
                        gen.writeNumberField('addl_freight_amt', WM_Utils.getDouble(ordr.TotalDeliveryAdjDistAmount));
                    }
                    if(  WM_Utils.getDouble(ordr.TotalDeliveryAdjDistAmount)!=null){
                        gen.writeNumberField('addl_freight_balance_amt', WM_Utils.getDouble(ordr.TotalDeliveryAdjDistAmount));
                    }
                    if( WM_Utils.getString(locatn.ExternalReference)!=null){
                        gen.writeStringField('whse', WM_Utils.getString(locatn.ExternalReference));
                    }
                    if( WM_Utils.getString(ordrDelMethod.ReferenceNumber)!=null){
                        gen.writeStringField('ship_via', WM_Utils.getString(ordrDelMethod.ReferenceNumber));
                    }
                    if( WM_Utils.getString(ordrDelGrpSum.fromStoreId__c )!=null){
                        gen.writeStringField('destination_store', WM_Utils.getString(ordrDelGrpSum.fromStoreId__c ));
                    }
                
                    gen.writeEndObject();
                    gen.writeFieldName('OrderPayments');
                    gen.writeStartArray();
                
                
                    for(OrderPaymentSummary ordrPaySum :ordrPaySumList){  
                        gen.writeStartObject();
                        if(WM_Utils.getString(ordrPaySum.Type)!=null){
                            if(WM_Utils.getString(ordrPaySum.Type)!='Unknown'){
                                gen.writeStringField('pay_type', WM_Utils.getString(ordrPaySum.Type));
                            }
                            else{
                                String recrdTypeName = [SELECT Id, RecordType.Name FROM AlternativePaymentMethod where id=:ordrPaySum.PaymentMethodId].RecordType.Name;
                                gen.writeStringField('pay_type',recrdTypeName);
                            }
                        }
                        if(WM_Utils.getString(ordrPaySum.Method)!=null){
                            gen.writeStringField('pay_type_desc', WM_Utils.getString(ordrPaySum.Method));
                        }
                        gen.writeEndObject();
                    }
                    gen.writeEndArray();
                    gen.writeFieldName('PickDetails');
                    gen.writeStartArray();
                
                    for(FulfillmentOrderLineItem fulfilmntOrderLineitm :fulFillmntLineItemList){                 
                        OrderItem ordrItem =  WM_ServiceHelper.getOrderItem(fulfilmntOrderLineitm.OrderItemId);
                        Product2 prod =  WM_ServiceHelper.getProduct(ordrItem.Product2Id); 
                        gen.writeStartObject();
                        
                        gen.writeNumberField('pick_line_nbr',WM_Utils.getInteger(fulfilmntOrderLineitm.FulfillmentOrderLineItemNumber));
                        
                        if(WM_Utils.getInteger(fulfilmntOrderLineitm.Quantity)!=null){
                            gen.writeNumberField('qty_printed',WM_Utils.getInteger(fulfilmntOrderLineitm.Quantity));
                        }
                        if(WM_Utils.getDouble(fulfilmntOrderLineitm.UnitPrice)!=null){
                            gen.writeNumberField('selling_price',WM_Utils.getDouble(fulfilmntOrderLineitm.UnitPrice));
                        }
                        if(WM_Utils.getDouble(fulfilmntOrderLineitm.TotalPrice)!=null){
                            gen.writeNumberField('selling_price_extended',WM_Utils.getDouble(fulfilmntOrderLineitm.TotalPrice));
                        }
                        if(WM_Utils.getDouble(fulfilmntOrderLineitm.TotalAdjustmentAmount)!=null){
                            gen.writeNumberField('hand_charge_amt',WM_Utils.getDouble(fulfilmntOrderLineitm.TotalAdjustmentAmount));
                        }
                        if(WM_Utils.getInteger(fulfilmntOrderLineitm.OriginalQuantity)!=null){
                            gen.writeNumberField('qty_ordered',WM_Utils.getInteger(fulfilmntOrderLineitm.OriginalQuantity));
                        }
                        if(fulfillmentOrder.Type=='Special'){
                            if(WM_Utils.getString(ordrItem.Special_Order_SKU__c)!=null){
                                gen.writeStringField('item', WM_Utils.getString(ordrItem.Special_Order_SKU__c));
                            }
                            else{
                                if(WM_Utils.getString(prod.ProductCode)!=null){
                                    gen.writeStringField('item' , WM_Utils.getString(prod.ProductCode).toUppercase());
                                }  
                            }
                            if(WM_Utils.getString(ordrItem.longDescription__c)!=null){
                                gen.writeStringField('item_desc',WM_Utils.getString(ordrItem.longDescription__c));
                            }
                        }
                        else{
                            if(WM_Utils.getString(prod.ProductCode)!=null){
                                gen.writeStringField('item', WM_Utils.getString(prod.ProductCode));
                            }
                            if(WM_Utils.getString(prod.Description)!=null){
                                gen.writeStringField('item_desc',WM_Utils.getString(prod.Description));
                            }   
                        }
                        gen.writeFieldName('OrderDetail');
                        gen.writeStartObject();
                        if(WM_Utils.getInteger(ordrItem.LineNumber)!=null){
                            gen.writeNumberField('order_detail_nbr', WM_Utils.getInteger(ordrItem.LineNumber));
                        }
                        if(WM_Utils.getDouble(ordrItem.ListPrice)!=null){
                            gen.writeNumberField('selling_price',WM_Utils.getDouble(ordrItem.ListPrice));
                        }
                        if(WM_Utils.getString(locatn.ExternalReference)!=null){
                            gen.writeStringField('whse' , WM_Utils.getString(locatn.ExternalReference));
                        }
                        gen.writeEndObject();
                        gen.writeFieldName('Item');
                        gen.writeStartObject();
                        if(fulfillmentOrder.Type=='Special'){
                            if(WM_Utils.getString(ordrItem.Special_Order_SKU__c)!=null){
                                gen.writeStringField('Item_Number', WM_Utils.getString(ordrItem.Special_Order_SKU__c));
                            }
                            else {
                                if(WM_Utils.getString(prod.ProductCode)!=null){
                                    gen.writeStringField('Item_Number' , WM_Utils.getString(prod.ProductCode).toUppercase());
                                }  
                            }
                        }
                        else{
                            if(WM_Utils.getString(prod.ProductCode)!=null){
                                gen.writeStringField('Item_Number' , WM_Utils.getString(prod.ProductCode));
                            }
                        }
                        if(fulfillmentOrder.Type=='Drop Ship'){
                            gen.writeStringField('Drop_ship_item','Y');
                        }
                        else{
                            gen.writeStringField('Drop_ship_item','N');
                        }
                        if(WM_Utils.getString(ordrItem.weight__c)!=null){
                            gen.writeStringField('Ship_weight',WM_Utils.getString(ordrItem.weight__c));
                        }
                        if (fulfillmentOrder.Type=='Special') {
                            gen.writeStringField('LCL_Location_class','01');
                        } else if (fulfillmentOrder.Type=='Physical Gift Card') {
                            gen.writeStringField('LCL_Location_class','04');
                        } else if (fulfillmentOrder.Type=='Member/Tow') {
                            gen.writeStringField('LCL_Location_class','05');                       
                        }
                    
                        if(WM_Utils.getString(ordrItem.unitMeasure__c)!=null){
                            gen.writeStringField('Unit_of_measure', WM_Utils.getString(ordrItem.unitMeasure__c));
                        }
                        if(WM_Utils.getString(ordrItem.vendorNumber__c)!=null){
                            gen.writeStringField('Vendor_Nbr', WM_Utils.getString(ordrItem.vendorNumber__c));
                        }
                        if(WM_Utils.getString(ordrItem.vendorName__c)!=null){
                            gen.writeStringField('Manufacturer_Vendor', WM_Utils.getString(ordrItem.vendorName__c));
                        }
                        
                        if(WM_Utils.getString(locatn.ExternalReference)!=null){
                            gen.writeStringField('Warehouse' , WM_Utils.getString(locatn.ExternalReference ));
                        }
                    
                        gen.writeEndObject();
                        OrderItemSummary orderItemSummary = WM_ServiceHelper.getOrderItemSummary(fulfilmntOrderLineitm.OrderItemSummaryId);
                        gen.writeFieldName('PickDetailMsg');
                        gen.writeStartArray(); 
                    
                        if(orderItemSummary.physicalGiftCard__c){
                            gen.writeStartObject();
                            gen.writeStringField('msg_type', 'OL');
                            if(orderItemSummary.gcMessage__c!=null){
                                gen.writeStringField('msg' , WM_Utils.getString(orderItemSummary.gcMessage__c));
                            }
                            gen.writeEndObject();
                        } else if(WM_Utils.getString(ordrSummary.exchangeOrderNumber__c)!=null){
                            gen.writeStartObject();
                            gen.writeStringField('msg_type', 'B');
                            gen.writeStringField('msg', Label.Messaging_Prefix+''+WM_Utils.getString(ordrSummary.exchangeOrderNumber__c ));
                            gen.writeEndObject();
                        } else if(fulfillmentOrder.Type=='Special') {
                            gen.writeStartObject();
                            gen.writeStringField('msg_type', 'SH');
                            gen.writeStringField('msg_label', 'LOCATION');
                            gen.writeStringField('msg', WM_Utils.getStringOrReturnEmptyString(ordrItem.vendorLocation__c)); 
                            gen.writeEndObject();
                            gen.writeStartObject();
                            gen.writeStringField('msg_type', 'SH');
                            gen.writeStringField('msg_label', 'VENDOR #');
                            gen.writeStringField('msg', WM_Utils.getStringOrReturnEmptyString(ordrItem.vendorNumber__c));
                            gen.writeEndObject();
                            gen.writeStartObject();
                            gen.writeStringField('msg_type', 'SH');
                            gen.writeStringField('msg_label', 'VENDOR NAME');
                            gen.writeStringField('msg', WM_Utils.getStringOrReturnEmptyString(ordrItem.vendorName__c));
                            gen.writeEndObject();
                            gen.writeStartObject();
                            gen.writeStringField('msg_type', 'SH');
                            gen.writeStringField('msg_label', 'VENDOR PART#');
                            gen.writeStringField('msg', WM_Utils.getStringOrReturnEmptyString(ordrItem.manufacturerSKU__c));
                            gen.writeEndObject();
                            gen.writeStartObject();
                            gen.writeStringField('msg_type', 'SH');
                            gen.writeStringField('msg_label', 'DESCRIPTION');
                            gen.writeStringField('msg', WM_Utils.getStringOrReturnEmptyString(ordrItem.longDescription__c));
                            gen.writeEndObject();
                            gen.writeStartObject();
                            gen.writeStringField('msg_type', 'SH');
                            gen.writeStringField('msg_label', 'UNIT OF MEASURE');
                            gen.writeStringField('msg', WM_Utils.getStringOrReturnEmptyString(ordrItem.unitMeasure__c));
                            gen.writeEndObject();
                            gen.writeStartObject();
                            gen.writeStringField('msg_type', 'SH');
                            gen.writeStringField('msg_label', 'RETAIL PRICE');
                            gen.writeNumberField('msg', WM_Utils.getDouble(ordrItem.UnitPrice));
                            gen.writeEndObject();
                            gen.writeStartObject();
                            gen.writeStringField('msg_type', 'SH');
                            gen.writeStringField('msg_label', 'WEIGHT');
                            gen.writeStringField('msg', WM_Utils.getStringOrReturnEmptyString(ordrItem.weight__c));
                            gen.writeEndObject();
                            gen.writeStartObject();
                            gen.writeStringField('msg_type', 'SH');
                            gen.writeStringField('msg_label', 'SO NOTE');
                            gen.writeStringField('msg', WM_Utils.getStringOrReturnEmptyString(ordrItem.notes__c));
                            gen.writeEndObject();
                        }
                    
                        gen.writeEndArray();
                        
                        
                        gen.writeEndObject();
                        lineNumber++;
                    }
                    gen.writeEndArray();
                    
                    gen.writeEndObject();
                    gen.writeEndObject();
                    String payLoad = gen.getAsString();
                    system.debug('payload for FO ID: ' + fulfillmentOrder.Id);
                    system.debug('payload: ' + payLoad);
                    
                    request.setBody(payLoad);
                    request.setTimeout(60000);
                    System.debug('request : '+ request);
                    HttpResponse response = new HttpResponse();
                    response = http.send(request);
                    system.debug('getStatusCode ' + response.getStatusCode());
                    system.debug('getBody ' + response.getBody());
                    if(response.getStatusCode()==200){
                        fulfillmentOrder.JSON_sent_to_TIBCO__c = payLoad;
                        fulfillmentOrder.Status = 'Pickpack';
                        fulfilList.add(fulfillmentOrder);
                        system.debug('Success Updated FO');			
                        mapOfFulFillmentIDWithResult.put(fulfillId,true);
                        result.add(true);
                    }
                    else{
                        fulfillmentOrder.Status = 'Failed';
                        mapOfFulFillmentIDWithResult.put(fulfillId,false);
                        result.add(false);
                    }
                }
                else{
                    result.add(false);
                }
            }
            catch(Exception e) {
                system.debug('Exception occured: '+e);
                if(e!=null){
                    if(e.getStackTraceString()!=null){
                        mapOfFulFillmentIDWithResult.put(fulfillId,false);
                        for(Id foId  : mapOfFulFillmentIDWithResult.keyset()){
                            if(mapOfFulFillmentIDWithResult.get(foId) == false){
                                FulFillmentOrder fo = new FulFillmentOrder();
                                fo.Id = foId;
                                fo.CancelReason__c = '-';
                                update fo;
                            }
                        }

                        result.add(false);
                    }
                    else{
                        result.add(false);
                    }
                }
                result.add(false);
            }
        }
        Update fulfilList; 
        List<FeedItem> postList = new list<FeedItem>();
        for(String k :mapOfFulFillmentIDWithResult.keyset()){
            if(mapOfFulFillmentIDWithResult.get(k)){
                FeedItem post = new FeedItem();                    
                post.ParentId = k;     
                post.Title = 'The request to PickOut Service was successful';
                post.Body = 'The request to PickOut Service was successful';
                postList.add(post);
            }
            else{
                FeedItem post = new FeedItem();                    
                post.ParentId = k;     
                post.Title = 'The request to PickOut Service failed';
                post.Body = 'The request to PickOut Service failed';
                postList.add(post);
            }
        }
        if(postList.size()>0){
            insert postList;   
        }

    }
}