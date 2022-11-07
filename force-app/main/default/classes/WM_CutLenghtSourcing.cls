public class WM_CutLenghtSourcing {
  @InvocableMethod(label='Cut Length Sourcing V2')
  public static List<Response> getFulfillmentGroups(List<WM_SourcingRequest> requestList) {
    List<Response> responses = new List<Response>();
    System.debug('In Cut Length Sourcing');
      // SV : Check if requestList is not empty
      if(requestList.size() !=0){
          
      

    for (WM_SourcingRequest request : requestList) {
      //create and add this response to list
      Response response = new Response();
      response.fullyAllocated = true; //only cases when false handled below
      responses.add(response);

      //create and add these fulfillmentGroups to the current response
      List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
      response.fulfillmentGroups = fulfillmentGroups;

      //check for a bad request
      if (
        request.locations == null ||
        request.locations.size() == 0 ||
        request.deliveryGroup == null ||
        request.locationsFromOCI == null ||
        request.locationsFromOCI.size() == 0 ||
        request.lineItems == null ||
        request.lineItems.size() == 0
      ) {
        response.fullyAllocated = false;
        continue;
      }

      //Determine items required quantities
      Map<String, Decimal> quantityRequiredMap = request.getQuantityRequiredMap();

      //Set maps from request
      Map<String, ConnectApi.OCILocationAvailabilityOutputRepresentation> inventoryReferenceLocationMap = request.getInventoryReferenceLocationMap();
      Map<String, Schema.Location> primaryLocationMapByRef = request.getPrimaryLocationMap();
      Map<String, Schema.Location> storeMapByRef = request.getStoreMap();
      Map<String, Schema.Location> allLocationMap = request.getAllLocationMap();

      Map<String, String> locationIdToRefMap = request.getLocationIdToRefMap();
      Map<String, List<OrderItemSummary>> skuItemsMap = request.getSKUItemsMap();

      //STEP SUB-ZERO (Flawless Victory!)
      //Handle pre-assigned locations via wmWarehouse__c
      Map<String, ConnectApi.FulfillmentGroupInputRepresentation> predefinedFulfillmentLocations = new Map<String, ConnectApi.FulfillmentGroupInputRepresentation>();
      for (OrderItemSummary lineItem : request.lineItems){
          if (lineItem.wmWarehouse__c != null) {
              ConnectApi.OrderItemSummaryInputRepresentation oisInput = new ConnectApi.OrderItemSummaryInputRepresentation();
              oisInput.orderItemSummaryId = (lineItem.Id == null)
                  ? lineItem.Name
                  : lineItem.Id;
              oisInput.quantity =
                  lineItem.QuantityOrdered -
                  lineItem.QuantityAllocated -
                  lineItem.QuantityCanceled;
              if (oisInput.quantity == 0) {
                  continue; //handle situation where assigned items are already allocated
              }
              
              if (predefinedFulfillmentLocations.containsKey(lineItem.wmWarehouse__c)) {
                  ConnectApi.FulfillmentGroupInputRepresentation existingFulfillmentGroup = predefinedFulfillmentLocations.get(
                      lineItem.wmWarehouse__c
                  );
                  existingFulfillmentGroup.orderItemSummaries.add(oisInput);
                  List<ConnectApi.OrderItemSummaryInputRepresentation> additionalItems = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
                  additionalItems.add(oisInput);
                  //This line will not be needed if we iterate through FGs in post processing
                  quantityRequiredMap = remainingQuantityRequiredMap(
                      quantityRequiredMap,
                      additionalItems,
                      skuItemsMap
                  );
              } else if (
                  primaryLocationMapByRef.containsKey(lineItem.wmWarehouse__c)
              ) {
                  Schema.Location location = primaryLocationMapByRef.get(
                      lineItem.wmWarehouse__c
                  );
                  ConnectApi.FulfillmentGroupInputRepresentation newFulfillmentGroup = new ConnectApi.FulfillmentGroupInputRepresentation();
                  newFulfillmentGroup.orderItemSummaries = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
                  newFulfillmentGroup.orderItemSummaries.add(oisInput);
                  newFulfillmentGroup.fulfilledFromLocationId = location.Id;
                  newFulfillmentGroup.fulfillmentType = getFulfillmentType(
                      (location.LocationType == 'Store' ||
                       location.LocationType == 'Hub'),
                      request.isStoreShipment
                  );
                  predefinedFulfillmentLocations.put(
                      lineItem.wmWarehouse__c,
                      newFulfillmentGroup
                  );
                  //we weren't given requirements, so assuming that locations explicitly defined are used only for the items specified
                  //If this requirement changes, then we will likely need to iterate through the FGs and perform the 3 lines below
                  //plus any additional logic around determining items in the same location
                  primaryLocationMapByRef.remove(location.ExternalReference);
                  fulfillmentGroups.add(newFulfillmentGroup);
                  quantityRequiredMap = remainingQuantityRequiredMap(
                      quantityRequiredMap,
                      newFulfillmentGroup.orderItemSummaries,
                      skuItemsMap
                  );
              } else if (storeMapByRef.containsKey(lineItem.wmWarehouse__c)) {
                  Schema.Location location = storeMapByRef.get(
                      lineItem.wmWarehouse__c
                  );
                  ConnectApi.FulfillmentGroupInputRepresentation newFulfillmentGroup = new ConnectApi.FulfillmentGroupInputRepresentation();
                  newFulfillmentGroup.orderItemSummaries = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
                  newFulfillmentGroup.orderItemSummaries.add(oisInput);
                  newFulfillmentGroup.fulfilledFromLocationId = location.Id;
                  newFulfillmentGroup.fulfillmentType = getFulfillmentType(
                      (location.LocationType == 'Store' ||
                       location.LocationType == 'Hub'),
                      request.isStoreShipment
                  );
                  predefinedFulfillmentLocations.put(
                      lineItem.wmWarehouse__c,
                      newFulfillmentGroup
                  );
                  //we weren't given requirements, so assuming that locations explicitly defined are used only for the items specified
                  //If this requirement changes, then we will likely need to iterate through the FGs and perform the 3 lines below
                  //plus any additional logic around determining items in the same location
                  storeMapByRef.remove(location.ExternalReference);
                  fulfillmentGroups.add(newFulfillmentGroup);
                  quantityRequiredMap = remainingQuantityRequiredMap(
                      quantityRequiredMap,
                      newFulfillmentGroup.orderItemSummaries,
                      skuItemsMap
                  );
              } else {
                  //Location is not being considered, but since it is explicitly defined we still need to grab it from all available locations
                  Schema.Location location = allLocationMap.get(
                      lineItem.wmWarehouse__c
                  );
                  ConnectApi.FulfillmentGroupInputRepresentation newFulfillmentGroup = new ConnectApi.FulfillmentGroupInputRepresentation();
                  newFulfillmentGroup.orderItemSummaries = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
                  newFulfillmentGroup.orderItemSummaries.add(oisInput);
                  newFulfillmentGroup.fulfilledFromLocationId = location.Id;
                  newFulfillmentGroup.fulfillmentType = getFulfillmentType(
                      (location.LocationType == 'Store' ||
                       location.LocationType == 'Hub'),
                      request.isStoreShipment
                  );
                  predefinedFulfillmentLocations.put(
                      lineItem.wmWarehouse__c,
                      newFulfillmentGroup
                  );
                  fulfillmentGroups.add(newFulfillmentGroup);
                  quantityRequiredMap = remainingQuantityRequiredMap(
                      quantityRequiredMap,
                      newFulfillmentGroup.orderItemSummaries,
                      skuItemsMap
                  );
              }
          }
          
      }
        
        ConnectApi.FulfillmentGroupInputRepresentation sameStoreFulfillmentGroup = null;
        
        //STEP 0: is this ship to store and the store has items?
        if (request.isStoreShipment) {
            Schema.Location location = WM_DetermineDestinationStoreLocation.getDestinationStore(
                request.deliveryGroup,
                request.locations
            );
            
            if (location != null) {
                //we are just going to get what we can from this store
                response.deliverToLocationId = location.Id;
                Map<String, Schema.Location> sameStoreMapById = new Map<String, Schema.Location>();
                sameStoreMapById.put(location.ExternalReference, location);
                
                sameStoreFulfillmentGroup = getBestFulfillmentGroup(
                    quantityRequiredMap,
                    sameStoreMapById,
                    request
                );
                if (sameStoreFulfillmentGroup != null) {
                    //we have a group to add
                    fulfillmentGroups.add(sameStoreFulfillmentGroup);
                    
                    //setup remaining quantity map
                    quantityRequiredMap = remainingQuantityRequiredMap(
                        quantityRequiredMap,
                        sameStoreFulfillmentGroup.orderItemSummaries,
                        skuItemsMap
                    );
                    
                    if (quantityRequiredMap.isEmpty()) {
                        //Congratulations!  All the items are already at the store
                        continue;
                    }
                }
                
                //make sure we don't consider this location again
                if (storeMapByRef.containsKey(location.ExternalReference)) {
                    storeMapByRef.remove(location.ExternalReference);
                } else if (
                    primaryLocationMapByRef.containsKey(location.ExternalReference)
                ) {
                    primaryLocationMapByRef.remove(location.ExternalReference);
                }
            }
        }
        
        //STEP 1-7: Determine if primary location which could fulfill any part of this order
        Map<String, Decimal> remainingRequiredMap = quantityRequiredMap.clone();
        system.debug('****remainingRequiredMap**** ' + remainingRequiredMap);
        for (Integer i = 0; i < 3; i++) {
            //we are going to loop through this three times unless we finish early
            ConnectApi.FulfillmentGroupInputRepresentation primaryFulfillmentGroup;
            primaryFulfillmentGroup = getBestFulfillmentGroup(
                remainingRequiredMap,
                primaryLocationMapByRef,
                request
            );
            
            if (primaryFulfillmentGroup == null) {
                //nothing for us here, empty the primary map and break
                primaryLocationMapByRef.clear();
                break;
            }
            
            fulfillmentGroups.add(primaryFulfillmentGroup);
            remainingRequiredMap = remainingQuantityRequiredMap(
                remainingRequiredMap,
                primaryFulfillmentGroup.orderItemSummaries,
                skuItemsMap
            );
            if (remainingRequiredMap.isEmpty()) {
                //Congratulations!  All the items fulfilled
                break;
            } else {
                //otherwise, make sure we don't consider this location again
                primaryLocationMapByRef.remove(
                    locationIdToRefMap.get(
                        primaryFulfillmentGroup.fulfilledFromLocationId
                    )
                );
            }
        }
        
        if (remainingRequiredMap.isEmpty()) {
            //Make sure we aren't done
            continue;
      }

      //STEP 8-9: Check if a store can ship the entire order
      ConnectApi.FulfillmentGroupInputRepresentation shipCompleteStoreFulfillmentGroup;
      shipCompleteStoreFulfillmentGroup = getBestFulfillmentGroup(
        quantityRequiredMap,
        storeMapByRef,
        request
      );

      if (shipCompleteStoreFulfillmentGroup == null) {
        //nothing for us in stores, empty the map
        storeMapByRef.clear();
      } else {
        Map<String, Decimal> storeCompleteRequiredMap = remainingQuantityRequiredMap(
          quantityRequiredMap,
          shipCompleteStoreFulfillmentGroup.orderItemSummaries,
          skuItemsMap
        );
        if (storeCompleteRequiredMap.isEmpty()) {
          //able to ship from store, clear list and create new
          fulfillmentGroups.clear();
          if (sameStoreFulfillmentGroup != null) {
            fulfillmentGroups.add(sameStoreFulfillmentGroup);
          }
          fulfillmentGroups.add(shipCompleteStoreFulfillmentGroup);
          continue; //Completely fulfilled!
        }
      }

      //STEP 10-11: Fulfill the rest considering all locations
      Map<String, Schema.Location> allLocationsMap = new Map<String, Schema.Location>();
      allLocationsMap.putAll(storeMapByRef);
      allLocationsMap.putAll(primaryLocationMapByRef);

      while (!remainingRequiredMap.isEmpty()) {
        ConnectApi.FulfillmentGroupInputRepresentation allFulfillmentGroup = getBestFulfillmentGroup(
          remainingRequiredMap,
          allLocationsMap,
          request
        );

        if (allFulfillmentGroup == null) {
          //nothing for us anymore, set failed and break
          response.fullyAllocated = false;
          break;
        }

        fulfillmentGroups.add(allFulfillmentGroup); //add found fulfillment group
        allLocationsMap.remove(
          locationIdToRefMap.get(allFulfillmentGroup.fulfilledFromLocationId)
        ); //remove location from consideration
        remainingRequiredMap = remainingQuantityRequiredMap(
          remainingRequiredMap,
          allFulfillmentGroup.orderItemSummaries,
          skuItemsMap
        ); //determine remaining items
      }
      //We are done regardless of what happened above
    }

    System.debug(responses);
    System.debug('AAA:*****************Responses Start***********************');
    for(Response responseRecord : responses){

      // @InvocableVariable
      // public List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups;
      // @InvocableVariable
      // public Boolean fullyAllocated;
      // @InvocableVariable
      // public String deliverToLocationId;
      System.debug('AAA Response Start: --------------------');
      System.debug('AAA: Fully Allocated:' + responseRecord.fullyAllocated);
      System.debug('AAA: deliveryToLocationId:' + responseRecord.deliverToLocationId);
      System.debug('AAA!!!!!!!!!!!!!!!!!!Fulfillment Groups Start!!!!!!!!!!!!!!!!!!!!!');
      for(ConnectApi.FulfillmentGroupInputRepresentation fgir : responseRecord.fulfillmentGroups){
        System.debug('AAA@@@@@@@@@@@Fulfillment Group Start@@@@@@@@@@@@@');
        System.debug('AAAfulfilledFromLocationId:' + fgir.fulfilledFromLocationId);
        System.debug('AAAfulfillmentType:' + fgir.fulfillmentType);
        System.debug('AAA#################Order Item Summaries Start ################');
        for(ConnectApi.OrderItemSummaryInputRepresentation oisi : fgir.orderItemSummaries){
          System.debug('AAA$$$$$$$$$$$$$$$Order Item Summary Start$$$$$$$$$$$$$$$$$$$$$$$$$');
          System.debug('AAA OrderItemSummaryId:' + oisi.orderItemSummaryId);
          System.debug('AAA Quantity:' + oisi.quantity);
          System.debug('AAA$$$$$$$$$$$$$$$Order Item Summary End$$$$$$$$$$$$$$$$$$$$$$$$$');
        }
        System.debug('AAA#################Order Item Summaries End ################');

        System.debug('AAA@@@@@@@@@@@Fulfillment Group End@@@@@@@@@@@@@');
      }
      System.debug('AAA//////////Fulfillment Groups End////////////////////');
      System.debug('AAA Response End: --------------------');
    }
    System.debug('AAA:*****************Responses End***********************');
          //SV : Null check for request List
      }
    return responses;
  }

  //get best fulfillment location from map based on greatest quantity and then closest
  private static ConnectApi.FulfillmentGroupInputRepresentation getBestFulfillmentGroup(
    Map<String, Decimal> requiredMap,
    Map<String, Schema.Location> locationMap,
    WM_SourcingRequest request
  ) {
    ConnectApi.FulfillmentGroupInputRepresentation bestFulfillmentGroup = null; //default
    Map<String, ConnectApi.OCILocationAvailabilityOutputRepresentation> ociMap = request.getInventoryReferenceLocationMap();
    Map<String, List<OrderItemSummary>> skuItemsMap = request.getSKUItemsMap();
    Boolean isSTS = request.isStoreShipment;

    Decimal bestQuantity = 0;
    Map<Schema.Location, ConnectApi.FulfillmentGroupInputRepresentation> bestFulfillmentGroups = new Map<Schema.Location, ConnectApi.FulfillmentGroupInputRepresentation>();
    for (String locationRefId : locationMap.keySet()) {
      Schema.Location location = locationMap.get(locationRefId);
      List<ConnectApi.OrderItemSummaryInputRepresentation> availableItems = getItemsAvailableFromLocation(
        requiredMap,
        location,
        ociMap.get(locationRefId),
        skuItemsMap
      );

      //determine number available from this location
      Decimal thisLocationQuantity = 0;
      for (
        ConnectApi.OrderItemSummaryInputRepresentation item : availableItems
      ) {
        thisLocationQuantity += item.quantity;
      }

      if (thisLocationQuantity > 0 && thisLocationQuantity >= bestQuantity) {
        if (thisLocationQuantity > bestQuantity) {
          //if it is better than clear the others
          bestFulfillmentGroups.clear();
          bestQuantity = thisLocationQuantity;
        }

        ConnectApi.FulfillmentGroupInputRepresentation newBestGroup = new ConnectApi.FulfillmentGroupInputRepresentation();
        newBestGroup.orderItemSummaries = availableItems;
        newBestGroup.fulfilledFromLocationId = location.Id;
        newBestGroup.fulfillmentType = getFulfillmentType(
          (location.LocationType == 'Store' ||
          location.LocationType == 'Hub'),
          isSTS
        );
        bestFulfillmentGroups.put(location, newBestGroup);
      }
    }

    if (bestFulfillmentGroups.size() == 1) {
      //set our single group to return
      bestFulfillmentGroup = bestFulfillmentGroups.values()[0];
    } else if (bestFulfillmentGroups.size() > 1) {
      //tied: determine closest location and use its group
      List<Schema.Location> bestLocations = new List<Schema.Location>(
        bestFulfillmentGroups.keySet()
      );
      Schema.Location bestLocation = request.determineClosestLocation(
        bestLocations,
        bestLocations[0]
      );
      bestFulfillmentGroup = bestFulfillmentGroups.get(bestLocation);
    }
    system.debug('bestFulfillmentGroup ' + bestFulfillmentGroup);

    return bestFulfillmentGroup;
  }

  //get fulfillment type
  private static String getFulfillmentType(
    boolean isFromStore,
    boolean isToStore
  ) {
    String fulfillmentType;

    if (isFromStore) {
      fulfillmentType = (isToStore)
        ? 'Store/Hub To Store'
        : 'Store/Hub to Home';
    } else {
      fulfillmentType = (isToStore)
        ? 'Warehouse to Store'
        : 'Warehouse to Home';
    }

    return fulfillmentType;
  }

  //determine items available from this location
  private static List<ConnectApi.OrderItemSummaryInputRepresentation> getItemsAvailableFromLocation(
    Map<String, Decimal> quantityRequiredMap,
    Schema.Location location,
    ConnectApi.OCILocationAvailabilityOutputRepresentation ociLocation,
    Map<String, List<OrderItemSummary>> skuItemsMap
  ) {
    List<ConnectApi.OrderItemSummaryInputRepresentation> availableItems = new List<ConnectApi.OrderItemSummaryInputRepresentation>();

    if (ociLocation == null) {
      //This location doesn't have loaded inventory, nothing can be done
      return availableItems;
    }

    for (
      ConnectApi.OCIInventoryRecordOutputRepresentation inventoryRecord : ociLocation.inventoryRecords
    ) {
      Decimal requestedAmountForSku = quantityRequiredMap.get(
        inventoryRecord.stockKeepingUnit
      );
     
      if (requestedAmountForSku != null) {
        Decimal amountAvailable = Math.min(
          requestedAmountForSku,
          inventoryRecord.availableToFulfill
        );

        if (amountAvailable > 0) {
          Decimal originalQuantity = 0;
          for (
            OrderItemSummary item : skuItemsMap.get(
              inventoryRecord.stockKeepingUnit
            )
          ) {
            Decimal relevantQuantity =
              item.QuantityOrdered -
              item.QuantityAllocated -
              item.QuantityCanceled;
            originalQuantity += relevantQuantity;
          }

          Decimal alreadyAddressedQuantity =
            originalQuantity - requestedAmountForSku;
          for (
            OrderItemSummary item : skuItemsMap.get(
              inventoryRecord.stockKeepingUnit
            )
          ) {
            Decimal relevantQuantity =
              item.QuantityOrdered -
              item.QuantityAllocated -
              item.QuantityCanceled;
            if (
              alreadyAddressedQuantity < relevantQuantity &&
              amountAvailable > 0
            ) {
                
                {
                    //we can source this item with the amount available
                    relevantQuantity = Math.min(
                        relevantQuantity - alreadyAddressedQuantity,
                        amountAvailable
                    );
                }
                ConnectApi.OrderItemSummaryInputRepresentation oisInput = new ConnectApi.OrderItemSummaryInputRepresentation();
              oisInput.orderItemSummaryId = (item.Id == null)
                ? item.Name
                : item.Id;
              oisInput.quantity = relevantQuantity;
              availableItems.add(oisInput);
              alreadyAddressedQuantity = 0;
              amountAvailable -= relevantQuantity; //reduce amount available for next eval
            } else if (alreadyAddressedQuantity >= relevantQuantity) {
              //We already sourced this item, skip it and reduce addressed quantity for next eval
              alreadyAddressedQuantity -= relevantQuantity;
            }
          }
        }
      }
    }

    return availableItems;
  }

  //create new map of quantity required based on previous map and item list
  private static Map<String, Decimal> remainingQuantityRequiredMap(
    Map<String, Decimal> quantityRequiredMap,
    List<ConnectApi.OrderItemSummaryInputRepresentation> items,
    Map<String, List<OrderItemSummary>> skuItemsMap
  ) {
    Map<String, Decimal> remainingMap = quantityRequiredMap.clone();

    for (String sku : quantityRequiredMap.keySet()) {
      Decimal quantityRequired = quantityRequiredMap.get(sku);

      for (OrderItemSummary item : skuItemsMap.get(sku)) {
        String id = (item.Id == null) ? item.Name : item.Id;
        for (ConnectApi.OrderItemSummaryInputRepresentation oisInput : items) {
          if (oisInput.orderItemSummaryId == id) {
            if (quantityRequired == oisInput.quantity) {
              remainingMap.remove(sku); //all quantity from this location, remove from map
            } else {
              quantityRequired -= oisInput.quantity;
              remainingMap.put(sku, quantityRequired); //deduct from required
            }
          }
        }
      }
    }

    return remainingMap;
  }

  //class for response
  public class Response {
    @InvocableVariable
    public List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups;
    @InvocableVariable
    public Boolean fullyAllocated;
    @InvocableVariable
    public String deliverToLocationId;
  }
}