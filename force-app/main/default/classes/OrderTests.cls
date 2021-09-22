@isTest
private class OrderTests {
	@testSetup
    static void SetupTestData(){
        TestDataFactory.InsertTestData(Constants.DEFAULT_ROWS);
    }
    static testMethod void OrderUpdate_UnitTest(){
        List<Product2> originalProducts = [SELECT Id, Quantity_Ordered__c FROM Product2];
        List<Order> orderList = [SELECT Id, Status FROM Order];
        for(Order od : orderList){
            od.Status = Constants.ACTIVATED_ORDER_STATUS;
        }
        update orderList;
        List<Product2> updatedProducts = [SELECT Id, Quantity_Ordered__c FROM Product2];
        for(Integer i = 0; i < Constants.DEFAULT_ROWS; i++){
        	TestDataFactory.VerifyQuantityOrdered(originalProducts[i], updatedProducts[i], Constants.DEFAULT_ROWS);
        }
    }

	static testMethod void OrderExtension_UnitTest(){
        Map<Id,Order> ordMap = new Map<Id,Order>([SELECT Id, AccountId, TotalAmount, Status, (SELECT Id, Product2Id, UnitPrice, Quantity, Product2.Family FROM OrderItems) FROM Order WHERE Status =: Constants.DRAFT_ORDER_STATUS]);
        PageReference pg = Page.OrderEdit;
        Test.setCurrentPage(pg);
        Integer optSize = 0;
        for(ID orderId : ordMap.keySet()){
            Order od = ordMap.get(orderId);
            List<OrderItem> oiList = od.OrderItems;
            ApexPages.StandardController sc = new ApexPages.StandardController(od);
            OrderExtension oe = new OrderExtension(sc);
            System.assertEquals(Constants.DEFAULT_ROWS, oe.orderItemList.size());
            oe.selectedFamily = oiList[0].Product2.Family;
            List<SelectOption> optList = oe.GetFamilyOptions();
			optSize = optList.size();
            oe.SelectFamily();
            oe.OnFieldChange();
            oe.First();
            if(oe.GetHasNext()){
                oe.Next();
            }
            if(oe.GetHasPrevious()){
                oe.Previous();
            }
            oe.Last();
            oe.GetPageNumber();
            oe.GetTotalPages();
            oe.Save();
        }
        System.assertEquals(Constants.DEFAULT_ROWS, optSize);
    }
}