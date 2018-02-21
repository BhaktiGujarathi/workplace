public with sharing class MCAStipsTabController {

    public Stips__c[] stips;
    public Stips__c[] newStips {get; set;}
    public Container[] containers;

    public Opportunity opportunity {get; set;}
    public Boolean editAll {get;set;}
    public Integer noOpenStips {get;set;}
    public Id recordToDelete {get;set;}
    public Integer indexToRemove {get;set;}
    private Id opportunityId;
    public string DestURL {get; set;}
    public string openStips {get; set;}
    private string PENDING = 'Pending';
    private string REQUESTED = 'Requested';
    public Integer stipsOpenCnt {get;set;}
    public Integer stipsCloseCnt {get;set;}

    public List<Submission__c> submissionlist {get; Set;}
    public Integer subSize {get; set;}
    public Boolean editmode {get; set;}
    public Boolean isFirst;
    public Boolean isUpdated;
    public Map<Id, Stips__c> mapIDANDStips;
    public List<Stips__c> listToUpdate;
    public Map<Id, Submission__c> mapIDANDSubmission;
    public Set<Integer> setInvalidRow;
    public Set<Id> listSubmissionId;
    public Boolean isValidation;
    Map<Integer, Integer> mapOfIndex;

    public MCAStipsTabController() {
        isFirst = true;
        isValidation = false;
        listSubmissionId =new Set<ID>();
        setInvalidRow = new Set<Integer>();
        mapIDANDStips = new Map<Id, Stips__c>();
        mapOfIndex = new Map<Integer, Integer>();
        opportunityId = Apexpages.currentPage().getParameters().get('id');
        opportunity = new Opportunity();
        opportunity = [Select Id, Name, Open_Stips__c, Owner_1__c,Owner_1__r.Email, OwnerId from Opportunity where Id=:opportunityId ];
        openStips = 'SELECT count() FROM Stips__c WHERE Opportunity__c = :'+ opportunityId +' AND  (Status__c = '+ PENDING + ' OR Status__c = '+REQUESTED+')';
        refresh();
        if(system.Label.McaGrid_EmailStips == 'Opportunity Owner')
        DestURL = '/_ui/core/email/author/EmailAuthor?p3_lkid='+opportunity.Id+'&retURL=%2F'+opportunity.Id+'&template_id='+system.Label.Email_Stips_Template_Id+'&p24='+[select Email, Id From User where Id =: opportunity.OwnerId].Email;
        else
        DestURL = '/_ui/core/email/author/EmailAuthor?p3_lkid='+opportunity.Id+'&retURL=%2F'+opportunity.Id+'&template_id='+system.Label.Email_Stips_Template_Id+'&p2='+Opportunity.Owner_1__c+'&p2_lkid='+ Opportunity.Owner_1__c;
        system.debug('*******'+DestURL);
        stipsOpenCnt = 0;
        stipsCloseCnt = 0;
        editmode = false;
    }

    public Stips__c[] getStips() {
        isFirst = false;
        stips = new Stips__c[] {};
        stips.addAll(newStips);
        mapIDANDStips.clear();
        
        mapIDANDStips = new Map<Id, Stips__c>([SELECT
                                                    Id,
                                                    Recv_d__c,
                                                    Name,
                                                    Type__c,
                                                    Status__c,
                                                    Requested_by__c,
                                                    Date_Requested__c,
                                                    Requirement__c,
                                                    Submission__c,
                                                    Submission__r.Name,
                                                    Submission__r.Status__c,
                                                    Submission__r.Funder__c,
                                                    Submission__r.Funder__r.Name,
                                                    Notes__c
                                                FROM Stips__c
                                                WHERE Opportunity__c = :opportunityId]);
        stips.addAll(mapIDANDStips.values());

        return stips;
    }
    
    public void getSubmissionID() {
         List<Submission__c> listSubmmision = [SELECT Id 
                                                FROM Submission__c
                                                WHERE Opportunity__c = :opportunityId];
        for(Submission__c objSubm : listSubmmision){
            listSubmissionId.add(objSubm.id);
        }
    }
    public Container[] getContainers() {
        stipsOpenCnt = 0;
        stipsCloseCnt = 0;
        stips = new Stips__c[] {};
        String subName;     
        getSubmissionMap();
        getSubmissionID();
        if(isFirst && !editAll && !isValidation && setInvalidRow.size() <= 0){    
            stips.addAll(getStips());
        } else {
            stips.addAll(newStips);
            for (Container containerVal: containers) {
                if(containerVal.index != indexToRemove){
                    if(!listSubmissionId.contains(containerVal.stip.Submission__c))
                        containerVal.stip.Submission__c = null;
                    stips.add(containerVal.stip);
                }
            }
        }
        system.debug('stips----->'+stips);
        indexToRemove = -1;
        containers = new Container[] {};
        Submission__c objSubmission = new Submission__c();
        for (Integer i = 0; i < stips.size(); i++) {
            if(stips[i].Submission__c != null){
                
                if(mapIDANDSubmission.get(stips[i].Submission__c) != null) {
                    objSubmission = mapIDANDSubmission.get(stips[i].Submission__c);
                    subName = objSubmission.Name;
                    if(setInvalidRow.contains(i - newStips.size())){
                        containers.add(new Container(stips[i], i, (objSubmission.Funder__c!=null?objSubmission.Funder__r.Name+'-':'')
                        +(objSubmission.Status__c!=null?objSubmission.Status__c+'-':'')+'('+subName.substring(4,subName.length())+')', true));
                    } else {
                        containers.add(new Container(stips[i], i, (objSubmission.Funder__c!=null?objSubmission.Funder__r.Name+'-':'')
                            +(objSubmission.Status__c!=null?objSubmission.Status__c+'-':'')+'('+subName.substring(4,subName.length())+')', false));
                    }
                }else{
                    if(setInvalidRow.contains(i - newStips.size()))
                        containers.add(new Container(stips[i], i,'', true));
                    else
                        containers.add(new Container(stips[i], i,'', false));
                }
            }
            else{
                if(setInvalidRow.contains(i - newStips.size()))
                    containers.add(new Container(stips[i], i,'', true));
                else
                    containers.add(new Container(stips[i], i,'', false));
            }
            if(stips[i].Status__c == 'Pending' || stips[i].Status__c == 'Requested')
                ++stipsOpenCnt;
            if(stips[i].Status__c == 'Completed')
                ++stipsCloseCnt;
        }
        newStips = new List<Stips__c>();
        getSubmissionNames();
        return containers;
    }
    
    public pageReference test(){
        getContainers();
        return null;
    }

    public void save(){

    }
    public void getSubmissionMap(){
        mapIDANDSubmission = new Map<Id, Submission__c> ([Select Id, Name,Funder__c,Funder__r.Name, Status__c FROM Submission__c where Opportunity__c =: opportunityId]);
    }
    
    public List<SelectOption> getSubmissionNames(){
        getSubmissionMap();
        List<SelectOption> options = new List<SelectOption>();
        submissionlist = new List<Submission__c>();
        submissionlist = mapIDANDSubmission.values();
        subSize = submissionlist.size();
        options.add(new SelectOption('','--None--'));
        for (Integer j=0;j<submissionlist.size();j++){
            String subName = submissionlist[j].Name;
            options.add(new SelectOption(submissionlist[j].Id,submissionlist[j].Funder__r.Name+'-'+submissionlist[j].Status__c+'-('+subName.substring(4,subName.length())+')'));
        }
        return options;
    }



    public void newStip() {
        saveMessage();
        newStips.add(new Stips__c(Opportunity__c = opportunityId, Type__c = 'Stip', Status__c = 'Pending', Date_Requested__c = system.today()));
    }
    public void saveMessage(){
        isUpdated = false;
        checkoldAndNewVal();
        if(editAll !=true && isUpdated == true){
            
            updateInlineEditedValue();
        }
    }
    public void updateInlineEditedValue() {
        String msgStr = '';
        setInvalidRow.clear();
        try{
            //update listToUpdate;
            List<Database.saveResult> results = Database.update(listToUpdate, false);
            for (Integer i= 0; i< results.size(); i++) {
              if (!results[i].isSuccess()){
                  for (Database.Error err : results[i].getErrors()){
                      msgStr = msgStr + 'Error: '+ err.getMessage() + ' For record with serial number : ' +(mapOfIndex.get(i) +1) + '<br />';
                      setInvalidRow.add(mapOfIndex.get(i));
                  }
              }
            }
           if(!msgStr.contains('Argument 2 cannot be null') && String.isNotBlank(msgStr)) 
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,msgStr));
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'All changes have been saved.'));
        }
        catch(Exception e){
            system.debug('***Enter In Exception****');
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
    }
    
    public void checkoldAndNewVal() {
        listToUpdate = new List<Stips__c>();
        Stips__c stipsValue = new Stips__c();
        List<Stips__c> listStip = getStips();
        mapOfIndex.clear();
        for (Container containerVal: containers) {
            if(containerVal.stip.id != null){
                stipsValue = mapIDANDStips.get(containerVal.stip.id);
                if(stipsValue != null) {
                    if(containerVal.stip.Name != stipsValue.Name
                    || containerVal.stip.Status__c != stipsValue.Status__c
                    || containerVal.stip.Date_Requested__c != stipsValue.Date_Requested__c
                    || containerVal.stip.Submission__r.Name != stipsValue.Submission__r.Name
                    || containerVal.stip.Recv_d__c != stipsValue.Recv_d__c
                    || containerVal.stip.Notes__c != stipsValue.Notes__c
                    || containerVal.stip.Submission__c != stipsValue.Submission__c) {
                            listToUpdate.add(containerVal.stip);
                            mapOfIndex.put(listToUpdate.size() - 1, containerVal.index);
                            isUpdated = true;
                    }
                }
            }
        }
    }
    public void afterSave() {
        isFirst = true;
        recordToDelete = null;
        editAll = false;
        newStips = new Stips__c[] {};
    }
    public void refresh() {
        setInvalidRow.clear();
        afterSave();
    }

    public void saveAllStips() {
        String msgStr = '';
        isValidation = false;
        setInvalidRow.clear();
        try{
            //upsert stips;
            List<Database.upsertResult> results = Database.upsert(stips, false);
            for (Integer i =0; i< results.size(); i++) {
               if (!results[i].isSuccess()){
                  for (Database.Error err : results[i].getErrors()){
                      msgStr = msgStr + 'Error: ' + err.getMessage() + ' For record with serial number : ' +(containers[i].index +1) + '<br />';
                      setInvalidRow.add(i);
                  }
               }
            }
            if(!msgStr.contains('Argument 2 cannot be null') && String.isNotBlank(msgStr)) 
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,msgStr));
        }
        catch(Exception e){
            isValidation = true;
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
        afterSave();
    }
    
    public void editAll() {
        refresh();
        editAll = true;
    }
    public void removeStips() {
        saveMessage();
    }
    public void deleteStip() {
        saveMessage();
        if (recordToDelete != null) {
            Stips__c record = [SELECT Id FROM Stips__c WHERE Id = :recordToDelete];
            try {
                delete record;
            }catch (Exception ex){
                indexToRemove = -1;
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
            }
        }
    }
    public void inlineedit(){
        if(editmode == false)
            editmode = true;
    }  

    public class Container {
        public Stips__c stip {get;set;}
        public Integer index {get;set;}
        public String submissionName {get; set;}
        public Boolean isedited {get;set;}
        public Container(Stips__c instance, Integer index, String pSubmissionName, Boolean isedited) {
            stip = instance;
            this.index = index;
            this.submissionName = pSubmissionName;
            this.isedited = isedited;
        }
    }
}