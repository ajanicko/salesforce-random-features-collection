global class KBAuthProvider extends Auth.AuthProviderPluginClass {
    private String redirectUri; // use this URL for the endpoint that the authentication provider calls back to for configuration
    private String key;
    private String secret;
    private String authUrl; // application redirection to the Concur website for authentication and authorization
    private String accessTokenUrl; // uri to get the new access token from concur  using the GET verb

    global String getCustomMetadataType() {
        return 'KB_API_Setting__mdt';
    }

    global PageReference initiate(Map<string, string> authProviderConfiguration, String stateToPropagate) {
        authUrl = authProviderConfiguration.get('Authorization_Endpoint_URL__c');
        key = authProviderConfiguration.get('Client_Id__c');
        redirectUri = authProviderConfiguration.get('Redirect_URI__c');
        //URL where we will redirect the user
        String url = authUrl + '?client_id=' + key + '&scope=adaa&redirect_uri=' + redirectUri + '&response_type=code' + '&state=' + stateToPropagate;
        return new PageReference(url);
    }

    global Auth.AuthProviderTokenResponse handleCallback(Map<string, string> authProviderConfiguration, Auth.AuthProviderCallbackState state) {
        //callback after successfull authorization through intiate method
        key = authProviderConfiguration.get('Client_Id__c');
        secret = authProviderConfiguration.get('Client_Secret__c');
        accessTokenUrl = authProviderConfiguration.get('Token_Endpoint_URL__c');
        redirectUri = authProviderConfiguration.get('Redirect_URI__c');
        Map<String, String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');

        HttpRequest req = new HttpRequest();
        req.setClientCertificateName('vase_pokladna');
        req.setEndpoint(accessTokenUrl);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setBody(
            'client_id=' + key +
            '&client_secret=' + secret +
            '&code=' + code +
            '&redirect_uri=' + redirectUri +
            '&grant_type=authorization_code' +
            '&state=' + sfdcState
        );
        Http http = new Http();
        HTTPResponse res = http.send(req);
        Response response = (Response) JSON.deserialize(res.getBody(), Response.class);
        return new Auth.AuthProviderTokenResponse('KBAuthProvider', response.access_token, response.refresh_token, sfdcState);
    }

    global override Auth.OAuthRefreshResult refresh(Map<String,String> authProviderConfiguration, String refreshToken) {
        key = authProviderConfiguration.get('Client_Id__c');
        secret = authProviderConfiguration.get('Client_Secret__c');
        accessTokenUrl = authProviderConfiguration.get('Token_Endpoint_URL__c');

        HttpRequest req = new HttpRequest();
        req.setClientCertificateName('vase_pokladna');
        req.setEndpoint(accessTokenUrl);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setBody(
            'client_id=' + key +
            '&client_secret=' + secret +
            '&grant_type=refresh_token' +
            '&refresh_token=' + refreshToken
        );
        Http http = new Http();
        HTTPResponse res = http.send(req);
        Response response = (Response) JSON.deserialize(res.getBody(), Response.class);
        return new Auth.OAuthRefreshResult(response.access_token, response.refresh_token);
    }

    global Auth.UserData getUserInfo(Map<string, string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) {
        //Here the developer is responsible for constructing an Auth.UserData object
        //KB has no UserInfo endpoint
        return new Auth.UserData(null, null, null, null, null, null, null, null, 'KBAuthProvider', null, null);
    }

    global class Response {
        public Integer expires_in;
        public String token_type;
        public String access_token;
        public String refresh_token;
        public Integer acr;
    }
}