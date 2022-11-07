global class WM_LocationCappingScheduled  Implements Schedulable {
        global void execute(SchedulableContext sc) {
            setLocationCappingAttributes();
        }

        public void setLocationCappingAttributes() {
			List<AggregateResult> locationInformation = [select FulfilledFromLocationId, count(id) OrderCount from fulfillmentorder WHERE CreatedDate = TODAY group by FulfilledFromLocationId];
            Map<String, Integer> locationInformationMap = new Map<String, Integer>();
            
            for (AggregateResult individualResult : locationInformation) {
                system.debug(individualResult.get('FulfilledFromLocationId') + ' ' + individualResult.get('OrderCount'));
                locationInformationMap.put((String) individualResult.get('FulfilledFromLocationId'),(Integer) individualResult.get('OrderCount'));
            }
			
            List<schema.Location> locationsToUpdate = new List<schema.Location>();
            List<schema.Location> locations = [select Id, RetailThreshold__c, ProThreshold__c,Retail_Order_Count_For_Today__c,Pro_Order_Count_For_Today__c from Location];
            
            for (schema.Location location: locations) {
                schema.Location locationToUpdate = new schema.Location();
                locationsToUpdate.add(locationToUpdate);
                locationToUpdate.Id = location.Id;
                if (locationInformationMap.get(location.Id) != null && location.RetailThreshold__c != null && locationInformationMap.get(location.Id) >= location.RetailThreshold__c) {
                    locationToUpdate.ReachedMaximumRetail__c = TRUE;
                    System.debug('Set true for ' + location.Id);
                } else {
                    locationToUpdate.ReachedMaximumRetail__c = FALSE;
                    locationToUpdate.Retail_Order_Count_For_Today__c = 0;
                }
                
                if (locationInformationMap.get(location.Id) != null && location.ProThreshold__c != null && locationInformationMap.get(location.Id) >= location.ProThreshold__c) {
                    locationToUpdate.ReachedMaximumPro__c = TRUE;
                    System.debug('Set true for ' + location.Id);
                } else {
                    locationToUpdate.ReachedMaximumPro__c = FALSE;
                    locationToUpdate.Pro_Order_Count_For_Today__c = 0;
                }
            }
            
            update locationsToUpdate;
        }
    }