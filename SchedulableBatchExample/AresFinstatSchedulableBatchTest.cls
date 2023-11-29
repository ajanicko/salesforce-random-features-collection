@isTest
public class AresFinstatSchedulableBatchTest {
    @isTest
    static void executeBatchCZ() {
        Test.setMock(HttpCalloutMock.class, new AresAPITest.GoodMock());
        Account czAccount = TestDataFactory.createTestAccounts(1, false)[0];
        czAccount.Company_Registration_Number__c = '27074358';
        czAccount.BillingCountryCode = 'CZ';
        insert czAccount;

        Test.startTest();
        Database.executeBatch(new AresFinstatSchedulableBatch());
        Test.stopTest();

        List<Account> accUpdatedList = [SELECT VAT__c, HasValidCompanyRegister__c, CompanyRegisterCheckDate__c FROM Account];
        System.assertEquals('CZ27074358', accUpdatedList[0].VAT__c, 'VAT should have been updated from Mock request');
        System.assertEquals(true, accUpdatedList[0].HasValidCompanyRegister__c, 'Should be valid.');
        System.assertEquals(AresFinstatSchedulableBatch.TODAY, accUpdatedList[0].CompanyRegisterCheckDate__c, 'CompanyRegisterCheckDate__c should have been updated to today.');
    }

    @isTest
    static void executeBatchCZError() {
        Test.setMock(HttpCalloutMock.class, new AresAPITest.BadMock());
        Account czAccount = TestDataFactory.createTestAccounts(1, false)[0];
        czAccount.Company_Registration_Number__c = '27074358';
        czAccount.BillingCountryCode = 'CZ';
        insert czAccount;

        Test.startTest();
        Database.executeBatch(new AresFinstatSchedulableBatch());
        Test.stopTest();

        List<Error_Log__c> logList = [SELECT Class_Name__c, Message__c FROM Error_Log__c];
        System.assertEquals(1, logList.size(), 'Unexpected size.');
        System.assertEquals('AresFinstatSchedulableBatch.getDataFromApis', logList[0].Class_Name__c, 'Unexpected class.');
    }

    @isTest
    static void executeBatchSK() {
        Test.setMock(HttpCalloutMock.class, new FinstatAPITest.GoodMock());
        Account skAccount = TestDataFactory.createTestAccounts(1, false)[0];
        skAccount.Company_Registration_Number__c = '36562939';
        skAccount.BillingCountryCode = 'SK';
        insert skAccount;

        Test.startTest();
        Database.executeBatch(new AresFinstatSchedulableBatch());
        Test.stopTest();

        List<Account> accUpdatedList = [SELECT VAT__c, HasValidCompanyRegister__c, CompanyRegisterCheckDate__c FROM Account];
        System.assertEquals('SK2021863811', accUpdatedList[0].VAT__c, 'VAT should have been updated from Mock request');
        System.assertEquals(true, accUpdatedList[0].HasValidCompanyRegister__c, 'Should be valid.');
        System.assertEquals(AresFinstatSchedulableBatch.TODAY, accUpdatedList[0].CompanyRegisterCheckDate__c, 'CompanyRegisterCheckDate__c should have been updated to today.');
    }

    @isTest
    static void executeBatchSKError() {
        Test.setMock(HttpCalloutMock.class, new FinstatAPITest.BadMock());
        Account skAccount = TestDataFactory.createTestAccounts(1, false)[0];
        skAccount.Company_Registration_Number__c = '36562939';
        skAccount.BillingCountryCode = 'SK';
        insert skAccount;

        Test.startTest();
        Database.executeBatch(new AresFinstatSchedulableBatch());
        Test.stopTest();

        List<Error_Log__c> logList = [SELECT Class_Name__c, Message__c FROM Error_Log__c];
        System.assertEquals(1, logList.size(), 'Unexpected size.');
        System.assertEquals('AresFinstatSchedulableBatch.getDataFromApis', logList[0].Class_Name__c, 'Unexpected class.');
    }

    @isTest
    static void executeBatchPL() {
        Test.setMock(WebServiceMock.class, new ViesSoapAPITest.GoodMock());
        Account plAccount = TestDataFactory.createTestAccounts(1, false)[0];
        plAccount.VAT__c = 'PL7010482926';
        insert plAccount;

        Test.startTest();
        Database.executeBatch(new AresFinstatSchedulableBatch());
        Test.stopTest();

        List<Account> accUpdatedList = [SELECT OfficialName__c, BillingStreet, BillingPostalCode, BillingCity, BillingCountry, HasValidVATNumber__c, VIESRegisterCheckDate__c FROM Account];
        System.assertEquals(
            'ITERATORS SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ',
            accUpdatedList[0].OfficialName__c,
            'OfficialName__c should have been updated from Mock request'
        );
        //System.assertEquals('NOWOBERESTECKA 16 M2A 02-204 WARSZAWA', accUpdatedList[0].BillingStreet, 'BillingStreet should have been updated from Mock request');
        System.assertEquals(true, accUpdatedList[0].HasValidVATNumber__c, 'Should be valid.');
        System.assertEquals(AresFinstatSchedulableBatch.TODAY, accUpdatedList[0].VIESRegisterCheckDate__c, 'VIESRegisterCheckDate__c should have been updated to today.');
    }

    @isTest
    static void executeBatchBadICO() {
        Test.setMock(HttpCalloutMock.class, new FinstatAPITest.GoodMock());
        Account skAccount = TestDataFactory.createTestAccounts(1, false)[0];
        skAccount.HasValidCompanyRegister__c = true;
        skAccount.Company_Registration_Number__c = 'BADICO123456';
        skAccount.BillingCountryCode = 'SK';
        insert skAccount;

        Test.startTest();
        Database.executeBatch(new AresFinstatSchedulableBatch());
        Test.stopTest();

        List<Account> accUpdatedList = [SELECT VAT__c, HasValidCompanyRegister__c, CompanyRegisterCheckDate__c FROM Account];
        System.assertEquals(null, accUpdatedList[0].VAT__c, 'VAT should not have been updated.');
        System.assertEquals(false, accUpdatedList[0].HasValidCompanyRegister__c, 'HasValidCompanyRegister__c should have been false.');
        System.assertEquals(AresFinstatSchedulableBatch.TODAY, accUpdatedList[0].CompanyRegisterCheckDate__c, 'CompanyRegisterCheckDate__c should have been updated to today.');
    }

    @isTest
    static void executeBatchViesException() {
        Test.setMock(WebServiceMock.class, new ViesSoapAPITest.BadMock());
        Account plAccount = TestDataFactory.createTestAccounts(1, false)[0];
        plAccount.VAT__c = 'PL7010482926';
        plAccount.HasValidVATNumber__c = true;
        insert plAccount;

        Test.startTest();
        Database.executeBatch(new AresFinstatSchedulableBatch());
        Test.stopTest();

        List<Account> accUpdatedList = [SELECT HasValidVATNumber__c, VIESRegisterCheckDate__c FROM Account];
        System.assertEquals(true, accUpdatedList[0].HasValidVATNumber__c, 'There should be no change.');
        System.assertNotEquals(AresFinstatSchedulableBatch.TODAY, accUpdatedList[0].VIESRegisterCheckDate__c, 'VIESRegisterCheckDate__c should NOT have been updated to today.');
    }

    @isTest
    static void executeScheduler() {
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String cron = '0 6 * * * ?';

        Test.startTest();
        String jobId = System.schedule('Scheduler Test', cron, new AresFinstatSchedulableBatch());
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM CronTrigger WHERE id = :jobId], 'A job should be scheduled');
    }
}
