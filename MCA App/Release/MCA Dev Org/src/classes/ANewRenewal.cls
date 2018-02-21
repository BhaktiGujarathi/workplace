//experimental shot 1

public with sharing class ANewRenewal {
    public list<Opportunity> oppLst                   {get;set;}//getting result from query and passing to wrapper
    public list<RenewalWrapper> renewalWrapperLst     {get;set;}//wrapper for opportunity and selection boolean
    public list<RenewalWrapper> renewalWrapperLstSel  {get;set;}//wrapper for opportunity to save selections from previous page to save view state(not to be refreshed ever)
    public map <Id,Opportunity> holdSelectedMap;                   // list of selected opportunity
    public list<RenewalWrapper> renewalWrapperLstBckup{get;set;}// jst like that
    public integer limitQuery                         {get;set;}//limit of records to show on page as per user
    public integer offsetQuery                        {get;set;}//Offset=last offset +limit ,on sort or filter set to 0 
//sort filter
    public string sortOrder                           {get;set;}//Order by clause ASC or DESC
    public string sortCriteria                        {get;set;}//field on which sorting would happen
// fiter criteria variables
    public string renewalEligibilityPer               {get;set;}//percentage compared to term%
    public boolean myDealsCheckbox                    {get;set;}//Deals
    public string renewalDateFunded                   {get;set;}//Date 
    public Opportunity oppFilter                      {get;set;}//fields of opportunity
    public string universalSearch                     {get;set;}//Search in all fields
    public boolean isFirst                            {get;set;}//boolean for setting offset 1
    private static final string BANK_NAME = 'Bank';//for account type of  bank  used in  filter
    private map<Id,Account> mapAllBankIdWithName;//list  of banks;
    public integer recordCount                        {get;set;}
    public boolean pageBlockRender                    {get;set;}
// variables for functions create opportunity button and remove opportunity and delay eligibility,task follow up
    public list<selectOption> lstUser                 {get;set;}
    public string selectedUser                        {get;set;}
    public boolean displayUserPopUp                   {get;set;}
    public static final String SELECTED_OWNER = '--Opportunity Owner--';
    public boolean showThankyouPage                   {get;set;}
    public list<Opportunity> newOppList               {get;set;}
    public boolean renderedBasePage                   {get;set;}
    public string DelayTime                           {get;set;}
    public boolean displaydelayPopUp                  {get;set;}
    public boolean displayUserTaskPopUp               {get;set;}
    public static final String TASK_SUBJECT = 'Follow up for Renewal -' ;
    //private string renewalQuery ;// as of now not needed
//constructor for Manage renewal of opportunities
    public ANewRenewal(){
        lstUser= new list<selectOption>();
        limitQuery=10;// for page size
        offsetQuery=0;
        sortCriteria='Date_Funded__c';
        sortOrder = 'ASC';
        holdSelectedMap=new map<Id,Opportunity>();
        isFirst=true;
        showThankyouPage = false;
        displayUserPopUp=false;
        renderedBasePage=true;
        displaydelayPopUp=false;
        displayUserTaskPopUp=false;
        //pageBlockRender=true;
    }
    
    public void getUserList(){ 
        list<User> userList = [select Id,FirstName,LastName from User Where IsActive = true];
        lstUser.add(new Selectoption('--Opportunity Owner--','--Opportunity Owner--'));
        for(User objUser : userList ){
            lstUser.add(new Selectoption(objUser.Id,objUser.FirstName+' '+objUser.LastName));
        }
    }
    
   public void assignOwnerTask(){
        saveRemoveOpportunity();
        if(holdSelectedMap.size()!=0){
            if (lstUser.size()==0){
                  getUserList();
              }
            displayUserTaskPopUp=true;
            selectedUser=SELECTED_OWNER;
        }else{
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, 
                                    System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
        }
   
   }
// on click of Assign  and create
    public void createFollowupTask(){
            Task followupTask;
            List<Task> listTaskToInsert = new List<Task>();
            Set<Id> setAccountId = new Set<Id>();
            // get all account record related to opp
            for(Opportunity objOpp :holdSelectedMap.values()) {
            if(objOpp.AccountId != null)
                setAccountId.add(objOpp.AccountId);
            }//End For
            Map<Id, Account> mapIdAndAccount = new Map<Id, Account>([SELECT name
                                                                 FROM Account
                                                                 WHERE Id IN :setAccountId]);
            for(Opportunity objOpp :holdSelectedMap.values()) {
                followupTask = new Task();
                followupTask.WhatId = objOpp.Id;  
                followupTask.IsReminderSet = true;
                followupTask.ReminderDateTime = system.now();
                if(selectedUser <> SELECTED_OWNER) {
                    followupTask.OwnerId = selectedUser;
                }else {
                    followupTask.OwnerId = objOpp.OwnerId;
                }//End Else - If
                if(objOpp.AccountId != null) {
                    followupTask.Subject = 
                        mapIdAndAccount.get(objOpp.AccountId) <> null ? TASK_SUBJECT + 
                                         mapIdAndAccount.get(objOpp.AccountId).Name : TASK_SUBJECT;
                } else 
                    followupTask.Subject = TASK_SUBJECT;
                followupTask.Status = 'In Progress';
                followupTask.ActivityDate = system.today();
                listTaskToInsert.add(followupTask);
                deselectOpportunity();
                applyfilter();
            }// End For
            try{
                if(!listTaskToInsert.isEmpty()){
                    insert listTaskToInsert;
                    ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.CONFIRM, 
                                                                    'Task was succesful created.');
                    ApexPages.addMessage(message);
                    displayUserTaskPopUp = false;
                    
                }
            }catch(Exception e){
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,e.getMessage());
                apexpages.addmessage(msg);
            }//End Try - catch
    }
