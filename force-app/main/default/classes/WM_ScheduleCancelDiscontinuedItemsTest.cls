@IsTest(SeeAllData=true)
public with sharing class WM_ScheduleCancelDiscontinuedItemsTest{
        
        static testMethod void reEvaluateFlw2() {
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new MockHttpResponseGenerator() );
        WM_ScheduleCancelDiscontinuedItems myClass8 = new WM_ScheduleCancelDiscontinuedItems();   
        String chron = '0 0 0 * * ?';        
        System.schedule('WM_ScheduleCancelDiscontinuedItems2', chron, myClass8);
        Test.stopTest();

    }
}