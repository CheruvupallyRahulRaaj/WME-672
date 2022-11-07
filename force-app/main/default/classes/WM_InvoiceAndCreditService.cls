/**
* @description       : Service Class for Invoice and Credit Memo
* @author            : schauhan@liveareacx.com
* @last modified on  : 02-11-2021
* @last modified by  : schauhan@liveareacx.com
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   02-11-2021   schauhan@liveareacx.com   Initial Version
**/
public class WM_InvoiceAndCreditService {
    /*Method Name : invoiceAndCreditService
*Accepting Parameters :  sObject Ids
*Purpose : Invocable from a flow to execute a call to an external system
*/
   /* @InvocableMethod(label='InvoiceAndCreditService')
     public static void invoiceAndCreditService (List<String> sObjectIds) {
         for(String sobId :sObjectIds){
             invoiceAndCredit(new List<String>{sobId});
         } 

     }
    
    @future(callout=true)
    public static void invoiceAndCredit (List<String> sObjectIds) {
         List<FulfillmentOrder> fulfillmentOrderList = new List<FulfillmentOrder>();
         Map<String,Boolean> mapOfFulFillmentIDWithResult = new Map<String,Boolean>();
        for(String sId :sObjectIds){
        try{
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String apiKey = WM_WebServiceDetails__c.getValues('InvoiceApiKey').WM_ApiKey__c;
       
        request.setMethod('POST'); 
        request.setHeader('Content-Type','application/json');
        request.setHeader('api_key',apiKey); 
          
             Id sObjectId = (Id)sId;
            String sObjName = sObjectId.getSObjectType().getDescribe().getName();
            Invoice invoiceObj = new Invoice();
            CreditMemo creditMemoObj = new CreditMemo();
            Account acc = new Account();
		    Contact con = new Contact();
            OrderSummary ordrSummary = new OrderSummary();
            Order ordr = new Order();
            Schema.Location locatn = new Schema.Location();
            List<PaymentAuthorization> paymentAuthorizationList = new List<PaymentAuthorization>();
            List<OrderPaymentSummary> orderPaymentSummaryList = new List<OrderPaymentSummary>();
            Set<Id> ordPaymntSumIds = new Set<Id>();
            SalesChannel salesChannl = new SalesChannel();
            Address__c addr = new Address__c();
            List<Tax_Exemption__c> TaxExemptnList = new List<Tax_Exemption__c>();
            Set<Id> deliveryMethodIds = new Set<Id>();
            List<OrderDeliveryMethod> orderDeliveryMethodList = new List<OrderDeliveryMethod>();
            OrderDeliveryGroupSummary ordrDelGrpSum = new OrderDeliveryGroupSummary();
            List<OrderDeliveryGroupSummary> ordrDelGrpSumList = new List<OrderDeliveryGroupSummary>();
            List<InvoiceLine> invoiceLineList = new List<InvoiceLine>();
            List<FulfillmentOrder> fullfillmentOrderList = new List<FulfillmentOrder>();
            Set<Id> fullfillmentOrderIds = new Set<Id>();
            List<FulfillmentOrderLineItem> fOrderLineItemList = new List<FulfillmentOrderLineItem>();
            List<CreditMemoLine> creditMemoLineList = new List<CreditMemoLine>();
            WM_InvoiceCreditMemoWrapper wrp = new WM_InvoiceCreditMemoWrapper();
            List<CardPaymentMethod> cpmList = new List<CardPaymentMethod>();
            List<AlternativePaymentMethod> apmList = new List<AlternativePaymentMethod>();
	        List<PaymentAuthorization> payAuthList = new List<PaymentAuthorization>();	
            list<OrderItemSummaryChange> orditmschngList = new list<OrderItemSummaryChange>();
            OrderItemSummary orditemsummary = new OrderItemSummary();
            List<OrderItemSummary> orditemsummaryList = new List<OrderItemSummary>();
            list<Shipment> shipmentList = new list<Shipment>();
            
            if(sObjName=='Invoice'){  
                 request.setEndpoint('callout:InvoiceService');
                invoiceObj = WM_ServiceHelper.getInvoice(sId);
                if(invoiceObj.BillingAccountId!=null){
                    acc = WM_ServiceHelper.getAccount(invoiceObj.BillingAccountId); 
                    //con  = WM_ServiceHelper.getContact(invoiceObj.BillToContactId); 
                   		

                }
                /*if(invoiceObj.BillToContactId!= null){
                    con  = WM_ServiceHelper.getContact(invoiceObj.BillToContactId);    
                        }*/
                
