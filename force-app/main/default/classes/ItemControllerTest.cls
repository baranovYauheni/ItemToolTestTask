@isTest
public class ItemControllerTest {

    @testSetup
    static void setupTestData() {
        List<Item__c> items = new List<Item__c>();
        items.add(new Item__c(Name = 'Item 1', Family__c = '1', Type__c = '1', Description__c = 'Test item 1', Price__c = 100.0));
        items.add(new Item__c(Name = 'Item 2', Family__c = '2', Type__c = '2', Description__c = 'Test item 2', Price__c = 200.0));
        items.add(new Item__c(Name = 'Item 3', Family__c = '3', Type__c = '3', Description__c = 'Test item 3', Price__c = 50.0));
        insert items;
    }

    @isTest
    static void testGetAllItems() {
        Test.startTest();
        List<Item__c> items = ItemController.getAllItems();
        Test.stopTest();

        System.assertEquals(3, items.size(), 'The number of items returned should match the test data.');

        System.assertEquals('Item 1', items[0].Name, 'The first item name should match.');
        System.assertEquals('1', items[0].Family__c, 'The first item family should match.');
        System.assertEquals(100.0, items[0].Price__c, 'The first item price should match.');

        System.assertEquals('Item 2', items[1].Name, 'The second item name should match.');
        System.assertEquals('2', items[1].Family__c, 'The second item family should match.');
        System.assertEquals(200.0, items[1].Price__c, 'The second item price should match.');

        System.assertEquals('Item 3', items[2].Name, 'The third item name should match.');
        System.assertEquals('3', items[2].Family__c, 'The third item family should match.');
        System.assertEquals(50.0, items[2].Price__c, 'The third item price should match.');
    }
}