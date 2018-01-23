@isTest 
private class TestBenefitHandler{
    private static TestMethod  void TestBenefitHandler_UnitTest(){
    
	Patient_Insurance__c patInsurance = new Patient_Insurance__c();
	patInsurance.Name = 'test';
	insert patInsurance;
	
	Insurance_Benefit__c insBenefit = new Insurance_Benefit__c();
	insBenefit.LOC_Benefits_are_the_Same__c = true;
	insBenefit.Patient_Insurance__c = patInsurance.Id;
	insBenefit.PHP_Covered__c = 'Yes';
	insBenefit.Detox_Covered__c = 'Yes';
	insBenefit.PHP_Pays_at__c = 100;
	insBenefit.Detox_Pays_at__c = 100;
	insBenefit.PHP_Ratio__c = '100';
	insBenefit.Detox_Ratio__c = '100';
	insBenefit.PHP_Admit_Co_Payment__c = 100;
	insBenefit.Detox_Admit_Co_Payment__c = 100;
	insBenefit.PHP_Day_Max_Applies__c = 'Yes';
	insBenefit.Detox_Day_Max_Applies__c = 'Yes';
	insBenefit.IOP_Covered__c = 'Yes';
	insBenefit.IOP_Pays_at__c = 100;
	insBenefit.IOP_Ratio__c = '100';
	insBenefit.IOP_Admit_Co_Payment__c = 100;
	insBenefit.IOP_Day_Max_Applies__c = 'Yes';
	insBenefit.RTC_Covered__c = 'Yes';
	insBenefit.RTC_Pays_at__c = 100;
	insBenefit.RTC_Ratio__c = '100';
	insBenefit.RTC_Admit_Co_Payment__c = 100;
	insBenefit.RTC_Day_Max_Applies__c = 'Yes';
	insert insBenefit;
	update insBenefit;
    }
}