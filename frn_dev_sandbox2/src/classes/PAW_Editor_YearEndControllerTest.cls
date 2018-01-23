@isTest
private class PAW_Editor_YearEndControllerTest {

	@testSetup static void setup() {
		PAW_Editor_YearEndController.MetaData meta = new PAW_Editor_YearEndController.MetaData();

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

		Insurance_Benefit__c objInsuranceBenefit = new Insurance_Benefit__c(Patient_Insurance__c = objPatientInsurance.id , Applicable_For_Year__c = '2017' );
		insert objInsuranceBenefit;

		Insurance_Benefit__c objInsuranceBenefitSecondary = new Insurance_Benefit__c(Patient_Insurance__c = objPatientInsurance.id , Applicable_For_Year__c = '2018' );
		insert objInsuranceBenefitSecondary;

		Facility_Program__c objFRNFacility = new Facility_Program__c(Name = 'FRNfacilityTest' , FRN_Facility__c = objAcc.id);
		insert objFRNFacility;

		Pay_Agreement_Worksheet__c objPAyagreement = new Pay_Agreement_Worksheet__c( Patient_Insurance__c = objPatientInsurance.id , Insurance_Benefit__c = objInsuranceBenefit.id ,
																					 FRN_Facility__c = objAcc.id , Facility_Program__c = objFRNFacility.id);
		insert objPAyagreement;

		Pay_Agreement_Worksheet__c objPAyagreementSecondary = new Pay_Agreement_Worksheet__c( Patient_Insurance__c = objPatientInsurance.id , Insurance_Benefit__c = objInsuranceBenefitSecondary.id ,
																							  FRN_Facility__c = objAcc.id , Facility_Program__c = objFRNFacility.id , Related_Pay_Agreement_Worksheet__c =objPAyagreement.id,
																							  Total_Patient_Contribution__c = 1000 ,Room_and_Board_Days_Rate__c = 500);
		insert objPAyagreementSecondary;

		Insurance_Company_Rate_Adjustment__c objRateAdjustment = PAWTestDataFactory.createRtAdjustmntRecord(
                                                                            objAccount.Id,
                                                                            objAcc.Id);
		/*new Insurance_Company_Rate_Adjustment__c(Insurance_Company__c = objAccount.id ,
																										  Type__c = 'UCR',
																										  FRN_Facility__c = objAcc.id
																										 );*/

		insert objRateAdjustment;

		Year_End_PAW_Settings__c objCustomSetting = new Year_End_PAW_Settings__c();
		objCustomSetting.Year_End_Mode_Enabled__c = true;
		insert objCustomSetting;

		System.debug('<<<<<objCustomSetting '+objCustomSetting);

	}

	@isTest static void initializeForOppId_test_method() {

		PAW_Editor_YearEndController.MetaData meta = new PAW_Editor_YearEndController.MetaData();
		Opportunity objOppTest = [SELECT Id FROM Opportunity LIMIT 1];
		Year_End_PAW_Settings__c objCustomSettingTest = [SELECT id, Year_End_Mode_Enabled__c FROM Year_End_PAW_Settings__c LIMIT 1];
		System.debug('<<<<<objCustomSetting '+objCustomSettingTest);
		Test.setCurrentPageReference(new PageReference('Page.PAW_Editor_YearEnd'));
		System.currentPageReference().getParameters().put('id', objOppTest.id);

		Test.StartTest();
		PAW_Editor_YearEndController controller = new PAW_Editor_YearEndController();
		controller.yearEndMode = objCustomSettingTest.Year_End_Mode_Enabled__c;
		System.debug('<<<<<objCustomSetting '+controller.yearEndMode );
		controller.initialize();
		Test.StopTest();

		System.assert(controller.meta.hasSecondary != null);
		System.assert(controller.yearEndMode == true);

	}

	@isTest static void initializeForPAWIdForCurrentYear_test_method() {

		PAW_Editor_YearEndController.MetaData meta = new PAW_Editor_YearEndController.MetaData();
		Pay_Agreement_Worksheet__c objPAyagreementTest = [SELECT ID FROM Pay_Agreement_Worksheet__c LIMIT 1];
		Test.setCurrentPageReference(new PageReference('Page.PAW_Editor_YearEnd'));
		System.currentPageReference().getParameters().put('id', objPAyagreementTest.id);

		Test.StartTest();
		PAW_Editor_YearEndController controller = new PAW_Editor_YearEndController();
		System.debug('<<<<<objCustomSetting '+controller.yearEndMode );
		controller.initialize();
		Test.StopTest();

		System.assert(controller.meta.hasSecondary == false);
	}
	@isTest static void initializeForPAWIdForNextYear_test_method() {

		PAW_Editor_YearEndController.MetaData meta = new PAW_Editor_YearEndController.MetaData();
		Insurance_Benefit__c objInsuranceBenefitSecondaryTest = [SELECT id , Applicable_For_Year__c FROM Insurance_Benefit__c WHERE Applicable_For_Year__c='2018'];
		Pay_Agreement_Worksheet__c objPAyagreementTest = [SELECT ID FROM Pay_Agreement_Worksheet__c WHERE Insurance_Benefit__c =: objInsuranceBenefitSecondaryTest.id];
		Test.setCurrentPageReference(new PageReference('Page.PAW_Editor_YearEnd'));
		System.currentPageReference().getParameters().put('id', objPAyagreementTest.id);

		Test.StartTest();
		PAW_Editor_YearEndController controller = new PAW_Editor_YearEndController();
		controller.initialize();
		Test.StopTest();

		System.assert(controller.meta.hasSecondary == true);
	}

