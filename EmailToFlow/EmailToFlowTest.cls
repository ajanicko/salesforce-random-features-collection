@IsTest
public class EmailToFlowTest {
    @IsTest
    static void handleInboundEmailTest() {
        String fromTestEmail = 'test@test.com';
        String toTestEmail = 'salesforceEmailService@test.com';
        Account acc = TestDataFactory.createAccount('Test Acc', true);
        Contact contact = TestDataFactory.createContact('Test', 'Contact', acc.Id, false);
        contact.Email = fromTestEmail;
        insert contact;
        Epic__c epic = TestDataFactory.createTestOperationEpics(1, false)[0];
        epic.Name = 'Cases To Classification';
        insert epic;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = fromTestEmail;
        env.toAddress = toTestEmail;
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.htmlBody = '<div dir="ltr">Test 4 body</div>';
        email.toAddresses = new List<String>{
            toTestEmail,
            'emailtoflownew@2p1wqhyl2gqlw1kuw3chgk1lgsnlzdedpybbuswhc1elr4v2qa.26-huh5eak.cs81.apex.sandbox.salesforce.com'
        };
        email.fromAddress = fromTestEmail;
        email.headers = new List<Messaging.InboundEmail.Header>();
        email.headers.add(createHeader('Return-Path', fromTestEmail));
        email.headers.add(createHeader('X-SFDC-TLS-STATUS', 'true'));
        email.messageId = '<CANnPLY-+pHDU4Dziv36=z8Nc_UZ9g6mCSbtgFVBG09w4TcCLPg@mail.gmail.com>';
        email.subject = 'Test Subject';
        email.plainTextBody = 'Test Body';
        email.textAttachments = new List<Messaging.Inboundemail.TextAttachment>{ createTextAttachment() };
        email.binaryAttachments = new List<Messaging.Inboundemail.BinaryAttachment>{ createBinaryAttachment() };

        Test.startTest();
        Messaging.InboundEmailResult result = new EmailToFlow().handleInboundEmail(email, env);
        Test.stopTest();

        System.assertEquals(true, result.success, 'Success is expected.');
    }

    private static Messaging.Inboundemail.TextAttachment createTextAttachment() {
        Messaging.Inboundemail.TextAttachment txtAttachment = new Messaging.Inboundemail.TextAttachment();
        txtAttachment.body = 'Test';
        txtAttachment.bodyIsTruncated = false;
        txtAttachment.charset = 'US-ASCII';
        txtAttachment.fileName = 'Test.txt';
        txtAttachment.mimeTypeSubType = 'text/plain';
        txtAttachment.headers = new List<Messaging.InboundEmail.Header>();
        txtAttachment.headers.add(createHeader('Content-Type', 'text/plain; charset="US-ASCII"; name="test.txt"'));
        txtAttachment.headers.add(createHeader('Content-Disposition', 'attachment; filename="test.txt"'));
        txtAttachment.headers.add(createHeader('Content-Transfer-Encoding', 'base64'));
        txtAttachment.headers.add(createHeader('Content-ID', '<f_l88r8xi60>'));
        txtAttachment.headers.add(createHeader('X-Attachment-Id', 'f_l88r8xi60'));
        return txtAttachment;
    }

    private static Messaging.Inboundemail.BinaryAttachment createBinaryAttachment() {
        Messaging.Inboundemail.BinaryAttachment binaryAttachment = new Messaging.Inboundemail.BinaryAttachment();
        binaryAttachment.body = Blob.valueOf('Test');
        binaryAttachment.fileName = 'Test.pdf';
        binaryAttachment.mimeTypeSubType = 'application/pdf';
        binaryAttachment.headers = new List<Messaging.InboundEmail.Header>();
        binaryAttachment.headers.add(createHeader('Content-Type', 'application/pdf; name="test.pdf"'));
        binaryAttachment.headers.add(createHeader('Content-Disposition', 'attachment; filename="test.pdf"'));
        binaryAttachment.headers.add(createHeader('Content-Transfer-Encoding', 'base64'));
        binaryAttachment.headers.add(createHeader('Content-ID', '<f_l88r90371>'));
        binaryAttachment.headers.add(createHeader('X-Attachment-Id', 'f_l88r90371'));
        return binaryAttachment;
    }

    private static Messaging.InboundEmail.Header createHeader(String name, String value) {
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name = name;
        header.value = value;
        return header;
    }
}