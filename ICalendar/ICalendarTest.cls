@IsTest
public class ICalendarTest {
    @IsTest
    static void getVCALENDAR() {
        Account acc = TestDataFactory.createAccount('TestAccount', true);
        Contact con = TestDataFactory.createContact('Test', 'Name', acc.Id, true);
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User tempUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            email = 'test@test.com',
            Username = 'icalFeed@test.com',
            EmailEncodingKey = 'UTF-8',
            Alias = 'iFeed',
            TimeZoneSidKey = 'Europe/Prague',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = profileId
        );
        insert tempUser;
        System.runAs(tempUser) {
            Event e = new Event();
            e.DurationInMinutes = 60;
            e.ActivityDateTime = Datetime.now();
            e.Subject = 'Call';
            e.WhoId = con.Id;
            e.WhatId = acc.Id;
            e.ShowAs = 'Free';
            e.ReminderDateTime = Datetime.now().addDays(1);
            insert e;
        }
        iCalendar_Owner_Mapping__c mapping = new iCalendar_Owner_Mapping__c();
        mapping.Key__c = 'testKey';
        mapping.Event_Owner_Name__c = tempUser.FirstName + ' ' + tempUser.LastName;
        insert mapping;
        ICalendar ics = new ICalendar();

        String result;
        Test.startTest();
        ics.ownerKey = mapping.Key__c;
        result = ics.getVCALENDAR();
        Test.stopTest();

        System.assert(result != null, 'Some result should be returned.');
    }
}