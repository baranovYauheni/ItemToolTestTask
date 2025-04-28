public with sharing class UserController {
    @AuraEnabled(cacheable=true)
    public static Boolean isManager() {
        try {
            User currentUser = [SELECT IsManager__c FROM User WHERE Id = :UserInfo.getUserId()];
            return currentUser.IsManager__c;
        } catch (Exception e) {
            throw new AuraHandledException('Error while checking user status: ' + e.getMessage());
        }
    }
}