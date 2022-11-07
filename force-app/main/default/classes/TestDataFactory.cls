/*Author :  schauhan@liveareacx.com
* Class : TestUtils
* Purpose : Utility Class for Creating Test Data
* Date : 4th Jan'2021
* @last modified on  : 01-13-2021
* @last modified by  : schauhan@liveareacx.com
* */
@isTest
public class TestDataFactory  {
    
    public static CardPaymentMethod createCardPaymentMethodRecord(PaymentGateway payGateway,Account acc) {
        CardPaymentMethod cpm = new CardPaymentMethod();
        cpm.PaymentMethodCountry = WMConstants.Country;
        cpm.PaymentMethodCity = WMConstants.City;
        cpm.PaymentMethodpostalcode = WMConstants.PostalCode;
        cpm.PaymentMethodState = WMConstants.State;
        cpm.Phone = WMConstants.Phone;
        cpm.Email = WMConstants.Email;
        cpm.PaymentGatewayId = payGateway.Id;  
        cpm.CardType = 'VIC';
        cpm.CardHolderName = 'John Doee';
        cpm.ExpiryYear = 2020;
        cpm.ExpiryMonth = 1;
        cpm.CardCategory = 'CreditCard';
        cpm.Status = 'Active';
        cpm.AccountId = acc.Id;
        cpm.ProcessingMode = 'External';
        insert cpm;
        return cpm;
    }
    
    public static Payment createPaymentRecord(Id paymentmethodid, Id paymentAuthorizationid, Id orderPaymentSummaryId) {
        Payment Pay = new Payment();
        Pay.GatewayRefNumber = WMConstants.GatewayRefNumber;
        Pay.GatewayRefDetails = WMConstants.GatewayRefDetails;
        pay.PaymentMethodId = paymentmethodid;
        pay.Amount = 100;
        pay.Status = 'Draft';
        pay.Type = 'Capture';
        pay.ProcessingMode = 'External';    
        pay.PaymentAuthorizationId = paymentAuthorizationid;
        pay.OrderPaymentSummaryId = orderPaymentSummaryId;
        insert Pay;
        return Pay;
    }
    
    public static PaymentGateway createPaymentGatewayRecord() {
        String paymentGatewayProviderId = [Select Id From PaymentGatewayProvider Where DeveloperName = 'SalesforceAdapter'].Id;
        String merchantCredentialId = [Select Id,DeveloperName from NamedCredential where DeveloperName = 'Aurus_Service'].Id;
        PaymentGateway PayGateway = new PaymentGateway();
        PayGateway.Status = WMConstants.Status;
        PayGateway.PaymentGatewayName = 'TestPickout2';
        PayGateway.PaymentGatewayProviderId = paymentGatewayProviderId;
        PayGateway.MerchantCredentialId = merchantCredentialId;
        insert PayGateway;
        return PayGateway;
    }
    
    public static PaymentAuthorization createPaymentAuthorizationRecord(PaymentGateway payGateway, CardPaymentMethod cpm, Account acc,PaymentGroup payGrp) {
        PaymentAuthorization payAuth = new PaymentAuthorization();
        payAuth.GatewayRefNumber = WMConstants.GatewayRefNumber;
        payAuth.GatewayRefDetails = WMConstants.GatewayRefDetails;
        payAuth.PaymentGatewayId = payGateway.Id;
        payAuth.Amount = 291.39;
        payAuth.ProcessingMode = 'External';
        payAuth.Status = 'Processed';
        payAuth.PaymentGroupId = payGrp.Id;
        payAuth.AccountId = acc.Id;
        payAuth.PaymentMethodId = cpm.Id;
        payAuth.loyaltyDetailsOMS__c = '{"CertNumber":"1222765420","CertAvailableBalance":5,"ExpNoFormat":"1122"}';
        insert payAuth;
        system.debug('Payment Auth '+payAuth);
        return payAuth;
    }
    
    public static Id createSalesmen(){
        Salesmen__c sm = new Salesmen__c();
        sm.SalesmenNumber__c =123;
        sm.Name = 'Test Salesmen';
        insert sm;
        return sm.Id;
    }
    
