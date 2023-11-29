@isTest
public class KoopIndividualDebtorInvocableTest {
    @isTest
    static void getDataGood() {
        Test.setMock(WebServiceMock.class, new KoopAPITest.GoodMock());
        List<KoopIndividualDebtorInvocable.Request> requests = new List<KoopIndividualDebtorInvocable.Request>();
        KoopIndividualDebtorInvocable.Request request = new KoopIndividualDebtorInvocable.Request();
        request.mesicuPoSplatnosti = 3;
        request.partnerId = 'c8aea8e17e604466bab2fb34a4fae20c';
        request.ziskatelList = new List<String>{'307539','207538'};
        requests.add(request);

        List<KoopIndividualDebtorInvocable.Response> responseList = KoopIndividualDebtorInvocable.getData(requests);

        System.assertEquals(1, responseList.size(), 'For 1 request, there should be 1 response');
        System.assertEquals(2, responseList[0].items.size(), 'There should be 2 items from GoodMock');
        System.assertEquals('User1', responseList[0].items[0].PRIJMENI, 'User1 should be in first item.');
        System.assertEquals('User2', responseList[0].items[1].PRIJMENI, 'User2 should be in second item.');
        System.assertEquals(2, responseList[0].dataInfo.PocetZaznamu, 'Be careful, value is static and wont change if you add items.');
    }
}
