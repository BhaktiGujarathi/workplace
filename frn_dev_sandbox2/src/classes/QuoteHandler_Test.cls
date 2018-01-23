@isTest
public class QuoteHandler_Test {
     Static testMethod void QuoteHandlerController_Test()
        {
            Year_End_PAW_Settings__c objCustomSetting = new Year_End_PAW_Settings__c();
    		objCustomSetting.Year_End_Mode_Enabled__c = true;
    		insert objCustomSetting;

            Default_Pricebook__c pricebookName = new Default_Pricebook__c(Name = 'FRN Price Book',Default_Pricebook_Name__c = 'FRN Price Book');
            insert pricebookName;

            Pricebook2 prod = new Pricebook2(Name = pricebookName.Default_Pricebook_Name__c);
            insert prod;

            Account acc = new Account();
            acc.Name = 'test';
            insert acc;

            Contact con = new Contact();
            con.LastName = 'test';
            con.AccountId = acc.Id;
            con.Social_Security_Number__c = 'test#';
            insert con;

            Opportunity opp = new Opportunity();
            opp.StageName = 'Prospecting';
            opp.Name = 'test';
            opp.Have_You_Attended_Anger_Mgmt_Class__c = 'Yes';
            opp.CloseDate = System.today();
            insert opp;


            Insurance_Company_Rate_Adjustment__c Inscomp = new Insurance_Company_Rate_Adjustment__c();
            Inscomp.FRN_Facility__c = acc.Id;
            Inscomp.Insurance_Company__c = acc.Id;
            Inscomp.Contract_Type__c = 'In Network';
            insert Inscomp;
            Inscomp.In_Network_Rate_Adjustment__c = 18;
            update Inscomp;


            Patient_Insurance__c pi = new Patient_Insurance__c(Name = 'Test',
                                                               Patient__c = con.id, 
                                                               Opportunity__c = opp.id,
                                                               Patient_Social_Security_Number__c = 'Test',
                                                               Insurance_Company__c = Acc.id ,
                                                               COBRA_Account__c = 'Yes',
                                                               Accepts_Assignment_of_Benefits__c = 'No',
                                                               ACA_Policy__c = 'Yes');
            insert pi;

            Patient_Insurance__c ptntInsrnc = new Patient_Insurance__c(Name = 'Test',
                                                               Patient__c = con.id, 
                                                               Opportunity__c = opp.id,
                                                               Patient_Social_Security_Number__c = 'Test',
                                                               Insurance_Company__c = Acc.id ,
                                                               COBRA_Account__c = 'Yes',
                                                               Accepts_Assignment_of_Benefits__c = 'Yes',
                                                               ACA_Policy__c = 'Yes');
            insert ptntInsrnc;

            Insurance_Benefit__c ib = new Insurance_Benefit__c(Patient_Insurance__c=pi.id,
                                                               Disposition__c = 'Benefits Available',
                                                               Physician_Fees_Covered_Same__c = 'Yes',
                                                               Professional_Outpatient_Covered_Same__c = 'No',
                                                               Applicable_For_Year__c='2017');
            insert ib;

            Insurance_Benefit__c ib1 = new Insurance_Benefit__c(Patient_Insurance__c=pi.id, 
                                                                Disposition__c = 'Policy Termed' ,
                                                                Applicable_For_Year__c='2017');
            insert ib1;

            Insurance_Benefit__c insrncBnft = new Insurance_Benefit__c(Patient_Insurance__c=ptntInsrnc.id, 
                                                                Disposition__c = 'Unable to Verify Benefits',
                                                                Applicable_For_Year__c='2018');
            insert insrncBnft;


            Facility_Program__c fp = new Facility_Program__c(Name = 'test',
                                                             FRN_Facility__c = acc.id);
            insert fp;

            Facility_Program_Determination_Script__c fpds = new Facility_Program_Determination_Script__c(
                                                            Determination_Script__c = '{Co_Pay__c} and {Co_Pay__c.}',
                                                            Facility_Program__c = fp.id,
                                                            Contract_Type__c = 'In Network',
                                                            Assignment_of_Benefits_Script__c = 'test',
                                                            ACA_Policy_Script__c = 'test');
            insert fpds;

            Trip__c tp = new Trip__c(Patient__c = con.id, 
                                     Opportunity__c = opp.id);
            insert tp;

            Id RecRTId = Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Airfare').getRecordTypeId();
            Reservation__c rc = new Reservation__c(RecordTypeID = RecRTId, 
                                                   Trip__c = tp.id, 
                                                   Rate__c = 10,
                                                   Total_Amount_Charged__c = 20);
            insert rc;
            Reservation__c rc1 = new Reservation__c(RecordTypeID = RecRTId, 
                                                    Trip__c = tp.id,
                                                    Rate__c = 10,
                                                    Total_Amount_Charged__c = 20);
            insert rc1;

            Product2 p2 = new Product2(Auto_Add_to_Quote_Line_Items__c = true, 
                                       Name = 'Car Service',
                                       Family = 'Insurance Cost');
            insert p2;

            Product2 prdct = new Product2(Auto_Add_to_Quote_Line_Items__c = true, 
                                       Name = 'Amount Request',
                                       Family = 'Insurance Cost');
            insert prdct;

            Id pbId = Test.getStandardPricebookId();
            PricebookEntry pbe = new PricebookEntry(Pricebook2id=pbId,
                                                    Product2id=p2.Id,
                                                    unitprice=10,
                                                    isActive=true);
            insert pbe;
            System.debug('prod ::>'+prod);
            PricebookEntry pbe1 = new PricebookEntry(Pricebook2id=prod.Id,
                                                     Product2id=p2.Id,
                                                     unitprice=1.0,
                                                     isActive=true);
            insert pbe1;

            PricebookEntry pbe2 = new PricebookEntry(Pricebook2id=pbId,
                                                    Product2id=prdct.Id,
                                                    unitprice=10,
                                                    isActive=true);
            insert pbe2;
            System.debug('prod ::>'+prod);
            PricebookEntry pbe3 = new PricebookEntry(Pricebook2id=prod.Id,
                                                     Product2id=prdct.Id,
                                                     unitprice=1.0,
                                                     isActive=true);
            insert pbe3;

            Pay_Agreement_Worksheet__c paw = new Pay_Agreement_Worksheet__c(Opportunity__c = opp.id,
                                                                            Insurance_Benefit__c=ib.id);
            insert paw;

            Pay_Agreement_Worksheet__c pawSec = new Pay_Agreement_Worksheet__c(Opportunity__c = opp.id,
                                                                               Insurance_Benefit__c=insrncBnft.id,
                                                                               Patient_Insurance__c = ptntInsrnc.Id);
            insert pawSec;
            paw.Related_Pay_Agreement_Worksheet__c = pawSec.Id;
            update paw;
            pawSec.Related_Pay_Agreement_Worksheet__c = paw.Id;
            update pawSec;

            Determination_Script_Component__c dsc = new Determination_Script_Component__c(
                                                                  Script__c='Test {Quote.Name}',
                                                                  Type__c='Aggression');
            insert dsc;

            Determination_Script_Component__c dsc1 = new Determination_Script_Component__c(
                                                                  Script__c='Test {Quote.Name}',
                                                                  Type__c='Weekend/Weeknight Determination');
            insert dsc1;

            Determination_Script_Component__c dsc2 = new Determination_Script_Component__c(
                                                                  Script__c='Test {Quote.Name}',
                                                                  Type__c='Medical records');
            insert dsc2;

            Determination_Script_Component__c dsc3 = new Determination_Script_Component__c(
                                                                  Script__c='Test {Quote.Name}',
                                                                  Type__c='High acuity');
            insert dsc3;

            Determination_Script_Component__c dsc4 = new Determination_Script_Component__c(
                                                                  Script__c='Test {Quote.Name}',
                                                                  Type__c='Professional Coverage');
            insert dsc4;

            Determination_Script_Component__c dsc5 = new Determination_Script_Component__c(
                                                                  Script__c='Test {Quote.Name}',
                                                                  Type__c='Physician Fees');
            insert dsc5;

            Quote quo = new Quote();
            quo.Name = 'test';
            quo.opportunityId = opp.Id;
            quo.FRN_Facility__c = acc.Id;
            quo.Insurance_Company__c = acc.Id;
            quo.Facility_Program__c = fp.Id;
            quo.Pay_Agreement_Worksheet__c = paw.Id;
            quo.Insurance_Company_Contract_Type__c = 'In Network';
            quo.Secondary_Pay_Agreement_Worksheet__c = pawSec.Id;
            //quo.Secondary_Insurance_Company_Name__c = acc.Id;
            insert quo;
            update quo;



            ApexPages.StandardController sc2 = new ApexPages.StandardController(quo);
            QuoteHandler Qh = new QuoteHandler();
        }
}