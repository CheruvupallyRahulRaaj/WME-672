/**
* @description       : class WM_CRMIntegrationQueueable
* @last modified on  : 12-09-2022
* @last modified by  : ShravanyaP@genzeon.com
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   12-09-2022   Manohar Alla                         WME-274 story related updates
* 2.0   12-09-2022   Shravanya Padala                     WMe-83 story related updates
**/

public class WM_CRMIntegrationQueueable implements Queueable,Database.AllowsCallouts {
    private List<Id> sObjectIds;
    private String actionType;
    private Integer i;
    
    public WM_CRMIntegrationQueueable(List<Id> sObjIds,String actnType,Integer currentElement){
        this.sObjectIds = sObjIds;
        this.actionType = actnType;
        this.i = currentElement;
    }
    
    
    public void execute(QueueableContext context) {
      system.debug('called  from WM_CRMIntegrationQueueable');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        // retreving the API key which is configured in Custom Settings
        String apiKey = WM_WebServiceDetails__c.getValues('CRMService').WM_ApiKey__c;
        // Setting appropriate attributes for the request
        request.setEndpoint('callout:CRMService');
        request.setMethod('POST'); 
        request.setHeader('Content-Type','application/json');
        request.setHeader('api_key',apiKey);  
        system.debug('before error');
        String sObjName = sObjectIds[i].getSObjectType().getDescribe().getName();
        system.debug('after error');
        Account acc = new Account();
        List<Address__c> addressList = new List<Address__c>();
        List<Address__c> addresses = new List<Address__c>();
        List<Contact> conList = new List<Contact> ();
        list<Tax_Exemption__c> TaxExemptnList = new List<Tax_Exemption__c>();
        String accountId;
        
        // Story: WME-274 Developer: Manohar Alla Change: New List
        // WME-274 Change History 1 Start
        List<Address__c> Parentaddresses = new List<Address__c>();
        string  parentId;
        // WME-274 Change History 1 End
        
        if(sObjName == 'Account') {
            acc =  WM_CRMServiceHelper.getAccount(sObjectIds[i]);
            system.debug('acctest'+acc.Parent_Bill_To__c);
            conList =  WM_CRMServiceHelper.getRelatedContact(sObjectIds[i]);
            addressList = WM_CRMServiceHelper.getAddress(sObjectIds[i]);
            addresses = WM_CRMServiceHelper.getAddresses(sObjectIds[i]);
            TaxExemptnList = WM_CRMServiceHelper.getTaxExemptions(sObjectIds[i]);

            // Story: WME-274 Developer: Manohar Alla Change: Get Parent Account Address
            // WME-274 Change History 2: Start
            parentId =WM_Utils.getParenTID(sObjectIds[i]);
            system.debug('parenTId is '+parentId);
            Parentaddresses=WM_CRMServiceHelper.getAddress(parentId);
            system.debug('Parentaddresses'+Parentaddresses);
            // WME-274 Change History 2: End
        }
        if(sObjNAme == 'Contact'){
           
            conList = WM_CRMServiceHelper.getContacts(new List<Id>{sObjectIds[i]});
            accountId = conList[0].AccountId;
            acc =  WM_CRMServiceHelper.getAccount(accountId);
            addressList =  WM_CRMServiceHelper.getAddress(accountId);
            addresses = WM_CRMServiceHelper.getAddresses(accountId);
            TaxExemptnList = WM_CRMServiceHelper.getTaxExemptions(accountId);
            
            // Story: WME-274 Developer: Manohar Alla Change: Get Parent Account Address
            // WME-274 Change History 3: Start
            parentId =WM_Utils.getParenTID(accountId);
            Parentaddresses=WM_CRMServiceHelper.getAddress(parentId);
            // WME-274 Change History 3: End
          
        }
        if(sObjNAme == 'Address__c'){
          system.debug('{sObjectIds[i]'+sObjectIds[i]);
            addressList = WM_CRMServiceHelper.getAllAddress(new List<Id>{sObjectIds[i]});
          
            for(Address__c addrObj : addressList){
                accountId = addrObj.Account__c;
            }
         
            acc = WM_ServiceHelper.getAccount(accountId);
            conList  = WM_CRMServiceHelper.getRelatedContact(accountId);
            TaxExemptnList = WM_CRMServiceHelper.getTaxExemptions(accountId);

            // Story: WME-274 Developer: Manohar Alla Change: Get Parent Account Address
            // WME-274 Change History 4: Start
            parentId =WM_Utils.getParenTID(accountId);
            Parentaddresses=WM_CRMServiceHelper.getAddress(parentId);
            // WME-274 Change History 4: End 
        }
        
        // Story: WME-274 Developer: Manohar Alla
        // WME-274 Change History 5: Start
        boolean jsonConditions = actionType=='A'?(WM_Utils.getString(acc.Parent_Bill_To__c)!=null && WM_Utils.getString(acc.Parent_Bill_To__c)=='Y' && acc.SCCActive__c):
        (WM_Utils.getString(acc.Parent_Bill_To__c)!=null && WM_Utils.getString(acc.Parent_Bill_To__c)=='Y' && acc.SCCActive__c&& !WM_Utils.checkchildAccounts(acc.id));
        system.debug('jsonConditions: '+jsonConditions);
        if(!jsonConditions){
        // WME-274 Change History 5: End

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('CustomerOut_Request');
        gen.writeStartObject();
        gen.writeFieldName('CustSoldTo');
        gen.writeStartObject();
        //WME-83
        if(addressList.size()>0 && WM_Utils.getString(addressList[0].isNewAddress__c)!=null && WM_Utils.getString(addressList[0].isNewAddress__c) == 'Y'){
            gen.writeStringField('cst_action_type', 'C');
        }
        else{
            gen.writeStringField('cst_action_type', actionType);
        }
        //WME-83
        //gen.writeStringField('cst_action_type', actionType);

        // Story: WME-274 Developer: Manohar Alla
        // WME-274 Change History 6: Start
        Account childAccount = WM_Utils.getChildAccount(acc.Id);
        if(childAccount != null){
            if( WM_Utils.getString(childAccount.AccountNumber)!=null){
                gen.writeStringField('cst_cust_nbr', WM_Utils.getString(childAccount.AccountNumber));
            }
        }
        else if(childAccount == null){
            //Get Parent Account
            Account parentAccount = WM_Utils.getParentAccount(acc.Id);
            if( WM_Utils.getString(parentAccount.AccountNumber)!=null){
                gen.writeStringField('cst_cust_nbr', WM_Utils.getString(parentAccount.AccountNumber));
            }
        }
        // WME-274 Change History 6: End
        
        if( WM_Utils.getString(acc.Cust_Payment_Class__c)!=null){
            gen.writeStringField('cst_cust_class', WM_Utils.getString(acc.Cust_Payment_Class__c));
        } else {
            gen.writeStringField('cst_cust_class', 'R');
        }
        
        
        if(childAccount!=null){
            if( WM_Utils.getString(childAccount.Name)!=null){
                gen.writeStringField('cst_company_name', WM_Utils.getString(childAccount.Name));
            }
        }
        else if(childAccount == null){
            if( WM_Utils.getString(acc.Name)!=null){
                gen.writeStringField('cst_company_name', WM_Utils.getString(acc.Name));
            }
        }
        if( WM_Utils.getString(acc.Market_Team__c)!=null){
            gen.writeStringField('cst_curr_source', WM_Utils.getString(acc.Market_Team__c));
        }
        
        if(WM_Utils.getString(acc.FirstName)!=null){
            gen.writeStringField('cst_fname', WM_Utils.getString(acc.FirstName));             
        }
        if( WM_Utils.getString(acc.LastName)!=null){
            gen.writeStringField('cst_lname', WM_Utils.getString(acc.LastName));             
        }
        /*if( WM_Utils.getString(acc.Suffix__pc)!=null){
            gen.writeStringField('cst_suffix', WM_Utils.getString(acc.Suffix__pc)); 
        }*/
        if(childAccount == null && addressList.size()>0){
            if( WM_Utils.getString(addressList[0].Address_Line_1__c)!=null){
                gen.writeStringField('cst_street_addr', WM_Utils.getString(addressList[0].Address_Line_1__c));
            }
            
            if( WM_Utils.getString(addressList[0].City__c)!=null){
                gen.writeStringField('cst_city', WM_Utils.getString(addressList[0].City__c));
            }
            if( WM_Utils.getString(addressList[0].State__c)!=null){
                gen.writeStringField('cst_state', WM_Utils.getString(addressList[0].State__c));
            }
            if( WM_Utils.getString(addressList[0].Postal_Code__c)!=null){
                gen.writeStringField('cst_zip', WM_Utils.getString(addressList[0].Postal_Code__c));
            }
            if( WM_Utils.getString(addressList[0].Country__c)!=null){
                gen.writeStringField('cst_country', WM_Utils.getString(addressList[0].Country__c));
            }
        }
        else if(childAccount != null){
            System.debug('Child Account Address Fetch ');
            List<Address__c> childAddressList = WM_CRMServiceHelper.getAddresses(childAccount.Id);
            if(childAddressList.size()>0){
                if( WM_Utils.getString(childAddressList[0].Address_Line_1__c)!=null){
                    gen.writeStringField('cst_street_addr', WM_Utils.getString(childAddressList[0].Address_Line_1__c));
                }
                
                if( WM_Utils.getString(childAddressList[0].City__c)!=null){
                    gen.writeStringField('cst_city', WM_Utils.getString(childAddressList[0].City__c));
                }
                if( WM_Utils.getString(childAddressList[0].State__c)!=null){
                    gen.writeStringField('cst_state', WM_Utils.getString(childAddressList[0].State__c));
                }
                if( WM_Utils.getString(childAddressList[0].Postal_Code__c)!=null){
                    gen.writeStringField('cst_zip', WM_Utils.getString(childAddressList[0].Postal_Code__c));
                }
                if( WM_Utils.getString(childAddressList[0].Country__c)!=null){
                    gen.writeStringField('cst_country', WM_Utils.getString(childAddressList[0].Country__c));
                }
            }
        }
        if( WM_Utils.getString(acc.cst_tax_exempt__c)!=null){
            gen.writeStringField('cst_tax_exempt', WM_Utils.getString(acc.cst_tax_exempt__c));
        }
        
        /*if( WM_Utils.getString(acc.cst_exempt_certificate__c)!=null){
            gen.writeStringField('cst_exempt_certificate', WM_Utils.getString(acc.cst_exempt_certificate__c));
        }
        if( WM_Utils.getString(acc.cst_exempt_expirycst_exempt_expiry__c)!=null){
            gen.writeStringField('cst_exempt_expiry', WM_Utils.getString(acc.cst_exempt_expirycst_exempt_expiry__c  ));
        }*/
        
        if(acc.Associate__c!= null){
            gen.writeBooleanField('cst_associate', acc.Associate__c);
        }
        if( WM_Utils.getString(acc.Type)!=null){
            gen.writeStringField('cst_cust_type', WM_Utils.getString(acc.Type));
        }
        if( WM_Utils.getString(acc.CreatedDate)!=null){
            gen.writeStringField('cst_entry_date', WM_Utils.getStringForDateTimeNoTimeZone(acc.CreatedDate));
        }
        if( acc.SCCActive__c!=null){
            gen.writeBooleanField('cst_inactive', acc.SCCActive__c);
        }
        if( (acc.DoNotMail__c)!=null){
            if(acc.DoNotMail__c == false){
                gen.writeBooleanField('cst_mail_name',false);               
            }
            else {
                gen.writeBooleanField('cst_mail_name',true);
            }            
            //gen.writeBooleanField('cst_mail_name', acc.DoNotMail__c);
        }
        if(( WM_Utils.getString(acc.cst_rent_name__c)!=null)){
            gen.writeStringField('cst_rent_name', WM_Utils.getString(acc.cst_rent_name__c));
        }
        if( (acc.Associate__c)!=null ){
            if(acc.Associate__c &&  (acc.AssociateId__c)!=null){
                gen.writeStringField('cst_interface_cust_nbr',WM_Utils.getString(acc.AssociateId__c));
                
            }
            else if(!acc.Associate__c){
                if( WM_Utils.getString (acc.loyaltyAccountNumber__c)!=null){
                    gen.writeStringField('cst_interface_cust_nbr', WM_Utils.getString(acc.loyaltyAccountNumber__c));
                }
            }
        }
        if( WM_Utils.getString(acc.LastModifiedDate )!=null){
            gen.writeStringField('cst_last_chg_date', WM_Utils.getStringForDateTimeNoTimeZone(acc.LastModifiedDate ));
        }
        
        /*if( acc.PersonHasOptedOutOfEmail!=null){
            gen.writeBooleanField('cst_email_opt_in', acc.PersonHasOptedOutOfEmail);
        }*/
        if((acc.PersonHasOptedOutOfEmail)!=null ){
            if(acc.PersonHasOptedOutOfEmail == false){
                gen.writeBooleanField('cst_email_opt_in',false);
                
            }
            else {
                gen.writeBooleanField('cst_email_opt_in',true);
            }
        }
       
       //new field as part of ticket 4277
        if((acc.PersonDoNotCall)!=null){
            if(acc.PersonDoNotCall == false){
                gen.writeBooleanField('cst_do_not_call',false);
                
            }
            else {
                gen.writeBooleanField('cst_do_not_call',true);
            }
        }
            

        
        if( WM_Utils.getString(acc.PersonTitle)!=null){
            gen.writeStringField('cst_job_title', WM_Utils.getString(acc.PersonTitle));
        }
        if( acc.PersonHasOptedOutOfFax!=null){
            gen.writeBooleanField('cst_do_not_fax', acc.PersonHasOptedOutOfFax);
        }
        if( WM_Utils.getString(acc.Sales_Person_Number__c)!=null){
            gen.writeStringField('cst_salesman_nbr', WM_Utils.getString(acc.Sales_Person_Number__c));
        }
        if( WM_Utils.getString(acc.Sales_Person_Name__c)!=null){
            gen.writeStringField('cst_salesman_name', WM_Utils.getString(acc.Sales_Person_Name__r.Name));
        }
        if(WM_Utils.getString(acc.Industry)!=null){
            gen.writeStringField('cst_mail_code', WM_Utils.getString(acc.Industry));
            Account at = [Select Id,tolabel(Industry) from Account where Id=:acc.Id];
            gen.writeStringField('cst_mail_code_desc', WM_Utils.getString(at.Industry));
            
        }
        else{
            gen.writeStringField('cst_mail_code','Y');
            gen.writeStringField('cst_mail_code_desc', 'Default Mail Code');
        }
        
        
        if( acc.call_code__c != null){
            gen.writeStringField('cst_call_code', WM_Utils.getString(acc.call_code__c));
        }
        if( WM_Utils.getString(acc.LastModifiedBy.Name)!=null){
            gen.writeStringField('cst_change_user', WM_Utils.getString(acc.LastModifiedBy.Name));
        }
        if( WM_Utils.getString(acc.CreatedBy.Name)!=null){
            gen.writeStringField('cst_create_user', WM_Utils.getString(acc.CreatedBy.Name));
        }
        if( WM_Utils.getString(acc.wmProTier_c__c)!=null){
            gen.writeStringField('cst_price_group', WM_Utils.getString(acc.wmProTier_c__c));
        }
        if(addressList.size()>0){
            if( WM_Utils.getString(addressList[0].ReserveLocation__r.ExternalReference)!=null){
                gen.writeStringField('cst_reserve_whs', WM_Utils.getString(addressList[0].ReserveLocation__r.ExternalReference));
            }
            if( WM_Utils.getString(addressList[0].csh_van_route__c)!=null){
                gen.writeStringField('cst_van_route', WM_Utils.getString(addressList[0].csh_van_route__c));
            }
            if( WM_Utils.getString(addressList[0].csh_van_route_seq__c)!=null){
                gen.writeStringField('cst_van_route_seq', WM_Utils.getString(addressList[0].csh_van_route_seq__c));
            }
        }
        /*if( WM_Utils.getString(acc.Industry)!=null){
gen.writeStringField('cst_mail_code', WM_Utils.getString(acc.Industry));
}*/       
        if( WM_Utils.getString(acc.RegionZone__c)!=null){
            gen.writeStringField('cst_user_field_1', WM_Utils.getString(acc.RegionZone__c));
        }

        gen.writeBooleanField('cst_po_required', acc.wmProPORequired__c);
        
        /*
if( WM_Utils.getString(acc.cst_rent_name__c)!=null){
gen.writeStringField('cst_rent_name', WM_Utils.getString(acc.cst_rent_name__c));
}
*/
        gen.writeFieldName('CustSoldToPhoneNbr');
        gen.writeStartObject();
        if( WM_Utils.getString(acc.Phone)!=null){
            gen.writeStringField('cst_day_phone', WM_Utils.getString(acc.Phone));
        }
        if( WM_Utils.getString(acc.PersonHomePhone)!=null){
            gen.writeStringField('cst_eve_phone', WM_Utils.getString(acc.PersonHomePhone));
        }
        if( WM_Utils.getString(acc.PersonMobilePhone)!=null){
            gen.writeStringField('cst_fax_phone', WM_Utils.getString(acc.PersonMobilePhone));
        }
        gen.writeEndObject();
        gen.writeFieldName('CustSoldToCrossReferences');
        gen.writeStartArray();
        gen.writeStartObject();
        if( WM_Utils.getString(acc.Associate__c)!=null){
            //if(acc.Associate__c){ //WME-83
            if(WM_Utils.getString(acc.AssociateId__c)!=null){
                gen.writeStringField('cst_alternate_cust_nbr', WM_Utils.getString(acc.AssociateId__c));
            }
            else{
                if(acc.loyaltyAccountNumber__c!=null){
                    gen.writeStringField('cst_alternate_cust_nbr', WM_Utils.getString(acc.loyaltyAccountNumber__c));
                }
                
            }
            
        }
        gen.writeEndObject();
        gen.writeEndArray();
        
        gen.writeFieldName('CustSoldToEmails');
        gen.writeStartArray();
        gen.writeStartObject();
        if(!acc.IsPersonAccount ){
            if( WM_Utils.getString(acc.Email__c)!=null){
                gen.writeStringField('cst_email_addr', WM_Utils.getString(acc.Email__c));
            } 
        }
        else{
            if( WM_Utils.getString(acc.PersonEmail)!=null){
                gen.writeStringField('cst_email_addr', WM_Utils.getString(acc.PersonEmail));
            } 
        }
        
        if(acc.PersonHasOptedOutOfEmail!=null){
            gen.writeBooleanField('cst_email_status', acc.PersonHasOptedOutOfEmail);
        }
        gen.writeEndObject();
        gen.writeEndArray();
        if(addresses.size()>0){
            gen.writeFieldName('CustShipTos');
            gen.writeStartArray();
            for(Address__c addr :addresses){
                gen.writeStartObject();
                /*if( WM_Utils.getString(addr.Salutation__c)!=null){
gen.writeStringField('csh_prefix', WM_Utils.getString(addr.Salutation__c));
}*/
                if( WM_Utils.getString(addr.First_Name__c)!=null){
                    gen.writeStringField('csh_fname', WM_Utils.getString(addr.First_Name__c));
                }
                if( WM_Utils.getString(addr.Last_Name__c)!=null){
                    gen.writeStringField('csh_lname', WM_Utils.getString(addr.Last_Name__c));
                }
                /*if( WM_Utils.getString(addr.Suffix__c)!=null){
gen.writeStringField('csh_suffix', WM_Utils.getString(addr.Suffix__c));
}*/
                if( WM_Utils.getString(acc.Name)!=null){
                    gen.writeStringField('csh_company_name', WM_Utils.getString(acc.Name));
                }
                if( WM_Utils.getString(addr.Address_Line_1__c)!=null){
                    gen.writeStringField('csh_street_addr', WM_Utils.getString(addr.Address_Line_1__c));
                }
                
                if( WM_Utils.getString(addr.City__c)!=null){
                    gen.writeStringField('csh_city', WM_Utils.getString(addr.City__c));
                }
                if( WM_Utils.getString(addr.State__c)!=null){
                    gen.writeStringField('csh_state', WM_Utils.getString(addr.State__c));
                }
                if( WM_Utils.getString(addr.Postal_Code__c)!=null){
                    gen.writeStringField('csh_zip', WM_Utils.getString(addr.Postal_Code__c));
                }
                if( WM_Utils.getString(addr.Country__c)!=null){
                    gen.writeStringField('csh_country', WM_Utils.getString(addr.Country__c));
                }
                if( WM_Utils.getString(addr.cst_reserve_whs__c)!=null){
                    gen.writeStringField('csh_reserve_whs', WM_Utils.getString(addr.cst_reserve_whs__c));
                }
                if( WM_Utils.getString(addr.csh_van_route__c)!=null){
                    gen.writeStringField('csh_van_route', WM_Utils.getString(addr.csh_van_route__c));
                }
                if( WM_Utils.getString(addr.csh_van_route_seq__c)!=null){
                    gen.writeStringField('csh_van_route_seq', WM_Utils.getString(addr.csh_van_route_seq__c));
                }
                gen.writeFieldName('CustShipToPhoneNbr');
                gen.writeStartObject();
                if( WM_Utils.getString(addr.Phone__c)!=null){
                    gen.writeStringField('csh_day_phone', WM_Utils.getString(addr.Phone__c));
                }
                /*if( WM_Utils.getString(acc.Fax)!=null){
gen.writeStringField('csh_fax_phone', WM_Utils.getString(acc.Fax));
}*/
                gen.writeEndObject();
                gen.writeEndObject();
            }
            gen.writeEndArray();
        }
        if(!acc.IsPersonAccount ){
            gen.writeFieldName('CustIndividuals');
            gen.writeStartArray();
            for(Contact cont :conList){
                gen.writeStartObject();
                if( WM_Utils.getInteger(cont.IndividualNumber__c)!=null){
                    gen.writeNumberField('cif_individual_nbr', WM_Utils.getInteger(cont.IndividualNumber__c));
                }
                if( WM_Utils.getString(cont.Salutation__c)!=null){
                    gen.writeStringField('cif_prefix', WM_Utils.getString(cont.Salutation__c));
                }
                if( WM_Utils.getString(cont.FirstName)!=null){
                    gen.writeStringField('cif_fname', WM_Utils.getString(cont.FirstName));
                }
                if( WM_Utils.getString(cont.LastName)!=null){
                    gen.writeStringField('cif_lname', WM_Utils.getString(cont.LastName));
                }
                
                if( cont.ActiveContact__c!=null){
                    gen.writeBooleanField('cif_inactive', cont.ActiveContact__c);
                } 
                         if( WM_Utils.getString(cont.Mobilephone )!=null){
                    gen.writeStringField('cif_day_phone', WM_Utils.getString(cont.Mobilephone ));
                }
                if( WM_Utils.getString(cont.Phone)!=null){
                    gen.writeStringField('cif_eve_phone', WM_Utils.getString(cont.Phone));
                }
                if( WM_Utils.getString(cont.Fax)!=null){
                    gen.writeStringField('cif_fax_phone', WM_Utils.getString(cont.Fax));
                }
                if( WM_Utils.getString(cont.Dept__c)!=null){
                    gen.writeStringField('cif_department', WM_Utils.getString(cont.Dept__c));
                }
                if( WM_Utils.getString(cont.Title)!=null){
                    gen.writeStringField('cif_position', WM_Utils.getString(cont.Title));
                }
                if( WM_Utils.getString(cont.Email)!=null){
                    gen.writeStringField('cif_email_addr', WM_Utils.getString(cont.Email));
                }
                if(cont.HasOptedOutOfEmail!=null){
                    gen.writeBooleanField('cif_email_optin', cont.HasOptedOutOfEmail);
                } 
                if( cont.cif_rent_flag__c!=null){
                    gen.writeBooleanField('cif_rent_flag', cont.cif_rent_flag__c);
                }
                if( WM_Utils.getString(cont.CreatedBy.Name)!=null){
                    gen.writeStringField('cif_create_user', WM_Utils.getString(cont.CreatedBy.Name));
                }
                if( cont.ActiveContact__c!=null){
                    gen.writeBooleanField('cif_active_inactive', cont.ActiveContact__c);
                }
       
                
                
                gen.writeEndObject();
            }
            gen.writeEndArray();
            
            
            gen.writeFieldName('CustBillTo');
            gen.writeStartObject();
            if( WM_Utils.getString(acc.Parent.AccountNumber)!=null){
                gen.writeStringField('cbt_account_nbr', WM_Utils.getString(acc.Parent.AccountNumber));
            }
            
            else if( WM_Utils.getString(acc.AccountNumber)!=null){
                gen.writeStringField('cbt_account_nbr', WM_Utils.getString(acc.AccountNumber));
             }

            // WME-274 Change History 7: Start
            if(Parentaddresses.size()>0){
                if(WM_Utils.getString(Parentaddresses[0].First_Name__c)!=null){
                    gen.writeStringField('cbt_fname', WM_Utils.getString(Parentaddresses[0].First_Name__c));             
                }
                if(WM_Utils.getString(Parentaddresses[0].Last_Name__c)!=null){
                    gen.writeStringField('cbt_lname', WM_Utils.getString(Parentaddresses[0].Last_Name__c));             
                }
                if(WM_Utils.getString(Parentaddresses[0].Suffix__c)!=null){
                    gen.writeStringField('cbt_suffix', WM_Utils.getString(Parentaddresses[0].Suffix__c)); 
                }
            }  
             else  if(addressList.size()>0){
                if(WM_Utils.getString(addressList[0].First_Name__c)!=null){
                    gen.writeStringField('cbt_fname', WM_Utils.getString(addressList[0].First_Name__c));             
                }
                if(WM_Utils.getString(addressList[0].Last_Name__c)!=null){
                    gen.writeStringField('cbt_lname', WM_Utils.getString(addressList[0].Last_Name__c));             
                }
                if(WM_Utils.getString(addressList[0].Suffix__c)!=null){
                    gen.writeStringField('cbt_suffix', WM_Utils.getString(addressList[0].Suffix__c)); 
                }
            }
            // WME-274 Change History 7: End


            // WME-274 Change History 8: Start 
            if(WM_Utils.getString(acc.parent.Name)!=null){
                gen.writeStringField('cbt_company_name', WM_Utils.getString(acc.parent.Name)); 
            }
            else if(WM_Utils.getString(acc.Name)!=null){
                gen.writeStringField('cbt_company_name', WM_Utils.getString(acc.Name)); 
            }
            if(Parentaddresses.size()>0){
              
                if( WM_Utils.getString(Parentaddresses[0].Address_Line_1__c)!=null){
                    gen.writeStringField('cbt_street_addr', WM_Utils.getString(Parentaddresses[0].Address_Line_1__c));
                }
                if( WM_Utils.getString(Parentaddresses[0].City__c)!=null){
                    gen.writeStringField('cbt_city', WM_Utils.getString(Parentaddresses[0].City__c));
                }
                if( WM_Utils.getString(Parentaddresses[0].State__c)!=null){
                    gen.writeStringField('cbt_state', WM_Utils.getString(Parentaddresses[0].State__c));
                }
                if( WM_Utils.getString(Parentaddresses[0].Postal_Code__c)!=null){
                    gen.writeStringField('cbt_zip', WM_Utils.getString(Parentaddresses[0].Postal_Code__c));
                }
                if( WM_Utils.getString(Parentaddresses[0].Country__c)!=null){
                    gen.writeStringField('cbt_country', WM_Utils.getString(Parentaddresses[0].Country__c));
                }
                //WME-229
                if( WM_Utils.getString(acc.Parent.Email__c)!=null){   //WME-274 - Updated Parent Email
                    gen.writeStringField('cbt_email_addr', WM_Utils.getString(acc.Parent.Email__c));
                } 
                else{
                    if( WM_Utils.getString(acc.PersonEmail)!=null){
                        gen.writeStringField('cbt_email_addr', WM_Utils.getString(acc.PersonEmail));
                    } 
                }
                //WME-229
                // if(WM_Utils.getString(Parentaddresses[0].EmailAddress__c)!=null){
                //     gen.writeStringField('cbt_email_addr', WM_Utils.getString(Parentaddresses[0].EmailAddress__c)); 
                // }
            }
           
            else if(addressList.size()>0){
                system.debug('in   else'+addressList);
                if( WM_Utils.getString(addressList[0].Address_Line_1__c)!=null){
                    gen.writeStringField('cbt_street_addr', WM_Utils.getString(addressList[0].Address_Line_1__c));
                }
                if( WM_Utils.getString(addressList[0].City__c)!=null){
                    gen.writeStringField('cbt_city', WM_Utils.getString(addressList[0].City__c));
                }
                if( WM_Utils.getString(addressList[0].State__c)!=null){
                    gen.writeStringField('cbt_state', WM_Utils.getString(addressList[0].State__c));
                }
                if( WM_Utils.getString(addressList[0].Postal_Code__c)!=null){
                    gen.writeStringField('cbt_zip', WM_Utils.getString(addressList[0].Postal_Code__c));
                }
                if( WM_Utils.getString(addressList[0].Country__c)!=null){
                    gen.writeStringField('cbt_country', WM_Utils.getString(addressList[0].Country__c));
                }
                //WME-229
                if( WM_Utils.getString(acc.Email__c)!=null){
                    gen.writeStringField('cbt_email_addr', WM_Utils.getString(acc.Email__c));
                } 
            
                else{
                    if( WM_Utils.getString(acc.PersonEmail)!=null){
                    gen.writeStringField('cbt_email_addr', WM_Utils.getString(acc.PersonEmail));
                    } 
                }
                //WME-229
                // if(WM_Utils.getString(addressList[0].EmailAddress__c)!=null){
                //     gen.writeStringField('cbt_email_addr', WM_Utils.getString(addressList[0].EmailAddress__c)); 
                // }
            }
             // WME-274 Change History 8: End

            /*if( WM_Utils.getString(acc.Type)!=null){
if(acc.Type=='Retail' ){
gen.writeStringField('cbt_email_addr', WM_Utils.getString(acc.PersonEmail));

}
else if(acc.Type=='Business'){
if( WM_Utils.getString(acc.Email__c)!=null){
gen.writeStringField('cbt_email_addr', WM_Utils.getString(acc.Email__c));
}
}
}*/
            if(acc.PersonHasOptedOutOfEmail !=null){
                gen.writeBooleanField('cbt_optin_optout', acc.PersonHasOptedOutOfEmail); 
            }
            gen.writeFieldName('CustBillToPhoneNbr');
            gen.writeStartObject();

            // WME-274 Change History 9: Start  
            if(Parentaddresses.size()>0){
                if( WM_Utils.getString(Parentaddresses[0].Phone__c)!=null){
                    gen.writeStringField('cbt_day_phone', WM_Utils.getString(Parentaddresses[0].Phone__c));
                }
            }
             else if(addressList.size()>0){
                if( WM_Utils.getString(addressList[0].Phone__c)!=null){
                    gen.writeStringField('cbt_day_phone', WM_Utils.getString(addressList[0].Phone__c));
                }
            }
            if( WM_Utils.getString(acc.Parent.Phone)!=null){
                gen.writeStringField('cbt_eve_phone', WM_Utils.getString(acc.parent.Phone));
            }
           else if( WM_Utils.getString(acc.Phone)!=null){
                gen.writeStringField('cbt_eve_phone', WM_Utils.getString(acc.Phone));
            }
            if( WM_Utils.getString(acc.Parent.Fax)!=null){
                gen.writeStringField('cbt_fax_phone', WM_Utils.getString(acc.Parent.Fax));
            }
           else if( WM_Utils.getString(acc.Fax)!=null){
                gen.writeStringField('cbt_fax_phone', WM_Utils.getString(acc.Fax));
            }
            // WME-274 Change History 9: End
            
            gen.writeEndObject();
            gen.writeEndObject();
        }
        gen.writeFieldName('CustTaxes');
        gen.writeStartArray();
        if(TaxExemptnList!=null){
            for(Tax_Exemption__c taxExmption :TaxExemptnList){   
                gen.writeStartObject();
                if( WM_Utils.getString(taxExmption.Country__c)!=null){
                    gen.writeStringField('cst_tax_country', WM_Utils.getString(taxExmption.Country__c));
                }
                if( WM_Utils.getString(taxExmption.State__c)!=null){
                    gen.writeStringField('cst_tax_state', WM_Utils.getString(taxExmption.State__c));
                }
                
                if( WM_Utils.getString(taxExmption.Exemption_Type__c)!=null){
                    gen.writeStringField('cst_tax_code', WM_Utils.getString(taxExmption.Exemption_Type__c));
                }
                if( WM_Utils.getString(taxExmption.Exemption_Certificate__c)!=null){
                    gen.writeStringField('cst_tax_resale_exempt_nbr', WM_Utils.getString(taxExmption.Exemption_Certificate__c));
                }
                
                if( WM_Utils.maintainTheTimeZone(taxExmption.Expiration_Date__c)!=null){
                    gen.writeStringField('cst_tax_expiration_date', WM_Utils.maintainTheTimeZone(taxExmption.Expiration_Date__c));
                }
                gen.writeEndObject();
            }
        }
        gen.writeEndArray();
        
        if(acc.IsPersonAccount ){
            Account act = [Select Id,toLabel(HowManyBoats__c),toLabel(BoatType__c),toLabel(BoatLength__c),toLabel(PrimaryUse__c),toLabel(SecondaryUse__c) from Account where Id=:acc.id];
            gen.writeFieldName('CustProfiles');
            gen.writeStartArray();
            if( WM_Utils.getString(acc.HowManyBoats__c)!=null){
                gen.writeStartObject();
                gen.writeStringField('cst_profile_code','1');
                gen.writeStringField('cst_profile_code_desc','HOW MANY BOATS?');
                gen.writeStringField('cst_profile_data_desc',  WM_Utils.getString(act.HowManyBoats__c));
                gen.writeStringField('cst_profile_data_code', WM_Utils.getString(acc.HowManyBoats__c));
                gen.writeEndObject();    
            }  
            if( WM_Utils.getString(acc.BoatType__c)!=null){
                gen.writeStartObject();
                gen.writeStringField('cst_profile_code','2');
                gen.writeStringField('cst_profile_code_desc','BOAT TYPE?');
                gen.writeStringField('cst_profile_data_desc', WM_Utils.getString(act.BoatType__c));
                gen.writeStringField('cst_profile_data_code', WM_Utils.getString(acc.BoatType__c));
                gen.writeEndObject();    
            }
            if( WM_Utils.getString(acc.BoatLength__c)!=null){
                gen.writeStartObject();
                gen.writeStringField('cst_profile_code','3');
                gen.writeStringField('cst_profile_code_desc','BOAT LENGTH?');
                gen.writeStringField('cst_profile_data_desc', WM_Utils.getString(act.BoatLength__c));
                gen.writeStringField('cst_profile_data_code', WM_Utils.getString(acc.BoatLength__c));
                gen.writeEndObject();    
            }
            if( WM_Utils.getString(acc.PrimaryUse__c)!=null){
                gen.writeStartObject();
                gen.writeStringField('cst_profile_code','4');
                gen.writeStringField('cst_profile_code_desc','PRIMARY USE?');
                gen.writeStringField('cst_profile_data_desc', WM_Utils.getString(act.PrimaryUse__c));
                gen.writeStringField('cst_profile_data_code', WM_Utils.getString(acc.PrimaryUse__c));
                gen.writeEndObject();    
            }
            if( WM_Utils.getString(acc.SecondaryUse__c)!=null){
                gen.writeStartObject();
                gen.writeStringField('cst_profile_code','5');
                gen.writeStringField('cst_profile_code_desc','SECONDARY USE?');
                gen.writeStringField('cst_profile_data_desc', WM_Utils.getString(act.SecondaryUse__c));
                gen.writeStringField('cst_profile_data_code', WM_Utils.getString(acc.SecondaryUse__c));
                gen.writeEndObject();    
            }  
            if( WM_Utils.getString(acc.AnnualRevenue)!=null){
                gen.writeStartObject();
                gen.writeStringField('cst_profile_code','100');
                gen.writeStringField('cst_profile_code_desc','PS SALES POTENTIAL');
                gen.writeStringField('cst_profile_data_desc', WM_Utils.getString(acc.AnnualRevenue));
                gen.writeStringField('cst_profile_data_code', WM_Utils.getString(acc.AnnualRevenue));
                gen.writeEndObject();    
            }
            
            gen.writeEndArray();
            
        }
        gen.writeEndObject();
        gen.writeEndObject();
        String payLoad = gen.getAsString();
        system.debug('payload: '+payLoad);
        
        request.setBody(payLoad);
        System.debug('request : '+ request);
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        system.debug('getStatusCode ' + response.getStatusCode());
        system.debug('getBody ' + response.getBody());
        if(response.getStatusCode()==200){
            system.debug('Success ');
            //  return new List <Boolean>{true};
        }
        else{
            system.debug('Failure ');
            FeedItem post = new FeedItem();
            post.ParentId = sObjectIds[i]; 
            post.Title = 'The request to CRM Service failed with status code as '+response.getStatusCode() +'at '+String.valueOf(system.now());
            post.Body = response.getBody();
            insert post;
            //  return new List <Boolean>{false};
        }
        
        }
        // No depth limit in Enterprise edition 
        // 
        if(i!=49 && sObjectIds.size()<=50 && i!=sObjectIds.size()-1){
            System.enqueueJob(new WM_CRMIntegrationQueueable(sObjectIds,actionType,i+1));
            
        }
        
        
    }
}