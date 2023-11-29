public with sharing class EmailToFlow implements Messaging.InboundEmailHandler {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        List<Email_To_Flow_Setting__mdt> settings = Email_To_Flow_Setting__mdt.getAll().values();
        Map<String, Email_To_Flow_Setting__mdt> settingsMap = new Map<String, Email_To_Flow_Setting__mdt>();
        for (Email_To_Flow_Setting__mdt setting : settings) {
            settingsMap.put(setting.Email_Service_Address__c, setting);
        }
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

        Map<String, Object> flowParams = new Map<String, Object>();
        flowParams.put('HTMLBody', email.htmlBody);
        flowParams.put('ccAddresses', email.ccAddresses);
        flowParams.put('FromAddress', email.fromAddress);
        flowParams.put('ToAddresses', email.toAddresses);
        flowParams.put('FromName', email.fromName);
        String headerString = '';
        if (email.headers != null) {
            for (Messaging.InboundEmail.Header header : email.headers) {
                headerString += header.name + ': ' + header.value + '\n';
            }
        }
        flowParams.put('Headers', headerString);
        flowParams.put('MessageId', email.messageId);
        flowParams.put('Subject', email.subject);
        flowParams.put('PlainTextBody', email.plainTextBody);

        List<ContentVersion> versions = createVersions(email.textAttachments, email.binaryAttachments);
        if (!versions.isEmpty() && Schema.sObjectType.ContentVersion.isCreateable()) {
            insert versions;
        }
        versions = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :versions WITH SECURITY_ENFORCED];
        flowParams.put('EmailAttachments', versions);
        if (!Test.isRunningTest()) {
            Flow.Interview flow = Flow.Interview.createInterview(settingsMap.get(envelope.toAddress).Flow_API_Name__c, flowParams);
            flow.start();
        }
        result.success = true;
        return result;
    }

    private List<ContentVersion> createVersions(
        List<Messaging.Inboundemail.TextAttachment> textAttachments,
        List<Messaging.Inboundemail.BinaryAttachment> binaryAttachments
    ) {
        List<ContentVersion> versions = new List<ContentVersion>();
        if (textAttachments != null) {
            for (Messaging.Inboundemail.TextAttachment tAttachment : textAttachments) {
                versions.add(
                    new ContentVersion(Title = tAttachment.fileName, PathOnClient = tAttachment.fileName, VersionData = Blob.valueOf(tAttachment.body))
                );
            }
        }
        if (binaryAttachments != null) {
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : binaryAttachments) {
                versions.add(new ContentVersion(Title = bAttachment.fileName, PathOnClient = bAttachment.fileName, VersionData = bAttachment.body));
            }
        }
        return versions;
    }
}
