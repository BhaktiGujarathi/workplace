public with sharing class CreateNewLeadController {
    public Flow.Interview.Create_Lead leadFlow{get; set;}
    public Lead leads{get; set;}
    public string opportunityID{get; set;}
    public string getNextStep{get; set;}
    public CreateNewLeadController(ApexPages.StandardController controller)
    {
        Lead objlead = (Lead)controller.getRecord();
        leads = [Select l.Years_in_Business__c, l.Sub_Status__c, l.Status, l.Phone, l.LastName,  l.Timing__c,
                l.Notes__c, l.Next_Step__c, l.Need__c, l.Monthly_Gross_Sales__c, l.Id, l.Description,
                l.FirstName, l.Email, l.Desired_Amount__c, l.Credit_Score__c, l.Company, l.Budget__c, l.MobilePhone,
                l.Best_Time_to_Call__c, l.Industry, l.Purpose_of_Funding__c,
                l.Average_Monthly_CC_Sale__c, l.Authority__c From Lead l
                where id =: objlead.Id];
                
    }
    public PageReference getFinishPage()
    { 
    	list<Opportunity> opportunity = new list<Opportunity>();
    	PageReference p = new PageReference('/' + leads.Id);
    	list<Lead> lstLead = new list<Lead>();
    	lstLead = [select ID,IsConverted from Lead where Id =: leads.Id];
    	if(leadFlow != null && lstLead[0].IsConverted==true){
	    	opportunityID = (String) leadFlow.getVariableValue('NewOpportunityID1');
	    	if(opportunityID != null || opportunityID != '')
	    	opportunity = [select Id, Name,AccountId from Opportunity where Id =: opportunityID];
    
	        if(opportunity.size()>0){
		        //p=new PageReference('/apex/FundingApplication?id='+opportunity[0].AccountId+'&oppId='+opportunity[0].Id);
		        //p.setRedirect(true);
		        PageReference pr = Page.FundingApplication;
		        pr.getParameters().put('id',opportunity[0].AccountId);
                pr.getParameters().put('oppId',opportunity[0].Id);
                return pr;
		     }
        }
        else{
        	p=new PageReference('/' + leads.Id);
        	p.setRedirect(true);
        }
        return p;
    }
     
    public String getLeadId()
    {
        if(leadflow == null)
         return '';
         else
            return leadFlow.objLead;
    }
}