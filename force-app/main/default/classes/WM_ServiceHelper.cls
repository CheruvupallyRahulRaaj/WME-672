/**
* @description       : Helper class for WM_ServiceHelper class to fetch the desired records
* @author            : schauhan@liveareacx.com
* @last modified on  : 02-09-2021
* @last modified by  : schauhan@liveareacx.com
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   01-14-2021   schauhan@liveareacx.com   Initial Version
**/


public class WM_ServiceHelper {
    
    public static FulfillmentOrder getFulfillmentOrder(String fulFillmntorderId) {
        List < String > listOfFields = new List < String > {
            'Id', 'AccountId', 'DeliveryMethodId', 'FulfilledFromLocationId', 'FulfilledToName', 'FulfilledToStreet', 'FulfillmentOrderNumber',
                'FulfilledToCity', 'FulfilledToState', 'FulfilledToPostalCode', 'FulfilledToCountry', 'FulfilledToLatitude',
                'FulfilledToLongitude', 'FulfilledToGeocodeAccuracy', 'FulfilledToAddress', 'FulfilledToEmailAddress', 
                'FulfilledToPhone', 'ItemCount', 'Status', 'StatusCategory', 'Type', 'TypeCategory', 'TotalProductAmount', 
                'TotalAdjustmentAmount', 'TotalDeliveryAmount', 'TotalProductTaxAmount', 'TotalAdjustmentTaxAmount', 
                'TotalDeliveryTaxAmount', 'TotalAmount', 'TotalTaxAmount', 'OrderId', 'OrderSummaryId', 
                'InvoiceId', 'GrandTotalAmount', 'IsSuspended', 'TotalDeliveryAdjustAmount', 'TotalDeliveryAdjustTaxAmount',
                'TaxLocaleType', 'BillToContactId', 'TotalProductAmtWithTax', 'TotalAdjustmentAmtWithTax',
                'TotalDeliveryAmtWithTax', 'TotalDeliveryAdjustAmtWithTax','dummyInvoiceNumberForSTSFS__c','JSON_sent_to_TIBCO__c',
                'FulfilledToShippingStreet2__c','FulfilledToShippingStreet3__c','FulfilledToShippingStreet4__c',
                'van_route__c','van_route_seq_nbr__c','JDAFulfillmentOrderNumber__c','Order_Delivery_Group_Summary__c'
                };
                    
                    FulfillmentOrder FulfillmentOrder = (FulfillmentOrder) WM_DaoService.getSobjectById(fulFillmntorderId, listOfFields, FulfillmentOrder.SObjectType);
        return FulfillmentOrder;
    }
    
