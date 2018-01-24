@isTest

public class UltraFieldHistoryRecordCountTest
{
    public static testMethod void testUpdateRecordCount() 
    {
          
        List<UFHT__Ultra_Track_Container__c> UltraFieldHistoryList = new List<UFHT__Ultra_Track_Container__c>();
        decimal m = 102;
        decimal k;
        UltraFieldHistoryList.add(new UFHT__Ultra_Track_Container__c(UFHT__Object_Name__c='Case',UFHT__Object_Label__c='Case(case)'));
        UltraFieldHistoryList.add(new UFHT__Ultra_Track_Container__c(UFHT__Object_Name__c='Account',UFHT__Object_Label__c='Account(Account)'));
        UltraFieldHistoryList.add(new UFHT__Ultra_Track_Container__c(UFHT__Object_Name__c='Campaign',UFHT__Object_Label__c='Campaign(Campaign)'));
        UltraFieldHistoryList.add(new UFHT__Ultra_Track_Container__c(UFHT__Object_Name__c='Opportunity',UFHT__Object_Label__c='Opportunity(Opportunity)'));
     
       UltraFieldHistoryRecordCount rc = new UltraFieldHistoryRecordCount();  
        test.StartTest();
        UltraFieldHistoryRecordCount.updateRecordCount('Account',102);
        
        UFHT__Ultra_Track_Container__c a = [select UFHT__No_of_Records__c from UFHT__Ultra_Track_Container__c where UFHT__Object_Name__c = : 'Account' ];
        k =a.UFHT__No_of_Records__c;
        test.StopTest();  
        system.assertEquals(k,m);
        system.debug('k'+k);
        system.debug('m'+m);
        system.debug('a'+a);
               
    }
}