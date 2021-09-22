/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/

public class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
        /*List<CollaborationGroup> cgList = [SELECT Id, Name FROM CollaborationGroup WHERE Name =: 'TEST'+ Constants.INVENTORY_ANNOUNCEMENTS];
        if(cgList.size() > 0){
            return cgList[0];
        }*/
        CollaborationGroup cg = new CollaborationGroup(Name = 'TEST'+ Constants.INVENTORY_ANNOUNCEMENTS,Description='Created from Test Data Factory',CollaborationType='Public');
        return cg;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
    	List<Product2> prodList = new List<Product2>();
        for(Integer i = 0; i < cnt; i++){
            Product2 prod = new Product2(Name='Test ' + i, Initial_Inventory__c = 10, IsActive = true, Family = Constants.PRODUCT_FAMILY[math.mod(i,4)].getValue());
            prodList.add(prod);
        }
        return prodList;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
    	List<PricebookEntry> priceList =  new List<PricebookEntry>();
        for(Product2 prod : prods){
            Decimal prodPrice = 1.0;
            switch on prod.Family {
                when 'Entree' {prodPrice = 25.0;} 
                when 'Side' {prodPrice = 6.0;}
                when 'Dessert' {prodPrice = 5.0;}
                when else {prodPrice = 3.0;}
            }
            PricebookEntry price = new PricebookEntry(Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID, Product2Id = prod.Id, IsActive = true, UnitPrice = prodPrice);
            priceList.add(price);
        }
        return priceList;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
    	List<Account> accList = new List<Account>();
        for(Integer i = 0; i < cnt; i++){
            Account acc = new Account(Name='TEST ' + i);
            accList.add(acc);
        }
        return accList;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
    	List<Contact> conList = new List<Contact>();
        Integer i = 0;
        for(Account acc : accts){
            Contact con = new Contact(FirstName=acc.Name,LastName='ViRa ' + math.mod(i,cnt), AccountId = acc.Id);
            conList.add(con);
            i++;
        }
        return conList;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Order> ordList = new List<Order>();
        Integer i = 0;
        for(Account acc : accts){
            Order od = new Order(AccountId = acc.Id, Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID, EffectiveDate = System.today(), Status = Constants.DRAFT_ORDER_STATUS, Name = 'ViRa ' + math.mod(i, cnt));
            ordList.add(od);
            i++;
        }
        return ordList;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
    	List<OrderItem> oiList = new List<OrderItem>();
        Integer i = 0;
        for(Order od : ords){
            OrderItem oi = new OrderItem(OrderId = od.Id, PricebookEntryId = pbes[i].Id, Quantity = Constants.DEFAULT_ROWS, Product2Id = pbes[i].Product2Id, UnitPrice = pbes[i].UnitPrice);    
            oiList.add(oi);
            i++;
        }
        return oiList;
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
		CollaborationGroup cg = TestDataFactory.ConstructCollaborationGroup();
        insert cg;
        
 		List<Product2> prodList = TestDataFactory.ConstructProducts(cnt);
        insert prodList;
        
        List<PricebookEntry> priceListEntries = TestDataFactory.ConstructPricebookEntries(prodList);
        insert priceListEntries;
        
 		List<Account> accList = TestDataFactory.ConstructAccounts(cnt);
        insert accList;
        
        List<Contact> conList = TestDataFactory.ConstructContacts(cnt, accList);
        insert conList;
        
        List<Order> ordList = TestDataFactory.ConstructOrders(cnt, accList);
        insert ordList;
        
        List<OrderItem> oiList = TestDataFactory.ConstructOrderItems(cnt, priceListEntries, ordList);
        insert oiList;
    }
    
    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered){
        System.assertEquals(originalProduct.Quantity_Ordered__c+qtyOrdered, updatedProduct.Quantity_Ordered__c);
    }
}