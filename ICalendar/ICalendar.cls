public without sharing class ICalendar {
    /**
     * Owner name from url
     */
    public String ownerKey = ApexPages.currentPage().getParameters().get('owner');

    /**
     * Attributes
     */
    static final String CRLF = '\r\n';

    /**
     * Read the Events Object and return a well-formed iCal String.
     * @return result
     */
    public String getVCALENDAR() {
        List<Event> events = loadEvents();
        String dtstamp = 'DTSTAMP:' + Datetime.Now().formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'') + CRLF;
        String result = 'BEGIN:VCALENDAR' + CRLF + 'PRODID:-//Force.com Labs//iCalendar Export//EN' + CRLF + 'VERSION:2.0' + CRLF;
        result += 'METHOD:PUBLISH' + CRLF;
        result += 'X-WR-CALNAME:' + events[0].Owner.Name + '\'s Salesforce Calendar' + CRLF;
        result += 'X-WR-RELCALID:' + UserInfo.getUserId() + CRLF;
        for (Event event : events) {
            result += 'BEGIN:VEVENT' + CRLF;
            result += uid(event.Id);
            result += dtstamp;
            result += schedule(event.IsAllDayEvent, event.StartDateTime, event.EndDateTime);
            result += setField('SUMMARY:', event.Subject);
            result += setField('LOCATION:', event.Location);
            if (event.IsPrivate) {
                result += 'CLASS:PRIVATE' + CRLF;
            }
            result += busyStatus(event.ShowAs);
            if (!event.IsAllDayEvent) {
                result += reminder(event.ReminderDateTime, event.StartDateTime);
            }
            result += setField('DESCRIPTION:', addWhoWhat(event.Description, event.WhoId, event.Who.Type, event.WhatId, event.What.Type));
            result += 'END:VEVENT' + CRLF;
        }
        result += 'END:VCALENDAR' + CRLF;
        return result;
    }

    /**
     * Load the actuals Events for the UserId
     * @retun events;
     */
    private List<Event> loadEvents() {
        iCalendar_Owner_Mapping__c ownerMapping = [SELECT Event_Owner_Name__c FROM iCalendar_Owner_Mapping__c WHERE Key__c = :ownerKey LIMIT 1];

        List<Event> events = [
            SELECT
                Id,
                OwnerId,
                StartDateTime,
                EndDateTime,
                IsAllDayEvent,
                Subject,
                Location,
                ShowAs,
                IsPrivate,
                ReminderDateTime,
                Description,
                WhoId,
                Who.Type,
                WhatId,
                What.Type,
                IsRecurrence,
                IsGroupEvent,
                IsChild,
                Owner.Name
            FROM Event
            WHERE Owner.Name = :ownerMapping.Event_Owner_Name__c
        ];

        return events;
    }

    /**
     * Sets the escape format for the recived field
     * @params fieldName, fieldValue
     * @return fieldName+fieldValue
     */
    private String setField(String fieldName, String fieldValue) {
        if (fieldValue != null && fieldValue != '') {
            return fieldName + escape(fieldValue) + CRLF;
        }
        return '';
    }

    /**
     * Sets the escape format for the recived description field
     * @params fieldName, fieldValue
     * @return fieldName+fieldValue
     */
    private String setDescriptionField(String fieldName, String fieldValue) {
        if (fieldValue != null && fieldValue != '') {
            return fieldName + escape(fieldValue) + '\\n';
        }
        return '';
    }

    /**
     * Sets the UID value and return it
     * @params Id
     * @return 'UID:' + Id + CRLF;
     */
    private String uid(String id) {
        return 'UID:' + id + CRLF;
    }

    /**
     * Set the schedule and return result
     * @params isAllDayEvent, startDateTime, endDateTime
     * @return result;
     */
    private String schedule(Boolean isAllDayEvent, Datetime startDateTime, Datetime endDateTime) {
        String result;
        if (isAllDayEvent) {
            result = 'DTSTART;VALUE=DATE:' + startDateTime.formatGmt('yyyyMMdd') + CRLF;
            result += 'DTEND;VALUE=DATE:' + endDateTime.AddDays(1).formatGmt('yyyyMMdd') + CRLF;
        } else {
            result = 'DTSTART:' + startDateTime.formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'') + CRLF;
            result += 'DTEND:' + endDateTime.formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'') + CRLF;
        }
        return result;
    }

    /**
     * Check if the Event.WhoId is a Contact or Lead and return object type
     * @params whoId, whoId
     * @return sObject o;
     */
    private sObject whoProperties(String whoId, String whoType) {
        if (whoType == 'Contact' || whoType == 'Lead') {
            sObject o = Database.query('SELECT Name,Phone,Email FROM ' + whoType + ' WHERE Id=\'' + whoId + '\'')[0];
            return o;
        }
        return null;
    }

    /**
     * Check if the Event.WhatId is seted and return the object
     * @params whatId, whatType
     * @return sObject o;
     */
    private sObject whatProperties(String whatId, String whatType) {
        if (whatType != null) {
            sObject o = Database.query('SELECT Name FROM ' + whatType + ' WHERE Id=\'' + whatId + '\'')[0];
            return o;
        }
        return null;
    }

    /**
     * Add the Information about WhatId / WhoId
     * @params description, whoId, whoType, whatId, whatType
     * @return addInfo + description
     */
    private String addWhoWhat(String description, String whoId, String whoType, String whatId, String whatType) {
        if (description == null) {
            description = '';
        }
        sObject o = whoProperties(whoId, whoType);
        String addInfo = '';
        if (o != null) {
            addInfo += setDescriptionField(whoType + ': ', (String) o.get('Name'));
            addInfo += setDescriptionField('Phone: ', (String) o.get('Phone'));
            addInfo += setDescriptionField('Email: ', (String) o.get('Email'));
            addInfo += '\\n';
        }
        o = whatProperties(whatId, whatType);
        if (o != null) {
            if (whatType == 'Product2') {
                whatType = 'Product';
            }
            addInfo += setDescriptionField('Related to ' + whatType + ': ', (String) o.get('Name'));
            addInfo += '\\n';
        }
        return addInfo + description;
    }

    /**
     * Check the Event.ShowAs and set Busy Status
     * @params ShowAs
     * @return 'TRANSP:OPAQUE' + CRLF;
     */
    private String busyStatus(String ShowAs) {
        if (ShowAs == 'Free') {
            return 'TRANSP:TRANSPARENT' + CRLF + 'X-MICROSOFT-CDO-BUSYSTATUS:FREE' + CRLF;
        } else if (ShowAs == 'OutOfOffice') {
            return 'TRANSP:OPAQUE' + CRLF + 'X-MICROSOFT-CDO-BUSYSTATUS:OOF' + CRLF;
        }
        return 'TRANSP:OPAQUE' + CRLF;
    }

    /**
     * Sets the reminder alerts
     * @params ReminderDateTime, StartDateTime
     * @return string
     */
    private String reminder(Datetime ReminderDateTime, Datetime StartDateTime) {
        if (ReminderDateTime != null) {
            return 'BEGIN:VALARM' +
                CRLF +
                'TRIGGER:-PT' +
                ((StartDateTime.getTime() - ReminderDateTime.getTime()) / 1000) +
                'S' +
                CRLF +
                'ACTION:DISPLAY' +
                CRLF +
                'DESCRIPTION:reminder' +
                CRLF +
                'END:VALARM' +
                CRLF;
        }
        return '';
    }

    /**
     * Get a string and return this as eascaped string
     * @params original
     * @return original escaped
     */
    private String escape(String original) {
        return original.replace('\n', '\\n').replace('\r', '');
    }
}