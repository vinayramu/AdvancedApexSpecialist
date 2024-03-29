public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}

    public Product2Extension(ApexPages.StandardController controller){
        productsToInsert = new List<ProductWrapper>();
        AddRows();
    }

    public void AddRows(){
        for ( Integer i=0; i<Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add( new ProductWrapper());
        }
    }
    
    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }

    public PageReference Save(){
        SavePoint sp1 = Database.setSavepoint();
        try {
                Integer index = 0;
                Map<Integer, Product2> products = new Map<Integer, Product2>();
                Map<Integer, PriceBookEntry> priceBookEntries = new Map<Integer, PriceBookEntry>();    
                
                for(ProductWrapper prdWrapper : productsToInsert) {
                    if(String.isNotBlank(prdWrapper.productRecord.Name) && prdWrapper.pricebookEntryRecord.UnitPrice!=null && 
                       prdWrapper.productRecord.Initial_Inventory__c!=null && prdWrapper.productRecord.isActive && 
                       prdWrapper.productRecord.Initial_Inventory__c != 0 && prdWrapper.pricebookEntryRecord.UnitPrice!=0){
                              
                        products.put(index,prdWrapper.productRecord);
                        priceBookEntries.put(index,prdWrapper.pricebookEntryRecord);
                        index ++;
                    }
                }
                
                insert products.values();
            
                List<PriceBookEntry> pbList = new List<PriceBookEntry>();
                for(Integer mapIndex : products.keySet()) {
                    PriceBookEntry priceEntry = priceBookEntries.get(mapIndex);
                    if(products.get(mapIndex).Id!=null) {
                        priceEntry.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
                        priceEntry.Product2Id = products.get(mapIndex).Id;
                        priceEntry.IsActive = true;
                        pbList.add(priceEntry);
                    }       
                }
                
                insert pbList;
    
                //If successful clear the list and display an informational message
                apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,pbList.size()+' Inserted'));
                productsToInsert.clear();   //Do not remove
                addRows();  //Do not remove
        } catch (Exception e){
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,Constants.ERROR_MESSAGE));
            Database.rollback(sp1);
        }
        return null;
    }
    
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.SELECT_ONE,Constants.SELECT_ONE));
        for(Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY){
            options.add(new SelectOption(entry.getLabel(),entry.getValue()));
        }
        return options;
    }
    
    
    public class ProductWrapper{
        public Product2 productRecord {get;set;}
        public PriceBookEntry pricebookEntryRecord {get;set;}
        
        public ProductWrapper() {
            productRecord = new Product2(Initial_Inventory__c =0, Name='Test Product', isActive=true); 
            pricebookEntryRecord = new PricebookEntry(Unitprice=0.0);
        }
    }
}