    public static Account createAccountRecord() {
       String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';
    while (randStr.length() < 10) {
       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
       randStr += chars.substring(idx, idx+1);
    }
        
        Account acc = new Account();
        acc.FirstName = randStr;
        acc.MiddleName = 'Test';
        acc.LastName = 'Doe';
        acc.PersonEmail = randStr+'@gmail.com';
        acc.BillingStreet = '1166 W Newport Center Dr';
        acc.BillingCity = 'Deerfield Beach';
        acc.BillingPostalCode =  '33442';
        acc.BillingState =  'FL';
        acc.BillingCountry =  'US';
        acc.Phone = '3333333333';
        acc.AccountNumber = '1234';
        acc.cst_tax_resale_exempt_nbr__c = 2;
        acc.loyaltyAccountNumber__c = '123456';
        acc.cst_exempt_certificate__c = '123456';
        acc.PersonTitle = 'Naveen';
        acc.Industry = 'BB';
        acc.Account_IndustryDesc__c = 'BOAT BUILDER ';
        acc.wmProTier_c__c = 'GOLD';
        acc.c_wmWarehouse__c = '605';
        acc.RegionZone__c = 'A';
        acc.PersonHomePhone = '123456';
        acc.Fax = 'Naveen';
        acc.AssociateId__c = 'Naveen';
        acc.Suffix__pc = 'Naveen';
        acc.cst_tax_code__c = 'E';
        acc.taxState__c = 'Naveen';
        acc.cst_tax_country__c = 'CO';
       acc.HowManyBoats__c = '4';  
        acc.BoatType__c = 'POWER';
        acc.BoatLength__c = '10';
        acc.PrimaryUse__c = 'A';
        acc.SecondaryUse__c = 'FRESHWATER FISHING';
        //acc.Associate__c = true;
        acc.Type = 'Analyst'; 
        acc.cst_rent_name__c = 'Y';
        acc.cst_rent_email__c = 'Y';
        acc.Test_Context__c = true;
        acc.Cust_Payment_Class__c = 'R';
        acc.Sales_Person_Name__c = createSalesmen();
        acc.SalesmanNumber__c = '1';
        acc.Salutation__pc = 'Test';
        insert acc;
        return acc;
    }
    
    
    public static SalesChannel createSalesChannel(){
        SalesChannel sChannl = new SalesChannel();
        sChannl.Description = 'WestMarine';
        sChannl.SalesChannelName = 'WestMarine';
        
        insert sChannl;
        return sChannl;
    }
    
    public static PricebookEntry createPricebookEntry(Product2 prd,Pricebook2 pricBook){
        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.Pricebook2Id = pricBook.Id;
        pbEntry.UnitPrice = 79.2;
        pbEntry.Product2Id = prd.Id;
        pbEntry.IsActive = true;
        insert pbEntry;
        return pbEntry;
    }    
    
    public static Pricebook2 createPricebook(){
            Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        return standardPricebook;
    }

    
    public static Contract createContractRecord(Id accountid ) {
        Contract Contr = new Contract();
        Contr.StartDate = Date.newInstance(2020, 12, 9);
        Contr.ContractTerm = 6;
        Contr.Status = 'Draft';
        Contr.AccountId = accountid;
        insert Contr;
        return Contr;
    }
    
    public static String getRandomNumber(integer stringLength) {

final integer MAX = integer.valueOf(Math.pow(10,stringLength) - 1);

return String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(stringLength,'0');

}
    
    public static Order createOrderRecord(Pricebook2 pricBook, Account acc, SalesChannel sChannl) {
        Order ordr = new Order();
        ordr.Pricebook2Id = pricBook.Id;
        ordr.name = 'SFOM' + TestDataFactory.getRandomNumber(4);
        ordr.Status = 'Draft';
        ordr.EffectiveDate = Date.valueOf('2019-08-01');
        ordr.OrderReferenceNumber = 'SFOM-TEST-' + TestDataFactory.getRandomNumber(4);
        ordr.BillingStreet = '1166 W Newport Center Dr';
        ordr.BillingCity = 'Deerfield Beach';
        ordr.BillingState = 'FL';
        ordr.BillingPostalCode = '33442';
        ordr.BillingCountry = 'US';
        ordr.BillingPhoneNumber = '3333333333';
        ordr.OrderedDate = Date.valueOf('2018-09-18');
        ordr.BillingEmailAddress = 'john@doe.com';
        ordr.poNumber__c = '12345';
        ordr.AccountId = acc.Id;
        ordr.SalesChannelId = sChannl.Id;
        ordr.Test_Context__c = true;
        ordr.IsHistorical__c = false;
        insert ordr;
        return ordr;
    }
    
    
    public static OrderDeliveryMethod createOrderDeliveryMethod(){
        OrderDeliveryMethod odMethod = new OrderDeliveryMethod();
        odMethod.Description = 'Ground';
        odMethod.Name = 'Ground';
        odMethod.ReferenceNumber = '001';
        odMethod.IsActive = true;
        
        insert odMethod;
        return odMethod;
    }
    