    /*public static List<FulfillmentOrder> getFulfillmentOrderList(String ordrSumId) {
        List < String > listOfFields = new List < String > {
            'Id', 'AccountId', 'DeliveryMethodId', 'FulfilledFromLocationId',  'FulfillmentOrderNumber',
                'FulfilledFromLocationId', 'FulfilledToName', 'FulfilledToStreet', 'FulfillmentOrderNumber',
                'FulfilledToCity', 'FulfilledToState', 'FulfilledToPostalCode', 'FulfilledToCountry', 'FulfilledToLatitude',
                'FulfilledToLongitude', 'FulfilledToGeocodeAccuracy', 'FulfilledToAddress', 'FulfilledToEmailAddress', 
                'FulfilledToPhone', 'ItemCount', 'Status', 'StatusCategory', 'Type', 'TypeCategory', 'TotalProductAmount', 
                'TotalAdjustmentAmount', 'TotalDeliveryAmount', 'TotalProductTaxAmount', 'TotalAdjustmentTaxAmount', 
                'TotalDeliveryTaxAmount', 'TotalAmount', 'TotalTaxAmount', 'OrderId', 'OrderSummaryId', 
                'InvoiceId', 'GrandTotalAmount', 'IsSuspended', 'TotalDeliveryAdjustAmount', 'TotalDeliveryAdjustTaxAmount',
                'TaxLocaleType', 'BillToContactId', 'TotalProductAmtWithTax', 'TotalAdjustmentAmtWithTax',
                'TotalDeliveryAmtWithTax', 'TotalDeliveryAdjustAmtWithTax','JSON_sent_to_TIBCO__c',
                'FulfilledToShippingStreet2__c','FulfilledToShippingStreet3__c','FulfilledToShippingStreet4__c',
                'van_route__c','van_route_seq_nbr__c','JDAFulfillmentOrderNumber__c','FulfilledFromLocation','FulfillmentOrder.FulfilledFromLocation'
                };
                    List<FulfillmentOrder> fulfillmentOrdrList = (List<FulfillmentOrder>) WM_DaoService.getSobjectList(ordrSumId, listOfFields, FulfillmentOrder.SObjectType,'OrderSummaryId');            
        
        return fulfillmentOrdrList;
    }
    public static List<FulfillmentOrder> getFulfillmntOrdrLst(String invoiceId) {
        List < String > listOfFields = new List < String > {
            'Id', 'AccountId', 'DeliveryMethodId',  'FulfillmentOrderNumber',
                'FulfilledFromLocationId', 'FulfilledToName', 'FulfilledToStreet',
                'FulfilledToCity', 'FulfilledToState', 'FulfilledToPostalCode', 'FulfilledToCountry', 'FulfilledToLatitude',
                'FulfilledToLongitude', 'FulfilledToGeocodeAccuracy', 'FulfilledToAddress', 'FulfilledToEmailAddress', 
                'FulfilledToPhone', 'ItemCount', 'Status', 'StatusCategory', 'Type', 'TypeCategory', 'TotalProductAmount', 
                'TotalAdjustmentAmount', 'TotalDeliveryAmount', 'TotalProductTaxAmount', 'TotalAdjustmentTaxAmount', 
                'TotalDeliveryTaxAmount', 'TotalAmount', 'TotalTaxAmount', 'OrderId', 'OrderSummaryId', 
                'InvoiceId', 'GrandTotalAmount', 'IsSuspended', 'TotalDeliveryAdjustAmount', 'TotalDeliveryAdjustTaxAmount',
                'TaxLocaleType', 'BillToContactId', 'TotalProductAmtWithTax', 'TotalAdjustmentAmtWithTax',
                'TotalDeliveryAmtWithTax', 'TotalDeliveryAdjustAmtWithTax','JSON_sent_to_TIBCO__c',
                'FulfilledToShippingStreet2__c','FulfilledToShippingStreet3__c','FulfilledToShippingStreet4__c',
                'van_route__c','van_route_seq_nbr__c','JDAFulfillmentOrderNumber__c','FulfilledFromLocation.ExternalReference','FulfilledFromLocation.LocationType'
                };
                    List<FulfillmentOrder> fulfIllmentOrdrList = (List<FulfillmentOrder>) WM_DaoService.getSobjectList(invoiceId, listOfFields, FulfillmentOrder.SObjectType,'InvoiceId');            
        
        return fulfIllmentOrdrList;
    }*/
    
    public static OrderDeliveryMethod getOrderDeliveryMethod(String orderDelMethodId) {
        List < String > listOfFields = new List < String > {
            'Id', 'Name','Description','ReferenceNumber'
                };
                    
                    OrderDeliveryMethod ordrDelMethod = (OrderDeliveryMethod) WM_DaoService.getSobjectById(orderDelMethodId, listOfFields, OrderDeliveryMethod.SObjectType);
        return ordrDelMethod;
    }
    
