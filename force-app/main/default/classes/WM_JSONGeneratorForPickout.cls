public class WM_JSONGeneratorForPickout {
    
    public static JSONGenerator formtheJSONBody(ObjectWrapperForPickOut owrp){
        system.debug('JSONGenerator formtheJSONBody');
        Integer lineNumber = 1;
        FulfillmentOrder fulfillmentOrder = owrp.fulfillmentOrder;
        OrderSummary ordrSummary = owrp.mapOfFOWithOrderSummary.get(fulfillmentOrder.Id);
        Account acc = owrp.mapOfFOWithAccount.get(fulfillmentOrder.Id);
        List<Address__c> listOfAddress = acc.Addresses__r;
        List<Tax_Exemption__c> TaxExemptnList = acc.Tax_Exemptions__r;
        List<OrderPaymentSummary> ordrPaySumList = ordrSummary.OrderPaymentSummaries;
        List<FulfillmentOrderLineItem> fulFillmntLineItemList = fulfillmentOrder.FulfillmentOrderLineItems;
        
        // Instanting the JSONGenerator class to start building the json body for the request.
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('PickOut_Request');
        gen.writeStartObject();
        if(WM_Utils.getString(fulfillmentOrder.JDAFulfillmentOrderNumber__c)!=null){
            gen.writeStringField('pick_nbr', WM_Utils.getString(fulfillmentOrder.JDAFulfillmentOrderNumber__c));
        }
        /*if(WM_Utils.getString(fulfillmentOrder.Type)!=null){
			gen.writeStringField('gen_type', WM_Utils.getString(fulfillmentOrder.Type));
		}*/
        if(ordrSummary.OriginalOrder != NULL && WM_Utils.getString(ordrSummary.OriginalOrder.poNumber__c)!=null){
            gen.writeStringField('po_nbr', WM_Utils.getString(ordrSummary.OriginalOrder.poNumber__c)); 
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
        if(ordrSummary.OriginalOrder != NULL && WM_Utils.getString(ordrSummary.OriginalOrder.OrderReferenceNumber)!=null){
            gen.writeStringField('order_nbr', WM_Utils.getString(ordrSummary.OriginalOrder.OrderReferenceNumber));             
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
        /*if(WM_Utils.getString(acc.Suffix__pc)!=null){
			gen.writeStringField('ship_to_suffix', WM_Utils.getString(acc.Suffix__pc)); 
		}*/
        if(!acc.IsPersonAccount ){
            if(WM_Utils.getString(fulfillmentOrder.FulFilledToName)!=null){
                gen.writeStringField('ship_to_company', WM_Utils.getString((fulfillmentOrder.FulFilledToName))); 
            }      
        }
        //gen.writeStringField('ship_to_apt', '');             
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
        if(fulfillmentOrder.DeliveryMethod != NULL && WM_Utils.getString(fulfillmentOrder.DeliveryMethod.ReferenceNumber)!=null){
            gen.writeStringField('ship_via', WM_Utils.getString(fulfillmentOrder.DeliveryMethod.ReferenceNumber));             
        }
        if(fulfillmentOrder.FulfilledFromLocation != NULL && WM_Utils.getString(fulfillmentOrder.FulfilledFromLocation.ExternalReference)!=null){
            gen.writeStringField('whse', WM_Utils.getString(fulfillmentOrder.FulfilledFromLocation.ExternalReference));            
        }
        if(listOfAddress.size()>0 && fulfillmentOrder.DeliveryMethod != NULL && fulfillmentOrder.DeliveryMethod.ReferenceNumber!='5' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='14'  &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='6' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='4' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='98' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='15' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='12' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='physicalGCMethod' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='29' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='3' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='9' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='13' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='002-1' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='004-1' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='005-1' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='006-1' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='007-1' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='001-1' &&
           // Story: WME-44 Developer: Manohar Notes: Commented following Line
           //  ordrDelMethod.ReferenceNumber!='SDVN' && 
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='10' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='11' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='23' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='28' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='loyaltyGoldShippingMethod' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='7' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='2' &&
           fulfillmentOrder.DeliveryMethod.ReferenceNumber!='1'){
               if(listOfAddress.size() > 0 && WM_Utils.getString(listOfAddress[0].csh_van_route__c)!=null){
                   // Story: WME-44 Developer: Manohar Notes: Commented following Line
                   //    gen.writeStringField('van_route', WM_Utils.getString(listOfAddress[0].csh_van_route__c));             
                   
                   // Story: WME-44 Developer: Manohar Notes: Created new if condition
                   
                   if(fulfillmentOrder.DeliveryMethod != NULL && WM_Utils.getString(fulfillmentOrder.DeliveryMethod.ReferenceNumber)!= null && WM_Utils.getString(fulfillmentOrder.DeliveryMethod.ReferenceNumber).length()==4){
                       gen.writeStringField('van_route', WM_Utils.getString(fulfillmentOrder.DeliveryMethod.ReferenceNumber));  
                       
                   }             
               }
               if(listOfAddress.size() > 0 && WM_Utils.getString(listOfAddress[0].csh_van_route_seq__c)!=null){
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
        if(ordrSummary.OriginalOrder != NULL && WM_Utils.getString(ordrSummary.OriginalOrder.BillingStreet)!=null){
            gen.writeStringField('sold_to_addr1', WM_Utils.getString(ordrSummary.OriginalOrder.BillingStreet));
        }
        
        if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getString(ordrSummary.OriginalOrder.BillingCountry)!=null){
            gen.writeStringField('sold_to_country', WM_Utils.getString(ordrSummary.OriginalOrder.BillingCountry));
        }
        if(ordrSummary.OriginalOrder != NULL && WM_Utils.getString(ordrSummary.OriginalOrder.BillingCity)!=null){
            gen.writeStringField('sold_to_city', WM_Utils.getString(ordrSummary.OriginalOrder.BillingCity));
        }
        if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getString(ordrSummary.OriginalOrder.BillingState)!=null){
            gen.writeStringField('sold_to_state', WM_Utils.getString(ordrSummary.OriginalOrder.BillingState));
        }
        if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getString(ordrSummary.OriginalOrder.BillingPostalCode)!=null){
            gen.writeStringField('sold_to_postal_code', WM_Utils.getString(ordrSummary.OriginalOrder.BillingPostalCode));
        }
        if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getString(ordrSummary.OriginalOrder.BillingPhoneNumber)!=null){
            gen.writeStringField('sold_to_day_phone', WM_Utils.getString(ordrSummary.OriginalOrder.BillingPhoneNumber));
        }
        
        gen.writeEndObject();
        gen.writeFieldName('CustomerBillToAddress');
        gen.writeStartObject();
        //Pro account first condition (check if parent exist)
        if(!acc.IsPersonAccount && acc.ParentId!=null){
            //Account parentAccount = WM_ServiceHelper.getAccount(acc.ParentId);
            //List<Address__c> addressList = WM_CRMServiceHelper.getAddress(acc.ParentId);
            Account parentAccount = owrp.parentAccountMap.get(acc.Id);
            List<Address__c> addressList = parentAccount.Addresses__r;
            if(parentAccount != NULL) {
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
            if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getString(ordrSummary.OriginalOrder.BillingStreet)!=null){
                gen.writeStringField('bill_to_addr1', WM_Utils.getString(ordrSummary.OriginalOrder.BillingStreet));
            }
            
            if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getString(ordrSummary.OriginalOrder.BillingCity)!=null){
                gen.writeStringField('bill_to_city', WM_Utils.getString(ordrSummary.OriginalOrder.BillingCity));
            }
            if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getString(ordrSummary.OriginalOrder.BillingState)!=null){
                gen.writeStringField('bill_to_state', WM_Utils.getString(ordrSummary.OriginalOrder.BillingState));
            }
            if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getString(ordrSummary.OriginalOrder.BillingPostalCode)!=null){
                gen.writeStringField('bill_to_postal_code', WM_Utils.getString(ordrSummary.OriginalOrder.BillingPostalCode));
            }
            if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getString(ordrSummary.OriginalOrder.BillingCountry)!=null){
                gen.writeStringField('bill_to_country', WM_Utils.getString(ordrSummary.OriginalOrder.BillingCountry));
            }
        }
        gen.writeEndObject();
        gen.writeFieldName('OrderHeader');
        gen.writeStartObject();
        if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getString(ordrSummary.OriginalOrder.OrderReferenceNumber)!=null){
            gen.writeStringField('order_nbr', WM_Utils.getString(ordrSummary.OriginalOrder.OrderReferenceNumber));
        }
        if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getString(ordrSummary.OriginalOrder.OrderedDate)!=null){
            gen.writeStringField('order_date', WM_Utils.getStringForDateTimeNoTimeZone(ordrSummary.OriginalOrder.OrderedDate));
        }
        if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getString(ordrSummary.OriginalOrder.CreatedDate)!=null){
            gen.writeStringField('entered_date', WM_Utils.getStringForDateTimeNoTimeZone(ordrSummary.OriginalOrder.CreatedDate));
        }
        if(ordrSummary.OriginalOrder != NULL && WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalAdjustedDeliveryAmount)!=null){
            gen.writeNumberField('freight_amt', WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalAdjustedDeliveryAmount));
        }
        //if( WM_Utils.getString(salesChannl.SalesChannelName)!=null){
        //gen.writeStringField('order_channel', WM_Utils.getString(salesChannl.SalesChannelName));
        gen.writeStringField('order_channel', 'I');
        //}
        if (ordrSummary.OriginalOrder != NULL && ordrSummary.OriginalOrder.associateID__c != null) {
            gen.writeStringField('order_type', 'P');
        } else {
            gen.writeStringField('order_type', 'I');
        }
        //}
        //gen.writeStringField('sales_rep_nbr', 
        
        //if( WM_Utils.getString(acc.Cust_Payment_Class__c)!=null){
        // gen.writeStringField('customer_class',WM_Utils.getString(acc.Cust_Payment_Class__c));
        
        // As per ticket 1388
        //gen.writeStringField('customer_class','R');
        // }
        if( WM_Utils.getString(acc.Cust_Payment_Class__c)!=null){
            gen.writeStringField('customer_class', WM_Utils.getString(acc.Cust_Payment_Class__c));
        }
        else{
            gen.writeStringField('customer_class','R');
        }
        
        if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getString(ordrSummary.OriginalOrder.BillingEmailAddress)!=null){
            gen.writeStringField('email_address', WM_Utils.getString(ordrSummary.OriginalOrder.BillingEmailAddress));
        }
        //gen.writeStringField('entity', 
        gen.writeEndObject();
        gen.writeFieldName('OrderShipTo');
        gen.writeStartObject();
        if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getString(ordrSummary.OriginalOrder.OrderReferenceNumber)!=null){
            gen.writeStringField('order_nbr', WM_Utils.getString(ordrSummary.OriginalOrder.OrderReferenceNumber));
        }
        if( WM_Utils.getDouble(fulfillmentOrder.TotalAdjustmentAmtWithTax)!=null){
            gen.writeNumberField('addl_charge_amt',  WM_Utils.getDouble(fulfillmentOrder.TotalAdjustmentAmtWithTax));
        }
        if(  WM_Utils.getDouble(fulfillmentOrder.TotalAdjustmentAmtWithTax)!=null){
            gen.writeNumberField('addl_charge_balance_amt', WM_Utils.getDouble(fulfillmentOrder.TotalAdjustmentAmtWithTax));
        }
        //gen.writeStringField('cancel_bo', WM_Utils.getString(ordr.OrderNumber));
        //gen.writeNumberField('est_freight_amt', WM_Utils.getString(ordr.OrderNumber));
        if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalAdjustedDeliveryAmount)!=null){
            gen.writeNumberField('freight_amt', WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalAdjustedDeliveryAmount));
        }
        if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalAdjustedDeliveryAmount)!=null){
            gen.writeNumberField('freight_balance_amt', WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalAdjustedDeliveryAmount));
        }
        //gen.writeNumberField('hand_charge_amt', WM_Utils.getString(ordr.OrderNumber));
        //gen.writeNumberField('hand_balance_amt', WM_Utils.getString(ordr.OrderNumber));
        if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalAdjustedProductAmount)!=null){
            gen.writeNumberField('merch_amt', WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalAdjustedProductAmount));
        }
        if( WM_Utils.getDouble(fulfillmentOrder.TotalProductAmount)!=null){
            gen.writeNumberField('merch_balance_amt', WM_Utils.getDouble(fulfillmentOrder.TotalProductAmount));
        }
        if(TaxExemptnList!=null && TaxExemptnList.size() > 0){
            if(WM_Utils.getString(TaxExemptnList[0].Exemption_Certificate__c)!=null)
            {
                gen.writeStringField('resale_exemption_nbr', WM_Utils.getString(TaxExemptnList[0].Exemption_Certificate__c));
            }
            
        }
        if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalTaxAmount)!=null){
            gen.writeNumberField('tax_amt', WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalTaxAmount));
        }
        if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalTaxAmount)!=null){
            gen.writeNumberField('tax_balance_amt', WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalTaxAmount));
        }
        if(ordrSummary.OriginalOrder!= NULL && WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalDeliveryAdjDistAmount)!=null){
            gen.writeNumberField('addl_freight_amt', WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalDeliveryAdjDistAmount));
        }
        if(ordrSummary.OriginalOrder!= NULL &&  WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalDeliveryAdjDistAmount)!=null){
            gen.writeNumberField('addl_freight_balance_amt', WM_Utils.getDouble(ordrSummary.OriginalOrder.TotalDeliveryAdjDistAmount));
        }
        if(fulfillmentOrder.FulfilledFromLocation!= NULL && WM_Utils.getString(fulfillmentOrder.FulfilledFromLocation.ExternalReference)!=null){
            gen.writeStringField('whse', WM_Utils.getString(fulfillmentOrder.FulfilledFromLocation.ExternalReference));
        }
        if(fulfillmentOrder.DeliveryMethod!= NULL && WM_Utils.getString(fulfillmentOrder.DeliveryMethod.ReferenceNumber)!=null){
            gen.writeStringField('ship_via', WM_Utils.getString(fulfillmentOrder.DeliveryMethod.ReferenceNumber));
        }
        if(fulfillmentOrder.Order_Delivery_Group_Summary__r!= NULL && WM_Utils.getString(fulfillmentOrder.Order_Delivery_Group_Summary__r.fromStoreId__c )!=null){
            gen.writeStringField('destination_store', WM_Utils.getString(fulfillmentOrder.Order_Delivery_Group_Summary__r.fromStoreId__c ));
        }
        
        gen.writeEndObject();
        gen.writeFieldName('OrderPayments');
        gen.writeStartArray();
        
        
        for(OrderPaymentSummary ordrPaySum :ordrPaySumList){  
            PaymentAuthorization paymentAuth = owrp.mapOfOPMWithPaymentAuthorization.get(ordrPaySum.Id);
            gen.writeStartObject();
            //Start WME-361
            // if(WM_Utils.getString(ordrPaySum.Type)!=null){
            //     if(WM_Utils.getString(ordrPaySum.Type)!='Unknown'){
            //         gen.writeStringField('pay_type', WM_Utils.getString(ordrPaySum.Type));
            //     }
            //     else{
            //         String recrdTypeName = [SELECT Id, RecordType.Name FROM AlternativePaymentMethod where id=:ordrPaySum.PaymentMethodId].RecordType.Name;
            
            //         gen.writeStringField('pay_type',recrdTypeName);
            //     }
            // }
            if(WM_Utils.getString(ordrPaySum.Type)!=null){
                if(WM_Utils.getString(ordrPaySum.Type)!='Unknown'){
                    gen.writeStringField('pay_type', WM_Utils.getString(ordrPaySum.Type));
                }
                else if(WM_Utils.getString(paymentAuth)!=null && WM_Utils.getString(paymentAuth.FutureTerms__c)!=null){
                    gen.writeStringField('pay_type', WM_Utils.getString(paymentAuth.FutureTerms__c));
                }
                else {
                    String recrdTypeName = [SELECT Id, RecordType.Name FROM AlternativePaymentMethod where id=:ordrPaySum.PaymentMethodId].RecordType.Name;
                    // Story: WME-478 Developer: Manohar Notes: Added Null Pointer Check
                    if(string.isNotBlank(recrdTypeName)){
                        gen.writeStringField('pay_type',recrdTypeName);
                    }
                }
            }
            //End WME-361
            if(WM_Utils.getString(ordrPaySum.Method)!=null){
                gen.writeStringField('pay_type_desc', WM_Utils.getString(ordrPaySum.Method));
            }
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeFieldName('PickDetails');
        gen.writeStartArray();
        
        for(FulfillmentOrderLineItem fulfilmntOrderLineitm :fulFillmntLineItemList){                 
            /*OrderItem ordrItem =  WM_ServiceHelper.getOrderItem(fulfilmntOrderLineitm.OrderItemId);
            Product2 prod =  WM_ServiceHelper.getProduct(ordrItem.Product2Id); */
            OrderItem ordrItem = owrp.orderItemMap.get(fulfilmntOrderLineitm.Id);
            gen.writeStartObject();
            
            gen.writeNumberField('pick_line_nbr',WM_Utils.getInteger(fulfilmntOrderLineitm.FulfillmentOrderLineItemNumber));
            
            if(WM_Utils.getInteger(fulfilmntOrderLineitm.Quantity)!=null){
                gen.writeNumberField('qty_printed',WM_Utils.getInteger(fulfilmntOrderLineitm.Quantity));
            }
            if(WM_Utils.getDouble(fulfilmntOrderLineitm.UnitPrice)!=null){
                
                // Added by Manohar WME-72 start
                if(WM_Utils.getDouble(fulfilmntOrderLineitm.TotalAdjustmentAmount)!=null){
                    Decimal toround = fulfilmntOrderLineitm.UnitPrice + (fulfilmntOrderLineitm.TotalAdjustmentAmount)/(fulfilmntOrderLineitm.Quantity);
                    Decimal rounded = toRound.setScale(2, RoundingMode.HALF_UP);               
                    gen.writeNumberField('selling_price',WM_Utils.getDouble(rounded));
                } else{
                    gen.writeNumberField('selling_price',WM_Utils.getDouble(fulfilmntOrderLineitm.UnitPrice));
                }
                // 
                // Added by Manohar WME-72 end 
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
                if(ordrItem!= NULL && WM_Utils.getString(ordrItem.Special_Order_SKU__c)!=null){
                    gen.writeStringField('item', WM_Utils.getString(ordrItem.Special_Order_SKU__c));
                }
                else{
                    if(ordrItem!= NULL && ordrItem.Product2!= NULL && WM_Utils.getString(ordrItem.Product2.ProductCode)!=null){
                        gen.writeStringField('item' , WM_Utils.getString(ordrItem.Product2.ProductCode).toUppercase());
                    }  
                }
                if(ordrItem!= NULL && WM_Utils.getString(ordrItem.longDescription__c)!=null){
                    gen.writeStringField('item_desc',WM_Utils.getString(ordrItem.longDescription__c));
                }
            }
            else{
                if(ordrItem!= NULL && ordrItem.Product2!= NULL && WM_Utils.getString(ordrItem.Product2.ProductCode)!=null){
                    gen.writeStringField('item', WM_Utils.getString(ordrItem.Product2.ProductCode));
                }
                if(ordrItem!= NULL && ordrItem.Product2!= NULL && WM_Utils.getString(ordrItem.Product2.Description)!=null){
                    gen.writeStringField('item_desc',WM_Utils.getString(ordrItem.Product2.Description));
                }   
            }
            
            gen.writeFieldName('OrderDetail');
            gen.writeStartObject();
            if(ordrItem!= NULL && WM_Utils.getInteger(ordrItem.LineNumber)!=null){
                gen.writeNumberField('order_detail_nbr', WM_Utils.getInteger(ordrItem.LineNumber));
            }
            //gen.writeStringField('drop_ship',);
            if(ordrItem!= NULL && WM_Utils.getDouble(ordrItem.ListPrice)!=null){
                
                // Added by Manohar WME-72 start
                if(WM_Utils.getDouble(fulfilmntOrderLineitm.TotalAdjustmentAmount)!=null){
                    Decimal toround = fulfilmntOrderLineitm.UnitPrice + (fulfilmntOrderLineitm.TotalAdjustmentAmount)/(fulfilmntOrderLineitm.Quantity);
                    Decimal rounded = toRound.setScale(2, RoundingMode.HALF_UP);               
                    gen.writeNumberField('selling_price',WM_Utils.getDouble(rounded));
                }else{
                    gen.writeNumberField('selling_price',WM_Utils.getDouble(ordrItem.ListPrice));
                }
                // Added by Manohar WME-72 end
            }
            if(fulfillmentOrder.FulfilledFromLocation != NULL && WM_Utils.getString(fulfillmentOrder.FulfilledFromLocation.ExternalReference)!=null){
                gen.writeStringField('whse' , WM_Utils.getString(fulfillmentOrder.FulfilledFromLocation.ExternalReference));
            }
            gen.writeEndObject();
            gen.writeFieldName('Item');
            gen.writeStartObject();
            if(ordrItem!= NULL && fulfillmentOrder.Type=='Special'){
                if(WM_Utils.getString(ordrItem.Special_Order_SKU__c)!=null){
                    gen.writeStringField('Item_Number', WM_Utils.getString(ordrItem.Special_Order_SKU__c));
                }
                else{
                    if(ordrItem.Product2!= NULL && WM_Utils.getString(ordrItem.Product2.ProductCode)!=null){
                        gen.writeStringField('Item_Number' , WM_Utils.getString(ordrItem.Product2.ProductCode).toUppercase());
                    }  
                }
            }
            else{
                if(ordrItem!= NULL && ordrItem.Product2!= NULL && WM_Utils.getString(ordrItem.Product2.ProductCode)!=null){
                    gen.writeStringField('Item_Number' , WM_Utils.getString(ordrItem.Product2.ProductCode));
                }
            }
            if(fulfillmentOrder.Type=='Drop Ship'){
                
                
                
                gen.writeStringField('Drop_ship_item','Y');
            }
            else{
                gen.writeStringField('Drop_ship_item','N');
            }
            if(ordrItem!= NULL && WM_Utils.getString(ordrItem.weight__c)!=null){
                gen.writeStringField('Ship_weight',WM_Utils.getString(ordrItem.weight__c));
            }
            
            
            if (fulfillmentOrder.Type=='Special') {
                gen.writeStringField('LCL_Location_class','01');
            } else if (fulfillmentOrder.Type=='Physical Gift Card') {
                gen.writeStringField('LCL_Location_class','04');
            } else if (fulfillmentOrder.Type=='Member/Tow') {
                gen.writeStringField('LCL_Location_class','05');                       
            }
            
            if(ordrItem!= NULL && WM_Utils.getString(ordrItem.unitMeasure__c)!=null){
                gen.writeStringField('Unit_of_measure', WM_Utils.getString(ordrItem.unitMeasure__c));
            }
            if(ordrItem!= NULL && WM_Utils.getString(ordrItem.vendorNumber__c)!=null){
                gen.writeStringField('Vendor_Nbr', WM_Utils.getString(ordrItem.vendorNumber__c));
            }
            if(ordrItem!= NULL && WM_Utils.getString(ordrItem.vendorName__c)!=null){
                gen.writeStringField('Manufacturer_Vendor', WM_Utils.getString(ordrItem.vendorName__c));
            }
            
            if(fulfillmentOrder.FulfilledFromLocation!= NULL && WM_Utils.getString(fulfillmentOrder.FulfilledFromLocation.ExternalReference)!=null){
                gen.writeStringField('Warehouse' , WM_Utils.getString(fulfillmentOrder.FulfilledFromLocation.ExternalReference ));
            }
            
            gen.writeEndObject();
            //OrderItemSummary orderItemSummary = WM_ServiceHelper.getOrderItemSummary(fulfilmntOrderLineitm.OrderItemSummaryId);
            OrderItemSummary orderItemSummary = owrp.mapOfFOWithOrderItemSummary.get(fulfilmntOrderLineitm.OrderItemSummaryId);
            system.debug('Test-orderItemSummary:'+orderItemSummary);
            
            gen.writeFieldName('PickDetailMsg');
            gen.writeStartArray(); 
            
            
            
            if(orderItemSummary!= NULL && orderItemSummary.physicalGiftCard__c){
                gen.writeStartObject();
                gen.writeStringField('msg_type', 'OL');
                if(orderItemSummary.gcMessage__c!=null){
                    gen.writeStringField('msg' , WM_Utils.getString(orderItemSummary.gcMessage__c));
                }
                gen.writeEndObject();
                
                // WME-230, Developer: Satish V Comment: Following else if single line
            } else if(WM_Utils.getString(ordrSummary.exchangeOrderNumber__c)!=null && fulfillmentOrder.Type !='Special'){
                gen.writeStartObject();
                gen.writeStringField('msg_type', 'B');
                gen.writeStringField('msg', Label.Messaging_Prefix+''+WM_Utils.getString(ordrSummary.exchangeOrderNumber__c ));
                gen.writeEndObject();
            } else if(ordrItem!= NULL && fulfillmentOrder.Type=='Special') {
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
        return gen;
    }
    
    
}