@IsTest
public class KBAuthProviderTest {
    private static final String PROVIDER = 'KBAuthProvider';
    private static final String CODE = 'testCode';
    private static final String OAUTH_TOKEN = 'testToken';
    private static final String REFRESH_TOKEN = 'refreshToken';
    private static final String REDIRECT_URI = 'http://localhost/services/authcallback/orgId/KBAuthProvider';
    private static final String KEY = 'testKey';
    private static final String SECRET = 'testSecret';
    private static final String STATE_TO_PROPOGATE = 'testState';
    private static final String ACCESS_TOKEN_URL = 'http://www.dummy.com/token';
    private static final String AUTH_URL = 'http://www.dummy.com/authfe';
    private static final String CM_API_NAME = 'KB_API_Setting__mdt';

    // in the real world scenario , the key and value would be read from the (custom fields in) custom metadata type record
    private static Map<String, String> setupAuthProviderConfig() {
        Map<String, String> authProviderConfiguration = new Map<String, String>();
        authProviderConfiguration.put('Client_Id__c', KEY);
        authProviderConfiguration.put('Authorization_Endpoint_URL__c', AUTH_URL);
        authProviderConfiguration.put('Client_Secret__c', SECRET);
        authProviderConfiguration.put('Token_Endpoint_URL__c', ACCESS_TOKEN_URL);
        authProviderConfiguration.put('Redirect_URI__c', REDIRECT_URI);
        return authProviderConfiguration;
    }

    @IsTest
    static void getCustomMetadataTypeTest() {
        System.assertEquals(CM_API_NAME, new KBAuthProvider().getCustomMetadataType(), 'Unexpected Custom Metadata');
    }

    @IsTest
    static void initiateTest() {
        Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
        KBAuthProvider kbProvider = new KBAuthProvider();

        PageReference expectedUrl = new PageReference(
            authProviderConfiguration.get('Authorization_Endpoint_URL__c') +
            '?client_id=' +
            authProviderConfiguration.get('Client_Id__c') +
            '&scope=aisp&redirect_uri=' +
            authProviderConfiguration.get('Redirect_URI__c') +
            '&response_type=code' +
            '&state=' +
            STATE_TO_PROPOGATE
        );
        PageReference actualUrl = kbProvider.initiate(authProviderConfiguration, STATE_TO_PROPOGATE);
        System.assertEquals(expectedUrl.getUrl(), actualUrl.getUrl(), 'Unexpected Authorization URL');
    }

    @IsTest
    static void handleCallbackTest() {
        Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
        KBAuthProvider kbProvider = new KBAuthProvider();

        Test.setMock(HttpCalloutMock.class, new KBAuthProviderGoodMock());

        Map<String, String> queryParams = new Map<String, String>();
        queryParams.put('code', CODE);
        queryParams.put('state', STATE_TO_PROPOGATE);
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null, null, queryParams);
        Auth.AuthProviderTokenResponse actualAuthProvResponse = kbProvider.handleCallback(authProviderConfiguration, cbState);
        Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse(PROVIDER, OAUTH_TOKEN, REFRESH_TOKEN, STATE_TO_PROPOGATE);

        System.assertEquals(expectedAuthProvResponse.provider, actualAuthProvResponse.provider, 'Unexpected provider');
        System.assertEquals(expectedAuthProvResponse.oauthToken, actualAuthProvResponse.oauthToken, 'Unexpected access token');
        System.assertEquals(expectedAuthProvResponse.oauthSecretOrRefreshToken, actualAuthProvResponse.oauthSecretOrRefreshToken, 'Unexpected refresh roken');
        System.assertEquals(expectedAuthProvResponse.state, actualAuthProvResponse.state, 'Unexpected state');
    }

    @IsTest
    static void refreshTest() {
        Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
        KBAuthProvider kbProvider = new KBAuthProvider();

        Test.setMock(HttpCalloutMock.class, new KBAuthProviderGoodMock());

        Auth.OAuthRefreshResult actualAuthProvResponse = kbProvider.refresh(authProviderConfiguration, REFRESH_TOKEN);
        Auth.OAuthRefreshResult expectedAuthProvResponse = new Auth.OAuthRefreshResult(OAUTH_TOKEN, REFRESH_TOKEN);

        System.assertEquals(expectedAuthProvResponse.accessToken, actualAuthProvResponse.accessToken, 'Unexpected access token');
        System.assertEquals(expectedAuthProvResponse.refreshToken, actualAuthProvResponse.refreshToken, 'Unexpected refresh token');
    }

    @IsTest
    static void getUserInfoTest() {
        Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
        KBAuthProvider kbProvider = new KBAuthProvider();
        Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(PROVIDER, OAUTH_TOKEN, SECRET, STATE_TO_PROPOGATE);
        Auth.UserData actualUserData = kbProvider.getUserInfo(authProviderConfiguration, response);

        System.assertEquals(PROVIDER, actualUserData.provider, 'Unexpected provider');
    }

    public class KBAuthProviderGoodMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            KBAuthProvider.Response response = new KBAuthProvider.Response();
            response.access_token = OAUTH_TOKEN;
            response.refresh_token = REFRESH_TOKEN;
            response.expires_in = 3600;
            response.acr = 5;
            response.token_type = 'Bearer';

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(response));
            res.setStatusCode(200);
            return res;
        }
    }
}