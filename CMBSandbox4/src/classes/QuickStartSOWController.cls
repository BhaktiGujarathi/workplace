public with sharing class QuickStartSOWController {
	
	public Lead objLead				{get;set;}
	public boolean thankYouPopup	{get;set;}
	public boolean formDetails		{get;set;}
	public string address1			{get;set;}
	public string address2			{get;set;}
	

	public QuickStartSOWController(){
		objLead = new Lead();
		address1 = '';
		address2 = '';
		thankYouPopup = false;
		formDetails = true;
	}


	public void formSubmit(){
		//if(address1 != '' || address2 != '')
		objLead.Street = address1 + ' ' + address2;
		objLead.LastName = objLead.Company + '-' + date.today();
		objLead.LeadSource = 'Web - QuickStart Accelerator';
		try{
			if(objLead != null)
				insert objLead;
			system.debug('@@@@'+objLead);
			thankYouPopup = true;
			formDetails = false;
		}catch(Exception e){
			ApexPages.addMessages(e);
		}
	}


    public Boolean getHasErrorMessages() {

        return ApexPages.hasMessages(ApexPages.severity.ERROR);
    }	
}