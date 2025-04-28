@isTest
public class UnsplashAPITest {

    private static Item__c createTestItem() {
        Item__c testItem = new Item__c();
        testItem.Name = 'Test Item';
        insert testItem;
        return testItem;
    }

    @isTest
    static void testUpdateItemImageSuccess() {
        Item__c testItem = createTestItem();

        String mockResponse = '{ "results": [ { "urls": { "regular": "https://example.com/test-image.jpg" } } ] }';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse, 200));

        Test.startTest();
        UnsplashAPI.updateItemImage(testItem.Id, 'Test Search Query');
        Test.stopTest();

        Item__c updatedItem = [SELECT Image__c FROM Item__c WHERE Id = :testItem.Id];
        System.assertEquals('https://example.com/test-image.jpg', updatedItem.Image__c, 'The Image__c field should be updated with the correct URL.');
    }

    @isTest
    static void testUpdateItemImageInvalidInput() {
        Test.startTest();
        UnsplashAPI.updateItemImage(null, null);
        Test.stopTest();
    }

    @isTest
    static void testUpdateItemImageEmptyResults() {
        Item__c testItem = createTestItem();

        String mockResponse = '{ "results": [] }';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse, 200));

        Test.startTest();
        UnsplashAPI.updateItemImage(testItem.Id, 'Test Search Query');
        Test.stopTest();

        Item__c updatedItem = [SELECT Image__c FROM Item__c WHERE Id = :testItem.Id];
        System.assertEquals(null, updatedItem.Image__c, 'The Image__c field should remain null if no results are returned by the API.');
    }

    @isTest
    static void testUpdateItemImageHttpError() {
        Item__c testItem = createTestItem();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Internal Server Error', 500));

        Test.startTest();
        UnsplashAPI.updateItemImage(testItem.Id, 'Test Search Query');
        Test.stopTest();

        Item__c updatedItem = [SELECT Image__c FROM Item__c WHERE Id = :testItem.Id];
        System.assertEquals(null, updatedItem.Image__c, 'The Image__c field should remain null if the API call fails.');
    }
}