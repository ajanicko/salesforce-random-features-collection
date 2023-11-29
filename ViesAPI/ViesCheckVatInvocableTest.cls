@isTest
public class ViesCheckVatInvocableTest {
    @isTest
    static void getDataGood() {
        Test.setMock(WebServiceMock.class, new ViesSoapAPITest.GoodMock());
        List<ViesCheckVatInvocable.Request> requests = new List<ViesCheckVatInvocable.Request>();
        ViesCheckVatInvocable.Request request = new ViesCheckVatInvocable.Request();
        request.vatNumber = '11900750';
        request.countryCode = 'CZ';
        requests.add(request);

        List<ViesCheckVatInvocable.Response> responseList = ViesCheckVatInvocable.getData(requests);

        System.assertEquals('ITERATORS SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ', responseList[0].item.name, 'Name should be populated from Mock.');
        System.assertEquals(true, responseList[0].item.valid, 'Valid should be populated from Mock.');
    }
}