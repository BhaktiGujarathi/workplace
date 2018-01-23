/**
* @author Merul Shah
* @date 12-Apr-2016
*
* @description This is test class written for CMAFacilityStatusService Apex Class
* 
* 
*/
@isTest(seeAllData = false)
public Class CMAFacilityStatusServiceTest
{

static testMethod void facilityStatusRecordCreationTestCases() 
{

// Test data creation
// Account creation
 Account acc = CMAFacilityStatusTestDataFactory.createAccountOfRecordTypeFRNfacility(1);
 insert acc;

// Case creatation
 Case tempCase = CMAFacilityStatusTestDataFactory.createCaseOfRecordTypeCMA(1); 
 tempCase.AccountId = acc.Id;
 insert tempCase;



}

}