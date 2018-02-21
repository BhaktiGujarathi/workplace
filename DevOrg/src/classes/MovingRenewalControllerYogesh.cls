/* 
 *  Apex controller class call from ManageRenewal page to display all opportunity which are moving to renewal.
 *  Revision History: 
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Neena Tiwari           26/3/2014            Initial Draft 
 *  1.1               Sneha Patil            16/04/2014           -Displayed Thankyou Page on Create Of Opportunities
 *  1.2               Neena Tiwari           22/05/2014            Changing the filter criteria to display renewals
 *  1.3               Shraddha Patil         19/07/2014           Applied sorting to table columns 
 *  1.4               Nachiket R. Deshpande  22/12/2014           Added Pop-up on Create Opportunities and Task to facilitae user
 *                                                                to choose who should be Opportunity and Task owner.
 *                                                                Added Pop-up for the same.
 *  1.5               Nachiket R. Deshpande  24/12/2014           Added Thank you page for task after tasks are created.
 *                                                                Added conditional renderiang to rerender thank you page for 
 *                                                                Task and Opportunities.
 *  1.6               Nachiket R. Deshpande  09/06/2014           Updated Functionality USING J-query Data Table to implement Pagination,
 *                                                                passed opportunity data in J-Son string to server from client and deserilized it 
 *                                                                to create list of opportunity 
 */ 
 public with sharing class MovingRenewalControllerYogesh {
    //Variables
    private map<Id,Account> mapAllBankIdWithName;
    public map<Id, Account> selectedAccountMap;
    public map<Id, User> userMap;
    private static final string BANK_NAME = 'Bank';
    public static final string missingInformation = 'Please provide the required information';
    public static final String TASK_SUBJECT = 'Follow up for Renewal -' ;
    public static final String SELECTED_OWNER = '--Opportunity Owner--' ;
    //Properties
    public list<RenewalWrapper> RenewalWrapperLst     {get;set;}
    public list<Opportunity> contractLst              {get;set;}
    public Opportunity Cont                           {get;set;}
    public boolean displayPopup                       {get;set;}
    public string DelayTime                           {get;set;}
    public string RenewalEligibilityPer               {get;set;}
    public boolean myDealsCheckbox                    {get;set;}
    public string RenewalDateFunded                   {get;set;}
    public Blob fileBody                              {get;set;}
    public string fileName                            {get;set;}   
    public string attachment_name                     {get;set;} 
    public boolean showThankyouPage                   {get;set;}
    public boolean sendAnEmail                        {get;set;}
    public boolean blnAttachmet                       {get;set;}
    public boolean blnAttachFile                      {get;set;}
    public list<Opportunity> newOppLst                {get;set;}
    public list<Task> taskLst                         {get;set;}
    public String strBody                            {get;set;} 
    public String strSubject                         {get;set;}
    public String strAdditionalTo                    {get;set;}
    public String strBcc                             {get;set;}
    public Integer cnt                                {get;set;}
    private String sortDirection = 'DESC';
    private String sortExp = 'Term_Completed__c';
    
    public list<selectOption> lstUser                 {get;set;}
    List<Attachment> lstAttachment                    {get;set;}
    public String SelectedUser                        {get;set;}  
    public boolean displayUserPopUp                   {get;set;}  
    
    public boolean displayUserTaskPopUp               {get;set;}
    public String SelectedUserTask                    {get;set;} 
    public boolean showThankyouPageTask               {get;set;}
    public boolean isRendered                         {get;set;}
    public string DestURL                             {get;set;}
    public list<Submission_Mails_Detail__c> mailsDetails ;
    public string MessageBody = '';
    public static final String LOGO_NAME = Label.SubmissionWizard_LogoName;
    public static String EMAIL_LIMIT = 'EMAIL_LIMIT_EXCEEDED';
    public list<String> ckeckedOppIdsArray            {get;set;}
    public String oppDataJson                         {get;set;} 
    public String allOppDataJson                      {get;set;} 
    public list<Opportunity> lstOppToManipulate       {get;set;}
    public list<Opportunity> lstAllOppToManipulate    {get;set;}
    public list<Opportunity> lstOppToManipulate1 ;
    public list<Opportunity> lstOppDateToManipulate   {get;set;}
    public list<Opportunity> lstAllOppDateToManipulate{get;set;}
    public Id OppRId                                  {get;set;}
    public String oppIdsToRemoveJson                  {get;set;} 
    public list<Opportunity> lstOppDataToRemove   {get;set;}
    
    public String sortExpression
    {
        get { return sortExp; }
        set
        {
   //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }
    
    public String getSortDirection() {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value) {  
        sortDirection = value;
    } 
    
    //Constructor
    public MovingRenewalControllerYogesh (){ 
        DestURL = '';
        mailsDetails = [Select Is_Active__c,
                               Message_Body__c,
                               Subject__c,
                               CC_Address__c,
                               Bcc_Address__c
                        From Submission_Mails_Detail__c 
                        where Is_Active__c= true AND Name = 'Renewal Email'];
        this.init();
        lstUser = new list<SelectOption>();
        getUserList();     
    }//Constructor ends

    public void getUserList(){ 
        list<User> userList = [select Id,FirstName,LastName from User Where IsActive = true];
        lstUser.add(new Selectoption(SELECTED_OWNER,SELECTED_OWNER));
        for(User objUser : userList ){
      lstUser.add(new Selectoption(objUser.Id,objUser.FirstName+' '+objUser.LastName));
        }
    }
    
    public void init(){
        //Initializing all parameters
        myDealsCheckbox = false;
        RenewalWrapperLst = new list<RenewalWrapper>();
        lstOppToManipulate = new list<Opportunity> ();
        lstOppToManipulate1 = new list<Opportunity> ();
        lstOppDateToManipulate = new list<Opportunity> ();
        lstOppDataToRemove = new list<Opportunity>();
        selectedAccountMap = new map<Id, Account>();
        cont = new Opportunity();
        displayPopup = false;
        sendAnEmail = false;
        blnAttachFile = false;
        showThankyouPage = false;
        showThankyouPageTask = false;
        newOppLst = new list<Opportunity>(); 
        taskLst = new list<Task>();
        strBcc = '';
        strAdditionalTo = '';
        strBody = '';
        strSubject = '';
        cnt = 0;
        String url = ApexPages.currentPage().getUrl();
        isRendered = false;
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        Map<String, Schema.SObjectField> filterQuery = 
                                                    Schema.SObjectType.Opportunity.fields.getMap();
        string fieldnames = ' ';
        String query ;
        displayUserPopUp = false;
        displayUserTaskPopUp = false;
        for(Schema.SObjectField s:filterQuery.values()){
            Schema.DescribeFieldResult sfield=s.getDescribe();
            if(sfield.getName() != 'BillingAddress' && sfield.getName() != 'ShippingAddress')
            fieldnames += s + ',';
        }
        fieldnames = fieldnames.substring(0,fieldnames.length()-1);
        
        query =  'Select'+' StageName,Remove_from_Renewal_Management__c,Estimated_Renewal_Date__c,'+
                'Owner_1__c,Owner_1__r.FirstName,Owner_1__r.Email,Bank_Name__c,'+
                'Bank_Name__r.Name,Current_Balance_Date__c,Term_Completed__c,PaidImage__c,'+
                'Balance__c,Next_Opportunity__c,Next_Opportunity__r.stageName,OwnerId,AccountId,'+
                'Name,Previous_Opportunity1__c,Display_on_Renewal_Management__c,Date_Funded__c,'+
                'Funding_Amount__c,Payback_Amount__c,Term_Months__c,Balance_amt__c from '+ 
                SObjectType.Opportunity.Name + ' where '+ 
                +SObjectType.Opportunity.fields.Display_on_Renewal_Management__c.getSobjectField()+
                ' = true order by '+sortFullExp+' NULLS LAST'+ ' LIMIT 1000';

        contractLst = Database.query(query);
        
        RecordType RecType = [Select Id 
                              From RecordType
                              Where SobjectType = 'Account' 
                              and DeveloperName = :BANK_NAME];
        mapAllBankIdWithName = new map<Id,Account>([select Name,Id 
                                                    from Account 
                                                    where RecordTypeId =:RecType.Id]); 
        Decimal countOfBank = 0;
        Decimal balanceAmount = 0;
       
        //Passing value to wrapper list to display all renewals on page 
        for(Opportunity contract : contractLst){
            RenewalWrapperLst.add(new RenewalWrapper(contract,false));  
        }//End for
    }//End init method. 
    
    public void clearFilter(){
        RenewalEligibilityPer = '--None--';
        cont = new Opportunity();
        myDealsCheckbox = false;
        RenewalDateFunded = '--None--';
        getContractsAfterFilter(); 
    }
    
    //Action Function to 
    public PageReference passValueOfSelectedOpps(){        
        if(oppDataJson <> null ) {
            lstOppDateToManipulate = (list<Opportunity>)JSON.deserialize(oppDataJson,
                                                                          list<Opportunity>.Class);
        }
        
        if(oppDataJson <> null ) {
            lstOppToManipulate = new list<Opportunity>();
            lstOppToManipulate = [Select StageName,
                                         Remove_from_Renewal_Management__c,
                                         Estimated_Renewal_Date__c,
                                         AccountId,Owner_1__c,
                                         Owner_1__r.FirstName,
                                         Owner_1__r.Email,
                                         Bank_Name__c,
                                         Bank_Name__r.Name,
                                         Current_Balance_Date__c,
                                         Term_Completed__c,
                                         PaidImage__c,
                                         Balance__c,
                                         Next_Opportunity__c,
                                         Next_Opportunity__r.stageName,
                                         OwnerId,
                                         Name,
                                         Previous_Opportunity1__c,
                                         Display_on_Renewal_Management__c,
                                         Date_Funded__c,
                                         Funding_Amount__c,
                                         Payback_Amount__c,
                                         Term_Months__c,
                                         Balance_amt__c 
                                  from Opportunity 
                                  Where ID IN :lstOppDateToManipulate];
        }
        return null;
    }
    
    public PageReference removeValueOfSelectedOpps(){
        lstOppDataToRemove.clear();
        System.debug('>>>oppIdsToRemoveJson' +oppIdsToRemoveJson);
        if(oppIdsToRemoveJson <> '[]' || oppIdsToRemoveJson <> null ) {
         lstOppDataToRemove = (list<Opportunity>)JSON.deserialize(oppIdsToRemoveJson,
                                                                          list<Opportunity>.Class);
            System.debug('>>>lstOppDataToRemove' +lstOppDataToRemove);
            for(Integer i=0;i<lstOppDataToRemove.size();i++){
                lstOppDataToRemove[i].Remove_from_Renewal_Management__c = true;
            }
            update lstOppDataToRemove;
            System.debug('>>>After update lstOppDataToRemove' +lstOppDataToRemove);
            init();
        }       
        return null;
    }
   
    //Action Function second
    public PageReference passValueOfAllOpps(){        
        if(allOppDataJson <> null ) {
            lstAllOppDateToManipulate = (list<Opportunity>)JSON.deserialize(allOppDataJson,
                    list<Opportunity>.Class);
        }
        
        if(allOppDataJson <> null ) {
            lstAllOppToManipulate = new list<Opportunity>();
            lstAllOppToManipulate = [Select StageName,
                                            Remove_from_Renewal_Management__c,
                                            Estimated_Renewal_Date__c,
                                            AccountId,
                                            Owner_1__c,
                                            Owner_1__r.FirstName,
                                            Owner_1__r.Email,
                                            Bank_Name__c,
                                            Bank_Name__r.Name,
                                            Current_Balance_Date__c,
                                            Term_Completed__c,
                                            PaidImage__c,
                                            Balance__c,
                                            Next_Opportunity__c,
                                            Next_Opportunity__r.stageName,
                                            OwnerId,
                                            Name,
                                            Previous_Opportunity1__c,
                                            Display_on_Renewal_Management__c,
                                            Date_Funded__c,
                                            Funding_Amount__c,
                                            Payback_Amount__c,
                                            Term_Months__c,
                                            Balance_amt__c 
                                    From Opportunity 
                                    Where ID IN :lstAllOppDateToManipulate];
        }
        return null;
    }//Action Function End
    
    public void getContractsAfterFilter(){
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        string q;
        Map<String, Schema.SObjectField> filterQuery = 
                                                    Schema.SObjectType.Opportunity.fields.getMap();
        string fieldnames = ' ';
        String query ;
        for(Schema.SObjectField s:filterQuery.values()){
            Schema.DescribeFieldResult sfield=s.getDescribe();
            if(sfield.getName() != 'BillingAddress' && sfield.getName() != 'ShippingAddress')
            {
                fieldnames += s + ',';
            }
        }
        fieldnames = fieldnames.substring(0,fieldnames.length()-1);
        query = 'Select'+fieldnames+ ' ,Owner_1__r.FirstName,Owner_1__r.Email, Bank_Name__r.Name,'+
                'Next_Opportunity__r.stageName from '+SObjectType.Opportunity.Name;
        query += ' Where ';
        if((RenewalEligibilityPer != '--None--' || Cont.Estimated_Renewal_Date__c != null 
                                  || RenewalDateFunded != '--None--' || myDealsCheckbox != false)){
            string dateString;
            cnt++;
            if(RenewalEligibilityPer != null && !RenewalEligibilityPer.equalsIgnoreCase('0')){
                Integer maxRenewalEligiblePer = Integer.valueOf(RenewalEligibilityPer)+25;
                if(query.substring(query.length() - 8).contains('Where')){
                    query += SObjectType.Opportunity.fields.Term_Completed__c.Name +' >= '+ 
                            (RenewalEligibilityPer.equalsIgnoreCase('1')?'0':RenewalEligibilityPer)+
                            ' AND '+SObjectType.Opportunity.fields.Term_Completed__c.Name + ' < '+ 
                            maxRenewalEligiblePer ;
                }
            }
            if(Cont.Estimated_Renewal_Date__c != null){
                dateString = string.valueOf(Cont.Estimated_Renewal_Date__c);
                if(query.substring(query.length() - 8).contains('Where')){
                    query += SObjectType.Opportunity.fields.Estimated_Renewal_Date__c.Name+' <= '+
                             dateString;
                } else{
                    query += ' AND '+SObjectType.Opportunity.fields.Estimated_Renewal_Date__c.Name+
                             ' <= '+ dateString; 
                }//End else.
            }//End if.
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
                    
                if(query.substring(query.length() - 8).contains('Where')){
                    //Modified by sneha 23-05
                    query += ' Date_Funded__c <= '+ dateTimeFormat+' AND Date_Funded__c >= '+objdate;
                } else{
                    query += ' AND Date_Funded__c <= '+dateTimeFormat+' AND Date_Funded__c >= '+ objdate;
                }
            }//End if.
            if(Cont.Bank_Name__c != null){
                if(mapAllBankIdWithName.containsKey(Cont.Bank_Name__c)){
                    if(query.substring(query.length() - 8).contains('Where')){
                        query += 'Bank_Name__r.Name like \'%' + String.escapeSingleQuotes(
                                 String.ValueOf(mapAllBankIdWithName.get(Cont.Bank_Name__c).Name))+
                                 '%\'';
                    } else{
                        query += ' AND Bank_Name__r.Name like \'%' + String.escapeSingleQuotes(
                                 String.ValueOf(mapAllBankIdWithName.get(Cont.Bank_Name__c).Name))+
                                 '%\'';
                    }
                }//End If
            }//End if.
            
            if(myDealsCheckbox != false){
                User u = [select Id, username,Email from User where Id = :UserInfo.getUserId()];
                system.debug('###user'+u);
                    if(query.substring(query.length() - 8).contains('Where')){
                        query += SObjectType.Opportunity.fields.OwnerId.Name+' = \''+u.Id + '\'';
                    } else{                        
                        query += ' AND ' + SObjectType.Opportunity.fields.OwnerId.Name + ' = \'' +
                                 u.Id + '\'';
                    }
            }//End if.
        }//End if.
        
        if(query.substring(query.length() - 8).contains('Where')){
            this.init();
        } else{
            query += ' AND '+ SObjectType.Opportunity.fields.Display_on_Renewal_Management__c.getSobjectField()
                        +' = true order by '+sortFullExp;
            RenewalWrapperLst.clear();
            for(Opportunity Contracts : Database.query(query)){
                RenewalWrapperLst.add(new RenewalWrapper(Contracts,false));
            }
        }
    }//End getContractsAfterFilter method
    
     //Call Save method which will save changes of selected contract.
    public void save(){
        contractLst = new list<Opportunity>(); 
        list<RenewalWrapper> tempRenewalWrapperLst = new list<RenewalWrapper>();
        if(lstAllOppDateToManipulate == null){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,
                   'Please Select Opportunity');
            apexpages.addmessage(msg);  
            return;
        } else{
            for(Opportunity objOpp : lstAllOppDateToManipulate){
                contractLst.add(objOpp);
            }
            try{
                if(contractLst != null && contractLst.size()>0){
                    update contractLst;
                    apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Confirm,
                                                        System.Label.MovingRenewal_SaveSuccessful);
                    apexpages.addmessage(msg);  
                    init();
                    this.getContractsAfterFilter();
                }//End if
            }//End try
            catch(Exception e){
                ApexPages.addMessages(e);
            }//End Catch
        }
    }//End save method.
    
    //This method call from "Create Opportunites" which will change 
    //all selected contract to new opportunity.
    public PageReference createOpportunities(){
        contractLst = new list<Opportunity>();
        list<Opportunity> parentOpportunity = new list<Opportunity>();
        list<Opportunity> updateOpp = new list<Opportunity>();
        Opportunity objNewOpp ;
        Set<Id> setAccountId = new Set<Id>();
        // get all account record related to opp
        for(Opportunity objOpp :lstOppToManipulate) {
            if(objOpp.AccountId != null)
                setAccountId.add(objOpp.AccountId);
        }//End For
        // Query to get account
        Map<Id, Account> mapIdAndAccount = new Map<Id, Account>([SELECT name
                                                                 FROM Account
                                                                 WHERE Id IN :setAccountId]);
        for(Opportunity objOpp :lstOppToManipulate){
            cnt++;
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
            parentOpportunity.add(objOpp);

            if(SelectedUser <> SELECTED_OWNER){
                objNewOpp.OwnerId = SelectedUser;
            } else {
                objNewOpp.OwnerId = objOpp.OwnerId;
            }
            newOppLst.add(objNewOpp);
        }//End For   
        if(cnt == 0)
            apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.Info,
                System.Label.MovingRenewal_SelectCheckboxErr));
        try{
            //To bind the inserted opportunities in individual selected contracts.
            if(newOppLst != null && newOppLst.size() > 0){
                insert(newOppLst);
                cnt = 0;
                for( Opportunity parentOpp : parentOpportunity){
                    if(newOppLst.size() >= cnt && parentOpp.Next_Opportunity__c == null){
                        parentOpp.Next_Opportunity__c = newOppLst[cnt].Id;
                        updateOpp.add(parentOpp);
                    }
                    ++cnt;
                }
                if(updateOpp != null && updateOpp.size() > 0)
                    upsert updateOpp;  
                displayUserPopUp = false;
                if(isRendered == false && showThankyouPage == false){
                    isRendered = true;
                    showThankyouPage = true; 
                }
            }//End If
        }catch(DMLException e){
            apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }// End Try - catch
        return null;
    }// End createOpportunities()
    
    public pageReference sendAnEmail() {
        taskLst.clear();
        if(strAdditionalTo == '' || strSubject == ''){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,
                                                                               missingInformation);
            apexpages.addmessage(msg);
            return null;
        }
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        Messaging.EmailFileAttachment[] fileAttachments = new Messaging.EmailFileAttachment[]{};
        Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
        List<String> senderAddress = new List<String>();
        List<String> BCCAddress = new List<String>();
        BCCAddress = strBcc.split(',');
        if(lstAttachment != null && lstAttachment.size()>0) {
            fileAttachment.setFileName(lstAttachment[0].Name);
            fileAttachment.setContentType(lstAttachment[0].ContentType);
            fileAttachment.setBody(lstAttachment[0].Body);
            fileAttachment.setInline(false);
            fileAttachments.add(fileAttachment);
        }
        cnt = 0;
        strSubject = strSubject.replace('{Account Name}', '');
        string strBody1='';
        for(Opportunity ContractWrap :lstOppToManipulate){
            Messaging.Singleemailmessage message = new Messaging.Singleemailmessage();
            message.setSaveAsActivity(true);
            if(fileAttachments != null && fileAttachments.size()>0)
                message.setFileAttachments(fileAttachments); 
            if(BCCAddress.size() > 0)    
                message.setBccAddresses(BCCAddress);
            Task task = new Task ();
            task.Status = 'Completed';
            task.Subject = strSubject;
            task.Description = strBody;
            task.OwnerId = ContractWrap.OwnerId;
            if(ContractWrap.Owner_1__c != null && ContractWrap.Owner_1__r.Email != null){ 
                senderAddress.add(ContractWrap.Owner_1__r.Email);
                message.setToAddresses(senderAddress);
                if(selectedAccountMap.containsKey(ContractWrap.Id) && selectedAccountMap.get(
                                                                         ContractWrap.Id) != null){
                    message.setSubject(strSubject+' '+(selectedAccountMap.get(ContractWrap.Id)
                                                                                           ).Name);
                } else {
                    message.setSubject(strSubject);
                }//End If -Else

                if(ContractWrap.Owner_1__c != null && (ContractWrap.Owner_1__r.FirstName != null ||
                                                         ContractWrap.Owner_1__r.FirstName != '')){
                    strBody1 = messageBodyContent(ContractWrap.Owner_1__r.FirstName,strBody,
                                                  (userMap.get(ContractWrap.OwnerId)).Name,
                                                  (userMap.get(ContractWrap.OwnerId)).CompanyName);
                    strBody1 = strBody1.replace('{Owner First Name}', '');
                    strBody1 = strBody1.replace('{Opportunity Owner} {Opportunity.Owner.Company}', 
                                                                                               '');
                } else {
                    strBody1 = messageBodyContent('',strBody,'','');
                }
                strBody1 = strBody1.replace('null', '');
                message.setHtmlBody(strBody1);
                ++cnt;
                message.setWhatId(ContractWrap.Id);
                task.WhatId = ContractWrap.Id;
                allMails.add(message);
                taskLst.add(task);
            }//End If
            senderAddress.clear();
        }//End For
        cnt=0;      
        try{
            List<Messaging.SendEmailResult> results =  Messaging.sendEmail(allMails);
            if(taskLst != null && taskLst.size()>0)
                insert taskLst;
            if(lstAttachment != null && lstAttachment.size()>0)
                insert  lstAttachment;
        }catch(Exception e){
            if(e.getMessage() != '' && e.getMessage() != null && e.getMessage().contains(
                                                                                     EMAIL_LIMIT)){
                ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.Error,system.label.Submission_EmailLimitExceeded));
            } else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
                
            strBody = displayMessageBodyContent(); 
            return null;
        }

        if(showThankyouPageTask == false && sendAnEmail == true){
            isRendered = true;
            showThankyouPageTask = true; 
            sendAnEmail = false;
        }
        return null;
    }
    
    public PageReference uploadFile(){
        blnAttachmet = true;
        blnAttachFile = false;
        lstAttachment = new list<Attachment>();
        if(fileBody != null && fileName != null ){  
            for(Opportunity contractWrap :lstOppToManipulate) {
                Attachment myAttachment  = new Attachment();
                myAttachment.Body = fileBody;
                myAttachment.Name = fileName;
                myAttachment.ParentId = contractWrap.Id;
                lstAttachment.add(myAttachment);
            }
        }
        return null;
    }
    
    public Pagereference cancelTemplate(){
        blnAttachFile = false;
        return null;
    }
    
    public List<Attachment> getAttachments(){
        blnAttachmet = true;
        return lstAttachment;
    }
    
    public void removeAttachment(){
        lstAttachment.clear();
        blnAttachmet = false;
    }//removeAttachment
    
    public void attachFile(){
        blnAttachFile = true;
    }
    
    public pageReference cancel(){
        isRendered = false;
        sendAnEmail = false;
        blnAttachmet = false;
        blnAttachFile = false;
        return new pageReference('/apex/ManageRenewal');
    }
    // It is used to send an email 
    // Note : Need to change function name.
    public PageReference SendMail(){
        cnt = 0;
        Set<Id> ownerIds = new Set<Id>();
        List<ID> lstaccountId = new List<Id>();
        // Check json null / not.
        if(oppDataJson <>'[]' ) { 
            for(Opportunity contractWrap :lstOppToManipulate) {
                    ++cnt;
                    if(contractWrap.AccountId != null)
                        lstaccountId.add(contractWrap.AccountId);
                    if(contractWrap.Owner_1__c != null)
                        strAdditionalTo += contractWrap.Owner_1__r.Email+',';
                    ownerIds.add(contractWrap.OwnerId);
            }//End For

            if(cnt != 0){
                userMap = new map<Id, User>([SELECT Name, 
                                                    LastName, 
                                                    CompanyName 
                                             FROM User
                                             WHERE Id IN :OwnerIds]);
}
            if(cnt == 0) {
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,
                                                     System.Label.MovingRenewal_SelectCheckboxErr);
                apexpages.addmessage(msg);
                return null;
            }

            if(strAdditionalTo == '') {
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,
                                  'Please specify Email Address for selected Opportunity Owner1.');
                apexpages.addmessage(msg);
                return null;
            }
            // to get the name of account in subject
            Map<Id, Account> mapOfIdANDAcc = new  Map<Id, Account>([SELECT Id, 
                                                                           Name, 
                                                                           Email__c 
                                                                    FROM Account 
                                                                    WHERE Id IN: lstaccountId]);
            for(Opportunity contractWrap :lstOppToManipulate){
                if(mapOfIdANDAcc.get(contractWrap.AccountId) <> null)
                    selectedAccountMap.put(contractWrap.Id, mapOfIdANDAcc.get(contractWrap.AccountId));
            }//End For 
            strBcc = ''+UserInfo.getUserEmail();
            if(mailsDetails[0].Subject__c != null) {
                strSubject = mailsDetails[0].Subject__c;
            }
            strBody = displayMessageBodyContent();
            isRendered = true;
            sendAnEmail = true;
        }//End If 

        if(cnt == 0){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, 
                                                     System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
        }//End If 
        return null;
    }
    
    public String displayMessageBodyContent(){
         String messageBody = '';
         messageBody =  mailsDetails[0].Message_Body__c; 
         messageBody = messageBody.replaceAll('<[^>]+>',' \r\n');
         return messageBody;
    }
    
    //It is used to set send email body
    public String messageBodyContent(String contactName, String pstrBody, String pOwnername, 
                                                                            String pOwnerCompany) {
        List<Document> docuLst = new List<Document>();
        String messageBody = '';
        String query = 'Select d.SystemModstamp, d.Name, d.Id From Document d where name = \''
                                                                                   +LOGO_NAME+'\'';
        docuLst = Database.query(query);

        if(pstrBody != null && pstrBody != '') {
            if(!docuLst.IsEmpty()) {
                String strOrgId = UserInfo.getOrganizationId();
                String orgInst = URL.getSalesforceBaseUrl().getHost();
                String strDocUrl = URL.getSalesforceBaseUrl().getProtocol() + '://c.' + orgInst + 
                                   '/servlet/servlet.ImageServer?id=' + docuLst[0].Id + 
                                   '&oid=' + strOrgId;
                // to append the contact name in an email body
                List<String> lststrBody = pstrBody.split(',',2);
                List<String> lststrBodyDetails;
                if(lststrBody.size() > 0)
                    lststrBodyDetails = lststrBody[1].split('Thanks,',2);
                if(contactName != '' && lststrBody.size() > 0 && lststrBodyDetails.size()>0)
                    messageBody = '<html><body><div align="center"><img src="'+strDocUrl+
                              '" alt="Company Logo"></img></div>'+lststrBody[0] +' '+ contactName +
                              ',<br/><br/>'+  lststrBodyDetails[0]+ '<br/><br/>'+'Thanks,<br/>'+
                              lststrBodyDetails[1] +pOwnername+' '+pOwnerCompany+'</body></html>';
                else
                    messageBody = '<html><body><div align="center"><img src="'+strDocUrl+
                                     '" alt="Company Logo"></img></div>'+pstrBody+'</body></html>';
                return messageBody;
            } else{
                messageBody =  pstrBody; 
                messageBody = messageBody.replaceAll('<[^>]+>',' \r\n');
                return messageBody;
            }// End Else - If
        }//Emd If 
        return messageBody;
    } // End messageBodyContent()
    
    
    // To open Javascript pop-up for adding delay eligibility time in renewal date.
    public void displayDelayEligibility(){
        // Check json null / not.
        if(oppDataJson <>'[]' ){
            cnt++;
            displayPopup = true;
        }
        if(cnt == 0){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, 
                                                     System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
        }
    }

    // To open Javascript pop-up for adding Create Opportunities.
    public void displayCreateOpportunities(){
        // Check json null / not.
        if(oppDataJson <>'[]' ){
            cnt++;
            displayUserPopUp = true;
        }
        if(cnt == 0){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, 
                                                     System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
            return;
        }
    }//End displayCreateOpportunities()
        
    //to close the popup window
    public void ClosePopup(){
        displayPopup = false; 
    }
    
    public void CloseUserPopup(){
        displayUserPopUp = false; 
    }
    
    // To open Javascript pop-up for Follow up task 
    public void displayCreateFollowupTask(){
        // Check json null / not.
        if(oppDataJson <>'[]' ){
            cnt++;
            displayUserTaskPopUp = true;
        }
        if(cnt == 0){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, 
                                                     System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
            return;
        }
    }
        
    //to close the popup window  Note : Need to change the function name
    public void ClosePopupTask(){
        displayPopup = false; 
    }
    // Note : Need to change the function name 
    public void CloseUserTaskPopup(){
        displayUserTaskPopUp = false; 
    }
   
    //The method will delay time to 'Renewal Date' i.e Anticipated Renewal Date.
    public void delayTime() {
        contractLst = new List<Opportunity>();
        if(!DelayTime.equalsIgnoreCase('0')) {
            Integer noOFDays = Integer.valueOf(DelayTime) * 7;
            // Procress select opportunity 
            for(Opportunity wrapper :lstOppToManipulate) {
                wrapper.Estimated_Renewal_Date__c = (wrapper.Estimated_Renewal_Date__c <> null) ? 
                                            (wrapper.Estimated_Renewal_Date__c.addDays(noOFDays)) :
                                                                (system.today().addDays(noOFDays));
                contractLst.add(wrapper);
            }//End for
            try{
                if(!contractLst.IsEmpty()){
                    upsert contractLst;
                    apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Confirm,
                    System.Label.MovingRenewal_SaveSuccessful);
                    apexpages.addmessage(msg);  
                }
            } catch(Exception e){
                ApexPages.addMessages(e);
            }
        }//End if
        displayPopup = false;
    }//End Delay Time method
    
    // create followup task for opportunity.
    public PageReference createFollowupTask() {
        Task followupTask;
        List<Task> listTaskToInsert = new List<Task>();
        Set<Id> setAccountId = new Set<Id>();
        // get all account record related to opp
        for(Opportunity objOpp :lstOppToManipulate) {
            if(objOpp.AccountId != null)
                setAccountId.add(objOpp.AccountId);
        }//End For
        
        Map<Id, Account> mapIdAndAccount = new Map<Id, Account>([SELECT name
                                                                 FROM Account
                                                                 WHERE Id IN :setAccountId]);
        // Procress select opportunity 
        for(Opportunity objOpp :lstOppToManipulate) {
            cnt++;
            followupTask = new Task();
            followupTask.WhatId = objOpp.Id;  
            followupTask.IsReminderSet = true;
            followupTask.ReminderDateTime = system.now();
            
            if(SelectedUserTask <> SELECTED_OWNER) {
                followupTask.OwnerId = SelectedUserTask;
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
        }// End For 
        
        if(cnt == 0) {
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,
                                                     System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
        }
        try{
         if(!listTaskToInsert.isEmpty()){
                insert listTaskToInsert;
                ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.CONFIRM, 
                                                                    'Task was succesful created.');
                ApexPages.addMessage(message);
                displayUserTaskPopUp = false;
                taskLst.addAll(listTaskToInsert);
            }
        }catch(Exception e){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,e.getMessage());
            apexpages.addmessage(msg);
            return null;
        }//End Try - catch
        
        cont = new Opportunity();
        getContractsAfterFilter();
        return null;
    }// End createFollowupTask()
    
    //Wrapper Class contains Contract Object and isSelected to keep track of which Contract is selected 
    public class RenewalWrapper{
        
        public Opportunity contract       {get;set;}
        public boolean isSelected         {get; set;}

        public RenewalWrapper(Opportunity pcontract,Boolean pIsSelected){
            
            contract = pcontract;
            isSelected = pIsSelected;
        }
    }
    
    public PageReference ViewSortedData_Contract() {
        getContractsAfterFilter();
        return null;
   }
}