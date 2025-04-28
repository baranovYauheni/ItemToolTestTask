@isTest
public class PurchaseControllerTest {

    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        List<Item__c> testItems = new List<Item__c>();
        testItems.add(new Item__c(Name = 'Item 1', Price__c = 10.0));
        testItems.add(new Item__c(Name = 'Item 2', Price__c = 20.0));
        insert testItems;
    }

    @isTest
    static void testCreatePurchase_Success() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<Item__c> testItems = [SELECT Id, Price__c FROM Item__c];

        Test.startTest();
        Id purchaseId = PurchaseController.createPurchase(
                new List<Id>{ testItems[0].Id, testItems[1].Id },
                testAccount.Id
        );
        Test.stopTest();

        Purchase__c purchase = [SELECT Id, ClientId__c, TotalItems__c, GrandTotal__c FROM Purchase__c WHERE Id = :purchaseId LIMIT 1];
        System.assertEquals(testAccount.Id, purchase.ClientId__c);
        System.assertEquals(2, purchase.TotalItems__c);
        System.assertEquals(30.0, purchase.GrandTotal__c);

        List<PurchaseLine__c> purchaseLines = [SELECT ItemId__c, UnitCost__c, Amount__c FROM PurchaseLine__c WHERE PurchaseId__c = :purchaseId];
        System.assertEquals(2, purchaseLines.size());
        System.assertEquals(testItems[0].Id, purchaseLines[0].ItemId__c);
        System.assertEquals(10.0, purchaseLines[0].UnitCost__c);
        System.assertEquals(10.0, purchaseLines[0].Amount__c);
    }
}