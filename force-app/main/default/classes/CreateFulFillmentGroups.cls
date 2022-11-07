@isTest
public class CreateFulFillmentGroups {
/*    
    public class MessagingInput{
        
        @InvocableVariable
        public ConnectAPI.IASGetInventoryInputRepresentation inventoryAvailabilityRequest; 
        @InvocableVariable
        public ConnectAPI.IASGetAvailabilityOutputRepresentation inventoryAvailabilityResponse;  
        @InvocableVariable(label='Items ordered' required=true)
        public List<OrderItemSummary> lineItems;  
        @InvocableVariable(label='List of locations' required=true)
        public List<Schema.Location> locations; 
        @InvocableVariable(label='Order Delivery Group' required=true)
        public OrderDeliveryGroup deliveryGroup; 
    }
    
    public class MessagingOutput {
        @InvocableVariable
        public List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroupsOutputlst;
    }
    
    //createLocationToItemCountMap method to call for Item Count
    @InvocableMethod(label='CreateFulFillGroups')
    public static List<MessagingOutput> FulFillment_Groups(List<MessagingInput> requestList) {

        List<Schema.Location> locationList = new List<Schema.Location>();
        String deliveryGroup;
        
    for (MessagingInput request: requestList) {        
       // Inventory Availability Request Variables
          ConnectAPI.IASGetAvailabilityOutputRepresentation ociOutput = request.inventoryAvailabilityResponse;  
          //outside mainland using ASCII and USPS standards
            Set<String> outsideMainlandStateCodes = getOutsideMainlandSet();
          
          if (request.deliveryGroup.DeliverToCountry == 'US' && 
                !outsideMainlandStateCodes.contains(request.deliveryGroup.DeliverToState) && 
                request.inventoryAvailabilityResponse != null && request.lineItems != null) {
                    //Determine items required quantities
                    Map<String,Decimal> quantityRequiredMap = new Map<String,Decimal>();
                    
                    Decimal itemsOrdered = 0;
                    
                    //Determine items required quantities
                    for (OrderItemSummary lineItem : request.lineItems) {
                        itemsOrdered += lineItem.QuantityOrdered;
                        String lineItemKey = (lineItem.StockKeepingUnit != null) ? lineItem.StockKeepingUnit : lineItem.Name;
                        quantityRequiredMap.put(lineItemKey, lineItem.QuantityOrdered);
                    }
         
                      
          //Create map of Primary warehouse locations by external reference
          Map<String, Schema.Location> storeMap = new Map<String, Schema.Location>();
          Map<String, Schema.Location> warehouseMap = new Map<String, Schema.Location>();
          Map<String, Schema.Location> locationMap = new Map<String, Schema.Location>();
                         
                    for (Schema.Location location : request.locations) {
                        if (location.ExternalReference != null) {
                               locationMap.put(location.ExternalReference, location);
                            if (location.LocationType == 'Store') {
                                storeMap.put(location.ExternalReference, location);
                            }else{
                                warehouseMap.put(location.ExternalReference, location);
                            }
                        }
                    }
                    boolean exceptionRule, ShipCompleteflag = false;
              //Determine stores with full inventory
               List<Schema.Location> fullInventoryStores = new List<Schema.Location>();
               List<Schema.Location> fullInventoryWarehouses = new List<Schema.Location>();
                    
                    for (ConnectApi.IASLocationAvailabilityOutputRepresentation ociLocation : request.inventoryAvailabilityResponse.locations) {
                        Decimal availableAtLocation = 0;
                        
                        for (ConnectApi.IASInventoryRecordOutputRepresentation inventoryRecord : ociLocation.inventoryRecords) {
                            Decimal requestedAmountForSku = quantityRequiredMap.get(inventoryRecord.stockKeepingUnit);
                            
                            //check for inventory at this location
                            if (requestedAmountForSku != null) {
                                availableAtLocation += Math.min(requestedAmountForSku, inventoryRecord.availableToFulfill);
                            }
                        }
                        
                        //check if this location has all the items
                        if (availableAtLocation == itemsOrdered) {
                           // Need to add to storeMap or warehouse Map 
                           string ExternalSKU = ociLocation.locationIdentifier;
                            
                           // If store add to fullInventoryStores, if warehouse add to fullInventoryWarehouses 
                             Schema.Location Locations;
                             String Extid = ociLocation.locationIdentifier;
                             Locations = locationMap.get(Extid);  
                             If (Locations.LocationType == 'Store') {            
                                fullInventoryStores.add(storeMap.get(ociLocation.locationIdentifier));
                             }else{
                                 fullInventoryWarehouses.add(storeMap.get(ociLocation.locationIdentifier));
                             }
                        }
                    }
                    
                //    Schema.Location bestStoreLocation = determineClosestLocation(fullInventoryStores, null, 
                //                                                                 request.deliveryGroup.DeliverToLatitude, request.deliveryGroup.DeliverToLongitude);
               
                    
            
                    
                    
                          
         }  // If US     
     }  // For Input     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
      
   /*     
        // Create FulFillmentGroups
        ConnectApi.FulfillmentOrderInputRepresentation fulfillmentOrderInput = new  ConnectApi.FulfillmentOrderInputRepresentation();
        fulfillmentOrderInput.orderSummaryId =  strorderSummaryId ;
        
        fulfillmentOrderInput.orderDeliveryGroupSummaryId = strOrderDeliveryGroupSummaryId_input;  
        List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
        
        if(!wareHouseQuantityListOfItemsWrapperList.isEmpty()){
            //
            for(QuantityListOfItemsWrapper wrapRec : wareHouseQuantityListOfItemsWrapperList){
                
                ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroup = new ConnectApi.FulfillmentGroupInputRepresentation();
                fulfillmentGroup.fulfilledFromLocationId = wrapRec.LocationID;
                fulfillmentGroup.fulfillmentType = string.valueOf(wrapRec.FulFillmentType);
                
                List<OrderSummariesWrapper> orderSummaries = new List<OrderSummariesWrapper>();
                // For the OrderItemSummaryId’s in the Location
                List<ConnectApi.OrderItemSummaryInputRepresentation> orderItemSummaries = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
                
                orderSummaries.add(new OrderSummariesWrapper(wrapRec.OrderItemSummaryId,wrapRec.Quantity));
                
                //for the location that was found in loop above put in all the orderItemSummary Id's in quantities
                for(OrderSummariesWrapper wrapRecDetail : orderSummaries){        
                    ConnectApi.OrderItemSummaryInputRepresentation oisInputRepresentation = new
                        ConnectApi.OrderItemSummaryInputRepresentation();
                    oisInputRepresentation.orderItemSummaryId = wrapRecDetail.OrderItemSummaryId;
                    oisInputRepresentation.quantity = wrapRecDetail.Quantity;
                    orderItemSummaries.add(oisInputRepresentation);
                }
                
                fulfillmentGroup.orderItemSummaries = orderItemSummaries;
                fulfillmentGroups.add(fulfillmentGroup);
                
            } 
        } 
        
        if(!StoreQuantityListOfItemsWrapperList.isEmpty()){
            for(QuantityListOfItemsWrapper wrapRec : StoreQuantityListOfItemsWrapperList){
                ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroup = new ConnectApi.FulfillmentGroupInputRepresentation();
                fulfillmentGroup.fulfilledFromLocationId = wrapRec.LocationID;
                fulfillmentGroup.fulfillmentType = string.valueOf(wrapRec.FulFillmentType);
                List<OrderSummariesWrapper> orderSummaries = new List<OrderSummariesWrapper>();
                // For the OrderItemSummaryId’s in the Location
                List<ConnectApi.OrderItemSummaryInputRepresentation> orderItemSummaries = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
                
                orderSummaries.add(new OrderSummariesWrapper(wrapRec.OrderItemSummaryId,wrapRec.Quantity)); 
                
                for(OrderSummariesWrapper wrapRecDetail : orderSummaries){        
                    ConnectApi.OrderItemSummaryInputRepresentation oisInputRepresentation = new
                        ConnectApi.OrderItemSummaryInputRepresentation();
                    oisInputRepresentation.orderItemSummaryId = wrapRecDetail.OrderItemSummaryId;
                    oisInputRepresentation.quantity = wrapRecDetail.Quantity;
                    orderItemSummaries.add(oisInputRepresentation);
                }
                
                fulfillmentGroup.orderItemSummaries = orderItemSummaries;
                fulfillmentGroups.add(fulfillmentGroup);
                
            }
        }
        
        */
        
