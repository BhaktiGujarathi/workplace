@isTest
private class CloseLeadBatchClassTest 
{

    
public static testMethod void testschedule() {
Test.StartTest();
Lead ld = new Lead(Status  ='No Activity within 10 Days',LastName = 'Test');
        insert ld;
       
		
Lead ld1 = new Lead(Status  ='No Activity within 10 Days',LastName = 'Test1',IsConverted = false);
        insert ld1;
        update ld1;
CloseLeadBatchClass sh1 = new CloseLeadBatchClass();
String sch = '0 0 23 * * ?'; 
system.schedule('Test Territory Check', sch, sh1); 


Test.stopTest(); 
}



}