public with sharing class ICOValidator {
    @InvocableMethod(label='Validate ICO and return TRUE/FALSE Response')
    public static List<Response> validateIco(List<Requests> requests) {
        List<Response> responseList = new List<Response>();
        for (Requests req : requests) {
            Response response = new Response();
            response.isValid = validate(req.ico);
            responseList.add(response);
        }
        return responseList;
    }

    public static Boolean validate(String ico) {
        //remove whitespace and validate ico is an 8 digit number
        ico = ico.replaceAll('(\\s+)', '');
        Pattern numberPattern = Pattern.compile('^[0-9]{8}$');
        Matcher numberMatcher = numberPattern.matcher(ico);
        if (!numberMatcher.matches()) {
            return false;
        }

        Integer controlSummary = 0;
        for (Integer i = 0; i < 7; i++) {
            controlSummary += Integer.valueOf(ico.substring(i, i + 1)) * (8 - i);
        }

        Integer lastDigit = Integer.valueOf(ico.substring(7, 7 + 1));
        return lastDigit == Math.Mod(11 - Math.Mod(controlSummary, 11), 10);
    }

    public class Requests {
        @InvocableVariable(required=true)
        public String ico;
    }

    public class Response {
        @InvocableVariable
        public Boolean isValid;
    }
}
