/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
//
// seeAllData is set to true because ConnectApi methods are not supported in data siloed tests.
@isTest
public class SCCContactImpl_Test {
  @testSetup
  static void setup() {
    SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
    SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();
    SCCTestDataFactory.createSFCCLogDefaultCustomSetting();
    SCCTestDataFactory.createContact(
      new Map<Integer, String>{ 1 => 'fname', 2 => 'fname', 3 => 'fname' },
      new Map<Integer, String>{ 1 => 'lname', 2 => 'lname', 3 => 'lname' },
      new Map<Integer, String>{
        1 => 'test@hotmail1.com',
        2 => 'test@yahoo1.com',
        3 => 'test@salesforce1.com'
      }
    );
    SCCTestDataFactory.createFieldMappingCustomSettings(
      new Map<String, String>{
        'first_name' => 'FirstName',
        'last_name' => 'LastName',
        'enabled' => 'Active__c',
        'email' => 'Email',
        'birthday' => 'BirthDate'
      },
      'Contact'
    );

    // Do I need to test Account?
    SCCTestDataFactory.createAccount(
      new Map<Integer, String>{ 1 => 'fname', 2 => 'fname', 3 => 'fname' },
      new Map<Integer, String>{ 1 => 'lname', 2 => 'lname', 3 => 'lname' },
      new Map<Integer, String>{
        1 => 'test@hotmail.com',
        2 => 'test@yahoo.com',
        3 => 'test@salesforce.com'
      },
      new Map<Integer, String>{ 1 => '12345', 2 => '23456', 3 => '34567' }
    );

    //create pro account
    Id accId = SCCTestDataFactory.createAccountPro();
    Id addrId = SCCTestDataFactory.createAddress(accId);

    // SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'first_name'=>'FirstName', 'last_name'=>'LastName', 'enabled'=>'Active__c', 'email'=>'personEmail', 'birthday'=>'personBirthDate'}, 'Account');
    SCCTestDataFactory.createAccountCase(
      1,
      [SELECT Id FROM Account LIMIT 1]
      .Id,
      'Test Case Description',
      'ContactUs',
      'Test Case Title'
    );
    // Do I need to test Case?
    SCCTestDataFactory.createCase(
      1,
      [SELECT Id FROM Contact LIMIT 1]
      .Id,
      'Test Case Description',
      'ContactUs',
      'Test Case Title'
    );
  }
  @IsTest
  static void testContinueWithObject_One() {
    Test.setMock(
      HttpCalloutMock.class,
      new SCCHttpCalloutMockGenerator_Test('CustomerDetails')
    );
    Contact cont = [SELECT Id FROM Contact LIMIT 1];
    Test.startTest();
    (new SCCContactImpl()).continueWithObject((SObject) cont);
    Test.stopTest();
  }

  @isTest
  static void testContinueWithObject_Two() {
    Test.setMock(
      HttpCalloutMock.class,
      new SCCHttpCalloutMockGenerator_Test('CustomerDetailsWithAddress')
    );
    Contact cont = [SELECT Id FROM Contact LIMIT 1];
    Test.startTest();
    (new SCCContactImpl()).continueWithObject((SObject) cont);
    Test.stopTest();
  }

  @isTest
  static void testContinueWithObject_Three() {
    Contact cont = [SELECT Id FROM Contact LIMIT 1];
    Test.startTest();
    (new SCCContactImpl()).continueWithObject((SObject) cont);
    Test.stopTest();
  }
  @isTest
  private static void testPostCustProfile_Four() {
    Test.setMock(
      HttpCalloutMock.class,
      new SCCHttpCalloutMockGenerator_Test('CustomerDetails')
    );
    Map<String, Object> testPatchMap = new Map<String, Object>{
      'personbirthdate' => '30-08-1981',
      'personemail' => 'nirajyadav@gmail.com',
      'active__c' => true
    };
    Contact con = [SELECT Id, LastName FROM Contact LIMIT 1];
    //acc.SFCC_Customer_Number__pc = null;
    Test.startTest();
    Boolean result1 = SCCContactImpl.postCustProfile(testPatchMap, con);
    Test.stopTest();
  }

  @isTest
  private static void testPatchCustProfile_Five() {
    Test.setMock(
      HttpCalloutMock.class,
      new SCCHttpCalloutMockGenerator_Test('CustomerDetails')
    );
    Map<String, Object> testPatchMap = new Map<String, Object>{
      'personbirthdate' => '30-08-1981',
      'personemail' => 'nirajyadav@gmail.com',
      'active__c' => true
    };
    Contact con = [
      SELECT Id, LastName, SFCC_Customer_Number__c
      FROM Contact
      LIMIT 1
    ];
    //acc.SFCC_Customer_Number__pc = null;
    SCCFileLogger logger = SCCFileLogger.getInstance();
    Map<String, Object> jsonObjMap = SCCJsonUtil.initializeJsonObject(
      testPatchMap,
      'Contact',
      logger
    );
    String body = (String) System.JSON.serialize(jsonObjMap);
    Test.startTest();
    Boolean result0 = SCCContactImpl.patchCustProfile(testPatchMap, con);
    SCCContactImpl.patchCustProfileCallOut(body, con.SFCC_Customer_Number__c);
    Test.stopTest();
  }

