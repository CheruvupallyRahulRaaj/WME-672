@isTest
private class WM_LocationCappingScheduledTest {
    @isTest static void testSetLocationCappingAttributes() {
		schema.Location warehouse13 = new schema.Location();
        warehouse13.ExternalReference = '13';
        warehouse13.Name = '13';
        warehouse13.ProThreshold__c = 1;
        warehouse13.RetailThreshold__c = 1;
        insert warehouse13;
        
        WM_LocationCappingScheduled cappingScheduled = new WM_LocationCappingScheduled();
        cappingScheduled.setLocationCappingAttributes();
        
        Schema.Location testWarehouse13 = [select ReachedMaximumRetail__c, ReachedMaximumPro__c from Location where Id = :warehouse13.Id];
        System.assert(testWarehouse13.ReachedMaximumRetail__c == FALSE, 'Retail should be false');
        System.assert(testWarehouse13.ReachedMaximumPro__c == FALSE, 'Pro should be false');
    }
}