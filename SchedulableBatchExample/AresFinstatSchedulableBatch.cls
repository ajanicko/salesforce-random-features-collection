global class AresFinstatSchedulableBatch implements Database.Batchable<sObject>, schedulable, Database.AllowsCallouts {
    public static final Date TODAY = System.today();
    private List<Error_Log__c> errorLogList = new List<Error_Log__c>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String soqlquery = 'SELECT Company_Registration_Number__c, CompanyRegisterCheckDate__c, BillingCountryCode, VAT__c FROM Account WHERE Company_Registration_Number__c != null ORDER BY CompanyRegisterCheckDate__c ASC';
        return Database.getQueryLocator(soqlquery);
    }

    global void execute(Database.BatchableContext bc, List<Account> accounts) {
        Map<String, Account> accountsMap = new Map<String, Account>();
        List<AresAPI.Requests> aresRequests = new List<AresAPI.Requests>();
        List<FinstatAPI.Request> finstatRequests = new List<FinstatAPI.Request>();
        List<Account> viesAccounts = new List<Account>();
        for (Account acc : accounts) {
            accountsMap.put(acc.Company_Registration_Number__c, acc);
            createApiRequests(acc, aresRequests, finstatRequests, viesAccounts);
        }

        getDataFromApis(aresRequests, finstatRequests, viesAccounts, accountsMap);

        //if we have not updated some Accounts, it means that they are not valid
        for (Account acc : accountsMap.values()) {
            if (acc.CompanyRegisterCheckDate__c != TODAY) {
                acc.CompanyRegisterCheckDate__c = TODAY;
                acc.HasValidCompanyRegister__c = false;
            }
        }
        Database.SaveResult[] srList = Database.update(accountsMap.values(), false);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    System.debug(logginglevel.ERROR, err.getStatusCode() + ': ' + err.getMessage());
                    logError('AresFinstatSchedulableBatch.execute', err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
        if (!this.errorLogList.isEmpty()) {
            insert this.errorLogList;
        }
    }

    global void finish(Database.BatchableContext bc) {
    }

    global void execute(SchedulableContext sc) {
        Database.executebatch(new AresFinstatSchedulableBatch(), 100);
    }

    private void createApiRequests(Account acc, List<AresAPI.Requests> aresRequests, List<FinstatAPI.Request> finstatRequests, List<Account> viesAccounts) {
        if (acc.BillingCountryCode == 'CZ') {
            AresAPI.Requests aresRequest = new AresAPI.Requests();
            aresRequest.ico = acc.Company_Registration_Number__c;
            aresRequests.add(aresRequest);
        } else if (acc.BillingCountryCode == 'SK') {
            FinstatAPI.Request finstatRequest = new FinstatAPI.Request();
            finstatRequest.ico = acc.Company_Registration_Number__c;
            finstatRequests.add(finstatRequest);
        } else if (String.isNotBlank(acc.VAT__c) && (acc.VAT__c.substring(0, 2).isAlpha() || String.isNotBlank(acc.BillingCountryCode))) {
            viesAccounts.add(acc);
        }
    }

    private void getDataFromApis(
        List<AresAPI.Requests> aresRequests,
        List<FinstatAPI.Request> finstatRequests,
        List<Account> viesAccounts,
        Map<String, Account> accountsMap
    ) {
        if (!aresRequests.isEmpty()) {
            List<AresAPI.Response> aresResponseList;
            aresResponseList = AresAPI.getData(aresRequests);
            for (AresAPI.Response aresResponse : aresResponseList) {
                if (aresResponse.statusCode != null && aresResponse.statusCode != 200) {
                    Account removedAcc = accountsMap.remove(aresResponse.ico);
                    logError('AresFinstatSchedulableBatch.getDataFromApis', 'AccountId: ' + removedAcc.Id + ': ' + aresResponse.errorResponseBody);
                } else if (aresResponse.statusCode == 200) {
                    Account accToUpdate = accountsMap.get(aresResponse.ico);
                    if (accToUpdate != null) {
                        updateAresAccount(accToUpdate, aresResponse);
                    }
                }
            }
        }
        if (!finstatRequests.isEmpty()) {
            List<FinstatAPI.Response> finstatResponseList;
            finstatResponseList = FinstatAPI.getData(finstatRequests);
            for (FinstatAPI.Response finstatResponse : finstatResponseList) {
                if (finstatResponse.statusCode != null && finstatResponse.statusCode != 200) {
                    Account removedAcc = accountsMap.remove(finstatResponse.ico);
                    logError('AresFinstatSchedulableBatch.getDataFromApis', 'AccountId: ' + removedAcc.Id + ': ' + finstatResponse.errorResponseBody);
                } else if (finstatResponse.statusCode == 200) {
                    Account accToUpdate = accountsMap.get(finstatResponse.ico);
                    if (accToUpdate != null) {
                        updateFinstatAccount(accToUpdate, finstatResponse);
                    }
                }
            }
        }
        if (!viesAccounts.isEmpty()) {
            ViesSoapAPI.checkVatPort checkVatPort = new ViesSoapAPI.checkVatPort();
            for (Account acc : viesAccounts) {
                String tempCountryCode = acc.VAT__c.substring(0, 2);
                String countryCode = '';
                String vat = '';
                if (tempCountryCode.isAlpha()) {
                    countryCode = tempCountryCode;
                    vat = acc.VAT__c.substring(2);
                } else {
                    countryCode = acc.BillingCountryCode;
                    vat = acc.VAT__c;
                }
                try {
                    updateViesAccount(acc, checkVatPort.checkVat(countryCode, vat));
                } catch (CalloutException e) {
                    //skip accounts that failed, don't do anything to them
                    accountsMap.remove(acc.Company_Registration_Number__c);
                    System.debug(logginglevel.INFO, e.getMessage());
                    logError('AresFinstatSchedulableBatch.getDataFromApis', 'AccountId: ' + acc.Id + ': ' + e.getMessage());
                }
            }
        }
    }

    private void updateAresAccount(Account accForUpdate, AresAPI.Response aresResponse) {
        if (String.isNotBlank(aresResponse.dic)) {
            accForUpdate.VAT__c = aresResponse.dic;
        }
        if (String.isNotBlank(aresResponse.companyName)) {
            accForUpdate.OfficialName__c = aresResponse.companyName;
        }
        if (String.isNotBlank(aresResponse.numberOfEmployees)) {
            accForUpdate.No_of_Employees_Category__c = aresResponse.numberOfEmployees;
        }
        if (String.isNotBlank(aresResponse.legalFormId)) {
            accForUpdate.Legal_Form__c = aresResponse.legalFormId;
        }
        String aresStreet = buildAresStreet(aresResponse);
        if (String.isNotBlank(aresStreet) && String.isNotBlank(aresResponse.psc) && String.isNotBlank(aresResponse.cityName)) {
            accForUpdate.BillingStreet = aresStreet;
            accForUpdate.BillingPostalCode = aresResponse.psc;
            accForUpdate.BillingCity = aresResponse.cityName;
        }
        accForUpdate.CompanyRegisterCheckDate__c = TODAY;
        accForUpdate.HasValidCompanyRegister__c = true;
    }

    private String buildAresStreet(AresAPI.Response aresResponse) {
        String street = '';
        if (String.isNotBlank(aresResponse.streetName)) {
            street += aresResponse.streetName;
            street += ' ';
        }
        street += String.isNotBlank(aresResponse.houseNumber) ? aresResponse.houseNumber : '';
        if (aresResponse.houseNumberType != '1') {
            street += 'e';
        }
        if (String.isNotBlank(aresResponse.houseReferenceNumber)) {
            street += '/' + aresResponse.houseReferenceNumber;
        }
        return street;
    }

    private void updateFinstatAccount(Account accForUpdate, FinstatAPI.Response finstatResponse) {
        if (String.isNotBlank(finstatResponse.icDPH)) {
            accForUpdate.VAT__c = finstatResponse.icDPH;
        }
        if (String.isNotBlank(finstatResponse.name)) {
            accForUpdate.OfficialName__c = finstatResponse.name;
        }
        if (String.isNotBlank(finstatResponse.legalFormText)) {
            accForUpdate.Legal_Form__c = finstatResponse.legalFormText;
        }
        String finstatStreet = buildFinstatStreet(finstatResponse);
        if (String.isNotBlank(finstatStreet) && String.isNotBlank(finstatResponse.zipCode) && String.isNotBlank(finstatResponse.city)) {
            accForUpdate.BillingStreet = finstatStreet;
            accForUpdate.BillingPostalCode = finstatResponse.zipCode;
            accForUpdate.BillingCity = finstatResponse.city;
        }
        accForUpdate.CompanyRegisterCheckDate__c = TODAY;
        accForUpdate.HasValidCompanyRegister__c = true;
    }

    private String buildFinstatStreet(FinstatAPI.Response finstatResponse) {
        String street = '';
        street += finstatResponse.street;
        street += ' ';
        street += finstatResponse.streetNumber;
        return street;
    }

    private void updateViesAccount(Account accForUpdate, ViesSoapAPI.checkVatResponse_element viesResponse) {
        accForUpdate.VIESRegisterCheckDate__c = TODAY;
        accForUpdate.HasValidVATNumber__c = viesResponse.valid;
        /*if (viesResponse.address != '---') {
            accForUpdate.BillingStreet = viesResponse.address;
        }*/
        if (viesResponse.name != '---') {
            accForUpdate.OfficialName__c = viesResponse.name;
        }
    }

    private void logError(String name, String message) {
        Error_Log__c errorLog = new Error_Log__c();
        errorLog.Class_Name__c = name;
        errorLog.Message__c = message;
        errorLogList.add(errorLog);
    }
}
