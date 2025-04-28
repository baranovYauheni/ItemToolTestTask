@IsTest
private class AccountControllerTest {
    @TestSetup
    static void testData() {
        Account testAccount = new Account(
                Name = 'Test Account',
                AccountNumber = '123456',
                Industry = 'test'
        );
        insert testAccount;
    }

    @isTest
    static void testGetAccountDetails_Success() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Test.startTest();
        Account result = AccountController.getAccountDetails(testAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Account should not be null');
        System.assertEquals(testAccount.Id, result.Id, 'Account ID should match');
        System.assertEquals('Test Account', result.Name, 'Account Name should match');
        System.assertEquals('123456', result.AccountNumber, 'Account Number should match');
        System.assertEquals('test', result.Industry, 'Account Industry should match');
    }
}