    public static String createOrderSummaryRecord(Order ordr) {
        
        ConnectApi.OrderSummaryInputRepresentation  input = new ConnectApi.OrderSummaryInputRepresentation();
        input.orderid = ordr.Id;
        //input.IsHistorical__c = false;
        //input.name = 'ABC1234'; 
        input.orderLifeCycleType = 'MANAGED';
        //input.status = 'Approved';
        
        ConnectApi.OrderSummaryOutputRepresentation output = ConnectApi.OrderSummaryCreation.createOrderSummary(input);
        return output.orderSummaryId;
    }
    
    public static String createOrderPaymentSummaryRecord(String OrderSumId,PaymentAuthorization payAuth) {
        ConnectApi.CreateOrderPaymentSummaryInputRepresentation orderPaymentSummaryInput = 
            new ConnectApi.CreateOrderPaymentSummaryInputRepresentation();
        orderPaymentSummaryInput.orderSummaryId = OrderSumId;
        orderPaymentSummaryInput.paymentAuthorizationId = payAuth.Id;
        
        ConnectApi.CreateOrderPaymentSummaryOutputRepresentation result = ConnectAPI.OrderPaymentSummary.createOrderPaymentSummary(orderPaymentSummaryInput);
        return result.orderPaymentSummaryId;
    }
    
    
    public static OrderItemSummary createOrderItemSummaryRecord(Id orgnlOrderItem) {
        OrderItemSummary ordprdsum = new OrderItemSummary();
        ordprdsum.Description = WMConstants.Description;
        ordprdsum.Name = WMConstants.Name;  
        ordprdsum.OriginalOrderItemId = orgnlOrderItem;
        ordprdsum.gcMessage__c = 'Naveen';
        ordprdsum.specialOrder__c = true;
        //ordprdsum.Status = ORDERED;
        //ordprdsum.OrderDeliveryGroupSummaryId = ordrDelGroupSummary;
        //ordprdsum.OrderSummaryId = ordrSumId;
        insert ordprdsum;
        return ordprdsum;
    }
    
    public static OrderItemSummary createDiscOrderItemSummaryRecord(Id orgnlOrderItem) {
        OrderItemSummary ordprdsum = new OrderItemSummary();
        ordprdsum.Description = WMConstants.Description;
        ordprdsum.Name = WMConstants.Name;  
        ordprdsum.OriginalOrderItemId = orgnlOrderItem;
        ordprdsum.sku_status__c = 'D';
        ordprdsum.backorderable__c = false;
        //ordprdsum.Status = ORDERED;
        //ordprdsum.OrderDeliveryGroupSummaryId = ordrDelGroupSummary;
        //ordprdsum.OrderSummaryId = ordrSumId;
        insert ordprdsum;
        return ordprdsum;
    }
    
  
    public static OrderItem createOrderItemRecord(Product2 prd,OrderDeliveryGroup odGrp, Order ordr,PricebookEntry pbEntry) {
        OrderItem ordItem = new OrderItem();
        ordItem.Description = 'WOMEN TORPEDO JACKET';
        ordItem.Type = 'Order Product';
        ordItem.Quantity = 1;
        ordItem.TotalLineAmount = 79.2;
        ordItem.LineNumber = 1;
        ordItem.UnitPrice = 79.2;
        ordItem.OrderId = ordr.Id;
        ordItem.OrderDeliveryGroupId = odGrp.Id;
        ordItem.PricebookEntryId = pbEntry.Id;
        ordItem.Product2Id = prd.Id;
        ordItem.eGiftCard__c = true;
        ordItem.gcMessage__c = 'Naveen';
        //ordItem.vendorLocation__c = 'TestLoc';
        //ordItem.notes__c = 'TestNo';
        ordItem.manufacturerSKU__c = 'TestNo';
        ordItem.longDescription__c = 'TestNo';
        ordItem.unitMeasure__c = 'TestNo';
        ordItem.weight__c = 'TestNo';
        ordItem.notes__c = 'TestNo';
        ordItem.UnitPrice = 10;
        ordItem.vendorLocation__c = '760';
        ordItem.vendorNumber__c = '12345';
        insert ordItem;
        return ordItem;
    }
    public static OrderDeliveryGroup createOrderDeliveryGroupRecord(OrderDeliveryMethod odMethod, Order ordr) {
        OrderDeliveryGroup odGrp = new OrderDeliveryGroup();
        odGrp.EmailAddress = 'john@doe.com';
        odGrp.DeliverToCity = 'Deerfield Beach';
        odGrp.DeliverToCountry = 'US';
        odGrp.DeliverToName = 'John Doe';
        odGrp.DeliverToPostalCode = '33442';
        odGrp.DeliverToState = 'FL';
        odGrp.DeliverToStreet = '1166 W Newport Center Dr';
        odGrp.PhoneNumber = '3333333333';
        odGrp.OrderDeliveryMethodId = odMethod.Id;
        odGrp.OrderId =  ordr.Id;
        odGrp.Test_Context__c = true;
        odGrp.DeliverToName = 'John Doe';
        odGrp.DeliverToStreet = 'Test Street';
        odGrp.DeliverToCity = 'Kansas City';
        odGrp.DeliverToState = 'MO';
        odGrp.DeliverToPostalCode = '64157';
        odGrp.DeliverToCountry = 'US';
        
        insert odGrp;
        return odGrp;
    }
    