  @isTest
  private static void testUpsertAddressBook_One() {
    String addressBody = '[{"_type" : "customer_address","address1" : "10 Presidential Way","address_id" : "mea","city" : "Woburn","country_code" : "US","first_name" : "John","full_name" : "John M. Smith","last_name" : "Smith","postal_code" : "018.3","salutation" : "Mr.","state_code" : "MA"},';
    addressBody += '{"_type" : "customer_address","address1" : "10 Presidential Way","address_id" : "meb","city" : "Woburn","country_code" : "US","first_name" : "John","full_name" : "John M. Smith","last_name" : "Smith","postal_code" : "018.3","salutation" : "Mr.","state_code" : "MA"}]';
    List<Object> testAddressObj = (List<Object>) System.JSON.deserializeUntyped(
      addressBody
    );
    Contact cont = [
      SELECT Id, SFCC_Customer_Number__c, AccountId
      FROM Contact
      LIMIT 1
    ];
    SCCContactImpl.upsertAddressBook(cont.Id, cont.AccountId, testAddressObj);
  }

  @isTest
  private static void testUpsertAddressBook_Two() {
    String addressBody = '[{"_type" : "customer_address","address1" : "10 Presidential Way","city" : "Woburn","country_code" : "US","first_name" : "John","full_name" : "John M. Smith","last_name" : "Smith","postal_code" : "018.3","salutation" : "Mr.","state_code" : "MA"},';
    addressBody += '{"_type" : "customer_address","address1" : "10 Presidential Way","address_id" : "meb","city" : "Woburn","country_code" : "US","first_name" : "John","full_name" : "John M. Smith","last_name" : "Smith","postal_code" : "018.3","salutation" : "Mr.","state_code" : "MA"}]';
    List<Object> testAddressObj = (List<Object>) System.JSON.deserializeUntyped(
      addressBody
    );
    Contact cont = [
      SELECT Id, SFCC_Customer_Number__c, AccountId
      FROM Contact
      LIMIT 1
    ];
    SCCContactImpl.upsertAddressBook(null, cont.AccountId, testAddressObj);
  }

  @isTest
  private static void testPutCustProfile_Six() {
    Test.setMock(
      HttpCalloutMock.class,
      new SCCHttpCalloutMockGenerator_Test('CustomerDetails')
    );

    Contact con = [
      SELECT Id, FirstName, LastName, Email, SFCC_Customer_Number__c
      FROM Contact
      LIMIT 1
    ];

    Account acc = [
      SELECT Id
      FROM Account
      WHERE IsPersonAccount = FALSE AND ActivePRO__c = TRUE
      LIMIT 1
    ];
    con.email = 'TestClass@test.com';
    con.AccountId = acc.Id;
    update con;
    //acc.SFCC_Customer_Number__pc = null;

    String customerNo = con.SFCC_Customer_Number__c != null
      ? con.SFCC_Customer_Number__c
      : 'SFSC' + con.Id;
    String body = SCCSyncCustomerContactHelper.generateCustomerPayload(con);

    Test.startTest();
    Boolean result = SCCContactImpl.putCustProfile(con);

    SCCContactImpl.putCustProfileCallOut(body, customerNo, con.AccountId);

    Test.stopTest();
  }

  @isTest
  private static void testPutCustProfileException_Seven() {
    Test.setMock(
      HttpCalloutMock.class,
      new SCCHttpCalloutMockGenerator_Test('CustomerDetails')
    );

    Contact con = new Contact();

    String customerNo = 'SFCC0035C00000adDiSQAU';
    String body = SCCSyncCustomerContactHelper.generateCustomerPayload(con);

    Test.startTest();
    Boolean result = SCCContactImpl.putCustProfile(con);
    SCCContactImpl.putCustProfileCallOut(body, customerNo, con.AccountId);
    SCCContactImpl.patchCustProfile(new Map<String, Object>(), con);
    SCCContactImpl.postCustProfile(new Map<String, Object>(), con);
    SCCContactImpl.upsertAddressBook(con.Id, con.AccountId, new List<Object>());
    Test.stopTest();
  }

  @isTest
  private static void testSyncContact() {
    Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test());

    Contact con = [
      SELECT Id, FirstName, LastName, Email, SFCC_Customer_Number__c
      FROM Contact
      LIMIT 1
    ];

    Test.startTest();

    Boolean result = SCCContactImpl.syncContact(con.Id);

    Test.stopTest();
  }
}