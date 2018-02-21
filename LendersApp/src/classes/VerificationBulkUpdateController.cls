/*
 *  Apex controller class call from Bulk verification page to display all verification related to opportunity.
 *  Revision History:
 *  2.0               Ashwini kr. Singh      20/01/2015 to 23/01/2015            Refactored and added filters,save functionality,hold user on page functionality.
 *  2.1               Ashwini kr. Singh      01/02/2015 to 01/02/2015            Added custom setting for default filter for status  and stage and verification.
 */
public class VerificationBulkUpdateController {

    private ApexPages.StandardsetController standardController;
    public List<UWVerification__c> lstVerification              {get;set;}// list of verification
    public List<VerificationWrapper> verificationWrapperLst     {get;set;}//wrapper for opportunity and selection boolean
    public Boolean myVerifications                              {get;set;}//filters of verification assigned to me
    public String oppId                                         {get;set;}// parent id
    //public Url actionLink                                       {get;set;}// fields
    public String query;                                                  // dynamic query to be stored
    public String selectedstatus                                {get;set;}
    public String selectedstage                                 {get;set;}
    public List<Integer> indexesChanges                         {get;set;}// may be needed
    public List<String> queryStage;                                       // converting string to list
    public List<String> querystatus;                                      // converting string to list
    public Boolean parentFilter;                                          // to check for parent stage

   // constructor
    public VerificationBulkUpdateController(ApexPages.StandardsetController controller) {

        oppId = ApexPages.currentPage().getParameters().get('Id');
        query = '';
        this.standardController = controller;
        myVerifications = false;
        lstVerification = new List<UWVerification__c>();
        //lstVerification = [SELECT Id, Name, Rating__c, Status__c, Completed__c, Notes__c, Interview__c, Sort_Order__c, Action_Link__c FROM UWVerification__c WHERE Opportunity__c = :oppId ORDER BY Sort_Order__c];
        sObject objectname = new UWVerification__c();

        List<VBUDefaultFilters__c> vbufilterList = new list<VBUDefaultFilters__c>();
        vbufilterList = VBUDefaultFilters__c.getAll().values();
        VBUDefaultFilters__c vbuDefaultCS = vbufilterList[0];

        if (vbuDefaultCS <> null) {

            if (vbuDefaultCS.StatusFilter__c != null) {// if  status value is not null

                selectedstatus = vbuDefaultCS.StatusFilter__c;
                String defaultstatusfilter = '';
                List<String> statusInpicklist = verificationStatus;

                // filtering out values if not present in picklist
                for (String status : statusInpicklist) {

                    if (vbuDefaultCS.StatusFilter__c.contains(status)) {

                        defaultstatusfilter = defaultstatusfilter + status + ',';
                    }
                }

                defaultstatusfilter = defaultstatusfilter.removeEnd(',');
                selectedstatus = defaultstatusfilter;

            }
            else {

                selectedstatus = '';
            }

            if (vbuDefaultCS.StageFilter__c == true) {

                List<Opportunity> objOpp = [SELECT Id, Underwriting_Stage__c FROM Opportunity WHERE Id = :oppId];

                if (objopp[0].Underwriting_Stage__c != null) {

                    selectedstage = objopp[0].Underwriting_Stage__c;
                    String defaultstagefilter = objopp[0].Underwriting_Stage__c;
                }
                else {

                    selectedstage = '';
                }

                /*if(vbuDefaultCS.StageFilter__c!=null){
                selectedstage=vbuDefaultCS.StageFilter__c;
                string defaultstagefilter='';
                list<string> stagesInpicklist= verificationStages;
                // filtering out values if not present in picklist
                for (string stage:stagesInpicklist){
                if(vbuDefaultCS.StageFilter__c.contains(stage)){
                defaultstagefilter=defaultstagefilter+stage+',';
                }
                }
                defaultstagefilter=defaultstagefilter.removeEnd(',');
                selectedstage=defaultstagefilter;
                */
            }
            else {

                selectedstage = '';
            }

            myVerifications = vbuDefaultCS.AssigntoMe__c;

        }
        else {// if  custom setting not available

            selectedstatus = '';
            selectedstage = '';
            myVerifications = false;
        }

        indexesChanges = new List<Integer>();
        queryStage = new List<String>();
        queryStatus = new List<String>();
    }

