public class ObjectWrapperForPickOut {
	Public FulfillmentOrder fulfillmentOrder = new FulfillmentOrder();
    Public Map<Id,OrderSummary> mapOfFOWithOrderSummary = new Map<Id,OrderSummary>();
    Public Map<Id,Account> mapOfFOWithAccount = new Map<Id,Account>();
    Public Map<Id,OrderItem> orderItemMap = new Map<Id,OrderItem>();
    Public Map<Id,OrderItemSummary> mapOfFOWithOrderItemSummary = new Map<Id,OrderItemSummary>();
    Public Map<Id,PaymentAuthorization> mapOfOPMWithPaymentAuthorization = new Map<Id,PaymentAuthorization>();
    Public Map<Id,Account> parentAccountMap = new Map<Id,Account>();
}