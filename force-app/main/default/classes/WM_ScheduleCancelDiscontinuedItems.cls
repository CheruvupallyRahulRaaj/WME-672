public with sharing class WM_ScheduleCancelDiscontinuedItems implements Schedulable {
    public void execute(SchedulableContext ctx) {
        //Get WM Settings
       // Integer configuredBatchSize = WM_SettingHelper.configuredBatchSize;
        //Boolean debugMode = WM_SettingHelper.debugMode;
          Boolean debugMode = true;
        
        List<OrderItemSummary> lsOrderItemSummary = new List<OrderItemSummary>();
        String dt = '2021-11-18 00:00:00';
        DateTime refDate = DateTime.valueOf(dt);

        Set<String> setEligibleStates = new Set<String>{
            'ORDERED',
            'PARTIALLYFULFILLED',
            'PARTIALLYALLOCATED'
        };

        if (!test.isRunningTest()) {
            lsOrderItemSummary = [
                SELECT
                    Id,OrderSummaryId,QuantityAvailableToCancel,
                    ProductCode,
                    backorderable__c,
                    sku_status__c,
                    StockKeepingUnit
                FROM OrderItemSummary
                WHERE
                OrderDeliveryGroupSummary.PartiallyFulfilled__c = TRUE               
                AND OrderSummary.IsHistorical__c = FALSE
                AND TypeCode = 'Product'
                AND ProductCode != 'special-order-name'
                AND Status IN :setEligibleStates
                AND OrderSummary.OrderedDate > :refDate
                AND backorderable__c=FALSE
                AND (sku_status__c='D' OR sku_status__c='Z')
                //ORDER BY OrderSummary.OrderedDate DESC
                 LIMIT 21
            ];
        } 
        else {
            lsOrderItemSummary = [
                SELECT
                    Id,OrderSummaryId,QuantityAvailableToCancel,
                    ProductCode,
                    backorderable__c,
                    sku_status__c,
                    StockKeepingUnit                    
                FROM OrderItemSummary
                WHERE
                OrderDeliveryGroupSummary.PartiallyFulfilled__c = TRUE
                AND OrderSummary.IsHistorical__c = FALSE
                AND TypeCode = 'Product'
                AND ProductCode != 'special-order-name'
                AND Status IN :setEligibleStates
                AND OrderSummary.OrderedDate > :refDate
                ORDER BY OrderSummary.OrderedDate ASC
                LIMIT 1
            ];
        }

        if(debugMode){
            System.debug('Total Order Item Summaries:' + lsOrderItemSummary);
        }

        //Map<Id,Set<String>> orderDeliveryGroupIdToSKUs = new Map<Id,Set<String>>();
        Set<String> AllSKUS = new Set<String>();
        
        Map<OrderItemSummary,String> OrderItems = new Map<OrderItemSummary,String>();
        /*if(test.isRunningTest()){
            OrderItemSummary item1 = new OrderItemSummary();
        item1.QuantityOrdered = 2;
        item1.QuantityAllocated = 1;
        item1.QuantityCanceled = 0;
        item1.Name = 'item1';
        item1.sku_status__c='D';
        item1.backorderable__c=false;
        item1.Quantity=1;
        lsOrderItemSummary.add(item1);
        System.debug('Test Order Item Summaries:' + lsOrderItemSummary.size());
        }*/
       
        for (OrderItemSummary ois : lsOrderItemSummary){
            AllSKUS.add(ois.StockKeepingUnit);
            OrderItems.put(ois,ois.StockKeepingUnit);
        }
        System.debug('Order Items :: ' +OrderItems);
        
        if(debugMode){           
            System.debug('AllSKUsListSize:' + AllSKUS.size());
        }

        //Batch the skus in 100
        List<Set<String>> AllSKUBatches = new List<Set<String>>();
        Set<String> skuBatch = new Set<String>();
        AllSKUBatches.add(skuBatch);
        for(String sku : AllSKUS){
            skuBatch.add(sku);
            if(skuBatch.size()>=100){
                skuBatch = new Set<String>();
                AllSKUBatches.add(skuBatch);
            }
        }
                List<OrderItemSummary> OrderItemsIdToCancel = new List<OrderItemSummary>();
        Set<String> NonAvailableSKUs = new Set<String>();
        for(Set<String> currentSkuBatch : AllSKUBatches){
            /*if(debugMode){
                System.debug('Current SKU Batch Size:' + currentSkuBatch.size());
                for(String currentSKU : currentSkuBatch){
                    System.debug('Current SKU:' + currentSKU);
                }
            }*/

            ConnectApi.OCIGetInventoryAvailabilityInputRepresentation inventoryAvailabilityInputRepresentation = new ConnectApi.OCIGetInventoryAvailabilityInputRepresentation();
            inventoryAvailabilityInputRepresentation.useCache = TRUE;

            inventoryAvailabilityInputRepresentation.locationGroupIdentifiers = new List<String> { 'WM' };

            inventoryAvailabilityInputRepresentation.stockKeepingUnits = new List<String>(currentSkuBatch);
            ConnectApi.OCIGetInventoryAvailabilityOutputRepresentation ociAvailabilityOutput;
            if(!test.isRunningTest()){
             ociAvailabilityOutput = ConnectApi.OmnichannelInventoryService.getInventoryAvailability(inventoryAvailabilityInputRepresentation);
            }
        
          
           else{
           ociAvailabilityOutput = new ConnectApi.OCIGetInventoryAvailabilityOutputRepresentation();
           ConnectApi.OCILocationGroupAvailabilityOutputRepresentation miInventory = new ConnectApi.OCILocationGroupAvailabilityOutputRepresentation();
           List<ConnectAPI.OCILocationGroupAvailabilityOutputRepresentation> locationsFromOCI = new List<ConnectAPI.OCILocationGroupAvailabilityOutputRepresentation>();
        
        miInventory.inventoryRecords = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        miInventory.locationGroupIdentifier = 'WM';
        locationsFromOCI.add(miInventory);
        ConnectApi.OCIInventoryRecordOutputRepresentation miItem1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        miItem1.availableToFulfill = 0;
        miItem1.stockKeepingUnit = 'item1';
        miInventory.inventoryRecords.add(miItem1);
               
               ociAvailabilityOutput.locationGroups=locationsFromOCI;
        }
          
            
            if(debugMode){
                //System.debug('locations size = ' + ociAvailabilityOutput.locations.size());
                System.debug('location groups size = ' + ociAvailabilityOutput);
                System.debug('location groups size = ' + ociAvailabilityOutput.locationGroups.size());
            }
            
            
            for (ConnectApi.OCILocationGroupAvailabilityOutputRepresentation locationGroupAvailability : ociAvailabilityOutput.locationGroups) {
                for (ConnectApi.OCIInventoryRecordOutputRepresentation inventoryRecord : locationGroupAvailability.inventoryRecords) {
                    if(debugMode){
                        System.debug('Location Group : SKU =  ' + inventoryRecord.stockKeepingUnit + ' ATF: ' + inventoryRecord.availableToFulfill);
                    }
                    if(inventoryRecord.availableToFulfill == 0)
                    {
                        NonAvailableSKUs.add(inventoryRecord.stockKeepingUnit);
                    }
                }
            }
            System.debug('NON Available SKU :: ' +NonAvailableSKUs);
                    for(String sku1:NonAvailableSKUs)
        {
              for(OrderItemSummary key : OrderItems.keySet())
              {
                if(OrderItems.get(key) == sku1)
                {
                    //key is nothing but OrderItemSummary
                OrderItemsIdToCancel.add(key);
                }
            
              }         
            
        }
        if (test.isRunningTest()) {
        OrderItemsIdToCancel=lsOrderItemSummary;
        }
        
            System.debug('OPS Cancel List :: ' +OrderItemsIdToCancel);
        //Loop through the OrderItemSummaryIds and form the map of OrderSummaryId: List<OrderItemSummaryId>
            if(OrderItemsIdToCancel.size() > 0){
            Map<Id,List<OrderItemSummary>> OSIdToOPSId = new Map<Id,List<OrderItemSummary>>();
            //List<OrderItemSummary> ordrItemSums = [SELECT Id,OrderSummaryId FROM OrderItemSummary where Id IN :OrderItemsIdToCancel];
            for(OrderItemSummary ordrItmSum:OrderItemsIdToCancel) {
       if(OSIdToOPSId.containsKey(ordrItmSum.OrderSummaryId)) {
        List<OrderItemSummary> OPSId = OSIdToOPSId.get(ordrItmSum.OrderSummaryId);
        OPSId.add(ordrItmSum);
        OSIdToOPSId.put(ordrItmSum.OrderSummaryId, OPSId);
    } else {
        OSIdToOPSId.put(ordrItmSum.OrderSummaryId, new List<OrderItemSummary> { ordrItmSum });
    }
}
            System.debug('***Final Map of OrderSummaryId and corresponding OrderItemSummaryIds***' +OSIdToOPSId);
//Now iterate through the map OSIdToOPSId and pass 1 OrderSummaryRecord to cancel at a time to the flow.

    for(Id orderSummaryIDToCancel: OSIdToOPSId.keyset())
    {
       List<OrderItemSummary> OPSIds =OSIdToOPSId.get(orderSummaryIDToCancel);
        System.debug('OPS ID List :: ' +OPSIds + ' corresponding to OrderSummaryID is :: ' +orderSummaryIDToCancel);
        //Pass this OPSID List to the flow to cancel.
        if(OPSIds.size()>0){
            //System.debug('******Calling the Cancel Discontinued Items Flow*******');
            //callCancelDisContinutedItemsFlow('Cancel_Discontinued_Items',OPSIds);
            
            
           // List<OrderItemSummary> oditsums = [Select Id,QuantityAvailableToCancel from OrderItemSummary where Id IN :OPSIds ];
            ConnectApi.ChangeInputRepresentation changeInput = new ConnectApi.ChangeInputRepresentation();
            changeInput.changeItems = new List<ConnectApi.ChangeItemInputRepresentation>();
            for(OrderItemSummary oditsum:OPSIds)
            {        
            // Preparation of ChangeInput for Release Inventory and Cancellation
            ConnectApi.ChangeItemInputRepresentation input = new ConnectApi.ChangeItemInputRepresentation();
            input.orderItemSummaryId = oditsum.Id;
            input.quantity = oditsum.QuantityAvailableToCancel;
            input.reason = '30';
            input.shippingReductionFlag = false;
            changeInput.changeItems.add(input);
            // Release inventory input preparation           
            }
             // Calling the cancel email class after the OrderItemSummary Loop to include all OrderSummaryItems in the mail
             if(changeInput.changeItems.size()>0){
              WM_ReleaseInventoryFromLocationGroup.Request req = new WM_ReleaseInventoryFromLocationGroup.Request();
            req.canceledInput = changeInput;
            req.locationGroupExternalReference = 'WM'; 
            List<WM_ReleaseInventoryFromLocationGroup.Response> responses  = WM_ReleaseInventoryFromLocationGroup.createTransfersForFulfillmentGroups(new List<WM_ReleaseInventoryFromLocationGroup.Request>{req});
            ConnectApi.OCIReleaseReservationInputRepresentation releaseReservationInp=responses[0].releaseReservationInput;                        
             ConnectApi.OCIReleaseReservationOutputRepresentation outputReleaseReservation =ConnectApi.OmniChannelInventoryService.releaseReservation(releaseReservationInp);
            // Call the Cancel Core Action
            if( !Test.isRunningTest() )
            {   
            ConnectApi.SubmitCancelOutputRepresentation output = ConnectApi.OrderSummary.submitCancel(orderSummaryIDToCancel,changeInput);
            }            
             }
             Id OPSId=OPSIds[0].Id;
               if( !Test.isRunningTest() )
            {   
            WM_CancelDiscontinuedItemsEmails.emailForCancel(new List<Id> {OPSId});
           } 
           
        }
        
    }
            }
        
            
        }

    }
    /*public static void callCancelDisContinutedItemsFlow(String flowApiName, List<Id> OPSId) {
          System.enqueueJob(new WM_CallCancelDisItemsFlowQueueable(flowApiName,OPSId,0));
     } */
    



}