public without sharing class OrderHelper {

    /**
     * @name AfterUpdate
     * @description 
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
    **/
    public static void AfterUpdate(List<Order> newList, List<Order> oldList){
        Set<Id> orderIds = new Set<Id>();
        for ( Integer i=0; i<newList.size(); i++ ){
            if ( (newList[i].Status != null && oldList[i].Status != null) && 
                newList[i].Status == Constants.ACTIVATED_ORDER_STATUS && oldList[i].Status != Constants.ACTIVATED_ORDER_STATUS ){
                orderIds.add(newList[i].Id);
            }
        }
        
        RollUpOrderItems(orderIds);
    }
    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
		Map<Id,Product2> prodMap = new Map<Id,Product2>();
        Set<Id> prodIdSet = new Set<Id>();
		for ( OrderItem oi : [SELECT Id, Product2Id FROM OrderItem WHERE OrderId IN :activatedOrderIds])
        {
        	prodIdSet.add(oi.Product2Id);
        }
        if(prodIdSet.size() > 0){
            prodMap = new Map<Id,Product2>([SELECT Id, Quantity_Ordered__c FROM Product2 WHERE Id IN :prodIdSet]);
            AggregateResult[] results = [SELECT Product2Id, SUM(Quantity) totalQuantity FROM OrderItem WHERE OrderId IN :activatedOrderIds AND Product2Id IN :prodMap.keySet() GROUP BY Product2Id];
            for(AggregateResult res : results){
                prodMap.get((String)res.get('Product2Id')).Quantity_Ordered__c = Integer.valueOf(res.get('totalQuantity'));
            }
        }
        if(prodMap.size() > 0){
            update prodMap.values();
        }
    }
}