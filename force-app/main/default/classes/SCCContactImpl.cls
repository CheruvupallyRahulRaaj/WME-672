/**
 * Impl class of contact that implements interface
 *
 *
 * @author  Neeraj Yadav
 * @version 1.0
 * @since   2018-01-15
 * @author  Thomas Feldmeier
 * @version 1.1
 * @since   2021-02-18
 * @whatsnew   Updated with patchCustProfile and patchCustProfileCallOut
 */
public class SCCContactImpl implements SCCSynchronisedInterface {
  //related contact record
  public static Contact contactRecord;
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
  public void continueWithObject(SObject contactObj) {
    syncContact(contactObj.Id);
  }

  public static Boolean syncContact(String contactId) {
    SCCFileLogger logger = SCCFileLogger.getInstance();
    try {
      Map<String, SObject> contactFieldMappings = SCCUtilityClass.getAllCustomSettingValues(
        'Contact',
        logger
      );
      contactRecord = [
        SELECT
          Id,
          FirstName,
          LastName,
          Email,
          SFCC_Customer_Id__c,
          SFCC_Customer_Number__c,
          AccountId
        FROM Contact
        WHERE Id = :contactId
      ];
      customerNo = contactRecord.SFCC_Customer_Number__c;
      customerId = contactRecord.SFCC_Customer_Id__c;
      //List<SCCCustomerWrapper> returnList = new List<SCCCustomerWrapper>();
      String resBody = SCCCommerceCloudConnect.getCustomerDetails(
        customerNo,
        SCCCommerceCloudConnect.connectToCommerceCloud()
      );
      String addressBody = SCCCommerceCloudConnect.getCustomerDetailsById(
        customerId,
        SCCCommerceCloudConnect.connectToCommerceCloudViaAccessKey()
      );
      logger.debug(
        'SCCContactImpl.syncContact',
        'resBody: ' +
        resBody +
        ' addressBody: ' +
        addressBody
      );
      jsonMap = (Map<String, Object>) System.JSON.deserializeUntyped(resBody);
      Map<String, Object> addressJsonMap = (Map<String, Object>) System.JSON.deserializeUntyped(
        addressBody
      );
      system.debug(' **addressJsonMap for Address** ' + addressJsonMap);
      Contact updatedContact = (Contact) SCCUtilityClass.initializeObject(
        jsonMap,
        'Contact',
        contactFieldMappings,
        logger
      );
      updatedContact.Contact_Status__c = 'Synchronised';
      updatedContact.from_SFCC__c = true;
      updatedContact.Id = contactRecord.Id;
      updatedContact.Test_Context__c = true;
      Database.update(updatedContact, true);
      if (
        addressJsonMap.containsKey('addresses') &&
        !((List<Object>) addressJsonMap.get('addresses')).isEmpty()
      ) {
        upsertAddressBook(
          updatedContact.Id,
          contactRecord.AccountId,
          (List<Object>) addressJsonMap.get('addresses')
        );
      }

      return true;
    } catch (Exception e) {
      logger.error(
        'SCCContactRefreshComponentController.syncContact',
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
    Id accId,
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
      for (Object obj : addressJsonMap) {
        Map<String, Object> tempMap = (Map<String, Object>) obj;
        Address__c record = (Address__c) SCCUtilityClass.initializeObject(
          tempMap,
          'Address__c',
          addressFieldMappings,
          logger
        );
        Address__c address = SCCUtilityClass.getContactAddress(
          String.valueOf(tempMap.get('address_id')),
          null,
          accId
        );

        system.debug('**address**' + address);
        if (address != null && address.Id != null) {
          record.Id = address.Id;
        }
        record.Contact__c = recordId;
        record.Account__c = accId;
        record.from_SFCC__c = true;
        contactAddressList.add(record);
      }
      if (contactAddressList.size() > 0) {
        Database.upsert(contactAddressList);
      } else {
        throw new JSONException('Contact Address List is empty');
      }
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
    Contact con
  ) {
    system.debug('###patchDataMap ' + patchDataMap);

    SCCFileLogger logger = SCCFileLogger.getInstance();

    Map<String, Object> jsonObjMap;
    Boolean result = false;
    try {
      jsonObjMap = SCCJsonUtil.initializeJsonObject(
        patchDataMap,
        'Contact',
        logger
      );
      // Added Code starting for WME-111
      string provalue ='';
      for(string key: jsonObjMap.keySet()){
        if(key.toLowerCase()=='c_wmProTier'){
          string value = jsonObjMap.get(key).toString();
          if(value == 'BRNZ'){
              provalue = 'Pro';
          }
          if(value == 'SILV'){
             provalue='Pro Plus';
          }
          if(value == 'GOLD'){
            provalue='Pro Platinum';
          }
          break;
        }
      }
      jsonObjMap.put('c_wmProTier',provalue);
      // Added code ending for WME-111
      String body = (String) System.JSON.serialize(jsonObjMap);
      logger.debug(
        'SCCContactImpl.patchCustProfile',
        'Profile Patch request body: ' + body
      );
      if (body != '' && body != null && con.SFCC_Customer_Number__c != null) {
        patchCustProfileCallOut(body, con.SFCC_Customer_Number__c);
        result = true;
      } else {
        result = false;
        throw new JSONException('Request payload is empty');
      }
    } catch (Exception e) {
      logger.error(
        'SCCContactImpl.patchCustProfile',
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
  /**
   * This method is wrapper method to call webservice asynchronously.
   * @param patchDataMap: Map<String, Object>
   * @return Boolean.
   */
  @future(callout=true)
  public static void patchCustProfileCallOut(String body, String customerNo) {
    system.debug('###Body ' + body);
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

  public static Boolean postCustProfile(
    Map<String, Object> postDataMap,
    Contact con
  ) {
    SCCFileLogger logger = SCCFileLogger.getInstance();

    Map<String, Object> jsonObjMap;
    Boolean result = false;
    try {
      jsonObjMap = SCCJsonUtil.initializeJsonObject(
        postDataMap,
        'Contact',
        logger
      );
      String body = (String) System.JSON.serialize(jsonObjMap);
      logger.debug(
        'SCCContactImpl.postCustProfile',
        'Profile Post request body: ' + body
      );
      if (body != null && body != '') {
        postCustProfileCallOut(body);
        result = true;
      } else {
        result = false;
        throw new JSONException('Request payload empty');
      }
    } catch (Exception e) {
      logger.error(
        'SCCContactImpl.postCustProfile',
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

  public static Boolean putCustProfile(Contact con) {
    SCCFileLogger logger = SCCFileLogger.getInstance();
    Boolean result = false;
    String customerNo = con.SFCC_Customer_Number__c != null
      ? con.SFCC_Customer_Number__c
      : 'SFSC' + con.Id;

    try {
      String body = SCCSyncCustomerContactHelper.generateCustomerPayload(con);

      logger.debug(
        'SCCContactImpl.putCustProfile',
        'Profile Post request body: ' + body
      );
      System.debug(
        'Calling -> putCustProfileCallOut with body: ' +
        body +
        ' customerNo: ' +
        customerNo
      );
      if (body != '') {
        putCustProfileCallOut(body, customerNo, con.AccountId);
        result = true;
      } else {
        result = false;
        throw new JSONException('Request payload is empty');
      }
    } catch (Exception e) {
      logger.error(
        'SCCContactImpl.putCustProfile',
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
  public static void putCustProfileCallOut(
    String body,
    String customerNo,
    Id accId
  ) {
    SCCFileLogger logger = SCCFileLogger.getInstance();
    try {
      SCCCommerceCloudConnect.logger = logger;
      HttpResponse resp = SCCCommerceCloudConnect.putCCCustomerProfile(
        body,
        customerNo,
        SCCCommerceCloudConnect.connectToCommerceCloud2ProfileOperations(),
        accId
      );

      System.debug('putCustProfileCallOut response: ' + resp);
    } catch (Exception e) {
      logger.error(
        'SCCAccountImpl.putCustProfileCallOut',
        'Exception message : ' +
        e.getMessage() +
        ' StackTrack ' +
        e.getStackTraceString()
      );
    } finally {
      logger.flush();
    }
  }
}