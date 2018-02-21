@isTest
private class LeadStatusUpdateExtTest{
   static testMethod void LeadStatusUpdateExt(){
    
     //Create Test Data For Lead
        Lead objlead = new Lead();
        objlead.FirstName= 'Test First Name';
        objlead.LastName= 'Test First Name';
        objlead.Company= 'Test Company';
        objlead.Status = 'Open - Not Contacted';
        objlead.Sub_Status__c = 'Sub Status 1';
        objlead.Next_Step__c = 'Send Email 1a in 24h & follow-up call 48h later';
               
        insert objlead;
        system.debug('****objlead***'+objlead);
        
        Id leadID = objlead.Id;
        //Create a reference to the VF page
        PageReference pageRef = Page.LeadStatusChatterAction;
        pageRef.getParameters().put('Id', objlead.Id);
        system.debug('***pageRef***'+pageRef);
        Test.setCurrentPageReference(pageRef);
        

        ApexPages.StandardController sc = new ApexPages.standardController(objlead);
        LeadStatusUpdateExt obj = new LeadStatusUpdateExt(new ApexPages.StandardController(objlead));
        
        obj.dosave();
    }
 }