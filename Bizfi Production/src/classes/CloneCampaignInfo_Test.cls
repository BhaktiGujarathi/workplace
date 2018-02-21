/*
Author: Charan Vuyyuru
Created Date: 07/24/2105
Description: Test Class for Trigger on CampaignMember - CloneCampaignInfo
*/

@istest
public class CloneCampaignInfo_Test{

    public static testmethod void m1(){
    
        Lead ld = createLead();
        insert ld;
        
        Campaign camp= createCampaign();
        insert camp;
        
        CampaignMember cm = new CampaignMember();
        cm.leadid = ld.Id;
        cm.campaignId = camp.Id;
        insert cm;
    
    }
    
    public static Lead createLead(){
        
        Lead testLead = new Lead();
        testLead.FirstName='Test';
        testLead.LastName='Lead';
        testLead.Company='test company';
        return testlead;
        
    }
    
    public static Campaign createCampaign(){
        
        Campaign cm = new Campaign();
        cm.name='Test Campaign';
        return cm;
        
    }
    
}