  /*  public static List<OrderDeliveryMethod> getOrderDeliveryMethodList(Set<Id> orderDelMethodIds) {
        List<OrderDeliveryMethod> ordrDelMethodList = [Select Id, Name, Description,ReferenceNumber  from OrderDeliveryMethod where Id IN :orderDelMethodIds];
        return ordrDelMethodList;
    }
    public static OrderDeliveryGroupSummary getOrderDeliveryGrpSum(String orderSumId) {
        OrderDeliveryGroupSummary ordrDelGrpSum = [Select Id, DeliverToLocation__r.ExternalReference,EmailAddress, 
                                                   PhoneNumber, DeliverToName, DeliverToStreet, DeliverToCity, 
                                                   DeliverToState, DeliverToPostalCode, DeliverToCountry, DeliverToLatitude,fromStoreId__c,
                                                   DeliverToLongitude, DeliverToGeocodeAccuracy, DeliverToAddress from OrderDeliveryGroupSummary where OrderSummaryID = :orderSumId limit 1];
        return ordrDelGrpSum;            
    }*/
    public static OrderDeliveryGroupSummary getOrderDeliveryGrpSummary(String recId){
        OrderDeliveryGroupSummary ordrDelGrpSum = [Select Id, DeliverToLocation__r.ExternalReference,
                                                   EmailAddress, PhoneNumber, DeliverToName, DeliverToStreet, 
                                                   DeliverToCity, DeliverToState, DeliverToPostalCode, DeliverToCountry, 
                                                   DeliverToLatitude, DeliverToLongitude, DeliverToGeocodeAccuracy,fromStoreId__c, 
                                                   DeliverToAddress from OrderDeliveryGroupSummary where Id = :recId limit 1];
        return ordrDelGrpSum; 
    }
   /* public static List<OrderDeliveryGroupSummary> getReturnedOrderDelGrpSumList(List<String> recIds){
        List<OrderDeliveryGroupSummary> ordrDelGrpSum = [Select Id, DeliverToLocation__r.ExternalReference,
                                                   EmailAddress, PhoneNumber, DeliverToName, DeliverToStreet,OrderDeliveryMethodId,
                                                   OrderDeliveryMethod.ReferenceNumber,DeliverToCity, DeliverToState, DeliverToPostalCode, DeliverToCountry, 
                                                   DeliverToLatitude, DeliverToLongitude, DeliverToGeocodeAccuracy,fromStoreId__c,
                                                   DeliverToAddress from OrderDeliveryGroupSummary where Id IN :recIds];
        return ordrDelGrpSum; 
    }*/
    public static Schema.Location getLocation(String locId) {
        List < String > listOfFields = new List < String > {
            'Id', 'Name','ExternalReference','LocationType'
                };
                    
                    Schema.Location locatn = (Schema.Location) WM_DaoService.getSobjectById(locId, listOfFields,Schema.Location.SObjectType);
        return locatn;
    }
    
    public static OrderSummary getOrderSummary(String ordrSumId) {
        List < String > listOfFields = new List < String > {
            'Id', 'OrderNumber','OriginalOrderId','CreatedDate','PoNumber__c','Contact__c','associateID__c','exchangeOrderNumber__c', 'SalesChannel.Saleschannelname'
                };
                    
                    OrderSummary ordrSum = (OrderSummary) WM_DaoService.getSobjectById(ordrSumId, listOfFields, OrderSummary.SObjectType);
        return ordrSum;
    }
    
   /* public static  List<PaymentAuthorization> getPaymentAuthorization(Set<Id> orderPaymentSummaryIds) {
        
        List<PaymentAuthorization> paymentAuthList = [Select Id,loyaltyDetails__c, PaymentAuthorizationNumber,redeemedCerts__c, giftCardNumber__c, gcExpiry__c,gcAuthCode__c from PaymentAuthorization where OrderPaymentSummaryId IN :orderPaymentSummaryIds];
        return paymentAuthList;
    }*/
    
    public static  List<OrderPaymentSummary> getOrderPaymentSummary(Id ordrSumId) {
        system.debug('Order Sum Id '+ordrSumId);
        List<OrderPaymentSummary> ordrPaySumList = [Select Id,Type,Method,CapturedAmount,OrderSummaryId,Delivery_Tax_Amount__c, paymentmethodid,
                                                    (Select Id, FutureTerms__c from PaymentAuthorizations)//WME-361
                                                    from OrderPaymentSummary where OrderSummaryId = :ordrSumId order by createddate asc];
        return ordrPaySumList;
    }
    public static  List<FulfillmentOrderLineItem> getFulfillmentOrderLineItem(Set<Id> fulfillmentOrderIds) {
        List<FulfillmentOrderLineItem> fulFillmntLineItemList = new List<FulfillmentOrderLineItem>();
        fulFillmntLineItemList = [Select Id,FulfillmentOrderId,FulfillmentOrder.InvoiceId,FulfillmentOrder.JDAFulfillmentOrderNumber__c,FulfillmentOrder.FulfilledFromLocation.ExternalReference,Quantity,UnitPrice,
                                  TotalPrice,Quantity_Received__c,Quantity_Credited__c,TotalAdjustmentAmount,Quantity_Fulfilled__c,FulfillmentOrderLineItemNumber,
                                  OriginalQuantity,OrderItemId,OrderItemSummaryId,Product2Id from FulfillmentOrderLineItem where FulfillmentOrderId IN:fulfillmentOrderIds and type = 'Order Product' and quantity > 0 order by CreatedDate asc];
        return fulFillmntLineItemList;
    }
    