        ///////////////////////////////
        // Finaly
        /* 
                ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroup = new ConnectApi.FulfillmentGroupInputRepresentation();
                List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
                 fulfillmentGroup.fulfillmentType = 'Warehouse' ;
                 fulfillmentGroups.add(fulfillmentGroup);
                 
                 
        List<MessagingOutput> outputList = new List<MessagingOutput>(); 
        MessagingOutput output = new MessagingOutput();
        output.fulfillmentGroupsOutputlst = fulfillmentGroups;
        outputlist.add(output);   
        return outputlist;
        
    }  // Class
    private static Set<String> getOutsideMainlandSet() {
        Set<String> outsideMainlandStateCodes = new Set<String>();
        outsideMainlandStateCodes.add('AK');
        outsideMainlandStateCodes.add('HI');
        outsideMainlandStateCodes.add('AS');
        outsideMainlandStateCodes.add('GU');
        outsideMainlandStateCodes.add('MP');
        outsideMainlandStateCodes.add('PR');
        outsideMainlandStateCodes.add('VI');
        outsideMainlandStateCodes.add('UM');
        outsideMainlandStateCodes.add('FM');
        outsideMainlandStateCodes.add('MH');
        outsideMainlandStateCodes.add('PW');
        outsideMainlandStateCodes.add('AA');
        outsideMainlandStateCodes.add('AE');
        outsideMainlandStateCodes.add('AP');
        outsideMainlandStateCodes.add('CM');
        outsideMainlandStateCodes.add('CZ');
        outsideMainlandStateCodes.add('NB');
        outsideMainlandStateCodes.add('PI');
        outsideMainlandStateCodes.add('TT');
        
        return outsideMainlandStateCodes;
    }*/ 
   } // Class