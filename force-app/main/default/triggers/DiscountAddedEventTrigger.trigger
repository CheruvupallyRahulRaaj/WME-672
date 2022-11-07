trigger DiscountAddedEventTrigger on Discount_Added__e (after insert) {
    System.debug('AAA: DiscountAddedEventTrigger');
    Set<ID> setCreditMemoIds = new Set<ID>();
    System.debug('AAA: Total Events:' + Trigger.new.size());
    for(Discount_Added__e event : Trigger.new){
        setCreditMemoIds.add(event.Credit_Memo_ID__c);
        System.debug('AAA: Credit Memo ID:' + event.Credit_Memo_ID__c);
    }

    Map<Id,CreditMemo> mapCreditMemo = new Map<Id,CreditMemo>([
        SELECT
            Id,
            (Select ID, ReferenceEntityItemId,AdjustmentAmount,Type,RelatedLineId From CreditMemoLines)
        FROM
            CreditMemo
        WHERE ID IN :setCreditMemoIds
    ]);

    Map<Id,Decimal> OrderItemSummaryIdToDiscountMap = new Map<Id,Decimal>();
    for(CreditMemo cm : mapCreditMemo.values()){
        for(CreditMemoLine cmLine : cm.CreditMemoLines){
            if(cmLine.Type == 'Charge' && cmLine.ReferenceEntityItemId != null && cmLine.RelatedLineId == null){
                System.debug('AAA: Found Line with Type Charge' + cmLine.Id);
                Decimal amount = 0; 
                for(CreditMemoLine cmLineChild : cm.CreditMemoLines){
                    System.debug('AAA: RelatedLineId:' + cmLineChild.RelatedLineId);
                    if(cmLineChild.Type == 'Adjustment' && cmLineChild.RelatedLineId == cmLine.Id){
                        System.debug('AAA: Got It. Add Amount:' + cmLineChild.AdjustmentAmount);
                        amount += cmLineChild.AdjustmentAmount;
                    }
                }
                OrderItemSummaryIdToDiscountMap.put(cmLine.ReferenceEntityItemId, amount);
            }
        }
    }


    // for(CreditMemo cm : mapCreditMemo.values()){
    //     System.debug('AAA:Loop Credit Memo ID:' + cm.Id);
    //     System.debug('AAA:Total Lines:' + cm.CreditMemoLines.size());
    //     for(CreditMemoLine cmLineMaster : cm.CreditMemoLines){
    //         if(cmLineMaster.Type == 'Charge'){
    //             Id orderItemSummaryId = cmLineMaster.
    //             for(CreditMemoLine cmLine : cm.CreditMemoLines){
    //                 System.debug('CM Line ID: ' + cmLine.Id + ' ReferenceEntityId:' + cmLine.ReferenceEntityItemId);
    //                 if(!OrderItemSummaryIdToDiscountMap.containsKey(cmLine.ReferenceEntityItemId)){
    //                     OrderItemSummaryIdToDiscountMap.put(cmLine.ReferenceEntityItemId, 0);
    //                 }
    //                 Decimal runningTotal = OrderItemSummaryIdToDiscountMap.get(cmLine.ReferenceEntityItemId);
    //                 System.debug('AAA: Existing Value:' + runningTotal);
    //                 runningTotal += cmLine.AdjustmentAmount;
    //                 System.debug('AAA: New Value:' + runningTotal);
    //                 OrderItemSummaryIdToDiscountMap.put(cmLine.ReferenceEntityItemId, runningTotal);
    //             }
    //         }
    //     }
    // }

    for(Id oisId : OrderItemSummaryIdToDiscountMap.keySet()){
        System.debug('AAA: OrderItemSummaryID: ' + oisId + ' : DiscountValue:' + OrderItemSummaryIdToDiscountMap.get(oisId));
    }


    List<OrderItemSummary> lstOrderItemSummaries = [
        SELECT
            Id,
            TotalDiscountAdjustmentAmount__c
        FROM
            OrderItemSummary
        WHERE ID IN :OrderItemSummaryIdToDiscountMap.keySet()
    ];

    System.debug('AAA: Size of OrderItemSummaries:' + lstOrderItemSummaries.size());

    for(OrderItemSummary ois : lstOrderItemSummaries){
        System.debug('AAA: OISID:' + ois.Id);
        Decimal calculatedDiscountAdjustmentAmount = OrderItemSummaryIdToDiscountMap.get(ois.Id);
        System.debug('AAA: Value to Add:' + calculatedDiscountAdjustmentAmount);
        ois.TotalDiscountAdjustmentAmount__c += calculatedDiscountAdjustmentAmount;
        System.debug('AAA: New Value:' + ois.TotalDiscountAdjustmentAmount__c);
    }

    if(lstOrderItemSummaries.size()>0){
        update lstOrderItemSummaries;
    }





}