// on click of create opportunity assign user pops up
     public void assignOwner(){
         saveRemoveOpportunity();
         selectedUser=SELECTED_OWNER;
         if(holdSelectedMap.size()!=0){
              if (lstUser.size()==0){
                  getUserList();
              }
             displayUserPopUp=true;
         }else{
             apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, 
                                    System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
         }
     }
// cancel on any popup
     public void CloseUserPopup(){
        displayUserPopUp = false;
        displaydelayPopUp= false;
        displayUserTaskPopUp=false;
    }
// creating or renewing opportunity
    public void createOpportunity(){
        newOppList =new list<Opportunity>();
        list<Opportunity> parentOpportunity = new list<Opportunity>();
        Opportunity objNewOpp ;
        Opportunity objParentOpp;
        Set<Id> setAccountId = new Set<Id>();
        for (Opportunity objOpp: holdSelectedMap.values()){
             if(objOpp.AccountId != null){
                setAccountId.add(objOpp.AccountId);
             }
        }//End For
        // Query to get account
        Map<Id, Account> mapIdAndAccount = new Map<Id, Account>([SELECT name
                                                                 FROM Account
                                                                 WHERE Id IN :setAccountId]);
// creating structure for new renewal opportunity list
        for(Opportunity objOpp :holdSelectedMap.values()){
            objNewOpp = new Opportunity();
            if(objOpp.AccountId != null) {
                objNewOpp.Name = 
                    mapIdAndAccount.get(objOpp.AccountId) <> null ? mapIdAndAccount.get(objOpp.AccountId).Name 
                        + ' - ' +system.today().format(): system.today().format();
            } else 
                objNewOpp.Name = system.today().format();
                
            objNewOpp.StageName = system.label.MovingRenewal_CreatedOppStage;
            objNewOpp.CloseDate = system.today();
            objNewOpp.NextStep = system.label.MovingRenewal_CreatedOppNextStep;
            objNewOpp.Type = 'Existing Customer - Renewal';
            objNewOpp.Previous_Opportunity1__c = objOpp.Id;

            if(selectedUser <> SELECTED_OWNER){
                objNewOpp.OwnerId = selectedUser;
            } else {
                objNewOpp.OwnerId = objOpp.OwnerId;
            }
            newOppList.add(objNewOpp);
        }
        try{
           if(newOppList != null && newOppList.size() > 0){
                insert(newOppList);
           for( Opportunity newOpp : newOppList){
                 objParentOpp=new Opportunity();
                 objParentOpp.id=newOpp.Previous_Opportunity1__c;
                 objParentOpp.Next_Opportunity__c=newOpp.id;
                 parentOpportunity.add(objParentOpp);
                }
           if(parentOpportunity != null && parentOpportunity.size() > 0)
                    update(parentOpportunity); 
                    
            displayUserPopUp = false;
                if(showThankyouPage == false){
                   showThankyouPage = true;
                   renderedBasePage= false;
                   deselectOpportunity();
                   applyfilter();
                   
                }
           }// newly created opportunity if
        }catch(DMLException e){
            apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
        
    }
    // for removing opportunity from vfpage
    public void removeOpportunity(){
     saveRemoveOpportunity();
     newOppList= new list<opportunity>();
         if(holdSelectedMap.size()!=0){
           for (Opportunity objOpp: holdSelectedMap.values()){
                 objOpp.Remove_from_Renewal_Management__c=true;
                 newOppList.add(objOpp);
           }
           try{
               if(newOppList != null && newOppList.size() > 0){
                update(newOppList);
                 deselectOpportunity();
                 applyfilter();
                 
               }
           }catch(DMLException e){
            apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
           }
                
         }else{
             apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, 
                                    System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
         }
    }
    
    // for deselecting all hold up values
     public void deselectOpportunity(){
        RenewalWrapperLst = new list<RenewalWrapper>();
        holdSelectedMap=new map<Id,Opportunity>();
     }
     
     // set delay duration
     public void delayDuration(){
         saveRemoveOpportunity();
         newOppList = new list<Opportunity>();
        if(!DelayTime.equalsIgnoreCase('0')){
            integer noOFDays = Integer.valueOf(DelayTime) * 7;
            for(Opportunity objOpp: holdSelectedMap.values() ){
                    objOpp.Estimated_Renewal_Date__c = (objOpp.Estimated_Renewal_Date__c <> null) ? 
                                               (objOpp.Estimated_Renewal_Date__c.addDays(noOFDays)) :
                                                                    (system.today().addDays(noOFDays));
                    newOppList.add(objOpp);
            }//End for
            
            try{
                if(newOppList != null && newOppList.size()>0){
                    update(newOppList);
                    apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Confirm,
                                                  System.Label.MovingRenewal_SaveSuccessful);
                    apexpages.addmessage(msg);
                    deselectOpportunity();
                    CloseUserPopup();
                    applyFilter();  
                }
            }catch(Exception e){
                ApexPages.addMessages(e);
            }
        }//End if
     }
     // for delay eligibility for selected opportunity
     public void delayOpportunity(){
        saveRemoveOpportunity();
         if(holdSelectedMap.size()!=0){
             displaydelayPopUp=true;
         }else{
             apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, 
                                    System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
         }
        
     }
    //call this function prior to any function saving the selected data in wrapper
    // also this function is called on selecting or delecting the all the check box.
    public void saveRemoveOpportunity(){
        
       for(RenewalWrapper oppSelect :renewalWrapperLst){
           if(oppSelect.isSelected==true){
                holdSelectedMap.put(oppSelect.opp.id,oppSelect.opp); 
           }
           else{
                if (holdSelectedMap.containsKey(oppSelect.opp.id)){
                    holdSelectedMap.remove(oppSelect.opp.id);
                }
           }
      }
    }
    
