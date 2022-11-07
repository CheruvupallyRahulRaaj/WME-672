public class WM_ShipmentLineInfo {
    @InvocableMethod(label='Process Shipment Line Info')
    public static List<Response> processShipmentLineInfo(List<Request> requests) {
        List<Response> results = new List<Response>();
        system.debug('shipmantshrooq');
        
        for (Request request : requests) {
            Response response = new Response();
            results.add(response);
            
            //handle bad input
            if (request.fulfillmentOrderLineItemIds == null || request.fulfillmentOrderLineItemIds.size() == 0 ) {
                continue;
            }
            
            List<ConnectApi.FulfillmentOrderLineItemInputRepresentation> fulfillmentOrderItemsToCancel = request.fulfillmentOrderItems.clone();
            List<ConnectApi.OCIFulfillReservationSingleInputRepresentation> fulfillmentReservations = new  List<ConnectApi.OCIFulfillReservationSingleInputRepresentation>();
            List<ConnectApi.FulfillmentOrderLineItemInputRepresentation> itemsToRemove = new List<ConnectApi.FulfillmentOrderLineItemInputRepresentation>();
            List<FulfillmentOrderLineItem> fulfillmentOrderLineItemList = [Select Id,FulfillmentOrderLineItemNumber,
                                                                           Product2.StockKeepingUnit,FulfillmentOrder.FulfillmentOrderNumber,Quantity 
                                                                           from FulfillmentOrderLineItem where Id In:request.fulfillmentOrderLineItemIds];
            Map<String,String> mapOfLineNumberWithFOrderLineItemId = new Map<String,String>();
            Map<String,String> mapOfSKUWithFOrderLineItemId = new Map<String,String>();
            for(FulfillmentOrderLineItem fOrderLineItem: fulfillmentOrderLineItemList){
                Integer lineNumber = Integer.valueOf(fOrderLineItem.FulfillmentOrderLineItemNumber);
                mapOfLineNumberWithFOrderLineItemId.put(String.valueOf(lineNumber),fOrderLineItem.Id);
                mapOfSKUWithFOrderLineItemId.put(fOrderLineItem.Id,fOrderLineItem.Product2.StockKeepingUnit);
            }
            
            try {
                system.debug('request.lineInfoResult '+request.lineInfoResult);
                Map<String, Object> lineInfoRep = (Map<String, Object>) JSON.deserializeUntyped(request.lineInfoResult);
                //Valid JSON, set canceled items
                response.fulfillmentOrderItemsToCancel = fulfillmentOrderItemsToCancel;
                response.remainingFulfillmentReservations = new List<ConnectApi.OCIFulfillReservationSingleInputRepresentation>();
                
                List<Object> lineInfoList = (List<Object>) lineInfoRep.get('LineInfo');
                system.debug('**LineInforList**'+lineInfoList);
                if (lineInfoList == null) {
                    continue;  //All items will be canceled 
                }
                
                //setup potential reservations with 0 and add qty as we process
                for (ConnectApi.OCIFulfillReservationSingleInputRepresentation fulfillmentReservation : request.potentialFulfillmentReservations) {
                    fulfillmentReservation.quantity = 0;
                }
                
                           List<Integer> listOfPickNumbersFromLineInfo = new List<Integer>();
                
                for (Object lineInfoObject : lineInfoList) {
                    Map<String, Object> lineInfo = (Map<String, Object>) lineInfoObject;
                        listOfPickNumbersFromLineInfo.add(Integer.valueOf(lineInfo.get('pick_line_nbr')));
                   
                }
                for (Object lineInfoObject : lineInfoList) {
                    Map<String, Object> lineInfo = (Map<String, Object>) lineInfoObject;
                    Integer quantity = Integer.valueOf(lineInfo.get('qty_shipped'));
                    Integer pickNumber = Integer.valueOf(lineInfo.get('pick_line_nbr'));
                    system.debug('**pickNumber**'+pickNumber);
                    ConnectApi.FulfillmentOrderLineItemInputRepresentation item = new  ConnectApi.FulfillmentOrderLineItemInputRepresentation();
                    ConnectApi.OCIFulfillReservationSingleInputRepresentation reservation = new  ConnectApi.OCIFulfillReservationSingleInputRepresentation();
                    for(FulfillmentOrderLineItem fOrderLineItem: fulfillmentOrderLineItemList){
                        Integer lineNumber = Integer.valueOf(fOrderLineItem.FulfillmentOrderLineItemNumber);
                        if(!listOfPickNumbersFromLineInfo.contains(lineNumber)){
                            
                    ConnectApi.FulfillmentOrderLineItemInputRepresentation item1 = new  ConnectApi.FulfillmentOrderLineItemInputRepresentation();
                            item1.fulfillmentOrderLineItemId = fOrderLineItem.Id;
                            item1.quantity = fOrderLineItem.Quantity;
                            if((!itemsToRemove.contains(item1)) && item1.quantity > 0){
                               itemsToRemove.add(item1);  
                            }
                                
                        }
                        system.debug('**pickNumber**'+lineNumber);
                        if(String.valueOf(lineNumber) == String.valueOf(pickNumber)){
                            system.debug('***LineItemIdentified***');
                            item.fulfillmentOrderLineItemId = mapOfLineNumberWithFOrderLineItemId.get(String.valueOf(pickNumber));
                            item.quantity = fOrderLineItem.Quantity;
                            reservation.actionRequestId = IASUtility.NewGuid()[0];
                            reservation.externalRefId =   fOrderLineItem.FulfillmentOrder.FulfillmentOrderNumber;  
                            reservation.locationIdentifier = request.locationExternalReference;
                            reservation.quantity = 0;
                            reservation.stockKeepingUnit = mapOfSKUWithFOrderLineItemId.get(fOrderLineItem.Id);
                            
                           reservation.quantity += quantity;
                            system.debug('***Reservation***'+reservation);
                            if (quantity >= item.quantity) {
                                //itemsToRemove.clear();
                            } else {
                                item.quantity -= quantity;
                                itemsToRemove.add(item);
                            }
                            fulfillmentReservations.add(reservation);
                        }
                        
                    }
                    
                    
                    
                    
                }
            } catch (Exception e) {
                system.debug('****Exception occurred****'+e);
                system.debug('Exception Line  '+e.getLineNumber());
                //If the JSON isn't valid, continue
                continue;
            }
            
            //if we are here, we have valid JSON and items to process
            //remove 0 quantity items
            system.debug('**itemsToRemove**'+itemsToRemove);
            //fulfillmentOrderItemsToCancel =  itemsToRemove;
            
            /* for (ConnectApi.FulfillmentOrderLineItemInputRepresentation item : itemsToRemove) {
for (Integer i = 0; i < fulfillmentOrderItemsToCancel.size(); i++) {
if (item.fulfillmentOrderLineItemId == fulfillmentOrderItemsToCancel.get(i).fulfillmentOrderLineItemId) {
fulfillmentOrderItemsToCancel.remove(i);
break;
}
}
}*/
            response.fulfillmentOrderItemsToCancel = itemsToRemove;
            for (ConnectApi.OCIFulfillReservationSingleInputRepresentation reservation : fulfillmentReservations) {
                if (reservation.quantity > 0) {
                    response.remainingFulfillmentReservations.add(reservation);
                }
            }
        }
        
        system.debug('**** '+results);
        
        return results;
    }
    
    public class Request {
        @InvocableVariable
        public List<ConnectApi.FulfillmentOrderLineItemInputRepresentation> fulfillmentOrderItems;
        @InvocableVariable
        public List<ConnectApi.OCIFulfillReservationSingleInputRepresentation> potentialFulfillmentReservations;
        @InvocableVariable
        public String locationExternalReference;
        @InvocableVariable
        public List<Id> fulfillmentOrderLineItemIds;        
        @InvocableVariable
        public String lineInfoResult;
    }
    
    public class Response {
        @InvocableVariable
        public List<ConnectApi.FulfillmentOrderLineItemInputRepresentation> fulfillmentOrderItemsToCancel;
        @InvocableVariable
        public List<ConnectApi.OCIFulfillReservationSingleInputRepresentation> remainingFulfillmentReservations;
    }
}