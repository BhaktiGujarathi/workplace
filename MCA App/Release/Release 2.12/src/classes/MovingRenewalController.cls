/* 
 *  Apex controller class call from ManageRenewal page to display all opportunity which are moving to renewal.
 *  Revision History: 
 *  2.0               Ashwini kr. Singh      3/12/2015 to 18/12/2015            Refactored and redefined Manage renewal.
 */ 
public with sharing class MovingRenewalController {
    public list<Opportunity> oppLst                   {get;set;}//getting result from query and passing to wrapper
    public list<RenewalWrapper> renewalWrapperLst     {get;set;}//wrapper for opportunity and selection boolean
    public list<RenewalWrapper> renewalWrapperLstSel  {get;set;}//wrapper for opportunity to save selections from previous page to save view state(not to be refreshed ever)
    public map <Id,Opportunity> holdSelectedMap;                // list of selected opportunity
    public list<RenewalWrapper> renewalWrapperLstBckup;         //jst like that not used 
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
// variables  for mass mailing functionality
    public list<Submission_Mails_Detail__c> mailsDetails ;
    public boolean displayMailPopUp                   {get;set;}
    public string  strBcc                             {get;set;}
    public string strSubject                          {get;set;}
    public string strBody                             {get;set;}
    public list<id> massMailDefaulterList;
    public boolean blnAttachment                      {get;set;}
    public boolean blnAttachFile                      {get;set;}
    public blob fileBody                              {get;set;}
    public string fileName                            {get;set;}
    public list<Attachment> lstAttachment             {get;set;}
    public list<Task> taskLst                         {get;set;}
    public  boolean showThankyouPageTask              {get;set;}
    public list<Opportunity> lstOppToManipulate;
    public map<Id, Account> selectedAccountMap;
    public map<Id, User> userMap;
    public static String EMAIL_LIMIT = 'EMAIL_LIMIT_EXCEEDED';
//variables for pagination
    public integer limitQuery                         {get;set;}//limit of records to show on page as per user
    public integer offsetQuery                        {get;set;}//Offset=last offset +limit ,on sort or filter set to 0 
    public integer recordCount                        {get;set;}// total no. of records after filter
    public string recordDetails                       {get;set;}// to show records on page
//constructor for Manage renewal of opportunities
    public MovingRenewalController(){
        lstUser= new list<selectOption>();
        limitQuery=10;// for page size
        offsetQuery=0;
        sortCriteria='Term_Completed__c';
        sortOrder = 'DESC';
        holdSelectedMap=new map<Id,Opportunity>();
        isFirst=true;
        showThankyouPage = false;
        displayUserPopUp=false;
        renderedBasePage=true;
        displaydelayPopUp=false;
        displayUserTaskPopUp=false;
        displayMailPopUp=false;
        blnAttachment=false;
        blnAttachFile=false;
        lstAttachment = new list<Attachment>();
        taskLst=new list<Task>();
        lstOppToManipulate= new list<Opportunity>();
        selectedAccountMap = new map<Id, Account>();
        showThankyouPageTask=false;
        universalSearch='';
        //pageBlockRender=true;
    }
    public void getUserList(){ 
        list<User> userList = [select Id,FirstName,LastName from User Where IsActive = true ORDER BY FirstName nulls last, LastName ];
        lstUser.add(new Selectoption('--Opportunity Owner--','--Opportunity Owner--'));
        for(User objUser : userList ){
            lstUser.add(new Selectoption(objUser.Id,objUser.FirstName+' '+objUser.LastName));
        }
    }
//
    public void pagingDetails(){
        if(recordcount==0){
            recordDetails='No records to display matching filter criteria';
        }else if (recordcount>2000){
            recordDetails='showing records '+(offsetQuery+1)+' to '+ (offsetQuery+limitQuery)+' of top 2000 out of '+ recordcount;
        }else if((offsetQuery+limitQuery)<recordcount){
            recordDetails='showing records '+(offsetQuery+1)+' to '+ (offsetQuery+limitQuery)+' of '+ recordcount;
        }else{
            recordDetails='showing records '+(offsetQuery+1)+' to '+ recordcount +' of '+ recordcount;
        }
    }
// assign owner to  task
   public void assignOwnerTask(){
        saveRemoveOpportunity();
        if(holdSelectedMap.size()!=0){
            if (lstUser.size()==0){
                  getUserList();
              }
            displayUserTaskPopUp=true;
            displayUserPopUp = false;
            displaydelayPopUp= false;
            displayMailPopUp=false;
            selectedUser=SELECTED_OWNER;
        }else{
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, 
                                    System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
        }
   
   }
// check for mail_id for selected user
public void checkMailaddress(){
   list <Opportunity> maillist = [Select Id,StageName,Remove_from_Renewal_Management__c,Estimated_Renewal_Date__c,
                                    Owner_1__c,Owner_1__r.FirstName,Owner_1__r.Email,Bank_Name__c,Bank_Name__r.Name,
                                    Current_Balance_Date__c,Term_Completed__c,PaidImage__c,Current_Balance__c,
                                    Next_Opportunity__c,Next_Opportunity__r.stageName,OwnerId,AccountId,Name,
                                    Previous_Opportunity1__c,Display_on_Renewal_Management__c,Date_Funded__c,
                                    Funding_Amount__c,Payback_Amount__c,Term_Months__c,Balance_amt__c 
                                    from Opportunity 
                                    where Id in : holdSelectedMap.keySet()]; 
   holdSelectedMap.clear();
   for (Opportunity obj:maillist){
   holdSelectedMap.put(obj.id,obj);
   }
}

// mass mail  validation 
   public void massMailvalidation(){
    saveRemoveOpportunity();
    massMailDefaulterList=new list<id>();
    String opportunityName='';
    if(holdSelectedMap.size()!=0){
        checkMailaddress(); 
        for(Opportunity objOpp :holdSelectedMap.values()) {
           if (objOpp.Owner_1__c== null || objOpp.Owner_1__r.Email==null){
               opportunityName+='</br><a href="'+getbaseUrlOrg()+'/'+objOpp.id+'" target="_blank">'+objOpp.Name+'</a>';
               massMailDefaulterList.add(objOpp.id);
           }
        }
        if(!massMailDefaulterList.isEmpty()){
           apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.Info, 
                                                                    'Unable to find email address for owner(s) of:'+opportunityName 
                                                                    +'</br>Please deselect or add email address for owner(s).'));
        }else{
            User u = [select Id, username,Email from User where Id = :UserInfo.getUserId()];
            strBcc = ''+u.Email;
            
           mailsDetails = [Select Is_Active__c,
                               Message_Body__c,
                               Subject__c,
                               CC_Address__c,
                               Bcc_Address__c
                        From Submission_Mails_Detail__c 
                        where Is_Active__c= true AND Name = 'Renewal Email'];
          if(mailsDetails != null && mailsDetails.size() > 0){
                strSubject = mailsDetails[0].Subject__c;
                strBody ='';
                strBody =  mailsDetails[0].Message_Body__c; 
                strBody = strBody.replaceAll('<[^>]+>',' \r\n');
                displayMailPopUp=true;
                displaydelayPopUp=false;
                displayUserPopUp=false;
                displayUserTaskPopUp=false;
                renderedBasePage=false;
          }else{
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Email template of name Renewal Email is absent in the system.');
                apexpages.addmessage(msg);
          }
        }
    }else{
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, 
                                    System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
    }
   }

