@isTest
private class SyncAccountBillingAddressTest {
    @testSetup
    private static void createTestData() {
        Account acc = TestDataFactory.createAccountRecord();
        Address__c add = TestDataFactory.createAddress(acc.ID);
    }
    
	private static testMethod void test1() {
        Address__c add = [SELECT Id, wmPreferredAddress__c,Address_Line_1__c FROM Address__c LIMIT 1];
        add.wmPreferredAddress__c = true;
        add.Address_Line_1__c = 'Test1';
        add.from_SFCC__c =  false;
        update add;
	}
}