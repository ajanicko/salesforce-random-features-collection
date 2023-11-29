@isTest
public class AresStandardAPITest {
    private static final String FAKE_RESPONSE_XML =
        '<are:Ares_odpovedi xmlns:are="http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_answer/v_1.0.1" xmlns:dtt="http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_datatypes/v_1.0.4" xmlns:udt="http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/uvis_datatypes/v_1.0.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" odpoved_datum_cas="2022-11-24T11:10:02" odpoved_pocet="1" odpoved_typ="Standard" vystup_format="XML" xslt="klient" validation_XSLT="/ares/xml_doc/schemas/ares/ares_answer/v_1.0.0/ares_answer.xsl" xsi:schemaLocation="http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_answer/v_1.0.1 http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_answer/v_1.0.1/ares_answer_v_1.0.1.xsd" Id="ares"> ' +
        '<are:Odpoved> ' +
        '<are:Pocet_zaznamu>3</are:Pocet_zaznamu> ' +
        '<are:Typ_vyhledani>FREE</are:Typ_vyhledani> ' +
        '<are:Zaznam> ' +
        '<are:Shoda_OF> ' +
        '<dtt:Kod>7</dtt:Kod> ' +
        '</are:Shoda_OF> ' +
        '<are:Vyhledano_dle>OF</are:Vyhledano_dle> ' +
        '<are:Typ_registru> ' +
        '<dtt:Kod>2</dtt:Kod> ' +
        '<dtt:Text>OR</dtt:Text> ' +
        '</are:Typ_registru> ' +
        '<are:Datum_vzniku>2003-08-06</are:Datum_vzniku> ' +
        '<are:Datum_platnosti>2022-11-24</are:Datum_platnosti> ' +
        '<are:Pravni_forma> ' +
        '<dtt:Kod_PF>121</dtt:Kod_PF> ' +
        '</are:Pravni_forma> ' +
        '<are:Obchodni_firma>Asseco Central Europe, a.s.</are:Obchodni_firma> ' +
        '<are:ICO>27074358</are:ICO> ' +
        '<are:Identifikace> ' +
        '<are:Adresa_ARES> ' +
        '<dtt:ID_adresy>212824308</dtt:ID_adresy> ' +
        '<dtt:Kod_statu>203</dtt:Kod_statu> ' +
        '<dtt:Nazev_okresu>Hlavní město Praha</dtt:Nazev_okresu> ' +
        '<dtt:Nazev_obce>Praha</dtt:Nazev_obce> ' +
        '<dtt:Nazev_casti_obce>Michle</dtt:Nazev_casti_obce> ' +
        '<dtt:Nazev_mestske_casti>Praha 4</dtt:Nazev_mestske_casti> ' +
        '<dtt:Nazev_ulice>Budějovická</dtt:Nazev_ulice> ' +
        '<dtt:Cislo_domovni>778</dtt:Cislo_domovni> ' +
        '<dtt:Typ_cislo_domovni>1</dtt:Typ_cislo_domovni> ' +
        '<dtt:Cislo_orientacni>3a</dtt:Cislo_orientacni> ' +
        '<dtt:PSC>14000</dtt:PSC> ' +
        '<dtt:Adresa_UIR> ' +
        '<udt:Kod_oblasti>19</udt:Kod_oblasti> ' +
        '<udt:Kod_kraje>19</udt:Kod_kraje> ' +
        '<udt:Kod_okresu>3100</udt:Kod_okresu> ' +
        '<udt:Kod_obce>554782</udt:Kod_obce> ' +
        '<udt:Kod_pobvod>43</udt:Kod_pobvod> ' +
        '<udt:Kod_nobvod>43</udt:Kod_nobvod> ' +
        '<udt:Kod_casti_obce>490130</udt:Kod_casti_obce> ' +
        '<udt:Kod_mestske_casti>500119</udt:Kod_mestske_casti> ' +
        '<udt:PSC>14000</udt:PSC> ' +
        '<udt:Kod_ulice>444375</udt:Kod_ulice> ' +
        '<udt:Cislo_domovni>778</udt:Cislo_domovni> ' +
        '<udt:Typ_cislo_domovni>1</udt:Typ_cislo_domovni> ' +
        '<udt:Cislo_orientacni>3</udt:Cislo_orientacni> ' +
        '<udt:Pism_cislo_orientacni>a</udt:Pism_cislo_orientacni> ' +
        '<udt:Kod_adresy>41405609</udt:Kod_adresy> ' +
        '<udt:Kod_objektu>21770794</udt:Kod_objektu> ' +
        '</dtt:Adresa_UIR> ' +
        '</are:Adresa_ARES> ' +
        '</are:Identifikace> ' +
        '<are:Kod_FU>4</are:Kod_FU> ' +
        '<are:Priznaky_subjektu>NAAANANNNNANNNNNNNNNPNNNANNNNN</are:Priznaky_subjektu> ' +
        '</are:Zaznam> ' +
        '<are:Zaznam> ' +
        '<are:Shoda_OF> ' +
        '<dtt:Kod>7</dtt:Kod> ' +
        '</are:Shoda_OF> ' +
        '<are:Vyhledano_dle>OF</are:Vyhledano_dle> ' +
        '<are:Typ_registru> ' +
        '<dtt:Kod>2</dtt:Kod> ' +
        '<dtt:Text>OR</dtt:Text> ' +
        '</are:Typ_registru> ' +
        '<are:Datum_vzniku>2004-03-03</are:Datum_vzniku> ' +
        '<are:Datum_platnosti>2022-11-24</are:Datum_platnosti> ' +
        '<are:Pravni_forma> ' +
        '<dtt:Kod_PF>421</dtt:Kod_PF> ' +
        '</are:Pravni_forma> ' +
        '<are:Obchodni_firma>Asseco Central Europe,a.s., organizační složka</are:Obchodni_firma> ' +
        '<are:ICO>27123707</are:ICO> ' +
        '<are:Identifikace> ' +
        '<are:Adresa_ARES> ' +
        '<dtt:ID_adresy>212750689</dtt:ID_adresy> ' +
        '<dtt:Kod_statu>203</dtt:Kod_statu> ' +
        '<dtt:Nazev_okresu>Hlavní město Praha</dtt:Nazev_okresu> ' +
        '<dtt:Nazev_obce>Praha</dtt:Nazev_obce> ' +
        '<dtt:Nazev_casti_obce>Michle</dtt:Nazev_casti_obce> ' +
        '<dtt:Nazev_mestske_casti>Praha 4</dtt:Nazev_mestske_casti> ' +
        '<dtt:Nazev_ulice>Budějovická</dtt:Nazev_ulice> ' +
        '<dtt:Cislo_domovni>778</dtt:Cislo_domovni> ' +
        '<dtt:Typ_cislo_domovni>1</dtt:Typ_cislo_domovni> ' +
        '<dtt:Cislo_orientacni>3a</dtt:Cislo_orientacni> ' +
        '<dtt:PSC>14000</dtt:PSC> ' +
        '<dtt:Adresa_UIR> ' +
        '<udt:Kod_oblasti>19</udt:Kod_oblasti> ' +
        '<udt:Kod_kraje>19</udt:Kod_kraje> ' +
        '<udt:Kod_okresu>3100</udt:Kod_okresu> ' +
        '<udt:Kod_obce>554782</udt:Kod_obce> ' +
        '<udt:Kod_pobvod>43</udt:Kod_pobvod> ' +
        '<udt:Kod_nobvod>43</udt:Kod_nobvod> ' +
        '<udt:Kod_casti_obce>490130</udt:Kod_casti_obce> ' +
        '<udt:Kod_mestske_casti>500119</udt:Kod_mestske_casti> ' +
        '<udt:PSC>14000</udt:PSC> ' +
        '<udt:Kod_ulice>444375</udt:Kod_ulice> ' +
        '<udt:Cislo_domovni>778</udt:Cislo_domovni> ' +
        '<udt:Typ_cislo_domovni>1</udt:Typ_cislo_domovni> ' +
        '<udt:Cislo_orientacni>3</udt:Cislo_orientacni> ' +
        '<udt:Pism_cislo_orientacni>a</udt:Pism_cislo_orientacni> ' +
        '<udt:Kod_adresy>41405609</udt:Kod_adresy> ' +
        '<udt:Kod_objektu>21770794</udt:Kod_objektu> ' +
        '</dtt:Adresa_UIR> ' +
        '</are:Adresa_ARES> ' +
        '</are:Identifikace> ' +
        '<are:Kod_FU>4</are:Kod_FU> ' +
        '<are:Priznaky_subjektu>NAAANANNNNNNNNNNNNNNNNNNANNNNN</are:Priznaky_subjektu> ' +
        '</are:Zaznam> ' +
        '<are:Zaznam> ' +
        '<are:Shoda_OF> ' +
        '<dtt:Kod>7</dtt:Kod> ' +
        '</are:Shoda_OF> ' +
        '<are:Vyhledano_dle>OF</are:Vyhledano_dle> ' +
        '<are:Typ_registru> ' +
        '<dtt:Kod>2</dtt:Kod> ' +
        '<dtt:Text>OR</dtt:Text> ' +
        '</are:Typ_registru> ' +
        '<are:Datum_vzniku>1996-03-05</are:Datum_vzniku> ' +
        '<are:Datum_platnosti>2022-11-24</are:Datum_platnosti> ' +
        '<are:Pravni_forma> ' +
        '<dtt:Kod_PF>121</dtt:Kod_PF> ' +
        '</are:Pravni_forma> ' +
        '<are:Obchodni_firma>Asseco Solutions, a.s.</are:Obchodni_firma> ' +
        '<are:ICO>64949541</are:ICO> ' +
        '<are:Identifikace> ' +
        '<are:Adresa_ARES> ' +
        '<dtt:ID_adresy>211643432</dtt:ID_adresy> ' +
        '<dtt:Kod_statu>203</dtt:Kod_statu> ' +
        '<dtt:Nazev_okresu>Hlavní město Praha</dtt:Nazev_okresu> ' +
        '<dtt:Nazev_obce>Praha</dtt:Nazev_obce> ' +
        '<dtt:Nazev_casti_obce>Braník</dtt:Nazev_casti_obce> ' +
        '<dtt:Nazev_mestske_casti>Praha 4</dtt:Nazev_mestske_casti> ' +
        '<dtt:Nazev_ulice>Zelený pruh</dtt:Nazev_ulice> ' +
        '<dtt:Cislo_domovni>1560</dtt:Cislo_domovni> ' +
        '<dtt:Typ_cislo_domovni>1</dtt:Typ_cislo_domovni> ' +
        '<dtt:Cislo_orientacni>99</dtt:Cislo_orientacni> ' +
        '<dtt:PSC>14000</dtt:PSC> ' +
        '<dtt:Adresa_UIR> ' +
        '<udt:Kod_oblasti>19</udt:Kod_oblasti> ' +
        '<udt:Kod_kraje>19</udt:Kod_kraje> ' +
        '<udt:Kod_okresu>3100</udt:Kod_okresu> ' +
        '<udt:Kod_obce>554782</udt:Kod_obce> ' +
        '<udt:Kod_pobvod>43</udt:Kod_pobvod> ' +
        '<udt:Kod_nobvod>43</udt:Kod_nobvod> ' +
        '<udt:Kod_casti_obce>400203</udt:Kod_casti_obce> ' +
        '<udt:Kod_mestske_casti>500119</udt:Kod_mestske_casti> ' +
        '<udt:PSC>14000</udt:PSC> ' +
        '<udt:Kod_ulice>479896</udt:Kod_ulice> ' +
        '<udt:Cislo_domovni>1560</udt:Cislo_domovni> ' +
        '<udt:Typ_cislo_domovni>1</udt:Typ_cislo_domovni> ' +
        '<udt:Cislo_orientacni>99</udt:Cislo_orientacni> ' +
        '<udt:Kod_adresy>21812721</udt:Kod_adresy> ' +
        '<udt:Kod_objektu>21815305</udt:Kod_objektu> ' +
        '</dtt:Adresa_UIR> ' +
        '</are:Adresa_ARES> ' +
        '</are:Identifikace> ' +
        '<are:Kod_FU>4</are:Kod_FU> ' +
        '<are:Priznaky_subjektu>NAAANANANNANNNNNNNNNPNNNANNNNN</are:Priznaky_subjektu> ' +
        '</are:Zaznam> ' +
        '</are:Odpoved> ' +
        '</are:Ares_odpovedi>';

    public class GoodMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(FAKE_RESPONSE_XML);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void getDataGood() {
        Test.setMock(HttpCalloutMock.class, new GoodMock());
        List<AresStandardAPI.Request> requests = new List<AresStandardAPI.Request>();
        AresStandardAPI.Request request = new AresStandardAPI.Request();
        request.companyName = 'Asseco';
        requests.add(request);

        Test.startTest();
        List<AresStandardAPI.Response> responseList = AresStandardAPI.getData(requests);
        Test.stopTest();

        System.assertEquals(1, responseList.size(), 'Response should have been returned.');
        System.assertEquals(3, responseList[0].matchList.size(), 'Match List should have been populated.');
        for (AresStandardAPIMatch match : responseList[0].matchList) {
            if (match.companyName == 'Asseco Central Europe, a.s.') {
                System.assertEquals('27074358', match.ico, 'ICO should be paired to the correct company.');
            } else if (match.companyName == 'Asseco Central Europe,a.s., organizační složka') {
                System.assertEquals('27123707', match.ico, 'ICO should be paired to the correct company.');
            } else {
                //Asseco Solutions, a.s.
                System.assertEquals('64949541', match.ico, 'ICO should be paired to the correct company.');
            }
        }
    }
}
