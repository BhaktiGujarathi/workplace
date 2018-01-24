@isTest

public class RecordCountTest 
{
    public static testMethod void recordCountUFHT() 
    {
          
        List<UFHT__Ultra_Track_Container__c> UFHTList = new List<UFHT__Ultra_Track_Container__c>();
       
        UFHTList.add(new UFHT__Ultra_Track_Container__c(UFHT__Object_Name__c='Case',UFHT__Object_Label__c='Case(case)'));
        UFHTList.add(new UFHT__Ultra_Track_Container__c(UFHT__Object_Name__c='Account',UFHT__Object_Label__c='Account(Account)'));
        UFHTList.add(new UFHT__Ultra_Track_Container__c(UFHT__Object_Name__c='Campaign',UFHT__Object_Label__c='Campaign(Campaign)'));
        UFHTList.add(new UFHT__Ultra_Track_Container__c(UFHT__Object_Name__c='Opportunity',UFHT__Object_Label__c='Opportunity(Opportunity)'));
     
       RecordCount rc = new RecordCount();  
        test.StartTest();
        rc.calculateRecordCount();
        test.StopTest();  
        system.assertEquals(UFHTList.size(),4);
        system.debug('UFHTList'+UFHTList);
        system.debug('UFHTListsize'+UFHTList.size());
               
    }
}