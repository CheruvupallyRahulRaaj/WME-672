public class WM_ReturnReceivedService implements Queueable,Database.AllowsCallouts {
    
    private String payload;
    public WM_ReturnReceivedService(String reqBody) {
        this.payload = reqBody;
    }
    
    /*Method Name : returnReceivedService
*Accepting Parameters :  Credit Memo Id
*Purpose : Invocable from a flow to execute a call to an external system
*/
    @InvocableMethod(label='ReturnReceivedService')
    public static void returnReceivedService (List<Id> creditMemoId) {
        
        system.debug('Entered the Flow with ID as: '+creditMemoId);
        if(creditMemoId.size()>0){
            
            CreditMemo creditMemoObj  = WM_ServiceHelper.getCreditMemo(creditMemoId[0]);
            OrderSummary ordrSummary = new OrderSummary();
            Order ordr = new Order();
            List<OrderItemSummaryChange> orderItemSumChangeList = new List<OrderItemSummaryChange>();
            List<CreditMemoLine> CreditmemoLineList = new List<CreditMemoLine>();
            if(creditMemoObj.ReferenceEntityId!=null){
                ordrSummary =  WM_ServiceHelper.getOrderSummary(creditMemoObj.ReferenceEntityId);
                orderItemSumChangeList = WM_ServiceHelper.getOrderItemSummaryChange(creditMemoObj.ReferenceEntityId);
                CreditmemoLineList = WM_ServiceHelper.getCreditMemoLine(creditMemoObj.id);
                
            }
            if(orderItemSumChangeList.size()>0){
                for(OrderItemSummaryChange chngItem:orderItemSumChangeList){
                    //Integer Ra_nbrCount = WM_Utils.getInteger(chngItem.OrderItemSummary.ReturnAuthorizationField__c);
                    if(chngItem.OrderItemSummary.Type=='Order Product'){
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    gen.writeFieldName('Return_Out');
                    gen.writeStartObject();
                    if(WM_Utils.getString(ordrSummary.OrderNumber)!=null){
                        gen.writeStringField('order_nbr', WM_Utils.getString(ordrSummary.OrderNumber));
                    }
                    // if(WM_Utils.getInteger(chngItem.OrderItemSummary.ReturnAuthorizationField__c)!=null)  {
                    // 	gen.writeStringField('ra_nbr', WM_Utils.getString(Ra_nbrCount));
                    // }
                    if(CreditmemoLineList.size()>0){
                        for(CreditMemoLine crmlines:CreditmemoLineList){
                            if(crmlines.ReferenceEntityItemId==chngItem.OrderItemSummary.id){
                                if(WM_Utils.getString(crmlines.ReturnAuthAssignment__c)!=null){
                                    gen.writeStringField('ra_nbr', WM_Utils.getString(crmlines.ReturnAuthAssignment__c));
                                }
                            }
                        }
                    }
                    if(WM_Utils.getString(chngItem.OrderItemSummary.LineNumber)!=null)  {
                        gen.writeStringField('line_nbr',WM_Utils.getString(chngItem.OrderItemSummary.LineNumber));
                    }      
                    if(WM_Utils.getString(chngItem.OrderItemSummary.QuantityReturned)!=null)  {
                        gen.writeStringField('qty_returned',WM_Utils.getString(chngItem.OrderItemSummary.QuantityReturned));   
                        gen.writeStringField('qty_credited',WM_Utils.getString(chngItem.OrderItemSummary.QuantityReturned));   
                    }
                    gen.writeStringField('return_date',WM_Utils.getStringForDateTimeNoTimeZone(chngItem.CreatedDate));  
                    if(WM_Utils.getString(chngItem.Reason)!=null)  {               
                        gen.writeStringField('ret_reason',WM_Utils.getString(chngItem.Reason)); 
                    }
                     if(WM_Utils.getString(creditMemoObj.Return_Disposition_Code__c)!=null)  {  
                    gen.writeStringField('ret_disposition_code',WM_Utils.getString(creditMemoObj.Return_Disposition_Code__c)); 
                                         }
                    // if(WM_Utils.getString(chngItem.OrderItemSummary.ProductCode)!=null){
                    //   gen.writeStringField('item',WM_Utils.getString(chngItem.OrderItemSummary.ProductCode));                   
                    // }   
                    
                    // Added by Manohar, WME-128 Changes Start 
                    if(WM_Utils.getString(chngItem.OrderItemSummary.Special_Order_SKU__c)!=null ){
                       system.debug('in if special order');
                       gen.writeStringField('item', WM_Utils.getString(chngItem.OrderItemSummary.Special_Order_SKU__c));
                    }else if(WM_Utils.getString(chngItem.OrderItemSummary.ProductCode)!=null){ 
                       gen.writeStringField('item', WM_Utils.getString(chngItem.OrderItemSummary.ProductCode));
                       system.debug('in if normal order');
                    }
                    // Added by Manohar, WME-128 Changes End  
                   
                    if(WM_Utils.getString(chngItem.OrderItemSummary.Description)!=null){
                        gen.writeStringField('item_desc',WM_Utils.getString(chngItem.OrderItemSummary.Description));                   
                    }    
                    
                    String reqBody = gen.getAsString();
                    system.debug('request body '+reqBody);
                     WM_ReturnReceivedService receivedService = new WM_ReturnReceivedService(reqBody);
                      ID jobID = System.enqueueJob(receivedService);
                }
                }
            }                  
            
        }
    }
    public void execute (QueueableContext context) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        // retreving the API key which is configured in Custom Settings
        String apiKey = WM_WebServiceDetails__c.getValues('ReturnReceivedKey').WM_ApiKey__c;
        // Setting appropriate attributes for the request
        request.setEndpoint('callout:ReturnReceivedService');
        request.setMethod('POST'); 
        request.setHeader('Content-Type','application/json');
        request.setHeader('api_key',apiKey);   
        request.setBody(payload);
        System.debug('request : '+ request);
        request.setTimeout(60000);
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        system.debug('getStatusCode ' + response.getStatusCode());
        system.debug('getBody ' + response.getBody());
    }
}