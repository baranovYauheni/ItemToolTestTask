@isTest
public class PurchaseLineTriggerHandlerTest {
    @isTest
    static void testUpdatePurchaseTotals() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Purchase__c purchase = new Purchase__c(ClientId__c = testAccount.Id);
        insert purchase;

        Item__c item1 = new Item__c(Name = 'Item 1', Price__c = 100);
        Item__c item2 = new Item__c(Name = 'Item 2', Price__c = 200);
        insert new List<Item__c>{ item1, item2 };

        PurchaseLine__c line1 = new PurchaseLine__c(PurchaseId__c = purchase.Id, ItemId__c = item1.Id, UnitCost__c = 100, Amount__c = 100);
        PurchaseLine__c line2 = new PurchaseLine__c(PurchaseId__c = purchase.Id, ItemId__c = item2.Id, UnitCost__c = 200, Amount__c = 200);
        insert new List<PurchaseLine__c>{ line1, line2 };

        Purchase__c updatedPurchase = [SELECT TotalItems__c, GrandTotal__c FROM Purchase__c WHERE Id = :purchase.Id];
        System.assertEquals(2, updatedPurchase.TotalItems__c);
        System.assertEquals(300, updatedPurchase.GrandTotal__c);
    }
}