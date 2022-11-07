@RestResource(urlMapping='/taxExemption/*')
global with sharing class TaxExemptionController {
    @httpGet
    global static void doGetMethod(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        // Account acc= new Account();
        Map<String,String> paramsMap = RestContext.request.params;
        String accNum = paramsMap.get('AccountNumber');
        system.debug('Account Number '+accNum);
        Account accnt = [select id,AccountNumber,wmProTier_c__c,cst_tax_exempt__c,taxState__c,cst_tax_expiration_date__c,cst_tax_code__c,associatePriceBooks__c,proPriceBooks__c,Associate__c  from account where AccountNumber =:accNum limit 1];
        //Tax_Exemption__c TaxExm = [select id,State__c,Global_Exemption__c from Tax_Exemption__c where AccountId__c =: acc.id];
        Boolean taxEmptVar = false;
        Set<String> setOfStates = new Set<String>();
        List<Tax_Exemption__c> TaxExmList = [select id,State__c,Global_Exemption__c,Expiration_Date__c from Tax_Exemption__c where AccountId__c =: accnt.id];
        for (Tax_Exemption__c t: TaxExmList){
            
            if(t.Expiration_Date__c > system.today()){
           
                taxEmptVar = true;
                if(!t.Global_Exemption__c){
                    setOfStates.add(t.State__c);
                }
            }
            
        }
        SFCCConfiguration__c SFCCConfiguration = [SELECT Id,AssociatePriceBook__c, GOLDPriceBook__c, name, BRNZPriceBook__c,SILVPriceBook__c FROM SFCCConfiguration__c];
        List<String> listOfAssociatePriceBooks = new List<String>();
        List<String> listOfProPriceBooks = new List<String>();
        
        if(accnt.proPriceBooks__c!=null){
            listOfProPriceBooks = accnt.proPriceBooks__c.split('[|]');  
            for (Integer i = 0; i < listOfProPriceBooks.size(); i++) {
                if (listOfProPriceBooks.get(i).equals('')) {
                    listOfProPriceBooks.remove(i);
                    i--; 
                }
            }
        }
        
        //Add configured associate pricebook to associate list
        if (accnt.Associate__c && SFCCConfiguration.AssociatePriceBook__c != null) {
            listOfAssociatePriceBooks.add(SFCCConfiguration.AssociatePriceBook__c);
        }

        //Add configured pro pricebook to pro list 
        if(accnt.wmProTier_c__c == 'BRNZ' && SFCCConfiguration.BRNZPriceBook__c!=null) {
            listOfProPriceBooks.add(SFCCConfiguration.BRNZPriceBook__c); 
        }
        if(accnt.wmProTier_c__c == 'SILV' && SFCCConfiguration.SILVPriceBook__c!=null) {
            listOfProPriceBooks.add(SFCCConfiguration.SILVPriceBook__c); 
        }
        if(accnt.wmProTier_c__c == 'GOLD' && SFCCConfiguration.GOLDPriceBook__c!=null) {
            listOfProPriceBooks.add(SFCCConfiguration.GOLDPriceBook__c); 
        }

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        gen.writeBooleanField('taxExempt', taxEmptVar);
        if(taxEmptVar && setOfStates!=null){
            gen.writeFieldName('taxState');
              gen.writeStartArray();
            
            for(String st:setOfStates){
                 gen.writeStartObject();
                 gen.writeStringField('state', st);
                 gen.writeEndObject();
            }
           gen.writeEndArray();
           
        }     
        if(listOfAssociatePriceBooks.size()>0){
              gen.writeFieldName('associatePriceBooks');
              gen.writeStartArray();
            
            for(String aP:listOfAssociatePriceBooks){
                 gen.writeStartObject();
                 gen.writeStringField('associatePriceBook', aP);
                 gen.writeEndObject();
            }
           gen.writeEndArray();
        }
        if(listOfProPriceBooks.size()>0){
              gen.writeFieldName('proPriceBooks');
              gen.writeStartArray();
            
            for(String pPro:listOfProPriceBooks){
                 gen.writeStartObject();
                 gen.writeStringField('proPriceBook', pPro);
                 gen.writeEndObject();
            }
           gen.writeEndArray();
        }      
        gen.writeEndObject();
        String payload = gen.getAsString();
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueof(payLoad);		
    }
}