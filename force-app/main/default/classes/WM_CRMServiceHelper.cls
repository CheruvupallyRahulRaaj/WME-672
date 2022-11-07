/**
* @description       : Helper class for WM_CRMIntegrationService
* @author            : npendyala@liveareacx.com
* @last modified on  : 24-03-2021
* @last modified by  : Manohar.Alla@genzeon.com
* Modifications Log 
* Ver   Date         Author                               Modification
* 
**/
public class WM_CRMServiceHelper {
    public static Account getAccount(String accId) {
        List < String > listOfFields = new List < String > {
            'Id','AccountNumber','Salutation__pc','Suffix__pc','SoldToNumber__c','ShippingAddress','ShippingStreet',
                'ShippingCity', 'ShippingState', 'ShippingPostalCode', 'ShippingCountry', 'ShippingLatitude','PersonMobilePhone',
                'ShippingLongitude', 'ShippingGeocodeAccuracy', 'AnnualRevenue','SecondaryUse__c','PrimaryUse__c','BoatLength__c','BoatType__c',
                'HowManyBoats__c','ShippingStreet2__c','ShippingStreet3__c','ShippingStreet4__c','Name','BillingStreet', 'BillingCity',
                'BillingState', 'BillingPostalCode','Phone','PersonEmail','IsPersonAccount',
                'BillingCountry', 'BillingLatitude', 'BillingLongitude','Email__c','Sales_Person_Name__c','SalesmanNumber__c','Sales_Person_Name__r.Name', 
                'cst_tax_resale_exempt_nbr__c','FirstName','MiddleName','LastName','BillingAddress','BillingStreet2__c',
                'BillingStreet3__c','BillingStreet4__c','Type','AccountSource','Market_Team__c','AssociateId__c','Cust_Payment_Class__c',
                'loyaltyAccountNumber__c','RecordTypeId','cst_exempt_certificate__c','cst_tax_exempt__c','cst_exempt_expirycst_exempt_expiry__c',
                'Associate__c','SCCActive__c','cst_rent_name__c','cst_rent_email__c','RegionZone__c','DoNotMail__c','PersonHasOptedOutOfEmail','PersonTitle',
                'Sales_Person_Number__c','Industry','PersonDoNotCall','LastModifiedById','CreatedById','LastModifiedBy.Name','CreatedBy.Name','wmProTier_c__c','c_wmWarehouse__c','wmProPORequired__c',
                'PersonHomePhone','Fax','cst_tax_country__c','taxState__c','cst_tax_code__c','cst_tax_expiration_date__c','Account_IndustryDesc__c','CustomerNumber__c',
                'CreatedDate','LastModifiedDate','PersonHasOptedOutOfFax','call_code__c', 'Parent.AccountNumber',
                // Story: WME-274 Developer: Manohar Alla Change: Added following seven fields
                'ParentId','Parent_Bill_To__c','ActivePRO__c','parent.Name','parent.phone','parent.Fax','parent.Email__c'
                };
                    
                    Account acc = (Account) WM_DaoService.getSobjectById(accId, listOfFields, Account.SObjectType);
        return acc;
    }     
    public static List<Contact> getRelatedContact(String accountId){
        List<Contact> contactList = new List<Contact>();
       // WME-274 - following line Null Check for acc
       if(string.isNotBlank(accountId)){
        contactList = [Select ID, AccountId, FirstName,LastName,Name,Salutation__c,Suffix__c,ActiveContact__c,MobilePhone,HomePhone,Phone,Fax,Department,IndividualNumber__c,
                      Title,Email,HasOptedOutOfEmail,cif_rent_flag__c,CreatedById,CreatedBy.Name,LastModifiedBy.Name,Customer_Auth_Status__c,OwnerId,CreatedDate,Dept__c,LastModifiedDate from Contact where AccountId =:accountId];
       }
            return contactList;
    }
    public static List<Contact> getContacts(List<Id> conId) {
        List<Contact> contactList = new List<Contact>();
        contactList = [Select Id, AccountId, FirstName,LastName,Salutation__c,Name,Suffix__c,ActiveContact__c,MobilePhone,HomePhone,Phone,Fax,Department,IndividualNumber__c,
                      Title,Email,HasOptedOutOfEmail,cif_rent_flag__c,CreatedById,CreatedBy.Name,LastModifiedBy.Name,Customer_Auth_Status__c,OwnerId,CreatedDate,Dept__c,LastModifiedDate from Contact where Id IN :conId];
        return contactList;
    }
    public static List<Address__c> getAddress(String accId){
        Address__c addr = new Address__c();
        list<Address__c> addlist  = new list<Address__c>();
        // WME-274 - following line Null Check for acc
        if(string.isNotBlank(accId)){
          addlist= [SELECT Id, Salutation__c, Suffix__c, Address_Line_4__c, EmailAddress__c, MailCode__c, MailCodeDesc__c, 
            csh_van_route_seq__c, cst_reserve_whs__c, csh_van_route__c,Account__c, ReserveLocation__r.ExternalReference,ReserveLocation__c,
            ActiveAddress__c, wmPreferredAddress__c, Name,First_Name__c,Last_Name__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
            City__c,Country__c,State__c,Postal_Code__c,Phone__c,isNewAddress__c FROM Address__c where (Account__c=:accId and 
                                                                                       wmPreferredAddress__c=true) order by createddate desc ];
        }
         return addlist;

        /*if(addressList.size() > 0 ){
            return addressList[0];
        }else {
            return null;
        }*/
        
    }