    public static  OrderItem getOrderItem(String orderItemId) {
        List < String > listOfFields = new List < String > {
            'Id', 'LineNumber','ListPrice','Product2Id','UnitPrice','AdjustedLineAmount','Special_Order_SKU__c','longDescription__c','TotalTaxAmount','Quantity','Type','TotalPrice','unitMeasure__c','weight__c','notes__c','vendorNumber__c','vendorName__c','vendorLocation__c','TotalAdjustmentAmount','manufacturerSKU__c'
                };
                    
                    OrderItem ordrItem = (OrderItem) WM_DaoService.getSobjectById(orderItemId, listOfFields, OrderItem.SObjectType);
        return ordrItem;
    }
    
    public static  Product2 getProduct(String prodId) {
        List < String > listOfFields = new List < String > {
            'Id', 'ProductCode', 'QuantityUnitOfMeasure','Description','weight__c','vendorNumber__c'
                };
                    
                    Product2 prod = (Product2) WM_DaoService.getSobjectById(prodId, listOfFields, Product2.SObjectType);
        return prod;
    }
    
    public static Order getOrder(String ordrId) {
        List < String > listOfFields = new List < String > {
            'Id', 'PoNumber__c','OrderNumber','OrderedDate','CreatedDate','TotalAdjustedDeliveryAmount','OrderReferenceNumber','exchangeOrderNumber__c',
                'SalesChannelId','Type','BillingEmailAddress','TotalAdjDeliveryAmtWithTax','SalesStoreId','TotalTaxAmount','TotalAdjustedProductAmount',
                'BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry','associateId__c','BillingPhoneNumber','TotalDeliveryAdjDistAmount'
                };
                    
                    Order ordr = (Order) WM_DaoService.getSobjectById(ordrId, listOfFields, Order.SObjectType);
        return ordr;
    }
    
    public static SalesChannel getSalesChannel(String saleschannlId) {
        List < String > listOfFields = new List < String > {
            'Id', 'SalesChannelName'
                };
                    
                    SalesChannel salesChannl = (SalesChannel) WM_DaoService.getSobjectById(saleschannlId, listOfFields, SalesChannel.SObjectType);
        return salesChannl;
    }
    
    public static WebStore getStore(String storeId) {
        List < String > listOfFields = new List < String > {
            'Id', 'Name'
                };
                    
                    WebStore str = (WebStore) WM_DaoService.getSobjectById(storeId, listOfFields, WebStore.SObjectType);
        return str;
    } 
    
