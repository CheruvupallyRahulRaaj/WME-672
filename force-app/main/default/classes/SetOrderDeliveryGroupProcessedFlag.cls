public class SetOrderDeliveryGroupProcessedFlag{
    @InvocableMethod(label='Set Order Delivery Group Processed Flag to True')
    public static void process(List<Id> fulfillmentOrderIds) {

        Boolean debugMode = WM_SettingHelper.debugMode;
        List<FulfillmentOrder> lstFulfillmentOrders = [
            SELECT
                Id,
                Order_Delivery_Group_Summary__r.OriginalOrderDeliveryGroupId 
            FROM
                FulfillmentOrder
            WHERE ID IN :fulfillmentOrderIds
        ];

        Set<ID> OrderDeliveryGroupIds = new Set<ID>();
        for(FulFillmentOrder fo : lstFulfillmentOrders){
            OrderDeliveryGroupIds.add(fo.Order_Delivery_Group_Summary__r.OriginalOrderDeliveryGroupId);
        }

        List<ReEval_Data__c> lstReevalData = [
            SELECT 
                Id,
                OrderDeliveryGroupID__c 
            FROM
                ReEval_Data__c
            WHERE
                OrderDeliveryGroupID__c IN :OrderDeliveryGroupIds 
            AND 
                Is_Processed__c = FALSE
        ];

        if(debugMode){
            System.debug('AAA: Sizeof lstReevalData:' + lstReevalData.size());
        }
        for(ReEval_Data__c record : lstReevalData){
            if(debugMode){
                System.debug('AAA: ' + record.Id + ' ODGID: ' + record.OrderDeliveryGroupID__c);
            }
            record.Is_Processed__c = TRUE;
        }
        Database.update(lstReevalData,false);
    }
}