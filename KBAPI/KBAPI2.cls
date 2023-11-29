public with sharing class KBAPI2 {
    private static final String ACCOUNT_ID = KB_Account__mdt.getInstance('Account_1').Account_Id__c;
    private static final String API_KEY = KB_API_Setting__mdt.getInstance('KB').API_Key__c;
    //private static final String FROM_DATE = '2022-11-07';
    //pull everything from yesterday, needs to be scheduled in the morning
    private static final String FROM_DATE = Datetime.now().addDays(-1).formatGMT('yyyy-MM-dd');
    private static final String TO_DATE = FROM_DATE;
    private static final Http HTTP = new Http();

    //return first Client AccountId
    public static String sendAccountsRequest() {
        //https://api.kb.cz/open/api/adaa/v1/accounts
        String accountId;

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:KB_API');
        request.setMethod('GET');
        request.setHeader('x-correlation-id', '1c00c05d-9947-4c45-967e-efee1c30a9a1');
        request.setHeader('x-api-key', API_KEY);
        request.setHeader('Content-Type', 'application/json');
        HttpResponse response = HTTP.send(request);
        String jsonString = response.getBody();
        if (response.getStatusCode() == 200) {
            //replace reserved words
            jsonString = jsonString.replace('currency', 'currency2');
            //json string is not a valid JSON, as it is missing {}
            List<Object> accounts = (List<Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> firstAccount = (Map<String, Object>) accounts[0];
            accountId = (String) firstAccount.get('accountId');
        } else {
            //log an error
            System.debug(jsonString);
        }
        return accountId;
    }

    private static Response sendTransactionRequest(Integer page, String accountId) {
        //https://api.kb.cz/open/api/adaa/v1/accounts/:accountId/transactions?fromDate=2022-02-15&toDate=2022-03-05&size=20&page=0
        Response parsedResponse;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(
            'callout:KB_API/' +
            accountId +
            '/transactions?' +
            'fromDate=' +
            FROM_DATE +
            '&toDate=' +
            TO_DATE +
            '&page=' +
            page +
            '&size=' +
            20
        );
        request.setMethod('GET');
        request.setHeader('x-correlation-id', '1c00c05d-9947-4c45-967e-efee1c30a9a1');
        request.setHeader('x-api-key', API_KEY);
        HTTPResponse httpResponse = HTTP.send(request);

        String jsonString = httpResponse.getBody();
        if (httpResponse.getStatusCode() == 200) {
            //replace reserved words
            jsonString = jsonString.replace('currency', 'currency2');
            parsedResponse = (Response) JSON.deserialize(jsonString, Response.class);
        } else {
            //log an error
            System.debug(jsonString);
        }
        return parsedResponse;
    }

    private static List<Payment__c> createPayments(List<Content> contentList) {
        List<Payment__c> payments = new List<Payment__c>();
        for (Content content : contentList) {
            Payment__c payment = new Payment__c();
            payment.Ammount__c = content.amount.value;
            payment.CurrencyIsoCode = content.amount.currency2;
            payment.Counterparty_account_name__c = content?.counterParty?.name;
            payment.Counterparty_account_number__c = content?.counterParty?.accountNo;
            payment.Description__c = content?.additionalTransactionInformation;
            payment.Payment_Date__c = content?.valueDate;
            payment.Sum__c = content.amount.value;
            payment.Specific_symbol__c = content.references?.specific;
            payment.Variable_Symbol__c = content.references?.variable;
            payments.add(payment);
        }
        return payments;
    }

    @InvocableMethod(label='Create Payments FROM KB Transactions')
    public static void getAccountTransactions() {
        if (String.isNotBlank(ACCOUNT_ID)) {
            List<Payment__c> payments = new List<Payment__c>();
            Integer page = 0;
            Integer pageCount;
            do {
                Response response = sendTransactionRequest(page, ACCOUNT_ID);
                if (response != null) {
                    payments.addAll(createPayments(response.content));
                } else {
                    return;
                }

                if (page == 0) {
                    pageCount = response.totalPages;
                }
                page++;
            } while (page < pageCount);

            if (!payments.isEmpty() && Schema.sObjectType.Payment__c.isCreateable()) {
                insert payments;
            }
        }
    }

    public class Amount {
        public double value;
        public String currency2;
    }

    public class BankTransactionCode {
        public String code;
        public String issuer;
    }

    public class Content {
        public Datetime lastUpdated;
        public String accountType;
        public String entryReference;
        public String iban;
        public String creditDebitIndicator;
        public String transactionType;
        public BankTransactionCode bankTransactionCode;
        public Amount amount;
        public Datetime bookingDate;
        public Datetime valueDate;
        public Instructed instructed;
        public String status;
        public References references;
        public String additionalTransactionInformation;
        public CounterParty counterParty;
    }

    public class CounterParty {
        public String iban;
        public String accountNo;
        public String bankBic;
        public String bankCode;
        public String name;
    }

    public class Instructed {
        public Double value;
        public String currency2;
    }

    public class References {
        public String accountServicer;
        public String constant;
        public String variable;
        public String specific;
        public String endToEndIdentification;
        public String receiver;
    }

    public class Response {
        public List<Content> content;
        public Integer totalPages;
        public Integer pageNumber;
        public Integer pageSize;
        public Integer numberOfElements;
        public Boolean first;
        public Boolean last;
        public Boolean empty;
    }
}
