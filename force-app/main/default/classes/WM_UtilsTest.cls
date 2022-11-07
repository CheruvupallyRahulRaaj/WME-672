/**
* @description       :  test class for WM_Utils
* @author            :  Manohar.Alla@genzeon.com
* @last modified on  :  12-09-2022
* @last modified by  :  Manohar.Alla@genzeon.com
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   12-09-2022   Manohar.Alla@genzeon.com             Initial Version
**/

@istest
public with sharing class WM_UtilsTest {
   
    /* public static id accid;
    @TestSetup
      static void makeData(){
      accid = SCCTestDataFactory.createAccountPro();
    }*/
    
    @istest
      public static void Testmethod1(){
      id   accid = SCCTestDataFactory.createAccountPro();
      account  a =[select  id,createdDate,wmVanRouteseq__c,name ,Email__c ,LastModifiedDate from Account  where  id =:accid limit 1];
        a.wmVanRouteseq__c=11;
        update a;
      
      string accname= WM_Utils.getString(a.name);
      string accname1=  WM_Utils.getStringOrReturnEmptyString(a.name);
      WM_Utils.getStringForDateTime(a.LastModifiedDate);
      WM_Utils.getStringForDateTimeNoTimeZone(a.LastModifiedDate);
      
      DateTime dt = System.now();
      Date d = Date.newInstance(dt.year(), dt.month(), dt.day());
      WM_Utils.maintainTheTimeZone(d);
      WM_Utils.getDouble(a.wmVanRouteseq__c);
      WM_Utils.getInteger(a.wmVanRouteseq__c);
      WM_Utils.getCurrentTimeString();
      WM_Utils.getCurrentDateString();
      WM_Utils.getCurrentDate();
      
      boolean b =  WM_Utils.checkchildAccounts(a.id);
      WM_Utils.getParenTID(a.id);
      system.assertEquals(a.name,accname);
      system.assertEquals(a.name,accname1);
      system.assertEquals(b,false);
    }

}