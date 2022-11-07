public class WM_JSONGeneratorForCreditMemo {
    public static JSONGenerator formtheJSONBody(ObjectWrapperForCreditMemo oWrp,WM_InvoiceCreditMemoWrapper wrp){
        Integer seqNumber = 1;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('InvoiceOut_Request');
        gen.writeStartObject();
        
        system.debug('** oWrp.ordrItemSummaryList ***'+ oWrp.ordrItemSummaryList);
        if(WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.OrderReferenceNumber)!=null){
            gen.writeStringField('ihd_order_nbr', WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.OrderReferenceNumber));
        }
        if(WM_Utils.getString(wrp.InvoiceNumber)!=null){
            gen.writeStringField('ihd_invoice_nbr', WM_Utils.getString(wrp.InvoiceNumber));
        }
        if(WM_Utils.getString(oWrp.creditMemoObj.Return_Received__c)!=null && oWrp.creditMemoObj.Return_Received__c == true){
            gen.writeStringField('ihd_sj_print_date', WM_Utils.getCurrentDate());
        }
        else if(WM_Utils.getString(oWrp.creditMemoObj.Return_Received__c)!=null && oWrp.creditMemoObj.Return_Received__c == False){
            if(WM_Utils.getString(wrp.InvoiceDate)!=null){
                gen.writeStringField('ihd_sj_print_date', WM_Utils.getStringForDateTimeNoTimeZone(wrp.InvoiceDate));
            }
        }
        gen.writeFieldName('OrderHeader');
        gen.writeStartObject();
        if( WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.OrderReferenceNumber)!=null){
            gen.writeStringField('ohd_reference_order_nbr', WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.OrderReferenceNumber));
        }
        if( WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.OrderedDate)!=null){
            gen.writeStringField('ohd_order_date', WM_Utils.getStringForDateTimeNoTimeZone(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.OrderedDate));
        }
        if( WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.CreatedDate)!=null){
            gen.writeStringField('ohd_enter_date', WM_Utils.getStringForDateTimeNoTimeZone(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.CreatedDate));
        }
        if( WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.CreatedDate)!=null){
            gen.writeStringField('ohd_enter_time', WM_Utils.getStringForDateTimeNoTimeZone(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.CreatedDate));
        }
        if( WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.SalesChannel.SalesChannelName)!=null){
            gen.writeStringField('ohd_order_channel','I');
        }
        if( WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.associateId__c)!=null){
            gen.writeStringField('ohd_order_type', 'P');
        } else {
            gen.writeStringField('ohd_order_type', 'I');
        }
        if( WM_Utils.getInteger(oWrp.creditMemoObj.BillingAccount.Sales_Person_Number__c)!=null){
            gen.writeNumberField('ohd_salesman_nbr', WM_Utils.getInteger(oWrp.creditMemoObj.BillingAccount.Sales_Person_Number__c));
        }
        if( WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.AccountSource)!=null){
            gen.writeStringField('ohd_invoice_source_code', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.AccountSource));
        }
        else{
            gen.writeStringField('ohd_invoice_source_code', '93WEB000A');              
        }
        
        if(oWrp.creditMemoObj.BillingAccount.IsPersonAccount && oWrp.creditMemoObj.BillingAccount.Cust_Payment_Class__c == 'A'){
            gen.writeStringField('ohd_invoice_division_code',WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Associate__c));
            gen.writeStringField('ohd_invoice_entity_nbr',WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Associate__c));
            
        }
        else if(oWrp.creditMemoObj.BillingAccount.IsPersonAccount && oWrp.creditMemoObj.BillingAccount.Cust_Payment_Class__c != 'A'){
            gen.writeStringField('ohd_invoice_division_code', 'Retail');
            gen.writeStringField('ohd_invoice_entity_nbr', 'Retail');
            
        }
        else {
            gen.writeStringField('ohd_invoice_division_code', 'Business');
            gen.writeStringField('ohd_invoice_entity_nbr', 'Business');
        }
        
        if( WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Cust_Payment_Class__c)!=null){
            gen.writeStringField('ohd_customer_class', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Cust_Payment_Class__c));
        }
        else{
            gen.writeStringField('ohd_customer_class','R');
        }
        
        if( WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.AccountNumber)!=null){
            gen.writeStringField('ohd_cbt_account_nbr', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.AccountNumber));
        }
        
        if( WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.AccountNumber)!=null){
            gen.writeStringField('ohd_cst_customer_nbr', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.AccountNumber));
        }
        
        if( WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.associateID__c)!=null){
            gen.writeStringField('ohd_entered_by_user', WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.associateID__c));
        }

        if(WM_Utils.getString(oWrp.creditMemoObj.Return_Received__c)!=null){

            if(oWrp.creditMemoObj.Return_Received__c == true)
            {
            gen.writeStringField('ohd_return_type', 'Physical');
            }
            else {
            gen.writeStringField('ohd_return_type', 'Non-Physical');
            }
        }
        
        gen.writeEndObject();
        
        gen.writeFieldName('CustomerSoldTo');
        gen.writeStartObject();          
        
        if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.SoldToNumber__c)!=null){
            gen.writeStringField('sold_to_nbr', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.SoldToNumber__c));
        }
        if( WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Salutation__pc)!=null){
            gen.writeStringField('sold_to_prefix', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Salutation__pc));
        }
        if( WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.FirstName)!=null){
            gen.writeStringField('sold_to_fname', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.FirstName));
        }
        if( WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.LastName)!=null){
            gen.writeStringField('sold_to_lname', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.LastName));
        }
        if( WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Suffix__pc)!=null){
            gen.writeStringField('sold_to_suffix', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Suffix__pc));
        }
        if( WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Name)!=null){
            gen.writeStringField( 'sold_to_company', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Name));
        }
        if( WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingStreet)!=null){
            gen.writeStringField('sold_to_address1', WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingStreet));
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
        if( WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingCity)!=null){
            gen.writeStringField('sold_to_city', WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingCity));
        }     
        if( WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingCountry)!=null){
            gen.writeStringField('sold_to_country', WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingCountry));
        } 
        if( WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingState)!=null){
            gen.writeStringField('sold_to_state', WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingState));
        }
        if( WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingPostalCode)!=null){
            gen.writeStringField('sold_to_zip', WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingPostalCode));
        }
        
        if(oWrp.creditMemoObj.BillingAccount.IsPersonAccount ){
            if( WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.PersonEmail)!=null) {
                gen.writeStringField('sold_to_email_address', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.PersonEmail));
            }
            if( WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.PersonMobilePhone)!=null) {
                gen.writeStringField('sold_to_day_phone', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.PersonMobilePhone));
            }
        }
        else {
            if( WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Email__c)!=null) {
                gen.writeStringField('sold_to_email_address', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Email__c));
            }
            if ( WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Phone)!=null) {
                gen.writeStringField('sold_to_day_phone', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Phone));
            }
        }
        if(oWrp.creditMemoObj.BillingAccount.Associate__c!= null){
            gen.writeBooleanField('sold_to_associate', oWrp.creditMemoObj.BillingAccount.Associate__c);
        }
        if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.cst_tax_code__c)!=null){
            gen.writeStringField('sold_to_type', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.cst_tax_code__c));
        }
        if( (oWrp.creditMemoObj.BillingAccount.Associate__c)!=null &&  (oWrp.creditMemoObj.BillingAccount.AssociateId__c)!=null){
            if(oWrp.creditMemoObj.BillingAccount.Associate__c ==True){
                gen.writeStringField('sold_to_alternate_id',WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.AssociateId__c));
             }   
            }
            else if(oWrp.creditMemoObj.BillingAccount.Associate__c ==False){
                if( (oWrp.creditMemoObj.BillingAccount.Associate__c)!=null && WM_Utils.getString (oWrp.creditMemoObj.BillingAccount.loyaltyAccountNumber__c)!=null){
                    gen.writeStringField('sold_to_alternate_id', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.loyaltyAccountNumber__c));
                }
            }
        
        gen.writeFieldName('Placer');
        gen.writeStartObject();
        
        if(WM_Utils.getInteger(oWrp.creditMemoObj.BillToContact.IndividualNumber__c)!=null){
            gen.writeNumberField('placer_nbr', WM_Utils.getInteger(oWrp.creditMemoObj.BillToContact.IndividualNumber__c));
        }
        
        if(WM_Utils.getString(oWrp.creditMemoObj.BillToContact.FirstName)!=null){
            gen.writeStringField('placer_fname', WM_Utils.getString(oWrp.creditMemoObj.BillToContact.FirstName));
        }
        if(WM_Utils.getString(oWrp.creditMemoObj.BillToContact.LastName)!=null){
            gen.writeStringField('placer_lname', WM_Utils.getString(oWrp.creditMemoObj.BillToContact.LastName));
        }
        gen.writeEndObject();
        
        gen.writeEndObject();
        gen.writeFieldName('CustomerBillTo');
        gen.writeStartObject();
        if(!oWrp.creditMemoObj.BillingAccount.IsPersonAccount && oWrp.creditMemoObj.BillingAccount.ParentId!=null){
            
            if( WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Parent.AccountNumber)!=null){
                gen.writeStringField('bill_to_nbr', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Parent.AccountNumber));
            }
            if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Parent.Salutation__pc)!=null ){
                gen.writeStringField('bill_to_prefix', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Parent.Salutation__pc));
            }
            if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Parent.FirstName)!=null){
                gen.writeStringField('bill_to_fname', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Parent.FirstName));
            }
            if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Parent.MiddleName)!=null){
                gen.writeStringField('bill_to_initial', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Parent.MiddleName));
            }
            if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Parent.LastName)!=null){
                gen.writeStringField('bill_to_lname', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Parent.LastName));
            }
            if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Parent.Suffix__pc)!=null){
                gen.writeStringField('bill_to_suffix', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Parent.Suffix__pc));
            }
            if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Parent.Name)!=null){
                gen.writeStringField('bill_to_company', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Parent.Name));
            }
            if(oWrp.parentAddressMap.get(oWrp.creditMemoObj.BillingAccount.ParentId)!=null){
                if(WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.creditMemoObj.BillingAccount.ParentId).Address_Line_1__c)!=null){
                    gen.writeStringField('bill_to_address1', WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.creditMemoObj.BillingAccount.ParentId).Address_Line_1__c));
                }
                if(WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.creditMemoObj.BillingAccount.ParentId).Address_Line_2__c)!=null){
                    gen.writeStringField('bill_to_address2', WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.creditMemoObj.BillingAccount.ParentId).Address_Line_2__c));
                }
                if(WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.creditMemoObj.BillingAccount.ParentId).Address_Line_3__c)!=null){
                    gen.writeStringField('bill_to_address3', WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.creditMemoObj.BillingAccount.ParentId).Address_Line_3__c));
                }
                if(WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.creditMemoObj.BillingAccount.ParentId).City__c)!=null ){
                    gen.writeStringField('bill_to_city', WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.creditMemoObj.BillingAccount.ParentId).City__c));
                }
                if(WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.creditMemoObj.BillingAccount.ParentId).Country__c)!=null){
                    gen.writeStringField('bill_to_country', WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.creditMemoObj.BillingAccount.ParentId).Country__c));
                }
                if(WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.creditMemoObj.BillingAccount.ParentId).State__c)!=null){
                    gen.writeStringField('bill_to_state', WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.creditMemoObj.BillingAccount.ParentId).State__c));
                }
                if(WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.creditMemoObj.BillingAccount.ParentId).Postal_Code__c)!=null ) {
                    gen.writeStringField('bill_to_zip', WM_Utils.getString(oWrp.parentAddressMap.get(oWrp.creditMemoObj.BillingAccount.ParentId).Postal_Code__c));
                }
            }
        }
        else{
            if( WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.AccountNumber)!=null){
                gen.writeStringField('bill_to_nbr', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.AccountNumber));
            }
            if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Salutation__pc)!=null ){
                gen.writeStringField('bill_to_prefix', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Salutation__pc));
            }
            if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.FirstName)!=null){
                gen.writeStringField('bill_to_fname', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.FirstName));
            }
            if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.MiddleName)!=null){
                gen.writeStringField('bill_to_initial', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.MiddleName));
            }
            if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.LastName)!=null){
                gen.writeStringField('bill_to_lname', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.LastName));
            }
            if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Suffix__pc)!=null){
                gen.writeStringField('bill_to_suffix', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Suffix__pc));
            }
            if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Name)!=null){
                gen.writeStringField('bill_to_company', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Name));
            }
            if(WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingStreet)!=null){
                gen.writeStringField('bill_to_address1', WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingStreet));
            }
            /*if(WM_Utils.getString(addr.Address_Line_2__c)!=null){
gen.writeStringField('bill_to_address2', WM_Utils.getString(addr.Address_Line_2__c));
}
if(WM_Utils.getString(addr.Address_Line_3__c)!=null){
gen.writeStringField('bill_to_address3', WM_Utils.getString(addr.Address_Line_3__c));
}*/
            if(WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingCity)!=null ){
                gen.writeStringField('bill_to_city', WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingCity));
            }
            if(WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingCountry)!=null ){
                gen.writeStringField('bill_to_country', WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingCountry));
            }
            if(WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingState)!=null ){
                gen.writeStringField('bill_to_state', WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingState));
            }
            if(WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingPostalCode)!=null) {
                gen.writeStringField('bill_to_zip', WM_Utils.getString(oWrp.ordrItemSummaryList[0].OrderSummary.OriginalOrder.BillingPostalCode));
            }              
        }
        gen.writeEndObject();
        
        Boolean creditCardFlag = false;
        Boolean giftCardFlag = false;
        Boolean loyaltyCertFlag = false;
        Boolean termsFlag = false;
        Boolean CODFlag = false;
        Boolean writeOffFlag = false;
        for(OrderPaymentSummary ordrPay :oWrp.ordrPaySumList){
            String recrdTypeName;
            if(WM_Utils.getString(ordrPay.Type)!=null){
                if(WM_Utils.getString(ordrPay.Type)!='Unknown'){
                    creditCardFlag = true;
                }
                else{
                    recrdTypeName = oWrp.mapOfAlternatePayment.get(ordrPay.Id).RecordType.Name;
                    if(recrdTypeName=='GIFT_CARD'){
                        giftCardFlag = true;
                    }
                    if(recrdTypeName=='Terms'){
                        termsFlag =  true;
                    }
                    if(recrdTypeName=='COD'){
                        CODFlag = true;
                    }
                    if(recrdTypeName=='WRITE_OFF'){
                        writeOffFlag = true; 
                    }
                    if(recrdTypeName=='LOYALTY_CERTIFICATE'){
                        loyaltyCertFlag = true;
                    }
                    
                }
            }
        }
        
        Boolean eGiftCardFlag = false;
        gen.writeFieldName('InvoicePaymentMethods');
        gen.writeStartArray();
        for(OrderPaymentSummary ordrPaySum :oWrp.ordrPaySumList){
            String recrdTypeName;
            if(creditCardFlag && giftCardFlag && !loyaltyCertFlag){
                if(WM_Utils.getString(ordrPaySum.Type)=='Unknown'){
                    continue;
                }
            }
            else if(!creditCardFlag && giftCardFlag && loyaltyCertFlag){
                if(WM_Utils.getString(ordrPaySum.Type)!='Unknown'){
                    continue;
                }
                else if(oWrp.mapOfAlternatePayment.get(ordrPaySum.Id).RecordType.Name !='GIFT_CARD'){
                    continue;
                }
            }
            else if(creditCardFlag && !giftCardFlag && loyaltyCertFlag){
                if(WM_Utils.getString(ordrPaySum.Type)=='Unknown'){
                    continue;
                }
            }
            else if(creditCardFlag && giftCardFlag && loyaltyCertFlag){
                if(WM_Utils.getString(ordrPaySum.Type)=='Unknown'){
                    continue;
                } 
            }
            else if(giftCardFlag && termsFlag && !creditCardFlag && !loyaltyCertFlag){
                if(WM_Utils.getString(ordrPaySum.Type)!='Unknown'){
                    continue;
                }
                else if(oWrp.mapOfAlternatePayment.get(ordrPaySum.Id).RecordType.Name !='Terms'){
                    continue;
                }
            }
            else if(CODFlag && giftCardFlag && !creditCardFlag && !loyaltyCertFlag){
                if(WM_Utils.getString(ordrPaySum.Type)!='Unknown'){
                    continue;
                }
                else if(oWrp.mapOfAlternatePayment.get(ordrPaySum.Id).RecordType.Name !='COD'){
                    continue;
                }
            }
            else if (eGiftCardFlag)
            {
                continue;
            }
            gen.writeStartObject();
            gen.writeNumberField('ipm_seq_nbr', WM_Utils.getInteger(seqNumber));
            // if(WM_Utils.getString(ordrPaySum.Type)!=null){
            //     if(WM_Utils.getString(ordrPaySum.Type)!='Unknown'){
            //         gen.writeStringField('ipm_pay_type', WM_Utils.getString(ordrPaySum.Type));
            //     }
            //     else if(oWrp.mapOfAlternatePayment!=null && oWrp.mapOfAlternatePayment.get(ordrPaySum.Id)!=null && oWrp.mapOfAlternatePayment.get(ordrPaySum.Id).RecordType.Name!=null){
            //         recrdTypeName = oWrp.mapOfAlternatePayment.get(ordrPaySum.Id).RecordType.Name;
            //         gen.writeStringField('ipm_pay_type',recrdTypeName);
            //     }
            // }
            System.debug('AAA: payType:' + ordrPaySum.Type);
            System.debug('AAA: Credit Destination: '+WM_Utils.getString(oWrp.creditMemoObj.Credit_Destination__c));
            if(WM_Utils.getString(ordrPaySum.Type)!=null){
                if(WM_Utils.getString(oWrp.creditMemoObj.Credit_Destination__c)==null){
                    if(WM_Utils.getString(ordrPaySum.Type)!=null){
                        if(WM_Utils.getString(ordrPaySum.Type)!='Unknown'){
                            gen.writeStringField('ipm_pay_type', WM_Utils.getString(ordrPaySum.Type));
                        }
                        else if(oWrp.mapOfAlternatePayment!=null && oWrp.mapOfAlternatePayment.get(ordrPaySum.Id)!=null && oWrp.mapOfAlternatePayment.get(ordrPaySum.Id).RecordType.Name!=null){
                            recrdTypeName = oWrp.mapOfAlternatePayment.get(ordrPaySum.Id).RecordType.Name;
                            gen.writeStringField('ipm_pay_type',recrdTypeName);
                        }
                    }
                }
                else if(WM_Utils.getString(ordrPaySum.Type)!='Unknown' && WM_Utils.getString(oWrp.creditMemoObj.Credit_Destination__c)!=null && WM_Utils.getString(oWrp.creditMemoObj.Credit_Destination__c) != 'Gift Card'){
                    gen.writeStringField('ipm_pay_type', WM_Utils.getString(ordrPaySum.Type));
                }
                if(WM_Utils.getString(oWrp.creditMemoObj.Credit_Destination__c)!=null && WM_Utils.getString(oWrp.creditMemoObj.Credit_Destination__c) == 'Gift Card'){
                    gen.writeStringField('ipm_pay_type', 'GIFT_CARD');
                }
                //else if(WM_Utils.getString(oWrp.creditMemoObj.Credit_Destination__c)!=null && WM_Utils.getString(oWrp.creditMemoObj.Credit_Destination__c) == 'Original Payment Method'){
                else if(oWrp.mapOfAlternatePayment!=null && oWrp.mapOfAlternatePayment.get(ordrPaySum.Id)!=null && oWrp.mapOfAlternatePayment.get(ordrPaySum.Id).RecordType.Name!=null){
                    recrdTypeName = oWrp.mapOfAlternatePayment.get(ordrPaySum.Id).RecordType.Name;
                    gen.writeStringField('ipm_pay_type',recrdTypeName);
                }
            }
            
            if(WM_Utils.getDouble(wrp.TotalTaxAmount )!=null){
                gen.writeNumberField('ipm_tax_amt', WM_Utils.getDouble((-1)*wrp.TotalTaxAmount));
            }
            
            gen.writeNumberField('ipm_ord_lvl_frt_tax_amt', WM_Utils.getDouble((-1)*oWrp.freightTaxAmt));    
            
            if(WM_Utils.getString(ordrPaySum.Type)!='Unknown'){
                if(WM_Utils.getString(ordrPaySum.Type)=='PayPal'){
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
            if(WM_Utils.getString(oWrp.creditMemoObj.Return_Received__c)!=null && oWrp.creditMemoObj.Return_Received__c == true){
                gen.writeStringField('ipm_invoice_date', WM_Utils.getCurrentDate());
            }
            else if(WM_Utils.getString(oWrp.creditMemoObj.Return_Received__c)!=null && oWrp.creditMemoObj.Return_Received__c == false){
                if(WM_Utils.getString(wrp.InvoiceDate)!=null){
                    gen.writeStringField('ipm_invoice_date', WM_Utils.getStringForDateTimeNoTimeZone(wrp.InvoiceDate));
                }
            }
            System.debug('CreditDestination:'+oWrp.creditMemoObj.Credit_Destination__c);
            System.debug('orderSum Type:'+ordrPaySum.Type);
            //System.debug('aurusPayOOT__c:'+oWrp.mapOfDigitalWalletPayment.get(ordrPaySum.Id).aurusPayOOT__c);
            //Start--- WME-220
            if(WM_Utils.getString(oWrp.creditMemoObj.Credit_Destination__c)!=null && WM_Utils.getString(oWrp.creditMemoObj.Credit_Destination__c) == 'Original Payment Method' && WM_Utils.getString(ordrPaySum.Type)!='Unknown'){
                //if(WM_Utils.getString(ordrPaySum.Type)!='Unknown'){//WME386
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
                //}
            }
            else if(WM_Utils.getString(oWrp.creditMemoObj.Credit_Destination__c)!=null && WM_Utils.getString(oWrp.creditMemoObj.Credit_Destination__c) == 'Gift Card'){
                if(oWrp.giftCardNumber !=null){
                    gen.writeStringField('ipm_credit_card_nbr', oWrp.giftCardNumber);
                    eGiftCardFlag = true;
                }
            }
            //Start---WME-386
            else if(WM_Utils.getString(ordrPaySum.PaymentAuthorizations[0].giftCardNumber__c)!=null && oWrp.giftCardNumber!=null ){
                gen.writeStringField('ipm_credit_card_nbr', oWrp.giftCardNumber);
                eGiftCardFlag = true;
            //END----WME-386
            }               
            //END---- WME-220
            else if(recrdTypeName=='Terms'){
                if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.AccountNumber)!=null){
                    gen.writeStringField('ipm_credit_card_nbr', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.AccountNumber));
                }
            }
            if(WM_Utils.getDouble(wrp.TotalAmountWithTax )!=null){
                gen.writeNumberField('ipm_deposit_amount', WM_Utils.getDouble(-1*wrp.TotalAmountWithTax));
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
            
        }
        gen.writeEndArray();
      
        
        gen.writeFieldName('InvoiceShipTos');
       // gen.writeStartArray();
       // for(OrderItemSummary orditmSum : oWrp.ordrItemSummaryList){
        OrderItemSummary orditmSum = oWrp.ordrItemSummaryList[0];
            gen.writeStartObject();
            if(WM_Utils.getString(wrp.InvoiceDate)!=null){
                gen.writeStringField('ins_invoice_date', WM_Utils.getStringForDateTimeNoTimeZone(wrp.InvoiceDate));
            }
            if(oWrp.creditMemoObj.CreditMemoLines!=null){
                Decimal merchandiseTotal = 0;
                Decimal freightAmt = 0;
                for(CreditMemoLine crmLine:oWrp.creditMemoObj.CreditMemoLines){
                    // WME-338 Manohar, in the following IF, added one more condition, crmLine.RelatedLine.Name!='Shipping'
                    if(crmLine.ReferenceEntityItem.Name!='Shipping' && crmLine.Type!='Tax' && crmLine.RelatedLine.Name!='Shipping'){
                        merchandiseTotal=merchandiseTotal+crmLine.LineAmount;
                    }
                    if((crmLine.Type=='Charge' || crmLine.Type=='Adjustment') && (crmLine.ReferenceEntityItem.Name=='Shipping' || crmLine.RelatedLine.Name=='Shipping')){
                        freightAmt=freightAmt+crmLine.LineAmount;
                    }
                }
                gen.writeNumberField('ins_merchandise_amt', WM_Utils.getDouble(-1*merchandiseTotal));
                gen.writeNumberField('ins_freight_amt', WM_Utils.getDouble(-1*freightAmt));
            }
            
            // need clarification
            if(WM_Utils.getDouble(orditmSum.OrderSummary.OriginalOrder.TotalDeliveryAdjDistAmount)!=null){
                gen.writeNumberField('ins_addl_freight_amt', WM_Utils.getDouble(orditmSum.OrderSummary.OriginalOrder.TotalDeliveryAdjDistAmount));
            }
            if(WM_Utils.getDouble(wrp.TotalTaxAmount)!=null){
                gen.writeNumberField('ins_tax_amt', WM_Utils.getDouble(-1*wrp.TotalTaxAmount));
            }
            gen.writeFieldName('OrderShipTo');
            gen.writeStartObject();
            if(WM_Utils.getString(orditmSum.OrderSummary.OriginalOrder.SalesStoreId)!=null){
                gen.writeStringField('ost_broker_delivery_type', WM_Utils.getString(orditmSum.OrderSummary.OriginalOrder.SalesStoreId));
            }
            
            if(WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.fromStoreId__c )!=null){
                gen.writeStringField('ost_destination_store', WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.fromStoreId__c ));
            }
            if(WM_Utils.getString(orditmSum.OrderSummary.poNumber__c)!=null){
                gen.writeStringField('ost_purchase_order_nbr', WM_Utils.getString(orditmSum.OrderSummary.poNumber__c));
            }
            if(oWrp.accnt.Tax_Exemptions__r!=null && oWrp.accnt.Tax_Exemptions__r.size()>0){
                if(WM_Utils.getString(oWrp.accnt.Tax_Exemptions__r[0].Exemption_Certificate__c)!=null)
                {
                    gen.writeStringField('ost_resale_exempt_nbr', WM_Utils.getString(oWrp.accnt.Tax_Exemptions__r[0].Exemption_Certificate__c));
                }
                
            }
            if(WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.OrderDeliveryMethod.ReferenceNumber)!=null){
                gen.writeStringField('ost_ship_via_code', WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.OrderDeliveryMethod.ReferenceNumber));
            }
            if(WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.OrderDeliveryMethod.Description)!=null){
                gen.writeStringField('ost_ship_via_description', WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.OrderDeliveryMethod.Description));
            }
            
            if(orditmSum.OrderSummary.exchangeOrderNumber__c!=null){
                gen.writeFieldName('OrderMessages');
                gen.writeStartArray();
                gen.writeStartObject();
                
                gen.writeStringField('order_message_text', Label.Messaging_Prefix+''+WM_Utils.getString(orditmSum.OrderSummary.exchangeOrderNumber__c ));
                
                gen.writeEndObject();
                gen.writeEndArray();
            }
            if(oWrp.ordrPaySumList[0].PaymentAuthorizations.size()>0){
                if(String.isNotEmpty(oWrp.ordrPaySumList[0].PaymentAuthorizations[0].loyaltyDetailsOMS__c)){
                    List<Object> listOfLoyaltyDtls = (List<Object>)JSON.deserializeUntyped(oWrp.ordrPaySumList[0].PaymentAuthorizations[0].loyaltyDetailsOMS__c);
                    
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
            
            gen.writeEndObject();
            
            gen.writeFieldName('CustomerShipTo');
            gen.writeStartObject();
            
            if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.AccountNumber)!=null){
                gen.writeStringField('ship_to_customer_nbr', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.AccountNumber));
            }
            if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Salutation__pc)!=null){
                gen.writeStringField('ship_to_prefix', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Salutation__pc));
            }
            if(oWrp.creditMemoObj.BillingAccount.IsPersonAccount){
                if(WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToName)!=null){
                    String ShipToName = WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToName);
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
            if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Suffix__pc)!=null){
                gen.writeStringField('ship_to_suffix', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Suffix__pc));
            }
            if(!oWrp.creditMemoObj.BillingAccount.IsPersonAccount ){
                if(WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Name)!=null){
                    gen.writeStringField('ship_to_company', WM_Utils.getString(oWrp.creditMemoObj.BillingAccount.Name));
                }
            }
            if(WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToStreet)!=null){
                gen.writeStringField('ship_to_address1', WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToStreet));
            }
            if(WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToCity)!=null){
                gen.writeStringField('ship_to_city', WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToCity));
            }
            if(WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToCountry)!=null){
                gen.writeStringField('ship_to_country_name', WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToCountry));
            }
            if(WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToState)!=null){
                gen.writeStringField('ship_to_state', WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToState));
            }
            if(WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToPostalCode)!=null){
                gen.writeStringField('ship_to_zip', WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToPostalCode));
            }
            if(WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToStreet)!=null){
                gen.writeStringField('order_ship_to_address1', WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToStreet));
            }
            if(WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToCity)!=null){
                gen.writeStringField('order_ship_to_city', WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToCity));
            }
            if(WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToCountry)!=null){
                gen.writeStringField('order_ship_to_country_name', WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToCountry));
            }
            if(WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToState)!=null){
                gen.writeStringField('order_ship_to_state', WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToState));
            }
            if(WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToPostalCode)!=null){
                gen.writeStringField('order_ship_to_zip', WM_Utils.getString(orditmSum.OrderDeliveryGroupSummary.DeliverToPostalCode));
            }        
            
            gen.writeEndObject();
                gen.writeFieldName('InvoiceDetails');
                gen.writeStartArray();                       
                Integer invSeqNumber = 1;
                for(OrderItemSummary orditmSum2 : oWrp.ordrItemSummaryList){
                    if(orditmSum2!=null && orditmSum2.Type=='Order Product'){
                        Boolean isReturn = False;
                        // Set<ID> returnedLineItems = new Set<ID>();
                           
                           gen.writeStartObject();
                           gen.writeNumberField('idt_line_nbr', WM_Utils.getInteger(invSeqNumber));
                           if(WM_Utils.getInteger(orditmSum2.QuantityFulfilled)!=null){
                            gen.writeNumberField('idt_shipped_qty', WM_Utils.getInteger(orditmSum2.QuantityFulfilled));
                             }
                           
                           if(oWrp.creditMemoObj.CreditMemoLines!=null){
                               for(CreditMemoLine crmLine:oWrp.creditMemoObj.CreditMemoLines){
                                   if(crmLine.ReferenceEntityItemId==orditmSum2.Id){
                                       if(WM_Utils.getInteger(crmLine.Quantity__c)!=null){
                                           gen.writeNumberField('idt_return_qty', WM_Utils.getInteger((-1)*(crmLine.Quantity__c)));
                                        //    returnedLineItems.add(crmLine.Id);
                                        isReturn = TRUE;

                                       }
                                       else {
                                        gen.writeNumberField('idt_return_qty', 0);
                                       }
                                   }
                                   
                               }
                           }

                         /*  if(oWrp.creditMemoObj.CreditMemoLines!=null){
                            for(CreditMemoLine crmLine:oWrp.creditMemoObj.CreditMemoLines){
                                for (AggregateResult individualResult : oWrp.invoiceLineList){
                                if(crmLine.ReferenceEntityItemId==individualResult.get('ReferenceEntityItemId')){
                               
                                    if(individualResult.get('VertexLineAmountTotal')!=null){
                                        gen.writeNumberField('idt_original_tax_amt', WM_Utils.getDouble(individualResult.get('VertexLineAmountTotal')));
                                    }
                                }
                            }
                            }
                        } */

                           
                      
                        if(WM_Utils.getDouble(orditmSum2.UnitPrice)!=null){
                            Decimal toround = orditmSum2.UnitPrice + (orditmSum2.TotalDiscountAdjustmentAmount__c + orditmSum2.OriginalOrderItem.TotalAdjustmentAmount)/(orditmSum2.QuantityOrdered);
                            Decimal rounded = toRound.setScale(2, RoundingMode.HALF_UP); 
                            gen.writeNumberField('idt_actual_price',WM_Utils.getDouble(rounded));
                        }

                        /*  if(WM_Utils.getDouble(orditmSum2.UnitPrice)!=null){
                               gen.writeNumberField('idt_actual_price',WM_Utils.getDouble(orditmSum2.UnitPrice));
                           } */


                        //  if(WM_Utils.getDouble(orditmSum2.TotalAdjustmentAmount)!=null){
                        //        gen.writeNumberField('idt_discount_amt',-(WM_Utils.getDouble(orditmSum2.TotalAdjustmentAmount)));
                        //    } 
                        

                        if(oWrp.creditMemoObj.CreditMemoLines!=null){
                            for(CreditMemoLine crmLine:oWrp.creditMemoObj.CreditMemoLines){
                                if(crmLine.ReferenceEntityItemId==orditmSum2.Id){
                                    for(CreditMemoLine crmLine2:oWrp.creditMemoObj.CreditMemoLines){
                                        if((crmLine.Id==crmLine2.RelatedLineId) && (crmLine2.type == 'Adjustment')){
                                        // if((crmLine.Id==crmLine2.RelatedLineId) && (crmLine2.type == 'Adjustment') && (crmLine2.AdjustmentAmount < 0)){
                                        
                                            gen.writeNumberField('idt_discount_amt', WM_Utils.getDouble(crmLine2.AdjustmentAmount));
                                           
                                        }
                                    }
                                }
                                
                            }
                        } 

                           
                        if(oWrp.creditMemoObj.CreditMemoLines!=null){
                            for(CreditMemoLine crmLine:oWrp.creditMemoObj.CreditMemoLines){
                                if(crmLine.ReferenceEntityItemId==orditmSum2.Id){
                                    if(WM_Utils.getInteger(crmLine.Quantity__c)!=null){

                                        for(CreditMemoLine crmLine2:oWrp.creditMemoObj.CreditMemoLines){
                                            if((crmLine.Id==crmLine2.RelatedLineId) && (crmLine2.type == 'Tax')){
                                            
                                                gen.writeNumberField('idt_tax_amt', WM_Utils.getDouble(crmLine2.LineAmount));
                                               
                                            }
                                        } 
                                       
                                    }
                                    else 
                                    {
                                        if(WM_Utils.getDouble(orditmSum2.TotalTaxAmount)!=null)
                                        {
                                        gen.writeNumberField('idt_tax_amt',WM_Utils.getDouble(orditmSum2.TotalTaxAmount));
                                        } 
                                    }
                                }
                                
                            }
                        }



                       /*    if(WM_Utils.getDouble(orditmSum2.TotalTaxAmount)!=null){
                               gen.writeNumberField('idt_tax_amt',WM_Utils.getDouble(orditmSum2.TotalTaxAmount));
                           } */
            


                                        
                        if(WM_Utils.getDouble(orditmSum2.TotalLineAmount)!=null){
                            gen.writeNumberField('idt_original_price',orditmSum2.TotalLineAmount);
                        }


                        if(WM_Utils.getDouble(orditmSum2.TotalLineTaxAmount)!=null){
                            gen.writeNumberField('idt_original_tax_amt',WM_Utils.getDouble(orditmSum2.TotalLineTaxAmount));
                        }



                        //Start WME-220
                        //    if(WM_Utils.getString(orditmSum2.OrderDeliveryGroupSummary.fromStoreId__c )!=null){
                        //        gen.writeStringField('idt_return_location',WM_Utils.getString(orditmSum2.OrderDeliveryGroupSummary.fromStoreId__c));
                        //    }
                        if(WM_Utils.getString(oWrp.creditMemoObj.Return_Disposition_Code__c)!=null){
                            gen.writeStringField('idt_return_location', WM_Utils.getString(oWrp.creditMemoObj.Return_Disposition_Code__c));
                        }
                        //END WME-220

                            // if(returnedLineItems.size()>0){
                            if(isReturn == TRUE){
                                if(oWrp.creditMemoObj.CreditMemoLines!=null){
                                    Decimal idt_cost_amount_for_return = 0;
                                    for(CreditMemoLine crmLine:oWrp.creditMemoObj.CreditMemoLines){
                                        if(crmLine.ReferenceEntityItemId==orditmSum2.Id && crmLine.Type == 'Charge'){
                                            idt_cost_amount_for_return += WM_Utils.getDouble(crmLine.LineAmount);
                                            if(WM_Utils.getInteger(crmLine.Quantity__c)!=null){
                                                for(CreditMemoLine crmLine2:oWrp.creditMemoObj.CreditMemoLines){
                                                    if((crmLine.Id==crmLine2.RelatedLineId) && (crmLine2.type == 'Adjustment')){
                                                        idt_cost_amount_for_return +=  (WM_Utils.getDouble(crmLine2.LineAmount));
                                                    }
                                                } 
                                            }
                                        }
                                    }
                                    Decimal rounded_idt_amt = idt_cost_amount_for_return.setScale(2, RoundingMode.HALF_UP); 
                                    gen.writeNumberField('idt_cost_amt', rounded_idt_amt);
                                }

                            }
                            else{
                                if(WM_Utils.getDouble(orditmSum2.UnitPrice)!=null){
                                    // Decimal toround = ((orditmSum2.UnitPrice) * (orditmSum2.QuantityFulfilled));                 
                                    System.debug('BBB:Total Price:' + orditmSum2.TotalPrice);
                                    System.debug('BBB:TotalAdjustmentAmount :' + orditmSum2.TotalAdjustmentAmount);
                                    System.debug('BBB:Original Order Item TotalAdjustmentAmount :' + orditmSum2.OriginalOrderItem.TotalAdjustmentAmount);
                                    Decimal toround = orditmSum2.TotalPrice - (orditmSum2.TotalAdjustmentAmount - orditmSum2.OriginalOrderItem.TotalAdjustmentAmount);
                                    gen.writeNumberField('idt_cost_amt',WM_Utils.getDouble((-1)*(toround)));
                                    System.debug('ToRound' + toround);
                                } 
                            }

                          


                        //ra_nbr
                        // if(WM_Utils.getDouble(orditmSum2.ReturnAuthorizationField__c)!=null){
                        //     gen.writeNumberField('ra_nbr',WM_Utils.getInteger(orditmSum2.ReturnAuthorizationField__c));
                        // }
                        // if(WM_Utils.getInteger(oWrp.creditMemoObj.CreditMemoLines.ReturnAuthAssignment__c)!=null){
                        //     gen.writeNumberField('ra_nbr', WM_Utils.getInteger(oWrp.creditMemoObj.CreditMemoLines.ReturnAuthAssignment__c));
                        // }
                        if(oWrp.creditMemoObj.CreditMemoLines!=null){
                            for(CreditMemoLine crmLine:oWrp.creditMemoObj.CreditMemoLines){
                                if(crmLine.ReferenceEntityItemId==orditmSum2.Id){
                                    if(WM_Utils.getInteger(crmLine.ReturnAuthAssignment__c)!=null){
                                        gen.writeNumberField('ra_nbr', crmLine.ReturnAuthAssignment__c);
                                    }
                                }
                            }
                        }
        
                           gen.writeFieldName('OrderDetail');
                           gen.writeStartObject();
                           if(WM_Utils.getString(orditmSum2.QuantityOrdered)!=null){
                               gen.writeStringField('odt_ordered_qty', WM_Utils.getString(orditmSum2.QuantityOrdered));
                           }
                           if(WM_Utils.getString(orditmSum2.QuantityFulfilled)!=null){
                               gen.writeStringField('odt_shipped_qty', WM_Utils.getString(orditmSum2.QuantityFulfilled));
                           }
                           
                           
                           if(oWrp.creditMemoObj.CreditMemoLines!=null){
                               for(CreditMemoLine crmLine:oWrp.creditMemoObj.CreditMemoLines){
                                   if(crmLine.ReferenceEntityItemId==orditmSum2.Id){
                                       if(WM_Utils.getInteger(crmLine.Quantity__c)!=null){
                                           gen.writeNumberField('odt_credited_qty', crmLine.Quantity__c);
                                       }
                                   }
                                   
                               }
                           }
                           
                                  // added by Manohar, WME-128 start 
                           if(WM_Utils.getString(orditmSum2.Special_Order_SKU__c)!=null ){
                               system.debug('in if special order');
                            gen.writeStringField('odt_item', WM_Utils.getString(orditmSum2.Special_Order_SKU__c));
                           }else if(WM_Utils.getString(orditmSum2.ProductCode)!=null){ 
                            gen.writeStringField('odt_item', WM_Utils.getString(orditmSum2.ProductCode));
                            system.debug('in if normal order');
                           }
                                // added by Manohar, WME-128 end

                          /* if(WM_Utils.getDouble(orditmSum2.UnitPrice)!=null){ 
                               Decimal toround2 = orditmSum2.UnitPrice + (orditmSum2.TotalAdjustmentAmount)/(orditmSum2.QuantityOrdered);
                             //  Decimal rounded2 = toRound2.setScale(2, RoundingMode.HALF_UP); 
                               gen.writeNumberField('odt_price',WM_Utils.getDouble(toround2));
                           } */

                           if(WM_Utils.getDouble(orditmSum2.UnitPrice)!=null){
                       
                            gen.writeNumberField('odt_price',orditmSum2.UnitPrice);
                        }


                           gen.writeStringField('odt_price_override_code', 'I');
                           gen.writeEndObject();
                           
                           gen.writeEndObject();  
                           invSeqNumber = invSeqNumber + 1; 
                       }
                }
            gen.writeEndArray();
            gen.writeEndObject();       
       // }    
       // gen.writeEndArray();
        
    return gen;                 
    
}
}