    public static  OrderItemAdjustmentLineItem createOrderItemAdjustmentLineItem(OrderItem ordItem,OrderAdjustmentGroup ordAdjGrp) {
        OrderItemAdjustmentLineItem ordItmAdjLineItem = new OrderItemAdjustmentLineItem();
        ordItmAdjLineItem.Name = '2072100 - Adj';
        ordItmAdjLineItem.Amount =  -15.84;
        ordItmAdjLineItem.OrderItemId = ordItem.Id;
        ordItmAdjLineItem.OrderAdjustmentGroupId = ordAdjGrp.Id;
        
        insert ordItmAdjLineItem;
        return ordItmAdjLineItem;
    }
    
    public static OrderAdjustmentGroup createOrderAdjustmentGroup(Order ordr){
        OrderAdjustmentGroup ordAdjGrp = new OrderAdjustmentGroup();
        ordAdjGrp.Name = 'PromotionTest';
        ordAdjGrp.Description = 'PromotionTest';
        ordAdjGrp.Type = 'Header';
        ordAdjGrp.OrderId = ordr.Id;
        
        insert ordAdjGrp;
        return ordAdjGrp;
    }
    
    public static OrderItemTaxLineItem createOrderItemTaxLineItem(OrderItem ordItem,OrderItemAdjustmentLineItem ordItmAdjLineItem){        
        OrderItemTaxLineItem ordItmTaxLineItm = new OrderItemTaxLineItem();
        ordItmTaxLineItm.Name = '2072100 - Adjustment Tax';
        ordItmTaxLineItm.Type = 'Estimated';
        ordItmTaxLineItm.Amount = -0.79;
        ordItmTaxLineItm.Rate = 0.05;
        ordItmTaxLineItm.TaxEffectiveDate = Date.valueOf('2018-09-18');
        ordItmTaxLineItm.OrderItemId = ordItem.Id;
        ordItmTaxLineItm.OrderItemAdjustmentLineItemId = ordItmAdjLineItem.Id;
        
        insert ordItmTaxLineItm;
        return ordItmTaxLineItm;
    }
    
    public static Order updateOrderStatus(Order ordr){
        Order od = [Select Id,Status from Order where Id=:ordr.Id];
        od.Status = 'Activated';
        update od;
        return od;
    }
    
       public static Order cancelOrder(Order ordr){
        Order od = [Select Id,Status from Order where Id=:ordr.Id];
        od.Status = 'Canceled';
        update od;
        return od;
    }
    
    public static Product2 createProduct2Record() {
        Product2 prd = new Product2();
        prd.Description =  'WOMEN TORPEDO JACKET';
        prd.Name = 'WOMEN TORPEDO JACKET';
        prd.StockKeepingUnit = '11721009';
        prd.ProductCode = '1950598';
        prd.IsActive = true;
        
        insert prd;
        return prd;
    }
     public static Product2 createSecondProduct2Record() {
        Product2 prd = new Product2();
        prd.Description =  'WOMEN TORPEDO JACKET';
        prd.Name = 'WOMEN TORPEDO JACKET';
        prd.StockKeepingUnit = '11221109';
        prd.ProductCode = '1960598';
        prd.IsActive = true;
        
        insert prd;
        return prd;
    }
    
