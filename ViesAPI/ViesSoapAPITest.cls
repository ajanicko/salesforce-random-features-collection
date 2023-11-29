@isTest
public class ViesSoapAPITest {
    public class GoodMock implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
        ) {
            if (request instanceof ViesSoapAPI.checkVat_element) {
                ViesSoapAPI.checkVatResponse_element checkVatResponse = new ViesSoapAPI.checkVatResponse_element();
                checkVatResponse.countryCode = 'PL';
                checkVatResponse.vatNumber = '7010482926';
                checkVatResponse.requestDate = System.today();
                checkVatResponse.valid = true;
                checkVatResponse.name = 'ITERATORS SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ';
                checkVatResponse.address = 'NOWOBERESTECKA 16 M2A\n02-204 WARSZAWA';
                response.put('response_x', checkVatResponse);
            } else if (request instanceof ViesSoapAPI.checkVatApprox_element) {
                response.put('response_x', new ViesSoapAPI.checkVatApproxResponse_element());
            }
        }
    }

    public class BadMock implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
        ) {
            throw new CalloutException('BadMock Exception.');
        }
    }

    @isTest
    static void coverGeneratedCodeTypes() {
        Test.setMock(WebServiceMock.class, new GoodMock());
        ViesSoapAPI parentObject = new ViesSoapAPI();
        new ViesSoapAPI.checkVat_element();
        new ViesSoapAPI.checkVatApprox_element();
        new ViesSoapAPI.checkVatApproxResponse_element();
        new ViesSoapAPI.checkVatResponse_element();
        System.assert(parentObject != null, 'Should be empty object.');
    }

    @isTest
    static void coverCodeForcheckVat() {
        Test.setMock(WebServiceMock.class, new GoodMock());
        ViesSoapAPI.checkVatPort testObject = new ViesSoapAPI.checkVatPort();
        ViesSoapAPI.checkVatResponse_element response = testObject.checkVat(null, null);
        System.assertEquals('ITERATORS SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ', response.name, 'Name should be populated from Mock.');
    }

    @isTest
    static void coverCodeForcheckVatApprox() {
        Test.setMock(WebServiceMock.class, new GoodMock());
        ViesSoapAPI.checkVatPort testObject = new ViesSoapAPI.checkVatPort();
        System.assert(testObject.checkVatApprox(null, null, null, null, null, null, null, null, null) != null, 'Empty response should be returned.');
    }
}