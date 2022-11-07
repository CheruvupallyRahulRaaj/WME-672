/**
 * Impl class of Account that implements interface
 *
 *
 * @author  Neeraj Yadav
 * @version 1.0
 * @since   2018-01-15
 */
public class SCCAccountImpl implements SCCSynchronisedInterface {
  //related account record
  public static Account accountRecord { get; set; }
  //customer number for commerce cloud
  public static String customerNo { get; set; }
  //customer number for commerce cloud
  public static String customerId { get; set; }
  //json map after deserialization
  public static Map<String, Object> jsonMap { get; set; }

  /**
   * This method used for implementing related operations and update object status as Synchronised for contact records
   * @param contactObj: SObject
   * @return None.
   */
  public void continueWithObject(SObject accountObj) {
    syncAccount(accountObj.Id);
  }

  public static Boolean syncAccount(String accountId) {
    SCCFileLogger logger = SCCFileLogger.getInstance();
    try {
      Map<String, SObject> accountFieldMappings = SCCUtilityClass.getAllCustomSettingValues(
        'Account',
        logger
      );
      String query = SCCQueryUtilClass.getInstance()
        .getQueryInstance()
        .setObjectName('Account')
        .setRelatedFields(
          new Set<String>{
            'Id',
            'FirstName',
            'LastName',
            'PersonEmail',
            'SFCC_Customer_Id__pc',
            'SFCC_Customer_Number__pc'
          }
        )
        .setClause('Id', '=', '\'' + accountId + '\'')
        .setLimit('1')
        .getQuery();
      List<Account> accountRecords = (List<Account>) SCCQueryUtilClass.getRecords(
        query
      );
      accountRecord = accountRecords.get(0);
      customerNo = accountRecord.SFCC_Customer_Number__pc;
      customerId = accountRecord.SFCC_Customer_Id__pc;
      //List<SCCCustomerWrapper> returnList = new List<SCCCustomerWrapper>();
      String resBody = SCCCommerceCloudConnect.getCustomerDetails(
        customerNo,
        SCCCommerceCloudConnect.connectToCommerceCloud()
      );
      logger.debug('SCCAccountImpl.Auth', 'customerNo: ' + customerNo);
      //String addressBody = SCCCommerceCloudConnect.getAddressDetails(customerNo, SCCCommerceCloudConnect.connectToCommerceCloud());
      String addressBody = SCCCommerceCloudConnect.getCustomerDetailsById(
        customerId,
        SCCCommerceCloudConnect.connectToCommerceCloudViaAccessKey()
      );
      logger.debug(
        'SCCAccountImpl.CustomerDetails',
        'customerNo: ' + customerNo
      );
      jsonMap = (Map<String, Object>) System.JSON.deserializeUntyped(resBody);
      Map<String, Object> addressJsonMap = (Map<String, Object>) System.JSON.deserializeUntyped(
        addressBody
      );
      system.debug(' **addressJsonMap for Address** ' + addressJsonMap);
      jsonMap.put('auth_type', addressJsonMap.get('auth_type'));
      jsonMap.put('addresses', addressJsonMap.get('addresses'));
      system.debug(' **jsonMap** ' + jsonMap);
      logger.debug(
        'SCCAccountImpl.syncAccount',
        'after adding address jsonMap: ' + System.JSON.serialize(jsonMap)
      );
      Account updatedAccount = (Account) SCCUtilityClass.initializeObject(
        jsonMap,
        'Account',
        accountFieldMappings,
        logger
      );
      updatedAccount.Contact_Status__pc = 'Synchronised';
      updatedAccount.from_SFCC__pc = true;
      updatedAccount.Id = accountRecord.Id;
      updatedAccount.Test_Context__c = true;
      Database.update(updatedAccount, true);

      if (
        addressJsonMap.containsKey('addresses') &&
        !((List<Object>) addressJsonMap.get('addresses')).isEmpty()
      ) {
        upsertAddressBook(
          updatedAccount.Id,
          (List<Object>) addressJsonMap.get('addresses')
        );
      }

      //This is add any client specific customization.
      updateAdditionalAttributes(updatedAccount, jsonMap, logger);
      return true;
    } catch (Exception e) {
      logger.error(
        'SCCAccountImpl.syncAccount',
        'Exception message : ' +
        e.getMessage() +
        ' StackTrack ' +
        e.getStackTraceString()
      );

      return false;
    } finally {
      logger.flush();
    }
  }