    public static Account getAccount(String accId) {
        List < String > listOfFields = new List < String > {
            'Id','AccountNumber','Salutation__pc','Suffix__pc','SoldToNumber__c','ShippingAddress','ShippingStreet','PersonHasOptedOutOfEmail',
                'ShippingCity', 'ShippingState', 'ShippingPostalCode', 'ShippingCountry', 'ShippingLatitude','LastModifiedDate','Sales_Person_Name__c','Sales_Person_Name__r.Name',
                'ShippingLongitude', 'ShippingGeocodeAccuracy', 'LastModifiedBy.Name','CreatedBy.Name','CreatedDate','PersonTitle',
                'ShippingStreet2__c','ShippingStreet3__c','ShippingStreet4__c','Name','BillingStreet', 'BillingCity','c_wmWarehouse__c',
                'BillingState', 'BillingPostalCode','Phone','PersonEmail','PersonMobilePhone','Email__c ','PersonHasOptedOutOfFax',
                'BillingCountry', 'BillingLatitude', 'BillingLongitude','cst_tax_code__c','IsPersonAccount','Industry','Account_IndustryDesc__c',
                'cst_tax_resale_exempt_nbr__c','FirstName','MiddleName','LastName','BillingAddress','BillingStreet2__c','PersonDoNotCall','wmProTier_c__c',
                'BillingStreet3__c','BillingStreet4__c','Type','AccountSource','Market_Team__c','AssociateId__c','Cust_Payment_Class__c','wmProPORequired__c',
                'loyaltyAccountNumber__c','RecordTypeId','cst_exempt_certificate__c','cst_tax_exempt__c','cst_exempt_expirycst_exempt_expiry__c','PersonHomePhone',
                'Associate__c','SCCActive__c','cst_rent_name__c','cst_rent_email__c','RegionZone__c','DoNotMail__c','CustomerNumber__c','Sales_Person_Number__c','Parent.id','IndividualNumber__pc',
                'Fax','cst_tax_country__c','taxState__c','cst_tax_expiration_date__c','HowManyBoats__c','BoatType__c','BoatLength__c','PrimaryUse__c','SecondaryUse__c','AnnualRevenue',
                // Story: WME-274 Developer: Manohar Alla Change: Added following eight fields
                'call_code__c','ParentId','Parent_Bill_To__c','ActivePRO__c','parent.Name','parent.phone','parent.Fax','parent.Email__c' 
                };
                    
                    Account acc = (Account) WM_DaoService.getSobjectById(accId, listOfFields, Account.SObjectType);
        return acc;
    } 
   /* public static Invoice getInvoice(String invoiceId) {
        List < String > listOfFields = new List < String > {
            'Id', 'CreatedDate', 'ReferenceEntityId', 'DocumentNumber', 'InvoiceNumber', 'BillingAccountId', 'TotalAmount', 
                'TotalAmountWithTax', 'TotalChargeAmount', 'TotalAdjustmentAmount', 'TotalTaxAmount', 'Status', 'InvoiceDate','InvoiceName__c','InvoiceName__r.InvoiceCredNum__c',
                'DueDate', 'BillToContactId', 'Description', 'Balance', 'TaxLocaleType', 'TotalChargeTaxAmount', 'TotalChargeAmountWithTax', 
                'TotalAdjustmentTaxAmount', 'TotalAdjustmentAmountWithTax','JDAInvoiceNumber__c','Total_Freight_Tax_Amount__c','Total_Freight_Amount__c','VertexLOM__VertexTaxTotal__c','Vertex_Total_with_Tax__c'
                };
                    Invoice invoiceObj = (Invoice) WM_DaoService.getSobjectById(invoiceId, listOfFields, Invoice.SObjectType);
        return invoiceObj;
    }*/
    
    public static CreditMemo getCreditMemo(String creditMemoId) {
        List < String > listOfFields = new List < String > {
            'Id', 'CreatedDate','DocumentNumber', 'BillingAccountId', 'ReferenceEntityId', 'CreditMemoNumber', 'TotalAmount', 'TotalAmountWithTax', 
                'TotalChargeAmount', 'TotalAdjustmentAmount', 'TotalTaxAmount', 'CreditDate', 'Description', 'Status', 'BillToContactId','JDAInvoiceCreditNumber__c','JDAInvoiceCreditNumber__r.InvoiceCredNum__c',
                'Balance', 'TaxLocaleType', 'TotalChargeTaxAmount', 'TotalChargeAmountWithTax', 'TotalAdjustmentTaxAmount', 
                'TotalAdjustmentAmountWithTax','Return_Disposition_Code__c','JDACreditMemoNumber__c'
                };
                    CreditMemo creditMemoObj = (CreditMemo) WM_DaoService.getSobjectById(creditMemoId, listOfFields, CreditMemo.SObjectType);
        return creditMemoObj;
    }
    
