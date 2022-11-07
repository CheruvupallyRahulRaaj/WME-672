/**
 @description       :  Abstract class for all transaction service classes, contains common methods for all service classes Every service class should extend the AbstractTransactionService
 * @author            : nendyala@liveareacx.com
 * Modifications Log 
 * Ver   Date         Author                    Modification 
 */ 
public abstract class WM_AbstractTransactionService implements Database.AllowsCallouts {
  protected final commercepayments.SalesforceResultCode SUCCESS_SALESFORCE_RESULT_CODE = 
       commercepayments.SalesforceResultCode.SUCCESS;
  protected final commercepayments.SalesforceResultCode DECLINE_SALESFORCE_RESULT_CODE = 
       commercepayments.SalesforceResultCode.DECLINE;
  
  protected commercepayments.paymentGatewayContext gatewayContext;

  public WM_AbstractTransactionService(commercepayments.paymentGatewayContext gatewayContext) {
    this.gatewayContext = gatewayContext;
  }
  
  public abstract HttpRequest buildRequest();
  
  public abstract commercepayments.GatewayResponse buildResponse(HttpResponse response);
  
  public commercepayments.GatewayResponse execute() {
    HttpRequest req;
    try {
      System.debug('Log Start');
      req = buildRequest();
    } catch(Exception e) {
      return new commercepayments.GatewayErrorResponse('700', e.getMessage()+'-- Line number:'+e.getLineNumber());
    }
   commercepayments.PaymentsHttp http = new commercepayments.PaymentsHttp();
      //Http  http = new Http();
    HttpResponse res = null;
    try {
      system.debug('vdebug:req:'+req);
      res = http.send(req);
      system.debug('vdebug:res:'+res);
    } catch(CalloutException ce) {
      system.debug('vdebugce::'+ce.getMessage());
      return new commercepayments.GatewayErrorResponse('500', ce.getMessage());
    }
    try {
      return buildResponse(res);
       
    }       
     catch(Exception e) {
      return new commercepayments.GatewayErrorResponse('400',
        'Something went wrong in the Gateway Adapter : ' + e.getMessage());
    }
  }
  
  protected commercepayments.SalesforceResultCodeInfo getSalesforceResultCodeInfo(String resultCode) {
    if (resultCode == SUCCESS_SALESFORCE_RESULT_CODE.name()) {
      return new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Success);
    } else {
      return new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Decline);
    }
  }
}