public with sharing class SCCSyncContactAddressQ implements Queueable, Database.AllowsCallouts {
  private Id accountId;
  public SCCSyncContactAddressQ(Id accId) {
    this.accountId = accId;
  }

  public void execute(System.QueueableContext qc) {
    Boolean addrSyncResult = SCCSyncCustomerContactHelper.syncContactAddressData(
      accountId
    );
  }
}