   /* public static Contact getContact(String conId) {
        List < String > listOfFields = new List < String > {
            'Id','FirstName','LastName','Salutation__c','Name','Suffix__c','ActiveContact__c','HomePhone','Phone','Fax','Department','Title','Email','IndividualNumber__c',
                'HasOptedOutOfEmail','cif_rent_flag__c','CreatedById','Customer_Auth_Status__c','OwnerId','CreatedDate','LastModifiedDate','LastModifiedBy.Name','CreatedBy.Name'
                };
                    
                    Contact con = (Contact) WM_DaoService.getSobjectById(conId, listOfFields, Contact.SObjectType);
        return con;
    }
    
    public static e_GiftCard__c getGiftCard(String eGiftCardId){
        List<String> listofFields = new List<String>{
            'Id','Name', 'Gift_Card_Number__c', 'Order_Summary__c', 'Amount__c', 'Issued__c', 'Is_Assigned__c','gcMessage__c'
                };
                    e_GiftCard__c eGiftCrd = (e_GiftCard__c)WM_DaoService.getSobjectById(eGiftCardId, listofFields, e_GiftCard__c.SObjectType);
        return eGiftCrd;
    }*/
    public static List<OrderDeliveryGroup> getOrderDeliveryGroup(String orderId){
        List<String> listofFields = new List<String>{
            'DeliverToGeocodeAccuracy', 'DeliverToAddress', 'DeliverToLatitude', 'DeliverToLongitude', 'DeliverToCountry', 'DeliverToPostalCode', 'DeliverToState', 
                'DeliverToCity', 'DeliverToStreet', 'EmailAddress', 'PhoneNumber', 'DeliverToName', 'OrderDeliveryMethodId', 
                'OrderId', 'Id', 'OrderDeliveryGroupNumber', 'CreatedDate', 'IsGift'
                };
                    List<OrderDeliveryGroup> orderDelGrpList = (List<OrderDeliveryGroup>) WM_DaoService.getSobjectList(orderId, listOfFields, OrderDeliveryGroup.SObjectType,'OrderId');            
        return orderDelGrpList;
    }
    