    public static List<Address__c> getBillingAddress(String accId){
        Address__c addr = new Address__c();
        List<Account> childAccounts = [Select Id,ParentId,Parent_Bill_To__c From Account WHERE Id = :accId];
        Account childAccount = null;
        if(childAccounts.size()>0){
            childAccount = childAccounts[0];
        }
        if(childAccount!=null && childAccount.ParentId!=null){
            return  [SELECT Id,Account__r.Name, Salutation__c, Suffix__c, Address_Line_4__c, EmailAddress__c, MailCode__c, MailCodeDesc__c, 
                    csh_van_route_seq__c, cst_reserve_whs__c, csh_van_route__c,Account__c, ReserveLocation__r.ExternalReference,ReserveLocation__c,
                    ActiveAddress__c, wmPreferredAddress__c, Name,First_Name__c,Last_Name__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                    City__c,Country__c,State__c,Postal_Code__c,Phone__c,isNewAddress__c FROM Address__c where (Account__c=:childAccount.ParentId and 
                                                                                            wmPreferredAddress__c=true) order by createddate desc ];
        }
        else{
            return null;
        }
    }
    
     public static List<Address__c> getAddresses(String accId){
        Address__c addr = new Address__c();
          // WME-274 - following line Null Check for acc
          list<Address__c> addlist  = new list<Address__c>();
          if(string.isNotBlank(accId)){
            addlist=  [SELECT Id, Salutation__c, Suffix__c, Address_Line_4__c, EmailAddress__c, MailCode__c, MailCodeDesc__c, 
                csh_van_route_seq__c, cst_reserve_whs__c, csh_van_route__c,Account__c, ReserveLocation__r.ExternalReference,ReserveLocation__c,
                ActiveAddress__c, wmPreferredAddress__c, Name,First_Name__c,Last_Name__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                City__c,Country__c,State__c,Postal_Code__c,Phone__c,isNewAddress__c FROM Address__c where Account__c=:accId order by createddate desc ];    
          }    
          return addlist;
    }
    
    // The following would not be used ideally
    public static List<Address__c> getAllAddress(List<Id> adressIDs){
        List<Address__c> addr = new List<Address__c>();
        addr = [SELECT Id, Salutation__c, Suffix__c, Address_Line_4__c, EmailAddress__c, MailCode__c, MailCodeDesc__c, 
                csh_van_route_seq__c, cst_reserve_whs__c, csh_van_route__c,Account__c,ReserveLocation__r.ExternalReference,ReserveLocation__c,
                ActiveAddress__c, wmPreferredAddress__c, Name,First_Name__c,Last_Name__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                City__c,Country__c,State__c,Postal_Code__c,Phone__c,isNewAddress__c FROM Address__c where ID IN :adressIDs order by createddate desc];
        if(addr!=null && addr.size() > 0){
            return addr;
        }
        else{
            return null;
        }
    }
    
    public static List<Tax_Exemption__c> getTaxExemptions(String accountId) {
        List<Tax_Exemption__c> TaxExemptnList = [Select Id,AccountId__c,State__c,Country__c,Exemption_Certificate__c,Exemption_Type__c,Expiration_Date__c,Global_Exemption__c  from Tax_Exemption__c where AccountId__c =:accountId];
       if(TaxExemptnList.size()>0){
           return TaxExemptnList; 
       }
        else{
            return null;
        }
       
    }
    
}