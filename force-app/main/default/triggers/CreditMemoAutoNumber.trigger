trigger CreditMemoAutoNumber on CreditMemo (before insert) {
 List<JDAInvoiceCreditNumber__c> InvCreNumList = new List<JDAInvoiceCreditNumber__c>();

    for(CreditMemo credMemo:trigger.new)
    {
       JDAInvoiceCreditNumber__c InvCreNum = new JDAInvoiceCreditNumber__c ();      
       InvCreNumList.add(InvCreNum);      
    }

    insert InvCreNumList;
    for(Integer i=0;i<trigger.new.size();i++){
        trigger.new.get(i).JDAInvoiceCreditNumber__c  = InvCreNumList.get(i).Id;
    }
}