		@isTest static void saveRecords_test_method() {

			Opportunity oppObj = [Select id From Opportunity Limit 1];
            Account Acc = [Select id From Account where Name = 'AccountTest' LIMIT 1];
		    //Account objAcc = [select ID from Account where Name = 'AccountTest2' LIMIT 1];
			Patient_Insurance__c objPatientInsTest = [SELECT id FROM Patient_Insurance__c LIMIT 1];
			Facility_Program__c objFRNFacilityTest = [SELECT id FROM Facility_Program__c LIMIT 1];
			Insurance_Company_Rate_Adjustment__c objRateAdjustmentTest = [SELECT id FROM Insurance_Company_Rate_Adjustment__c LIMIT 1];
			Test.setCurrentPageReference(new PageReference('Page.PAW_Editor_YearEnd'));
            ApexPages.currentPage().getParameters().put('id', oppObj.Id);


			Test.StartTest();
			PAW_Editor_YearEndController controller = new PAW_Editor_YearEndController();
			controller.initialize();
			controller.primaryController.getPtntInsrnceSelectOptions();
            controller.primaryController.wrprObj.pyAgrmntWrksht.Patient_Insurance__c = controller.primaryController.ptntInsrnceSelectOptions[1].getValue();
            controller.primaryController.onPatientSelection();
            controller.primaryController.getInsrncBnftSelectOptions();
            controller.primaryController.wrprObj.insrncBnftSelected = controller.primaryController.insrncBnftSelectOptions[1].getValue();
            controller.primaryController.onBenefitSelection();
            controller.primaryController.wrprObj.facilitySelected = Acc.Id;
            controller.primaryController.onFacilitySelection();
            controller.primaryController.wrprObj.fcltyPrgrmSelected = controller.primaryController.fcltyPrgrmOptions[1].getValue();
            controller.primaryController.getRtAdjstmntOptions();
            system.debug('>>> controller.primaryController : '+controller.primaryController.rtAdjstmntOptions);
            controller.primaryController.wrprObj.rateAdjstmntSelected = controller.primaryController.rtAdjstmntOptions[1].getValue();
            controller.primaryController.updateWraperValues();
            controller.primaryController.savePAWRecords();
            Pay_Agreement_Worksheet__c pawObjPrimary = [Select id from Pay_Agreement_Worksheet__c where Insurance_Benefit__c =:controller.primaryController.insrncBnftSelectOptions[1].getValue() order by createdDate Desc Limit 1];

			controller.secondaryController.isTalbott = true;
            controller.secondaryController.getPtntInsrnceSelectOptions();
            controller.secondaryController.wrprObj.pyAgrmntWrksht.Patient_Insurance__c = controller.secondaryController.ptntInsrnceSelectOptions[1].getValue();
            controller.secondaryController.onPatientSelection();
            controller.secondaryController.getInsrncBnftSelectOptions();
            controller.secondaryController.wrprObj.insrncBnftSelected = controller.secondaryController.insrncBnftSelectOptions[1].getValue();
            controller.secondaryController.onBenefitSelection();
            controller.secondaryController.wrprObj.facilitySelected = Acc.Id;
            controller.secondaryController.onFacilitySelection();
            controller.secondaryController.wrprObj.fcltyPrgrmSelected = controller.secondaryController.fcltyPrgrmOptions[1].getValue();
            controller.secondaryController.getRtAdjstmntOptions();
            system.debug('>>> controller.primaryController : '+controller.secondaryController.rtAdjstmntOptions);
            controller.secondaryController.wrprObj.rateAdjstmntSelected = controller.secondaryController.rtAdjstmntOptions[1].getValue();
            controller.secondaryController.updateWraperValues();
            controller.secondaryController.savePAWRecords();
            Pay_Agreement_Worksheet__c pawObjSecondary = [Select id from Pay_Agreement_Worksheet__c where Insurance_Benefit__c =:controller.secondaryController.insrncBnftSelectOptions[1].getValue() order by createdDate Desc Limit 1 ];

            ApexPages.currentPage().getParameters().put('primaryPAWRecordId', pawObjPrimary.Id);
            ApexPages.currentPage().getParameters().put('secondaryPAWRecordId', pawObjSecondary.Id);
			controller.saveRecords();
			Test.StopTest();

			//System.assert();
		}


	@isTest static void PayAgreementWorksheet_test_method() {
		Pay_Agreement_Worksheet__c objPAyagreementTest = [SELECT ID FROM Pay_Agreement_Worksheet__c LIMIT 1];

		Test.StartTest();
		PAW_Editor_YearEndController controller = new PAW_Editor_YearEndController();
		controller.getPayAgreementWorksheet(objPAyagreementTest.id);
		Test.StopTest();

		//System.assert(controller.payAgreementWorksheetList != NULL);
	}

	@isTest static void getThis_test_method() {

		Test.StartTest();
		PAW_Editor_YearEndController controller = new PAW_Editor_YearEndController();
		controller.getThis();
		Test.StopTest();
	}

	@isTest static void treatNullAsZero_test_method() {

		Decimal valueInstance;

		Test.StartTest();
		PAW_Editor_YearEndController controller = new PAW_Editor_YearEndController();
		valueInstance = controller.treatNullAsZero(valueInstance);
		Test.StopTest();

		System.assert(valueInstance == 0.0);
	}

}