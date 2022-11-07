@isTest
public class SOMLocationSyncUtility {
   /* static Map<String, String> newLocations = new Map<String,String>();

    public static void Sync(String JsonRequest) {

        SOMLocationRequestUtility somLocationRequestUtil = 
            SOMLocationRequestUtility.parse(JsonRequest);
        
        SyncLocations(somLocationRequestUtil.SOMLocationRequest);

    }

    private static void SyncLocations(SOMLocationRequestUtility.SOMLocationRequest somLocationRequest) {

        // Delete any assignments that the user has marked for delete
        deleteAssignments(somLocationRequest.locationGroups);

        // Add new assignments
        for (SOMLocationRequestUtility.LocationGroupRequest grp : somLocationRequest.locationGroups) {

            Id groupId = getGroupId(grp);
            for (SOMLocationRequestUtility.LocationRequest loc : grp.locations) {
                Id locationId = getLocationId(loc);

                // if we don't already have a location assignment for the location and group, let's create one
                // TODO: This needs to be refactored, commenting out for now
//                List<LocationGroupAssignment> assigments = [SELECT Id FROM LocationGroupAssignment 
//                    WHERE LocationId =: locationId AND LocationGroupId =: groupId];

//                if (assigments.size() == 0) {
//                    LocationGroupAssignment la = new LocationGroupAssignment();
//                    la.LocationId = locationId;
//                    la.LocationGroupId = groupId;

//                    insert la;
//                }

            }
        }
    } 

    // If the group already exist, get the Id, otherwise create the group and return the Id
    private static Id getGroupId(SOMLocationRequestUtility.LocationGroupRequest groupRequest) {
        if (groupRequest.id.contains('new_grp_')) {
            LocationGroup grp = new LocationGroup();
            grp.LocationGroupName = groupRequest.name;
            grp.ExternalReference = groupRequest.externalReference;
            grp.IsEnabled = groupRequest.isEnabled;
            grp.ShouldSyncWithIas = true;

            insert grp;
            
            return grp.Id;
        } else {
            return Id.valueOf(groupRequest.id);
        }
    }

    // If the location already exist, get the Id, otherwise create the location and return the Id
    private static String getLocationId(SOMLocationRequestUtility.LocationRequest locationRequest) {
        Boolean newLoc = locationRequest.id.contains('new_loc_');
        if (newLoc && newLocations.containsKey(locationRequest.id)) {
            return newLocations.get(locationRequest.id);
        }
        else if (newLoc) {
            Schema.Location loc = new Schema.Location();
            loc.LocationType = locationRequest.type;
            loc.Name = locationRequest.name;
            loc.ExternalReference = locationRequest.externalReference;
            loc.ShouldSyncWithIas = true;

            insert loc;

            newLocations.put(locationRequest.id, loc.Id);
            
            return loc.Id;
        } else {
            return Id.valueOf(locationRequest.id);
        }
    }

    // This method is used to delete assignments that the user has marked for delete
    private static void deleteAssignments(List<SOMLocationRequestUtility.LocationGroupRequest> groups) 
    {
        List<LocationGroupAssignment> assigmentsToDelete = new List<LocationGroupAssignment>();

        for (SOMLocationRequestUtility.LocationGroupRequest grp : groups) { 

            // lets store the location ids in a list to simplify the looping structure
            List<String> locIds = new List<String>();
            for (SOMLocationRequestUtility.LocationRequest loc : grp.locations) { 
                locIds.add(loc.id);
            }

            List<LocationGroupAssignment> grpAssigments = [SELECT Id, LocationId, LocationGroupId 
                FROM LocationGroupAssignment WHERE LocationGroupId =: grp.id];

            for (LocationGroupAssignment assignment : grpAssigments) {
                // if the location is no longer apart of the assignment, lets mark it for delete
                if (!locIds.contains(assignment.LocationId)) {
                    assigmentsToDelete.add(assignment);
                }
            }
        }

        delete assigmentsToDelete;
    }*/
}