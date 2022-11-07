public class UpdateOrderDeliveryGroupSummary {

   @InvocableMethod(label='Update Order Delivery group Summary List')
    public static void updateRecords(List<Request> requests ){
        
        try{
            for(Request req:requests){
        if(req.orderDelGroupSumList!=null && req.orderDelGroupSumList.size()>0){
            system.debug('req.orderDelGroupSumList '+req.orderDelGroupSumList);
            List<OrderDeliveryGroupSummary> orderDelGroupSumListToUpdate = new List<OrderDeliveryGroupSummary>();
            for(OrderDeliveryGroupSummary ordrDelGrpSum:req.orderDelGroupSumList){
                ordrDelGrpSum.PartiallyFulfilled__c = false;
            
            orderDelGroupSumListToUpdate.add(ordrDelGrpSum);
            }
            update orderDelGroupSumListToUpdate;
        }
        }
        }
        catch (Exception e){
            system.debug('Exception occured while updating Order Delivery Group Summary records '+e);
        }
        
    }
    
     public class Request {
        @InvocableVariable
        public List<OrderDeliveryGroupSummary> orderDelGroupSumList;
     }
    
}