public without sharing class ChartHelper {
	@AuraEnabled
    public static List<chartData> GetInventory(){
        List<chartData> cht = new List<chartData>();
        //ToDo: Perform a calculation that aggregates active Products that have a positive Quantity_Remaining__c
        for(AggregateResult res : [SELECT Family, SUM(Quantity_Remaining__c) remainingQty FROM Product2 WHERE Quantity_Remaining__c > 0 AND isActive = true GROUP BY Family])
        {
            chartData cd = new chartData(String.valueOf(res.get('Family')),Integer.valueOf(res.get('remainingQty')));
            cht.add(cd);
        }
        //  And return a list of chartData
        //  Where the name is the Product Family and the Qty is the sum of the Quantity_Remaining__c
        return cht;
    }

    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val){
            this.name = name;
            this.val = val;
        }
    }

}