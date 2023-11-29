public with sharing class BrokerRatesPDFController {
    public List<RateWrapper> wrappedRates { get; set; }
    public String brokerName { get; set; }
    public String formatedDate { get; set; }

    public BrokerRatesPDFController() {
        String stringDate = ApexPages.currentPage().getParameters().get('stringDate')?.escapeHtml4();
        String brokerId = ApexPages.currentPage().getParameters().get('brokerId')?.escapeHtml4();

        this.brokerName = [SELECT Name FROM Account WHERE Id = :brokerId WITH SECURITY_ENFORCED].Name;
        this.formatedDate = Date.valueOf(stringDate).format();

        Map<String, List<BrokerRatesController.LwcResponse>> ratesMap = new Map<String, List<BrokerRatesController.LwcResponse>>();
        for (BrokerRatesController.LwcResponse rate : BrokerRatesController.getCommissionTerms(brokerId, stringDate)) {
            addRateToMap(ratesMap, rate, rate.productCategory);
        }

        wrappedRates = new List<RateWrapper>();
        for (String key : ratesMap.keySet()) {
            RateWrapper rateWrap = new RateWrapper();
            rateWrap.category = key;
            rateWrap.categoryRates = ratesMap.get(key);
            wrappedRates.add(rateWrap);
        }
    }

    private void addRateToMap(Map<String, List<BrokerRatesController.LwcResponse>> ratesMap, BrokerRatesController.LwcResponse rate, String key) {
        if (ratesMap.containsKey(key)) {
            ratesMap.get(key).add(rate);
        } else {
            ratesMap.put(key, new List<BrokerRatesController.LwcResponse>{ rate });
        }
    }

    public class RateWrapper {
        public String category { get; set; }
        public List<BrokerRatesController.LwcResponse> categoryRates { get; set; }
    }
}