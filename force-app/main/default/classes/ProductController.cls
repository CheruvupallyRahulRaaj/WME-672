@isTest
public with sharing class ProductController {
   /* public ProductController() {

    }
    @AuraEnabled(cacheable=true)
    public static List<PriceBookEntry> getProductList() {
        return [
            SELECT Id, UnitPrice, Product2.Id, Product2.Name, Product2.ProductCode
            FROM PriceBookEntry
            WHERE Product2.IsActive = true
            ORDER BY Product2.CreatedDate DESC
            LIMIT 50
        ];
    }*/
}