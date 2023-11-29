public with sharing class KBAPI {
    private static final String ACCOUNT_ID = KB_Account__mdt.getInstance('Account_1').Account_Id__c;
    //only data on KB test sandbox
    private static final String FROM_DATE = '2021-06-30';
    //private static final String FROM_DATE = Datetime.now().addDays(-1).formatGMT('yyyy-MM-dd');
    private static final String TO_DATE = FROM_DATE;
    private static final Http HTTP = new Http();

    private static HTTPResponse sendTransactionRequest(Integer page) {
        //https://api.kb.zc/sandbox/aisp/v1/my/accounts/{id}/transactions{?fromDate,toDate,currency,size,page,sort,order}
        HttpRequest request = new HttpRequest();
        request.setEndpoint(
            'callout:KB_API/accounts/' +
            ACCOUNT_ID +
            '/transactions?fromDate=' +
            FROM_DATE +
            '&toDate=' +
            TO_DATE +
            '&page=' +
            page +
            '&size=' +
            10000
        );
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json');
        return HTTP.send(request);
    }

    private static List<Payment__c> createPayments(List<Transaction2> transactions) {
        List<Payment__c> payments = new List<Payment__c>();

        for (Transaction2 transaction2 : transactions) {
            Payment__c payment = new Payment__c();
            payment.Ammount__c = transaction2.amount.amount;
            payment.CurrencyIsoCode = transaction2.amount.currency2;
            payment.Counterparty_account_name__c = transaction2.entryDetails.transactionDetails.relatedParties.creditorAccount.identification.name;
            payment.Counterparty_account_number__c = transaction2.entryDetails.transactionDetails.relatedParties.creditorAccount.identification.iban;
            payment.Description__c = transaction2.entryDetails.transactionDetails.additionalTransactionInformation;
            payment.Payment_Date__c = transaction2.valueDate.date2;
            payment.Sum__c = transaction2.amount.amount;
            for (String ref : transaction2.entryDetails.transactionDetails.remittanceInformation.structured.creditorReferenceInformation.reference) {
                if (ref?.contains('SS')) {
                    payment.Specific_symbol__c = ref.split(':')[1];
                } else if (ref?.contains('VS')) {
                    payment.Variable_Symbol__c = ref.split(':')[1];
                }
            }
            payments.add(payment);
        }
        return payments;
    }

    @InvocableMethod(label='Create Payments FROM KB Transactions')
    public static void getAccountTransactions() {
        List<Payment__c> payments = new List<Payment__c>();
        Integer page = 0;
        Integer pageCount;
        do {
            HTTPResponse httpResponse = sendTransactionRequest(page);
            Response response;
            String jsonString = httpResponse.getBody();
            System.debug(jsonString);
            if (httpResponse.getStatusCode() == 200) {
                //replace reserved words
                jsonString = jsonString.replace('currency', 'currency2');
                jsonString = jsonString.replace('date', 'date2');

                response = (Response) JSON.deserialize(jsonString, Response.class);
                payments.addAll(createPayments(response.transactions));
            } else {
                //log an error
                System.debug(jsonString);
                return;
            }

            if (page == 0) {
                pageCount = response.pageCount;
            }
            page++;
        } while (page < pageCount);

        if (!payments.isEmpty() && Schema.sObjectType.Payment__c.isCreateable()) {
            insert payments;
        }
    }

    public class Response {
        public Integer pageNumber;
        public Integer pageCount;
        public Integer pageSize;
        public List<Transaction2> transactions;
    }

    public class Transaction2 {
        public Amount amount;
        public String creditDebitIndicator;
        public BookingDate bookingDate;
        public ValueDate valueDate;
        public BankTransactionCode bankTransactionCode;
        public EntryDetails entryDetails;
    }

    public class Amount {
        public Decimal amount;
        public String currency2;
    }

    public class BookingDate {
        public Datetime date2;
    }

    public class ValueDate {
        public Datetime date2;
    }

    public class BankTransactionCode {
        public ProprietaryCode proprietary;
    }

    public class ProprietaryCode {
        public String code;
        public String issuer;
    }

    public class EntryDetails {
        public TransactionDetails transactionDetails;
    }

    public class TransactionDetails {
        //public References references;
        public InstructedAmount instructedAmount;
        public CounterValueAmount counterValueAmount;
        public CurrencyExchange currencyExchange;
        public RelatedParties relatedParties;
        public RelatedAgents relatedAgents;
        public RemittanceInformation remittanceInformation;
        public String additionalTransactionInformation;
    }

    /*public class References {
        public String paymentInformationIdentification;
        public String endToEndIdentification;
    }*/

    public class InstructedAmount {
        public Decimal amount;
        public String currency2;
    }

    public class CounterValueAmount {
        public String currency2;
        public Decimal amount;
    }

    public class CurrencyExchange {
        public String sourceCurrency;
        public ExchangeRate exchangeRate;
    }

    public class ExchangeRate {
    }

    public class RelatedParties {
        public CreditorAccount creditorAccount;
    }

    public class CreditorAccount {
        public Identification identification;
    }

    public class Identification {
        public String name;
        public String iban;
    }

    public class RelatedAgents {
        public CreditorAgent creditorAgent;
    }

    public class CreditorAgent {
        public FinancialInstitutionIdentification financialInstitutionIdentification;
    }

    public class FinancialInstitutionIdentification {
        public String bic;
        public ClearingSystemMemberIdentification clearingSystemMemberIdentification;
    }

    public class ClearingSystemMemberIdentification {
        public String memberIdentification;
    }

    public class RemittanceInformation {
        public Structured structured;
    }

    public class Structured {
        public CreditorReferenceInformation creditorReferenceInformation;
    }

    public class CreditorReferenceInformation {
        public List<String> reference;
    }
}