@isTest(SeeAllData=true)
public class FilteredLocationsTest { 
    static testmethod void test1() {

        Schema.Location locatn= TestDataFactory.createLocation();
       
        List<String> locationIds = new List<String>();
        String locations = [SELECT
                            Id,
                            Name,
                            LocationType,
                            Latitude,
                            Longitude,
                            Location,
                            Description,
                            DrivingDirections,
                            TimeZone,
                            ParentLocationId,
                            PossessionDate,
                            ConstructionStartDate,
                            ConstructionEndDate,
                            OpenDate,
                            CloseDate,
                            RemodelStartDate,
                            RemodelEndDate,
                            IsMobile,
                            IsInventoryLocation,
                            VisitorAddressId,
                            RootLocationId,
                            LocationLevel,
                            ExternalReference,
                            ShouldSyncWithOci,
                            LogoId,
                            preferredShipComplete__c,
                            District__c,
                            Region__c,
                            Phone__c,
                            Address__c,
                            State__c,
                            Zip_Postal_Code__c,
                            City__c,
                            FedEx_Shipping_Preference__c,
                            UPS_Shipping_Preference__c,
                            DHL_Shipping_Preference__c
                            FROM Location
                           
                            limit 1].Id;
        Test.startTest();  
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<String> temp = new List<String>{locations};
            FilteredLocations.getFulFilledLocations(new List<List<String>>{temp});
        Test.stopTest();
    }
}