public with sharing class AccountController {
    @AuraEnabled(cacheable=true)
    public static Account getAccountDetails(Id accountId) {
        return [
                SELECT Id, Name, AccountNumber, Industry
                FROM Account
                WHERE Id = :accountId
                LIMIT 1
        ];
    }
}