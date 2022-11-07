@isTest
private class WM_FullstoryTest {
    @isTest static void test_getEnabled_positive() {
        WM_Tools_Configuration__c config = new WM_Tools_Configuration__c();
        config.Name = 'Fullstory';
        config.Enabled__c = true;
        insert config;
        System.assert(WM_Fullstory.getEnabled() == true, 'enable should be true');
    }

    @isTest static void test_getEnabled_default() {
        System.assert(WM_Fullstory.getEnabled() == false, 'enable should be false');
    }

    @isTest static void test_getChannelName_positive() {
        SalesChannel channel = new SalesChannel();
        channel.SalesChannelName = 'WestMarine';
        insert channel;
        System.assert(WM_Fullstory.getChannelName(channel.Id) == 'WestMarine', 'channel name should be WestMarine');
    }

    @isTest static void test_getChannelName_negative() {
        Boolean hasException = false;
        SalesChannel channel = new SalesChannel();
        channel.SalesChannelName = 'WestMarine';
        insert channel;
        try {
            WM_Fullstory.getChannelName('');
        } catch (QueryException e) {
            hasException = true;
        }
        System.assert(hasException, 'An exception was not thrown');
    }

    @isTest static void test_getSessions_positive_wm() {
        Test.setMock(HttpCalloutMock.class, new WM_FullstoryMockHttpResponseGenerator());
        String body = WM_FullStory.getSessions('WestMarine', 'test@westmarine.com');
        System.assert(body != '', 'response body is empty');
    }

    @isTest static void test_getSessions_positive_wmp() {
        Test.setMock(HttpCalloutMock.class, new WM_FullstoryMockHttpResponseGenerator());
        String body = WM_FullStory.getSessions('WestMarinePro', 'test@westmarine.com');
        System.assert(body != '', 'response body is empty');
    }

    @isTest static void test_getSessions_negative_channel() {
        Boolean hasException = false;
        Test.setMock(HttpCalloutMock.class, new WM_FullstoryMockHttpResponseGenerator());
        try {
            WM_FullStory.getSessions('', 'test@westmarine.com');
        } catch (CalloutException e) {
            hasException = true;
        }
        System.assert(hasException, 'An exception was not thrown');
    }

    @isTest static void test_getSessions_negative_email() {
        Boolean hasException = false;
        Test.setMock(HttpCalloutMock.class, new WM_FullstoryMockHttpResponseGenerator());
        try {
            WM_FullStory.getSessions('WestMarine', '');
        } catch (CalloutException e) {
            hasException = true;
        }
        System.assert(hasException, 'An exception was not thrown');
    }
}