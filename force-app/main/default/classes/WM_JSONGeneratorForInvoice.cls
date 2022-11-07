public class WM_JSONGeneratorForInvoice {
    
    
    public static JSONGenerator formtheJSONBody(ObjectWrapper oWrp,WM_InvoiceCreditMemoWrapper wrp){
        system.debug('called  from WM_JSONGeneratorForInvoice');
        Integer seqNumber = 1;
        Double totalLoyalityCertAmt = 0.0;
        Double ipmDepositAmt=0.0;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('InvoiceOut_Request');
        gen.writeStartObject();
        if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.OrderReferenceNumber)!=null){
            gen.writeStringField('ihd_order_nbr', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.OrderReferenceNumber));
        }
        if(WM_Utils.getString(wrp.InvoiceNumber)!=null){
            gen.writeStringField('ihd_invoice_nbr', WM_Utils.getString(wrp.InvoiceNumber));
        }
        if(WM_Utils.getString(wrp.InvoiceDate)!=null){
            gen.writeStringField('ihd_sj_print_date', WM_Utils.getStringForDateTimeNoTimeZone(wrp.InvoiceDate));
        }
        gen.writeFieldName('OrderHeader');
        gen.writeStartObject();
        if( WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.OrderReferenceNumber)!=null){
            gen.writeStringField('ohd_reference_order_nbr', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.OrderReferenceNumber));
        }
        if( WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.OrderedDate)!=null){
            gen.writeStringField('ohd_order_date', WM_Utils.getStringForDateTimeNoTimeZone(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.OrderedDate));
        }
        if( WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.CreatedDate)!=null){
            gen.writeStringField('ohd_enter_date', WM_Utils.getStringForDateTimeNoTimeZone(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.CreatedDate));
        }
        if( WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.CreatedDate)!=null){
            gen.writeStringField('ohd_enter_time', WM_Utils.getStringForDateTimeNoTimeZone(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.CreatedDate));
        }
        if( WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.SalesChannel.SalesChannelName)!=null){
            gen.writeStringField('ohd_order_channel','I');
        }
        if( WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.associateId__c)!=null){
            gen.writeStringField('ohd_order_type', 'P');
        } else {
            gen.writeStringField('ohd_order_type', 'I');
        }
        if( WM_Utils.getInteger(oWrp.invoiceObj.BillingAccount.Sales_Person_Number__c)!=null){
            gen.writeNumberField('ohd_salesman_nbr', WM_Utils.getInteger(oWrp.invoiceObj.BillingAccount.Sales_Person_Number__c));
        }
        if( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.AccountSource)!=null){
            gen.writeStringField('ohd_invoice_source_code', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.AccountSource));
        }
        else{
          gen.writeStringField('ohd_invoice_source_code', '93WEB000A');  
        
        }
        
        if(oWrp.invoiceObj.BillingAccount.IsPersonAccount && oWrp.invoiceObj.BillingAccount.Cust_Payment_Class__c == 'A'){
            gen.writeStringField('ohd_invoice_division_code',WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Associate__c));
            gen.writeStringField('ohd_invoice_entity_nbr',WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Associate__c));
            
        }
        else if(oWrp.invoiceObj.BillingAccount.IsPersonAccount && oWrp.invoiceObj.BillingAccount.Cust_Payment_Class__c != 'A'){
            gen.writeStringField('ohd_invoice_division_code', 'Retail');
            gen.writeStringField('ohd_invoice_entity_nbr', 'Retail');
            
        }
        else {
            gen.writeStringField('ohd_invoice_division_code', 'Business');
            gen.writeStringField('ohd_invoice_entity_nbr', 'Business');
        }
        
        if( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Cust_Payment_Class__c)!=null){
            gen.writeStringField('ohd_customer_class', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Cust_Payment_Class__c));
        }
        else{
            gen.writeStringField('ohd_customer_class','R');
        }
        
        if( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.AccountNumber)!=null){
            gen.writeStringField('ohd_cbt_account_nbr', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.AccountNumber));
        }
        else if( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.AccountNumber)!=null){
            gen.writeStringField('ohd_cbt_account_nbr', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.AccountNumber));
        }
        if( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.AccountNumber)!=null){
            gen.writeStringField('ohd_cst_customer_nbr', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.AccountNumber));
        }
        
        if( WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.associateID__c)!=null){
            gen.writeStringField('ohd_entered_by_user', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.associateID__c));
        }
        
        gen.writeEndObject();
        
        gen.writeFieldName('CustomerSoldTo');
        gen.writeStartObject();          
        
        if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.SoldToNumber__c)!=null){
            gen.writeStringField('sold_to_nbr', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.SoldToNumber__c));
        }
        if( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Salutation__pc)!=null){
            gen.writeStringField('sold_to_prefix', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Salutation__pc));
        }
        if( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.FirstName)!=null){
            gen.writeStringField('sold_to_fname', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.FirstName));
        }
        if( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.LastName)!=null){
            gen.writeStringField('sold_to_lname', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.LastName));
        }
        if( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Suffix__pc)!=null){
            gen.writeStringField('sold_to_suffix', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Suffix__pc));
        }
        if( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Name)!=null){
            gen.writeStringField( 'sold_to_company', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Name));
        }
        if( WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingStreet)!=null){
            gen.writeStringField('sold_to_address1', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingStreet));
        }
        /*if( (addr.wmPreferredAddress__c)!=null &&  (addr.Address_Line_2__c)!=null){
if(addr.wmPreferredAddress__c =True){
gen.writeStringField('sold_to_address2',WM_Utils.getString(addr.Address_Line_2__c));

}
}
if( (addr.wmPreferredAddress__c)!=null &&  (addr.Address_Line_3__c)!=null){
if(addr.wmPreferredAddress__c =True){
gen.writeStringField('sold_to_address3',WM_Utils.getString(addr.Address_Line_3__c));

}
}*/
        if( WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingCity)!=null){
            gen.writeStringField('sold_to_city', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingCity));
        }     
        if( WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingCountry)!=null){
            gen.writeStringField('sold_to_country', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingCountry));
        } 
        if( WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingState)!=null){
            gen.writeStringField('sold_to_state', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingState));
        }
        if( WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingPostalCode)!=null){
            gen.writeStringField('sold_to_zip', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingPostalCode));
        }
        
        if(oWrp.invoiceObj.BillingAccount.IsPersonAccount ){
            if( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.PersonEmail)!=null) {
                gen.writeStringField('sold_to_email_address', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.PersonEmail));
            }
            if( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.PersonMobilePhone)!=null) {
                gen.writeStringField('sold_to_day_phone', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.PersonMobilePhone));
            }
        }
        else {
            if( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Email__c)!=null) {
                gen.writeStringField('sold_to_email_address', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Email__c));
            }
            if ( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Phone)!=null) {
                gen.writeStringField('sold_to_day_phone', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Phone));
            }
        }
        if(oWrp.invoiceObj.BillingAccount.Associate__c!= null){
            gen.writeBooleanField('sold_to_associate', oWrp.invoiceObj.BillingAccount.Associate__c);
        }
        if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.cst_tax_code__c)!=null){
            gen.writeStringField('sold_to_type', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.cst_tax_code__c));
        }
        if( (oWrp.invoiceObj.BillingAccount.Associate__c)!=null &&  (oWrp.invoiceObj.BillingAccount.AssociateId__c)!=null){
            if(oWrp.invoiceObj.BillingAccount.Associate__c ==True){
                gen.writeStringField('sold_to_alternate_id',WM_Utils.getString(oWrp.invoiceObj.BillingAccount.AssociateId__c));
             }   
            }
            else if(oWrp.invoiceObj.BillingAccount.Associate__c ==False){
                if( (oWrp.invoiceObj.BillingAccount.Associate__c)!=null && WM_Utils.getString (oWrp.invoiceObj.BillingAccount.loyaltyAccountNumber__c)!=null){
                    gen.writeStringField('sold_to_alternate_id', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.loyaltyAccountNumber__c));
                }
            }
        
        gen.writeFieldName('Placer');
        gen.writeStartObject();
        
        if(WM_Utils.getInteger(oWrp.invoiceObj.BillToContact.IndividualNumber__c)!=null){
            gen.writeNumberField('placer_nbr', WM_Utils.getInteger(oWrp.invoiceObj.BillToContact.IndividualNumber__c));
        }
        
        if(WM_Utils.getString(oWrp.invoiceObj.BillToContact.FirstName)!=null){
            gen.writeStringField('placer_fname', WM_Utils.getString(oWrp.invoiceObj.BillToContact.FirstName));
        }
        if(WM_Utils.getString(oWrp.invoiceObj.BillToContact.LastName)!=null){
            gen.writeStringField('placer_lname', WM_Utils.getString(oWrp.invoiceObj.BillToContact.LastName));
        }
        gen.writeEndObject();
        
        gen.writeEndObject();
        gen.writeFieldName('CustomerBillTo');
        gen.writeStartObject();
        if(!oWrp.invoiceObj.BillingAccount.IsPersonAccount && oWrp.invoiceObj.BillingAccount.ParentId!=null){
            
            if( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.AccountNumber)!=null){
                gen.writeStringField('bill_to_nbr', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.AccountNumber));
            }
            if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.Salutation__pc)!=null ){
                gen.writeStringField('bill_to_prefix', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.Salutation__pc));
            }
            if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.FirstName)!=null){
                gen.writeStringField('bill_to_fname', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.FirstName));
            }
            if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.MiddleName)!=null){
                gen.writeStringField('bill_to_initial', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.MiddleName));
            }
            if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.LastName)!=null){
                gen.writeStringField('bill_to_lname', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.LastName));
            }
            if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.Suffix__pc)!=null){
                gen.writeStringField('bill_to_suffix', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.Suffix__pc));
            }
            if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.Name)!=null){
                gen.writeStringField('bill_to_company', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Parent.Name));
            }
            if(oWrp.parentAddressMap.get(oWrp.invoiceObj.BillingAccount.ParentId)!=null){
                if(WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.invoiceObj.BillingAccount.ParentId).Address_Line_1__c)!=null){
                    gen.writeStringField('bill_to_address1', WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.invoiceObj.BillingAccount.ParentId).Address_Line_1__c));
                }
                if(WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.invoiceObj.BillingAccount.ParentId).Address_Line_2__c)!=null){
                    gen.writeStringField('bill_to_address2', WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.invoiceObj.BillingAccount.ParentId).Address_Line_2__c));
                }
                if(WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.invoiceObj.BillingAccount.ParentId).Address_Line_3__c)!=null){
                    gen.writeStringField('bill_to_address3', WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.invoiceObj.BillingAccount.ParentId).Address_Line_3__c));
                }
                if(WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.invoiceObj.BillingAccount.ParentId).City__c)!=null ){
                    gen.writeStringField('bill_to_city', WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.invoiceObj.BillingAccount.ParentId).City__c));
                }
                if(WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.invoiceObj.BillingAccount.ParentId).Country__c)!=null){
                    gen.writeStringField('bill_to_country', WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.invoiceObj.BillingAccount.ParentId).Country__c));
                }
                if(WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.invoiceObj.BillingAccount.ParentId).State__c)!=null){
                    gen.writeStringField('bill_to_state', WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.invoiceObj.BillingAccount.ParentId).State__c));
                }
                if(WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.invoiceObj.BillingAccount.ParentId).Postal_Code__c)!=null ) {
                    gen.writeStringField('bill_to_zip', WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.invoiceObj.BillingAccount.ParentId).Postal_Code__c));
                }
            }
        }
        else{
            if( WM_Utils.getString(oWrp.invoiceObj.BillingAccount.AccountNumber)!=null){
                gen.writeStringField('bill_to_nbr', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.AccountNumber));
            }
            if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Salutation__pc)!=null ){
                gen.writeStringField('bill_to_prefix', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Salutation__pc));
            }
            if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.FirstName)!=null){
                gen.writeStringField('bill_to_fname', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.FirstName));
            }
            if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.MiddleName)!=null){
                gen.writeStringField('bill_to_initial', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.MiddleName));
            }
            if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.LastName)!=null){
                gen.writeStringField('bill_to_lname', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.LastName));
            }
            if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Suffix__pc)!=null){
                gen.writeStringField('bill_to_suffix', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Suffix__pc));
            }
            if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Name)!=null){
                gen.writeStringField('bill_to_company', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Name));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingStreet)!=null){
                gen.writeStringField('bill_to_address1', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingStreet));
            }
            /*if(WM_Utils.getString(addr.Address_Line_2__c)!=null){
gen.writeStringField('bill_to_address2', WM_Utils.getString(addr.Address_Line_2__c));
}
if(WM_Utils.getString(addr.Address_Line_3__c)!=null){
gen.writeStringField('bill_to_address3', WM_Utils.getString(addr.Address_Line_3__c));
}*/
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingCity)!=null ){
                gen.writeStringField('bill_to_city', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingCity));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingCountry)!=null ){
                gen.writeStringField('bill_to_country', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingCountry));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingState)!=null ){
                gen.writeStringField('bill_to_state', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingState));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingPostalCode)!=null) {
                gen.writeStringField('bill_to_zip', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.BillingPostalCode));
            }              
        }
        gen.writeEndObject();
        
        gen.writeFieldName('InvoicePaymentMethods');
        //WMSA-5091
        totalLoyalityCertAmt = 0.0;
        for(OrderPaymentSummary ordrPaySum :oWrp.ordrPaySumList){
            if(ordrPaySum.PaymentAuthorizations.size()>0){
                for(PaymentAuthorization payAuth:ordrPaySum.PaymentAuthorizations){ 
                    if(String.isNotEmpty(payAuth.loyaltyDetailsOMS__c)){
                        List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(payAuth.loyaltyDetailsOMS__c);
                        for(Object fld : fieldList){    
                            Map<String,Object> data = (Map<String,Object>)fld;
                            totalLoyalityCertAmt += Double.valueOf(data.get('CertAvailableBalance'));
                        }
                    }
                }
            }
        }
        gen.writeStartArray();
        for(OrderPaymentSummary ordrPaySum :oWrp.ordrPaySumList){
            // totalLoyalityCertAmt = 0.0;
            String recrdTypeName;
            gen.writeStartObject();
            gen.writeNumberField('ipm_seq_nbr', WM_Utils.getInteger(seqNumber));
            system.debug('Data22++++++++'+ WM_Utils.getString(ordrPaySum.Type));
            if(WM_Utils.getString(ordrPaySum.Type)!=null){
                if(WM_Utils.getString(ordrPaySum.Type)!='Unknown'){
                    gen.writeStringField('ipm_pay_type', WM_Utils.getString(ordrPaySum.Type));
                    system.debug('Data++++++++'+ WM_Utils.getString(ordrPaySum.Type));
                }
                else if(oWrp.mapOfAlternatePayment!=null && oWrp.mapOfAlternatePayment.get(ordrPaySum.Id)!=null && oWrp.mapOfAlternatePayment.get(ordrPaySum.Id).RecordType.Name!=null){
                    recrdTypeName = oWrp.mapOfAlternatePayment.get(ordrPaySum.Id).RecordType.Name;
                    system.debug('recordtypeName++++'+ recrdTypeName);
                    gen.writeStringField('ipm_pay_type',recrdTypeName);
                    system.debug('Data111++++++++'+ recrdTypeName);
                }
                //WME-294 --- START
                else if(WM_Utils.getString(ordrPaySum.PaymentAuthorizations[0])!=null && WM_Utils.getString(ordrPaySum.PaymentAuthorizations[0].FutureTerms__c)!=null){
                    gen.writeStringField('ipm_pay_type', WM_Utils.getString(ordrPaySum.PaymentAuthorizations[0].FutureTerms__c));
                }
                //WME-294 --- END
            }
            
            if(WM_Utils.getDouble(wrp.TotalTaxAmount )!=null){
                gen.writeNumberField('ipm_tax_amt', WM_Utils.getDouble(wrp.TotalTaxAmount));
            }
            
            gen.writeNumberField('ipm_ord_lvl_frt_tax_amt', WM_Utils.getDouble(oWrp.freightTaxAmt));    
            
            if(WM_Utils.getString(ordrPaySum.Type)!='Unknown'){
                if(WM_Utils.getString(ordrPaySum.Type)=='PayPal'){
                    System.debug('AAA: mapOfDigitalWalletPayment:' + oWrp.mapOfDigitalWalletPayment);
                    if(oWrp.mapOfDigitalWalletPayment.get(ordrPaySum.Id).aurusApprovalCode__c!=null){
                        gen.writeStringField('ipm_auth_number', WM_Utils.getString(oWrp.mapOfDigitalWalletPayment.get(ordrPaySum.Id).aurusApprovalCode__c));
                    }     
                }
                else{
                    if(oWrp.mapOfCardPayment.get(ordrPaySum.Id).aurusApprovalCode__c!=null){
                        gen.writeStringField('ipm_auth_number', WM_Utils.getString(oWrp.mapOfCardPayment.get(ordrPaySum.Id).aurusApprovalCode__c));
                    }     
                }

            } else {
                if(WM_Utils.getString(ordrPaySum.PaymentAuthorizations[0].gcAuthCode__c)!=null){
                    gen.writeStringField('ipm_auth_number', WM_Utils.getString(ordrPaySum.PaymentAuthorizations[0].gcAuthCode__c));
                }     
            }
            if(WM_Utils.getString(wrp.Status )!=null){
                if(WM_Utils.getString(wrp.Status)=='Posted'){
                    gen.writeStringField('ipm_payment_option_type','P');
                }
                else if(WM_Utils.getString(wrp.Status)=='Canceled'){
                    gen.writeStringField('ipm_payment_option_type','C');  
                }
            }
            
            if(WM_Utils.getString(wrp.InvoiceDate)!=null){
                gen.writeStringField('ipm_invoice_date', WM_Utils.getStringForDateTimeNoTimeZone(wrp.InvoiceDate));
            }
            system.debug('orderpaysummaryType+++++'+ WM_Utils.getString(ordrPaySum.Type));
            if(WM_Utils.getString(ordrPaySum.Type)!='Unknown'){

                if(WM_Utils.getString(ordrPaySum.Type)=='PayPal'){
                    if(WM_Utils.getString(oWrp.mapOfDigitalWalletPayment.get(ordrPaySum.Id).aurusPayOOT__c)!=null){
                        gen.writeStringField('ipm_credit_card_nbr', WM_Utils.getString(oWrp.mapOfDigitalWalletPayment.get(ordrPaySum.Id).aurusPayOOT__c));
                    }
                }
                else{
                    if(WM_Utils.getString(oWrp.mapOfCardPayment.get(ordrPaySum.Id).aurusPayOOT__c)!=null){
                        gen.writeStringField('ipm_credit_card_nbr', WM_Utils.getString(oWrp.mapOfCardPayment.get(ordrPaySum.Id).aurusPayOOT__c));
                    }
                    if(WM_Utils.getString(oWrp.mapOfCardPayment.get(ordrPaySum.Id).ExpiryMonth) != null && WM_Utils.getString(oWrp.mapOfCardPayment.get(ordrPaySum.Id).ExpiryYear) != null){
                        if(WM_Utils.getString(oWrp.mapOfCardPayment.get(ordrPaySum.Id).ExpiryMonth).getChars().size()>1){
                            gen.writeStringField('ipm_cc_expiration_date', WM_Utils.getString(oWrp.mapOfCardPayment.get(ordrPaySum.Id).ExpiryMonth)+WM_Utils.getString(oWrp.mapOfCardPayment.get(ordrPaySum.Id).ExpiryYear).substring(2));
                        }
                        else{
                            gen.writeStringField('ipm_cc_expiration_date',  '0'+WM_Utils.getString(oWrp.mapOfCardPayment.get(ordrPaySum.Id).ExpiryMonth)+WM_Utils.getString(oWrp.mapOfCardPayment.get(ordrPaySum.Id).ExpiryYear).substring(2));
                        }
                    }
                }
            }
            else if(recrdTypeName=='GIFT_CARD'){
                if(WM_Utils.getString(ordrPaySum.PaymentAuthorizations[0].giftCardNumber__c)!=null){
                    gen.writeStringField('ipm_credit_card_nbr', WM_Utils.getString(ordrPaySum.PaymentAuthorizations[0].giftCardNumber__c));
                }               
            }
            else if(recrdTypeName=='Terms'){
                if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.AccountNumber)!=null){
                    gen.writeStringField('ipm_credit_card_nbr', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.AccountNumber));
                }
            }

            // if(ordrPaySum.PaymentAuthorizations.size()>0){
            //     for(PaymentAuthorization payAuth:ordrPaySum.PaymentAuthorizations){ 
            //         if(String.isNotEmpty(payAuth.loyaltyDetailsOMS__c)){
            //             List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(payAuth.loyaltyDetailsOMS__c);
            //             for(Object fld : fieldList){    
            //                 Map<String,Object> data = (Map<String,Object>)fld;
            //                 System.debug('AAA1: CertAvailableBalance:' + Double.valueOf(data.get('CertAvailableBalance')));
            //                 System.debug('AAA2: Initial totalLoyalityCertAmt :' + totalLoyalityCertAmt);
            //                 totalLoyalityCertAmt += Double.valueOf(data.get('CertAvailableBalance'));
            //                 System.debug('AAA3: AfterAddition totalLoyalityCertAmt :' + totalLoyalityCertAmt);
            //             }
            //             system.debug('AAA4:Final  totalLoyalityCertAmt++@@@'+totalLoyalityCertAmt);
            //         }
            //     }
            // }
            for(PaymentLineInvoice payLine:oWrp.invoiceObj.PaymentLinesInvoice){
                system.debug('totalLoyalityCertAmtValueee   '+totalLoyalityCertAmt);
                if(payLine.Payment.OrderPaymentSummaryId==ordrPaySum.Id && totalLoyalityCertAmt!=null) {
                    system.debug('if condition');
                    ipmDepositAmt = WM_Utils.getDouble(payLine.Amount) - totalLoyalityCertAmt;
                    gen.writeNumberField('ipm_deposit_amount', WM_Utils.getDouble(Decimal.valueOf(ipmDepositAmt).setScale(2))); 
                    break;
                }else if(payLine.Payment.OrderPaymentSummaryId==ordrPaySum.Id){
                    gen.writeNumberField('ipm_deposit_amount', WM_Utils.getDouble(payLine.Amount)); 
                    break;
                }
            }  
            
            if(WM_Utils.getString(ordrPaySum.Type)!='Unknown'){
                if(WM_Utils.getString(ordrPaySum.Type)=='PayPal'){
                    if(oWrp.mapOfDigitalWalletPayment.get(ordrPaySum.Id).aurusPayAPTN__c!=null){
                        gen.writeStringField('ipm_auth_transaction_id', WM_Utils.getString(oWrp.mapOfDigitalWalletPayment.get(ordrPaySum.Id).aurusPayAPTN__c ));
                    }
                }
                else{
                    if(oWrp.mapOfCardPayment.get(ordrPaySum.Id).aurusPayAPTN__c!=null){
                        gen.writeStringField('ipm_auth_transaction_id', WM_Utils.getString(oWrp.mapOfCardPayment.get(ordrPaySum.Id).aurusPayAPTN__c ));
                    }
                }
            }
            gen.writeEndObject();
            seqNumber++;
            if(ordrPaySum.PaymentAuthorizations.size()>0){
                for(PaymentAuthorization payAuth:ordrPaySum.PaymentAuthorizations){ 
                    if(String.isNotEmpty(payAuth.loyaltyDetailsOMS__c)){
                        List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(payAuth.loyaltyDetailsOMS__c);
                        for(Object fld : fieldList){    
                            Map<String,Object> data = (Map<String,Object>)fld;
                            gen.writeStartObject();        
                            gen.writeNumberField('ipm_seq_nbr', WM_Utils.getInteger(seqNumber));
                            gen.writeStringField('ipm_pay_type','LOYALTY_CERTIFICATE');
                            if(WM_Utils.getDouble(wrp.TotalTaxAmount )!=null){
                                gen.writeNumberField('ipm_tax_amt', WM_Utils.getDouble(wrp.TotalTaxAmount));
                            }
                            gen.writeNumberField('ipm_ord_lvl_frt_tax_amt', WM_Utils.getDouble(oWrp.freightTaxAmt)); 
                            if(WM_Utils.getString(wrp.InvoiceDate)!=null){
                                gen.writeStringField('ipm_invoice_date', WM_Utils.getStringForDateTimeNoTimeZone(wrp.InvoiceDate));
                            } 
                            
                            gen.writeStringField('ipm_credit_card_nbr', 'UA'+String.valueOf(data.get('CertNumber')));
                            gen.writeNumberField('ipm_deposit_amount', Integer.valueOf(data.get('CertAvailableBalance')));   
                            gen.writeEndObject();
                            seqNumber++;
                        }
                    }
                }
            }
        }
        gen.writeEndArray();
        
        gen.writeFieldName('InvoiceShipTos');
        gen.writeStartArray();
        //for(FulfillmentOrderLineItem fulfLineItm : oWrp.fulFillmentOrders[0].FulfillmentOrderLineItems){
        if(oWrp.fulFillmentOrders[0].FulfillmentOrderLineItems !=null && oWrp.fulFillmentOrders[0].FulfillmentOrderLineItems.size()>0){
            FulfillmentOrderLineItem fulfLineItm = oWrp.fulFillmentOrders[0].FulfillmentOrderLineItems[0];
            gen.writeStartObject();
            if(WM_Utils.getString(wrp.InvoiceDate)!=null){
                gen.writeStringField('ins_invoice_date', WM_Utils.getStringForDateTimeNoTimeZone(wrp.InvoiceDate));
            }
            if(oWrp.invoiceObj.InvoiceLines!=null){
                Decimal merchandiseTotal = 0;
                Decimal freightAmt = 0;
                for(InvoiceLine invLine:oWrp.invoiceObj.InvoiceLines){
                    if(invLine.ReferenceEntityItem.Name!='Shipping' && invLine.Type!='Tax'){
                        merchandiseTotal=merchandiseTotal+invLine.LineAmount;
                    }
                    if((invLine.Type=='Charge' || invLine.Type=='Adjustment') && invLine.ReferenceEntityItem.Name=='Shipping'){
                        freightAmt=freightAmt+invLine.LineAmount;
                    }
                }
                gen.writeNumberField('ins_merchandise_amt', WM_Utils.getDouble(merchandiseTotal));
                gen.writeNumberField('ins_freight_amt', WM_Utils.getDouble(freightAmt));
            }
            
            // need clarification
            if(WM_Utils.getDouble(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.TotalDeliveryAdjDistAmount)!=null){
                gen.writeNumberField('ins_addl_freight_amt', WM_Utils.getDouble(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.TotalDeliveryAdjDistAmount));
            }
            if(WM_Utils.getDouble(wrp.TotalTaxAmount)!=null){
                gen.writeNumberField('ins_tax_amt', WM_Utils.getDouble(wrp.TotalTaxAmount));
            }
            gen.writeFieldName('OrderShipTo');
            gen.writeStartObject();
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.SalesStoreId)!=null){
                gen.writeStringField('ost_broker_delivery_type', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.OriginalOrder.SalesStoreId));
            }
            
            if(WM_Utils.getString(fulfLineItm.OrderItemSummary.OrderDeliveryGroupSummary.fromStoreId__c)!=null){
                gen.writeStringField('ost_destination_store', WM_Utils.getString(fulfLineItm.OrderItemSummary.OrderDeliveryGroupSummary.fromStoreId__c));
            }
            
            if( WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledFromLocation.ExternalReference)!=null){
                if(oWrp.listOfFulfillmentOrders[0].FulfilledFromLocation.LocationType=='Store' ){  
                    gen.writeStringField('ost_originating_store', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledFromLocation.ExternalReference));
                }
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.poNumber__c)!=null){
                gen.writeStringField('ost_purchase_order_nbr', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.poNumber__c));
            }
            if(oWrp.accnt.Tax_Exemptions__r!=null && oWrp.accnt.Tax_Exemptions__r.size()>0){
                if(WM_Utils.getString(oWrp.accnt.Tax_Exemptions__r[0].Exemption_Certificate__c)!=null)
                {
                    gen.writeStringField('ost_resale_exempt_nbr', WM_Utils.getString(oWrp.accnt.Tax_Exemptions__r[0].Exemption_Certificate__c));
                }
                
            }
            if(WM_Utils.getString(fulfLineItm.OrderItemSummary.OrderDeliveryGroupSummary.OrderDeliveryMethod.ReferenceNumber)!=null){
                gen.writeStringField('ost_ship_via_code', WM_Utils.getString(fulfLineItm.OrderItemSummary.OrderDeliveryGroupSummary.OrderDeliveryMethod.ReferenceNumber));
            }
            if(WM_Utils.getString(fulfLineItm.OrderItemSummary.OrderDeliveryGroupSummary.OrderDeliveryMethod.Description)!=null){
                gen.writeStringField('ost_ship_via_description', WM_Utils.getString(fulfLineItm.OrderItemSummary.OrderDeliveryGroupSummary.OrderDeliveryMethod.Description));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledFromLocation.ExternalReference)!=null){
                if(oWrp.listOfFulfillmentOrders[0].FulfilledFromLocation.LocationType=='Warehouse' ){
                    gen.writeStringField('ost_warehouse', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledFromLocation.ExternalReference));
                }
            }
            if(oWrp.listOfFulfillmentOrders[0].OrderSummary.exchangeOrderNumber__c!=null){
                gen.writeFieldName('OrderMessages');
                gen.writeStartArray();
                gen.writeStartObject();
                
                gen.writeStringField('order_message_text', Label.Messaging_Prefix+''+WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].OrderSummary.exchangeOrderNumber__c ));
                
                gen.writeEndObject();
                gen.writeEndArray();
            }
        for(OrderPaymentSummary ordrPaySum1 :oWrp.ordrPaySumList){
            if(ordrPaySum1.PaymentAuthorizations.size()>0){
                if(String.isNotEmpty(ordrPaySum1.PaymentAuthorizations[0].loyaltyDetailsOMS__c)){
                    List<Object> listOfLoyaltyDtls = (List<Object>)JSON.deserializeUntyped(ordrPaySum1.PaymentAuthorizations[0].loyaltyDetailsOMS__c);
                    
                    gen.writeFieldName('Certificates');
                    gen.writeStartArray();
                    for(Object o:listOfLoyaltyDtls){
                        gen.writeStartObject();
                        Map<String,Object> m = (Map<String,Object>)o;
                        gen.writeStringField('certificate_number', WM_Utils.getString(m.get('CertNumber'))); 
                        gen.writeStringField('certificate_amount', WM_Utils.getString(m.get('CertAvailableBalance')));                                
                        gen.writeEndObject();
                    }
                    gen.writeEndArray();
                }}
        }
            
            gen.writeEndObject();
            
            gen.writeFieldName('CustomerShipTo');
            gen.writeStartObject();
            
            if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.AccountNumber)!=null){
                gen.writeStringField('ship_to_customer_nbr', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.AccountNumber));
            }
            if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Salutation__pc)!=null){
                gen.writeStringField('ship_to_prefix', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Salutation__pc));
            }
            if(oWrp.invoiceObj.BillingAccount.IsPersonAccount){
                if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulFilledToName)!=null){
                    String ShipToName = WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulFilledToName);
                    String[] nameList = ShipToName.split(' ', 3);
                    if(nameList.size()==2){
                        gen.writeStringField('ship_to_fname', WM_Utils.getString(nameList[0])); 
                        gen.writeStringField('ship_to_lname', WM_Utils.getString(nameList[1]));      
                    }
                    if(nameList.size()==3){
                        gen.writeStringField('ship_to_fname', WM_Utils.getString(nameList[0])); 
                        //gen.writeStringField('ship_to_initial', WM_Utils.getString(nameList[1]));   
                        gen.writeStringField('ship_to_lname', WM_Utils.getString(nameList[2])); 
                    }
                    if(nameList.size()==1){
                        gen.writeStringField('ship_to_fname', WM_Utils.getString(nameList[0])); 
                    }
                    
                }
            }
            if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Suffix__pc)!=null){
                gen.writeStringField('ship_to_suffix', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Suffix__pc));
            }
            if(!oWrp.invoiceObj.BillingAccount.IsPersonAccount ){
                if(WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Name)!=null){
                    gen.writeStringField('ship_to_company', WM_Utils.getString(oWrp.invoiceObj.BillingAccount.Name));
                }
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToStreet)!=null){
                gen.writeStringField('ship_to_address1', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToStreet));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToShippingStreet2__c)!=null){
                gen.writeStringField('ship_to_address2', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToShippingStreet2__c));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToShippingStreet3__c)!=null){
                gen.writeStringField('ship_to_address3', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToShippingStreet3__c));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToCity)!=null){
                gen.writeStringField('ship_to_city', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToCity));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToCountry)!=null){
                gen.writeStringField('ship_to_country_name', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToCountry));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToState)!=null){
                gen.writeStringField('ship_to_state', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToState));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToPostalCode)!=null){
                gen.writeStringField('ship_to_zip', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToPostalCode));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToStreet)!=null){
                gen.writeStringField('order_ship_to_address1', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToStreet));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToShippingStreet2__c)!=null){
                gen.writeStringField('order_ship_to_address2', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToShippingStreet2__c));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToShippingStreet3__c)!=null){
                gen.writeStringField('order_ship_to_address3', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToShippingStreet3__c));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToCity)!=null){
                gen.writeStringField('order_ship_to_city', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToCity));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToCountry)!=null){
                gen.writeStringField('order_ship_to_country_name', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToCountry));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToState)!=null){
                gen.writeStringField('order_ship_to_state', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToState));
            }
            if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToPostalCode)!=null){
                gen.writeStringField('order_ship_to_zip', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledToPostalCode));
            }
            
            gen.writeEndObject();
            gen.writeFieldName('InvoiceDetails');
            gen.writeStartArray();                       
            Integer invSeqNumber = 1;
            for(FulfillmentOrderLineItem fulfilordLineitem :  oWrp.fulFillmentOrders[0].FulfillmentOrderLineItems){  
                gen.writeStartObject();
                gen.writeNumberField('idt_line_nbr', WM_Utils.getInteger(invSeqNumber));
                if(WM_Utils.getString(oWrp.fulFillmentOrders[0].JDAFulfillmentOrderNumber__c)!=null){
                    gen.writeStringField('idt_control_nbr', WM_Utils.getString(oWrp.fulFillmentOrders[0].JDAFulfillmentOrderNumber__c));
                }
                if(WM_Utils.getInteger(fulfilordLineitem.Quantity)!=null){
                    gen.writeNumberField('idt_shipped_qty', WM_Utils.getInteger(fulfilordLineitem.Quantity));
                }
                if(WM_Utils.getInteger(fulfilordLineitem.orderItemSummary.QuantityReturned)!=null){
                    gen.writeNumberField('idt_return_qty', WM_Utils.getInteger(fulfilordLineitem.orderItemSummary.QuantityReturned));
                }
                if(WM_Utils.getInteger(fulfilordLineitem.orderItemSummary.QuantityReturned)!=null){
                    gen.writeNumberField('idt_credited_qty', WM_Utils.getInteger(fulfilordLineitem.orderItemSummary.QuantityReturned));
                }
                
               if(WM_Utils.getDouble(fulfilordLineitem.orderItemSummary.UnitPrice)!=null){
                  Decimal toround = fulfilordLineitem.orderItemSummary.UnitPrice + (fulfilordLineitem.orderItemSummary.TotalAdjustmentAmount)/(fulfilordLineitem.orderItemSummary.QuantityOrdered);
                  Decimal rounded = toRound.setScale(2, RoundingMode.HALF_UP);               
                    gen.writeNumberField('idt_actual_price',WM_Utils.getDouble(rounded));
                } 

              
               /* if(WM_Utils.getDouble(fulfilordLineitem.orderItemSummary.UnitPrice)!=null){
                    gen.writeNumberField('idt_actual_price',WM_Utils.getDouble(fulfilordLineitem.orderItemSummary.UnitPrice));
                } */


                if(WM_Utils.getDouble(fulfilordLineitem.TotalAdjustmentAmount)!=null){
                    gen.writeNumberField('idt_discount_amt',-(WM_Utils.getDouble(fulfilordLineitem.orderItemSummary.TotalAdjustmentAmount)));
                }
                if(WM_Utils.getDouble(fulfilordLineitem.TotalTaxAmount)!=null){
                    gen.writeNumberField('idt_tax_amt',WM_Utils.getDouble(fulfilordLineitem.orderItemSummary.TotalTaxAmount));
                }

               /* if(WM_Utils.getDouble(fulfilordLineitem.TotalLineAmount)!=null){
                    gen.writeNumberField('idt_original_price',fulfilordLineitem.TotalLineAmount);
                }


                if(WM_Utils.getDouble(fulfilordLineitem.TotalLineTaxAmount)!=null){
                    gen.writeNumberField('idt_original_tax_amt',WM_Utils.getDouble(fulfilordLineitem.TotalLineTaxAmount));
                } */


                if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledFromLocation.ExternalReference)!=null){
                    system.debug('FulFillment Order Line Item Location   '+oWrp.listOfFulfillmentOrders[0].FulfilledFromLocation);
                    gen.writeStringField('fulfilling_location', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledFromLocation.ExternalReference));
                }
                if(oWrp.fulFillmentOrders[0].FulfillmentOrderShipments.size()>0){
                    if(WM_Utils.getString(oWrp.fulFillmentOrders[0].FulfillmentOrderShipments[0].TrackingNumber)!=null){
                        gen.writeStringField('Tracking_Number', WM_Utils.getString(oWrp.fulFillmentOrders[0].FulfillmentOrderShipments[0].TrackingNumber));
                    }}
                // if(WM_Utils.getString(fulfLineItm.OrderItemSummary.OrderDeliveryGroupSummary.fromStoreId__c)!=null){
                //     gen.writeStringField('sts_location', WM_Utils.getString(fulfLineItm.OrderItemSummary.OrderDeliveryGroupSummary.fromStoreId__c));
                // }
                if(WM_Utils.getDouble(fulfilordLineitem.orderItemSummary.TotalPrice)!=null){
                    gen.writeNumberField('idt_cost_amt',(WM_Utils.getDouble(fulfilordLineitem.orderItemSummary.TotalPrice)));
                }
                gen.writeFieldName('OrderDetail');
                gen.writeStartObject();
                if(WM_Utils.getInteger(fulfilordLineitem.orderItemSummary.QuantityOrdered )!=null){
                    gen.writeNumberField('odt_ordered_qty', WM_Utils.getInteger(fulfilordLineitem.orderItemSummary.QuantityOrdered));
                }
                if(WM_Utils.getInteger(fulfilordLineitem.orderItemSummary.QuantityFulfilled)!=null){
                    gen.writeNumberField('odt_shipped_qty', WM_Utils.getInteger(fulfilordLineitem.orderItemSummary.QuantityFulfilled));
                }
                if(WM_Utils.getInteger(fulfilordLineitem.orderItemSummary.QuantityReturned)!=null){
                    gen.writeNumberField('odt_credited_qty', WM_Utils.getInteger(fulfilordLineitem.orderItemSummary.QuantityReturned));
                }
                if(fulfilordLineitem.OrderItemSummary.dropship__c){
                    gen.writeStringField('odt_drop_ship','Y');
                }
                else{
                    gen.writeStringField('odt_drop_ship','N');
                }
                if(oWrp.listOfFulfillmentOrders[0].Type=='Special'){
                    if(WM_Utils.getString(fulfilordLineitem.OrderItemSummary.Special_Order_SKU__c)!=null){
                        gen.writeStringField('odt_item', WM_Utils.getString(fulfilordLineitem.OrderItemSummary.Special_Order_SKU__c));
                    }    
                }
                else{
                    if(WM_Utils.getString(fulfilordLineitem.OrderItemSummary.ProductCode)!=null){
                        gen.writeStringField('odt_item', WM_Utils.getString(fulfilordLineitem.OrderItemSummary.ProductCode));
                    }
                }
              
              /*  if(WM_Utils.getDouble(fulfilordLineitem.orderItemSummary.UnitPrice)!=null){
                      Decimal toround2 = fulfilordLineitem.orderItemSummary.UnitPrice + (fulfilordLineitem.orderItemSummary.TotalAdjustmentAmount)/(fulfilordLineitem.orderItemSummary.QuantityOrdered);
                 // Decimal rounded2 = toRound2.setScale(2, RoundingMode.HALF_UP); 
                    gen.writeNumberField('odt_price',WM_Utils.getDouble(toround2));
                } */
               if(WM_Utils.getDouble(fulfilordLineitem.UnitPrice)!=null){
                    gen.writeNumberField('odt_price',WM_Utils.getDouble(fulfilordLineitem.orderItemSummary.UnitPrice));
                } 



                if(WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledFromLocation.ExternalReference)!=null){
                    system.debug('FulFillment Order Line Item Location   '+oWrp.listOfFulfillmentOrders[0].FulfilledFromLocation);
                    gen.writeStringField('odt_whs_warehouse', WM_Utils.getString(oWrp.listOfFulfillmentOrders[0].FulfilledFromLocation.ExternalReference));
                }
                if(WM_Utils.getString(oWrp.fulFillmentOrders[0].FulfillmentOrderLineItems[0].OrderItemSummary.OrderDeliveryGroupSummary.OrderDeliveryMethod.ReferenceNumber)!=null){
                    gen.writeStringField('odt_via_ship_via_code', WM_Utils.getString(oWrp.fulFillmentOrders[0].FulfillmentOrderLineItems[0].OrderItemSummary.OrderDeliveryGroupSummary.OrderDeliveryMethod.ReferenceNumber));             
                }

                gen.writeStringField('odt_price_override_code', 'I');
                if(fulfilordLineitem.orderItemSummary.eGiftCard__c ){
                    gen.writeFieldName('StoredValueCards');
                    gen.writeStartArray();
                    if(oWrp.mapOfGiftCardsWithOrderItemSum !=null && oWrp.mapOfGiftCardsWithOrderItemSum !=null){
                        for(e_GiftCard__c eGf: oWrp.mapOfGiftCardsWithOrderItemSum.get(fulfilordLineitem.orderItemSummary.Id)){
                            
                            gen.writeStartObject();
                            gen.writeStringField('svc_card_nbr',WM_Utils.getString(eGf.Gift_Card_Number__c));
                            gen.writeEndObject();         
                        }
                    }
                    gen.writeEndArray();
                }
                
                gen.writeEndObject();
                if(WM_Utils.getString(fulfilordLineitem.orderItemSummary.associatedLoyaltyProducts__c)!=null){
                    if(String.isNotEmpty(fulfilordLineitem.orderItemSummary.associatedLoyaltyProducts__c)){
                        Map<String,Object> LoyaltyProdctsMap = (Map<String,Object>)JSON.deserializeUntyped(fulfilordLineitem.orderItemSummary.associatedLoyaltyProducts__c);
                        system.debug('associatedLoyaltyProductsMap values: '+LoyaltyProdctsMap.values());
                        gen.writeFieldName('MembershipDetails');
                        gen.writeStartArray();
                        for(Object p:LoyaltyProdctsMap.values()){
                            List<object> tempObject  = (List<object>)p;
                            for(Object o:tempObject){
                                gen.writeStartObject();
                                //system.debug('O'+ JSON.serialize(o));
                                Map<String,Object> mp = (Map<String,Object>)o;
                                gen.writeStringField('odt_membership_item', WM_Utils.getString(mp.get('pid'))); 
                                gen.writeNumberField('odt_membership_price', WM_Utils.getDouble(mp.get('price'))); 
                                gen.writeNumberField('idt_membership_tax_amt', WM_Utils.getDouble(mp.get('tax')));                                
                                
                                gen.writeEndObject();
                            }
                        }
                        gen.writeEndArray();
                    }
                }
                
            //gen.writeEndObject();
                
                if(WM_Utils.getString(fulfilordLineitem.orderItemSummary.associatedWarrantyProduct__c)!=null){
                    gen.writeFieldName('WarrantyDetail');
                    gen.writeStartObject();
                    if(WM_Utils.getString(fulfilordLineitem.orderItemSummary.associatedWarrantyProduct__c)!=null){
                        gen.writeStringField('odt_warranty_item',WM_Utils.getString(fulfilordLineitem.orderItemSummary.associatedWarrantyProduct__c));
                    }
                    if(WM_Utils.getString(fulfilordLineitem.orderItemSummary.associatedWarrantyPrice__c )!=null){
                        gen.writeStringField('odt_warranty_price',WM_Utils.getString(fulfilordLineitem.orderItemSummary.associatedWarrantyPrice__c));
                    }
                    if(WM_Utils.getString(fulfilordLineitem.orderItemSummary.associatedWarrantyTaxAmt__c)!=null){
                        gen.writeStringField('idt_warranty_tax_amt',WM_Utils.getString(fulfilordLineitem.orderItemSummary.associatedWarrantyTaxAmt__c));
                    }
                    
                    gen.writeEndObject();
              
                }
                gen.writeEndObject(); 
                invSeqNumber = invSeqNumber + 1;
            }
        }
            gen.writeEndArray();
            gen.writeEndObject();   
        //}
        gen.writeEndArray();
        
        
        return gen;                                
        
    }
}