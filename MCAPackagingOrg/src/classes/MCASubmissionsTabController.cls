public with sharing class MCASubmissionsTabController {

    public Submission__c[] submissions;
    public Submission__c[] newSubmissions {get; set;}
    public Opportunity opportunityObj{get; set;}
    public Container[] containers;

    public Boolean editAll {get;set;}
    public Boolean declinedFlag = false;
    public Id recordToDelete {get;set;}
    public Integer indexToRemove {get;set;}

    public Integer submissionCount {get; set;}
    public Integer submissionCntUW {get; set;}
    public Integer submissionCntApproved {get; set;}
    public Integer submissionIndex {get; set;}
    public String submissionStatusValue {get; set;}
    public String inlineEdit {get; set;}
    public Boolean isFirst;
    public String theValue {get;set;}
    private Id opportunityId;
    public Boolean isUpdated;
    public Map<Id, Submission__c> mapIDANDSubmission;
    public List<Submission__c> listToUpdate;
    public Boolean isValidation;
    
    public MCASubmissionsTabController() {
        opportunityObj = new Opportunity();
        mapIDANDSubmission = new Map<Id, Submission__c>();
        isFirst = true;
        isValidation = false;
        opportunityId = Apexpages.currentPage().getParameters().get('id');
        opportunityObj = [Select AccountId, Id, Name from Opportunity where Id =: opportunityId ];
        submissionCntUW = 0;
        submissionCntApproved = 0;
        inlineEdit = 'false';
        refresh();
    }

    public Container[] getContainers() {
        theValue = 'false';
        Container[] copyContainers = new Container[] {};
        for(Integer i=0; i<containers.size(); i++){
            copyContainers.add(new Container(containers[i].submission, containers[i].index, containers[i].submissionStatusValue));
        }
        submissionCntUW=0;
        submissionCntApproved=0;
        submissions = new Submission__c[] {};
        
        submissions.addAll(newSubmissions);
        if(isFirst && !editAll && !isValidation){
            submissions.addAll(submissionList());
            
        } else {
            for (Container containerVal: containers) {
                if(containerVal.index != indexToRemove)
                    submissions.add(containerVal.submission);
            }
        }
        indexToRemove = -1;
        containers = new Container[] {};
        submissionCount = submissions.size();
        Integer j=0;
        for (Integer i = 0; i < submissions.size(); i++) {
            if(copyContainers.size()>j && copyContainers[j].submission.Id == submissions[i].Id){
                if(copyContainers[j].submissionStatusValue != 'Declined')
                submissions[i].DecliedReason__c = '';
                containers.add(new Container(submissions[i], i, copyContainers[j].submissionStatusValue));
                ++j;
            }else
            containers.add(new Container(submissions[i], i, submissions[i].Status__c));
            if(submissions[i].Status__c == 'UW')
                ++submissionCntUW;
            if(submissions[i].Status__c == 'Approved')
                ++submissionCntApproved;
        }
        newSubmissions = new List<Submission__c>();
        return containers;
    }
     //It is used query all the present task for the opportunity
    public List<Submission__c> submissionList() {
        isFirst = false;
        mapIDANDSubmission.clear();
        mapIDANDSubmission = new Map<ID, Submission__c>([SELECT
                                                            Id,
                                                            Name,
                                                            Funder__c,
                                                            Date_Submitted__c,
                                                            Status__c,
                                                            DecliedReason__c,
                                                            Status_Date__c,
                                                            Contact__c,                       
                                                            Program__c,
                                                            Application_Number__c,
                                                            Notes__c,
                                                            //Highest_Funding_Amt__c,
                                                            //Longest_Term__c,
                                                            (SELECT
                                                                 Term_Months__c,
                                                                 Status__c,
                                                                 Send__c,
                                                                 Rate__c,
                                                                 Payment_Amt__c,
                                                                 Payback_Amt__c,
                                                                 PMT_Schedule__c,
                                                                 Holdback__c,
                                                                 Funder__c,
                                                                 Deal_Type__c,
                                                                 Submission__c,
                                                                 Amount__c
                                                            FROM Offers__r)
                                                        FROM Submission__c
                                                        WHERE Opportunity__c = :opportunityId]);
        return mapIDANDSubmission.values();
    }
    public void newSubmission() {
        /*isUpdated = false;
        checkoldAndNewVal();
        if(editAll !=true && isUpdated == true){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'All changes have been saved.'));
            updateInlineEditedValue();
        }*/
        saveMessage();
        newSubmissions.add(new Submission__c(Opportunity__c = opportunityId));
    }
    
    public void updateInlineEditedValue() {
        try{
            update listToUpdate;
        }
        catch(Exception e){
            system.debug('***Enter In Exception****');
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
    }
    
    public void checkoldAndNewVal() {
        listToUpdate = new List<Submission__c>();
        Submission__c subValue = new Submission__c();
        List<Submission__c> listSub = submissionList();
        for (Container containerVal: containers) {
            if(containerVal.submission.id != null){
                subValue = mapIDANDSubmission.get(containerVal.submission.id);
                if(subValue != null){
                    if(containerVal.submission.Funder__c != subValue.Funder__c
                    || containerVal.submission.Date_Submitted__c != subValue.Date_Submitted__c
                    || containerVal.submission.Status__c != subValue.Status__c
                    || containerVal.submission.Status_Date__c != subValue.Status_Date__c
                    || containerVal.submission.Notes__c != subValue.Notes__c
                    //|| containerVal.submission.Highest_Funding_Amt__c != subValue.Highest_Funding_Amt__c
                    //|| containerVal.submission.Longest_Term__c != subValue.Longest_Term__c
                    || containerVal.submission.Program__c != subValue.Program__c){
                        listToUpdate.add(containerVal.submission);
                        isUpdated = true;
                    }
                }
            }
        }
    }
    public void refresh() {
        theValue = 'false';
        isFirst = true;
        if(!inlineEdit.containsIgnoreCase('true'))
            editAll = false;
        recordToDelete = null;
        newSubmissions = new Submission__c[] {};
        containers = new Container[] {};
        if(inlineEdit.containsIgnoreCase('true')){
            inlineEdit = 'false';
        }   
    }

    public void editAll() {
        editAll = true;
    }
    public void save(){}

    public void saveAllSubmissions() {
        isValidation = false;
        try{
            upsert submissions;
        }
        catch(Exception e){
            isValidation = true;
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
        refresh();
    }
     public void removeSubmission(){
      saveMessage();
     }
        
     public void saveMessage(){
        isUpdated = false;
        checkoldAndNewVal();
        if(editAll !=true && isUpdated == true){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'All changes have been saved.'));
            updateInlineEditedValue();
        }
    }   

    public void deleteSubmission() {
           saveMessage(); 
        if (recordToDelete != null) {
            Submission__c record = [SELECT Id FROM Submission__c WHERE Id = :recordToDelete];
            delete record;
        }
    }
    

    public pageReference setSubmissionStatus() {
        inlineEdit = Apexpages.currentPage().getParameters().get('inlineFalse');
        containers[submissionIndex].submissionStatusValue = submissionStatusValue;
        if(submissionStatusValue != 'Declined'){
            containers[submissionIndex].submission.DecliedReason__c = '';
        }
        declinedFlag = true;
        return null;
    }

    public class Container {

        public Submission__c submission {get;set;}
        public Integer index {get;set;}
        public String submissionStatusValue {get; set;}

        public Container(Submission__c instance, Integer index, String statusVal) {
            submission = instance;
            this.index = index;
            submissionStatusValue = statusVal;
        }
    }
}