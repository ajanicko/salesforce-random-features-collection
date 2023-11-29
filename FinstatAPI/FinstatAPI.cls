public with sharing class FinstatAPI {
    private static Http http = new Http();
    private static final String API_KEY = 'E056A250CB994EF99E7581358629E228';
    private static final String PRIVATE_KEY = 'B8736BF41DF549F390C6C81C4A175554';

    @InvocableMethod(label='Retrieves JSON from Finstat and returns a parsed Response')
    public static List<Response> getData(List<Request> requests) {
        List<Response> responseList = new List<Response>();
        for (Request req : requests) {
            Response parsedResponse = new Response();
            if (ICOValidator.validate(req.ico)) {
                String normalizedIco = req.ico.replaceAll('(\\s+)', '');
                HttpRequest request = new HttpRequest();
                String hash = getHash(API_KEY, PRIVATE_KEY, normalizedIco);
                request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                request.setEndpoint('https://finstat.sk/api/detail.json');
                request.setBody('ico=' + normalizedIco + '&apiKey=' + API_KEY + '&Hash=' + hash);
                request.setMethod('POST');
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200) {
                    parsedResponse = (Response) JSON.deserialize(response.getBody(), Response.class);
                } else {
                    parsedResponse.errorResponseBody = response.getBody();
                    parsedResponse.ico = req.ico;
                }
                parsedResponse.statusCode = response.getStatusCode();
            }
            responseList.add(parsedResponse);
        }
        return responseList;
    }

    private static String getHash(String apiKey, String privateKey, String ico) {
        Blob targetBlob = Blob.valueOf('SomeSalt+' + apiKey + '+' + privateKey + '++' + ico + '+ended');
        Blob hash = Crypto.generateDigest('SHA-256', targetBlob);
        return EncodingUtil.convertToHex(hash);
    }

    public class Request {
        @InvocableVariable(required=true)
        public String ico;
    }

    public class BankAccount {
        @InvocableVariable
        public String accountNumber;
        @InvocableVariable
        public Datetime publishedAt;
    }

    public class IcDphAdditional {
        @InvocableVariable
        public String icDph;
        @InvocableVariable
        public String paragraph;
    }

    public class JudgementIndicator {
        @InvocableVariable
        public String name;
        @InvocableVariable
        public Boolean value;
    }

    public class Response {
        @InvocableVariable
        public Integer statusCode;
        @InvocableVariable
        public String errorResponseBody;
        @InvocableVariable
        public Decimal revenue;
        @InvocableVariable
        public Decimal profit;
        @InvocableVariable
        public String registerNumberText;
        @InvocableVariable
        public String dic;
        @InvocableVariable
        public String icDPH;
        @InvocableVariable
        public Boolean suspendedAsPerson;
        @InvocableVariable
        public Boolean paymentOrderWarning;
        @InvocableVariable
        public Boolean orChange;
        @InvocableVariable
        public String skNaceCode;
        @InvocableVariable
        public String skNaceText;
        @InvocableVariable
        public String skNaceDivision;
        @InvocableVariable
        public String skNaceGroup;
        @InvocableVariable
        public String legalFormCode;
        @InvocableVariable
        public String legalFormText;
        @InvocableVariable
        public String salesCategory;
        @InvocableVariable
        public Decimal profitActual;
        @InvocableVariable
        public Decimal revenueActual;
        @InvocableVariable
        public IcDphAdditional icDphAdditional;
        @InvocableVariable
        public List<JudgementIndicator> judgementIndicators;
        @InvocableVariable
        public String judgementFinstatLink;
        @InvocableVariable
        public Boolean hasKaR;
        @InvocableVariable
        public Boolean hasDebt;
        @InvocableVariable
        public Boolean anonymized;
        @InvocableVariable
        public List<BankAccount> bankAccounts;
        @InvocableVariable
        public String activity;
        @InvocableVariable
        public Datetime created;
        @InvocableVariable
        public Boolean warning;
        @InvocableVariable
        public String ico;
        @InvocableVariable
        public String url;
        @InvocableVariable
        public String name;
        @InvocableVariable
        public String street;
        @InvocableVariable
        public String streetNumber;
        @InvocableVariable
        public String zipCode;
        @InvocableVariable
        public String city;
        @InvocableVariable
        public String region;
        @InvocableVariable
        public String district;
    }
}
