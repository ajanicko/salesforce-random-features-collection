@IsTest
public class KBAPITest {
    private static Datetime datetimeNow = Datetime.now();

    @IsTest
    static void getAccountTransactionsTest() {
        Test.setMock(HttpCalloutMock.class, new KBAPIGoodMock());
        KBAPI.getAccountTransactions();

        List<Payment__c> payments = [
            SELECT
                Ammount__c,
                CurrencyIsoCode,
                Counterparty_account_name__c,
                Counterparty_account_number__c,
                Payment_Date__c,
                Sum__c,
                Specific_symbol__c,
                Variable_Symbol__c
            FROM Payment__c
        ];
        for (Payment__c payment : payments) {
            System.assertEquals(49, payment.Ammount__c, 'Unexpected payment amount');
            System.assertEquals('CZK', payment.CurrencyIsoCode, 'Unexpected payment currency');
            System.assertEquals('TestCreditorName', payment.Counterparty_account_name__c, 'Unexpected name');
            System.assertEquals('CZ0401000000000000000000', payment.Counterparty_account_number__c, 'Unexpected iban');
            System.assertEquals(datetimeNow, payment.Payment_Date__c, 'Unexpected date');
            System.assertEquals(49, payment.Sum__c, 'Unexpected sum');
            System.assertEquals('00000001', payment.Specific_symbol__c, 'Unexpected specific symbol');
            System.assertEquals('00000000', payment.Variable_Symbol__c, 'Unexpected variable symbol');
        }
    }

    public class KBAPIGoodMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            KBAPI.Response response = new KBAPI.Response();
            response.pageCount = 1;
            response.pageNumber = 0;
            response.pageSize = 1;
            KBAPI.Transaction2 transaction2 = new KBAPI.Transaction2();
            KBAPI.Amount amount = new KBAPI.Amount();
            amount.amount = 49;
            amount.currency2 = 'CZK';
            transaction2.amount = amount;
            KBAPI.ValueDate valueDate = new KBAPI.ValueDate();
            valueDate.date2 = datetimeNow;
            transaction2.valueDate = valueDate;
            KBAPI.Identification identification = new KBAPI.Identification();
            identification.iban = 'CZ0401000000000000000000';
            identification.name = 'TestCreditorName';
            KBAPI.CreditorAccount creditorAccount = new KBAPI.CreditorAccount();
            creditorAccount.identification = identification;
            KBAPI.RelatedParties relatedParties = new KBAPI.RelatedParties();
            relatedParties.creditorAccount = creditorAccount;
            KBAPI.CreditorReferenceInformation creditorRefInf = new KBAPI.CreditorReferenceInformation();
            creditorRefInf.reference = new List<String>{ 'VS:00000000', 'SS:00000001', 'KS:0002' };
            KBAPI.Structured structured = new KBAPI.Structured();
            structured.creditorReferenceInformation = creditorRefInf;
            KBAPI.RemittanceInformation remittanceInf = new KBAPI.RemittanceInformation();
            remittanceInf.structured = structured;
            KBAPI.TransactionDetails transactionDetails = new KBAPI.TransactionDetails();
            transactionDetails.relatedParties = relatedParties;
            transactionDetails.remittanceInformation = remittanceInf;
            KBAPI.EntryDetails entryDetails = new KBAPI.EntryDetails();
            entryDetails.transactionDetails = transactionDetails;
            transaction2.entryDetails = entryDetails;
            response.transactions = new List<KBAPI.Transaction2>{ transaction2 };
            String jsonString = JSON.serialize(response);
            //replace reserved words
            jsonString = jsonString.replace('currency2', 'currency');
            jsonString = jsonString.replace('date2', 'date');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(jsonString);
            res.setStatusCode(200);
            return res;
        }
    }
}