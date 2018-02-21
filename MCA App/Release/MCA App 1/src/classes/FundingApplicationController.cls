/* 
 *  Description - Controller for FundingApplication Page
 *	 
 *  Date - 17-02-2014
 *  
 *  Created by - Sneha P.
 */
public with sharing class FundingApplicationController {
	
	private String AccId;
	private String OppId;
	public Opportunity opportunity {get; set;}
	private ApexPages.StandardController stdController;
	private final String selectAccountError = 'Please select Account on opportunity';
		
	public FundingApplicationController(ApexPages.StandardController stdController){
		this.stdController = stdController;
		opportunity = new Opportunity();
		try{
			AccId = ApexPages.currentPage().getParameters().get('id');
			OppId = ApexPages.currentPage().getParameters().get('oppId');
			opportunity = [Select Balance__c ,Cash_Advance_Company__c,
								  Ever_used_a_Business_Cash_Advance__c,
								  Requested_Amount_of_Funds__c
								  from Opportunity where Id =: OppId ];
		}catch(Exception e){
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
		}
		
	}
	
	public PageReference Save(){
		this.QuickSave();
		PageReference pageRef = new PageReference('/apex/FundingApplicationView?id='+AccId+'&oppId='+OppId);
		pageRef.setRedirect(true);
		return pageRef;
	} 
	
	public void QuickSave(){
		this.stdController.save();
		update opportunity;	
	}
	
	public PageReference cancel(){
		return new PageReference('/'+OppId);
	}
	
	public PageReference editPage(){
		PageReference pageRef = new PageReference('/apex/FundingApplication?id='+AccId+'&oppId='+OppId);
		pageRef.setRedirect(true);
		return pageRef;
	}
}