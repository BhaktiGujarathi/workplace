public without sharing class LeadSearchWidgetController {
	
	public Boolean showSearch { get; set; }
	public Boolean showName { get; set; }
	public Boolean showLink { get; set; }

	public String searchId { get; set; }
	public String leadName { get; set; }
	public String leadId { get; set; }
	private Lead lead;

	
	public LeadSearchWidgetController() {
		searchId = '';
		leadName = '';
		leadId = '';
		showSearch = true;
		showName = false;
		showLink = false;
	}


	public void searchLead() {

		for (Lead l : [select Name from Lead where Search_Id__c = :searchId and Searchable_via_Widget__c = true]) {
			lead = l;
			leadName = l.Name;
			showSearch = false;
			showName = true;			
		}
	}


	public void cancel() {
		searchId = '';
		leadName = '';
		leadId = '';
		showSearch = true;
		showName = false;
		showLink = false;		
	}


	public void assignLead() {

		lead.OwnerId = UserInfo.getUserId();
		update lead;

		leadId = lead.Id;
		showName = false;
		showLink = true;		
	}
}