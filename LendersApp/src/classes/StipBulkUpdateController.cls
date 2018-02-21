public class StipBulkUpdateController {

    private ApexPages.StandardSetController standardController;

    public List<McaApp__Stips__c> lstStip                       {get;set;}// list for stips
    public List<StipsWrapper> stipsWrapperLst                   {get;set;}//wrapper for opportunity and selection boolean
    public Boolean myStips                                      {get;set;}//filters of stip assigned to me
    public String oppId                                         {get;set;}// parent id
    public String query;                                                  // dynamic query to be stored
    public String selectedstatus                                {get;set;}
    public String selectedstage                                 {get;set;}
    public List<Integer> indexesChanges                         {get;set;}// may be needed
    public List<String> queryStage;                                       // converting string to list
    public List<String> querystatus;                                      // converting string to list
    public Boolean parentFilter;                                          // to check for parent stage

    public StipBulkUpdateController(ApexPages.StandardSetController controller) {

        oppId = ApexPages.currentPage().getParameters().get('Id');
        this.standardController = controller;

        lstStip = new List<McaApp__Stips__c>();
        myStips = false;
        query = '';

        sObject objectname = new McaApp__Stips__c();
        //lstStip = [SELECT Id, Name, McaApp__Status__c, Completed__c, Notes__c, Interview__c FROM McaApp__Stips__c WHERE McaApp__Opportunity__c = :oppId];

        List<SBUDefaultFilters__c> sbufilterList = new List<SBUDefaultFilters__c>();

        sbufilterList = SBUDefaultFilters__c.getAll().values();

        SBUDefaultFilters__c sbuDefaultCS = sbufilterList[0];

        if (sbuDefaultCS <> null) {

            if (sbuDefaultCS.StatusFilter__c != null) {// if  status value is not null

                selectedstatus = sbuDefaultCS.StatusFilter__c;
                string defaultstatusfilter = '';

                List<String> statusInpicklist = stipStatus;
                // filtering out values if not present in picklist
                for (string status:statusInpicklist) {

                    if (sbuDefaultCS.StatusFilter__c.contains(status)) {

                        defaultstatusfilter = defaultstatusfilter + status + ',';
                    }
                }

                defaultstatusfilter = defaultstatusfilter.removeEnd(',');
                selectedstatus = defaultstatusfilter;
            }
            else {

                selectedstatus = '';
            }

            if (sbuDefaultCS.StageFilter__c == true) {

                List<Opportunity> objOpp = [SELECT Id, Underwriting_Stage__c FROM Opportunity WHERE Id=:oppId];

                if (objopp[0].Underwriting_Stage__c != null) {

                    selectedstage = objopp[0].Underwriting_Stage__c;
                    string defaultstagefilter = objopp[0].Underwriting_Stage__c;
                }
                else {

                    selectedstage = '';
                }
            }
            else {

                selectedstage = '';
            }

            myStips = sbuDefaultCS.AssigntoMe__c;
        }
        else {// if  custom setting not available

            selectedstatus = '';
            selectedstage = '';
            myStips = false;
        }

        indexesChanges = new list<integer>();
        queryStage = new list<string>();
        queryStatus = new list<string>();
    }

    // getting list of stipstages
    public List<String> stipStages {
        get {
            if (stipStages == null) {
                
                stipStages = new List<String>();
                Schema.Describefieldresult stageNameField = McaApp__Stips__c.Stage__c.getDescribe();
                List<Schema.Picklistentry> stages = stageNameField.getPickListValues();
                
                for (Schema.Picklistentry stage : stages) {

                    stipStages.add(stage.getValue());
                }
            }

            return stipStages;
        }

        private set;
    }

    //getting list of stip status
    public List<String> stipStatus {
        get {
            if (stipStatus == null) {

                stipStatus = new List<String>();
                Schema.Describefieldresult statusNameField = McaApp__Stips__c.McaApp__Status__c.getDescribe();
                List<Schema.Picklistentry> statuses = statusNameField.getPickListValues();

                for (Schema.Picklistentry status : statuses) {

                    stipStatus.add(status.getValue());
                }
            }

            return stipstatus;
        }

       private set;
    }


    // dynamic query generator
    public string queryGenerator() {

        query ='Select Id,Name,McaApp__Status__c,Stage__c,Completed__c, Notes__c, Interview__c'+
                ' FROM McaApp__Stips__c WHERE McaApp__Opportunity__c = :oppId';

        // logic for applying filters
        if (myStips != false) {//assign to me filter

            User u = [select Id, username, Email from User where Id = :UserInfo.getUserId()];
            query += ' AND Assigned_To__c =\'' + u.Id+'\'';
        }

        if (selectedstage != '') {// stage filter

            queryStage = selectedstage.split(',');
            query += ' AND Stage__C in : queryStage';
        }

        if (selectedstatus != '') {//status filter

            queryStatus = selectedstatus.split(',');
            query += ' AND McaApp__Status__c in : queryStatus';
        }

        return query;
    }

    public void init(){
        
        String stipsQuery = queryGenerator();
        stipsWrapperLst = new list<StipsWrapper>();
        
        lstStip = Database.query(stipsQuery);

        Integer index = 0;

        if (lstStip != null && !lstStip.isEmpty()) {
         
            for (McaApp__Stips__c stip : lstStip) {

                index = index++;
                stipsWrapperLst.add(new StipsWrapper(stip,(index)));
            }    
        }
    }

    //quicksave functionality for bulk stip
    public void saveStips() {

        lstStip= new list<McaApp__Stips__c>();

        for (StipsWrapper stipObj : stipsWrapperLst) {
            
            lstStip.add(stipObj.stip);
        }

        if  (lstStip != null && lstStip.size() > 0) {

            try {

                update lstStip;
                applyfilter();
            }
            catch(Exception e) {

               apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, e.getmessage());
               apexpages.addmessage(msg);
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
        mystips = false;
        init();
    }

    // update and return to opportunity
    public Pagereference updateRecords() {

        saveStips();
        return new pagereference('/' + oppId);
    }

    // wrapper class helpful in increasing scope
    public class StipsWrapper {

        public McaApp__Stips__c stip          {get;set;}
        public Integer wrapIndex              {get; set;}
        
        public StipsWrapper(McaApp__Stips__c stips,integer index) {
            
            stip = stips;
            wrapIndex = index;
        }
    }
}