global class ScheduleReEvalFlow implements Schedulable {
  global void execute(SchedulableContext ctx) {
    //List<OrderDeliveryGroupSummary> orderDelGrpSum = new List<OrderDeliveryGroupSummary>();
    List<OrderItemSummary> lsOrderItemSummary = new List<OrderItemSummary>();
    String dt = '2021-11-18 00:00:00';
    DateTime refDate = DateTime.valueOf(dt);

    Set<String> setEligibleStates = new Set<String>{
      'ORDERED',
      'PARTIALLYFULFILLED',
      'PARTIALLYALLOCATED'
    };

    if (!test.isRunningTest()) {
      lsOrderItemSummary = [
        SELECT
          Id,
          OrderDeliveryGroupSummaryId,
          OrderDeliveryGroupSummary.PartiallyFulfilled__c,
          OrderDeliveryGroupSummary.OriginalOrderDeliveryGroupId,
          OrderDeliveryGroupSummary.OrderSummaryId
        FROM OrderItemSummary
        WHERE
          OrderDeliveryGroupSummary.PartiallyFulfilled__c = TRUE
          AND OrderSummary.Hold_Re_evaluation__c = FALSE
          AND OrderSummary.IsHistorical__c = FALSE
          AND TypeCode = 'Product'
          AND ProductCode != 'special-order-name'
          AND Status IN :setEligibleStates
          AND OrderSummary.OrderedDate > :refDate
      ];
    } else {
      lsOrderItemSummary = [
        SELECT
          Id,
          OrderDeliveryGroupSummaryId,
          OrderDeliveryGroupSummary.PartiallyFulfilled__c,
          OrderDeliveryGroupSummary.OriginalOrderDeliveryGroupId,
          OrderDeliveryGroupSummary.OrderSummaryId
        FROM OrderItemSummary
        WHERE
          OrderDeliveryGroupSummary.PartiallyFulfilled__c = TRUE
          AND OrderSummary.Hold_Re_evaluation__c = FALSE
          AND OrderSummary.IsHistorical__c = FALSE
          AND TypeCode = 'Product'
          AND ProductCode != 'special-order-name'
          AND Status IN :setEligibleStates
          AND OrderSummary.OrderedDate > :refDate
        LIMIT 51
      ];
    }
    Set<Id> orderDelGrpids = new Set<Id>();

    for (OrderItemSummary ois : lsOrderItemSummary) {
      orderDelGrpids.add(
        ois.OrderDeliveryGroupSummary.OriginalOrderDeliveryGroupId
      );
    }

    List<OrderDeliveryGroup> updateorderdelgrp = [
      SELECT Id, Execute_Re_evaluate__c
      FROM OrderDeliveryGroup
      WHERE Id IN :orderDelGrpids
    ];

    for (OrderDeliveryGroup ordelg : updateorderdelgrp) {
      ordelg.Execute_Re_evaluate__c = true;
    }
    if (updateorderdelgrp.size() > 0) {
      if (updateorderdelgrp.size() <= 1) {
        System.enqueueJob(
          new WM_ReevalQueueableFlow(
            0,
            updateorderdelgrp.size(),
            updateorderdelgrp
          )
        );
      } else {
        System.enqueueJob(new WM_ReevalQueueableFlow(0, 1, updateorderdelgrp));
      }
    }

    // update updateorderdelgrp;
  }
}