              /*  if(invoiceObj.ReferenceEntityId!=null){
                    ordrSummary = WM_ServiceHelper.getOrderSummary(invoiceObj.ReferenceEntityId); 
                    //con  = WM_ServiceHelper.getContact(ordrSummary.Contact__c); 
                }
                
                
                if(ordrSummary != null){
                    fulfillmentOrderList = WM_ServiceHelper.getFulfillmntOrdrLst(sId);
			        //orditemsummary = WM_ServiceHelper.getOrderItemSummary(ordrSummary.Id+'');
                    orditmschngList = WM_ServiceHelper.getOrderItemSummaryChange(ordrSummary.Id+'');
                    ordrDelGrpSum = WM_ServiceHelper.getOrderDeliveryGrpSum(ordrSummary.Id+'');
                   
                }
                if(ordrSummary.Contact__c!=null){
                    con  = WM_ServiceHelper.getContact(ordrSummary.Contact__c);    
                }
                
                if(fulfillmentOrderList.size() > 0){
                    for(FulfillmentOrder eachOrder: fulfillmentOrderList){
                        fullfillmentOrderIds.add( eachOrder.Id );
                    }
                    fOrderLineItemList = WM_ServiceHelper.getFulfillmentOrderLineItem(fullfillmentOrderIds);
                    shipmentList = WM_ServiceHelper.getshpment(fullfillmentOrderIds);
                }
                system.debug('Location Id'+fulfillmentOrderList[0]);
                if(fulfillmentOrderList[0].FulfilledFromLocationId!=null){
                    locatn = WM_ServiceHelper.getLocation(fulfillmentOrderList[0].FulfilledFromLocationId);
                }
                
                
                invoiceLineList = WM_ServiceHelper.getInvoiceLineList(invoiceObj.Id);
                  wrp = new WM_InvoiceCreditMemoWrapper(invoiceObj.InvoiceName__r.InvoiceCredNum__c,invoiceObj.CreatedDate,invoiceObj.VertexLOM__VertexTaxTotal__c,invoiceObj.TotalAdjustmentAmount,invoiceObj.Status,invoiceObj.Vertex_Total_with_Tax__c,invoiceObj.Id);
            }
            if(sObjName=='CreditMemo'){
                   request.setEndpoint('callout:CreditMemoService');
                creditMemoObj = WM_ServiceHelper.getCreditMemo(sId);
                if(creditMemoObj.BillingAccountId!=null){
                    acc = WM_ServiceHelper.getAccount(creditMemoObj.BillingAccountId);
                }
                if(creditMemoObj.ReferenceEntityId!=null){
                    ordrSummary = WM_ServiceHelper.getOrderSummary(creditMemoObj.ReferenceEntityId);                 
                } 
                
                creditMemoLineList = WM_ServiceHelper.getCreditMemoLineList(sId);
                List<String> ordrItemIds = WM_ServiceHelper.getCreditMemoLineIds(sId);
                if(ordrItemIds.size()>0){
                  orditemsummaryList = WM_ServiceHelper.getOrderItemSummaries(ordrItemIds);  
                }               
                  wrp = new WM_InvoiceCreditMemoWrapper(creditMemoObj.JDAInvoiceCreditNumber__r.InvoiceCredNum__c,creditMemoObj.CreatedDate,creditMemoObj.TotalTaxAmount,null,creditMemoObj.Status,creditMemoObj.TotalAmountWithTax,creditMemoObj.Id);
                
            }
            if(ordrSummary.OriginalOrderId!=null){
                ordr = WM_ServiceHelper.getOrder(ordrSummary.OriginalOrderId); 
                orderPaymentSummaryList = WM_ServiceHelper.getOrderPaymentSummary(ordrSummary.Id);
            }
            if(orderPaymentSummaryList.size()>0){
                List<Id> cPMIds = new List<Id>();
                List<Id> aPMIds = new List<Id>();
                for(OrderPaymentSummary ops :orderPaymentSummaryList){
                    if(ops.Type!='Unknown'){
                        cPMIds.add(ops.paymentmethodid);
                    }
                    else{
                       aPMIds.add(ops.paymentmethodid);
                    }
                      
                    ordPaymntSumIds.add(ops.Id);
                }   
                paymentAuthorizationList = WM_ServiceHelper.getPaymentAuthorization(ordPaymntSumIds);
                if(cPMIds.size()>0){
                    cpmList = WM_ServiceHelper.getCPM(cPMIds);
                }
                if(aPMIds.size()>0){
                    apmList = WM_ServiceHelper.getAPM(aPMIds);
                }
            }
            if(ordr.SalesChannelId!=null){
                salesChannl = WM_ServiceHelper.getSalesChannel(ordr.SalesChannelId);
            }   
            if(acc!=null){
                system.debug('Account Id  '+acc.Id);
               addr =  WM_ServiceHelper.getAddress(acc.Id);
               TaxExemptnList= WM_ServiceHelper.getTaxExemptions(acc.Id);
               
            }
                
                //get OrderDeliveryMethod records
                for(FulfillmentOrder fo: fulfillmentOrderList){
                    if(fo.DeliveryMethodId != null){
                        deliveryMethodIds.add( fo.DeliveryMethodId );
                    }
                }
                if(deliveryMethodIds.size() > 0){
                    orderDeliveryMethodList = WM_ServiceHelper.getOrderDeliveryMethodList(deliveryMethodIds);
                    
                }
               
               /*JSONGenerator gen = WM_CommonServiceForInvoiceandCredit.commonService(acc,con,ordrSummary, wrp,ordr, salesChannl,addr,orderPaymentSummaryList,
                                 orderDeliveryMethodList,invoiceLineList,fulfillmentOrderList, fOrderLineItemList,creditMemoLineList, cpmList,apmList,paymentAuthorizationList,orditmschngList,locatn,
                                 shipmentList,ordrDelGrpSum,TaxExemptnList,orditemsummaryList);*/
            
