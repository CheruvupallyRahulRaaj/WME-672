/**
* @description       :  test class for WM_CRMServiceHelper
* @author            :  Manohar.Alla@genzeon.com
* @last modified on  :  12-09-2022
* @last modified by  :  Manohar.Alla@genzeon.com
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   12-09-2022   Manohar.Alla@genzeon.com             Initial Version
**/

@istest
public with sharing class WM_CRMServiceHelperTest {
    @istest
    public static void Testmethod1(){
    account  acc = TestDataFactory.CreateBusinAccount();
    Address__c add = TestDataFactory.createAddress(acc.id);
    Tax_Exemption__c TaxExm = TestDataFactory.CreateTaxExemption(acc.id);
    contact  con = new  contact();
    con.AccountId = acc.Id;
    con.lastName = 'United States';
    con.FirstName = 'Naveen1';
    con.Title = 'Test1';
    con.Email = 'testtest@gmail.com';  
    con.HasOptedOutOfEmail = true;
    con.cif_rent_flag__c = true; 
   insert con;
    
     string  accid1 = acc.id;
     list<id>conids  = new list<id>();
     conids.add(con.id);
    account a=   WM_CRMServiceHelper.getAccount(accid1);
       WM_CRMServiceHelper.getContacts(conids);
       WM_CRMServiceHelper.getBillingAddress(accid1);
      list<contact> cont =   WM_CRMServiceHelper.getRelatedContact(accid1);
       WM_CRMServiceHelper.getAddress(accid1);
       WM_CRMServiceHelper.getAddresses(accid1);
       WM_CRMServiceHelper.getTaxExemptions(accid1);
     // getBillingAddress
     system.assertEquals(acc.name,a.name);
     system.assertEquals(1,cont.size());
}
}