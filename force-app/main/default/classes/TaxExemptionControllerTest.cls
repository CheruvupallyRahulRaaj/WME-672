@isTest
public class TaxExemptionControllerTest {
    
    @testSetup 
    static void testData() 
    {
        //List<Account> acc4 = new List<Account>();
        Account Acc = new Account();
        Acc.Name = 'Naveen';
        Acc.AccountNumber = '10416913';
        Acc.cst_tax_exempt__c = true; 
        // Acc.cst_tax_expiration_date__c = Date.valueOf('2021-06-11');
        Acc.associatePriceBooks__c = 'Naveen';
        Acc.proPriceBooks__c = 'Naveen';
        Acc.wmProTier_c__c = 'BRNZ';
        //Acc.wmProTier_c__c = 'GOLD';
        //Acc.wmProTier_c__c = 'SILV';
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test());
        insert Acc;
        //acc4.add(Acc);
        
        
        
        Account Acc1 = new Account();
        Acc1.Name = 'Naveen';
        Acc1.AccountNumber = '104169133';
        Acc1.cst_tax_exempt__c = True; 
        // Acc.cst_tax_expiration_date__c = Date.valueOf('2021-06-11');
        Acc1.associatePriceBooks__c = 'Naveen';
        Acc1.proPriceBooks__c = 'Naveen';
        Acc1.wmProTier_c__c = 'GOLD';
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test());
        insert Acc1;
        
        Account Acc2 = new Account();
        Acc2.Name = 'Naveen';
        Acc2.AccountNumber = '104169132';
        Acc2.cst_tax_exempt__c = True; 
        // Acc.cst_tax_expiration_date__c = Date.valueOf('2021-06-11');
        Acc2.associatePriceBooks__c = 'Naveen';
        Acc2.proPriceBooks__c = 'Naveen';
        Acc2.wmProTier_c__c = 'SILV';
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test());
        insert Acc2;
        
        Account Acc3 = new Account();
        Acc3.Name = 'Naveen';
        Acc3.AccountNumber = '104169133';
        Acc3.cst_tax_exempt__c = True; 
        // Acc.cst_tax_expiration_date__c = Date.valueOf('2021-06-11');
        Acc3.associatePriceBooks__c = 'Naveen';
      
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test());
        insert Acc3;
        
         
        Tax_Exemption__c  TaxExm = new Tax_Exemption__c();
        //TaxExm.State__c = 'Washington DC';
        TaxExm.Country__c = 'US';
        taxexm.AccountId__c = Acc.id;
        TaxExm.Name = 'Naveen';
        TaxExm.Exemption_Certificate__c = '111';
        TaxExm.Exemption_Type__c = 'T';
        TaxExm.Expiration_Date__c = Date.today().addDays(+1);	
        TaxExm.State__c = 'DC';
       
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test());
        insert TaxExm;
        
        Tax_Exemption__c  TaxExm1 = new Tax_Exemption__c();
        TaxExm1.Country__c = 'US';
        TaxExm1.Name = 'Naveen';
        TaxExm1.Exemption_Certificate__c = '111';
        TaxExm1.Exemption_Type__c = 'T';
        TaxExm1.Expiration_Date__c = Date.valueOf('2022-06-11');		
        TaxExm1.Global_Exemption__c = false;
        TaxExm1.State__c = 'AL';
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test());
        insert TaxExm1;
        
         /*Tax_Exemption__c  TaxExm2 = new Tax_Exemption__c();
     
        TaxExm2.Name = 'Naveen';
         Account accnt = [select id,AccountNumber,wmProTier_c__c,cst_tax_exempt__c,taxState__c,cst_tax_expiration_date__c,cst_tax_code__c,associatePriceBooks__c,proPriceBooks__c,Associate__c  from account where AccountNumber =:Acc1.AccountNumber limit 1];
        system.debug('##Account number' + Acc1.AccountNumber);
        Tax_Exemption__c TaxExmL = [select id,State__c,Global_Exemption__c,Expiration_Date__c from Tax_Exemption__c limit 1];
        TaxExm2.Expiration_Date__c = System.today() + 5;	
        TaxExm2.Country__c = 'US';
        TaxExm2.Exemption_Type__c = 'T';
        TaxExm2.Global_Exemption__c = false;
        TaxExm2.State__c = TaxExmL.State__c;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test());
        insert TaxExm2;*/
        
        WM_WebServiceDetails__c custsetting = new WM_WebServiceDetails__c();
        custsetting.Name = 'CRMService';
        custsetting.WM_ApiKey__c = 'WM_ApiKey__c';
        insert custsetting;
        SFCCConfiguration__c cs = new SFCCConfiguration__c();
        cs.Name='test';
        cs.Time__c = 1;
        cs.BRNZPriceBook__c = 'BRNZ';
        cs.SILVPriceBook__c = 'SILV';
        cs.GOLDPriceBook__c = 'GOLD';
        cs.AssociatePriceBook__c = 'wm-associate';
        //cs.Other fiels values
        insert cs;
        
    }
    @isTest
    static  void testdoGetMethod() {
        Account acc = [SELECT Id, AccountNumber FROM Account limit 1];
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/taxExemption/';
        req.httpMethod = 'GET';
        req.addParameter('AccountNumber', '10416913');
        RestContext.request = req;
        RestContext.response= res;
        test.starttest();
        TaxExemptionController.doGetMethod();
        test.stopTest();
        
        
    }
    @isTest
    static  void testdoGetMethod2() {
         Account acc = [SELECT Id, AccountNumber FROM Account limit 1];
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/taxExemption/';
        req.httpMethod = 'GET';
        req.addParameter('AccountNumber', '104169133');
        RestContext.request = req;
        RestContext.response= res;
        test.starttest();
        TaxExemptionController.doGetMethod();
        test.stopTest();
        
        
    }
    @isTest
    static  void testdoGetMethod3() {
         Account acc = [SELECT Id, AccountNumber FROM Account limit 1];
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/taxExemption/';
        req.httpMethod = 'GET';
        req.addParameter('AccountNumber', '104169132');
        RestContext.request = req;
        RestContext.response= res;
        test.starttest();
        TaxExemptionController.doGetMethod();
        test.stopTest();
        
        
    }
}