public with sharing class KanbanLwcController {
    @AuraEnabled(cacheable=true)
    public static List<SObject> getAllRecords(String epicRecordId, String objectApiName, Integer dayLimit) {
        Datetime datetimeFilter = Datetime.now().addDays(-1 * dayLimit);
        
        String baseQuery = 'SELECT Key__c, DueDate__c, OriginalEstimate__c, Epic__r.Name, Epic__r.Key__c, Name, Priority__c, Status__c, Assignee__r.Name, Project__c, Customer__c';
        if (objectApiName == 'Task__c') {
            baseQuery += ', Type__c FROM Task__c WHERE';
        } else if (objectApiName == 'CaseBBT__c') {
            baseQuery += ' FROM CaseBBT__c WHERE IsForClassification__c = FALSE AND';
        }

        String baseQueryReversedLastFilter;
        String statusFilterValues = '(\'Done\', \'Cancelled\', \'Duplicate\')';
        if (epicRecordId != null) {
            baseQuery += ' Epic__c = :epicRecordId AND';
        } 
        baseQueryReversedLastFilter = baseQuery;
        baseQuery += ' Status__c NOT IN ' + statusFilterValues;
        baseQueryReversedLastFilter += ' Status__c IN ' + statusFilterValues + ' AND LastModifiedDate >= :datetimeFilter';

        List<SObject> recordsToReturn = Database.query(baseQuery);
        recordsToReturn.addAll(Database.query(baseQueryReversedLastFilter));
        return recordsToReturn;
    }

    @AuraEnabled(cacheable=true)
    public static String getCurrentUserName() {
        return UserInfo.getName();
    }
}