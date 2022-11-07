public class CreateFulFillmentOrdertest {
/*
public class MessagingInput{
@InvocableVariable
public String Inventory_Availability_Request;
@InvocableVariable
public String OrderSummaryId;
@InvocableVariable
public String Inventory_Availability_Response;
}

public class MessagingOutput {
@InvocableVariable
public string isresult;
}


@InvocableMethod(label='CreateFulFillmentOrder')
public static List<MessagingOutput> createLocationToItemCountMap(List<MessagingInput> lstInputs) {
///////////////////////////////////////////////////////
// Setup Variables to use from Input and Queries   
///////////////////////////////////////////////////////
String OrderDeliveryGroupSummaryId          = Null;             // Order Delivery Group Id from Flow
String locationGroupIdentifiers_input       = Null;             // Location Group from Input
String locationIdentifier_input             = Null;             // Location List from Input
String stockKeepingUnits_input              = Null;             // SKU List from input   
String strInventory_Availability_Response   = Null;             // JSON from Input
String strInventory_Availability_Request    = Null;             // Input from List
list<string> SelectedFullmentLocationList = new List<String>();
list<LocationSkuOrderedWrapper> LocationSkuWrapperList = new list<LocationSkuOrderedWrapper>();
list<LocationMapWrapper> LocationMapWrapperList = new list<LocationMapWrapper>();
list<string> StockKeepingUnits = new list<string>(); 
String ShipToStore                          = Null;             // Is Ship To Store
Double DeliverToLatitude                    = 0;                // Variable used in Location Distance Calculation
Double DeliverToLongitude                   = 0;                // Variable used in Location Distance Calculation
String DeliverToState                       = Null;             // To Compare for Store Exception Rules
String DeliverToPostalCode                  = Null;             // To Compare for ShipToStore Location Match
String orderSummaryId                       = Null;             // Order Summary Id 

// MessageInput
if(lstInputs.size() > 0) {
    for(MessagingInput input : lstInputs) {
        
        ////////////////////////////////////////////////////////
        // Populate variables 
        ///////////////////////////////////////////////////////
        strInventory_Availability_Response = input.Inventory_Availability_Response;
        strInventory_Availability_Request = input.Inventory_Availability_Request;
        orderSummaryId =  input.OrderSummaryId;
        Inventory_Availability_RequestWrapper Inputwrapper = (Inventory_Availability_RequestWrapper)System.JSON.deserialize(strInventory_Availability_Request, Inventory_Availability_RequestWrapper.class) ;
        
        locationIdentifier_input         = String.join(Inputwrapper.locationIdentifiers, ',');
        stockKeepingUnits_input          = String.join(Inputwrapper.stockKeepingUnits, ',');
        locationGroupIdentifiers_input   = String.join(Inputwrapper.locationGroupIdentifiers, ',');  
    }
}
// Get needed information from OrderDeliveryGroupSummary
OrderDeliveryGroupSummary orderDeliveryGpSummaryObjRec = [select id, OrderDeliveryMethodId,
                                                            DeliverToName, DeliverToState,DeliverToPostalCode, OrderSummaryId,
                                                            OrderDeliveryMethod.Name, DeliverToLatitude, DeliverToLongitude
                                                            from OrderDeliveryGroupSummary where OrderSummaryId =: orderSummaryId limit 1];

if(orderDeliveryGpSummaryObjRec.DeliverToState != null){
    DeliverToState = orderDeliveryGpSummaryObjRec.DeliverToState;
}
// Hold DeliverToPostalCode in variable 
if(orderDeliveryGpSummaryObjRec.DeliverToPostalCode != null){
    DeliverToPostalCode = orderDeliveryGpSummaryObjRec.DeliverToPostalCode;             
}

if(orderDeliveryGpSummaryObjRec.DeliverToLatitude == null || orderDeliveryGpSummaryObjRec.DeliverToLatitude == 0.0){
    orderDeliveryGpSummaryObjRec.DeliverToLatitude = 41.7083;
    DeliverToLatitude = orderDeliveryGpSummaryObjRec.DeliverToLatitude ;
}

if(orderDeliveryGpSummaryObjRec.DeliverToLongitude == null || orderDeliveryGpSummaryObjRec.DeliverToLongitude == 0.0){
    orderDeliveryGpSummaryObjRec.DeliverToLongitude = -87.9764; 
    DeliverToLongitude = orderDeliveryGpSummaryObjRec.DeliverToLongitude;
}

if(orderDeliveryGpSummaryObjRec.OrderDeliveryMethodId != null && orderDeliveryGpSummaryObjRec.OrderDeliveryMethod.Name == 'Store'){
    SelectedFullmentLocationList.add(orderDeliveryGpSummaryObjRec.DeliverToName);  //  
    locationGroupIdentifiers_input = 'store';
    ShipToStore = 'store';
}
//
if(orderDeliveryGpSummaryObjRec.OrderSummaryId != null ){
    OrderDeliveryGroupSummaryId = orderDeliveryGpSummaryObjRec.Id;
}
// Parse and Map JSON from Inventory_Availability_Response input
WrapperClass wrap =  WrapperClass.parse(strInventory_Availability_Response);
map<string, list<WrapperClass.InventoryRecords>> inventoryRecVsLocationIdentifierMap = new map<string, list<WrapperClass.InventoryRecords>>();

for(WrapperClass.Locations locationRec : wrap.locations){
    if(!locationRec.inventoryRecords.isEmpty())  
        // Location Identifier and StockKeeping Inventory records added to Map
        inventoryRecVsLocationIdentifierMap.put(locationRec.locationIdentifier,locationRec.inventoryRecords);
}

// Get QrderItemSummary [Id's] for all StockKeeping Units from stockKeepingUnits_input that was passed to Apex Class
list<OrderItemSummary> orderItemSummaryList = [select id, StockKeepingUnit,
                                                Quantity, OrderDeliveryGroupSummaryId 
                                                from OrderItemSummary where OrderDeliveryGroupSummaryId =: OrderDeliveryGroupSummaryId 
                                                and StockKeepingUnit in : StockKeepingUnits];

// Map into a StockKeeping Map: OrderItemSummary.id, StockKeepingUnit, Quantity 
map<string, OrderItemSummary> stockKeepingUnitVsorderItemSummaryMap = new map<string, OrderItemSummary>();
for(OrderItemSummary orderItmRec : orderItemSummaryList){
    LocationSkuWrapperList.add(new LocationSkuOrderedWrapper(orderItmRec.StockKeepingUnit, orderItmRec.id, Integer.valueOf(orderItmRec.Quantity)));
    stockKeepingUnitVsorderItemSummaryMap.put(orderItmRec.StockKeepingUnit,orderItmRec);
}

// Create Location List. Select Location data based on Locations input
list<string> locationIdentifierLst = new list<string>();
locationIdentifierLst[0] = locationIdentifier_input ;
list<Schema.Location> locationLst = [select id, ExternalReference, LocationType, Latitude, Longitude, ShouldSyncWithIas,Zip_Postal_Code__c from Location where ExternalReference in : locationIdentifierLst];

// Loop through List and Location MapWrapper, calculate and calculate Distance 
for(Schema.Location locationRec : locationLst){
    
    // Calulate Distance between Order and each Location in the form of Miles
    // Location loc1 = Location.newInstance(DeliverToLatitude_input,DeliverToLongitude_input);
    Location loc1 = Location.newInstance(DeliverToLatitude,DeliverToLongitude);  // Hard Coded for testing 
    Location loc2 = Location.newInstance(locationRec.Latitude,locationRec.Longitude);
    Double dist = Location.getDistance(loc1, loc2, 'mi');
    
    //Add to List
    LocationMapWrapperList.add(new LocationMapWrapper(locationRec.ExternalReference,locationRec.LocationType, locationRec.Latitude, locationRec.Longitude, locationRec.Id, string.valueOf(locationRec.ShouldSyncWithIas), dist,locationRec.Zip_Postal_Code__c));
}
// <------------------------------------------  Need to get to here
// Create a Primary and Secondary Group, each with Locations, SKU's and Quantity
list<LocationSKUWrapper> locationSKUWrapperStoreFinalList = new list<LocationSKUWrapper>();
list<LocationSKUWrapper> locationSKUWrapperWarehouseFinalList = new list<LocationSKUWrapper>();
list<LocationSKUWrapper> finalLocationSKUWrapperList= new list<LocationSKUWrapper>();

for(LocationMapWrapper locationWrapRec : LocationMapWrapperList){
    /////////////////////////////////////////////////////////////
    // Create Secondary Group if Location Type equals 'Store'
    if(locationWrapRec.LocationType == 'Store'){
        if(inventoryRecVsLocationIdentifierMap != null && inventoryRecVsLocationIdentifierMap.containsKey(locationWrapRec.Indentifier)){
            for(WrapperClass.InventoryRecords inventoryRec : inventoryRecVsLocationIdentifierMap.get(locationWrapRec.Indentifier)){
                locationSKUWrapperStoreFinalList.add(new LocationSKUWrapper(locationWrapRec.Indentifier, inventoryRec.stockKeepingUnit, stockKeepingUnitVsorderItemSummaryMap.get(inventoryRec.stockKeepingUnit).Id, Integer.valueOf(stockKeepingUnitVsorderItemSummaryMap.get(inventoryRec.stockKeepingUnit).Quantity), locationWrapRec.LocationType, inventoryRecVsLocationIdentifierMap.get(locationWrapRec.Indentifier).size(), locationWrapRec.LocationId, locationWrapRec.ShouldSyncWithIas, locationWrapRec.Distance, inventoryRec.availableToFulfill,locationWrapRec.ZipPostalCode));                    
            }
        }   
    }   
    /////////////////////////////////////////////////////////////////////////
    // Create a Primary Warehouse if Location Type is (Warehouse, Hub or DC)
    if(locationWrapRec.LocationType == 'WM' || locationWrapRec.LocationType == 'Warehouse' || locationWrapRec.LocationType == 'Hub' || locationWrapRec.LocationType == 'DC'  ){
        if(inventoryRecVsLocationIdentifierMap != null && inventoryRecVsLocationIdentifierMap.containsKey(locationWrapRec.Indentifier)){
            for(WrapperClass.InventoryRecords inventoryRec : inventoryRecVsLocationIdentifierMap.get(locationWrapRec.Indentifier)){
                locationSKUWrapperWarehouseFinalList.add(new LocationSKUWrapper(locationWrapRec.Indentifier, inventoryRec.stockKeepingUnit, stockKeepingUnitVsorderItemSummaryMap.get(inventoryRec.stockKeepingUnit).Id, Integer.valueOf(stockKeepingUnitVsorderItemSummaryMap.get(inventoryRec.stockKeepingUnit).Quantity), locationWrapRec.LocationType, inventoryRecVsLocationIdentifierMap.get(locationWrapRec.Indentifier).size(), locationWrapRec.LocationId, locationWrapRec.ShouldSyncWithIas, locationWrapRec.Distance, inventoryRec.availableToFulfill,locationWrapRec.ZipPostalCode));                    
            }
        }   
    }              
}
 // -------------------------------------------------------------------------->>>
/////////////////////////////////////////////////////////////////
// Sort Primary and Secondary Groups by Distance
/////////////////////////////////////////////////////////////////
locationSKUWrapperWarehouseFinalList.sort(); //Primary Warehouse
locationSKUWrapperStoreFinalList.sort(); //Secondary Store

// Add Sorted List to Wrapper Class
finalLocationSKUWrapperList.addall(locationSKUWrapperStoreFinalList);     //
finalLocationSKUWrapperList.addall(locationSKUWrapperWarehouseFinalList); //

//These are the outcome quantitylist for Primary and Secondary/Store Groups
list<QuantityListOfItemsWrapper> StoreQuantityListOfItemsWrapperList = new list<QuantityListOfItemsWrapper>();
list<QuantityListOfItemsWrapper>  StoreQuantityListOfQuantityListWrapperList = new list<QuantityListOfItemsWrapper>();

list<QuantityListOfItemsWrapper> wareHouseQuantityListOfItemsWrapperList = new list<QuantityListOfItemsWrapper>();
list<QuantityListOfItemsWrapper>  wareHouseQuantityListOfQuantityListWrapperList = new list<QuantityListOfItemsWrapper>();

//These are the Primary and Store lists to store the values of SKU's if they are found for Best Match
list<QuantityListOfItemsWrapper> StoreQuantityListOfItemsWrapperList1= new list<QuantityListOfItemsWrapper>();
list<QuantityListOfItemsWrapper>  wareHouseQuantityListOfItemsWrapperList1= new list<QuantityListOfItemsWrapper>();

//These are the list to store any remaining StockKeeping Units that are unable to find a Location/Inventory in
list<LocationSKUWrapper> RemainingStoreSkUsForSecondary = new list<LocationSKUWrapper>();
list<LocationSKUWrapper>  RemainingWarehouseSKUs = new list<LocationSKUWrapper>();

//Lists to compare the final list with list contains values of SKU's
List<String> LocationFromPrimary = new List<String>();

////////////////////////////////////////////////////////////////////// 
// Step-0 If Ship-To-Store
//        Try to Ship-Complete to the Secondary Store
//        If not fall out to check Primary 
/////////////////////////////////////////////////////////////////////
boolean exceptionRule, ShipCompleteflag = false;

if(ShipToStore == 'Store'){    
    for(LocationSKUWrapper skuWrapper : locationSKUWrapperStoreFinalList){   
        if (ShipCompleteflag = false) {
            // Find Ship Complete
            if(StockKeepingUnits.size() == skuWrapper.ItemCount && skuWrapper.Quantity <= skuWrapper.availableToFulfill){ 
                if (DeliverToState == 'HI' && skuWrapper.ShouldSyncWithIas == 'HI' ) {
                    exceptionRule = true;
                } else if (DeliverToState == 'AK' && skuWrapper.ShouldSyncWithIas == 'AK' ) {
                    exceptionRule = true;
                } else if (DeliverToState == 'PR' && skuWrapper.ShouldSyncWithIas == 'PR' ) {
                    exceptionRule = true;
                } else {
                    exceptionRule = true;
                }
                if (exceptionRule = true ) {  
                    if (skuWrapper.ZipPostalCode == DeliverToPostalCode) {             
                        storeQuantityListOfItemsWrapperList.add(new QuantityListOfItemsWrapper(skuWrapper.LocationID, skuWrapper.availableToFulfill, skuWrapper.OrderItemSummaryId, skuWrapper.Quantity));                                  
                        ShipCompleteflag = true;
                    }
                    
                } 
            }    
        } }
}

exceptionRule = false;  
//////////////////////////////////////////////////////////////////// 
//Step-1: First attempt to find Ship-Complete from Primary Group   
/////////////////////////////////////////////////////////////////////
if(storeQuantityListOfItemsWrapperList.isEmpty()){
    if(ShipCompleteflag = false){
        for(LocationSKUWrapper skuWrapper : locationSKUWrapperWarehouseFinalList){   
            // Find Ship Complete
            if(StockKeepingUnits.size() == skuWrapper.ItemCount && skuWrapper.Quantity <= skuWrapper.availableToFulfill){                 
                wareHouseQuantityListOfItemsWrapperList.add(new QuantityListOfItemsWrapper(skuWrapper.LocationID, skuWrapper.availableToFulfill, skuWrapper.OrderItemSummaryId, skuWrapper.Quantity));                                
                ShipCompleteflag = true;
            }     
        } }
}   

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Step-2: if we didn't find a Primary Group Ship-Complete, now will attempt to find a Primary Group Best Match  
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
if(ShipCompleteflag = false){  
    integer SKUCOUNT = StockKeepingUnits.size() - 1 ;
    Integer count = 1;
    do {
        for(LocationSKUWrapper skuWrapper : locationSKUWrapperWarehouseFinalList){     
            //If its Store and if the itemCount is the match and Quantity<=AvailableToFullFill
            //Keep Tracking what SKU's were found
            if(SKUCOUNT == skuWrapper.ItemCount && skuWrapper.Quantity <= skuWrapper.availableToFulfill){
                wareHouseQuantityListOfItemsWrapperList.add(new QuantityListOfItemsWrapper(skuWrapper.LocationID, skuWrapper.availableToFulfill, skuWrapper.OrderItemSummaryId, skuWrapper.Quantity));
                //Get out of the loop if you found your first best match 
                LocationFromPrimary.add(skuWrapper.LocationID);
                SKUCOUNT = 1;
            }
        }  
        SKUCOUNT = SKUCOUNT - 1;
    } while (SKUCOUNT > 1);
    
    ///////////////////////////////////////////////////////////
    //Step-3 Get Remaining SKU's not found in Primary without ItemCount  
    // Best Match plus remaining SKU's
    //////////////////////////////////////////////////////////  
    List<String> LocationFromPrimary1 = new List<String>();
    for(LocationSKUWrapper skuWrapper : locationSKUWrapperWarehouseFinalList){
        if(!LocationFromPrimary.contains(skuWrapper.LocationID)){
            if(skuWrapper.Quantity <= skuWrapper.availableToFulfill){
                //Remaining  SKU's and which are try to match without Item Count check using finalLocationSKUWrapperListwarehouse
                RemainingWarehouseSKUs.add(skuWrapper);
                LocationFromPrimary1.add(skuWrapper.LocationID); 
            }
        }
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Step-4 If Still Remaining Sku's, attempt to try to Ship Complete from Secondary Group finalLocationSKUWrapperListstore
    // Try to Ship Complete from Secondary 
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    if(!RemainingWarehouseSKUs.isEmpty()){
        // Try to find all SKU's once again to Ship-Complete from store using finalLocationSKUWrapperListstore
        for(LocationSKUWrapper skuWrapper : locationSKUWrapperStoreFinalList){   
            // Find Ship Complete                         
            if(ShipCompleteflag = false){
                if(StockKeepingUnits.size() == skuWrapper.ItemCount && skuWrapper.Quantity <= skuWrapper.availableToFulfill){  
                    StoreQuantityListOfItemsWrapperList.add(new QuantityListOfItemsWrapper(skuWrapper.LocationID, skuWrapper.availableToFulfill, skuWrapper.OrderItemSummaryId, skuWrapper.Quantity));                                
                    ShipCompleteflag = true;
                }  }
        }
    }
    
    //If you can create a Secondary Group StoreQuanityList, Clear warehouseQuantityList  
    if(!StoreQuantityListOfItemsWrapperList.isEmpty()){
        wareHouseQuantityListOfItemsWrapperList.clear();
    } 
    else{  // Step 5: If Not able to Ship-Complete from Seconndary Group in 3.0in Step-4 Find Remaining Warehouse Items from Secondary Group
        for(LocationSKUWrapper skuWrapper : locationSKUWrapperStoreFinalList){
            if(!LocationFromPrimary1.contains(skuWrapper.LocationID)){
                if(skuWrapper.Quantity <= skuWrapper.availableToFulfill){
                    // Why add to List2
                    //Remaining  SKU's and which are try to match without Item Count check using finalLocationSKUWrapperListwarehouse
                    RemainingStoreSkUsForSecondary.add(skuWrapper);
                }
            }
        }
    }
    //if found put in warehouseQuantityList NOT StoreQuanityList
    if(!RemainingStoreSkUsForSecondary.isEmpty()){
        for(LocationSKUWrapper skuWrapper : RemainingStoreSkUsForSecondary){
            wareHouseQuantityListOfItemsWrapperList.add(new QuantityListOfItemsWrapper(skuWrapper.LocationID, skuWrapper.availableToFulfill, skuWrapper.OrderItemSummaryId, skuWrapper.Quantity));
        }
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  If no StoreQuantityListOfItemsWrapperList AND no warehouseQuantityListOfItemsWrapperList  
//    List2 Add List1 = warehouseQuantityListOfItemsWrapperList
//     Create OrderFulFillmentGroup  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

// This is only Warehouse?

ConnectApi.FulfillmentOrderInputRepresentation fulfillmentOrderInput = new
    ConnectApi.FulfillmentOrderInputRepresentation();
fulfillmentOrderInput.orderSummaryId =  orderSummaryId ;

fulfillmentOrderInput.orderDeliveryGroupSummaryId = OrderDeliveryGroupSummaryId;  
List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups = new
    List<ConnectApi.FulfillmentGroupInputRepresentation>();

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
    fulfillmentOrderInput.fulfillmentGroups = fulfillmentGroups;
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
    fulfillmentOrderInput.fulfillmentGroups = fulfillmentGroups; 
}

// Finaly
ConnectApi.FulfillmentOrderOutputRepresentation result = ConnectAPI.FulfillmentOrder.createFulfillmentOrders(fulfillmentOrderInput);

List<MessagingOutput> outputList = new List<MessagingOutput>();
MessagingOutput output = new MessagingOutput();
// output.isresult = result;
outputList.add(output);
return outputList;

}
public class OrderSummariesWrapper{
public string orderItemSummaryId;
public Integer quantity;
public OrderSummariesWrapper(string orderItemSummaryId,Integer quantity){
    this.orderItemSummaryId= orderItemSummaryId;
    this.quantity = quantity;
}
}
public class LocationSkuOrderedWrapper{ 
public String StockingUnit;
public String OrderItemSummaryId;
public Integer Quantity;
public LocationSkuOrderedWrapper(String StockingUnit, String OrderItemSummaryId, Integer Quantity){
    this.StockingUnit = StockingUnit;
    this.OrderItemSummaryId = OrderItemSummaryId;
    this.Quantity = Quantity;
}
}

public class LocationMapWrapper{
public String Indentifier;
public String LocationType;
public Decimal Latitude;
public Decimal Longitude;
public String LocationId;
public String ShouldSyncWithIas;
public Double Distance;
public String ZipPostalCode;
public LocationMapWrapper(String Indentifier, String LocationType, Decimal Latitude, Decimal Longitude, String LocationId, String ShouldSyncWithIas, Double Distance,String ZipPostalCode){
    this.Indentifier = Indentifier;
    this.LocationType = LocationType;
    this.Latitude = Latitude;
    this.Longitude = Longitude;
    this.LocationId = LocationId;
    this.ShouldSyncWithIas = ShouldSyncWithIas;
    this.Distance = Distance;
    this.ZipPostalCode = ZipPostalCode;
}
}

public class LocationSKUWrapper { //implements Comparable
public String StockingUnit;
public Id OrderItemSummaryId;
public Integer Quantity;
public String Indentifier;
public String LocationType;
public Integer ItemCount;
public String LocationId;
public String ShouldSyncWithIas;
public Double Distance;
public Double availableToFulfill;
public String ZipPostalCode;
public LocationSKUWrapper(String Indentifier, String StockingUnit, Id OrderItemSummaryId, Integer Quantity, String LocationType, Integer ItemCount, String LocationId, String ShouldSyncWithIas, Double Distance, Double availableToFulfill,String ZipPostalCode){
    this.StockingUnit = StockingUnit;
    this.OrderItemSummaryId = OrderItemSummaryId; 
    this.Quantity = Quantity;
    this.Indentifier = Indentifier;
    this.LocationType = LocationType;
    this.ItemCount = ItemCount;
    this.LocationId = LocationId;
    this.ShouldSyncWithIas = ShouldSyncWithIas;
    this.Distance = Distance;
    this.availableToFulfill =  availableToFulfill;
    this.ZipPostalCode = ZipPostalCode;
}

/*public Double compareTo(Object ObjToCompare) {
return Distance.CompareTo(((LocationSKUWrapper)ObjToCompare).Distance);
}
*/
//}
/*
public class QuantityListOfItemsWrapper{
public String LocationID;
public Double FulFillmentType;
public String OrderItemSummaryId;
public Integer Quantity;
public QuantityListOfItemsWrapper(String LocationID, Double FulFillmentType, String OrderItemSummaryId, Integer Quantity){
    this.LocationID = LocationID;
    this.FulFillmentType = FulFillmentType;
    this.OrderItemSummaryId = OrderItemSummaryId;
    this.Quantity = Quantity;
}
} 
public class Inventory_Availability_RequestWrapper {
public List<string> locationIdentifiers;
public List<string> stockKeepingUnits;
public List<string> locationGroupIdentifiers;
public Boolean useCache;
}*/
}