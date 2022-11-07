/**
* @description       : 
* @author            : schauhan@liveareacx.com
* @group             : 
* @last modified on  : 01-12-2021
* @last modified by  : schauhan@liveareacx.com
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   01-08-2021   schauhan@liveareacx.com   Initial Version
**/
public class WM_TransactionHelper{
    public static PaymentAuthorization getAuthObjectForCapture(String authorizationId, Boolean IS_MULTICURRENCY_ORG) {
        List < String > listOfFields = new List < String > {
            'GatewayAuthCode',
                'GatewayRefNumber',
                'GatewayRefDetails',
                'PaymentGatewayId',
                'Amount',
                'PaymentMethodId',
                'OrderPaymentSummaryId',
                'AccountId',
                'Id'
                };
                    if (IS_MULTICURRENCY_ORG) {
                        listOfFields.add('CurrencyIsoCode');
                    }
        PaymentAuthorization authObject = (PaymentAuthorization) WM_DaoService.getSobjectById(authorizationId, listOfFields, PaymentAuthorization.SObjectType);
        if(authObject!=null){
            return authObject;
        }
        else{
            return null;
        }
        
    }
    
    public static Payment getPaymentObjectForRefund(String paymentId, Boolean IS_MULTICURRENCY_ORG){
        List<String> listOfFields = new List<String>();
        listOfFields.add('GatewayRefNumber');
        listOfFields.add('GatewayRefDetails');
        listOfFields.add('PaymentMethodId');
        listOfFields.add('PaymentAuthorizationId');
        listOfFields.add('OrderPaymentSummaryId');
        listOfFields.add('AccountId');
        if (IS_MULTICURRENCY_ORG) {
            // currency of payment required if org is multi currency
            listOfFields.add('CurrencyIsoCode');
        }
        //Fetch the payment record using the Payment Id
        Payment paymentObject = (Payment) WM_DaoService.getSobjectById(paymentId, listOfFields, Payment.SObjectType);
        if(paymentObject!=null){
            return paymentObject;
        }
        else{
            return null;
        }
    }

    public static DigitalWallet getDigitalWalletPaymentMethod(String paymentMethodId) {
        List < String > listOfFields = new List < String > {
            'Id',
            'DigitalWalletNumber',
            'PaymentMethodStreet',
            'CompanyName',
            'GatewayToken',
            'PaymentGatewayId',
            'PaymentMethodCity',
            'PaymentMethodpostalcode',
            'NickName',
            'Type',
            'PaymentMethodState',
            'Phone',
            'Email',
            'PaymentMethodCountry',
            'aurusPayAPTID__c',
            'aurusPayAPTN__c',
            'aurusPayOOT__c'
        };
        DigitalWallet dwMethod = (DigitalWallet) WM_DaoService.getSobjectById(paymentMethodId, listOfFields, DigitalWallet.SObjectType);
        if(dwMethod !=null){
            return dwMethod;
        }
        else{
            return null;
        }
    }

    public static CardPaymentMethod getCardPaymentMethodWithAccountId(String accountId){
        List < String > listOfFields = new List < String > {
            'Id',
                'CardPaymentMethodNumber',
                'ExpiryMonth',
                'ExpiryYear',
                'PaymentMethodStreet',
                'CardHolderName',
                'GatewayToken',
                'PaymentGatewayId',
                'PaymentMethodCity',
                'PaymentMethodpostalcode',
                'CardHolderFirstName',
                'CardHolderLastName',
                'CardType',
                'PaymentMethodState',
                'Phone',
                'Email',
                'PaymentMethodCountry',
                'InputCardNumber',
                'aurusPayAPTID__c',
                'aurusPayAPTN__c',
                'aurusPayOOT__c',
                'AccountId'
                };
                    List<CardPaymentMethod> cpMethodList = (List<CardPaymentMethod>) WM_DaoService.getSobjectList(accountId, listOfFields, CardPaymentMethod.SObjectType,'AccountId');
        if(cpMethodList.size()>0){
            return cpMethodList[0];
        }
        else{
            return null;
        }      
    }

    public static DigitalWallet getPaypalPaymentMethod(String paymentMethodId) {
        List < String > listOfFields = new List < String > {
            'Id',
            'DigitalWalletNumber',
            'PaymentMethodStreet',
            'CompanyName',
            'GatewayToken',
            'PaymentGatewayId',
            'PaymentMethodCity',
            'PaymentMethodpostalcode',
            'NickName',
            'Type',
            'PaymentMethodState',
            'Phone',
            'Email',
            'PaymentMethodCountry',
            'aurusPayAPTID__c',
            'aurusPayAPTN__c',
            'aurusPayOOT__c'
        };
        DigitalWallet dwMethod = (DigitalWallet) WM_DaoService.getSobjectById(paymentMethodId, listOfFields, DigitalWallet.SObjectType);
        if(dwMethod !=null){
            return dwMethod;
        }
        else{
            return null;
        }
    }
    