  public static void upsertAddressBook(
    Id recordId,
    List<Object> addressJsonMap
  ) {
    SCCFileLogger logger = SCCFileLogger.getInstance();
    try {
      logger.debug(
        'SCCAccountImpl.upsertAddressBook',
        ' recordId: ' +
        recordId +
        ' addressJsonMap: ' +
        addressJsonMap
      );
      Map<String, SObject> addressFieldMappings = SCCUtilityClass.getAllCustomSettingValues(
        'Address',
        logger
      );
      List<Address__c> contactAddressList = new List<Address__c>();
      Account personAccount = SCCUtilityClass.getPersonAccount(recordId);
      String contactId = personAccount.PersonContactId;

      for (Object obj : addressJsonMap) {
        Map<String, Object> tempMap = (Map<String, Object>) obj;
        Address__c record = (Address__c) SCCUtilityClass.initializeObject(
          tempMap,
          'Address__c',
          addressFieldMappings,
          logger
        );
        system.debug('**** ' + record);
        Address__c address = SCCUtilityClass.getContactAddress(
          String.valueOf(tempMap.get('address_id')),
          contactId,
          String.valueOf(recordId)
        );
        system.debug('**** ' + address);
        logger.debug(
          '****************Address ',
          ' recordId: ' +
          recordId +
          ' addressJsonMap: ' +
          addressJsonMap
        );
        if (address != null && address.Id != null) {
          record.Id = address.Id;
        }
        if (String.isNotEmpty(contactId)) {
          record.Contact__c = contactId;
        }
        record.Account__c = recordId;
        record.from_SFCC__c = true;
        contactAddressList.add(record);
      }
      system.debug('**contactAddressList** ' + contactAddressList);
      Database.upsert(contactAddressList);
    } catch (Exception e) {
      logger.error(
        'SCCAccountImpl.upsertAddressBook',
        'Exception message : ' +
        e.getMessage() +
        ' StackTrack ' +
        e.getStackTraceString()
      );
    } finally {
      logger.flush();
    }
  }

  /**
   * This method patch customer profile in commerce cloud. This is called usually by triggers
   * in service cloud when contact or account is updated in service cloud.
   * @param patchDataMap: Map<String, Object>
   * @return Boolean.
   */
  public static Boolean patchCustProfile(
    Map<String, Object> patchDataMap,
    Account acc
  ) {
    SCCFileLogger logger = SCCFileLogger.getInstance();
    Map<String, Object> jsonObjMap;
    Boolean result = false;
    try {
      system.debug('Patch Data Map ' + patchDataMap);
      jsonObjMap = SCCJsonUtil.initializeJsonObject(
        patchDataMap,
        'Account',
        logger
      );
      system.debug('JSONOBJMap ' + jsonObjMap);
      String body = (String) System.JSON.serialize(jsonObjMap);
      system.debug('Body  ' + jsonObjMap);
      logger.debug(
        'SCCAccountImpl.patchCustProfile',
        'Profile Patch request body: ' + body
      );
      patchCustProfileCallOut(body, acc.SFCC_Customer_Number__pc);
      result = true;
    } catch (Exception e) {
      logger.error(
        'SCCAccountImpl.patchCustProfile',
        'Exception message : ' +
        e.getMessage() +
        ' StackTrack ' +
        e.getStackTraceString()
      );
    } finally {
      logger.flush();
    }
    return result;
  }