// sending email to users
public pageReference sendAnEmail(){
        List<Messaging.SingleEmailMessage> allmails = new List<Messaging.SingleEmailMessage>();
        taskLst.clear();
        Messaging.EmailFileAttachment[] fileAttachments = new Messaging.EmailFileAttachment[]{};
        Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
        Set<Id> ownerIds = new Set<Id>();
        if(lstAttachment != null && lstAttachment.size()>0)
        {
            fileAttachment.setFileName(lstAttachment[0].Name);
            fileAttachment.setContentType(lstAttachment[0].ContentType);
            fileAttachment.setBody(lstAttachment[0].Body);
            fileAttachment.setInline(false);
            fileAttachments.add(fileAttachment);
        }
      //  cnt = 0;
        //string strBody1=displayMessageBodyContent();
        list<id> lstaccountId= new list<Id>();
        for(Opportunity objOpp :holdSelectedMap.values()) {
            lstOppToManipulate.add(objOpp);
            lstaccountId.add(objOpp.AccountId);
            ownerIds.add(objOpp.OwnerId);
        }
        // list of account for subject
        list<Account> lstaccount = [select Id,Name, Email__c From Account where Id IN: lstaccountId];
            for(Opportunity oppObj : lstOppToManipulate){
                if(oppObj.AccountId != null){
                    for(Account acc: lstaccount){
                        if(oppObj.AccountId == acc.Id)
                            selectedAccountMap.put(oppObj.Id,acc);
                    }    
               }       
             }
        userMap = new map<Id, User>([SELECT Name, LastName, CompanyName FROM User WHERE Id IN :OwnerIds]);
        system.debug('****MovingRenewalService*****'+strSubject+strBcc+strBody);
        allMails = (new MovingRenewalService()).createSendMailRecord(fileAttachments, lstOppToManipulate, strSubject, strBcc, strBody,selectedAccountMap,userMap);
        taskLst = (new MovingRenewalService()).createTask(lstOppToManipulate,selectedAccountMap,userMap, strSubject, strBody);
        system.debug('****allMails*****'+allMails);
        try{
                List<Messaging.SendEmailResult> results =  Messaging.sendEmail(allMails);
                system.debug('@@@result'+results);
                if(taskLst != null && taskLst.size()>0)
                    insert taskLst;
                if(lstAttachment != null && lstAttachment.size()>0)
                    insert  lstAttachment;
        }
        catch(Exception e){
                if(e.getMessage() != '' && e.getMessage() != null && e.getMessage().contains(EMAIL_LIMIT)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.Submission_EmailLimitExceeded));               
                }else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));  
                strBody = displayMessageBodyContent(); 
                return null;
        }
        if(showThankyouPageTask == false && displayMailPopUp == true){
                           //renderedBasePage=true;
                           showThankyouPageTask = true; 
                           displayMailPopUp = false;
                           blnAttachment = true;
                           blnAttachFile = false;
        } 
     return null;
    }
