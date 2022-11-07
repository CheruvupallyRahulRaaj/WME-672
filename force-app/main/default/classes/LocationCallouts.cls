public class LocationCallouts {
    
    
         private static String  googleApiKey;
   
    
    
   	//@future
    static public void locationCallout(set<id> li) {
        for (OrderDeliveryGroup deliveryGroup : [
            SELECT DeliverToCity, DeliverToCountry, DeliverToPostalCode, DeliverToState, DeliverToStreet, 
            DeliverToLatitude, DeliverToLongitude  
            FROM OrderDeliveryGroup 
            WHERE id = :li
        ]) {
            callGeoCodeForDeliveryGroup(deliveryGroup);
        }
    }
    
    @InvocableMethod(label = 'Geocoding for delivery group') 
    static public void geoCodeDeliveryGroups(List<OrderDeliveryGroup> deliveryGroups) {
        for (OrderDeliveryGroup deliveryGroup : deliveryGroups) {
            callGeoCodeForDeliveryGroup(deliveryGroup);
        }
    }
    
   //	@future(callout = true)
    static public void asyncgeoCodeDeliveryGroup(String orderDelId) {
        OrderDeliveryGroup ordDeGrp = [SELECT Id, OrderDeliveryGroupNumber, OrderDeliveryMethodId, RelatedDeliveryGroupId, 
                                       DeliverToName, PhoneNumber, EmailAddress, DeliverToStreet, DeliverToCity, DeliverToState,
                                       DeliverToPostalCode, DeliverToCountry, DeliverToLatitude, DeliverToLongitude, DeliverToGeocodeAccuracy, 
                                       DeliverToAddress, IsGift, PromisedDeliveryDate, DesiredDeliveryDate, TotalTaxAmount, TotalAmount, 
                                       TotalLineAmount, TotalAdjustmentAmount, TotalLineTaxAmount, TotalAdjustmentTaxAmount, GrandTotalAmount,
                                       GiftMessage, Description, DeliveryInstructions, TotalLineAmtWithTax, TotalAdjustmentAmtWithTax, 
                                       Test_Context__c, fromStoreId__c FROM OrderDeliveryGroup where Id=:orderDelId limit 1];
        geoCodeDeliveryGroup(ordDeGrp);
    }
    
    static private void geoCodeDeliveryGroup(OrderDeliveryGroup deliveryGroup) {
        Boolean updateDeliveryGroup = callGeoCodeForDeliveryGroup(deliveryGroup);
        
        if (updateDeliveryGroup) {
        	update deliveryGroup;
        }
    }

    
	static private Boolean callGeoCodeForDeliveryGroup(OrderDeliveryGroup deliveryGroup) {
        if(!Test.isRunningTest()){
         	googleApiKey= WM_WebServiceDetails__c.getValues('googleGEOLocationKey').WM_ApiKey__c;
        }
        
        //Only perform lookup if necessary
        if (deliveryGroup.DeliverToLatitude == null || deliveryGroup.DeliverToLongitude == null) {
            String address = '';
            
            if (deliveryGroup.DeliverToStreet != null) {
                address += deliveryGroup.DeliverToStreet + ',';
            }
            
            if (deliveryGroup.DeliverToCity != null) {
                address += deliveryGroup.DeliverToCity + ',';
            }
            
            if (deliveryGroup.DeliverToState != null) {
                address += deliveryGroup.DeliverToState + ' ';
            }
            
            if (deliveryGroup.DeliverToPostalCode != null) {
                address += deliveryGroup.DeliverToPostalCode + ',';
            }
            
            if (deliveryGroup.DeliverToCountry != null) {
                address += deliveryGroup.DeliverToCountry;
            }
            
            address = EncodingUtil.urlEncode(address, 'UTF - 8');
            
            // build callout
            Http h = new Http();
            
            HttpRequest req = new HttpRequest();
            
            req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=' + address + '&sensor=false&key=' + googleApiKey);
            req.setMethod('GET');
            
            req.setTimeout(5000);
            try {
                // callout
                HttpResponse res = h.send(req);
                
                // parse coordinates from response
                System.debug('Google Geocode response: ' + res.getBody());
                JSONParser parser = JSON.createParser(res.getBody());
                
                double lat = null;
                double lon = null;
                
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'location')) {
                        parser.nextToken(); // object start
                        while (parser.nextToken() != JSONToken.END_OBJECT) {
                            String txt = parser.getText();
                            parser.nextToken();
                            if (txt == 'lat') {
                                lat = parser.getDoubleValue();
                            } else if (txt == 'lng') {
                                lon = parser.getDoubleValue();  
                            }
                        }
                    }
                }
                
                // update coordinates if we get back
                if (lat != null) {
                    deliveryGroup.DeliverToLatitude = lat;
                    deliveryGroup.DeliverToLongitude = lon;
                    return true;
                } 
                
            } catch(Exception e) {
                system.debug(e);
            }
        }
        
        return false;
	}
}