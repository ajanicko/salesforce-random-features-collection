@isTest
public class FinstatAPITest {
    private static final String FAKE_RESPONSE =
        '{' +
        '  "Revenue": 1,' +
        '  "Profit": 1,' +
        '  "RegisterNumberText": "Obchodný register Okresného súdu Bratislava I, oddiel: Sro, vložka č. 35889/B",' +
        '  "Dic": "2021863811",' +
        '  "IcDPH": "SK2021863811",' +
        '  "SuspendedAsPerson": false,' +
        '  "PaymentOrderWarning": false,' +
        '  "PaymentOrderUrl": null,' +
        '  "OrChange": false,' +
        '  "OrChangeUrl": null,' +
        '  "SkNaceCode": "46190",' +
        '  "SkNaceText": "Sprostredkovanie obchodu s rozličným tovarom",' +
        '  "SkNaceDivision": "Veľkoobchod, okrem motorových vozidiel a motocyklov",' +
        '  "SkNaceGroup": "Sprostredkovanie veľkoobchodu",' +
        '  "LegalFormCode": "112",' +
        '  "LegalFormText": "Spol. s r. o.",' +
        '  "RpvsInsert": null,' +
        '  "RpvsUrl": null,' +
        '  "SalesCategory": "50,000,000 - 100,000,000 €",' +
        '  "ProfitActual": 2793391.0,' +
        '  "RevenueActual": 80785030.0,' +
        '  "IcDphAdditional": {' +
        '    "IcDph": "SK2021863811",' +
        '    "Paragraph": "§4",' +
        '    "CancelListDetectedDate": null,' +
        '    "RemoveListDetectedDate": null' +
        '  },' +
        '  "JudgementIndicators": [' +
        '    {' +
        '      "Name": "Defendant",' +
        '      "Value": true' +
        '    },' +
        '    {' +
        '      "Name": "Plaintiff",' +
        '      "Value": true' +
        '    }' +
        '  ],' +
        '  "JudgementFinstatLink": "http://www.finstat.sk/36562939/sudne_rozhodnutia?ref=ece7f05e806ff86a4d9a84c17855ea5c9ee8c5058f0397f89d1b1d73ddc1a108",' +
        '  "HasKaR": false,' +
        '  "HasDebt": false,' +
        '  "KaRUrl": null,' +
        '  "DebtUrl": null,' +
        '  "Anonymized": false,' +
        '  "BankAccounts": [' +
        '    {' +
        '      "AccountNumber": "SK8681300000002112960005",' +
        '      "PublishedAt": "2022-01-03T00:00:00"' +
        '    },' +
        '    {' +
        '      "AccountNumber": "CZ7326000000002531930206",' +
        '      "PublishedAt": "2022-01-03T00:00:00"' +
        '    },' +
        '    {' +
        '      "AccountNumber": "SK7811000000002624225848",' +
        '      "PublishedAt": "2022-01-03T00:00:00"' +
        '    },' +
        '    {' +
        '      "AccountNumber": "CZ2426000000002531930409",' +
        '      "PublishedAt": "2022-01-03T00:00:00"' +
        '    },' +
        '    {' +
        '      "AccountNumber": "CZ6003001712801017133453",' +
        '      "PublishedAt": "2022-01-03T00:00:00"' +
        '    },' +
        '    {' +
        '      "AccountNumber": "CZ0326000000002531930302",' +
        '      "PublishedAt": "2022-01-03T00:00:00"' +
        '    },' +
        '    {' +
        '      "AccountNumber": "CZ2426000000002531930118",' +
        '      "PublishedAt": "2022-01-03T00:00:00"' +
        '    },' +
        '    {' +
        '      "AccountNumber": "SK6875000000004001969241",' +
        '      "PublishedAt": "2022-01-03T00:00:00"' +
        '    }' +
        '  ],' +
        '  "Activity": "Sprostredkovanie",' +
        '  "Created": "2004-08-12T00:00:00",' +
        '  "Cancelled": null,' +
        '  "Warning": false,' +
        '  "WarningUrl": null,' +
        '  "Ico": "36562939",' +
        '  "Url": "http://www.finstat.sk/36562939?ref=ece7f05e806ff86a4d9a84c17855ea5c9ee8c5058f0397f89d1b1d73ddc1a108",' +
        '  "Name": "Alza.sk s. r. o.",' +
        '  "Street": "Sliačska",' +
        '  "StreetNumber": "1D",' +
        '  "ZipCode": "831 02",' +
        '  "City": "Bratislava - mestská časť Nové Mesto",' +
        '  "Country": null,' +
        '  "Region": "Bratislavský",' +
        '  "District": "Bratislava III"' +
        '}';

    public class GoodMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(FAKE_RESPONSE);
            res.setStatusCode(200);
            return res;
        }
    }

    public class BadMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('NaNNaNNaNNaNBatman');
            res.setStatusCode(400);
            return res;
        }
    }

    @isTest
    static void getDataGood() {
        Test.setMock(HttpCalloutMock.class, new GoodMock());
        List<FinstatAPI.Request> requests = new List<FinstatAPI.Request>();
        FinstatAPI.Request request = new FinstatAPI.Request();
        request.ico = '36562939';
        requests.add(request);

        Test.startTest();
        List<FinstatAPI.Response> responseList = FinstatAPI.getData(requests);
        Test.stopTest();

        System.assertEquals(1, responseList.size(), 'Response should have been returned.');
        System.assertEquals(request.ico, responseList[0].ico, 'Ico should be same.');
    }

    @isTest
    static void getDataBad() {
        Test.setMock(HttpCalloutMock.class, new BadMock());
        List<FinstatAPI.Request> requests = new List<FinstatAPI.Request>();
        FinstatAPI.Request request = new FinstatAPI.Request();
        request.ico = '36562939';
        requests.add(request);

        Test.startTest();
        List<FinstatAPI.Response> responseList = FinstatAPI.getData(requests);
        Test.stopTest();

        System.assertEquals(1, responseList.size(), 'Response should have been returned.');
        System.assertEquals(400, responseList[0].statusCode, 'Not OK status code expected.');
        System.assert(String.isNotBlank(responseList[0].errorResponseBody), 'Non empty error body expected.');
        System.assertEquals(request.ico, responseList[0].ico, 'Ico should be same.');
    }
}
