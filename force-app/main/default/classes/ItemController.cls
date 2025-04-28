public with sharing class ItemController {
    @AuraEnabled(cacheable=true)
    public static List<Item__c> getAllItems() {
        return [SELECT Id, Name, Family__c, Type__c, Description__c, Price__c, Image__c FROM Item__c];
    }
}