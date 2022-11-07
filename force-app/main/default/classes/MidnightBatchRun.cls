global class MidnightBatchRun implements Schedulable{
    global void execute(SchedulableContext sc) {
        resetOrderCountForToday();
    }


    public void resetOrderCountForToday() {
        List<Schema.Location> lstLocations = [Select Retail_Order_Count_For_Today__c, Pro_Order_Count_For_Today__c From Location];
        for(Schema.Location location : lstLocations){
            location.Retail_Order_Count_For_Today__c = 0;
            location.Pro_Order_Count_For_Today__c = 0;
        }
        update lstLocations;
    }

}