public inherited sharing class KoopKmenDetailInvocable {
    @InvocableMethod(label='Get data from Koop KmenDetail endpoint.')
    public static List<Response> getData(List<Request> requests) {
        List<Response> responseList = new List<Response>();
        for (Request req : requests) {
            Response response = new Response();
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

            KoopAPI.KmenDetailData koopResponse = wsDataExtranetSoap.KmenDetail(arrayOfZiskatel, req.cisloSmlouvy, req.partnerId);

            List<KoopAPI_KmenDetailItem> tempKmenDetailItems = new List<KoopAPI_KmenDetailItem>();
            for (KoopAPI.KmenDetailItem item : koopResponse.KmenDetailList.KmenDetailItem) {
                tempKmenDetailItems.add((KoopAPI_KmenDetailItem) JSON.deserialize(JSON.serialize(item), KoopAPI_KmenDetailItem.class));
            }
            response.kmenDetailItems = tempKmenDetailItems;

            if (koopResponse?.RoleOsobaList?.RoleOsobaItem != null) {
                List<KoopAPI_RoleOsobaItem> tempRoleOsobaItems = new List<KoopAPI_RoleOsobaItem>();
                for (KoopAPI.RoleOsobaItem item : koopResponse.RoleOsobaList.RoleOsobaItem) {
                    tempRoleOsobaItems.add((KoopAPI_RoleOsobaItem) JSON.deserialize(JSON.serialize(item), KoopAPI_RoleOsobaItem.class));
                }
                response.roleOsobaItems = tempRoleOsobaItems;
            }

            if (koopResponse?.OsobaList?.OsobaItem != null) {
                List<KoopAPI_OsobaItem> tempOsobaItems = new List<KoopAPI_OsobaItem>();
                for (KoopAPI.OsobaItem item : koopResponse.OsobaList.OsobaItem) {
                    tempOsobaItems.add((KoopAPI_OsobaItem) JSON.deserialize(JSON.serialize(item), KoopAPI_OsobaItem.class));
                }
                response.osobaItems = tempOsobaItems;
            }

            if (koopResponse?.VozidloList?.VozidloItem != null) {
                List<KoopAPI_VozidloItem> tempVozidloItems = new List<KoopAPI_VozidloItem>();
                for (KoopAPI.VozidloItem item : koopResponse.VozidloList.VozidloItem) {
                    tempVozidloItems.add((KoopAPI_VozidloItem) JSON.deserialize(JSON.serialize(item), KoopAPI_VozidloItem.class));
                }
                response.vozidloItems = tempVozidloItems;
            }

            if (koopResponse?.RizikoList?.RizikoItem != null) {
                List<KoopAPI_RizikoItem> tempRizikoItems = new List<KoopAPI_RizikoItem>();
                for (KoopAPI.RizikoItem item : koopResponse.RizikoList.RizikoItem) {
                    tempRizikoItems.add((KoopAPI_RizikoItem) JSON.deserialize(JSON.serialize(item), KoopAPI_RizikoItem.class));
                }
                response.rizikoItems = tempRizikoItems;
            }

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
        public String cisloSmlouvy;

        @InvocableVariable(required=true)
        public String partnerId;
    }

    public class Response {
        @InvocableVariable
        public KoopAPI_KmenDetailItem[] kmenDetailItems;

        @InvocableVariable
        public KoopAPI_RoleOsobaItem[] roleOsobaItems;

        @InvocableVariable
        public KoopAPI_OsobaItem[] osobaItems;

        @InvocableVariable
        public KoopAPI_VozidloItem[] vozidloItems;

        @InvocableVariable
        public KoopAPI_MistoPojisteniItem[] mistoPojisteniItems;

        @InvocableVariable
        public KoopAPI_RizikoItem[] rizikoItems;

        @InvocableVariable
        public KoopAPI_ExtraDataInfo dataInfo;
    }
}
