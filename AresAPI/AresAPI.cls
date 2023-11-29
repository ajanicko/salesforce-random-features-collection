public class AresAPI {
    private static Response parsedResponse;
    private static Http http = new Http();

    @InvocableMethod(label='Retrieves Data from MFCR Basic API based on Company ICO.')
    public static List<Response> getData(List<Requests> requests) {
        List<Response> responseList = new List<Response>();
        for (Requests req : requests) {
            parsedResponse = new Response();
            if (ICOValidator.validate(req.ico)) {
                HttpRequest request = new HttpRequest();
                request.setEndpoint('https://wwwinfo.mfcr.cz/cgi-bin/ares/darv_bas.cgi?ico=' + req.ico.replaceAll('(\\s+)', ''));
                request.setMethod('GET');
                HttpResponse response = http.send(request);
                parsedResponse.statusCode = response.getStatusCode();
                if (response.getStatusCode() == 200) {
                    DOM.Document doc = new DOM.Document();
                    doc.load(response.getBody());
                    DOM.XmlNode rootNode = doc.getRootElement();
                    parseXML(rootNode);
                } else {
                    parsedResponse.errorResponseBody = response.getBody();
                    parsedResponse.ico = req.ico;
                }
            }
            responseList.add(parsedResponse);
        }
        return responseList;
    }

    private static void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if ('OF'.equals(node.getName())) {
                parsedResponse.companyName = node.getText().trim();
            } else if ('ICO'.equals(node.getName())) {
                parsedResponse.ico = node.getText().trim();
            } else if ('DIC'.equals(node.getName())) {
                parsedResponse.dic = node.getText().trim();
            } else if ('KPF'.equals(node.getName())) {
                parsedResponse.legalFormId = node.getText().trim();
            } else if ('NPF'.equals(node.getName())) {
                parsedResponse.legalFormName = node.getText().trim();
            } else if ('IDA'.equals(node.getName())) {
                parsedResponse.addressId = node.getText().trim();
            } else if ('KS'.equals(node.getName())) {
                parsedResponse.stateCode = node.getText().trim();
            } else if ('NS'.equals(node.getName())) {
                parsedResponse.stateName = node.getText().trim();
            } else if ('N'.equals(node.getName())) {
                parsedResponse.cityName = node.getText().trim();
            } else if ('NCO'.equals(node.getName())) {
                parsedResponse.districtName = node.getText().trim();
            } else if ('NMC'.equals(node.getName())) {
                parsedResponse.municipalityName = node.getText().trim();
            } else if ('NU'.equals(node.getName())) {
                parsedResponse.streetName = node.getText().trim();
            } else if ('CD'.equals(node.getName()) && 'AA'.equals(node.getParent().getName())) {
                parsedResponse.houseNumber = node.getText().trim();
            } else if ('TCD'.equals(node.getName()) && 'AA'.equals(node.getParent().getName())) {
                parsedResponse.houseNumberType = node.getText().trim();
            } else if ('CO'.equals(node.getName()) && 'AA'.equals(node.getParent().getName())) {
                parsedResponse.houseReferenceNumber = node.getText().trim();
            } else if ('PSC'.equals(node.getName()) && 'AA'.equals(node.getParent().getName())) {
                parsedResponse.psc = node.getText().trim();
            } else if ('KPP'.equals(node.getName())) {
                parsedResponse.numberOfEmployees = node.getText().trim();
            } else if ('SSU'.equals(node.getName())) {
                parsedResponse.state = node.getText().trim();
            } else if ('NACE'.equals(node.getName())) {
                parsedResponse.naceList.add(node.getText().trim());
            }
        }
        for (Dom.XMLNode child : node.getChildElements()) {
            parseXML(child);
        }
    }

    public class Requests {
        @InvocableVariable(required=true)
        public String ico;
    }

    public class Response {
        @InvocableVariable
        public Integer statusCode;

        @InvocableVariable
        public String errorResponseBody;

        @InvocableVariable(label='Obchodni_firma')
        public String companyName;

        @InvocableVariable
        public String ico;

        @InvocableVariable
        public String dic;

        @InvocableVariable(label='Kod_PF')
        public String legalFormId;

        @InvocableVariable(label='Nazev_PF')
        public String legalFormName;

        @InvocableVariable(label='Adresa ARES: ID_adresy')
        public String addressId;

        @InvocableVariable(label='Adresa ARES: Kod_statu')
        public String stateCode;

        @InvocableVariable(label='Adresa ARES: Nazev_statu')
        public String stateName;

        @InvocableVariable(label='Adresa ARES: Nazev_obce')
        public String cityName;

        @InvocableVariable(label='Adresa ARES: Nazev_casti_obce')
        public String districtName;

        @InvocableVariable(label='Adresa ARES: Nazev_mestske_casti')
        public String municipalityName;

        @InvocableVariable(label='Adresa ARES: Nazev_ulice')
        public String streetName;

        @InvocableVariable(label='Adresa ARES: Cislo_domovni')
        public String houseNumber;

        @InvocableVariable(label='Adresa ARES: Typ_cislo_domovni')
        public String houseNumberType;

        @InvocableVariable(label='Adresa ARES: Cislo_orientacni')
        public String houseReferenceNumber;

        @InvocableVariable(label='Adresa ARES: PSC')
        public String psc;

        @InvocableVariable(label='Kategorie_poctu_pracovniku')
        public String numberOfEmployees;

        @InvocableVariable(label='Stav_subjektu')
        public String state;

        @InvocableVariable
        public List<String> naceList = new List<String>();
    }
}