public String displayMessageBodyContent(){
         if(mailsDetails != null && mailsDetails.size() > 0)
         {
             String messageBody = '';
             messageBody =  mailsDetails[0].Message_Body__c; 
             messageBody = messageBody.replaceAll('<[^>]+>',' \r\n');
             return messageBody;
         }
         else
         {
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Email template of name Renewal Email is absent in the system.');
                apexpages.addmessage(msg);
                return null;
         }
    }
    
  public void attachFile(){
    blnAttachFile = true;
  }
  
  public PageReference uploadFile(){
        blnAttachment = true;
        blnAttachFile = false;
        lstAttachment = new list<Attachment>();
        system.debug('---------'+ fileName);
        if(fileBody != null && fileName != null ){  
            for(Opportunity oppObj : holdSelectedMap.values()){
                    Attachment myAttachment  = new Attachment();                  
                    myAttachment.Body = fileBody;  
                    myAttachment.Name = fileName;              
                    myAttachment.ParentId = oppObj.Id;
                    lstAttachment.add(myAttachment);
                }
        }
        return null;
    }

public List<Attachment> getAttachments(){
        blnAttachment = true;
        return lstAttachment;
    }

  public void cancelTemplate(){
     blnAttachFile = false;
     blnAttachment = false;
   }
  
  public void removeAttachment(){
        lstAttachment.clear();
        blnAttachment = false;
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
             displaydelayPopUp= false;
             displayUserTaskPopUp=false;
             displayMailPopUp=false;
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
        displayMailPopUp=false;
        renderedBasePage=true;
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
                   //applyfilter();
                }
           }// newly created opportunity if
        }catch(DMLException e){
            apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
    }
    @RemoteAction
    public static void saveOpportBal(String id, string bal) {
        Opportunity oppSave= new Opportunity();
        oppSave.id=id;
        if(bal!=null){
        oppSave.Current_Balance__c=Decimal.valueOf(bal);
        }else{
        oppSave.Current_Balance__c=0;
        }
        try{
        update oppSave;
        }catch(Exception e) {
        apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
    }
    @RemoteAction
    public static void saveOpportBalDate(String id, string balDate) {
        Opportunity oppSave= new Opportunity();
        oppSave.id=id;
        if(balDate!=null){
        oppSave.Current_Balance_Date__c=Date.valueOf(balDate);
        }else{
        oppSave.Current_Balance_Date__c=null;
        }
        try{
        update oppSave;
        }catch(Exception e) {
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
             displayUserPopUp=false;
             displayUserTaskPopUp=false;
             displayMailPopUp=false;
         }else{
             apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, 
                                    System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
         }
     }
//call this function prior to any action function saving the selected data in wrapper
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
            limitquery=math.mod(recordCount, limitQuery);
            offsetQuery=(recordCount - limitQuery);
        }else{
            offsetQuery=(2000 - limitQuery);
        }
        isFirst=false;
        applyfilter();
    }
    
    public void callPrevious(){
        offsetQuery=(offsetQuery-limitQuery);
        if (offsetQuery<0)
         offsetQuery=0;
        applyfilter();
    }
    
    public void callNext(){
        offsetQuery=(offsetQuery+limitQuery);
        isFirst=false;
        applyfilter();
    }
    
// function on sorting over rows and adding filters
    public  void callOnSort(){
        isFirst=true;
        offsetQuery=0;
        applyFilter();
    }
// function on call on apply filter
public void callOnFilter(){
    isFirst=true;
        offsetQuery=0;
        holdSelectedMap=new map<Id,Opportunity>();
        renewalWrapperLst =new list<RenewalWrapper>(); 
        applyFilter();
}
    
    
// called on clear filters
    public void clearFilter(){
        holdSelectedMap=new map<Id,Opportunity>();
        renewalWrapperLst =new list<RenewalWrapper>();
        renewalEligibilityPer = '--None--';
        oppFilter = new Opportunity();
        myDealsCheckbox = false;
        renewalDateFunded = '--None--';
        isFirst=true;
        applyFilter();
    }
    
    public void genericSearch(){
    isFirst=true;
    applyfilter();
    }
