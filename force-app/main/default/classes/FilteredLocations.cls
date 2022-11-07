public with sharing class FilteredLocations {
	@InvocableMethod(label='Get FulFilled Location Records')
	public static List<List<Schema.Location>> getFulFilledLocations(List<List<String>> locations) {
		List<String> locationIds = new List<String>();
		List<List<Schema.Location>> result = new List<List<Schema.Location>>();
		if (locations != null && locations.size() > 0) {
			locationIds = locations[0];
			List<Schema.Location> locationList = [
				SELECT
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
				WHERE Id IN :locationIds
			];
			if (locationList.size() > 0) {
				result.add(locationList);
			}
		}

		return result;
	}
}