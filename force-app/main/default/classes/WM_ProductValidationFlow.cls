public class WM_ProductValidationFlow {
    
    public class ProductInput {
        @InvocableVariable(required=true)
        public String srecordId;
        @InvocableVariable(required=true)
        public String sproductCode;
    }
    
    public class ProductOutput {
        @InvocableVariable(required=true)
        public String strproductCheck;
        @InvocableVariable
        public boolean isSuccessful;
    }
    
    @InvocableMethod(label = 'Validate Special Product Product') 
    public static List<ProductOutput> getProductValidation(List<ProductInput> ProductInputs) {
        
        SCCFileLogger logger = SCCFileLogger.getInstance();
        List<ProductOutput> ProductOutputs = new List<ProductOutput>();
        ProductOutput ProductOutput = new ProductOutput(); 
        ProductOutput.isSuccessful = false;
        String isExists = 'false';
        // Get the email from the input
        for (ProductInput ProductInput : ProductInputs) {
            
            if(ProductInput.sproductCode != null ){
                
                isExists = WM_ProductValidation.isProductExist(ProductInput.sproductCode, ProductInput.srecordId);
                
                system.debug('*******Product Code Input***************' + ProductInput.sproductCode);
                system.debug('*******Record id Input***************' + ProductInput.srecordId);
                system.debug('*******Boolean Return Value***************' + isExists);
                
                if(isExists == 'true') {
                    //
                    // Call function to Update OrderItem with new Product Code by recordId 
                    //                  
                    system.debug('*******Returned Product True***************' + isExists);
                    
                    ProductOutput.strproductCheck = 'Product Code was validated in Commerce Cloud and successfully updated in OMS-Order Product.';
                    ProductOutput.isSuccessful = true;
                    ProductOutputs.add(ProductOutput);
                }
                if(isExists == 'truenottrue') { 
                    ProductOutput.strproductCheck = 'Product Code was validated in Commerce Cloud, however was not able to be updated OMS-Order Product. Please notify your Administrator!';
                    ProductOutputs.add(ProductOutput);
                    system.debug('*******True Not True***************' + ProductOutputs); 
                }  
                
                if(isExists == 'false') { 
                    ProductOutput.strproductCheck = 'Product Code was not Found on Commerce Cloud!';
                    ProductOutputs.add(ProductOutput);
                    system.debug('*******Final False Output***************' + ProductOutputs); 
                }   
                
            }else{
                ProductOutput.strproductCheck = 'Product Code was not Found on Commerce Cloud!';
                ProductOutputs.add(ProductOutput);
                system.debug('*******Product Code was blank***************' + ProductOutputs);  
            }  
            
        }        
        system.debug('*******END Return***************' + ProductOutputs);
        return ProductOutputs; 
    }
    
    
}