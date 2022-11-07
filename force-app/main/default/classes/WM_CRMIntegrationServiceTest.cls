/**
* @description       : Test class for WM_CRMIntegrationService
* @author            : npendyala@liveareacx.com
* @last modified on  : 08-09-2022
* @last modified by  : Manohar.Alla@genzeon.com
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   08-09-2022   Manohar.Alla@genzeon.com             WMSA-5266 story related updates
**/
@isTest(SeeAllData=true)
public class WM_CRMIntegrationServiceTest {
     // Creating Test Data 
    public static Account acc = TestDataFactory.createAccountRecord();
    public static Address__c add = TestDataFactory.createAddress(acc.ID);
    public static Tax_Exemption__c TaxExm = TestDataFactory.CreateTaxExemption(acc.ID);
    public static Contact Con = TestDataFactory.CreateContacts(acc.ID);
    public static Account Acc1 = TestDataFactory.CreateBusinAccount(); 
    public static Address__c add1 = TestDataFactory.createAddress(acc1.ID);
    
    @IsTest
    static void testCRMService() {
        Test.startTest();
        //Mocking the response for the REST callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WM_CRMIntegrationProcessor.handlingTheChunkSizeLogic(new List<Id> {acc.ID},'A');
        Test.stopTest();
    }
     @IsTest
    static void testCRMService1() {
        Test.startTest();
        //Mocking the response for the REST callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WM_CRMIntegrationProcessor.handlingTheChunkSizeLogic(new List<Id> {add.ID},'A');
        Test.stopTest();
    }
    @IsTest
    static void testCRMService2() {
        Test.startTest();
        //Mocking the response for the REST callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         WM_CRMIntegrationProcessor.handlingTheChunkSizeLogic(new List<Id> {Con.ID},'A');
        Test.stopTest();
    }
       @IsTest
    static void testCRMService3() {
        Contact con = new Contact();
        con.AccountId = acc1.Id;
        con.lastName = 'United States';
        con.FirstName = 'Naveen';
        con.Title = 'Test';
        con.Email = 'test@gmail1.com';  
        con.HasOptedOutOfEmail = true;
        con.cif_rent_flag__c = true;
        insert con;
        Test.startTest();
        
        //Mocking the response for the REST callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WM_CRMIntegrationProcessor.handlingTheChunkSizeLogic(new List<Id> {Acc1.ID},'A');
        Test.stopTest();
    }
 
    // Story: WMSA-5266 Developer: Manohar Alla Change: New Method
    // WMSA-5266 Change History: Start 
    @IsTest
    static void testCRMService22() {
       id parentId = SCCTestDataFactory.createAccountPro();
       SCCTestDataFactory.createAddress(parentId);
       Account acc = new Account();
       acc.Name = 'Test Pro Account11';
       acc.AccountNumber = 'Test-1111111112322';
       acc.Email__c = 'protest11@test.com';
       acc.Phone = '222-222-3333';
       acc.ActivePRO__c = true;
       acc.SCCActive__c = true;
       acc.Cust_Payment_Class__c = 'P1';
       acc.wmProTier_c__c = 'SILV';
       acc.Test_Context__c = true;
       acc.ParentId=parentId;
       acc.fax='9999999999';
       insert acc;
       Test.startTest();
        //Mocking the response for the REST callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WM_CRMIntegrationProcessor.handlingTheChunkSizeLogic(new List<Id> {acc.ID},'A');
       Test.stopTest();
    }
    // WMSA-5266 Change History: Start
}