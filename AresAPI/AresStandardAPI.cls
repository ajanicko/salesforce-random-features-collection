public inherited sharing class AresStandardAPI {
    private static AresStandardAPIMatch match;
    private static Http http = new Http();

    @InvocableMethod(label='Retrieves Data from MFCR Standard API based on Company Name.')
    public static List<Response> getData(List<Request> requests) {
        List<Response> responseList = new List<Response>();
        for (Request req : requests) {
            Response parsedResponse = new Response();
            parsedResponse.matchList = new List<AresStandardAPIMatch>();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://wwwinfo.mfcr.cz/cgi-bin/ares/darv_std.cgi?obchodni_firma=' + EncodingUtil.urlEncode(req.companyName, 'UTF-8'));
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            Dom.Document doc = response.getBodyDocument();
            DOM.XmlNode rootNode = doc.getRootElement();
            DOM.XmlNode answerNode = rootNode.getChildElement('Odpoved', 'http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_answer/v_1.0.1');
            for (DOM.XmlNode node : answerNode.getChildElements()) {
                if (node.getNodeType() == DOM.XMLNodeType.ELEMENT && 'Zaznam'.equals(node.getName())) {
                    match = new AresStandardAPIMatch();
                    parseXML(node);
                    parsedResponse.matchList.add(match);
                }
            }
            responseList.add(parsedResponse);
        }
        return responseList;
    }

    private static void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if ('Obchodni_firma'.equals(node.getName())) {
                match.companyName = node.getText().trim();
            } else if ('ICO'.equals(node.getName())) {
                match.ico = node.getText().trim();
            } else if ('Kod_PF'.equals(node.getName())) {
                match.legalFormId = node.getText().trim();
            } else if ('ID_adresy'.equals(node.getName())) {
                match.addressId = node.getText().trim();
            } else if ('Kod_statu'.equals(node.getName())) {
                match.stateCode = node.getText().trim();
            } else if ('Nazev_okresu'.equals(node.getName())) {
                match.regionName = node.getText().trim();
            } else if ('Nazev_obce'.equals(node.getName())) {
                match.cityName = node.getText().trim();
            } else if ('Nazev_casti_obce'.equals(node.getName())) {
                match.districtName = node.getText().trim();
            } else if ('Nazev_mestske_casti'.equals(node.getName())) {
                match.municipalityName = node.getText().trim();
            } else if ('Nazev_ulice'.equals(node.getName())) {
                match.streetName = node.getText().trim();
            } else if ('Cislo_domovni'.equals(node.getName()) && 'Adresa_ARES'.equals(node.getParent().getName())) {
                match.houseNumber = node.getText().trim();
            } else if ('Typ_cislo_domovni'.equals(node.getName()) && 'Adresa_ARES'.equals(node.getParent().getName())) {
                match.houseNumberType = node.getText().trim();
            } else if ('Cislo_orientacni'.equals(node.getName()) && 'Adresa_ARES'.equals(node.getParent().getName())) {
                match.houseReferenceNumber = node.getText().trim();
            } else if ('PSC'.equals(node.getName()) && 'Adresa_ARES'.equals(node.getParent().getName())) {
                match.psc = node.getText().trim();
            }
        }
        for (Dom.XMLNode child : node.getChildElements()) {
            parseXML(child);
        }
    }

    public class Request {
        @InvocableVariable(required=true)
        public String companyName;
    }

    public class Response {
        @InvocableVariable
        public List<AresStandardAPIMatch> matchList;
    }
}
