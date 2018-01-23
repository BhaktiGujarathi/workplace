@isTest
private class PAW_YearEnd_ControllerTest {

	@testSetup static void setup() {


		Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FRN Facility').getRecordTypeId();
		Account objAcc = new Account(Name = ' AccountTest' , RecordTypeId = devRecordTypeId);
		insert objAcc;

		Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insurance Company').getRecordTypeId();
		Account objAccount = new Account(Name = ' AccountTest2' , RecordTypeId = recordTypeId);
		insert objAccount;

		Opportunity objOpp = new Opportunity( Name = 'testClass',stageName='In Process', CloseDate =  system.Today().addMonths(5));
		insert objOpp;

		Patient_Insurance__c objPatientInsurance = new Patient_Insurance__c(Name = 'testPatient' , Opportunity__c=objOpp.id, Insurance_Company__c = objAccount.id );
     	insert objPatientInsurance;
		System.debug('>>>>>>>> PI >>>>>' +objPatientInsurance);

		
		Insurance_Benefit__c objInsuranceBenefit = new Insurance_Benefit__c(Patient_Insurance__c = objPatientInsurance.id ,
																			Applicable_For_Year__c = '2017' );
		insert objInsuranceBenefit;


		Facility_Program__c objFRNFacility = new Facility_Program__c(Name = 'FRNfacilityTest' , FRN_Facility__c = objAcc.id);
		insert objFRNFacility;

		Pay_Agreement_Worksheet__c objPAyagreement = new Pay_Agreement_Worksheet__c( Patient_Insurance__c = objPatientInsurance.id , Insurance_Benefit__c = objInsuranceBenefit.id ,
																		FRN_Facility__c = objAcc.id , Facility_Program__c = objFRNFacility.id);
		insert objPAyagreement;

		Pay_Agreement_Worksheet__c objPAyagreementSecondary = new Pay_Agreement_Worksheet__c( Patient_Insurance__c = objPatientInsurance.id , Insurance_Benefit__c = objInsuranceBenefit.id ,
																		FRN_Facility__c = objAcc.id , Facility_Program__c = objFRNFacility.id);
		insert objPAyagreementSecondary;

		Insurance_Company_Rate_Adjustment__c objRateAdjustment = PAWTestDataFactory.createRtAdjustmntRecord(
																		objAccount.Id,
																		objAcc.Id);
        insert objRateAdjustment;

		Quote objQuote =  new Quote(Name =objOpp.id , OpportunityId =objOpp.id ,Facility_Program__c= objFRNFacility.id,	FRN_Facility__c=objAcc.id , Insurance_Company__c=objAcc.id ,
									Pay_Agreement_Worksheet__c=objPAyagreement.id , Secondary_Pay_Agreement_Worksheet__c = objPAyagreementSecondary.id);
		insert objQuote;
	}

	@isTest static void PtntInsrnceSelectOptions_testMethod() {
		Opportunity objOppTest = [SELECT Id FROM Opportunity LIMIT 1];
		Patient_Insurance__c objPatientInsuranceTest = [SELECT id FROM Patient_Insurance__c];
	    System.debug('########## PI >>>>>' +objPatientInsuranceTest);
		Test.StartTest();
		PAW_YearEnd_Controller controller = new PAW_YearEnd_Controller();
		controller.oppId = objOppTest.id;
		controller.year = '2017';
		controller.getPtntInsrnceSelectOptions();
		Test.StopTest();

		System.assert(controller.ptntInsrnceSelectOptions.size()!=NULL);
		System.assert(controller.ptntInsrnceSelectOptions.size()==2);
	}

	@isTest static void InsrncBnftSelectOptions_testMethod(){

	//	Opportunity objOppTest = [SELECT Id FROM Opportunity LIMIT 1];
	//	Patient_Insurance__c objPatientInsuranceTest = [SELECT id , Name , Opportunity__c FROM Patient_Insurance__c WHERE Name = 'testPatient1' LIMIT 1];
		Insurance_Benefit__c objInsuranceBenefit = [SELECT Id FROM Insurance_Benefit__c LIMIt 1];

		Test.StartTest();
		PAW_YearEnd_Controller controller = new PAW_YearEnd_Controller();
		//controller.oppId = objOppTest.id;
		controller.year = '2017';
		controller.getInsrncBnftSelectOptions();
		System.debug('???????????????????'+controller.insrncBnftSelectOptions.size());
		Test.StopTest();

		System.assert(controller.insrncBnftSelectOptions.size()!=0);

	}

	@isTest static void RecordId_testMethod() {

		Opportunity objOppTest = [SELECT Id FROM Opportunity LIMIT 1];

		Test.StartTest();
		PAW_YearEnd_Controller controller = new PAW_YearEnd_Controller();
		controller.setRecordId(objOppTest.id);
		Test.StopTest();

		System.assert(controller.recordId == objOppTest.id);
	}

	@isTest static void IsPrimary_testMethod() {

		Boolean Primary = True;

		Test.StartTest();
		PAW_YearEnd_Controller controller = new PAW_YearEnd_Controller();
		controller.setIsPrimary(Primary);
		Test.StopTest();

		System.assert(controller.isPrimary == Primary);
	}

