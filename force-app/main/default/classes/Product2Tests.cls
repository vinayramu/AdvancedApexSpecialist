@isTest
private class Product2Tests {
    static testMethod void Product2Extension_UnitTest(){
        List<Product2> prods = TestDataFactory.ConstructProducts(Constants.DEFAULT_ROWS);
        List<PriceBookEntry> prices = TestDataFactory.ConstructPricebookEntries(prods);
        PageReference pageRef = page.product2New;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        Product2Extension ext = new Product2Extension(new ApexPages.StandardController(prods[0]));
        System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());
        ext.addRows();
        System.assertEquals(2*Constants.DEFAULT_ROWS, ext.productsToInsert.size());
        List<SelectOption> options = ext.GetFamilyOptions();
        System.assertEquals(Constants.DEFAULT_ROWS, options.size());
        
        for(Integer i = 0; i< Constants.DEFAULT_ROWS; i++){
            ext.productsToInsert[i].productRecord = prods[i];
            ext.productsToInsert[i].pricebookEntryRecord = prices[i];
            ext.addRows();
        	ext.save();
            List<ChartHelper.ChartData> chartList = ext.GetInventory();
        }      
        Test.stopTest();
        Integer szProd = [SELECT COUNT() FROM Product2];
        Integer szPrice = [SELECT COUNT() FROM PriceBookEntry];
        System.assertEquals(Constants.DEFAULT_ROWS, szProd);
        System.assertEquals(Constants.DEFAULT_ROWS, szPrice);
    }

    static testMethod void Product2Trigger_UnitTest(){
        List<Product2> prodList = TestDataFactory.ConstructProducts(Constants.DEFAULT_ROWS);
        List<String> prodNames = new List<String>();
        Test.startTest();
        for(Product2 p : prodList){
            p.Quantity_Ordered__c =  Constants.DEFAULT_ROWS;
            prodNames.add(p.Name);
        }
        insert prodList;
        Test.stopTest();
        List<Product2> newProdList = [SELECT Id,Quantity_Remaining__c FROM Product2 WHERE Quantity_Remaining__c = 5];
        system.assertEquals( Constants.DEFAULT_ROWS, newProdList.size());
    }
}