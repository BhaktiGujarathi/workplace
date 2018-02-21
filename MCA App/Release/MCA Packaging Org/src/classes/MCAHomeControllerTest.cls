/**

 *  Description -  Test Class for DashboardIdeasController
 *
 * Version     Author            Date           Description
 * 1.0         Neena Tiwari      03/04/2014     Initial Draft
 *                                                          
 */
 
@isTest
private class MCAHomeControllerTest {

     static testMethod void testStatisticsDataForOpportunityAndLead() {
        
        //created a single record of account
        Account accRecord = MCAHomeControllerTest.getAccountRecords();
        insert accRecord; 
       
        //created list of opportunity record for underwriter stage
        List<Opportunity> oppforStageUnderwriterLst = MCAHomeControllerTest.getOpportunityRecord(20);
        for(Opportunity opp:oppforStageUnderwriterLst){
            opp.StageName = 'Underwriting';  
            opp.AccountId = accRecord.Id;    
        }
        insert oppforStageUnderwriterLst; //opportunity list inserted
        
        //created list of opportunity record for approved stage
        List<Opportunity> oppforStageApprovedLst = MCAHomeControllerTest.getOpportunityRecord(20);
        for(Opportunity opp:oppforStageApprovedLst){
            opp.StageName = 'Approved'; 
            opp.AccountId = accRecord.Id;    
        }
        insert oppforStageApprovedLst; //opportunity list inserted
        
        //created list of opportunity record for signed stage
        List<Opportunity> oppforStageSignedLst = MCAHomeControllerTest.getOpportunityRecord(20);
        for(Opportunity opp:oppforStageSignedLst){
            opp.StageName = 'Agreement Signed'; 
            opp.AccountId = accRecord.Id;    
        }
        insert oppforStageSignedLst; //opportunity list inserted
        
        //created list of opportunity record for signed stage
        List<Opportunity> oppforStageAppSent= MCAHomeControllerTest.getOpportunityRecord(20);
        for(Opportunity opp:oppforStageAppSent){
            opp.StageName = 'Application Sent'; 
            opp.AccountId = accRecord.Id;    
        }
        insert oppforStageAppSent; //opportunity list inserted
       
       //created list of opportunity record for signed stage
        List<Opportunity> oppforStageAppIn= MCAHomeControllerTest.getOpportunityRecord(20);
        for(Opportunity opp:oppforStageAppIn){
            opp.StageName = 'Application In'; 
            opp.AccountId = accRecord.Id;    
        }
        insert oppforStageAppIn; //opportunity list inserted
        
        //created list of opportunity record for signed stage
        List<Opportunity> oppforStageAppMissInfo= MCAHomeControllerTest.getOpportunityRecord(20);
        for(Opportunity opp:oppforStageAppMissInfo){
            opp.StageName = 'Application Missing Info'; 
            opp.AccountId = accRecord.Id;    
        }
        insert oppforStageAppMissInfo;        
        
        //created list of opportunity record for signed stage
        List<Opportunity> oppforStageAgreementSent= MCAHomeControllerTest.getOpportunityRecord(20);
        for(Opportunity opp:oppforStageAgreementSent){
            opp.StageName = 'Agreement Sent'; 
            opp.AccountId = accRecord.Id;    
        }
        insert oppforStageAgreementSent;
        
         //created list of opportunity record for signed stage
        List<Opportunity> oppforStageFunded= MCAHomeControllerTest.getOpportunityRecord(20);
        for(Opportunity opp:oppforStageFunded){
            opp.StageName = 'Funded'; 
            opp.Date_Funded__c = System.today();
            opp.Funding_Amount__c = 100;
            opp.AccountId = accRecord.Id;    
        }
        insert oppforStageFunded;
        
        //created list of Lead records which are unread by owner
        List<Lead> leadUnreadLst = MCAHomeControllerTest.getLeadRecord(20);
        for(Lead leads: leadUnreadLst){
            leads.IsUnreadByOwner = true;
        }
        insert leadUnreadLst; //Leads which are unread is inserted
        
        test.startTest();
        MCAHomeController controller = new MCAHomeController();
        
        controller.onLoad();
        
        test.stopTest();
       /* system.assertEquals(controller.UnderwriterOpp, 20);
        system.assertEquals(controller.ApprovedOpp, 20);              
        system.assertEquals(controller.appSentOpp, 20);
        system.assertEquals(controller.appRecievedOpp, 20);                      
        system.assertEquals(controller.signedContractOpp, 20);               
        system.assertEquals(controller.contractSentOpp, 20);
        system.assertEquals(controller.NewLeadsThisWeek, 20);*/
    }

    //Populates and returns a list of Account records
    public static Account getAccountRecords(){
        
       Account account = new Account(Name = 'Test Account2',
                                          Email__c='testacc@gmail.com',
                                          Phone = '0223455755');   
        return account;
    }
    
    //Method that returns a list of Opportunity records
    public static List<Opportunity> getOpportunityRecord(Integer pCountOfOpportunity){
    
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer intIndex = 0; intIndex < pCountOfOpportunity; intIndex ++){
            
            Opportunity objOpp = new Opportunity();
            objOpp.Name = 'testOpp' + intIndex;
            objOpp.CloseDate = Date.today();
            oppList.add(objOpp);                       
        }
        return oppList;
    } 
    
    //Method that returns a list of Leads records
    public static list<Lead> getLeadRecord(Integer pCountOfLead){
        
        List<Lead> leadLst = new List<Lead>();
        for(Integer intIndex = 0; intIndex < pCountOfLead; intIndex ++){
            
            Lead objlead = new Lead();
            objlead.Company = 'Company ABC' + intIndex;
            objlead.LastName = 'TestDashboard' + intIndex;
            objlead.Status = 'Working - Contacted';
            leadLst.add(objlead);            
        }
        return leadLst;
    }
}