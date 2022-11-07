public with sharing class SCCSyncCustomerContactHelper {
  public SCCSyncCustomerContactHelper() {
  }

  public static String generateCustomerPayload(Contact con) {
    Contact conData = new Contact();

    Id conId = con.Id;
    String soql =
      ' SELECT Id, Email, Phone, ActiveContact__c, FirstName, LastName, Account.Name, Account.Id, ' +
      ' Account.Parent.AccountNumber, Account.AccountNumber, Account.Cust_Payment_Class__c, ' +
      ' Account.wmProPORequired__c, Account.wmProTier_c__c, SFCC_Customer_Id__c ' +
      ' From Contact ' +
      ' Where Id = : conId ';
    try {
      conData = Database.query(soql);
    } catch (Exception ex) {
      System.debug('Contact query failed with: ' + ex.getMessage());
      conData = null;
    }

    JSONGenerator gen = JSON.createGenerator(true);

    if (conData != null) {
      Id accId = conData.AccountId;

      System.debug('Contact Data: ' + conData);

      gen.writeStartObject();
      gen.writeFieldName('credentials');
      gen.writeStartObject();
      gen.writeStringField('login', conData.Email);
      gen.writeBooleanField('enabled', conData.ActiveContact__c ? true : false);
      gen.writeEndObject();
      gen.writeStringField(
        'first_name',
        conData.FirstName != null ? conData.FirstName : ''
      );
      gen.writeStringField(
        'last_name',
        conData.LastName != null ? conData.LastName : ''
      );

      gen.writeStringField('email', conData.Email != null ? conData.Email : '');

      gen.writeStringField(
        'phone_business',
        conData.Phone != null ? conData.Phone : ''
      );

      gen.writeBooleanField(
        'c_activeCustomer',
        conData.ActiveContact__c ? true : false
      );
      gen.writeBooleanField('c_isPro', true);

      gen.writeStringField(
        'company_name',
        conData.Account != null ? conData.Account.Name : ''
      );
      if (conData.Account != null) {
        gen.writeStringField(
          'c_wmDisplayAccountNumber',
          conData.Account.AccountNumber != null
            ? conData.Account.AccountNumber
            : ''
        );

        gen.writeStringField(
          'c_proCustomerClass',
          conData.Account.Cust_Payment_Class__c != null
            ? conData.Account.Cust_Payment_Class__c
            : ''
        );

        gen.writeBooleanField(
          'c_wmProPORequired',
          conData.Account.wmProPORequired__c
        );

        gen.writeStringField(
          'c__wmDisplayAccountNumber',
          conData.Account.AccountNumber != null
            ? conData.Account.AccountNumber
            : ''
        );

        gen.writeStringField(
          'c_wmAccountNumber',
          conData.Account.Parent != null &&
            conData.Account.Parent.AccountNumber != null
            ? conData.Account.Parent.AccountNumber
            : conData.Account.AccountNumber
        );

        if (
          conData.Account.wmProTier_c__c != null &&
          conData.Account.wmProTier_c__c.toLowerCase() == 'gold'
        ) {
          gen.writeStringField('c_wmProTier', 'Pro Platinum');
        } else if (
          conData.Account.wmProTier_c__c != null &&
          conData.Account.wmProTier_c__c.toLowerCase() == 'silv'
        ) {
          gen.writeStringField('c_wmProTier', 'Pro Plus');
        } else if (
          conData.Account.wmProTier_c__c != null &&
          conData.Account.wmProTier_c__c.toLowerCase() == 'brnz'
        ) {
          gen.writeStringField('c_wmProTier', 'Pro');
        }
      }
      gen.writeBooleanField('c_wmPOStatus', true);

      if (
        conData.SFCC_Customer_Id__c != null &&
        conData.SFCC_Customer_Id__c != ''
      ) {
        gen.writeStringField('c_sscSyncStatus', 'exported');
      }

      gen.writeEndObject();

      return gen.getAsString();
    }
    return '';
  }

  public static Boolean syncContactAddressData(Id accId) {
    //Id accId = con.AccountId;
    List<Address__c> lsAddress = new List<Address__c>();
    SCCFileLogger logger = SCCFileLogger.getInstance();
    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Address__c.fields.getMap();
    Boolean result = false;
    String agentAccessToken = SCCCommerceCloudConnect.connectToCommerceCloudViaAccessKey();
    List<String> custIds = new List<String>();

    String addrSoql =
      ' Select Id, Name, Salutation__c, Suffix__c, wmPreferredAddress__c, First_Name__c, Last_Name__c, Second_Name__c, Account__c, Contact__c, MailCodeDesc__c, ' +
      ' Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Line_4__c, Post_Box__c, City__c, Postal_Code__c, State__c, MailCode__c, csh_van_route_seq__c, ' +
      ' Full_Name__c,  Phone__c, ActiveAddress__c, Reserve_Location_Name__c, csh_van_route__c, EmailAddress__c, ReserveLocation__c, cst_reserve_whs__c, ' +
      ' from_SFCC__c, OwnerId, IsDeleted, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LimitFlag__c, ExternalReference__c, ' +
      ' Account__r.SFCC_Customer_Number__pc, Account__r.SFCC_Customer_Id__pc, Country__c, Account__r.IsPersonAccount, Account__r.Id ' +
      ' From Address__c ' +
      ' Where Account__c = :accId AND ActiveAddress__c = true AND IsDeleted = false' +
      ' Order By wmPreferredAddress__c, ActiveAddress__c Desc ';

    try {
      lsAddress = Database.query(addrSoql);
    } catch (Exception ex) {
      System.debug('Address fetch  failed with: ' + ex.getMessage());
    }

    for (Contact con : [
      SELECT SFCC_Customer_Id__c, Id
      FROM Contact
      WHERE AccountId = :accId
    ]) {
      custIds.add(con.SFCC_Customer_Id__c);
    }

    for (Integer i = 0; i < lsAddress.size(); i++) {
      Map<String, Object> postDataMap = new Map<String, Object>();

      Address__c newAdd = lsAddress.get(i);
      // this is avoid calling SFCC when updated by webservice from CC.
      if (!newAdd.from_SFCC__c) {
        for (String str : fieldMap.keyset()) {
          postDataMap.put(str, newAdd.get(str));
        }
        if (!postDataMap.isEmpty()) {
          Map<String, Object> jsonObjMap = SCCJsonUtil.initializeJsonObject(
            postDataMap,
            'Address__c',
            logger
          );

          system.debug('JSONOBJMap ' + jsonObjMap);
          String body = (String) System.JSON.serialize(jsonObjMap);
          system.debug('Body  ' + jsonObjMap);

          try {
            SCCCommerceCloudConnect.postAddressDetails(
              body,
              custIds,
              agentAccessToken
            );
            result = true;
          } catch (Exception e) {
            system.debug('Exception occured while posting address' + e);
          }
        }
      }
      //newAdd.from_SFCC__c = false;
    }

    return result;
  }
}