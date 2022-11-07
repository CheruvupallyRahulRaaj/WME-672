@IsTest
public with sharing class ShoppingCartAuraControllerTest {
    
    @testSetup 
    static void setup() {

        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();      
        SCCTestDataFactory.createSFCCLogDefaultCustomSetting();         
        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        SCCTestDataFactory.createAccount(1, 'test account', false);
        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();
                  
        SCCTestDataFactory.createAccountCase(1, [select Id from Account Limit 1].Id, 'Test Case Description', 'ContactUs', 'Test Case Title');
		SCCTestDataFactory.createCase(5, [SELECT Id FROM Contact LIMIT 1].Id, 'Test cases', 'ContactUs','Mr');
    }

    @IsTest
    static void testGetAccessTokenCase() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        Case caseRec = [SELECT Id, AccountId FROM Case where AccountId != NULL LIMIT 1];
        ShoppingCartAuraController.getAccessToken(caseRec.Id, 'Case');
        Test.stopTest();
    }
    
    @IsTest
    static void testErrorGetAccessTokenCase() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        ShoppingCartAuraController.getAccessToken('abcd', 'Case');
        Test.stopTest();
    }    
    
    @IsTest
    static void testGetAccessTokenAccount() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        Case caseRec = [SELECT Id, AccountId FROM Case where AccountId != NULL LIMIT 1];
        ShoppingCartAuraController.getAccessToken(caseRec.AccountId, 'Account');
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAccessTokenContact() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        Contact conRec = [SELECT Id, AccountId FROM Contact LIMIT 1];
        ShoppingCartAuraController.getAccessToken(conRec.Id, 'Contact');
        Test.stopTest();
    }
    
    @IsTest
    static void testErrorGetAccessTokenAccount() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        ShoppingCartAuraController.getAccessToken('abcd', 'Account');
        Test.stopTest();
    } 
    
    @IsTest
    static void testGetStoreSessionURL() {
        ShoppingCartAuraController.getStoreSessionURL();
    } 
   
    @IsTest
    static void testGetStoreFrontURL() {
        ShoppingCartAuraController.getStoreFrontURL();
    } 
    
    @IsTest
    static void testGetProStoreSessionURL() {
        ShoppingCartAuraController.getProStoreSessionURL();
    } 
   
    @IsTest
    static void testGetProStoreFrontURL() {
        ShoppingCartAuraController.getProStoreFrontURL();
    } 
    
}