// functions for pagination  
    public void callFirst(){
    offsetQuery=0;
    applyFilter();
    }
    
    public void callLast(){
        if (recordCount<2000){
            offsetQuery=(recordCount - limitQuery);
        }else{
        offsetQuery=(2000 - limitQuery);
        }
        applyfilter();
    }
    
    public void callPrevious(){
        offsetQuery=(offsetQuery-limitQuery);
        applyfilter();
    }
    
    public void callNext(){
        offsetQuery=(offsetQuery+limitQuery);
        applyfilter();
    }
    
    
// function on sorting over rows
// function on adding filters
    public  void callOnSortandFilter(){
        isFirst=true;
        applyFilter();
    }
    
// called on clear filters
    public void clearFilter(){
        renewalEligibilityPer = '--None--';
        oppFilter = new Opportunity();
        myDealsCheckbox = false;
        renewalDateFunded = '--None--';
        isFirst=true;
    }
    
//called on Apply Filters or Sort or anything for creating wrapper and dynamic query
    public void applyFilter(){
        saveRemoveOpportunity();
        string renewalQuery=queryStringGen();
        // Renewal Eligibility
        string filters='';
          if(RenewalEligibilityPer != '0'){
            filters+=' AND Term_Completed__c >='+renewalEligibilityPer +
                          'AND Term_Completed__c <'+(Integer.valueOf(renewalEligibilityPer)+25); 
          }
          //RenewalDateFunded
          if(!RenewalDateFunded.equalsIgnoreCase('--None--')){
                String objdate;
                String dateTimeFormat;
                if(RenewalDateFunded.equalsIgnoreCase('1-3 Months Ago')){
                    objdate = DateTime.now().addMonths(-3).format('yyyy-MM-dd');
                    dateTimeFormat = DateTime.now().addMonths(-1).format('yyyy-MM-dd');
                }
                else if(RenewalDateFunded.equalsIgnoreCase('4-6 Months Ago')){
                    objdate = DateTime.now().addMonths(-6).format('yyyy-MM-dd');
                    dateTimeFormat = DateTime.now().addMonths(-4).format('yyyy-MM-dd');
                }
                else if(RenewalDateFunded.equalsIgnoreCase('7-9 Months Ago')){
                    objdate = DateTime.now().addMonths(-9).format('yyyy-MM-dd');
                    dateTimeFormat = DateTime.now().addMonths(-7).format('yyyy-MM-dd');
                }
                else if(RenewalDateFunded.equalsIgnoreCase('10-12 Months ago')){
                    objdate = DateTime.now().addMonths(-12).format('yyyy-MM-dd');
                    dateTimeFormat = DateTime.now().addMonths(-10).format('yyyy-MM-dd');
                }
                else if(RenewalDateFunded.equalsIgnoreCase('12+ Months')){
                    objdate = DateTime.now().format('yyyy-MM-dd');
                    dateTimeFormat = DateTime.now().addMonths(-12).format('yyyy-MM-dd');
                }
                filters += ' AND Date_Funded__c <= '+dateTimeFormat+' AND Date_Funded__c >= '+ objdate;
            }
            // by estimated renewal date
            if(oppFilter.Estimated_Renewal_Date__c!= null){
             string dateString = string.valueOf(oppFilter.Estimated_Renewal_Date__c);
                    filters += ' AND Estimated_Renewal_Date__c '+
                             ' <= '+ dateString; 
            }
            
            if(oppFilter.Bank_Name__c != null){
                // for first time getting list  of  banks
                if (mapAllBankIdWithName== null){
                // getting recordtype for bank name and its related list
                    RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName =: BANK_NAME];
                    mapAllBankIdWithName = new map<Id,Account>([select Name,Id 
                                                    from Account 
                                                    where RecordTypeId =:RecType.Id]);
                }                                   
                if(mapAllBankIdWithName.containsKey(oppFilter.Bank_Name__c)){
                        filters += ' AND Bank_Name__r.Name like \'%' + String.escapeSingleQuotes(
                                 String.ValueOf(mapAllBankIdWithName.get(oppFilter.Bank_Name__c).Name))+
                                 '%\'';
                }//End If
            }//End if.
            
             if(myDealsCheckbox != false){
                User u = [select Id, username,Email from User where Id = :UserInfo.getUserId()];
                filters += ' AND OwnerId =' + u.Id;
            }//End if.
            // filters applied
            if (isFirst== true){
                offsetQuery=0;
                isFirst=False;
            }
            
            // getting no. of records 
            string queryCount='SELECT count() FROM Opportunity where Display_on_Renewal_Management__c=true AND Remove_from_Renewal_Management__c=false' + filters;
            recordCount=(Database.countQuery(queryCount));
            renewalQuery+=filters+' ORDER BY ' + sortCriteria + ' ' +sortOrder  +' NULLS LAST limit '+ limitQuery +' offset '+ offsetQuery;
            oppLst=Database.query(renewalQuery);
            RenewalWrapperLst = new list<RenewalWrapper>();
            boolean isOppSelect=false;
            for(Opportunity opp : oppLst){
                if (holdSelectedMap.containsKey(opp.id)){
                        isOppSelect=true;
                }else{
                        isOppSelect=false;
                }
                renewalWrapperLst.add(new RenewalWrapper(opp,isOppSelect));
            }
    }

