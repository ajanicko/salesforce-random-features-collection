@isTest
public class KoopKmenDetailInvocableTest {
    @isTest
    static void getDataGood() {
        Test.setMock(WebServiceMock.class, new KoopAPITest.GoodMock());
        List<KoopKmenDetailInvocable.Request> requests = new List<KoopKmenDetailInvocable.Request>();
        KoopKmenDetailInvocable.Request request = new KoopKmenDetailInvocable.Request();
        request.cisloSmlouvy = '6009018452';
        request.partnerId = 'c8aea8e17e604466bab2fb34a4fae20c';
        request.ziskatelList = new List<String>{ '307539', '207538' };
        requests.add(request);

        List<KoopKmenDetailInvocable.Response> responseList = KoopKmenDetailInvocable.getData(requests);

        System.assertEquals(1, responseList.size(), 'For 1 request, there should be 1 response.');
        System.assertEquals(1, responseList[0].kmenDetailItems.size(), 'Unexpected number of items.');
        System.assertEquals('6009018452', responseList[0].kmenDetailItems[0].CISLO_NAVRHU, 'Unexpected value.');
        System.assertEquals(2, responseList[0].roleOsobaItems.size(), 'Unexpected number of items.');
        System.assertEquals('Pojistník', responseList[0].roleOsobaItems[0].ROLE_POPIS, 'Unexpected value.');
        System.assertEquals('Pojištěný', responseList[0].roleOsobaItems[1].ROLE_POPIS, 'Unexpected value.');
        System.assertEquals(1, responseList[0].osobaItems.size(), 'Unexpected number of items.');
        System.assertEquals('U letenského sadu', responseList[0].osobaItems[0].ULICE, 'Unexpected value.');
        System.assertEquals(2, responseList[0].dataInfo.PocetZaznamu, 'Be careful, value is static and wont change if you add items.');
    }
}
