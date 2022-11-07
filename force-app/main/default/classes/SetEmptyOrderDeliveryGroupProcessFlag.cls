public class SetEmptyOrderDeliveryGroupProcessFlag {
    @InvocableMethod(label='Set Unallocated Order Delivery Group Processed Flag to True')
    public static void process(List<Id> orderDeliveryGroupIds) {

        Boolean debugMode = WM_SettingHelper.debugMode;
        List<ReEval_Data__c> lstReevalData = [
            SELECT 
                Id,
                OrderDeliveryGroupID__c,
                Is_Processed__c,
                Is_Error__c
            FROM
                ReEval_Data__c
            WHERE
                OrderDeliveryGroupID__c IN :OrderDeliveryGroupIds 
            AND 
                Is_Processed__c = FALSE
        ];
        for(ReEval_Data__c record : lstReevalData){
            if(debugMode){
                System.debug('AAA:' + record.Id + ' ODGID:' + record.OrderDeliveryGroupID__c + ' :Is_Processed__c:' + record.Is_Processed__c + ' : IsError:' + record.Is_Error__c);
            }
            record.Is_Processed__c = TRUE;
        }
        Database.update(lstReevalData,false);
    }
}