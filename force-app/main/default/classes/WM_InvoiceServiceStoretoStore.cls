public class WM_InvoiceServiceStoretoStore {

      @InvocableMethod(label='InvoiceService')
     public static void callInvoiceService (List<String> fulfillmentOrderIds) {
         syncInvoiceService(fulfillmentOrderIds);
     }
    
    public static void syncInvoiceService (List<String> ordrFulfillmntIds) {
        System.enqueueJob(new WM_InvoiceServiceStoSQueueable(ordrFulfillmntIds));
    }
    
}