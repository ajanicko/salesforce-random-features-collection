public inherited sharing class ViesCheckVatInvocable {
    @InvocableMethod(label='Get data from VIES checkVat endpoint.')
    public static List<Response> getData(List<Request> requests) {
        List<Response> responseList = new List<Response>();
        for (Request req : requests) {
            Response response = new Response();
            ViesSoapAPI.checkVatPort checkVatPort = new ViesSoapAPI.checkVatPort();
            response.item = (ViesSoapAPI_checkVatResponse_element) JSON.deserialize(
                JSON.serialize(checkVatPort.checkVat(req.countryCode, req.vatNumber)),
                ViesSoapAPI_checkVatResponse_element.class
            );
            responseList.add(response);
        }
        return responseList;
    }

    public class Request {
        @InvocableVariable(required=true)
        public String vatNumber;
        @InvocableVariable(required=true)
        public String countryCode;
    }

    public class Response {
        @InvocableVariable
        public ViesSoapAPI_checkVatResponse_element item;
    }
}
