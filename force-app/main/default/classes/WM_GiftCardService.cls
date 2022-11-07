public class WM_GiftCardService implements Queueable,Database.AllowsCallouts {
    
    private List<e_GiftCard__c> egiftCrdList;
    private List<String> requestBodyList;
    private Integer currentIndex; 
    public WM_GiftCardService(List<e_GiftCard__c> giftCrdList,List<String> payLoadList,Integer index) {
        this.egiftCrdList = giftCrdList;
        this.requestBodyList = payLoadList;
        this.currentIndex = index;
    }
    
    @InvocableMethod(label='GiftCardService')
    public static void giftCardService (List<Id> eGiftCardId) {
        List<e_GiftCard__c> giftCrdList =[Select Id,Name,Gift_Card_Number__c, 
                                          Order_Summary__c,Order_Summary__r.OrderNumber,Order_Summary__r.Createddate, Amount__c, Issued__c, 
                                          Is_Assigned__c,gcMessage__c from e_GiftCard__c where Id In:eGiftCardId];
        Map<String,List<String>> mapOfOrderSummaryWithGiftCard = new Map<String,List<String>>();
        Map<String,OrderDeliveryGroupSummary> mapOfOrderDelGrpSummaryWithGiftCard = new Map<String,OrderDeliveryGroupSummary>();
        for(e_GiftCard__c eGiftCrd : giftCrdList){
            if(mapOfOrderSummaryWithGiftCard.containsKey(eGiftCrd.Order_Summary__c)){
                List<String> tempList = mapOfOrderSummaryWithGiftCard.get(eGiftCrd.Order_Summary__c);
                tempList.add(eGiftCrd.Id);
                mapOfOrderSummaryWithGiftCard.put(eGiftCrd.Order_Summary__c,tempList);
            }
            else{
                mapOfOrderSummaryWithGiftCard.put(eGiftCrd.Order_Summary__c,new List<String>{eGiftCrd.Id});
            }
        }
        List<OrderDeliveryGroupSummary> orderDelGrpSumList= [SELECT Id, OriginalOrderDeliveryGroupId,OriginalOrderDeliveryGroup.DeliverToName,OriginalOrderDeliveryGroup.DeliverToStreet,
                                                             OriginalOrderDeliveryGroup.DeliverToCity,OriginalOrderDeliveryGroup.DeliverToState,OriginalOrderDeliveryGroup.DeliverToPostalCode,
                                                             OriginalOrderDeliveryGroup.DeliverToCountry,OrderSummaryId FROM OrderDeliveryGroupSummary where OrderSummaryId In:mapOfOrderSummaryWithGiftCard.keySet()];
        for(OrderDeliveryGroupSummary ordrDelgrpSum: orderDelGrpSumList){
            if(mapOfOrderSummaryWithGiftCard.containsKey(ordrDelgrpSum.OrderSummaryId)){
                
                for(String eGfId:mapOfOrderSummaryWithGiftCard.get(ordrDelgrpSum.OrderSummaryId)){
                    mapOfOrderDelGrpSummaryWithGiftCard.put(eGfId,ordrDelgrpSum);
                }
            }
        }
        List<String> listOfRequestBody = new List<String>();
        for(e_GiftCard__c giftCrd:giftCrdList){
            OrderDeliveryGroupSummary odGrpSum = mapOfOrderDelGrpSummaryWithGiftCard.get(giftCrd.Id);
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('Request');
            gen.writeStartObject();
            gen.writeStringField('Division', 'WMRetail');
            if(WM_Utils.getString(giftCrd.Order_Summary__r.OrderNumber)!=null){
                gen.writeStringField('OrderNumber', WM_Utils.getString(giftCrd.Order_Summary__r.OrderNumber)); 
            }
            if(WM_Utils.getString(giftCrd.Order_Summary__r.CreatedDate)!=null){
                gen.writeStringField('OrderDate', WM_Utils.getStringForDateTime(giftCrd.Order_Summary__r.CreatedDate));
            }
            
            gen.writeStringField('CallType', 'FA');
            if(WM_Utils.getString(giftCrd.Gift_Card_Number__c)!=null){
                gen.writeStringField('CardType', ((WM_Utils.getString(giftCrd.Gift_Card_Number__c)).substring(0,2)));
                gen.writeStringField('AccountNumber', ((WM_Utils.getString(giftCrd.Gift_Card_Number__c)).substring(2,12)));
                gen.writeStringField('CardSecure', ((WM_Utils.getString(giftCrd.Gift_Card_Number__c)).substring(12,16)));                     
            }
            if(WM_Utils.getString(giftCrd.Amount__c)!=null){ 
                gen.writeStringField('Amount', WM_Utils.getString(giftCrd.Amount__c)); 
            }
            if(WM_Utils.getString(odGrpSum.OriginalOrderDeliveryGroup.DeliverToName)!=null){ 
                gen.writeStringField('Name', WM_Utils.getString(odGrpSum.OriginalOrderDeliveryGroup.DeliverToName)); 
            }
            if(WM_Utils.getString(odGrpSum.OriginalOrderDeliveryGroup.DeliverToStreet)!=null){
                String address = WM_Utils.getString(odGrpSum.OriginalOrderDeliveryGroup.DeliverToStreet);
                if (address.length() > 30) {
                    address = address.substring(0, 29);
                }
                gen.writeStringField('Address1', address);  
            }
            if(WM_Utils.getString(odGrpSum.OriginalOrderDeliveryGroup.DeliverToCity)!=null){ 
                gen.writeStringField('City', WM_Utils.getString(odGrpSum.OriginalOrderDeliveryGroup.DeliverToCity)); 
            }
            if(WM_Utils.getString(odGrpSum.OriginalOrderDeliveryGroup.DeliverToState)!=null){ 
                gen.writeStringField('State', WM_Utils.getString(odGrpSum.OriginalOrderDeliveryGroup.DeliverToState));
                
            }
            if(WM_Utils.getString(odGrpSum.OriginalOrderDeliveryGroup.DeliverToPostalCode)!=null){ 
                gen.writeStringField('Zip', WM_Utils.getString(odGrpSum.OriginalOrderDeliveryGroup.DeliverToPostalCode));
                
            }
            if(WM_Utils.getString(odGrpSum.OriginalOrderDeliveryGroup.DeliverToCountry)!=null){ 
                gen.writeStringField('Country', WM_Utils.getString(odGrpSum.OriginalOrderDeliveryGroup.DeliverToCountry));
                
            }
            gen.writeEndObject();
            gen.writeEndObject();
            String reqBody = gen.getAsString();
            system.debug('request body '+reqBody);
            listOfRequestBody.add(reqBody);
        }
        
        WM_GiftCardService giftService = new WM_GiftCardService(giftCrdList,listOfRequestBody,0);
        System.enqueueJob(giftService);
        
    }
    public void execute (QueueableContext context) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        // retreving the API key which is configured in Custom Settings
        String apiKey = WM_WebServiceDetails__c.getValues('GiftCardService').WM_ApiKey__c;
        // Setting appropriate attributes for the request
        request.setEndpoint('callout:GiftCardService');
        request.setMethod('POST'); 
        request.setHeader('Content-Type','application/json');
        request.setHeader('api_key',apiKey);
        request.setHeader('Accept','text/plain');
        request.setBody(requestBodyList[currentIndex]);
        request.setTimeout(60000);
        System.debug('request : '+ request);
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        system.debug('getStatusCode ' + response.getStatusCode());
        system.debug('getBody ' + response.getBody());
        if(response.getStatusCode() ==200){
            e_GiftCard__c eGiftCrd = [Select Id,Issued__c from e_GiftCard__c where Id=:egiftCrdList[currentIndex].Id];
            eGiftCrd.Issued__c = true;
            try{
                update eGiftCrd;
                if(currentIndex!=egiftCrdList.size()-1 && currentIndex<egiftCrdList.size()){
                    WM_GiftCardService giftService = new WM_GiftCardService(egiftCrdList,requestBodyList,currentIndex+1);
                    System.enqueueJob(giftService);
                }
            }
            catch(Exception e){
                system.debug('Exception occured '+e);
                if(currentIndex!=egiftCrdList.size()-1 && currentIndex<egiftCrdList.size()){
                    WM_GiftCardService giftService = new WM_GiftCardService(egiftCrdList,requestBodyList,currentIndex+1);
                    System.enqueueJob(giftService);
                }
            }
        }
    }
}