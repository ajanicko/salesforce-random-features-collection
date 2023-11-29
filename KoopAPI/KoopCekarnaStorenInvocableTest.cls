@isTest
public class KoopCekarnaStorenInvocableTest {
    @isTest
    static void getDataGood() {
        Test.setMock(WebServiceMock.class, new KoopAPITest.GoodMock());
        List<KoopCekarnaStorenInvocable.Request> requests = new List<KoopCekarnaStorenInvocable.Request>();
        KoopCekarnaStorenInvocable.Request request = new KoopCekarnaStorenInvocable.Request();
        request.partnerId = 'c8aea8e17e604466bab2fb34a4fae20c';
        request.ziskatelList = new List<String>{'307539','207538'};
        requests.add(request);

        List<KoopCekarnaStorenInvocable.Response> responseList = KoopCekarnaStorenInvocable.getData(requests);

        System.assertEquals(1, responseList.size(), 'For 1 request, there should be 1 response');
        System.assertEquals(2, responseList[0].items.size(), 'Unexpected number of items.');
        System.assertEquals('SCS', responseList[0].items[0].KOD_PRODUKTU, 'Unexpected value.');
        System.assertEquals('1IO', responseList[0].items[1].KOD_PRODUKTU, 'Unexpected value.');
        System.assertEquals(2, responseList[0].dataInfo.PocetZaznamu, 'Be careful, value is static and wont change if you add items.');
    }
}