  public static Boolean postCustProfile(
    Map<String, Object> postDataMap,
    Account acc
  ) {
    SCCFileLogger logger = SCCFileLogger.getInstance();
    Map<String, Object> jsonObjMap;
    Boolean result = false;
    try {
      system.debug('Post Data Map ' + postDataMap);
      jsonObjMap = SCCJsonUtil.initializeJsonObject(
        postDataMap,
        'Account',
        logger
      );
      system.debug('JSONOBJMap ' + jsonObjMap);
      String body = (String) System.JSON.serialize(jsonObjMap);
      system.debug('Body  ' + jsonObjMap);
      logger.debug(
        'SCCAccountImpl.postCustProfile',
        'Profile Post request body: ' + body
      );
      postCustProfileCallOut(body);
      result = true;
    } catch (Exception e) {
      logger.error(
        'SCCAccountImpl.postCustProfile',
        'Exception message : ' +
        e.getMessage() +
        ' StackTrack ' +
        e.getStackTraceString()
      );
    } finally {
      logger.flush();
    }
    return result;
  }

  public static Boolean postCustProfileForAddress(
    Map<String, Object> postDataMap,
    Address__c add
  ) {
    SCCFileLogger logger = SCCFileLogger.getInstance();
    Boolean result = false;
    List<String> custIds = new List<String>();
    Map<String, Object> jsonObjMap;
    Address__c ac = [
      SELECT
        Id,
        Account__r.SFCC_Customer_Number__pc,
        Account__r.SFCC_Customer_Id__pc,
        Country__c,
        Account__r.IsPersonAccount,
        Account__r.Id,
        Last_Name__c
      FROM Address__c
      WHERE Id = :add.Id
      LIMIT 1
    ];
    if (ac.Account__r.IsPersonAccount) {
      custIds.add(ac.Account__r.SFCC_Customer_Id__pc);
    } else {
      for (Contact con : [
        SELECT SFCC_Customer_Id__c, Id
        FROM Contact
        WHERE AccountId = :ac.Account__r.Id
      ]) {
        custIds.add(
          con.SFCC_Customer_Id__c != null
            ? con.SFCC_Customer_Id__c
            : 'SFSC' + con.Id
        );
      }
    }
    try {
      system.debug('Post Data Map ' + postDataMap);
      jsonObjMap = SCCJsonUtil.initializeJsonObject(
        postDataMap,
        'Address__c',
        logger
      );
      system.debug('JSONOBJMap ' + jsonObjMap);
      String body = (String) System.JSON.serialize(jsonObjMap);
      system.debug('Body  ' + jsonObjMap);
      logger.debug(
        'SCCAccountImpl.patchCustProfile',
        'Profile Patch request body: ' + body
      );
      postCustProfileCallOutForAddress(body, custIds);
      result = true;
    } catch (Exception e) {
      logger.error(
        'SCCAccountImpl.patchCustProfile',
        'Exception message : ' +
        e.getMessage() +
        ' StackTrack ' +
        e.getStackTraceString()
      );
    } finally {
      logger.flush();
    }
    return result;
  }

  public static Boolean patchCustProfileForAddress(
    Map<String, Object> patchDataMap,
    Address__c add,
    String addId
  ) {
    List<String> custIds = new List<String>();
    Address__c ac = [
      SELECT
        Id,
        Account__r.SFCC_Customer_Number__pc,
        Account__r.SFCC_Customer_Id__pc,
        Country__c,
        Last_Name__c,
        Account__r.IsPersonAccount,
        Account__r.Id
      FROM Address__c
      WHERE Id = :add.Id
      LIMIT 1
    ];
    if (ac.Account__r.IsPersonAccount) {
      custIds.add(ac.Account__r.SFCC_Customer_Id__pc);
    } else {
      for (Contact con : [
        SELECT SFCC_Customer_Id__c, Id
        FROM Contact
        WHERE AccountId = :ac.Account__r.Id
      ]) {
        custIds.add(con.SFCC_Customer_Id__c);
      }
    }
    SCCFileLogger logger = SCCFileLogger.getInstance();
    Map<String, Object> jsonObjMap;
    Boolean result = false;
    try {
      if (!patchDataMap.containsKey('name')) {
        patchDataMap.put('name', addId);
      }
      if (!patchDataMap.containsKey('country__c')) {
        patchDataMap.put('country__c', ac.Country__c);
      }
      if (!patchDataMap.containsKey('last_name__c')) {
        patchDataMap.put('last_name__c', ac.Last_Name__c);
      }
      system.debug('Patch Data Map ' + patchDataMap);
      jsonObjMap = SCCJsonUtil.initializeJsonObject(
        patchDataMap,
        'Address__c',
        logger
      );
      system.debug('JSONOBJMap ' + jsonObjMap);
      String body = (String) System.JSON.serialize(jsonObjMap);
      system.debug('Body  ' + jsonObjMap);
      logger.debug(
        'SCCAccountImpl.patchCustProfile',
        'Profile Patch request body: ' + body
      );
      patchCustProfileCallOutForAddress(body, custIds, addId);
      result = true;
    } catch (Exception e) {
      logger.error(
        'SCCAccountImpl.patchCustProfile',
        'Exception message : ' +
        e.getMessage() +
        ' StackTrack ' +
        e.getStackTraceString()
      );
    } finally {
      logger.flush();
    }
    return result;
  }

