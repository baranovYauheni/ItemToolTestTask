public class PurchaseLineTriggerHandler {
    public static void updatePurchaseTotals(Map<Id, PurchaseLine__c> newPurchaseLines, Map<Id, PurchaseLine__c> oldPurchaseLines) {
        Set<Id> purchaseIds = new Set<Id>();

        if (newPurchaseLines != null) {
            for (PurchaseLine__c line : newPurchaseLines.values()) {
                if (line.PurchaseId__c != null) {
                    purchaseIds.add(line.PurchaseId__c);
                }
            }
        }

        if (oldPurchaseLines != null) {
            for (PurchaseLine__c line : oldPurchaseLines.values()) {
                if (line.PurchaseId__c != null) {
                    purchaseIds.add(line.PurchaseId__c);
                }
            }
        }

        if (!purchaseIds.isEmpty()) {
            List<Purchase__c> purchases = [SELECT Id, TotalItems__c, GrandTotal__c
                                            FROM Purchase__c
                                            WHERE Id IN :purchaseIds];

            List<AggregateResult> aggregateResults = [
                    SELECT PurchaseId__c, COUNT(Id) totalItems, SUM(Amount__c) grandTotal
                    FROM PurchaseLine__c
                    WHERE PurchaseId__c IN :purchaseIds
                    GROUP BY PurchaseId__c
            ];

            Map<Id, AggregateResult> aggregatedResultsMap = new Map<Id, AggregateResult>();
            for (AggregateResult result : aggregateResults) {
                aggregatedResultsMap.put((Id) result.get('PurchaseId__c'), result);
            }

            for (Purchase__c purchase : purchases) {
                AggregateResult result = aggregatedResultsMap.get(purchase.Id);
                if (result != null) {
                    purchase.TotalItems__c = (Integer) result.get('totalItems');
                    purchase.GrandTotal__c = (Double) result.get('grandTotal');
                }
            }

            if (!purchases.isEmpty()) {
                update purchases;
            }
        }
    }
}