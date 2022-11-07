public with sharing class CheckATFFromInventory {

    @InvocableMethod(label='Get ATF forLocations')
    public static List<Response> checkATFFromGetInventoryOutput(List<WM_ATFLocationsRequest> requestList) {
        System.debug('Input:: ' +requestList);
        WM_ATFLocationsRequest request = requestList[0];
        List<Response> responses = new List<Response>();
        Response response = new Response();
        for(OrderItemSummary ois : request.orderItemSummaries){
            if(ois.StockKeepingUnit==request.currectSKUInLoop){
                Integer iQty=ois.Quantity.intValue();
                System.debug('Qty on the product is::  ' +iQty);
                System.debug('Current SKU in Loop is:: ' +ois.StockKeepingUnit);
            if(ois.backorderable__c==false && (ois.sku_status__c=='D' || ois.sku_status__c=='Z'))
        {
            Integer iTempATF=0;
            for(ConnectApi.OCILocationAvailabilityOutputRepresentation location : request.locations){
            for(ConnectApi.OCIInventoryRecordOutputRepresentation invRec  : location.inventoryRecords){
                System.debug('SKU:' + invRec.StockKeepingUnit + ' : AvailableToFUlfill:' + invRec.availableToFulfill);
                iTempATF+=invRec.availableToFulfill.intValue();
                }
            }
            if(iTempATF ==0 && ois.Quantity.intValue()!=0 ){
                System.debug('Final ATF is 0 for the D & Z SKU :: ' +ois.StockKeepingUnit);
                Integer ATF=0;
                String SKU=ois.StockKeepingUnit;
                Id oisId=ois.Id;
                response.ZeroATF=ATF;
                response.ZeroSKU=SKU;
                response.ZeroOISId=oisId;
                break;
            }
            else{
                //SKU which is D or Z but has inventory.
                response.ZeroATF=iTempATF;
                response.ZeroSKU='NA';
                break;
            }
        }  
      //SKU which is non D or Z.
                else{
                response.ZeroATF=01;
                response.ZeroSKU='NA';
                break;
            }                
            } 
            
  }
        System.debug('Final Zero ATF:: ' +response.ZeroATF);
        System.debug('Final Zero SKU:: ' +response.ZeroSKU);
        System.debug('Final Zero OIS Id:: ' +response.ZeroOISId);
  		responses.add(response);
  		return responses;
    }
    
    public class WM_ATFLocationsRequest {
        @InvocableVariable(label='OCILocations' required=true)
         public List<ConnectApi.OCILocationAvailabilityOutputRepresentation> locations; 
        @InvocableVariable(label='Order Product Summaries' required=true)
         public List<OrderItemSummary> orderItemSummaries; 
        @InvocableVariable
         public String currectSKUInLoop; 
    }

 	public class Response {
        //ZeroATF,ZeroSKU,ZeroOISId = Will be populated only when ATF =0 for the current sku in the loop.
        ////orderItemSummariesOp will be populated for non D&Z items and for D&Z items which has inventory.
        @InvocableVariable
        public Integer ZeroATF;
        @InvocableVariable
        public String ZeroSKU;
        @InvocableVariable
        public Id ZeroOISId;      
    }
}