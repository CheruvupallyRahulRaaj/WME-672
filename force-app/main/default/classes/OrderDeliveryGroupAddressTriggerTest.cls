@isTest(SeeAllData=true)  
private class OrderDeliveryGroupAddressTriggerTest {
    static testMethod void testGoolgeAPI() {
        Account testAccount = new Account(
            Name = 'Buster'
        );
        insert testAccount;
    
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
        insert testOrder;
    
        OrderDeliveryGroup testOrderDelivery = new OrderDeliveryGroup(
            DeliverToCity = 'Lemont',
            DeliverToStreet = '12876 Rosa Lane',
            DeliverToName = 'Test',
            OrderId = testOrder.Id
        );
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
           insert testOrderDelivery;
        Test.stopTest();
        
        OrderDeliveryGroup verifyOrderDeliveryGroup = [
            SELECT Id, DeliverToLatitude, DeliverToLongitude 
            FROM OrderDeliveryGroup
            WHERE Id = :testOrderDelivery.Id
        ];
   
       // System.assertEquals(38.436710, verifyOrderDeliveryGroup.DeliverToLatitude);
        //System.assertEquals(-89.908210, verifyOrderDeliveryGroup.DeliverToLongitude);
        
    }
    
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
           res.setHeader('Content-Type', 'application/json');
           
            res.setBody(
                '{' + 
                '   "results" : [' + 
                '      {' + 
                '         "address_components" : [' + 
                '            {' + 
                '               "long_name" : "12876",' + 
                '               "short_name" : "12876",' + 
                '               "types" : [ "street_number" ]' + 
                '            },' + 
                '            {' + 
                '               "long_name" : "Rosa Lane",' + 
                '               "short_name" : "Rosa Lane",' + 
                '               "types" : [ "route" ]' + 
                '            },' + 
                '            {' + 
                '               "long_name" : "Lemont",' + 
                '               "short_name" : "Lemont",' + 
                '               "types" : [ "locality", "political" ]' + 
                '            },' + 
                '            {' + 
                '               "long_name" : "Cook County",' + 
                '               "short_name" : "Cook County",' + 
                '               "types" : [ "administrative_area_level_2", "political" ]' + 
                '            },' + 
                '            {' + 
                '               "long_name" : "Illinios",' + 
                '               "short_name" : "IL",' + 
                '               "types" : [ "administrative_area_level_1", "political" ]' + 
                '            },' + 
                '            {' + 
                '               "long_name" : "United States",' + 
                '               "short_name" : "US",' + 
                '               "types" : [ "country", "political" ]' + 
                '            },' + 
                '            {' + 
                '               "long_name" : "60439",' + 
                '               "short_name" : "60439",' + 
                '               "types" : [ "postal_code" ]' + 
                '            }' + 
                '         ],' + 
                '         "formatted_address" : "12876 Rosa Lane, Lemont, IL 60439, USA",' + 
                '         "geometry" : {' + 
                '            "location" : {' + 
                '               "lat" : 38.436710,' + 
                '               "lng" : -89.908210' + 
                '            },' + 
                '            "location_type" : "ROOFTOP",' + 
                '            "viewport" : {' + 
                '               "northeast" : {' + 
                '                  "lat" : 38.436710,' + 
                '                  "lng" : -89.908210' + 
                '               },' + 
                '               "southwest" : {' + 
                '                  "lat" : 38.436710,' + 
                '                  "lng" : -89.908210' + 
                '               }' + 
                '            }' + 
                '         },' + 
                '         "place_id" : "ChIJtYuu0V25j4ARwu5e4wwRYgE",' + 
                '         "plus_code" : {' + 
                '            "compound_code" : "CWC8+R3 Lemont, Illinios, United States",' + 
                '            "global_code" : "849VCWC8+R3"' + 
                '         },' + 
                '         "types" : [ "street_address" ]' + 
                '      }' + 
                '   ],' + 
                '   "status" : "OK"' + 
                '}'
            );
            res.setStatusCode(200);
            return res;
        }
    }
}