           /* String payLoad = '';
            system.debug('payload: '+payLoad);
            
            request.setBody(payLoad);
            request.setTimeout(60000);
            System.debug('request : '+ request);
            HttpResponse response = new HttpResponse();
            response = http.send(request);
            system.debug('getStatusCode ' + response.getStatusCode());            
            system.debug('getBody ' + response.getBody());
            if(response.getStatusCode()==200){
                                FeedItem post = new FeedItem();
                if(fulfillmentOrderList.size()>0){
                    mapOfFulFillmentIDWithResult.put(fulfillmentOrderList[0].Id,true);
                 /*post.ParentId = fulfillmentOrderList[0].Id; 
            
                post.Title = 'The request to Invoice Service was successful';
post.Body = 'The request to Invoice Service was successful and returned response as   '+response.getBody();
insert post;*/
              /*  }
            }
            else{
                FeedItem post = new FeedItem();
                if(fulfillmentOrderList.size()>0){
                    mapOfFulFillmentIDWithResult.put(fulfillmentOrderList[0].Id,false);
                /* post.ParentId = fulfillmentOrderList[0].Id; 
            
                post.Title = 'The request to Invoice Service failed with status code as '+response.getStatusCode() +'at '+String.valueOf(system.now());
post.Body = response.getBody();
insert post;*/
            /*    }
           }
            
        }
        catch(Exception e){ 
            system.debug('Exception occured: '+e);
             List<String> line2 = e.getStackTraceString().split('\n');     
       system.debug('Error '+line2);
             FeedItem post = new FeedItem();
             Id sObjectId = (Id)sId;
            String sObjName =  sObjectId.getSObjectType().getDescribe().getName();
            if(sObjName=='Invoice'){
            if(fulfillmentOrderList.size()>0){
                 mapOfFulFillmentIDWithResult.put(fulfillmentOrderList[0].Id,false);
                /* post.ParentId = fulfillmentOrderList[0].Id; 
                 post.Title = 'The invoice service failed at runtime';
                            post.Body = String.valueOf(e) + String.valueOf(line2);
                insert post;*/
          /*  }
            
                           
                           }
            //return new List<Boolean>{false};
        }
            
        }
                List<FeedItem> postList = new list<FeedItem>();
        for(String k :mapOfFulFillmentIDWithResult.keyset()){
            if(mapOfFulFillmentIDWithResult.get(k)){
                FeedItem post = new FeedItem();                    
                    post.ParentId = k;     
                    post.Title = 'The request to Invoice Service was successful';
                    post.Body = 'The request to Invoice Service was successful';
                postList.add(post);
            }
            else{
                 FeedItem post = new FeedItem();                    
                    post.ParentId = k;     
                    post.Title = 'The request to Invoice Service failed';
                    post.Body = 'The request to Invoice Service failed';
                postList.add(post);
            }
        }
        if(postList.size()>0){
         insert postList;   
        }
        
        
        }
        
        */
    
}