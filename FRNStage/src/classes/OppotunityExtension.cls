public class OppotunityExtension{
    public List<Opportunity> opplist{get;set;}     
    public String opprec;
    
    public oppotunityExtension(ApexPages.StandardController controller){
        
        opplist = new List<opportunity>();
        
        opprec =((opportunity)controller.getRecord()).id;
        if(opprec!= null){
            Opportunity oppo = [select Id, Contact__c,Contact__r.Name,Contact__r.MobilePhone,Contact__r.Phone FROM Opportunity where Id=: opprec];
			String conName = oppo.Contact__r.Name;
            if(oppo.Contact__c !=null){
				String opportunityQuery = 'Select Id, Owner.Name, StageName, CloseDate,Name, CreatedDate FROM Opportunity WHERE Id !=: opprec AND (Contact__r.Name =: conName )';
				if(oppo.Contact__r.MobilePhone!=null){
					opportunityQuery = opportunityQuery.remove(')');
					String conMobilePhone = oppo.Contact__r.MobilePhone;
					opportunityQuery = opportunityQuery+' OR Contact__r.Phone =: conMobilePhone OR Contact__r.MobilePhone =: conMobilePhone )';
				}
				if(oppo.Contact__r.Phone!=null){
					opportunityQuery = opportunityQuery.remove(')');
					String conPhone = oppo.Contact__r.Phone;
					opportunityQuery = opportunityQuery+' OR Contact__r.Phone =: conPhone OR Contact__r.MobilePhone =: conPhone )';
				}
				opportunityQuery = opportunityQuery+' order by CloseDate DESC LIMIT 50000';
				System.debug('opportunityQuery ::>'+opportunityQuery);
                opplist = Database.query(opportunityQuery);     
            }
        }
        System.debug('opplist----'+opplist.size());
    }   
}