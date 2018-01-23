/**
* @author Merul Shah
* @date 12-Apr-2016
*
* @description This is test data factory specific to CMAFacilityStatusServiceTest class.
* 
* 
*/
public class CMAFacilityStatusTestDataFactory
{

public static Account createAccountOfRecordTypeFRNfacility(Integer i)
{
    
    List<Account> lstAcc = new List<Account>();
    lstAcc  = FRNTestDataFactory.createAccountBasedOnRecordCount(1);
    lstAcc[0].name = 'TestAccount';
    lstAcc[0].FRN_Facility_Type__c = 'Residential Treatment';
    lstAcc[0].Needs_Clinical_Medical_Approval__c = true;
    lstAcc[0].recordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FRN Facility').getRecordTypeId();
    
    return lstAcc[0];

}


public static Case createCaseOfRecordTypeCMA(Integer i)
{
    
    List<Case> lstCase = new List<Case>();
    lstCase = FRNTestDataFactory.createCaseBasedOnRecordCount(1);
    lstCase[0].recordtypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clinical / Medical Approval').getRecordTypeId();
   
    return lstCase[0];

}


}