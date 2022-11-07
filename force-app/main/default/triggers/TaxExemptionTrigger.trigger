trigger TaxExemptionTrigger on Tax_Exemption__c (after insert,after update) {
    List<Id> accountIds = new List<Id>();
    for(Tax_Exemption__c tx:Trigger.new){
        accountIds.add(tx.AccountId__c);
    }
    if(!Test.isRunningTest() && accountIds.size()>0){

                            System.debug('8. handlingChunkSize Action Type: C');
                          WM_CRMIntegrationProcessor.handlingTheChunkSizeLogic(accountIds,'C');   
                        }
}