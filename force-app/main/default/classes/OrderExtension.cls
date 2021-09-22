/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}

    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;

    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
        showFirstOrderItemData();
        showPricebookEntry();
    }

    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection
    public void showPricebookEntry(){
        String q = 'SELECT Id, Name, Pricebook2Id, Product2Id, UnitPrice, Product2.Name, Product2.Quantity_Remaining__c, Product2.Family FROM PricebookEntry WHERE IsActive = true ';
        if(selectedFamily != Constants.SELECT_ONE && selectedFamily != null){
            q += 'AND Product2.Family = \'' + selectedFamily + '\'';
        }
        
        standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(q));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);

        showOrderItemsPage();
    }
    public void showOrderItemsPage(){
        orderItemList = new List<OrderItem>();
        List<sObject> plRecords = standardSetController.getRecords();
        if(standardSetController.getRecords() != null && standardSetController.getRecords().size() > 0){
            for(sObject rec : plRecords){
                PricebookEntry entry = (PricebookEntry)rec;
                
                if(orderItemMap.containsKey(entry.Product2Id)){
                    orderItemList.add(orderItemMap.get(entry.Product2Id));
                }
                else{
                    OrderItem oi = new OrderItem(
                    	Quantity = 0,
                        PricebookEntryId = entry.Id,
                        Product2Id = entry.Product2Id,
                        UnitPrice = entry.UnitPrice,
                        Product2 = entry.Product2
                    );
                    orderItemList.add(oi);
                    orderItemMap.put(entry.Product2Id, oi);
                }
            }
        }
    }
	
    public void showFirstOrderItemData(){
        for(OrderItem oi : orderRecord.OrderItems){
            orderItemMap.put(oi.Product2Id, oi);
        }
        showChart();
    }
    
    public void showChart(){
        this.total = 0.0;
        pieData = new List<ChartHelper.ChartData>();
        for(OrderItem oi : orderItemMap.values()){
            ChartHelper.ChartData ch = new ChartHelper.ChartData(oi.Product2.Name, (oi.UnitPrice*oi.Quantity));
            pieData.add(ch);
            total = total + oi.UnitPrice*oi.Quantity;
        }
    }
    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange(){
        //ToDo: Implement logic to store the values changed on the page
        //      and populate pieData
        //      and populate total
        for(OrderItem oi : orderItemList){
            orderItemMap.put(oi.Product2Id, oi);
        }
        showChart();
    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily(){
        //ToDo: Implement logic to filter based on the selected product family
    	showPricebookEntry();
    }

    /**
     * @name Save
     * @description
    **/
    public void Save(){
        //ToDo: Implement logic to save the Order and populated OrderItems
		System.Savepoint sp1 = Database.setSavepoint();
        try{
            if(orderRecord.Pricebook2Id == null){
                orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }
            upsert orderRecord;
            
            List<OrderItem> addOIList = new List<OrderItem>();
            List<OrderItem> delOIList = new List<OrderItem>();
            
            for(OrderItem oi : orderItemMap.values()){
                if(oi.Quantity > 0){
                    if(oi.OrderId == null)
                    	oi.OrderId = orderRecord.Id;
                    addOIList.add(oi);
                }
                else if(oi.Id != null){
                    delOIList.add(new OrderItem(Id=oi.Id));
                    oi.Id = null;
                }
                
            }
            upsert addOIList;
            delete delOIList;
        }
        catch(Exception e){
            Database.rollback(sp1);
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, Constants.ERROR_MESSAGE));
        }
    }


    /**
     * @name First
     * @description
    **/
    public void First(){
		standardSetController.first();
        showOrderItemsPage();
    }


    /**
     * @name Next
     * @description
    **/
    public void Next(){
		standardSetController.next();
        showOrderItemsPage();
    }


    /**
     * @name Previous
     * @description
    **/
    public void Previous(){
		standardSetController.previous();
        showOrderItemsPage();
    }

    /**
     * @name Last
     * @description
    **/
    public void Last(){
		standardSetController.last();
        showOrderItemsPage();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages(){
        return (Integer)math.ceil(standardSetController.getResultSize()/(Decimal)Constants.DEFAULT_ROWS);
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.SELECT_ONE,Constants.SELECT_ONE));
        for(Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY){
            options.add(new SelectOption(entry.getLabel(),entry.getValue()));
        }
        return options;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}