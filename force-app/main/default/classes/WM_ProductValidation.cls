public with sharing class WM_ProductValidation {
    
    
    public static String isProductExist(String strProductIds, String srecordId){
        String ordrItemId = [SELECT Id, OriginalOrderItemId FROM OrderItemSummary where  id=:srecordId limit 1].OriginalOrderItemId;
        SCCFileLogger logger = SCCFileLogger.getInstance();
        String isExists = 'false';
        
        // Authorize Access and Token
        String accessToken = '';
        if(!Test.isRunningTest()) {
            accessToken = SCCCommerceCloudConnect.connectToCommerceCloud2ProfileOperations();   
        } else {
            accessToken = 'TestAccessToken';
        }
        String siteid         = getsiteId();
        String ClientSecret   = getsiteSecret();
        String ClientId       = getClientId();
        System.debug('=====res.getStatusCode accessToken()====' + accessToken);
        System.debug('=====Get Side Id =======================' + siteid);
        System.debug('=====Get Secret  =======================' + ClientSecret);
        System.debug('=====Get Client Id  ====================' + ClientId);
        System.debug('=====Get Product Code  =================' + strProductIds);
        
        //Validate Product exists in Commerce Cloud
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
        req.setMethod('GET'); 
        req.setEndpoint('callout:SFCCUserCreds/s/' + siteid + '/dw/shop/v21_2/products/' + strProductIds + '?client_id=' + ClientId);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('x-dw-client-id', +ClientId );
        res = http.send(req);
        System.debug('=====res.getStatusCode()====' + res.getStatusCode());
        System.debug('=====res.getBody()====' + res.getBody());
        
        Map<string, Object> jsonMap = (Map<string, Object>)JSON.deserializeUntyped(res.getBody());
        System.debug('##%%%%jsonMap='+jsonMap);
        
        // Get Id from Commerce Cloud populated Json Map
        if(jsonMap.containsKey('id')) {
            String strId = String.valueOf(jsonMap.get('id'));
            Boolean bdropship;
            Boolean bwestAdvantageProduct;
            Boolean bphysicalGiftCard;
            If (String.valueOf(jsonMap.get('c_dropship')) == 'true' ) {
                bdropship = true;
            } else {
                bdropship = false;
            }  
            If (String.valueOf(jsonMap.get('c_westAdvantageProduct')) == 'true' ) {
                bwestAdvantageProduct = true;
            } else {
                bwestAdvantageProduct = false;
            } 
            If (String.valueOf(jsonMap.get('c_giftCardProduct')) == 'true' ) {
                bphysicalGiftCard = true;
            } else {
                bphysicalGiftCard = false;
            } 
            
            if(strId == strProductIds) {
                System.debug('=====res.getBody()====' + res.getBody());
                isExists = 'true';
                try {   
                    
                       /* Product2 oiToBeUpdate = new Product2(
                        Id = srecordId, 
                        Productcode = strId,
                        StockKeepingUnit = strId,
                        Description = String.valueOf(jsonMap.get('name')),
                        Name = String.valueOf(jsonMap.get('name')),
                        weight__c = String.valueOf(jsonMap.get('c_weight')),
                        vendorNumber__c = String.valueOf(jsonMap.get('c_vendorNumber')),
                        dropship__c = bdropship,
                        westAdvantageProduct__c = bwestAdvantageProduct,
                        physicalGiftCard__c = bphysicalGiftCard
                    );*/
                    OrderItemSummary oiToBeUpdate = new OrderItemSummary(
                    Id = srecordId,
                         // no field of ProductCode,StockKeepingUnit,Name  on OrderIten  
                    Special_Order_SKU__c  = strId,
                    //longDescription__c = String.valueOf(jsonMap.get('name')),
                    //Name = String.valueOf(jsonMap.get('name')),
                    weight__c = String.valueOf(jsonMap.get('c_weight')),
                    vendorNumber__c = String.valueOf(jsonMap.get('c_vendorNumber')),
                     dropship__c = bdropship,   
                    westAdvantageProduct__c = bwestAdvantageProduct,
                    physicalGiftCard__c = bphysicalGiftCard
                    );
                        OrderItem oiToBeUpdate2 = new OrderItem(
                    Id = ordrItemId,
                         // no field of ProductCode,StockKeepingUnit,Name  on OrderIten  
                    Special_Order_SKU__c  = strId,
                    longDescription__c = String.valueOf(jsonMap.get('name')),
                    //Name = String.valueOf(jsonMap.get('name')),
                    weight__c = String.valueOf(jsonMap.get('c_weight')),
                    vendorNumber__c = String.valueOf(jsonMap.get('c_vendorNumber')),
                     dropship__c = bdropship,   
                    westAdvantageProduct__c = bwestAdvantageProduct,
                    physicalGiftCard__c = bphysicalGiftCard
                    );
                    //update oiToBeUpdate2;
                    update oiToBeUpdate;
                    System.debug('=====oiToBeUpdate====' + oiToBeUpdate);
                } catch(Exception e) {
                    logger.error('WM_ProductValidationFlow.OrderItem', 'Exception message : '
                                 + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
                    system.debug('WM_ProductValidationFlow.OrderItem Exception message : '+ e.getMessage() + ' StackTrack '+ e.getStackTraceString());
                    isExists = 'truenottrue';
                    system.debug('*******Order Item Update failed***************' + isExists);
                }
            }
        }
        System.debug('=====isExists====' + isExists);
        return isExists;
        
        
        
    }  
    public static String getsiteId() {
        String query = SCCQueryUtilClass.getInstance()
            .getQueryInstance()
            .setObjectName('SFCCConfiguration__c')
            .setRelatedFields(new Set<String>{'Id', 'Name', 'Site_Id__c'})
            .setLimit('1')
            .getQuery();
        List<SFCCConfiguration__c> objList = (List<SFCCConfiguration__c>)SCCQueryUtilClass.getRecords(query);
        if(objList.size()>0){
            String siteId =  objList[0].Site_Id__c;
            return siteId; 
        }
        else {
            return null;
        }
        
    }
    
    public static String getsiteSecret() {
        String query = SCCQueryUtilClass.getInstance()
            .getQueryInstance()
            .setObjectName('SFCC_Integration_Creds__c')
            .setRelatedFields(new Set<String>{'Id', 'Name', 'Client_Id__c', 'Client_Secret__c'})
            .setLimit('1')
            .getQuery();
        List<SFCC_Integration_Creds__c> objList = (List<SFCC_Integration_Creds__c>)SCCQueryUtilClass.getRecords(query);
        if(objList.size()>0){
            String ClientSecret =  objList[0].Client_Secret__c; 
            return ClientSecret; }
        else {
            return null;
        }
        
    }
    public static String getClientId() {
        String query = SCCQueryUtilClass.getInstance()
            .getQueryInstance()
            .setObjectName('SFCC_Integration_Creds__c')
            .setRelatedFields(new Set<String>{'Id', 'Name', 'Client_Id__c'})
            .setLimit('1')
            .getQuery();
        List<SFCC_Integration_Creds__c> objList = (List<SFCC_Integration_Creds__c>)SCCQueryUtilClass.getRecords(query);
        if(objList.size()>0){
            String ClientId = objList[0].Client_Id__c;
            return ClientId; }
        else{
            return null;
        }
    }
}