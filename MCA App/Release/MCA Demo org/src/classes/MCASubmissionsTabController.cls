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

  private Id opportunityId;  

  public MCASubmissionsTabController() {

    opportunityId = Apexpages.currentPage().getParameters().get('id');
    opportunityObj = [Select AccountId, Id, Name from Opportunity where Id =: opportunityId ];
    submissionCntUW = 0;
    submissionCntApproved = 0;
    //submissionStatusValue = '';
    refresh();
  }

  //public Submission__c[] getSubmissions() {
  public Container[] getContainers() {
    system.debug('###con'+containers);
    Container[] copyContainers = new Container[] {};
    for(Integer i=0; i<containers.size(); i++){
         copyContainers.add(new Container(containers[i].submission, containers[i].index, containers[i].submissionStatusValue));
    }
    system.debug('##copyContainers#'+copyContainers);
    //if(declinedFlag != true){
        submissionCntUW=0;
        submissionCntApproved=0;
        submissions = new Submission__c[] {};
        containers = new Container[] {};
        system.debug('1111newsubmissions'+newSubmissions.size()+newSubmissions);
        submissions.addAll(newSubmissions);
        system.debug('1111submissions'+submissions.size()+submissions);
        submissions.addAll([SELECT
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
        submissionCount = submissions.size();
        system.debug('1111submissions'+submissions.size()+submissions); 
        system.debug('###copy'+copyContainers.size());
        Integer j=0;
        for (Integer i = 0; i < submissions.size(); i++) {
            system.debug('##inside for');
            if(copyContainers.size()>j && copyContainers[j].submission.Id == submissions[i].Id){
                system.debug('###copy!!!!!!'+copyContainers[j].submission.Id+'##'+submissions[i].Id+'##'+i);
                containers.add(new Container(submissions[i], i, copyContainers[j].submissionStatusValue));
                ++j;
            }else
                containers.add(new Container(submissions[i], i, submissions[i].Status__c));
          if(submissions[i].Status__c == 'UW')
            ++submissionCntUW;
          if(submissions[i].Status__c == 'Approved')
            ++submissionCntApproved;
        }
        system.debug('##copyContainers#'+copyContainers);
        system.debug('##Containers#'+containers);
    return containers;
  }

  public void newSubmission() {

    system.debug('--DEBUG Previous ' + newSubmissions);
    newSubmissions.add(new Submission__c(Opportunity__c = opportunityId));
    system.debug('--DEBUG After ' + newSubmissions + ' ');
  }

  public void refresh() {

    editAll = false;
    recordToDelete = null;
    //newSubmissions = new Set<Submission__c>();
    newSubmissions = new Submission__c[] {};
    containers = new Container[] {};
    system.debug('*****containers**** ' + containers);
    system.debug('*****newSubmissions**** ' + newSubmissions);     
  }

  public void editAll() {

    refresh();
    editAll = true;
  }
    
    public void save(){}

  public void saveAllSubmissions() {


    /*Submission__c[] recordsToUpdate = new Submission__c[] {};

    for (Submission__c record :submissions) {

      if (MCARecordValidator.isRecordValid(record)) {
        recordsToUpdate.add(record);
      }
    }*/
     system.debug('*****containers**** ' + containers);

    //system.debug('***submissions before recordsToUpdate***'+recordsToUpdate);
    system.debug('***submissions before upsert***'+submissions);
    upsert submissions;
    //upsert recordsToUpdate;
    system.debug('***submissions after upsert***'+submissions);

    refresh();

    system.debug('***submissions after refresh***'+submissions);
    //system.debug('***submissions after recordsToUpdate***'+recordsToUpdate);
  }

  public void deleteSubmission() {

    if (recordToDelete != null) {
      Submission__c record = [SELECT Id FROM Submission__c WHERE Id = :recordToDelete];
      delete record;
      
    }
  }

  public void removeSubmission() {

    system.debug('--DEBUG container list ' + containers + ' ');

    if (indexToRemove != null) {

      Container c = null;

      for (Container element :containers) {

        if (element.index == indexToRemove) {
          c = element;
        }
      }

      //containers.remove(c.index);
      newSubmissions.remove(c.index);
    }

  }
  
    public pageReference setSubmissionStatus() {
        //submissionStatusValue = 'Declined';
        //submissionStatusValue = Apexpages.currentPage().getParameters().get('decline');
        //if(submissionStatusValue != 'Declined')
        system.debug('##decline#'+Apexpages.currentPage().getParameters().get('decline'));
        system.debug('##index#'+Apexpages.currentPage().getParameters().get('index'));
        system.debug('******'+submissionStatusValue);
        //containers[submissionIndex].submission.Status__c = submissionStatusValue;
        containers[submissionIndex].submissionStatusValue = submissionStatusValue;
        declinedFlag = true;
        system.debug('******'+ containers[submissionIndex]);
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