    public static CardPaymentMethod getCardPaymentMethod(String cardPaymentMethodId) {
        List < String > listOfFields = new List < String > {
            'Id',
                'CardPaymentMethodNumber',
                'ExpiryMonth',
                'ExpiryYear',
                'PaymentMethodStreet',
                'CardHolderName',
                'GatewayToken',
                'PaymentGatewayId',
                'PaymentMethodCity',
                'PaymentMethodpostalcode',
                'CardHolderFirstName',
                'CardHolderLastName',
                'CardType',
                'PaymentMethodState',
                'Phone',
                'Email',
                'PaymentMethodCountry',
                'InputCardNumber',
                'aurusPayAPTID__c',
                'aurusPayAPTN__c',
                'aurusPayOOT__c',
                'CardCategory'
                };
                    CardPaymentMethod cpMethod = (CardPaymentMethod) WM_DaoService.getSobjectById(cardPaymentMethodId, listOfFields, CardPaymentMethod.SObjectType);
        if(cpMethod!=null){
            return cpMethod;
        }
        else{
            return null;
        }
    }
    
    public static DigitalWallet getDigitalWalletWithAccountId(String accountId){
        List < String > listOfFields = new List < String > {
            'Id',
            'PaymentGatewayId',
            'aurusPayAPTID__c',
            'aurusPayAPTN__c',
            'aurusPayOOT__c',
            'PaymentMethodStreet',
            'PaymentMethodCity',
            'PaymentMethodpostalcode',
            'PaymentMethodCountry',
            'PaymentMethodState',
            'Type',
            'Phone',
            'Email',
            'AccountId',
            'DigitalWalletNumber',
            'CompanyName',
            'GatewayToken',
            'NickName',
            'PaymentMethodState'
        };
        List<DigitalWallet> cpMethodList = (List<DigitalWallet>) WM_DaoService.getSobjectList(accountId, listOfFields, DigitalWallet.SObjectType,'AccountId');
        if(cpMethodList.size()>0){
            return cpMethodList[0];
        }
        else{
            return null;
        }      
    }
    


    public static OrderPaymentSummary getOrderPaymentSummary(String orderPaySumId) {
        List < String > listOfFields = new List < String > {
            'Id',
                'OrderSummaryId',
                'AuthorizationAmount',
                'CapturedAmount'
                };
                    OrderPaymentSummary orderPaySum = (OrderPaymentSummary) WM_DaoService.getSobjectById(orderPaySumId, listOfFields, OrderPaymentSummary.SObjectType);
        if(orderPaySum!=null){
            return orderPaySum;
        }
        else{
            return null;
        }  
    }
    
    public static List<OrderItemSummary> geOrderItemSummary(String orderSumId) {
        List < String > listOfFields = new List < String > {
            'Id',
                'OrderSummaryId',
                'OriginalOrderItemId',
                'OrderDeliveryGroupSummaryId',
                'Description',
                'Name',
                'Status',
                'Quantity',
                'QuantityFulfilled'
                };
                    List<OrderItemSummary> orderItemSumList = (List<OrderItemSummary>) WM_DaoService.getSobjectList(orderSumId, listOfFields, OrderItemSummary.SObjectType,'OrderSummaryId');
        if(orderItemSumList.size()>0){
            return orderItemSumList;
        }
        else{
            return null;
        }  
    }
    
    public static OrderItem getOrderItem(String orderProdId) {
        List < String > listOfFields = new List < String > {
            'Id',
                'Quantity',
                'OrderDeliveryGroupId',
                'Description',
                'UnitPrice',
                'TotalLineTaxAmount',
                'TotalTaxAmount',
                'TotalLineAmount',
                'TotalPrice',
                'OrderItemNumber',
                'TypeCode',
                'Product2Id'
                };
                    OrderItem orderProd = (OrderItem) WM_DaoService.getSobjectById(orderProdId, listOfFields, OrderItem.SObjectType);
        if(orderProd!=null){
            return orderProd;
        }
        else{
            return null;
        }  
    }
    public static OrderDeliveryGroup getOrderDeliveryGroup(String orderDelId) {
        List < String > listOfFields = new List < String > {
            'Id',
                'DeliverToAddress'
                };
                    OrderDeliveryGroup  orderDelGrp = (OrderDeliveryGroup) WM_DaoService.getSobjectById(orderDelId, listOfFields, OrderDeliveryGroup.SObjectType);
        if(orderDelGrp!=null){
            return orderDelGrp;
        }
        else{
            return null;
        }  
    }
    
    public static Product2 getProduct(String prodId) {
        List < String > listOfFields = new List < String > {
            'Id',
                'Name',
                'ProductCode',
                'Description',
                'QuantityUnitOfMeasure'
                };
                    Product2  prod = (Product2) WM_DaoService.getSobjectById(prodId, listOfFields, Product2.SObjectType);
        if(prod!=null){
            return prod;
        }
        else{
            return null;
        }  
    }
    
    public static Account getAccountObject(String accId) {
        List < String > listOfFields = new List < String > {
            'Id',
                'Name',
                'BillingAddress',
                'ShippingAddress'
                };
                    Account  acc = (Account) WM_DaoService.getSobjectById(accId, listOfFields, Account.SObjectType);
        if(acc!=null){
            return acc;
        }
        else{
            return null;
        } 
        
    }
}