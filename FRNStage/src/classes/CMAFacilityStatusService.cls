/**
* @author Merul Shah
* @date 12-4-2016
*
* @description This trigger fires on insertion of case with record type 'Clinical / Medical Approval'
* 
* 
*/


public Class CMAFacilityStatusService
{

public static List<Account> lstAcc;
public static List<Facility_Status__c> lstFacStat;


/*******************************************************************************************************
    * @description Creates Facility Status Record related to case.
    * @param 
    * @param 
    * @return Void
    *
    */
public static void facilityStatusRecordCreation()
{
        
        lstAcc = new List<Account>();
        lstFacStat = new List<Facility_Status__c>();
        Id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Clinical / Medical Approval').getRecordTypeId();
 
        lstAcc = [SELECT id,name 
                  FROM account 
                  WHERE FRN_Facility_Type__c = 'Residential Treatment' 
                  AND RecordType.Name = 'FRN Facility' 
                  AND Needs_Clinical_Medical_Approval__c = true];
        
        for(Case cs:(List<Case>) trigger.new)
        {
          if(cs.RecordTypeID == caseRecordTypeId )
          {
             
               for(Account acc : lstAcc)
                  {
                    Facility_Status__c tempFacStat = new Facility_Status__c();
                    tempFacStat.FRN_Facility__c = acc.id;
                    tempFacStat.Status__c = 'Pending';
                    tempFacStat.Case__c = cs.id;
                     
                    lstFacStat.add(tempFacStat);
                   
                  }
          }
         
             
        }   
        
        insert lstFacStat;
 
}

}