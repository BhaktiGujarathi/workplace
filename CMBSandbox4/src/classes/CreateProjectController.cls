/* Description - Create Project & Estimate
 * 
 *  Created By - Shraddha P.
 * 
 *  Date(dd/mm/yyyy) - 2/10/2015
 *
 */
global with sharing class CreateProjectController {
    
    webservice static string CreateRecords(String oppId){
        Opportunity objOpportunity = [Select Id,
                                            AccountId,
                                            account.name,
                                            ProjectType__c,
                                            Hourly_Rate__c,
                                            Project_Name__c,
                                            Total_SOW_Hours__c, 
                                            Name
                                            From Opportunity where Id=: oppId];
        HarvestProject__c newProject = CreateProject(objOpportunity);

        CreateEstimate(objOpportunity,newProject);
        return newProject.Id;
    }
    
    webservice static HarvestProject__c CreateProject(Opportunity opportunity){
        string projectManagerName=Label.Default_Project_Manger;
        list<Contact> lstContact = [Select id, Name From Contact 
                                                    where Name =:projectManagerName];
        HarvestProject__c objProject = new HarvestProject__c();
        objProject.ProjectType__c = opportunity.projectType__c;
        if(lstContact != null && !lstContact.isEmpty())
            objProject.ClientProjectManager__c = lstContact[0].Id;
        objProject.Account__c = opportunity.AccountId;
        objProject.Opportunity__c = opportunity.Id;
        //objProject.ProjectType__c='Implementation';
        objProject.ProjectHourlyRate__c=opportunity.Hourly_Rate__c;
        if(opportunity.Project_Name__c==null){
             objProject.Name = opportunity.Name;
        }else{
           objProject.Name = opportunity.Name + '-' + opportunity.Project_Name__c;
        }
        objProject.SyncStatus__c = 'Status Unknown';
        try{
            insert objProject;
        }catch(DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                SendErrorMail.sendErrorLog(e.getDmlMessage(i));
            }
        }
        return objProject;
    }
    
    webservice static void CreateEstimate(Opportunity opportunity, HarvestProject__c project){
        Estimates__c objEstimate = new Estimates__c();
        objEstimate.Estimates_Hours__c = opportunity.Total_SOW_Hours__c;
        objEstimate.Opportunity__c = opportunity.Id;
        objEstimate.Harvest_Projects__c = project.Id;
        objEstimate.Name = opportunity.Project_Name__c;
        objEstimate.Status__c = 'Approved - By Client';
        objEstimate.Approved_Via__c='SOW';
        objEstimate.Date_Sent__c = system.today();
        objEstimate.Name=Opportunity.Name+' - '+DateTime.now().format('yyyy-MM-dd');
        try{
            insert objEstimate;
        }catch(DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                SendErrorMail.sendErrorLog(e.getDmlMessage(i));
            }
        }
    }
}