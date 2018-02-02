public class LeadCustomerInteractionLog {
    public Lead myLead{get;set;}
    
    public String LeadId { 
        get {
            if(LeadId == null) {
                LeadId = ApexPages.currentPage().getParameters().get('id');
            }
            return LeadId;
        }
        set; 
    }

    public void updateWhoWhatId() {
        // Integer caseCount = [Select COUNT() from Case where id = :caseId];
        // if (caseCount==0) {
            // statusMessage = 'This log is not associated with a Case or Contact! Please save the case.';
            // return;
        // }
        system.debug('id----'+LeadId);
        myLead = [Select id,Customer_Note__c from Lead where id = :LeadId];
        system.debug('myCase----'+myLead);
        // task.whoId = myCase.contactId;
        // task.whatId = myCase.id;
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

    public LeadCustomerInteractionLog(ApexPages.StandardController controller) {
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

        update myLead;
        
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