	@isTest static void Year_testMethod() {

		String yearParam = '2017';

		Test.StartTest();
		PAW_YearEnd_Controller controller = new PAW_YearEnd_Controller();
		controller.setYear(yearParam);
		Test.StopTest();

		System.assert(controller.year == yearParam);
	}

	@isTest static void init_testMethod() {

		Test.StartTest();
		PAW_YearEnd_Controller controller = new PAW_YearEnd_Controller();
		controller.init();
		Test.StopTest();
	}

	@isTest static void MetaData_testMethod() {

		Boolean Primary = True;
		PAW_Editor_YearEndController.MetaData metaParam = new PAW_Editor_YearEndController.MetaData();

		Test.StartTest();
		PAW_YearEnd_Controller controller = new PAW_YearEnd_Controller();
		controller.setIsPrimary(Primary);
		controller.setMetaData(metaParam);
		Test.StopTest();
	}

	@isTest static void CurrentPAWId_testMethod() {

		Quote objQuoteTest = [SELECT Id , Pay_Agreement_Worksheet__c , Secondary_Pay_Agreement_Worksheet__c FROM Quote LIMIT 1];

		Test.StartTest();
		PAW_YearEnd_Controller controller = new PAW_YearEnd_Controller();
		controller.getCurrentPAWId(objQuoteTest);
		Test.StopTest();

	}

	@isTest static void createDetailRecordsForPAW_testMethod() {

		Boolean Primary = True;

		Test.StartTest();
		PAW_YearEnd_Controller controller = new PAW_YearEnd_Controller();
		controller.setIsPrimary(Primary);
		controller.createDetailRecordsForPAW();
		Test.StopTest();

		System.assert(controller.wrprObj.pyAgrmntWrksht.Ancillary_Fees__c != 0.00);
	}

	@isTest static void savePAWRecords_testMethod() {

		Opportunity oppObj = [Select id from Opportunity Limit 1];
		Account Acc = [Select id From Account where Name = 'AccountTest' LIMIT 1];
		/*Patient_Insurance__c objPatientInsTest = [SELECT id FROM Patient_Insurance__c LIMIT 1];
		Facility_Program__c objFRNFacilityTest = [SELECT id FROM Facility_Program__c LIMIT 1];
		Insurance_Company_Rate_Adjustment__c objRateAdjustmentTest = [SELECT id FROM Insurance_Company_Rate_Adjustment__c LIMIT 1];*/
		Test.setCurrentPageReference(new PageReference('Page.PAW_Editor_YearEnd'));
		ApexPages.currentPage().getParameters().put('id', oppObj.Id);


		Test.startTest();
			PAW_YearEnd_Controller cntrllrObj = new PAW_YearEnd_Controller();

			cntrllrObj.setYear('2017');
			cntrllrObj.oppId = oppObj.id;
			System.debug('#######year'+cntrllrObj.year);
			System.debug('#######year'+cntrllrObj.oppId);
            cntrllrObj.getPtntInsrnceSelectOptions();
            system.debug('>>> cntrllrObj.ptntInsrnceSelectOptions : '+cntrllrObj.ptntInsrnceSelectOptions[1]);
            system.debug('>>> cntrllrObj.ptntInsrnceSelectOptions.Insurance_Benefits__r : '+[Select id, Opportunity__c, (select id, name, Applicable_For_Year__c from Insurance_Benefits__r) from Patient_Insurance__c LIMIT 1].Insurance_Benefits__r);
            cntrllrObj.wrprObj.pyAgrmntWrksht.Patient_Insurance__c = cntrllrObj.ptntInsrnceSelectOptions[1].getValue();
            cntrllrObj.onPatientSelection();
            cntrllrObj.getInsrncBnftSelectOptions();
            cntrllrObj.wrprObj.insrncBnftSelected = cntrllrObj.insrncBnftSelectOptions[1].getValue();
            cntrllrObj.onBenefitSelection();
            cntrllrObj.wrprObj.facilitySelected =Acc.Id;
            cntrllrObj.onFacilitySelection();
            cntrllrObj.wrprObj.fcltyPrgrmSelected = cntrllrObj.fcltyPrgrmOptions[1].getValue();
            cntrllrObj.getRtAdjstmntOptions();
            cntrllrObj.wrprObj.rateAdjstmntSelected = cntrllrObj.rtAdjstmntOptions[1].getValue();
            cntrllrObj.updateWraperValues();
            cntrllrObj.createAndUpdatePAWDetailsRecords();
            system.debug('>>>2 cntrllrObj.wrprObj.insrncBnftSelected : '+cntrllrObj.wrprObj.insrncBnftSelected);
            system.debug('>>>2 cntrllrObj.wrprObj.facilitySelected : '+cntrllrObj.wrprObj.facilitySelected );
            system.debug('>>>2 cntrllrObj.wrprObj.fcltyPrgrmSelected : '+cntrllrObj.wrprObj.fcltyPrgrmSelected );
            cntrllrObj.savePAWRecords();
        Test.stopTest();

		System.assert(PAWValueCalculationService.pawObj != null);
	}
}