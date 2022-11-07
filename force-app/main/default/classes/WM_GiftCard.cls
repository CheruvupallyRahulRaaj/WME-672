global class WM_GiftCard {
    @InvocableMethod(label='Assign New Gift Card')
    global static void assignGiftCards(List<List<String>> orderItemSummaryIds){
        
        // Get the Order Summary
        List<orderItemSummary> lstordrItemSum = new List<orderItemSummary>();
        lstordrItemSum = [Select Id,Quantity,TotalPrice,OrderSummaryId,UnitPrice,gcRecipientName__c, 
                          gcMessage__c, gcFromName__c,gcFromEmail__c,gcRecipientEmail__c from orderItemSummary where Id IN: orderItemSummaryIds[0] and eGiftCard__c=true];
        Integer totalQuantitiesOfGiftCard = 0;
        for (orderItemSummary ordrItemSum : lstordrItemSum) 
        {
            totalQuantitiesOfGiftCard = totalQuantitiesOfGiftCard + Integer.valueOf(ordrItemSum.Quantity);      
            
        }
        
        String query = 'SELECT Id, Amount__c, Gift_Card_Number__c, Order_Summary__c, Order_Product_Summary__c, Is_Assigned__c, Issued__c FROM e_GiftCard__c where' 
            +' Amount__c=null and Gift_Card_Number__c!=null and Issued__c=false and Is_Assigned__c= false ORDER BY Createddate limit '+String.valueOf(totalQuantitiesOfGiftCard);
        List<e_GiftCard__c>  egfList =Database.query(query);
        List<e_GiftCard__c> updatedgiftCardList =  new List<e_GiftCard__c>();          
        
        Integer j =1;
        Integer k = 0;
        for (orderItemSummary ordrItemSum : lstordrItemSum) 
        {
            Integer i;
            for( i =j;i<=egfList.size();i++){
                
                
                if(i-j<Integer.valueOf(ordrItemSum.Quantity)){              
                    egfList[k].Amount__c = ordrItemSum.UnitPrice;
                    egfList[k].Order_Summary__c =   ordrItemSum.OrderSummaryId;
                    egfList[k].Order_Product_Summary__c = ordrItemSum.Id;
                    egfList[k].gcMessage__c= ordrItemSum.gcMessage__c;
                    egfList[k].gcRecipientName__c= ordrItemSum.gcRecipientName__c;
                    egfList[k].gcRecipientEmail__c=  ordrItemSum.gcRecipientEmail__c;
                    egfList[k].gcFromName__c = ordrItemSum.gcFromName__c;
                    egfList[k].gcFromEmail__c = ordrItemSum.gcFromEmail__c;
                    updatedgiftCardList.add(egfList[k]);    
                    k++;
                }
                else{
                    j=i;
                    break;
                }
            }
            
            
            
        }
        if(updatedgiftCardList.size()>0){
            update updatedgiftCardList;
        }
        
    }
}