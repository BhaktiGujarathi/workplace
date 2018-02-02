public class Send_for_CM_ReviewCONT {
    
    public Clinical_Medical_Review_Note__c CMRN{get;set;}
	public String selectUser{get;set;}
	public boolean shouldRedirect{get;set;}
	public String oppid{get;set;}
    public Send_for_CM_ReviewCONT() {
		shouldRedirect =false;
        CMRN = new Clinical_Medical_Review_Note__c();
		oppid = apexpages.currentpage().getparameters().get('id');
        //CMRN = [SELECT Assigned_To__c,Comments__c FROM Clinical_Medical_Review_Note__c];
    }
	
	public List<SelectOption> getUsersPiclist(){
		List<SelectOption> soList = new List<SelectOption>();
		for(USer u:[select id, name from user where isactive = true order by firstname asc]){
			soList.add(new SelectOption(u.id, u.name));
		}
		return soList;
	}
	public void save(){
		CMRN.Assigned_To__c = selectUser;
		if(oppid != null){
			CMRN.Opportunity__c	= oppid;		
		}
		insert CMRN;
		
		if(oppid != null){
			Opportunity opp = new Opportunity();
			opp.stagename = 'Pending Medical / Clinical Review';
			opp.id = oppid;
			update opp;
		}
		shouldRedirect =  true;
		//PageReference pageRef = new PageReference('/'+CMRN.id);
		//pageRef.setRedirect(true);
		//return pageRef;
	}
}