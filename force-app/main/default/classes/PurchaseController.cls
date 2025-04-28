public with sharing class PurchaseController {

    @AuraEnabled
    public static Id createPurchase(List<Id> itemIds, Id accountId) {
        List<Item__c> items = [SELECT Id, Price__c FROM Item__c WHERE Id IN :itemIds];

        if (items.isEmpty()) {
            throw new AuraHandledException('No items found for the provided item IDs.');
        }

        Double grandTotal = 0;
        Integer totalItems = items.size();

        for (Item__c item : items) {
            grandTotal += item.Price__c;
        }

        Purchase__c purchase = new Purchase__c();
        purchase.ClientId__c = accountId;
        purchase.TotalItems__c = totalItems;
        purchase.GrandTotal__c = grandTotal;
        insert purchase;

        List<PurchaseLine__c> purchaseLines = new List<PurchaseLine__c>();
        for (Item__c item : items) {
            PurchaseLine__c line = new PurchaseLine__c();
            line.PurchaseId__c = purchase.Id;
            line.ItemId__c = item.Id;
            line.UnitCost__c = item.Price__c;
            line.Amount__c = item.Price__c * 1;
            purchaseLines.add(line);
        }

        if (!purchaseLines.isEmpty()) {
            insert purchaseLines;
        }
        return purchase.Id;
    }
}