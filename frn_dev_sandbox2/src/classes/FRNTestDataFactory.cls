/**
* @author Merul Shah
* @date 12-Apr-2016
*
* @description This is org specific data factory
* 
* 
*/

public Class FRNTestDataFactory
{

 /*******************************************************************************************************
    * @description Created the bulk account
    * @param Integer: Number of account to be created. 
    * @return List<Account>  : List of Account
 */
 
public static List<Account> createAccountBasedOnRecordCount(Integer i)
{
    List<Account> lstAcc = new List<Account>();
    for(Integer j = 0;j < i ; j++)
    {
        Account acc = new Account();
        lstAcc.add(acc);
    }
    
    return lstAcc;

}


public static List<Case> createCaseBasedOnRecordCount(Integer i)
{
    List<Case> lstCase = new List<Case>();
    for(Integer j = 0;j < i ; j++)
    {
        Case tempCase = new Case();
        lstCase.add(tempCase);
    }
    
    return lstCase;

}

    public static Facility_Status__c createFacilityStatusRecord(Id pFacilityId, Id pCaseId)
    {
        Facility_Status__c faciltityStatusObj = new Facility_Status__c(FRN_Facility__c = pFacilityId,
                                                                       Case__c = pCaseId);
        return faciltityStatusObj;    
    }
    
    // mehtod to create contact records
    public static List<Contact> createContactList(Integer pCount) {
        List<Contact> contactList = new List<Contact>();
        
        for(Integer i=0; i<pCount; i++) {
            contactList.add(new Contact(LastName='TestLast'+i,
                                        FirstName='TestFirst'+i,
                                        Gender__c='Transgender'
                                        ));
        }
        
        return contactList;
    }
    
    // method to create Opportunity records
    public static List<Opportunity> createOpportunityList(Integer pCount) {
        List<Opportunity> opportunityList = new List<Opportunity>();
        Id oppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId();
        
        for(Integer i=0; i<pCount; i++) {
            opportunityList.add(new Opportunity(Name = 'Test'+i,
                                                RecordTypeId = oppRecId,
                                                StageName = 'In Process',
                                                CloseDate = System.today(),
                                                Probability = 10
                                                ));
        }
        
        return opportunityList;
    }

}