public inherited sharing class KoopKmenInvocable {
    @InvocableMethod(label='Get data from Koop Kmen endpoint.')
    public static List<Response> getData(List<Request> requests) {
        List<Response> responseList = new List<Response>();
        for (Request req : requests) {
            KoopAPI.WSDataExtranetSoap wsDataExtranetSoap = new KoopAPI.WSDataExtranetSoap();
            wsDataExtranetSoap.timeout_x = 60000;
            KoopAPI.ArrayOfZiskatel arrayOfZiskatel = new KoopAPI.ArrayOfZiskatel();
            KoopAPI.Ziskatel[] koopZiskatelList = new List<KoopAPI.Ziskatel>();
            for (String ziskatel : req.ziskatelList) {
                KoopAPI.Ziskatel koopZiskatel = new KoopAPI.Ziskatel();
                koopZiskatel.CisloZiskatele = ziskatel;
                koopZiskatelList.add(koopZiskatel);
            }
            arrayOfZiskatel.Ziskatel = koopZiskatelList;

            KoopAPI.KmenData koopResponse = wsDataExtranetSoap.Kmen(arrayOfZiskatel, req.stavSmlouvy, req.partnerId, true);
            
            Response response = new Response();
            List<KoopAPI_KmenItem> tempItems = new List<KoopAPI_KmenItem>();
            for (KoopAPI.KmenItem item : koopResponse.KmenList.KmenItem) {
                tempItems.add((KoopAPI_KmenItem) JSON.deserialize(JSON.serialize(item), KoopAPI_KmenItem.class));
            }
            response.items = tempItems;
            response.dataInfo = (KoopAPI_ExtraDataInfo) JSON.deserialize(JSON.serialize(koopResponse.DataInfo), KoopAPI_ExtraDataInfo.class);
            responseList.add(response);
        }
        return responseList;
    }

    public class Request {
        @InvocableVariable(required=true)
        public List<String> ziskatelList;

        @InvocableVariable(required=true)
        public String stavSmlouvy;

        @InvocableVariable(required=true)
        public String partnerId;
    }

    public class Response {
        @InvocableVariable
        public List<KoopAPI_KmenItem> items;

        @InvocableVariable
        public KoopAPI_ExtraDataInfo dataInfo;
    }
}