    public static Product2 createDiscontinuedProductRecord() {
        Product2 prd = new Product2();
        prd.Description =  'DISCONTINUED PRODUCT';
        prd.Name = 'DISCONTINUED PRODUCT';
        prd.StockKeepingUnit = 'item006';
        prd.ProductCode = 'item006';
        prd.IsActive = true;
        prd.sku_status__c='D';
        
        insert prd;
        return prd;
    }
    

    
    public static PaymentGroup createPaymentGroup(Order ordr) {
        PaymentGroup payGrp = new PaymentGroup();
        payGrp.SourceObjectId = ordr.Id;        
        insert payGrp;
        return payGrp;
    }
    
    public static String createInvoiceRecord(String fulfillmentOrderId) {
        ConnectApi.FulfillmentOrderInvoiceInputRepresentation invoiceInput = new ConnectApi.FulfillmentOrderInvoiceInputRepresentation();
        ConnectApi.FulfillmentOrderInvoiceOutputRepresentation outputRepresentation = ConnectApi.FulfillmentOrder.createInvoice(fulfillmentOrderId, invoiceInput);

        return outputRepresentation.invoiceId;   
    }
    
    public static String createCreditMemoRecord(String cancldOrdrId,String orderSummaryId) {
        ConnectApi.CreateCreditMemoInputRepresentation creditInput = new ConnectApi.CreateCreditMemoInputRepresentation();
        creditInput.changeOrderIds = new List<String>{cancldOrdrId};
        ConnectApi.CreateCreditMemoOutputRepresentation outputRepresentation = ConnectApi.OrderSummary.createCreditMemo(orderSummaryId, creditInput);

        return outputRepresentation.creditMemoId;   
    }
    
    
    public static PaymentAuthorization updatePaymentAuthorization(PaymentAuthorization payAuth,String orderpaySumId) {
        PaymentAuthorization updPayAuth = [Select Id,OrderPaymentSummaryId from PaymentAuthorization where Id=:payAuth.Id];
        updPayAuth.OrderPaymentSummaryId = orderpaySumId;
        update updPayAuth;
        return updPayAuth;
    }
    
    public static Schema.Location createLocation(){
        Schema.Location locatn = new Schema.Location();
        locatn.LocationType = 'Warehouse';
        locatn.Name = 'Test';
        locatn.ExternalReference = '514';

        insert locatn;
        return locatn;
        
    }
    