//called on Apply Filters or Sort or anything for creating wrapper and dynamic query
    public void applyFilter(){
        saveRemoveOpportunity();
        string renewalQuery=queryStringGen();
        // Renewal Eligibility
        string filters='';
          if(RenewalEligibilityPer != '0' && renewalEligibilityPer!='--None--'){
            filters+=' AND Term_Completed__c >='+renewalEligibilityPer +
                          ' AND Term_Completed__c <'+(Integer.valueOf(renewalEligibilityPer)+25); 
          }
          if(universalSearch!='' && universalSearch!=null){
              filters+=' AND Generic_Search__c like \'%'+universalSearch+'%\'' ;
          }
          //RenewalDateFunded
          if(!RenewalDateFunded.equalsIgnoreCase('--None--')){
                String objdate;
                String dateTimeFormat;
                if(RenewalDateFunded.equalsIgnoreCase('1-3 Months Ago')){
                    objdate = DateTime.now().addMonths(-3).format('yyyy-MM-dd');
                    dateTimeFormat = DateTime.now().format('yyyy-MM-dd');
                }
                else if(RenewalDateFunded.equalsIgnoreCase('4-6 Months Ago')){
                    objdate = DateTime.now().addMonths(-6).format('yyyy-MM-dd');
                    dateTimeFormat = DateTime.now().addMonths(-3).format('yyyy-MM-dd');
                }
                else if(RenewalDateFunded.equalsIgnoreCase('7-9 Months Ago')){
                    objdate = DateTime.now().addMonths(-9).format('yyyy-MM-dd');
                    dateTimeFormat = DateTime.now().addMonths(-6).format('yyyy-MM-dd');
                }
                else if(RenewalDateFunded.equalsIgnoreCase('10-12 Months ago')){
                    objdate = DateTime.now().addMonths(-12).format('yyyy-MM-dd');
                    dateTimeFormat = DateTime.now().addMonths(-9).format('yyyy-MM-dd');
                }
                else if(RenewalDateFunded.equalsIgnoreCase('12+ Months')){
                    objdate = DateTime.now().format('yyyy-MM-dd');
                    dateTimeFormat = DateTime.now().addMonths(-12).format('yyyy-MM-dd');
                }
                if(objdate==DateTime.now().format('yyyy-MM-dd')){
                    filters +=' AND Date_Funded__c <= '+dateTimeFormat;
                }else{
                    filters += ' AND Date_Funded__c <= '+dateTimeFormat+' AND Date_Funded__c >'+ objdate;
                }
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
                filters += ' AND OwnerId =\'' + u.Id+'\'';
            }//End if.
            // filters applied
            if (isFirst== true){
                offsetQuery=0;
                isFirst=false;
            }else if ((offsetQuery+limitQuery)>=2000){
                offsetQuery=(2000 - limitQuery);
            }
            // getting no. of records 
            system.debug('filterssssssssssssss'+ filters);
            string queryCount='SELECT count() FROM Opportunity where Display_on_Renewal_Management__c=true AND Remove_from_Renewal_Management__c=false' + filters;
            recordCount=(Database.countQuery(queryCount));
            pagingDetails();// call to get paging details
            transient string secondCriteria=',NAME ASC,ID ASC';
            if (sortCriteria=='NAME'){
                secondCriteria=',ID ASC';
            }
            renewalQuery+=filters+' ORDER BY ' + sortCriteria + ' ' +sortOrder  +' '+secondCriteria +' NULLS LAST limit '+ limitQuery +' offset '+ offsetQuery;
            system.debug('renewalQuery+++++++++++++'+renewalQuery);
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
             if (recordCount>2000){
                apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.Info, 
                                                                    'Showing only top 2000 data out of '+recordCount 
                                                                    +'. Please apply more filters to find more specific data'));
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
         pagingDetails();
         RenewalWrapperLst = new list<RenewalWrapper>();
        renewalEligibilityPer = '--None--';
        oppFilter = new Opportunity();
        myDealsCheckbox = false;
        renewalDateFunded = '--None--';
        isFirst=true;
         string renewalQuery= queryStringGen()+' ORDER BY ' + sortCriteria + ' ' +sortOrder +', NAME ASC, ID ASC ' +' NULLS LAST limit '+limitQuery;
         oppLst=Database.query(renewalQuery);
         for(Opportunity opp : oppLst){
            renewalWrapperLst.add(new RenewalWrapper(opp,false));
        }
        if (recordCount>2000){
            apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.Info, 
                                                                    'Showing only top 2000 data out of '+recordCount 
                                                                    +'. Please apply more filters to find more specific data'));
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
// url modification to work both in org as well as community  
    public string getbaseUrlOrg(){
        return MCAStringConstant.baseUrlOrg;
    }
}//class ends