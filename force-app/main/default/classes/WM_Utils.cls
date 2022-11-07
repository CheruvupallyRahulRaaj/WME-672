/**
* @description       : Utility class for accessing frequently used functions
* @author            : schauhan@liveareacx.com
* @group             : 
* @last modified on  : 08-09-2022
* @last modified by  : Manohar.Alla@genzeon.com
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   01-07-2021   schauhan@liveareacx.com              Initial Version
* 2.0   08-09-2022   Manohar.Alla@genzeon.com             Second Version, WME-274 story related updates
**/
public class WM_Utils{
    
    public static String getString(Object obj){
        if(obj!=null){
            return String.valueOf(obj);
        }
        else{
            return null;
        }
    }
    public static String getStringOrReturnEmptyString(Object obj){
        if(obj!=null){
            return String.valueOf(obj);
        }
        else{
            return '';
        }
    }
    
    public static String getStringForDateTime (Object obj){
        if(obj!=null){
             Datetime dt = Datetime.valueOf(obj);
             String dtPST = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'SSS', 'PST');
            return dtPST;
        }
        else{
            return null;
        }
        
        
    }

    public static String getStringForDateTimeNoTimeZone (Object obj){
        if(obj!=null){
             Datetime dt = Datetime.valueOf(obj);
             String dtStr = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'SSS','UTC');
            return dtStr;
        }
        else{
            return null;
        }
        
        
    }
    
    public static String maintainTheTimeZone(Date dt){
        Integer d = dt.day();
        Integer mo = dt.month();
        Integer yr = dt.year();
        
        DateTime convertDT = DateTime.newInstance(yr, mo, d,11, 59, 59);
        return  Datetime.valueOf(convertDT).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'SSS');    
    }
    
    public static Double getDouble(Object obj){
        if(obj!=null){
            return Double.valueOf(obj);
        }
        else{
            return null;
        }
    }
    public static Integer getInteger(Object obj){
        if(obj!=null){
            return Integer.valueOf(obj);
        }
        else{
            return null;
        }
    }
    
    public static String getCurrentTimeString() {
        DateTime nowDate = system.now();
        String currentHour = String.valueOf(nowDate.hour());
        if(currentHour.length() == 1) { currentHour = '0' + currentHour; }
        String currentMinute = String.valueOf(nowDate.minute());
        if(currentMinute.length() == 1) { currentMinute = '0' + currentMinute; }
        String currentSecond = String.valueOf(nowDate.second());
        if(currentSecond.length() == 1) { currentSecond = '0' + currentSecond; }
        String timeString = currentHour + currentMinute + currentSecond;
        return timeString;
    }
    
    public static String getCurrentDateString() {
        Date todayDate = system.today();
        String dateString = '';
        String monthString = String.valueOf(todayDate.month());
        if(monthString.length() == 1) { monthString = '0' + monthString; }
        String dayString = String.valueOf(todayDate.day());
        if(dayString.length() == 1) { dayString = '0' + dayString; }
        String yearString = String.valueOf(todayDate.year());
        dateString = monthString + dayString + yearString;
        return dateString;
    }
    public static String getCurrentDate() {
        String dateString = '';
        Datetime todayDate = Datetime.now();
        String strConvertedDate = todayDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'SSS','UTC');
        dateString = strConvertedDate;
        return dateString;
    }
    // Story: WME-274 Developer: Manohar Alla Change: New method to check current account has a childAccounts or not
    public static boolean checkchildAccounts(string  parentaccId){
        boolean check = false;
        list<Account> acc = [select  id, Parent_Bill_To__c  from Account  where  parentId =:ParentaccId limit 1];
        if(!acc.isEmpty()){
            check = true;
        }
        return check;
    }
    

    // Story: WME-274 Developer: Manohar Alla Change: New method to check childAccounts and fetch the parent record id
    public static string getParenTID(string  accId){
        string  parentId;
        list<Account> acc = [select  id ,parentId from Account  where  Id =:accId];
        if(!acc.isEmpty()){
            parentId=acc[0].parentId;
        }
        return parentId;
    }

    // Story: WME-274 Developer: Manohar Alla Change: Method returns the account and input parameters are account Id
    public static Account getParentAccount(string childAccountId){
        List<Account> lstAccounts =  [
            SELECT 
                Id,
                ParentId,
                AccountNumber 
            FROM Account 
            WHERE Id = :childAccountId
        ];
        if(lstAccounts.size()>0){
            return lstAccounts[0];
        }
        else{
            return null;
        }
    }

    // Story: WME-274 Developer: Manohar Alla Change: Method returns the account and input parameters are account Id
    public static Account getChildAccount(string  parentAccountId){
        Account childAccount = null;
        List<Account> lstChildAccounts = [
            SELECT 
                Id,
                AccountNumber,
                Name
            FROM 
                Account 
            WHERE 
                ParentId =:parentAccountId 
                AND 
                SCCActive__c = TRUE
            LIMIT 1
        ];
        if(lstChildAccounts!=null && !lstChildAccounts.isEmpty()){
            childAccount = lstChildAccounts[0];
        }
        return childAccount;
    }

}