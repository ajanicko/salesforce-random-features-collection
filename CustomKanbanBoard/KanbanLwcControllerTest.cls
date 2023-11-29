@IsTest
public class KanbanLwcControllerTest {
    @isTest
    static void getAllTasksTestEpic() {
        List<Task__c> tasks = TestDataFactory.createTestTasks(2, true);
        Id epicId = tasks[0].Epic__c;

        Test.startTest();
        Map<Id, Task__c> tasksToTestMap = new Map<Id, Task__c>();
        for (Task__c task : (List<Task__c>) KanbanLwcController.getAllRecords(epicId, 'Task__c', 7)) {
            tasksToTestMap.put(task.Id, task);
        }
        Test.stopTest();

        for (Task__c task : tasks) {
            System.assert(tasksToTestMap.containsKey(task.Id), 'Controller should have retuned all our tasks.');
        }
    }

    @isTest
    static void getAllCasesTest() {
        TestDataFactory.createTestCases(2, true);

        List<CaseBBT__c> casesToTest;
        Test.startTest();
        casesToTest = KanbanLwcController.getAllRecords(null, 'CaseBBT__c', 7);
        Test.stopTest();

        System.assertEquals(2, casesToTest.size(), 'Unexpected size');
    }

    @isTest
    static void getCurrentUserNameTest() {
        String testName;
        Test.startTest();
        testName = KanbanLwcController.getCurrentUserName();
        Test.stopTest();

        System.assertEquals(UserInfo.getName(), testName, 'Names should be equal');
    }
}