// basic mandate query();
    public string queryStringGen(){
         string renewalQuery='Select'+' StageName,Remove_from_Renewal_Management__c,Estimated_Renewal_Date__c,'+
                                    'Owner_1__c,Owner_1__r.FirstName,Owner_1__r.Email,Bank_Name__c,Bank_Name__r.Name,'+
                                    'Current_Balance_Date__c,Term_Completed__c,PaidImage__c,Current_Balance__c,'+
                                    'Next_Opportunity__c,Next_Opportunity__r.stageName,OwnerId,AccountId,Name,'+
                                    'Previous_Opportunity1__c,Display_on_Renewal_Management__c,Date_Funded__c,'+
                                    'Funding_Amount__c,Payback_Amount__c,Term_Months__c,Balance_amt__c '+
                                    'from Opportunity '+
                                    'where Display_on_Renewal_Management__c=true AND Remove_from_Renewal_Management__c=false';
         return renewalQuery;
    }
    
    // initializing function on load  of page
    public void init(){
         recordCount=[SELECT count() FROM Opportunity where Display_on_Renewal_Management__c=true AND Remove_from_Renewal_Management__c=false];
         RenewalWrapperLst = new list<RenewalWrapper>();
         clearFilter();
         string renewalQuery= queryStringGen()+' ORDER BY ' + sortCriteria + ' ' +sortOrder +' NULLS LAST limit '+limitQuery;
         oppLst=Database.query(renewalQuery);
         for(Opportunity opp : oppLst){
            renewalWrapperLst.add(new RenewalWrapper(opp,false));  
        }
    }

    //wrapper class to use on vf 
     public class RenewalWrapper{   
        public Opportunity opp          {get;set;}
        public boolean isSelected         {get; set;}
        public RenewalWrapper(Opportunity pOpp,Boolean pIsSelected){
            opp = popp;
            isSelected = pIsSelected;
        } 
    }
    
    public PageReference ViewSortedData_Contract() {
        //getContractsAfterFilter();
        return null;
    }
    
// url modification to work both in org as well as community  
    public string getbaseUrlOrg(){
        return MCAStringConstant.baseUrlOrg;
    }
}//class ends