    // getting list of verificationstages
    public List<String> verificationStages {
        get {

            if(verificationStages == null) {

                verificationStages = new List<String>();
                Schema.Describefieldresult stageNameField = UWVerification__c.Stage__c.getDescribe();
                List<Schema.Picklistentry> stages = stageNameField.getPickListValues();

                for (Schema.Picklistentry stage : stages) {

                    verificationStages.add(stage.getValue());
                }
            }

            return verificationStages;
        }

       private set;
    }

    //getting list of verification status
    public List<String> verificationStatus {

        get {
            if (verificationStatus == null) {

                verificationStatus = new List<String>();
                Schema.Describefieldresult statusNameField = UWVerification__c.Status__c.getDescribe();
                List<Schema.Picklistentry> statuses = statusNameField.getPickListValues();

                for (Schema.Picklistentry status : statuses) {

                    verificationStatus.add(status.getValue());
                }
            }

            return verificationstatus;
       }

       private set;
    }

    //quicksave functionality for bulk verification
    public void saveVerifications() {

        lstVerification = new list<UWVerification__c>();

        for (VerificationWrapper verification : verificationWrapperLst) {

            lstVerification.add(verification.verify);
        }
        if (lstVerification != null && lstVerification.size() > 0) {

            try {

                update lstVerification;
                applyfilter();
            }
            catch(exception e) {

               apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, e.getmessage());
               apexpages.addmessage(msg);
            }
        }
    }

    // dynamic query generator
    public String queryGenerator() {

        query ='Select Id,Name,Rating__c,Status__c,Stage__c,Completed__c, Notes__c, Interview__c, Sort_Order__c, Action_Link__c'+
                ' FROM UWVerification__c WHERE Opportunity__c = :oppId';

        // logic for applying filters
        if (myVerifications != false) {//assign to me filter

            User u = [SELECT Id, Username, Email FROM User WHERE Id = :UserInfo.getUserId()];
            query += ' AND OwnerId =\'' + u.Id +'\'';
        }

        if (selectedstage != '') {// stage filter

            queryStage = selectedstage.split(',');
            query += ' AND Stage__C in : queryStage';
        }
        if (selectedstatus != '') {//status filter

            queryStatus = selectedstatus.split(',');
            query += ' AND Status__C in : queryStatus';
        }

        query += ' ORDER BY Sort_Order__c'; // order by clause
        return query;
    }

    // initially on page load
    public void init() {
        
        String verificationquery = queryGenerator();
        verificationWrapperLst = new list<VerificationWrapper>();
        lstVerification = Database.query(verificationquery);
        integer index = 0;

        if (lstVerification != null && !lstVerification.isEmpty()) {
            
            for( UWVerification__c verify : lstVerification) {
                
                index = index + 1;
                verificationWrapperLst.add(new VerificationWrapper(verify,(index)));
            }
        }
        
    }

    // after applying filters may be required in future for some hold ups
    public void applyFilter() {

        init();
    }

    // clear out filters
    public void clearFilter() {

        selectedstatus = '';
        selectedstage = '';
        myVerifications = false;
        init();
    }

    // update and return to opportunity
    public Pagereference updateRecords() {

        saveVerifications();
        return new pagereference('/' + oppId);
    }

    // wrapper class helpful in increasing scope
    public class VerificationWrapper {

        public UWVerification__c verify {get;set;}
        public Integer wrapIndex {get; set;}
        
        public VerificationWrapper(UWVerification__c verification,integer index) {

            verify = verification;
            wrapIndex = Index;
        }
    }
}