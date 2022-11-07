/**
 * Util class create test data
 *
 *
 * @author  Neeraj Yadav
 * @version 1.0
 * @since   2017-11-22
 */
@isTest
public class SCCTestDataFactory {
  /**
   * This method used for creation of order record.
   * @param count: Integer
   * @param accountId: Id
   * @param effectiveDate: Date
   * @param status: String
   * @param orderNumber: String
   * @param contactId: Id
   * @return None.
   */
  /**public static void createOrder(Integer count, Id accountId, Date effectiveDate, String status, String orderNumber, Id contactId) {

        List<Order> insertOrderList = new List<Order>();
        for(Integer index = 0; index < count; index++) {
            Order o = new Order(    AccountId = accountId,
                                    EffectiveDate = effectiveDate,
                                    Status = status,
                                    SFCC_Order_Total__c = 80.00,
                                    Order_SCCSync_Status__c = 'created',
                                    SFCC_Order_Number__c = orderNumber + String.valueOf(index),
                                    Order_Contact__c = contactId
                               );
            insertOrderList.add(o);
        }
        Database.insert(insertOrderList, false);
		//System.debug('createOrder : Order inserted'+ JSON.serialize([SELECT Id, SFCC_Order_Number__c FROM Order]));
    }*/

  /**
   * This method used for creation of order record.
   * @param count: Integer
   * @param accountId: Id
   * @param effectiveDate: Date
   * @param status: String
   * @param orderNumber: String
   * @param contactId: Id
   * @return None.
   */
  /*public static void createAccountOrder(Integer count, Id accountId, Date effectiveDate, String status, String orderNumber, Id contactId) {

        List<Order> insertOrderList = new List<Order>();
        for(Integer index = 0; index < count; index++) {
            Order o = new Order(    AccountId = accountId,
                                    EffectiveDate = effectiveDate,
                                    Status = status,
                                    SFCC_Order_Total__c = 80.00,
                                    SFCC_Order_Number__c = orderNumber + String.valueOf(index),
                                    Order_Contact__c = contactId
                               );
            insertOrderList.add(o);
        }
        Database.insert(insertOrderList, false);
		//System.debug('createOrder : Order inserted'+ JSON.serialize([SELECT Id, SFCC_Order_Number__c FROM Order]));
    }*/

  /**
   * This method used for creation of Account record.
   * @param firstNameMap: Map<Integer, String>
   * @param lastNameMap: Map<Integer, String>
   * @param emailMap: Map<Integer, String>
   * @return None.
   */
  public static void createAccount(
    Map<Integer, String> firstNameMap,
    Map<Integer, String> lastNameMap,
    Map<Integer, String> emailMap,
    Map<Integer, String> customerNoMap
  ) {
    List<Account> insertAccountList = new List<Account>();
    for (Integer key : firstNameMap.keySet()) {
      Account acc = new Account(
        FirstName = firstNameMap.get(key),
        LastName = lastNameMap.get(key),
        personEmail = emailMap.get(key),
        SFCC_Customer_Number__pc = customerNoMap.get(key),
        Contact_Status__pc = 'Created',
        Test_Context__c = true
      );
      insertAccountList.add(acc);
    }
    system.debug('insertAccountList  ' + insertAccountList);
    Database.insert(insertAccountList, false);
  }

  /**
   * This method used for creation of contact record.
   * @param firstNameMap: Map<Integer, String>
   * @param lastNameMap: Map<Integer, String>
   * @param emailMap: Map<Integer, String>
   * @return None.
   */
  public static void createContact(
    Map<Integer, String> firstNameMap,
    Map<Integer, String> lastNameMap,
    Map<Integer, String> emailMap
  ) {
    List<Contact> insertContactList = new List<Contact>();
    for (Integer key : firstNameMap.keySet()) {
      Contact c = new Contact(
        FirstName = firstNameMap.get(key),
        LastName = lastNameMap.get(key),
        Email = emailMap.get(key),
        Contact_Status__c = 'Created',
        Test_Context__c = true
      );
      insertContactList.add(c);
    }
    system.debug('insertContactList  ' + insertContactList);
    Database.insert(insertContactList, false);
  }

