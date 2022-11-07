public class WM_FutureDeliveryDate {
    
    @InvocableMethod(label='SetFutureDeliveryDate')
    public static void futureDeliveryDate(List<Id> orderSumIds){
        
        List<OrderSummary> listId = new List<OrderSummary>();
        List<OrderSummary> updateList = new List<OrderSummary>();
        listId = [Select Id,futureDeliveryDate__c,Future_Delivery_Date__c,OrderedDate from OrderSummary where Id in :orderSumIds ];
        System.debug('OrderSumData :' + listId);

        for(OrderSummary listItem : listId)
        {   
            if(listItem.futureDeliveryDate__c != NUll && !String.isBlank(listItem.futureDeliveryDate__c))
            { 
            Date newDate = Date.parse(listItem.futureDeliveryDate__c);         
            listItem.Future_Delivery_Date__c = newDate;
            updateList.add(listItem);
            }
            
        }
        if(updateList.size() > 0)
        update updateList;

     }
}