global class ScheduleReEvalFlowV2 implements Schedulable {
    global void execute(SchedulableContext ctx) {
        //Get WM Settings
        Integer configuredBatchSize = WM_SettingHelper.configuredBatchSize;
        Boolean debugMode = WM_SettingHelper.debugMode;

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
                    Id,
                    OrderDeliveryGroupSummary.OriginalOrderDeliveryGroupId,
                    OriginalOrderItem.Change_Product_Code__c
                FROM OrderItemSummary
                WHERE
                    OrderDeliveryGroupSummary.PartiallyFulfilled__c = TRUE
                AND OrderSummary.Hold_Re_evaluation__c = FALSE
                AND OrderSummary.IsHistorical__c = FALSE
                AND TypeCode = 'Product'
                AND ProductCode != 'special-order-name'
                AND Status IN :setEligibleStates
                AND OrderSummary.OrderedDate > :refDate
                ORDER BY OrderSummary.OrderedDate ASC
            ];
        } 
        else {
            lsOrderItemSummary = [
                SELECT
                    Id,
                    OrderDeliveryGroupSummary.OriginalOrderDeliveryGroupId,
                    OriginalOrderItem.Change_Product_Code__c
                FROM OrderItemSummary
                WHERE
                    OrderDeliveryGroupSummary.PartiallyFulfilled__c = TRUE
                AND OrderSummary.Hold_Re_evaluation__c = FALSE
                AND OrderSummary.IsHistorical__c = FALSE
                AND TypeCode = 'Product'
                AND ProductCode != 'special-order-name'
                AND Status IN :setEligibleStates
                AND OrderSummary.OrderedDate > :refDate
                ORDER BY OrderSummary.OrderedDate ASC
                LIMIT 51
            ];
        }

        if(debugMode){
            System.debug('Total Order Item Summaries:' + lsOrderItemSummary.size());
        }

        Map<Id,Set<String>> orderDeliveryGroupIdToSKUs = new Map<Id,Set<String>>();
        Set<String> AllSKUS = new Set<String>();

        for (OrderItemSummary ois : lsOrderItemSummary){
            if(!orderDeliveryGroupIdToSKUs.containsKey(ois.OrderDeliveryGroupSummary.OriginalOrderDeliveryGroupId)){
                orderDeliveryGroupIdToSKUs.put(ois.OrderDeliveryGroupSummary.OriginalOrderDeliveryGroupId, new Set<String>());
            }
            orderDeliveryGroupIdToSKUs.get(ois.OrderDeliveryGroupSummary.OriginalOrderDeliveryGroupId).add(ois.OriginalOrderItem.Change_Product_Code__c);
            AllSKUS.add(ois.OriginalOrderItem.Change_Product_Code__c);
        }
        if(debugMode){
            System.debug('Total Order Delivery Groups:' + orderDeliveryGroupIdToSKUs.size());
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

        Set<String> AvailableSKUs = new Set<String>();
        for(Set<String> currentSkuBatch : AllSKUBatches){
            if(debugMode){
                System.debug('Current SKU Batch Size:' + currentSkuBatch.size());
                for(String currentSKU : currentSkuBatch){
                    System.debug('Current SKU:' + currentSKU);
                }
            }

            ConnectApi.OCIGetInventoryAvailabilityInputRepresentation inventoryAvailabilityInputRepresentation = new ConnectApi.OCIGetInventoryAvailabilityInputRepresentation();
            inventoryAvailabilityInputRepresentation.useCache = TRUE;
            //inventoryAvailabilityInputRepresentation.locationGroupIdentifier = 'WM';
            inventoryAvailabilityInputRepresentation.locationGroupIdentifiers = new List<String> { 'WM' };
            //inventoryAvailabilityInputRepresentation.stockKeepingUnit = '16356578';
            inventoryAvailabilityInputRepresentation.stockKeepingUnits = new List<String>(currentSkuBatch);
                
            ConnectApi.OCIGetInventoryAvailabilityOutputRepresentation ociAvailabilityOutput = ConnectApi.OmnichannelInventoryService.getInventoryAvailability(inventoryAvailabilityInputRepresentation);

            if(debugMode){
                System.debug('locations size = ' + ociAvailabilityOutput.locations.size());
                System.debug('location groups size = ' + ociAvailabilityOutput.locationGroups.size());
            }




            for (ConnectApi.OCILocationGroupAvailabilityOutputRepresentation locationGroupAvailability : ociAvailabilityOutput.locationGroups) {
                for (ConnectApi.OCIInventoryRecordOutputRepresentation inventoryRecord : locationGroupAvailability.inventoryRecords) {
                    if(debugMode){
                        System.debug('Location Group : SKU =  ' + inventoryRecord.stockKeepingUnit + ' ATF: ' + inventoryRecord.availableToFulfill);
                    }
                    if(inventoryRecord.availableToFulfill > 0){
                        AvailableSKUs.add(inventoryRecord.stockKeepingUnit);
                    }
                }
            }

            // for (ConnectApi.OCILocationAvailabilityOutputRepresentation locationAvailability : ociAvailabilityOutput.locations) {
            //     for (ConnectApi.OCIInventoryRecordOutputRepresentation inventoryRecord : locationAvailability.inventoryRecords) {
            //         System.debug('SKU =  ' + inventoryRecord.stockKeepingUnit);
            //         System.debug('locationAvailability availableToFulfill = ' + inventoryRecord.availableToFulfill);
            //     }
            // }

        }

        Map<Integer,Map<Id,Set<String>>> orderDeliveryGroupIdToSKUsBatches = new Map<Integer,Map<Id,Set<String>>>();

        if(configuredBatchSize == 1){
            Integer i = 0;
            for(Id odgId : orderDeliveryGroupIdToSKUs.keySet()){
                if(debugMode){
                    System.debug('AAA:BBB:Checking ODG ID:' + odgId);
                }
                Map<Id,Set<String>> singleODG = new Map<Id,Set<String>>();
                singleODG.put(odgId, orderDeliveryGroupIdToSKUs.get(odgId));
                Boolean AtleastOneSKUHasInventory = FALSE;
                for(String sku : singleODG.get(odgId)){
                    System.debug('AAA:BBB:ODG ' + odgId + ' Checking for SKU:' + sku);
                    if(AvailableSKUs.contains(sku)){
                        AtleastOneSKUHasInventory = TRUE;
                        if(debugMode){
                            System.debug('AAA:BBB:ODG ' + odgId + ' Inventory Available for SKU :' + sku);
                        }
                        break;
                    }
                    else{
                        System.debug('AAA:BBB:ODG ' + odgId + ' Inventory Not Available for SKU :' + sku);
                    }
                }
                if(AtleastOneSKUHasInventory == TRUE){
                    i++;
                    orderDeliveryGroupIdToSKUsBatches.put(i, singleODG);
                }
                else{
                    if(debugMode){
                        System.debug('AAA:BBB:ODG ' + odgId + ' NO Inventory for any SKUs');
                    }
                }
            }
        }
        else{
            Set<Integer> completedBatches = new Set<Integer>();

            for(Integer i = 1; i<= orderDeliveryGroupIdToSKUs.size();i++){
                orderDeliveryGroupIdToSKUsBatches.put(i, new Map<Id,Set<String>>());
            }
            for(Id loopOdgId : orderDeliveryGroupIdToSKUs.keySet()){
                Set<String> loopSkus = orderDeliveryGroupIdToSKUs.get(loopOdgId);
                Boolean AtleastOneSKUHasInventory = FALSE;
                for(String sku : loopSkus){
                    if(AvailableSKUs.contains(sku)){
                        AtleastOneSKUHasInventory = TRUE;
                        if(debugMode){
                            System.debug('AAA:BBB:ODG ' + loopOdgId + ' Inventory Available for SKU :' + sku);
                        }
                        break;
                    }
                    else{
                        if(debugMode){
                            System.debug('AAA:BBB:ODG ' + loopOdgId + ' Inventory Not Available for SKU :' + sku);
                        }
                    }
                }
                if(AtleastOneSKUHasInventory == FALSE){
                    continue;
                }
                

                for(Integer batchNumber = 1; batchNumber <= orderDeliveryGroupIdToSKUsBatches.size();batchNumber++){
                    if(completedBatches.contains(batchNumber)) continue;

                    Map<Id,Set<String>> batchODGs = orderDeliveryGroupIdToSKUsBatches.get(batchNumber);

                    Boolean SkuIsInBatch = FALSE;
                    for(Id batchODG : batchODGs.keySet()){
                        Set<String> batchODGSkus = batchODGs.get(batchODG);
                        for(String loopSKU : loopSkus){
                            if(batchODGSkus.contains(loopSKU)){
                                SkuIsInBatch = TRUE;
                                break;
                            }
                        }
                        if(SkuIsInBatch == TRUE){
                            break;
                        }
                    }

                    if(SkuIsInBatch == FALSE){
                        batchODGs.put(loopOdgId, loopSkus);
                        if(batchODGs.size()>=configuredBatchSize){
                            completedBatches.add(batchNumber);
                        }
                        break;
                    }
                }
            }

        }

        //Delete all Existing ReEval Data
        List<ReEval_Data__c> lstExistingReevalData = [Select ID From ReEval_Data__c];
        delete lstExistingReevalData;

        List<ReEval_Data__c> lstNewReEvalData = new List<ReEval_Data__c>();
        for(Integer batchNumber = 1; batchNumber <= orderDeliveryGroupIdToSKUsBatches.size();batchNumber++){
            Map<Id,Set<String>> batchODGs = orderDeliveryGroupIdToSKUsBatches.get(batchNumber);

            if(batchODGs.size()==0) break;

            for(Id odgId : batchODGs.keySet()){
                Set<String> SKUS = batchODGs.get(odgId);
                ReEval_Data__c r = new ReEval_Data__c();
                r.Name = odgId;
                r.BatchNumber__c = batchNumber;
                r.OrderDeliveryGroupID__c = odgId;
                r.Is_Processed__c = FALSE;
                r.Is_Error__c = FALSE;
                lstNewReEvalData.add(r);
                if(debugMode){
                    System.debug('AAA: ODG ID:' + r.OrderDeliveryGroupID__c + ' : BatchNumber:' + r.BatchNumber__c);
                    for(String sku : SKUS){
                        System.debug('-------AAA: SKU: ' + sku);
                    }
                }
            }
        }


        if(debugMode){
            System.debug('AAA: New Reeval Data');
            for(ReEval_Data__c reeval : lstNewReEvalData){
                System.debug('AAA: ID: ' + reeval.Id + ' ODG ID:' + reeval.OrderDeliveryGroupID__c + ' : BatchNumber:' + reeval.BatchNumber__c);
            }
        }

        if(lstNewReEvalData.size()>0){
            Id jobId = System.enqueueJob(new ReEvalFirstBatch(lstNewReEvalData));
            if(debugMode){
                System.debug('AAA: Job ID to Insert and Enqueue First Batch:' + jobId);
            }
        }
    }
}