  /**
   * This method used for creation of account record.
   * @param count: Integer
   * @param accountName: String
   * @param additionalName: Boolean
   * @return None.
   */
  public static void createAccount(
    Integer count,
    String accountName,
    Boolean additionalName
  ) {
    List<Account> insertAccountList = new List<Account>();
    for (Integer index = 0; index < count; index++) {
      String name = additionalName
        ? accountName + String.valueOf(index)
        : accountName;
      Account a = new Account(Name = name, Test_Context__c = true);
      insertAccountList.add(a);
    }
    Database.insert(insertAccountList, false);
  }

  /**
   * This method used for creation of Account record.
   * @return None.
   */

  public static Id createAccountPro() {
    Account acc = new Account();
    acc.Name = 'Test Pro Account';
    acc.AccountNumber = 'Test-111111111';
    acc.Email__c = 'protest@test.com';
    acc.Phone = '222-222-2222';
    acc.ActivePRO__c = true;
    acc.SCCActive__c = true;
    acc.Cust_Payment_Class__c = 'P1';
    acc.wmProTier_c__c = 'SILV';
    acc.Test_Context__c = true;
    system.debug('Pro Account   ' + acc);
    Database.insert(acc, false);
    return acc.Id;
  }

  public static Id createAddress(Id accId) {
    Address__c addr = new Address__c();
    addr.Account__c = accId;
    addr.ActiveAddress__c = true;
    addr.Name = 'Work';
    addr.Phone__c = '222-222-2222';
    addr.Address_Line_1__c = '1 Main St';
    addr.City__c = 'Columbus';
    addr.State__c = 'Ohio';
    addr.Country__c = 'US';
    addr.Postal_Code__c = '43230';
    addr.wmPreferredAddress__c = true;
    Database.insert(addr, false);
    return addr.Id;
  }

  /**
   * This method used for creation of sfcc configuration record(custom setting).
   * @return None.
   */
  public static void createSFCCConfigDefaultCustomSetting() {
    Database.insert(
      new SFCCConfiguration__c(
        Name = 'Default Test',
        Customer_List_Id__c = 'SiteGenesis',
        SFCC_Site_URL__c = 'https://xxxx-dw.demandware.net',
        Site_Id__c = 'RefArch',
        Contact_Site_Id__c = 'SiteWM',
        Time__c = 1,
        Replace_Order_Path__c = 'SiteWM'
      ),
      false
    );
  }

  /**
   * This method used for creation of sfcc credential record(custom setting).
   * @return None.
   */
  public static void createSFCCCredentialDefaultCustomSetting() {
    Database.insert(
      new SFCC_Integration_Creds__c(
        Client_Id__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        Client_Secret__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
      ),
      false
    );
  }

  /**
   * This method used for creation of sfcc log setting record(custom setting).
   * @return None.
   */
  public static void createSFCCLogDefaultCustomSetting() {
    Database.insert(
      new SCC_LogLevels__c(Name = 'SCCLoggerTestALL', Loglevel__c = 'SYSDEBUG'),
      false
    );
  }

  /**
   * This method used for creation of field_mappings record(custom setting - Order/Contact/Case).
   * @param keyValueMap: Map<String, String>
   * @param objectName: String
   * @return None.
   */
  public static void createFieldMappingCustomSettings(
    Map<String, String> keyValueMap,
    String objectName
  ) {
    List<SObject> insertObjectList = new List<SObject>();
    for (String key : keyValueMap.keySet()) {
      SObject obj = SCCUtilityClass.getNewSObject(
        objectName + 'FieldMapping__c'
      );
      obj.put('Name', key);
      obj.put('CC_Attribute__c', key);
      obj.put('Field_Api_Name__c', keyValueMap.get(key));
      insertObjectList.add(obj);
    }
    Database.insert(insertObjectList, false);
  }

