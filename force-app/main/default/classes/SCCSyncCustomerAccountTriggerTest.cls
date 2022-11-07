@isTest
public class SCCSyncCustomerAccountTriggerTest {
	@testSetup
    public static void createTestData() {
        Account acc = new Account();
        acc.FirstName = 'John';
        acc.LastName = 'Doe';
        acc.PersonEmail = 'john@doe.com';
        acc.BillingStreet = '1166 W Newport Center Dr';
        acc.BillingCity = 'Deerfield Beach';
        acc.BillingPostalCode =  '33442';
        acc.BillingState =  'FL';
        acc.BillingCountry =  'US';
        acc.Phone = '3333333333';
        acc.Test_Context__c = true;
        insert acc;
        Account Acc2 = new Account();        
        Acc2.Name = 'Naveen';
        Acc2.AccountNumber = '10416913';
        Acc2.Type = 'Business';
        Acc2.Email__c = 'test3@gmail.com';
        insert Acc2;
        Account Acc1 = new Account();        
        Acc1.Name = 'Naveen';
        Acc1.AccountNumber = '10416913';
        Acc1.Type = 'Business';
        Acc1.ParentId = Acc2.Id;
        Acc1.Email__c = 'test1@gmail.com';
        insert Acc1;
        Contact con = New Contact ();
        con.AccountId = Acc2.Id;
        con.lastName = 'United States';
        con.FirstName = 'Naveen';
        con.Title = 'Test';
        con.Email = 'test@gmail.com';  
        con.HasOptedOutOfEmail = true;
        con.cif_rent_flag__c = true;
        con.SFCC_Customer_Id__c = 'Test';  
        con.Contact_Status__c = 'Created';
        insert con;
        Contact con1 = New Contact ();
        con1.AccountId = Acc2.Id;
        con1.lastName = 'United';
        con1.HasOptedOutOfEmail = true;
        con1.cif_rent_flag__c = false;
        con1.SFCC_Customer_Id__c = 'Test1';  
        con1.Contact_Status__c = 'Updated';
        insert con1;
        con1 =  [SELECT Id,lastName, Title,SFCC_Customer_Id__c,Contact_Status__c FROM Contact where SFCC_Customer_Id__c != null limit 1];
        update con1;
        Address__c addr = new Address__c();
        addr.Suffix__c = 'Naveen';
        addr.EmailAddress__c = 'test@gmail.com';
        //addr.Account__c = addr.accId;
        addr.wmPreferredAddress__c = true;
        addr.ActiveAddress__c = false;
        addr.Phone__c = '1234567890';
        insert addr;
    }
    /*public static Account acc = TestDataFactory.createAccountRecord();
    public static Address__c add = TestDataFactory.createAddress(acc.ID);
    public static Contact con = TestDataFactory.CreateContacts(acc.ID);*/

   
	public static testMethod void test1() {
        Account acc = [SELECT Id, SFCC_update__c,AccountNumber,CustomerNumber__c FROM Account LIMIT 1];
        acc.SFCC_update__c = false;
        acc.AccountNumber = acc.CustomerNumber__c;
        update acc;
	}
   /* public static testMethod void test2() {
         Account Acc1 = new Account();        
        Acc1.Name = 'Naveen';
        Acc1.AccountNumber = '10416913';
        Acc1.Type = 'Business';
        insert Acc1;
    
        Contact con = [select id,AccountId,Contact_Status__c from contact LIMIT 1];
        con.AccountId = Acc1.Id;
        system.debug('AccountId' + Acc1.Id);
        con.Contact_Status__c = 'Updated';
        update con;
    }*/
}