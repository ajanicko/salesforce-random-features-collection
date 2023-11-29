public inherited sharing class KoopCekarnaStorenInvocable {
    @InvocableMethod(label='Get data from Koop CekarnaStoren endpoint.')
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

            KoopAPI.CekarnaStorenData koopResponse = wsDataExtranetSoap.CekarnaStoren(arrayOfZiskatel, true, req.partnerId, true);

            Response response = new Response();
            List<KoopAPI_CekarnaStorenItem> tempItems = new List<KoopAPI_CekarnaStorenItem>();
            for (KoopAPI.CekarnaStorenItem item : koopResponse.CekarnaStorenList.CekarnaStorenItem) {
                tempItems.add((KoopAPI_CekarnaStorenItem) JSON.deserialize(JSON.serialize(item), KoopAPI_CekarnaStorenItem.class));
            }
            response.items = tempItems;

            response.dataInfo = (KoopAPI_ExtraDataInfo) JSON.deserialize(
                JSON.serialize(koopResponse.DataInfo),
                KoopAPI_ExtraDataInfo.class
            );
            responseList.add(response);
        }
        return responseList;
    }

    public class Request {
        @InvocableVariable(required=true)
        public List<String> ziskatelList;

        @InvocableVariable(required=true)
        public String partnerId;
    }

    public class Response {
        @InvocableVariable
        public List<KoopAPI_CekarnaStorenItem> items;

        @InvocableVariable
        public KoopAPI_ExtraDataInfo dataInfo;
    }
}