  /**
   * This method used for creation of field_mappings record(custom setting - Order/Contact/Case).
   * @param keyValueMap: Map<String, String>
   * @param objectName: String
   * @return None.
   */
  public static void createSyncFieldMappingCustomSettings(
    Map<String, String> keyValueMap,
    String objectName
  ) {
    List<SObject> insertObjectList = new List<SObject>();
    for (String key : keyValueMap.keySet()) {
      SObject obj = SCCUtilityClass.getNewSObject(
        objectName + 'FieldMapping__c'
      );
      obj.put('Name', key);
      obj.put('CC_Attribute__c', key);
      obj.put('Field_Api_Name__c', keyValueMap.get(key));
      obj.put('Enable_Sync__c', true);
      insertObjectList.add(obj);
    }
    Database.insert(insertObjectList, false);
  }

  /**
   * This method used for creation of field_mappings record(custom setting - Order/Contact/Case).
   * @param keyValueMap: Map<String, String>
   * @param objectName: String
   * @return None.
   */
  public static void createPatchFieldMappingCustomSettings(
    Map<String, String> keyValueMap,
    String objectName
  ) {
    List<SObject> insertObjectList = new List<SObject>();
    for (String key : keyValueMap.keySet()) {
      SObject obj = SCCUtilityClass.getNewSObject(
        objectName + 'FieldMapping__c'
      );
      obj.put('Name', key);
      obj.put('CC_Attribute__c', key);
      obj.put('Field_Api_Name__c', keyValueMap.get(key));
      obj.put('Enable_Patch__c', true);
      insertObjectList.add(obj);
    }
    Database.insert(insertObjectList, false);
  }

  /**
   * This method used for creation of field_mappings record(custom setting - Order/Contact/Case).
   * @param keyValueMap: Map<String, String>
   * @param objectName: String
   * @return None.
   */
  public static void createPatchSyncFieldMappingCustomSettings(
    Map<String, String> keyValueMap,
    String objectName
  ) {
    List<SObject> insertObjectList = new List<SObject>();
    for (String key : keyValueMap.keySet()) {
      SObject obj = SCCUtilityClass.getNewSObject(
        objectName + 'FieldMapping__c'
      );
      obj.put('Name', key);
      obj.put('CC_Attribute__c', key);
      obj.put('Field_Api_Name__c', keyValueMap.get(key));
      obj.put('Enable_Sync__c', true);
      obj.put('Enable_Patch__c', true);
      insertObjectList.add(obj);
    }
    Database.insert(insertObjectList, false);
  }

  /**
   * This method used for creation of case record.
   * @param count: Integer
   * @param contactId: Id
   * @param description: String
   * @param casetype: String
   * @param title: String
   * @return None.
   */
  public static void createCase(
    Integer count,
    Id contactId,
    String description,
    String casetype,
    String title
  ) {
    List<Case> insertCaseList = new List<Case>();
    for (Integer index = 0; index < count; index++) {
      Case c = new Case(
        ContactId = contactId,
        Description = description,
        Type = caseType,
        Subject = title
      );
      insertCaseList.add(c);
    }
    Database.insert(insertCaseList, false);
  }

  /**
   * This method used for creation of case record.
   * @param count: Integer
   * @param contactId: Id
   * @param description: String
   * @param casetype: String
   * @param title: String
   * @return None.
   */
  public static void createAccountCase(
    Integer count,
    Id accountId,
    String description,
    String casetype,
    String title
  ) {
    List<Case> insertCaseList = new List<Case>();
    for (Integer index = 0; index < count; index++) {
      Case c = new Case(
        AccountId = accountId,
        Description = description,
        Type = caseType,
        Subject = title
      );
      insertCaseList.add(c);
    }
    Database.insert(insertCaseList, false);
  }
}