public with sharing class WM_AssignNonZeroSKUs {

    @InvocableMethod(label='Set Non ATF Items')
    public static List<Response> checkifSKUExists(List<WM_AssignRequest> requestList) {
        System.debug('Input from WM_AssignNonZeroSKUs :: ' +requestList);
        WM_AssignRequest request = requestList[0];
        List<Response> responses = new List<Response>();
        Response response = new Response();
         Set<String> SKUValuesofOPS = new Set<String>();
        Set<String> SKUValuesofCancel = new Set<String>();
        if(request.cancelSKUList.size()>0)
        {
         for(OrderItemSummary ois : request.orderItemSummaries)
        {
           SKUValuesofOPS.add(ois.StockKeepingUnit); 
        }
        System.debug('@@@@@ SKUs of OPS'+SKUValuesofOPS);
        
        for(String canS : request.cancelSKUList)
        {
           SKUValuesofCancel.add(canS);
        }
        System.debug('@@@@@ SKUs of CancelList'+SKUValuesofCancel);
        
        Set<String> differences = new Set<String>();
        differences.addAll(SKUValuesofOPS); 
         System.debug('@@@@@ Differences/SKUs of OPS'+SKUValuesofCancel);
		for(String item : SKUValuesofCancel)                  
            {
              if( !differences.add(item) )             
              {
                 differences.remove(item);                                       
              }
            }
        List<OrderItemSummary> OISUpdated = new List<OrderItemSummary>();
        for(OrderItemSummary ois : request.orderItemSummaries)
        {
            if(differences.contains(ois.StockKeepingUnit))
            {
                OISUpdated.add(ois);
            }
        }
        System.debug('@@@@@ Final List of OPS'+OISUpdated);
	    response.orderItemSummariesOutput=OISUpdated;
        responses.add(response);    
        }
                return responses;
}
    
    public class WM_AssignRequest 
    {
        @InvocableVariable(label='Order Product Summaries' required=true)
         public List<OrderItemSummary> orderItemSummaries; 
        @InvocableVariable
         public List<String> cancelSKUList; 
    }
    public class Response {      
		@InvocableVariable(label='Order Product Summaries' required=true)
         public List<OrderItemSummary> orderItemSummariesOutput; 
    }
}