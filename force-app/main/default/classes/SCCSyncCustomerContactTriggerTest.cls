@isTest
private class SCCSyncCustomerContactTriggerTest {
	private static testMethod void test1() {
	    Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Last name',
            IndividualNumber__c = 123,
            SFCC_update__c = true,
            Test_Context__c = true
        );
        insert con;
        
        con.SFCC_update__c = false;
        con.FirstName = 'Test 123';
        update con;
	}
	
}