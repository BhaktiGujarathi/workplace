public class NewAbusedSubstanceFrOppCont {
	Public Abused_Substance__c sub{get;set;}
	Private String oppId;
	
	public NewAbusedSubstanceFrOppCont(){
		sub = new Abused_Substance__c();
		oppId = apexpages.currentpage().getparameters().get('oppId');
	}
	
	public PageReference save(){
		sub.Opportunity__c = oppId;
		insert sub;
		PageReference page= new PageReference('/'+oppId+'/e');
		page.setRedirect(true);
		return page;
	}
	public PageReference Cancel(){
	
	PageReference page= new PageReference('/'+oppId+'/e');
		page.setRedirect(true);
		return page;
	}

}