public class OpportunitiesCustomerInteractionLog {
    public Opportunity myOpportunities{get;set;}
    
    public String OpportunityId { 
        get {
            if(OpportunityId == null) {
                OpportunityId = ApexPages.currentPage().getParameters().get('id');
            }
            return OpportunityId;
        }
        set; 
    }

    public void updateWhoWhatId() {
        // Integer caseCount = [Select COUNT() from Opportunities where id = :OpportunityId];
        // if (caseCount==0) {
            // statusMessage = 'This log is not associated with a Case or Contact! Please save the case.';
            // return;
        // }
        system.debug('id----'+OpportunityId);
        myOpportunities = [Select id,Customer_Note__c from Opportunity where id = :OpportunityId];
        system.debug('myOpportunities----'+myOpportunities);
        // task.whoId = myOpportunities.contactId;
        // task.whatId = myOpportunities.id;
    }

    private void initializeTask() {
        updateWhoWhatId();
        task.subject = Subject;
    }
    
    private String Subject { 
        get {
            Subject = 'Call at ' + DateTime.now();
            return Subject;
        }
        set; 
    }

    public OpportunitiesCustomerInteractionLog(ApexPages.StandardController controller) {
        initializeTask();
    }       

    public String ANI { get; set;}
    public String CallObject { get; set;} 
    public Integer CallDurationInSeconds { get; set;} 
    public String CallType { get; set;}  
    public String CallDisposition { get; set;}        
    
    public String statusMessage { get; set; }

    public Task task { 
        get {
            if(task == null) {
                task = new Task();
            }
            return task;
        }
        set; 
    }
    
    public void setCallAttachedData() {
        task.CallObject = CallObject;
        //task.ANI__c = ANI;
    }     

    public void setCallEndData() {
        task.CallDurationInSeconds = CallDurationInSeconds;
        task.CallDisposition = CallDisposition;    
        save();
    }
    
    public void save() {

        update myOpportunities;
        
        // statusMessage = 'Last save at ' + DateTime.now();
    }
    
     // public void saveAndNew() {
        // save();
        // task = null;
        // initializeTask();
        // //task.ANI__c= ANI;
        // task.CallObject = CallObject;
    // }        
}