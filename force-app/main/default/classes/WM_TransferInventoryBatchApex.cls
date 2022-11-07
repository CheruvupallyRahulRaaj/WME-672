public with sharing class WM_TransferInventoryBatchApex {
   /* public List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
    public Map<String, String> itemIdToSKUMap = new Map<String,String>();
    public Map<String, String> locationIdToExternalReferenceMap = new Map<String,String>();
    public String locationGroupExternalReference;
    public Map<String,String> mapOfFulFillmentOrderwithLineItems;
    
    public WM_TransferInventoryBatchApex(List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmntGrps,Map<String, String> itemIdSKUMap,
                                         Map<String, String> locatnIdToExternlReferenceMap,String locationGrpExtrnlRefrnce,Map<String,String> tempMap){
                                             this.fulfillmentGroups = fulfillmntGrps;
                                             this.itemIdToSKUMap = itemIdSKUMap;
                                             this.locationIdToExternalReferenceMap = locatnIdToExternlReferenceMap;
                                             this.locationGroupExternalReference = locationGrpExtrnlRefrnce; 
                                             this.mapOfFulFillmentOrderwithLineItems = tempMap;
                                             
                                         }
    
    public Iterable<ConnectApi.FulfillmentGroupInputRepresentation> start(Database.BatchableContext bc){       
        return this.fulfillmentGroups;
    }     
    public void execute(Database.BatchableContext bc, List<ConnectApi.FulfillmentGroupInputRepresentation> scope){
        
        Set<String> fulfilmentOrderIds = new Set<String>();
        List<ConnectApi.OCITransferReservationSingleInputRepresentation> singleInputRepresentations = new List<ConnectApi.OCITransferReservationSingleInputRepresentation>();
        try{
        for (ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroup : scope) {
            String toLocationIdentifier = locationIdToExternalReferenceMap.get(fulfillmentGroup.fulfilledFromLocationId);
            for (ConnectApi.OrderItemSummaryInputRepresentation itemSummary : fulfillmentGroup.orderItemSummaries) {
                fulfilmentOrderIds.add(mapOfFulFillmentOrderwithLineItems.get(itemSummary.orderItemSummaryId));
                ConnectApi.OCITransferReservationSingleInputRepresentation singleInputRepresentation = new ConnectApi.OCITransferReservationSingleInputRepresentation();
                singleInputRepresentation.fromLocationGroupIdentifier = locationGroupExternalReference;
                singleInputRepresentation.toLocationIdentifier = toLocationIdentifier;
                singleInputRepresentation.stockKeepingUnit = itemIdToSKUMap.get(itemSummary.orderItemSummaryId);
                singleInputRepresentation.quantity = itemSummary.quantity;
                singleInputRepresentation.actionRequestId = IASUtility.NewGuid()[0];
                singleInputRepresentation.externalRefId = toLocationIdentifier;
                singleInputRepresentations.add(singleInputRepresentation);
            }
        }
        ConnectApi.OCITransferReservationInputRepresentation transferRequest = new ConnectApi.OCITransferReservationInputRepresentation();
        transferRequest.transferRecords = singleInputRepresentations;
        ConnectApi.OCITransferReservationInputRepresentation transferReservationInput = new ConnectApi.OCITransferReservationInputRepresentation();
        transferReservationInput = transferRequest;
      
            ConnectApi.OCITransferReservationOutputRepresentation outputRepresentation = ConnectApi.OmnichannelInventoryService.transferReservation(transferReservationInput);
            
        }    
        catch(Exception e){
            system.debug('****Exception Occurred**** '+e);
            TransferInventory__c maxReTrials = [SELECT Id,NAME, Maximum_Number_of_Re_trials_for_Transfer__c FROM TransferInventory__c limit 1];
            List<FulfillmentOrder> failedFOrderList = [Select Id,Status,Tranfered_Inventory__c,Re_trials_for_Tranfer_Inventory__c,OrderSummaryId  from FulfillmentOrder where Id In:fulfilmentOrderIds];
            List<ProcessException> proExceptionList = new List<ProcessException>();
            for(FulfillmentOrder fOrder :failedFOrderList){
                if(fOrder.Re_trials_for_Tranfer_Inventory__c==maxReTrials.Maximum_Number_of_Re_trials_for_Transfer__c){
                    ProcessException proException = new ProcessException();
                    proException.Status = 'New';
                    proException.Message = 'Reached Maximum Number of Trials for Transfering Inventory';
                    proException.Category = 'Transfer Inventory';
                    proException.Priority = 'High';
                    proException.OrderSummaryId = fOrder.OrderSummaryId;
                    proException.Description = 'Reached Maximum Number of Trials for Transfering Inventory';
                    proExceptionList.add(proException);
                }
            }
            insert proExceptionList;
            
        }
        List<FulfillmentOrder> successfulFOrderList = [Select Id,Status,Tranfered_Inventory__c  from FulfillmentOrder where Id In:fulfilmentOrderIds];
        List<FulfillmentOrder> updateFOList = new List<FulfillmentOrder>();
        for(FulfillmentOrder fOrder:successfulFOrderList){
             fOrder.Status = 'Assigned';
            fOrder.Tranfered_Inventory__c  = true;
            updateFOList.add(fOrder);
        }      
        update updateFOList;
        
    }     
    
    public void finish(Database.BatchableContext bc){ 
        
    }  */
}