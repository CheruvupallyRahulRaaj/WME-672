trigger InvoiceAutoNumber on Invoice (before insert) {
 List<JDAInvoiceCreditNumber__c> InvCreNumList = new List<JDAInvoiceCreditNumber__c>();

    for(Invoice Inv:trigger.new)
    {
       JDAInvoiceCreditNumber__c InvCreNum = new JDAInvoiceCreditNumber__c ();      
       InvCreNumList.add(InvCreNum);      
    }

    insert InvCreNumList;
    for(Integer i=0;i<trigger.new.size();i++){
        trigger.new.get(i).InvoiceName__c = InvCreNumList.get(i).Id;
    }
}