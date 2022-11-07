/**
* @description       : Service Class for Order Fulfillment (Pick Out) to JDA
* @author            : schauhan@liveareacx.com
* @last modified on  : 02-09-2021
* @last modified by  : schauhan@liveareacx.com
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   01-07-2021   schauhan@liveareacx.com   Initial Version
* 2.0   14-10-2022   manohar.alla@genzeon.com  Second Version
**/
public class WM_PickOutService {
    
    /*Method Name : pickOut
*Accepting Parameters :  Order FulFillment Ids
*Purpose : Invocable from a flow to execute a call to an external system
*/
    @InvocableMethod(label='PickOutService')
    public static List<Boolean> pickOutService (List<Id> ordrFulfillmntIds) {
      List<Boolean> result = new List<Boolean>();
      // WME-230, Developer: Satish V
      //for(Id str:ordrFulfillmntIds){
      //result.add(true);
      //} 
      //pickOutServiceAsync(ordrFulfillmntIds);
      result.addAll(pickOutServiceAsync(ordrFulfillmntIds));
      return result;
    }
    
    // WME-230, Developer: Satish V
    //@future(callout=true)
    //public static void pickOutServiceAsync (List<Id> ordrFulfillmntIds) {
    public static List<Boolean> pickOutServiceAsync (List<Id> ordrFulfillmntIds) {
       system.debug('Entered the Flow with ID as: '+ordrFulfillmntIds);
       Map<String,Boolean> mapOfFulFillmentIDWithResult = new Map<String,Boolean>();
       List<FulfillmentOrder>  fulfilList = new list<FulfillmentOrder> ();
        List<Boolean> result = new List<Boolean>();
        
        /* Start: WME-266 Limit Exception on picks for order more than 50 Lines ******/
        Map<Id,FulfillmentOrder> fulfillmentOrderMap = new Map<Id,FulfillmentOrder>([Select Id, AccountId, Account.IsPersonAccount,Account.ParentId,DeliveryMethodId, FulfilledFromLocationId, FulfilledToName, FulfilledToStreet, FulfillmentOrderNumber,
                FulfilledToCity, FulfilledToState, FulfilledToPostalCode, FulfilledToCountry, FulfilledToLatitude,
                FulfilledToLongitude, FulfilledToGeocodeAccuracy, FulfilledToAddress, FulfilledToEmailAddress, 
                FulfilledToPhone, ItemCount, Status, StatusCategory, Type, TypeCategory, TotalProductAmount, 
                TotalAdjustmentAmount, TotalDeliveryAmount, TotalProductTaxAmount, TotalAdjustmentTaxAmount, 
                TotalDeliveryTaxAmount, TotalAmount, TotalTaxAmount, OrderId, OrderSummaryId, 
                InvoiceId, GrandTotalAmount, IsSuspended, TotalDeliveryAdjustAmount, TotalDeliveryAdjustTaxAmount,
                TaxLocaleType, BillToContactId, TotalProductAmtWithTax, TotalAdjustmentAmtWithTax,
                TotalDeliveryAmtWithTax, TotalDeliveryAdjustAmtWithTax,dummyInvoiceNumberForSTSFS__c,JSON_sent_to_TIBCO__c,
                FulfilledToShippingStreet2__c,FulfilledToShippingStreet3__c,FulfilledToShippingStreet4__c,
                van_route__c,van_route_seq_nbr__c,JDAFulfillmentOrderNumber__c,Order_Delivery_Group_Summary__c,
                (Select Id,FulfillmentOrderId,FulfillmentOrder.InvoiceId,FulfillmentOrder.JDAFulfillmentOrderNumber__c,FulfillmentOrder.FulfilledFromLocation.ExternalReference,Quantity,UnitPrice,
                 TotalPrice,Quantity_Received__c,Quantity_Credited__c,TotalAdjustmentAmount,Quantity_Fulfilled__c,FulfillmentOrderLineItemNumber,
                 OriginalQuantity,OrderItemId,OrderItemSummaryId,Product2Id from FulfillmentOrderLineItems where type = 'Order Product' and quantity > 0 order by CreatedDate asc), 
                 DeliveryMethod.Name,DeliveryMethod.Description,DeliveryMethod.ReferenceNumber,FulfilledFromLocation.Name,FulfilledFromLocation.ExternalReference,FulfilledFromLocation.LocationType, 
                 OrderSummary.OrderNumber,OrderSummary.OriginalOrderId,OrderSummary.CreatedDate,OrderSummary.PoNumber__c,OrderSummary.Contact__c,OrderSummary.associateID__c,OrderSummary.exchangeOrderNumber__c,OrderSummary.SalesChannel.Saleschannelname,
                 Order_Payment_Summary__c,Order_Delivery_Group_Summary__r.DeliverToLocation__r.ExternalReference,Order_Delivery_Group_Summary__r.EmailAddress, Order_Delivery_Group_Summary__r.PhoneNumber, Order_Delivery_Group_Summary__r.DeliverToName, Order_Delivery_Group_Summary__r.DeliverToStreet, 
                 Order_Delivery_Group_Summary__r.DeliverToCity, Order_Delivery_Group_Summary__r.DeliverToState, Order_Delivery_Group_Summary__r.DeliverToPostalCode, Order_Delivery_Group_Summary__r.DeliverToCountry, 
                 Order_Delivery_Group_Summary__r.DeliverToLatitude, Order_Delivery_Group_Summary__r.DeliverToLongitude, Order_Delivery_Group_Summary__r.DeliverToGeocodeAccuracy,Order_Delivery_Group_Summary__r.fromStoreId__c, 
                 Order_Delivery_Group_Summary__r.DeliverToAddress from FulfillmentOrder where ID IN: ordrFulfillmntIds]);
        
        set<Id> orderSummaryIds = new set<Id>();
        set<Id> accountIds = new set<Id>();
        Map<Id,Id> mapOfFOWithorderItemIds = new Map<Id,Id>();
        for(FulfillmentOrder fo: fulfillmentOrderMap.values()) {
            orderSummaryIds.add(fo.OrderSummaryId);
            accountIds.add(fo.AccountId);
            for(FulfillmentOrderLineItem foLI: fo.FulfillmentOrderLineItems) {
                mapOfFOWithorderItemIds.put(foLI.Id,foLI.OrderItemId);
            }
            if(fo.Account != NULL && !fo.Account.IsPersonAccount && fo.Account.ParentId != NULL) {
                accountIds.add(fo.Account.ParentId);
            }
        }
        Map<Id,OrderSummary> orderSummaryMap = new Map<Id,OrderSummary>
            ([Select Id, OrderNumber,OriginalOrderId,CreatedDate,PoNumber__c,Contact__c,associateID__c,exchangeOrderNumber__c, SalesChannel.Saleschannelname,
              OriginalOrder.PoNumber__c,OriginalOrder.OrderNumber,OriginalOrder.OrderedDate,OriginalOrder.CreatedDate,OriginalOrder.TotalAdjustedDeliveryAmount,
              OriginalOrder.OrderReferenceNumber,OriginalOrder.exchangeOrderNumber__c,OriginalOrder.SalesChannel.Saleschannelname,OriginalOrder.Type,OriginalOrder.BillingEmailAddress,
              OriginalOrder.TotalAdjDeliveryAmtWithTax,OriginalOrder.SalesStoreId,OriginalOrder.SalesStore.Name,OriginalOrder.TotalTaxAmount,OriginalOrder.TotalAdjustedProductAmount,OriginalOrder.BillingStreet,
              OriginalOrder.BillingCity,OriginalOrder.BillingState,OriginalOrder.BillingPostalCode,OriginalOrder.BillingCountry,OriginalOrder.associateId__c,OriginalOrder.BillingPhoneNumber,
              OriginalOrder.TotalDeliveryAdjDistAmount,(Select Id,Type,Method,CapturedAmount,OrderSummaryId,Delivery_Tax_Amount__c, paymentmethodid
              from OrderPaymentSummaries order by createddate asc),(Select Id, Description, QuantityOrdered, QuantityReturned, QuantityFulfilled, TypeCode, Type, LineNumber, StockKeepingUnit,UnitPrice,TotalLineAdjustmentAmount,TotalAdjustmentAmount,Quantity, 
              ProductCode, Product2Id, Name, AdjustedLineAmount, OrderSummaryId,Status,TotalAmtWithTax,TotalTaxAmount,vendorName__c,vendorNumber__c,weight__c,notes__c,manufacturerSKU__c,unitMeasure__c,
              associatedWarrantyTaxAmt__c, associatedWarrantyProduct__c, associatedWarrantyPrice__c,physicalGiftCard__c,eGiftCard__c,
              gcFromName__c,gcMessage__c,gcRecipientEmail__c,gcFromEmail__c,gcRecipientName__c from OrderItemSummaries limit 1) from OrderSummary where Id IN: orderSummaryIds]);
        
        
        set<Id> orderPaymentSummaryIds = new set<id>();
        for(OrderSummary os : orderSummaryMap.values()) {
            for(OrderPaymentSummary opm : os.OrderPaymentSummaries) {
                orderPaymentSummaryIds.add(opm.Id);
            }
            
        }
        Map<Id,PaymentAuthorization> paymentAuthorizationMap = new Map<Id,PaymentAuthorization>();
        for(PaymentAuthorization pAuth : [Select id,status,OrderPaymentSummaryId,FutureTerms__c from PaymentAuthorization where OrderPaymentSummaryId IN: orderPaymentSummaryIds order by createddate asc]) {
            if(!paymentAuthorizationMap.containsKey(pAuth.OrderPaymentSummaryId)) {
                paymentAuthorizationMap.put(pAuth.OrderPaymentSummaryId, pAuth);
            }
        }
        /*Map<Id,OrderPaymentSummary> orderPaymentSummaryMap = new Map<Id,OrderPaymentSummary>([Select Id,Type,Method,CapturedAmount,OrderSummaryId,Delivery_Tax_Amount__c, paymentmethodid,
                                                                                             (Select Id, FutureTerms__c from PaymentAuthorizations)//WME-361
                                                                                              from OrderPaymentSummary where OrderSummaryId IN :orderSummaryMap.keyset() order by createddate asc]);*/
        
        Map<Id,Account> accountMap = new Map<Id,Account>([Select id,AccountNumber,Salutation__pc,Suffix__pc,SoldToNumber__c,ShippingAddress,ShippingStreet,PersonHasOptedOutOfEmail,
                ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude,LastModifiedDate,Sales_Person_Name__c,Sales_Person_Name__r.Name,
                ShippingLongitude, ShippingGeocodeAccuracy, LastModifiedBy.Name,CreatedBy.Name,CreatedDate,PersonTitle,
                ShippingStreet2__c,ShippingStreet3__c,ShippingStreet4__c,Name,BillingStreet, BillingCity,c_wmWarehouse__c,
                BillingState, BillingPostalCode,Phone,PersonEmail,PersonMobilePhone,Email__c ,PersonHasOptedOutOfFax,
                BillingCountry, BillingLatitude, BillingLongitude,cst_tax_code__c,IsPersonAccount,Industry,Account_IndustryDesc__c,
                cst_tax_resale_exempt_nbr__c,FirstName,MiddleName,LastName,BillingAddress,BillingStreet2__c,PersonDoNotCall,wmProTier_c__c,
                BillingStreet3__c,BillingStreet4__c,Type,AccountSource,Market_Team__c,AssociateId__c,Cust_Payment_Class__c,wmProPORequired__c,
                loyaltyAccountNumber__c,RecordTypeId,cst_exempt_certificate__c,cst_tax_exempt__c,cst_exempt_expirycst_exempt_expiry__c,PersonHomePhone,
                Associate__c,SCCActive__c,cst_rent_name__c,cst_rent_email__c,RegionZone__c,DoNotMail__c,CustomerNumber__c,Sales_Person_Number__c,Parent.id,IndividualNumber__pc,
                Fax,cst_tax_country__c,taxState__c,cst_tax_expiration_date__c,HowManyBoats__c,BoatType__c,BoatLength__c,PrimaryUse__c,SecondaryUse__c,AnnualRevenue,
                // Story: WME-274 Developer: Manohar Alla Change: Added following eight fields
                call_code__c,ParentId,Parent_Bill_To__c,ActivePRO__c,parent.Name,parent.phone,parent.Fax,parent.Email__c,
                (SELECT Id,AccountId__c,State__c,Country__c,Exemption_Certificate__c,Exemption_Type__c,Expiration_Date__c,Global_Exemption__c from Tax_Exemptions__r),
                (SELECT Id, Salutation__c, Suffix__c, Address_Line_4__c, EmailAddress__c, MailCode__c, MailCodeDesc__c, 
                 csh_van_route_seq__c, cst_reserve_whs__c, csh_van_route__c,Account__c,ReserveLocation__r.ExternalReference,ReserveLocation__c, 
                 ActiveAddress__c, wmPreferredAddress__c, Name,First_Name__c,Last_Name__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                 City__c,Country__c,State__c,Postal_Code__c,Phone__c FROM Addresses__r where wmPreferredAddress__c=true and ActiveAddress__c=true order by createddate) from Account where Id IN: accountIds]);
        
        Map<Id,OrderItem> orderItemMap = new Map<Id,OrderItem>(
            [Select Id, LineNumber,ListPrice,Product2Id,UnitPrice,AdjustedLineAmount,
             Special_Order_SKU__c,longDescription__c,TotalTaxAmount,Quantity,Type,
             TotalPrice,unitMeasure__c,weight__c,notes__c,vendorNumber__c,vendorName__c,
             vendorLocation__c,TotalAdjustmentAmount,manufacturerSKU__c,
             Product2.ProductCode, Product2.QuantityUnitOfMeasure,Product2.Description,
             Product2.weight__c,Product2.vendorNumber__c from OrderItem where Id IN: mapOfFOWithorderItemIds.values()]);
        
        
        Map<Id,OrderSummary> mapOfFOWithOrderSummary = new Map<Id,OrderSummary>();
        Map<Id,Account> mapOfFOWithAccount = new Map<Id,Account>();
        Map<Id,ObjectWrapperForPickOut> owrpMap = new Map<Id,ObjectWrapperForPickOut>();
        Map<Id,OrderItemSummary> mapOfFOWithOrderItemSummary = new Map<Id,OrderItemSummary>();
        
        for(FulfillmentOrder fo: fulfillmentOrderMap.values()) {
            ObjectWrapperForPickOut owrp = new ObjectWrapperForPickOut();
            owrp.fulfillmentOrder = fo;
            owrp.mapOfFOWithOrderSummary.put(fo.Id, orderSummaryMap.get(fo.OrderSummaryId));
            owrp.mapOfFOWithAccount.put(fo.Id, accountMap.get(fo.AccountId));
            for(FulfillmentOrderLineItem foLI: fo.FulfillmentOrderLineItems) {
               owrp.orderItemMap.put(foLI.Id,orderItemMap.get(foLI.OrderItemId)); 
            }
            for(OrderItemSummary ois : orderSummaryMap.get(fo.OrderSummaryId).OrderItemSummaries) {
                owrp.mapOfFOWithOrderItemSummary.put(ois.Id,ois);
            }
            for(OrderPaymentSummary ops : orderSummaryMap.get(fo.OrderSummaryId).OrderPaymentSummaries) {
                owrp.mapOfOPMWithPaymentAuthorization.put(ops.Id,paymentAuthorizationMap.get(ops.Id));
            }
            if(fo.Account != NULL && !fo.Account.IsPersonAccount && fo.Account.ParentId != NULL) {
                owrp.parentAccountMap.put(fo.AccountId, accountMap.get(fo.Account.ParentId));
            }
            owrpMap.put(fo.Id,owrp);
        }
        /* END: WME-266 Limit Exception on picks for order more than 50 Lines **/
        
        for(Id fulfillId : ordrFulfillmntIds){
        try{
          
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            // retreving the API key which is configured in Custom Settings
            String apiKey = WM_WebServiceDetails__c.getValues('PickOutApiKey').WM_ApiKey__c;
            // Setting appropriate attributes for the request
            request.setEndpoint('callout:PickOutService');
            request.setMethod('POST'); 
            request.setHeader('Content-Type','application/json');
            request.setHeader('api_key',apiKey);   
            // Instantiating the necessary entities which would be utilized in the service
            FulfillmentOrder fulfillmentOrder = new FulfillmentOrder();
            OrderSummary ordrSummary = new OrderSummary();
            Account acc = new Account();
            //Integer lineNumber = 1;
            // Check if the size of the list of order fulfillment Ids is greater than zero.
            if(ordrFulfillmntIds.size()>0){
                ObjectWrapperForPickOut owrp = owrpMap.get(fulfillId);
                // Retrieving FulFillment Order record from a map.
                fulfillmentOrder = owrp.fulfillmentOrder;
                ordrSummary = owrp.mapOfFOWithOrderSummary.get(fulfillId);
                acc = owrp.mapOfFOWithAccount.get(fulfillId);
                /** WME:266: JSON logic moved to  WM_JSONGeneratorForPickout**/
                JSONGenerator gen = WM_JSONGeneratorForPickout.formtheJSONBody(owrp);
                String payLoad = gen.getAsString();
                system.debug('payload: '+payLoad);
                request.setBody(payLoad);
                request.setTimeout(60000);
                System.debug('request : '+ request);
                HttpResponse response = new HttpResponse();
                response = http.send(request);
                system.debug('getStatusCode ' + response.getStatusCode());
                system.debug('getBody ' + response.getBody());
                if(response.getStatusCode()==200){
                    fulfillmentOrder.JSON_sent_to_TIBCO__c = payLoad;
                      fulfilList.add(fulfillmentOrder);

                    system.debug('Success');            
                    mapOfFulFillmentIDWithResult.put(fulfillId,true);
                    result.add(true);
                        } else{
                            mapOfFulFillmentIDWithResult.put(fulfillId,false);
                            result.add(false);
                                }
                
            } else{
                 result.add(false);
                    }
            }
         catch(Exception e) {
            system.debug('Exception occured: '+e+'--Message:'+e.getMessage()+'--Line Number:'+e.getLineNumber());
            if(e!=null){
                if(e.getStackTraceString()!=null){
                     mapOfFulFillmentIDWithResult.put(fulfillId,false);
                   result.add(false);
                        }
                else{
                    result.add(false);
                        }
            }
            
            // WME-230, Developer: Satish V Comments: Only Else single line
            else{
           result.add(false);
            }
                
                }
         }
          Update fulfilList; 
        List<FeedItem> postList = new list<FeedItem>();
        for(String k :mapOfFulFillmentIDWithResult.keyset()){
            if(mapOfFulFillmentIDWithResult.get(k)){
                FeedItem post = new FeedItem();                    
                    post.ParentId = k;     
                    post.Title = 'The request to PickOut Service was successful';
                    post.Body = 'The request to PickOut Service was successful';
                postList.add(post);
            }
            else{
                 FeedItem post = new FeedItem();                    
                    post.ParentId = k;     
                    post.Title = 'The request to PickOut Service failed';
                    post.Body = 'The request to PickOut Service failed';
                postList.add(post);
            }
        }
        if(postList.size()>0){
         insert postList;   
        }
        
        // WME-230, Developer: Satish V
        return result;
        
    }
   
}