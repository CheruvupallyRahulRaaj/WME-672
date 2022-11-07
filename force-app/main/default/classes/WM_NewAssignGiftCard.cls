global class WM_NewAssignGiftCard {
    @InvocableMethod(label='Assign New Gift Card')
    global static void assignGiftCards(List<orderItemSummary> OrderItemSummaryIds){

        // Get the Order Summary
        List<orderItemSummary> lstordrItemSum = new List<orderItemSummary>();
        lstordrItemSum = [Select Id,Quantity,TotalPrice,OrderSummaryId,UnitPrice,gcRecipientName__c, 
                                        gcMessage__c, gcFromName__c,gcFromEmail__c,gcRecipientEmail__c from orderItemSummary where Id =:OrderItemSummaryIds and eGiftCard__c=true];
        
                                        List<e_GiftCard__c> updatedgiftCardList =  new List<e_GiftCard__c>();                              
        for (orderItemSummary ordrItemSum : lstordrItemSum) 
        {
        
            for(Integer i=0;i<ordrItemSum.Quantity;i++)
            {
            String query = 'SELECT Id, Amount__c, Gift_Card_Number__c, Order_Summary__c, Order_Product_Summary__c, Is_Assigned__c, Issued__c FROM e_GiftCard__c where' 
                +' Amount__c=null and Gift_Card_Number__c!=null and Issued__c=false and Is_Assigned__c= false ORDER BY Createddate limit 1 OFFSET '+String.valueOf(i);
            e_GiftCard__c  egf =Database.query(query);
            egf.Amount__c = ordrItemSum.UnitPrice;
            egf.Order_Summary__c =   ordrItemSum.OrderSummaryId;
            egf.Order_Product_Summary__c = ordrItemSum.Id;
            egf.gcMessage__c= ordrItemSum.gcMessage__c;
            egf.gcRecipientName__c= ordrItemSum.gcRecipientName__c;
            egf.gcRecipientEmail__c=  ordrItemSum.gcRecipientEmail__c;
            egf.gcFromName__c = ordrItemSum.gcFromName__c;
            egf.gcFromEmail__c = ordrItemSum.gcFromEmail__c;
                updatedgiftCardList.add(egf);    
            }
        
        }  
        if(updatedgiftCardList.size()>0){
            upsert updatedgiftCardList;
        }
    }
}