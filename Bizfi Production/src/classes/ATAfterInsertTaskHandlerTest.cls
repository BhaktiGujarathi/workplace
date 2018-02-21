//ATAfterInsertTaskHandler
@isTest(seeAllData = false)
public Class ATAfterInsertTaskHandlerTest
{
    
    static testMethod void testonCallTaskInsertForOpportunity()
    {
      Opportunity testOpportunity = ATTestDataUtility.generateTestOpportunity();
      insert testOpportunity;
      
      Task testTask = ATTestDataUtility.generateTestTaskOpportunity(testOpportunity.id);
      system.test.startTest();
      insert testTask;
      system.test.stopTest();
    } 
    
    
    static testMethod void testonCallTaskInsertForLead()
    {
      Lead testLead = ATTestDataUtility.generateTestLead();
      insert testLead;
      
      Task testTask = ATTestDataUtility.generateTestTaskLead(testLead.id);
      system.test.startTest();
      insert testTask;
      system.test.stopTest();
    } 
    

}