    public static Address__c getAddress(String accId){
        List<Address__c > addrList = [SELECT Id, Salutation__c, Suffix__c, Address_Line_4__c, EmailAddress__c, MailCode__c, MailCodeDesc__c, 
                                      csh_van_route_seq__c, cst_reserve_whs__c, csh_van_route__c,Account__c,ReserveLocation__r.ExternalReference,ReserveLocation__c, 
                                      ActiveAddress__c, wmPreferredAddress__c, Name,First_Name__c,Last_Name__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                                      City__c,Country__c,State__c,Postal_Code__c,Phone__c FROM Address__c where (Account__c=:accId and 
                                                                                                                 wmPreferredAddress__c=true and ActiveAddress__c=true) order by createddate];
        if(addrList.size()>0){
            return addrList[0];
        }
        else{
            return null;
        }
    }
    /*public static List<InvoiceLine> getInvoiceLineList(String invoiceId){
        List<InvoiceLine> invoiceLineList = new List<InvoiceLine>();
        invoiceLineList = [SELECT Id, InvoiceId, ReferenceEntityItemId, GroupReferenceEntityItemId, LineAmount,ReferenceEntityItem.Name, 
                           Quantity, UnitPrice, ChargeAmount, TaxAmount, AdjustmentAmount, InvoiceStatus, Description, 
                           InvoiceLineStartDate, InvoiceLineEndDate, ReferenceEntityItemType, ReferenceEntityItemTypeCode, 
                           Product2Id, RelatedLineId, Type, TaxName, TaxCode, TaxRate, TaxEffectiveDate, GrossUnitPrice, 
                           ChargeTaxAmount, ChargeAmountWithTax, AdjustmentTaxAmount, AdjustmentAmountWithTax FROM InvoiceLine where InvoiceId=:invoiceId order by createddate asc];
        return invoiceLineList;
    }
    
    public static List<CreditMemoLine> getCreditMemoLineList(String creditMemoId){
        List<CreditMemoLine> creditMemoLineList = [Select Id,ReferenceEntityItemId,CreditMemoId,ReferenceEntityItem.QuantityFulfilled,ReferenceEntityItem.Name,
                                                   ReferenceEntityItem.TotalAdjustmentAmount,ReferenceEntityItem.ReservedAtLocationId,LineAmount,Type,
                                                   ReferenceEntityItem.QuantityOrdered,ReferenceEntityItem.ProductCode,ReferenceEntityItem.TotalPrice,
                                                   ReferenceEntityItem.QuantityReturned,ReferenceEntityItem.TotalTaxAmount,ReferenceEntityItem.Quantity,
                                                   ReferenceEntityItem.UnitPrice,ReferenceEntityItem.Type,RelatedLineId,RelatedLine.Name
                                                   from CreditMemoLine where CreditMemoId=:creditMemoId];
        return creditMemoLineList;
    }
    
    public static List<String> getCreditMemoLineIds(String creditMemoId){
        List<CreditMemoLine> creditMemoLineList = [Select Id,ReferenceEntityItemId,CreditMemoId,ReferenceEntityItem.QuantityFulfilled,ReferenceEntityItem.Name,
                                                   ReferenceEntityItem.TotalAdjustmentAmount,ReferenceEntityItem.ReservedAtLocationId,LineAmount,Type,
                                                   ReferenceEntityItem.QuantityOrdered,ReferenceEntityItem.ProductCode,ReferenceEntityItem.TotalPrice,
                                                   RelatedLineId,RelatedLine.Name
                                                   from CreditMemoLine where CreditMemoId=:creditMemoId];
        List<String> ordrItemIds = new List<String>();
        for(CreditMemoLine cml:creditMemoLineList){
            ordrItemIds.add(cml.ReferenceEntityItemId);
        }
        return ordrItemIds;
    }*/
    public static OrderItemSummary getOrderItemSummary(String orderItemSummaryId){
        OrderItemSummary orderItemSum = new OrderItemSummary();
        
        orderItemSum = [SELECT Id, Description, QuantityOrdered, QuantityReturned, QuantityFulfilled, TypeCode, Type, LineNumber, StockKeepingUnit,UnitPrice,TotalLineAdjustmentAmount,TotalAdjustmentAmount,Quantity, 
                        ProductCode, Product2Id, Name, AdjustedLineAmount, OrderSummaryId,Status,TotalAmtWithTax,TotalTaxAmount,vendorName__c,vendorNumber__c,weight__c,notes__c,manufacturerSKU__c,unitMeasure__c,
                        associatedWarrantyTaxAmt__c, associatedWarrantyProduct__c, associatedWarrantyPrice__c,physicalGiftCard__c,eGiftCard__c,
                        gcFromName__c,gcMessage__c,gcRecipientEmail__c,gcFromEmail__c,gcRecipientName__c FROM OrderItemSummary where Id =:orderItemSummaryId limit 1];
        if(orderItemSum!=null){
            return orderItemSum;
        }
        else{
            return null;
        }
    }
   /* public static List<OrderItemSummary> getOrderItemSummaries(List<String> ordrItemSumIds){
        List<OrderItemSummary> orderItemSumList = new List<OrderItemSummary>();
        orderItemSumList = [SELECT Id, Description, QuantityOrdered, QuantityReturned, QuantityFulfilled, TypeCode, Type, LineNumber, StockKeepingUnit,UnitPrice,TotalLineAdjustmentAmount,TotalAdjustmentAmount,Quantity, 
                        ProductCode, Product2Id, Name, AdjustedLineAmount, OrderSummaryId,Status,TotalAmtWithTax,TotalTaxAmount,vendorName__c,vendorNumber__c,weight__c,notes__c,manufacturerSKU__c,unitMeasure__c,
                        associatedWarrantyTaxAmt__c, associatedWarrantyProduct__c, associatedWarrantyPrice__c,physicalGiftCard__c,OrderDeliveryGroupSummaryId,OriginalOrderItemId,OriginalOrderItem.TotalAdjustmentAmount, 
                        OrderDeliveryGroupSummary.DeliverToLocation__c,OrderDeliveryGroupSummary.OrderDeliveryMethod.ReferenceNumber,OrderDeliveryGroupSummary.DeliverToLocation__r.ExternalReference,
                        OrderDeliveryGroupSummary.OrderDeliveryMethod.Description,OrderDeliveryGroupSummary.DeliverToName,OrderDeliveryGroupSummary.DeliverToStreet,
                         OrderDeliveryGroupSummary.DeliverToCity,OrderDeliveryGroupSummary.fromStoreId__c,OrderDeliveryGroupSummary.DeliverToCountry,OrderDeliveryGroupSummary.DeliverToState,OrderDeliveryGroupSummary.DeliverToPostalCode,   
                        gcFromName__c,gcMessage__c,gcRecipientEmail__c,gcFromEmail__c,gcRecipientName__c FROM OrderItemSummary where Id IN:ordrItemSumIds and Type!='Delivery Charge'];
return orderItemSumList;
    }*/
    
    
    public static List<OrderItemSummaryChange> getOrderItemSummaryChange(String orderSumId){
        List<OrderItemSummaryChange> orderItemSumChange = [SELECT Id, OrderItemSummaryChangeNumber, OrderItemSummaryId,OrderItemSummary.Name, 
                                                           OrderItemSummary.QuantityReturned,OrderItemSummary.LineNumber,OrderItemSummary.Type,
                                                           OrderItemSummary.ProductCode,OrderItemSummary.Description,ChangeOrderItemId,CreatedDate, 
                                                           OrderSummaryId, Reason, IsPreFulfillment, ChangeType ,OrderItemSummary.Special_Order_SKU__c  // Added by Manohar, WME-128
                                                           FROM OrderItemSummaryChange where OrderSummaryId=:orderSumId];
        return orderItemSumChange;
    }
    public static List<CreditMemoLine> getCreditMemoLine(String CreditMemoID){
        List<CreditMemoLine> creditmemolines = [SELECT Id, CreditMemoId, ReferenceEntityItemId,ReferenceEntityItemTypeCode,ReturnAuthAssignment__c FROM CreditMemoLine where CreditMemoId=:CreditMemoID];
        return creditmemolines;
    }
   /* public static List<CardPaymentMethod> getPaymentMethods(String accountId){
        List<CardPaymentMethod> cardPaymentMethodList = [Select Id,GatewayToken,aurusApprovalCode__c,ExpiryMonth,ExpiryYear,aurusPayAPTID__c, aurusPayAPTN__c, aurusPayOOT__c from CardPaymentMethod where AccountId =:accountId];
        return cardPaymentMethodList;
    }
    public static List<CardPaymentMethod> getCPM(List<Id> cpmIds){
        List<CardPaymentMethod> cardPaymentMethodList = [Select Id,GatewayToken,aurusApprovalCode__c,ExpiryMonth,ExpiryYear,aurusPayAPTID__c, aurusPayAPTN__c, aurusPayOOT__c from CardPaymentMethod where Id IN:cpmIds];
        return cardPaymentMethodList;
    }
    public static List<AlternativePaymentMethod> getAPM(List<Id> apmIds){
        List<AlternativePaymentMethod> altPaymentMethodList = [SELECT Id, RecordType.Name FROM AlternativePaymentMethod where Id IN:apmIds];
        return altPaymentMethodList;
    }
    
    public static List<PaymentAuthorization> getPaymentAuth(String accountId){
        List<PaymentAuthorization> PaymentAuthList = [Select Id,AccountId,loyaltyDetails__c,PaymentAuthorizationNumber,GatewayRefNumber,redeemedCerts__c, giftCardNumber__c, gcExpiry__c, gcAuthCode__c from PaymentAuthorization where AccountId =:accountId];
        return PaymentAuthList;
    }
    public static List<OrderItemSummaryChange> getorditmschng(String ordrSumId){
        List<OrderItemSummaryChange> orditmschngList = [Select Id,Reason from OrderItemSummaryChange where OrderSummaryId =:ordrSumId];
        return orditmschngList;
    }*/	
    public static List<Shipment> getshpment(Set<Id> fullfillmentORderIDs){
        List<Shipment> shipmntList = [Select Id,FulfillmentOrder.InvoiceId,FulfillmentOrderId,TrackingNumber,CreatedDate from Shipment where FulfillmentOrderId IN:fullfillmentORderIDs];
        return shipmntList;
    }
    
    public static List<Tax_Exemption__c> getTaxExemptions(String accountId){
        
        List<Tax_Exemption__c> TaxExemptnList = [Select Id,AccountId__c,State__c,Country__c,Exemption_Certificate__c,Exemption_Type__c,Expiration_Date__c,Global_Exemption__c  from Tax_Exemption__c where AccountId__c =:accountId];
        if(TaxExemptnList.size()>0){
            return TaxExemptnList;
        }
        
        else{
            return  null;
        }
    }
    
    
}