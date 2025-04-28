trigger PurchaseLineTrigger on PurchaseLine__c (after insert, after update, after delete, after undelete) {
    PurchaseLineTriggerHandler.updatePurchaseTotals(Trigger.newMap, Trigger.oldMap);
}