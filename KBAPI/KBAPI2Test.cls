@IsTest
public class KBAPI2Test {
    @IsTest
    static void sendAccountsRequestTest() {
        Test.setMock(HttpCalloutMock.class, new KBAPIGoodMock());
        String accountId = KBAPI2.sendAccountsRequest();

        System.assert(String.isNotBlank(accountId), 'Some KB AccountId should be returned.');
    }

    @IsTest
    static void getAccountTransactionsTest() {
        Test.setMock(HttpCalloutMock.class, new KBAPIGoodMock());
        KBAPI2.getAccountTransactions();

        List<Payment__c> payments = [SELECT Ammount__c, CurrencyIsoCode FROM Payment__c];
        System.assertEquals(5, payments.size(), 'Unexpected number of payments returned.');
        for (Payment__c payment : payments) {
            System.assert(payment.Ammount__c != null, 'Amount cant be NULL.');
            System.assert(payment.CurrencyIsoCode != null, 'Currency cant be NULL');
        }
    }

    public class KBAPIGoodMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String json = '';
            if (req.getEndpoint().contains('transactions')) {
                json =
                    '{' +
                    '    "content": [' +
                    '        {' +
                    '            "lastUpdated": "2019-06-05T11:34:00Z",' +
                    '            "accountType": "KB",' +
                    '            "entryReference": "298-05062019 16020106916F1",' +
                    '            "iban": "CZ1301000901147771800227",' +
                    '            "creditDebitIndicator": "DEBIT",' +
                    '            "transactionType": "FEE",' +
                    '            "bankTransactionCode": {' +
                    '                "code": "400006",' +
                    '                "issuer": "OTHER"' +
                    '            },' +
                    '            "amount": {' +
                    '                "value": 18.0,' +
                    '                "currency": "CZK"' +
                    '            },' +
                    '            "bookingDate": "2019-06-05",' +
                    '            "valueDate": "2019-06-05",' +
                    '            "instructed": {' +
                    '                "value": 18.0,' +
                    '                "currency": "CZK"' +
                    '            },' +
                    '            "status": "PNG",' +
                    '            "references": {' +
                    '                "accountServicer": "298-05062019 16020106916F1",' +
                    '                "constant": "0898"' +
                    '            },' +
                    '            "additionalTransactionInformation": "TP zalozeni :  1 x  18, F00106916F1TP_MBB"' +
                    '        },' +
                    '        {' +
                    '            "lastUpdated": "2019-06-05T11:34:00Z",' +
                    '            "accountType": "KB",' +
                    '            "entryReference": "001-04062019 1602 602003 110031",' +
                    '            "iban": "CZ1301000901147771800227",' +
                    '            "creditDebitIndicator": "DEBIT",' +
                    '            "transactionType": "DOMESTIC",' +
                    '            "bankTransactionCode": {' +
                    '                "code": "100001",' +
                    '                "issuer": "OTHER"' +
                    '            },' +
                    '            "amount": {' +
                    '                "value": 268.0,' +
                    '                "currency": "CZK"' +
                    '            },' +
                    '            "bookingDate": "2019-06-04",' +
                    '            "valueDate": "2019-06-04",' +
                    '            "instructed": {' +
                    '                "value": 268.0,' +
                    '                "currency": "CZK"' +
                    '            },' +
                    '            "status": "BOOK",' +
                    '            "counterParty": {' +
                    '                "iban": "CZ0203000000000000000246",' +
                    '                "accountNo": "0000000000000246",' +
                    '                "bankBic": "CEKOCZPPXXX",' +
                    '                "bankCode": "0300"' +
                    '            },' +
                    '            "references": {' +
                    '                "accountServicer": "IU01RFIQT2F",' +
                    '                "variable": "6112047021",' +
                    '                "constant": "8422",' +
                    '                "specific": "3258999654"' +
                    '            },' +
                    '            "additionalTransactionInformation": "Force pay debit, IU01RFIQT2F 01"' +
                    '        },' +
                    '        {' +
                    '            "lastUpdated": "2019-06-05T11:34:00Z",' +
                    '            "accountType": "KB",' +
                    '            "entryReference": "001-22052019 1602 602030 390281",' +
                    '            "iban": "CZ1301000901147771800227",' +
                    '            "creditDebitIndicator": "CREDIT",' +
                    '            "transactionType": "DOMESTIC",' +
                    '            "bankTransactionCode": {' +
                    '                "code": "100001",' +
                    '                "issuer": "OTHER"' +
                    '            },' +
                    '            "amount": {' +
                    '                "value": 2550.0,' +
                    '                "currency": "CZK"' +
                    '            },' +
                    '            "bookingDate": "2019-05-22",' +
                    '            "valueDate": "2019-05-22",' +
                    '            "instructed": {' +
                    '                "value": 2550.0,' +
                    '                "currency": "CZK"' +
                    '            },' +
                    '            "status": "BOOK",' +
                    '            "counterParty": {' +
                    '                "iban": "CZ8101000901147770990217",' +
                    '                "name": "TATOR JAN",' +
                    '                "accountNo": "0901147770990217",' +
                    '                "bankBic": "KOMBCZPPXXX",' +
                    '                "bankCode": "0100"' +
                    '            },' +
                    '            "references": {' +
                    '                "accountServicer": "IU01RFH4XQH"' +
                    '            },' +
                    '            "additionalTransactionInformation": "Transfer credit, IU01RFH4XQH 01"' +
                    '        },' +
                    '        {' +
                    '            "lastUpdated": "2019-06-05T11:34:00Z",' +
                    '            "accountType": "KB",' +
                    '            "entryReference": "000-10052019-005-005-001-025660",' +
                    '            "iban": "CZ1301000901147771800227",' +
                    '            "creditDebitIndicator": "DEBIT",' +
                    '            "transactionType": "DOMESTIC",' +
                    '            "bankTransactionCode": {' +
                    '                "code": "100001",' +
                    '                "issuer": "OTHER"' +
                    '            },' +
                    '            "amount": {' +
                    '                "value": 6669.0,' +
                    '                "currency": "CZK"' +
                    '            },' +
                    '            "bookingDate": "2019-05-10",' +
                    '            "valueDate": "2019-05-10",' +
                    '            "instructed": {' +
                    '                "value": 6669.0,' +
                    '                "currency": "CZK"' +
                    '            },' +
                    '            "status": "BOOK",' +
                    '            "counterParty": {' +
                    '                "iban": "CZ5501000000000000000246",' +
                    '                "name": "IB-TĚST-1-ALĚNA-ŠČŘP ALĚNKA",' +
                    '                "accountNo": "0000000000000246",' +
                    '                "bankBic": "CEKOCZPPXXX",' +
                    '                "bankCode": "0100"' +
                    '            },' +
                    '            "references": {' +
                    '                "accountServicer": "000-10052019-005-005-001-025660",' +
                    '                "variable": "5545005500",' +
                    '                "constant": "4564",' +
                    '                "specific": "0000847552"' +
                    '            },' +
                    '            "additionalTransactionInformation": "Debit transfer, NA   CK-0000000000000246"' +
                    '        },' +
                    '        {' +
                    '            "lastUpdated": "2019-06-05T11:34:00Z",' +
                    '            "accountType": "KB",' +
                    '            "entryReference": "001-01112021 1602 602005 011151",' +
                    '            "iban": "CZ1301000901147771800227",' +
                    '            "creditDebitIndicator": "CREDIT",' +
                    '            "transactionType": "SEPA",' +
                    '            "bankTransactionCode": {' +
                    '                "code": "100004",' +
                    '                "issuer": "OTHER"' +
                    '            },' +
                    '            "amount": {' +
                    '                "value": 681.81,' +
                    '                "currency": "CZK"' +
                    '            },' +
                    '            "bookingDate": "2019-05-25",' +
                    '            "valueDate": "2019-05-25",' +
                    '            "instructed": {' +
                    '                "value": 27.28,' +
                    '                "currency": "EUR"' +
                    '            },' +
                    '            "status": "BOOK",' +
                    '            "counterParty": {' +
                    '                "iban": "FR7630003033000002054269605",' +
                    '                "name": "Francouzska Alizeé",' +
                    '                "accountNo": "00020542696",' +
                    '                "bankBic": "SOGEFRPPXXX",' +
                    '                "bankCode": "30003"' +
                    '            },' +
                    '            "references": {' +
                    '                "accountServicer": "IU01RFYZ35C",' +
                    '                "endToEndIdentification": "a6s51f6s51a69",' +
                    '                "constant": "6020000000",' +
                    '                "specific": "2206139812",' +
                    '                "receiver": "remittance info"' +
                    '            },' +
                    '            "additionalTransactionInformation": "Transfer credit, ucetFR7630003033000002054269605    rfKB   2206139812602               rfJUs65f1a6s5f1as561f651s9, bankSOGEFRPPXXX                    poplSLV, IU01RFYZ35C 13"' +
                    '        }' +
                    '    ],' +
                    '    "totalPages": 1,' +
                    '    "pageNumber": 0,' +
                    '    "pageSize": 10,' +
                    '    "numberOfElements": 5,' +
                    '    "first": true,' +
                    '    "last": true,' +
                    '    "empty": false' +
                    '}';
            } else {
                json =
                    '[' +
                    '    {' +
                    '        "accountId": "Q1oxMzAxMDAwOTAxMTQ3NzcxODAwMjI3OkNaSw",' +
                    '        "iban": "CZ1301000901147771800227",' +
                    '        "currency": "CZK"' +
                    '    },' +
                    '    {' +
                    '        "accountId": "Q1o2MTAxMDAwOTAwOTMwNzkwMTgwMjg3OkNaSw",' +
                    '        "iban": "CZ6101000900930790180287",' +
                    '        "currency": "CZK"' +
                    '    },' +
                    '    {' +
                    '        "accountId": "Q1o0NDAxMDAwOTAxMTQ4MDk2MTMwMjI3OkNaSw",' +
                    '        "iban": "CZ4401000901148096130227",' +
                    '        "currency": "CZK"' +
                    '    },' +
                    '    {' +
                    '        "accountId": "Q1o5NjAxMDAwOTAxMTQ4MDY2NTQwMjE3OkNaSw",' +
                    '        "iban": "CZ9601000901148066540217",' +
                    '        "currency": "CZK"' +
                    '    },' +
                    '    {' +
                    '        "accountId": "Q1o2ODAxMDAwOTAxMTQ3ODI2NzAwMjY3OkNaSw",' +
                    '        "iban": "CZ6801000901147826700267",' +
                    '        "currency": "CZK"' +
                    '    }' +
                    ']';
            }
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(json);
            res.setStatusCode(200);
            return res;
        }
    }
}