    public static List<String> createFulfillmentOrder(String orderSummaryId,String accountId, String warehouseFromLocationId) {
        String fulfillmentType = 'Drop Ship';
        
        ConnectApi.FulfillmentOrderInputRepresentation fulfillmentOrderInput = new ConnectApi.FulfillmentOrderInputRepresentation();
        fulfillmentOrderInput.orderSummaryId = orderSummaryId;
        
        List<OrderDeliveryGroupSummary> orderDeliveryGroupSummaryList = [SELECT Id FROM OrderDeliveryGroupSummary WHERE OrderSummaryId =: orderSummaryId];
        system.debug('Order Delivery Group Summary '+ orderDeliveryGroupSummaryList);
        for (OrderDeliveryGroupSummary orderDeliveryGroupSummary: orderDeliveryGroupSummaryList){
            
            fulfillmentOrderInput.orderDeliveryGroupSummaryId = orderDeliveryGroupSummary.Id;
            List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
            ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroup = new ConnectApi.FulfillmentGroupInputRepresentation();
            fulfillmentGroup.fulfilledFromLocationId = warehouseFromLocationId;
            fulfillmentGroup.fulfillmentType = fulfillmentType;
            
            List<ConnectApi.OrderItemSummaryInputRepresentation> orderItemSummaries = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
            
            List<OrderItemSummary> orderItemSummaryList = [Select Id, quantity FROM OrderItemSummary WHERE OrderSummaryId =: orderSummaryId AND OrderDeliveryGroupSummaryId =: orderDeliveryGroupSummary.Id];
            for(OrderItemSummary orderItemSummary : orderItemSummaryList){
                ConnectApi.OrderItemSummaryInputRepresentation oisInputRepresentation = new ConnectApi.OrderItemSummaryInputRepresentation();
                oisInputRepresentation.orderItemSummaryId = orderItemSummary.Id;
                oisInputRepresentation.quantity = orderItemSummary.quantity;
                orderItemSummaries.add(oisInputRepresentation);
            }
            
            fulfillmentGroup.orderItemSummaries = orderItemSummaries;
            fulfillmentGroups.add(fulfillmentGroup);      
            fulfillmentOrderInput.fulfillmentGroups = fulfillmentGroups;
            
        }
        
        ConnectApi.FulfillmentOrderOutputRepresentation result = ConnectAPI.FulfillmentOrder.createFulfillmentOrders(fulfillmentOrderInput);
        return result.fulfillmentOrderIds;
    }
    public static FulFillmentOrder updateFulfillmentOrder(String fulFillmntOrdrId,String invId){
    FulFillmentOrder fulFillmntOrdr = [Select Id,InvoiceId from FulFillmentOrder where Id=:fulFillmntOrdrId];
        fulFillmntOrdr.InvoiceId = invId;
        fulFillmntOrdr.Status = 'Fulfilled';
        try{
             update fulFillmntOrdr;
            return fulFillmntOrdr;
        }
        catch(Exception e){
            system.debug('Exception occured while updating FulFillment Order '+e);
            return null;
            }
       
    }
     public static Address__c createAddress(Id accId){
        Address__c addr = new Address__c();
         addr.Suffix__c = 'Naveen';
         addr.EmailAddress__c = 'test@gmail.com';
         addr.Account__c = accId;
         addr.Phone__c = '1234567890';
         addr.wmPreferredAddress__c = true;
         addr.ActiveAddress__c = true;
         addr.Address_Line_4__c = 'TestAddress';
         addr.MailCode__c = 'BB';
         addr.MailCodeDesc__c = 'BOAT BUILDER';
         addr.csh_van_route__c = 'Test';
         addr.cst_reserve_whs__c = 'nav';
         addr.First_Name__c = 'Naveen';
         addr.Last_Name__c = 'P';
         addr.Country__c = 'US';
         addr.Address_Line_1__c = 'Test';
         addr.Address_Line_2__c = 'Naveen';
         addr.Address_Line_3__c = 'Naveen';
         addr.Address_Line_4__c = 'Naveen';
         addr.City__c = 'India';
         addr.State__c = 'CA';
         addr.Postal_Code__c = '123456';
         addr.csh_van_route__c = 'Text';
         addr.csh_van_route_seq__c = 1234;
         insert addr;
         return addr;
     }
    public static e_GiftCard__c createGiftCard(String odSumId){
        e_GiftCard__c GftCrd = new e_GiftCard__c();
        GftCrd.Gift_Card_Number__c = 'U610003505157349';
        GftCrd.Amount__c = 123;
        GftCrd.Order_Summary__c = odSumId;
        GftCrd.Issued__c =  true;
        insert GftCrd;
        return GftCrd;
    }
    public static Tax_Exemption__c CreateTaxExemption (Id accId){
        Tax_Exemption__c  TaxExm = new Tax_Exemption__c();
        TaxExm.AccountId__c = accId;
        TaxExm.Country__c = 'US';
        TaxExm.Name = 'Naveen';
        TaxExm.Exemption_Certificate__c = '111';
        TaxExm.Exemption_Type__c = 'T';
        TaxExm.Expiration_Date__c = Date.valueOf('2021-06-11'); 
        TaxExm.State__c = 'DC';
        insert TaxExm;
        return TaxExm;
    }
       public static Contact CreateContacts (Id accId){
        Contact  con = [select id,Lastname from contact where AccountId =: accId ];
        con.AccountId = accId;
        con.lastName = 'United States';
        con.FirstName = 'Naveen';
        con.Title = 'Test';
        con.Email = 'test@gmail.com';  
        con.HasOptedOutOfEmail = true;
        con.cif_rent_flag__c = true; 
        //update con;
        return con;
    }
    
 public static Account CreateBusinAccount(){ 
        Account Acc1 = new Account();        
        Acc1.Name = 'Naveen';
        Acc1.AccountNumber = '10416913';
        Acc1.Type = 'Business';
        //Acc1.ParentId = accId;
        Acc1.Email__c = 'test1@gmail.com';
        insert Acc1;
        return Acc1;
    }
    
}