  @future(callout=true)
  static void patchCustProfileCallOutForAddress(
    String body,
    List<String> customerNos,
    String addId
  ) {
    SCCFileLogger logger = SCCFileLogger.getInstance();
    try {
      SCCCommerceCloudConnect.patchAddressDetails(
        body,
        customerNos,
        addId,
        SCCCommerceCloudConnect.connectToCommerceCloudViaAccessKey()
      );
    } catch (Exception e) {
      system.debug('Exception occured while posting address' + e);
    } finally {
      logger.flush();
    }
  }
  @future(callout=true)
  static void postCustProfileCallOutForAddress(
    String body,
    List<String> custIds
  ) {
    SCCFileLogger logger = SCCFileLogger.getInstance();
    try {
      String agentAccessToken = SCCCommerceCloudConnect.connectToCommerceCloudViaAccessKey();
      SCCCommerceCloudConnect.postAddressDetails(
        body,
        custIds,
        agentAccessToken
      );
    } catch (Exception e) {
      system.debug('Exception occured while posting address' + e);
    } finally {
      logger.flush();
    }
  }

  /**
   * This method is wrapper method to call webservice asynchronously.
   * @param patchDataMap: Map<String, Object>
   * @return Boolean.
   */
  @future(callout=true)
  static void patchCustProfileCallOut(String body, String customerNo) {
    SCCFileLogger logger = SCCFileLogger.getInstance();
    try {
      SCCCommerceCloudConnect.logger = logger;
      HttpResponse resp = SCCCommerceCloudConnect.updateCCCustomerProfile(
        body,
        customerNo,
        SCCCommerceCloudConnect.connectToCommerceCloud2ProfileOperations()
      );
    } catch (Exception e) {
      logger.error(
        'SCCAccountImpl.patchCustProfileCallOut',
        'Exception message : ' +
        e.getMessage() +
        ' StackTrack ' +
        e.getStackTraceString()
      );
    } finally {
      logger.flush();
    }
  }

  @future(callout=true)
  static void postCustProfileCallOut(String body) {
    SCCFileLogger logger = SCCFileLogger.getInstance();
    try {
      SCCCommerceCloudConnect.logger = logger;
      HttpResponse resp = SCCCommerceCloudConnect.postCCCustomerProfile(
        body,
        SCCCommerceCloudConnect.connectToCommerceCloud2ProfileOperations()
      );
    } catch (Exception e) {
      logger.error(
        'SCCAccountImpl.postCustProfileCallOut',
        'Exception message : ' +
        e.getMessage() +
        ' StackTrack ' +
        e.getStackTraceString()
      );
    } finally {
      logger.flush();
    }
  }

  /**
   * This method is to implement client specific customizations
   * @param updatedAccount: Account
   * @param jsonMap: Map<String, Object>
   * @param logger: SCCFileLogger
   * @return None.
   */
  public static void updateAdditionalAttributes(
    Account updatedAccount,
    Map<String, Object> jsonMap,
    SCCFileLogger logger
  ) {
  }
}