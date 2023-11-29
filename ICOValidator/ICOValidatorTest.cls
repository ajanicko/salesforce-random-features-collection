@IsTest
public class ICOValidatorTest {
    @IsTest
    static void validateTest() {
        String validIco = '255 96  641';

        System.assertEquals(true, ICOValidator.validate(validIco), 'Test ICO should be validated as true.');
    }

    @IsTest
    static void validateNotNumberTest() {
        String validIco = 'FFFFFFFF';

        System.assertEquals(false, ICOValidator.validate(validIco), 'Test ICO should be validated as false.');
    }

    @IsTest
    static void validateBadIcoTest() {
        String validIco = '99999999';

        System.assertEquals(false, ICOValidator.validate(validIco), 'Test ICO should be validated as false.');
    }

    @isTest
    static void validateIcoTest() {
        List<ICOValidator.Requests> requests = new List<ICOValidator.Requests>();
        ICOValidator.Requests request = new ICOValidator.Requests();
        request.ico = '27074358';
        requests.add(request);
        request = new ICOValidator.Requests();
        request.ico = '00000000';
        requests.add(request);

        Test.startTest();
        List<ICOValidator.Response> responseList = ICOValidator.validateIco(requests);
        Test.stopTest();

        System.assertEquals(2, responseList.size(), 'Response should have been returned.');
        System.assertEquals(true, responseList[0].isValid, 'ICO should be valid.');
        System.assertEquals(false, responseList[1].isValid, 'ICO should be invalid.');
    }
}
