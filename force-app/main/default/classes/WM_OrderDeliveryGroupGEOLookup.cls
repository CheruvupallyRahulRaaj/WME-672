public class WM_OrderDeliveryGroupGEOLookup {
    
    public class FlowInput {
        @InvocableVariable(required=true)
        public String srecordId;
        
    }
    
    @InvocableMethod(label = 'GEO Lat Log Lookup') 
    static public void getGeoLatlong(List<FlowInput> FlowInputs) {
        
        SCCFileLogger logger = SCCFileLogger.getInstance();        
         
        for (FlowInput FlowInput : FlowInputs) {  
            if(FlowInput.srecordId != null ){
                Set<Id> odgIds = new Set<Id>();
 				odgIds.add(FlowInput.srecordId);
                system.debug('********Passed Record ID ' + FlowInput.srecordId);
                system.debug('********SET FOR SOME REASON ' + odgIds);
                LocationCallouts.locationCallout(odgIds);
            }        
        }
    } 
}