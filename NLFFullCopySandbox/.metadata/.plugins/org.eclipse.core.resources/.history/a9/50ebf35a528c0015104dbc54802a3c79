Public Class ATTestDataUtility
{
    
    
    public static User generateTestUser(String userName,Profile  profile,String alias,String email)
    {
        
        return new User(Alias = alias,
                        Email= email,
                        EmailEncodingKey='UTF-8',
                        LastName='Testing',
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US',
                        ProfileId = profile.Id,
                        TimeZoneSidKey='America/Los_Angeles',
                        UserName= userName,
                        Generate_Sales_Rep_Scorecard__c = true);
        
    }
    
    public static Lead generateTestLead()
    {
        
        return  new Lead(LastName = 'Last',
                            FirstName = 'first',
                            Status = 'Open',
                            Phone = '12345678',
                            Business_Main_Phone__c = '1234567890',
                            Business_Email__c = 'test@testmail.com',
                            Company = 'Company');
        
    }
    
    public static Task generateTestTaskOpportunity(String whatID)
    {
        
        return new Task(WhatId = whatID,
                        CallType ='Outbound',
                        Type = 'Call',
                        Subject = 'Test',
                        Description = 'Description',
                        Priority='Normal',
                        status='Completed');
    }
    
    public static Task generateTestTaskLead(String whoID)
    {
        return new Task(WhoId = whoID, 
                        CallType ='Outbound',
                        Type = 'Call', 
                        Subject = 'Test3123', 
                        Description = 'Description',
                        Priority='Normal',
                        status='Completed');
    
    
    }
    
    
    public static Opportunity generateTestOpportunity()
    {
        return new Opportunity(Name = 'Test Opportunity',
                                StageName = 'Prospecting',
                                CloseDate = system.today());
        
    }
    
    public static Audit_trail__c generateTestAuditTrailForStatusChange(String objectName,
                                                                     String newStatus,
                                                                     String currentStatus,
                                                                     String type,
                                                                     Opportunity tempOpp,
                                                                     Lead tempLead,
                                                                     User userInstance,
                                                                     DateTime dtTime)
    {
        return new Audit_trail__c(Object__c = objectName,
                                  New_Status_Stage_value__c = newStatus, 
                                  Current_Stage__c = currentStatus,
                                  Type__c = type,
                                  Opportunity__c = tempOpp.id,
                                  Current_owner__c = userInstance.id,
                                  Date_Time_change_was_made__c = dtTime);
        
    }
    
    
}