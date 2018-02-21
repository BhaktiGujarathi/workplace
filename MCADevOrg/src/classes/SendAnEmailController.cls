public with sharing class SendAnEmailController {
    //Variables
    private map<Id, Decimal> mapBankWithCount;
    //private map<Id, Decimal> mapBankWithBalanceAmount;
    private map<Id,Account> mapAllBankIdWithName;
    private static final string BANK_NAME = 'Bank';
    private static final string OPPRENEWALCLOSEDLOST = 'Closed Lost';
    private static final string OPPRenewalDeclined = 'Declined';
    private static final string ContractClosedRenewed = 'Closed/Renewed';
    public string UserId;
    //Properties
    public list<RenewalWrapper> RenewalWrapperLst     {get;set;}
    public list<Contract> contractLst                 {get;set;}
    public Contract Cont                              {get;set;}
    public boolean displayPopup                       {get;set;}
    public string DelayTime                           {get;set;}
    public string RenewalEligibilityPer               {get;set;}
    public string bankName                            {get;set;}    
    public boolean showThankyouPage                   {get;set;}
    public list<Opportunity> newOppLst                {get;set;}
    public list<Task> taskLst                         {get;set;}
    public Integer cnt = 0;
    private String sortDirection = 'DESC';
    private String sortExp = 'Term_Completed__c';
    
    public list<selectOption> lstUser {get;set;}
    public String SelectedUser {get;set;}  
    public boolean displayUserPopUp {get;set;}  
    
    public boolean displayUserTaskPopUp {get;set;}
    public String SelectedUserTask {get;set;} 
    public boolean showThankyouPageTask {get;set;}
    public list<Task> newTaskLst {get;set;}
    public boolean isRendered {get;set;}
    public string DestURL {get; set;}
    public list<Submission_Mails_Detail__c> mailsDetails ;
    public string MessageBody = '';
    public static final String LOGO_NAME = Label.SubmissionWizard_LogoName;
    public static String EMAIL_LIMIT = 'EMAIL_LIMIT_EXCEEDED';
    public list<Id> accountId;
    
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
    
     public String getSortDirection()
     {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
          return 'ASC';
        else
         return sortDirection;
     }
    
     public void setSortDirection(String value)
     {  
       sortDirection = value;
     } 
    
    
    //Controller
    public SendAnEmailController(){ 
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
        accountId = new list<Id>();
        
        
            
    }//controller ends

    public void getUserList(){
        list<User> userList = [select Id,FirstName,LastName from User Where IsActive = true];
        system.debug('***userList****'+userList);
        lstUser.add(new Selectoption('--Opportunity Owner--','--Opportunity Owner--'));
        for(User objUser : userList ){
            lstUser.add(new Selectoption(objUser.Id,objUser.FirstName+' '+objUser.LastName));
        }
        
        system.debug('***lstUser****'+lstUser);
    }
    
    public void init(){
        //Initializing all parameters
        RenewalWrapperLst = new list<RenewalWrapper>();
        mapBankWithCount = new map<Id, Decimal>();
        cont = new Contract();
        displayPopup = false;
        bankName = '';
        showThankyouPage = false;
        showThankyouPageTask = false;
        newOppLst = new list<Opportunity>(); 
        taskLst = new list<Task>();
        String taskIds = '';
        String url = ApexPages.currentPage().getUrl();
        if(url.contains('taskIDs')) {              
        taskIds = ApexPages.currentPage().getParameters().get('taskIDs');
        if(taskIds!='' && taskIds.contains(','))
        {
            for (String idStr : taskIds.split(','))
                {
                    Task tsk=[select Id,Subject,OwnerId,Status,WhatId From Task where Id=: idStr];
                    taskLst.add(tsk);
                }
            }
            else{
                Task tsk=[select Id,Subject,OwnerId,Status,WhatId From Task where Id=: taskIds.trim()];
                taskLst.add(tsk);
            }
             system.debug('@@@taskLst'+taskLst);
            isRendered = true;
            showThankyouPageTask = true;
            system.debug('@@@Tasklst'+taskLst+'@@@'+ isRendered);   
            }
            else
                isRendered = false;
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        Map<String, Schema.SObjectField> filterQuery = Schema.SObjectType.Contract.fields.getMap();
        string fieldnames = ' ';
        String query ;
        displayUserPopUp = false;
        displayUserTaskPopUp = false;
        for(Schema.SObjectField s:filterQuery.values()){
            Schema.DescribeFieldResult sfield=s.getDescribe();
            system.debug('***'+s+'**'+sfield);
            if(sfield.getName() != 'BillingAddress' && sfield.getName() != 'ShippingAddress')
            fieldnames += s + ',';
        }
         fieldnames = fieldnames.substring(0,fieldnames.length()-1);
        /*query ='Select'+fieldnames+' ,Opportunity__r.Id,Opportunity__r.Date_Funded__c, Opportunity__r.OwnerId,Bank__r.Name,Opportunity__r.Funding_Amount__c, Opportunity__r.Payback_Amount__c, Opportunity__r.Term_Months__c, Opportunity__r.Bank_Name__c, Opportunity__r.Bank_Name__r.Name from '+
                 SObjectType.Contract.Name + ' where '+ 
                                SObjectType.Contract.fields.Opportunity__c.Name+' <> null AND '+ 
                                '( '+ SObjectType.Contract.fields.Opportunity_Renewal__c.Name+' = null OR '+
                                ' Opportunity_Renewal__r.StageName = \''+OPPRENEWALCLOSEDLOST+
                                '\' OR Opportunity_Renewal__r.StageName = \''+OPPRenewalDeclined+ '\') AND '+  
                                SObjectType.Contract.fields.Opportunity__c.Name+' <> null AND '+ SObjectType.Contract.fields.Stage__c.Name+' != \''+ContractClosedRenewed+'\''+
                                ' order by '+sortFullExp+' NULLS LAST'; */
                                
        query ='Select'+fieldnames+' ,Opportunity__r.Id,Opportunity__r.Date_Funded__c, Opportunity__r.OwnerId,Bank__r.Name,Opportunity__r.Funding_Amount__c, Opportunity__r.Payback_Amount__c, Opportunity__r.Term_Months__c, Opportunity__r.Bank_Name__c, Opportunity__r.Bank_Name__r.Name from '+
                 SObjectType.Contract.Name + ' where '+ 
                                + SObjectType.Contract.fields.Display_on_Manage_Renewal__c.getSobjectField()+'= true'+                              
                                ' order by '+sortFullExp+' NULLS LAST';
                                
        system.debug('***Query***'+query);
        contractLst = Database.query(query);
        mapAllBankIdWithName = new map<Id,Account>([select Name,Id 
                                                    from Account 
                                                    where RecordTypeId =:Schema.SObjectType.Account.getRecordTypeInfosByName().
                                                                         get(BANK_NAME).getRecordTypeId()]); 
        Decimal countOfBank = 0;
        Decimal balanceAmount = 0;
       
        //Passing value to wrapper list to display all renewals on page 
        for(Contract contract : contractLst){
            
            RenewalWrapperLst.add(new RenewalWrapper(contract,false));  
        }//End for
        
    }//End init method. 
    
    
    public void getContractsAfterFilter(){
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        string q;
        Map<String, Schema.SObjectField> filterQuery = Schema.SObjectType.Contract.fields.getMap();
        string fieldnames = ' ';
        String query ;
        for(Schema.SObjectField s:filterQuery.values()){
            Schema.DescribeFieldResult sfield=s.getDescribe();
            //if(string.valueof(s) != 'BillingAddress' || string.valueof(s) != 'ShippingAddress')
            if(sfield.getName() != 'BillingAddress' && sfield.getName() != 'ShippingAddress')
            {
                fieldnames += s + ',';
            }
        }
         fieldnames = fieldnames.substring(0,fieldnames.length()-1);
         query ='Select'+fieldnames+ ' ,Opportunity__r.Bank_Name__c, Opportunity__r.Date_Funded__c,Opportunity__r.OwnerId, Bank__r.Name,Opportunity__r.Funding_Amount__c, Opportunity__r.Payback_Amount__c, Opportunity__r.Term_Months__c from '+
                 SObjectType.Contract.Name;

        if((Cont.Current_Balance_Date__c != null || 
            RenewalEligibilityPer != null || 
            Cont.Anticipated_Renewal_Date__c != null ||
            Cont.Renewal_Eligibility_Days_from_funding__c != null ||
            Cont.Current_Balance_Amt__c != null ||
            Cont.Funded_Date__c != '--None--' ||
            bankName != '')){
            
            string dateString;
            cnt++;
            query += ' Where ';
            if(Cont.Current_Balance_Date__c != null){
                dateString = string.valueOf(Cont.Current_Balance_Date__c);
                query += SObjectType.Contract.fields.Current_Balance_Date__c.Name+'<= ' + dateString; 
            }
            if(RenewalEligibilityPer != null && !RenewalEligibilityPer.equalsIgnoreCase('0')){
                Integer maxRenewalEligiblePer = Integer.valueOf(RenewalEligibilityPer)+25;
                if(query.substring(query.length() - 8).contains('Where')){
                    system.debug('%%%'+RenewalEligibilityPer);
                    query += SObjectType.Contract.fields.Renewal_Eligibility_Percent__c.Name +' >= '+ (RenewalEligibilityPer.equalsIgnoreCase('1')?'0':RenewalEligibilityPer) + ' AND '+
                    SObjectType.Contract.fields.Renewal_Eligibility_Percent__c.Name + ' < '+ maxRenewalEligiblePer ;
                    system.debug('%%%'+query);
                }
                else{
                    query += ' AND ' + SObjectType.Contract.fields.Renewal_Eligibility_Percent__c.Name+' >= '+ RenewalEligibilityPer + ' AND '+
                    SObjectType.Contract.fields.Renewal_Eligibility_Percent__c.Name + ' < '+ maxRenewalEligiblePer ; 
                }
            }
            if(Cont.Anticipated_Renewal_Date__c != null){
                dateString = string.valueOf(Cont.Anticipated_Renewal_Date__c);
                if(query.substring(query.length() - 8).contains('Where')){
                     query +=SObjectType.Contract.fields.Anticipated_Renewal_Date__c.Name+' <= ' + dateString;  
                }//End if.
                else{
                    query += ' AND '+ SObjectType.Contract.fields.Anticipated_Renewal_Date__c.Name+' <= ' + dateString; 
                }//End else.
            }//End if.
            if(Cont.Funded_Date__c != null){
                String objdate;
                String dateTimeFormat; //= DateTime.now().format('yyyy-MM-dd');
                
                if(Cont.Funded_Date__c.equalsIgnoreCase('1-3 Months Ago')){
                    objdate = DateTime.now().addMonths(-3).format('yyyy-MM-dd');
                    dateTimeFormat = DateTime.now().addMonths(-1).format('yyyy-MM-dd');
                    system.debug('%%%objdate'+objdate+'%%dateTimeFormat'+dateTimeFormat);
                }
                else if(Cont.Funded_Date__c.equalsIgnoreCase('4-6 Months Ago')){
                    objdate = DateTime.now().addMonths(-6).format('yyyy-MM-dd');
                    dateTimeFormat = DateTime.now().addMonths(-4).format('yyyy-MM-dd');
                }
                else if(Cont.Funded_Date__c.equalsIgnoreCase('7-9 Months Ago')){
                    objdate = DateTime.now().addMonths(-9).format('yyyy-MM-dd');
                    dateTimeFormat = DateTime.now().addMonths(-7).format('yyyy-MM-dd');
                }
                else if(Cont.Funded_Date__c.equalsIgnoreCase('10-12 Months ago')){
                    objdate = DateTime.now().addMonths(-12).format('yyyy-MM-dd');
                    dateTimeFormat = DateTime.now().addMonths(-10).format('yyyy-MM-dd');
                }
                else if(Cont.Funded_Date__c.equalsIgnoreCase('12+ Months')){
                    objdate = DateTime.now().format('yyyy-MM-dd');
                    dateTimeFormat = DateTime.now().addMonths(-12).format('yyyy-MM-dd');
                }
                    
                if(query.substring(query.length() - 8).contains('Where')){
                    //Modified by sneha 23-05
                    query += 'Opportunity__r.Date_Funded__c <= '+ dateTimeFormat+' AND Opportunity__r.Date_Funded__c >= '+objdate;
                }//End if.
                else{
                    query += ' AND Opportunity__r.Date_Funded__c <= '+dateTimeFormat+' AND Opportunity__r.Date_Funded__c >= '+objdate;
                }
            }//End if.

            if(Cont.Bank__c != null){
                if(query.substring(query.length() - 8).contains('Where')){
                    query += 'Bank__r.Name like \'%' + String.escapeSingleQuotes(String.ValueOf(mapAllBankIdWithName.get(Cont.Bank__c).Name))+'%\'';
                }//End if.
                else{
                    query += ' AND Bank__r.Name like \'%' + String.escapeSingleQuotes(String.ValueOf(mapAllBankIdWithName.get(Cont.Bank__c).Name))+'%\'';
                }
            }//End if.
        }//End if.
        if(query.substring(query.length() - 8).contains('Where')){
            this.init();
        }
        else{
            query += ' AND ( '+ SObjectType.Contract.fields.Opportunity_Renewal__c.Name+' = null OR '+
                              ' Opportunity_Renewal__r.StageName = \''+OPPRENEWALCLOSEDLOST+
                             '\' OR Opportunity_Renewal__r.StageName = \''+OPPRenewalDeclined+ '\') AND '+  
                             SObjectType.Contract.fields.Opportunity__c.Name+' <> null AND '+ SObjectType.Contract.fields.Stage__c.Name+' != \''+ContractClosedRenewed+'\''+
                             'order by '+sortFullExp;
            
            RenewalWrapperLst.clear();
            for(Contract Contracts : Database.query(query)){
                RenewalWrapperLst.add(new RenewalWrapper(Contracts,false));
            } 
        }
    }//End getContractsAfterFilter method
    
    //Call Save method which will save changes of selected contract.
    public void save(){
        contractLst = new list<Contract>();
        list<RenewalWrapper> tempRenewalWrapperLst = new list<RenewalWrapper>();
        for(RenewalWrapper ContractWrap : RenewalWrapperLst){
            contractLst.add(ContractWrap.contract);
           
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
        Catch(Exception e){
            ApexPages.addMessages(e);
        }//End Catch
    }//End save method.
    
    //This method calls from Email Bank button.
    public void callEmailBank(){
    }
    
    //This method call from "Create Opportunites" which will change all selected contract to new opportunity.
    public PageReference createOpportunities(){
        contractLst = new list<Contract>();
        set<Id> insertedOppIds = new set<Id>();
        list<Opportunity> insertOppLst = new list<Opportunity>();
        map<String,Id> oppNumberMap = new map<String,Id>(); 
        
        for(RenewalWrapper createOppWrap : RenewalWrapperLst){
            if(createOppWrap.isSelected){
                cnt++;
                Opportunity theOpp = new Opportunity();
                theOpp.AccountId = createOppWrap.contract.AccountId;
                //theOpp.Name = 'Renewal Opp ' + createOppWrap.contract.Name;
                list<Account> accName= [select Name from Account where Id =: createOppWrap.contract.AccountId];
                theOpp.Name = 'Renewal Opp ' + accName[0].Name + ' - ' +system.today().format();
                theOpp.StageName = system.label.MovingRenewal_CreatedOppStage;
                theOpp.Contract_Auto_number_value__c = createOppWrap.contract.ContractNumber; 
                theOpp.CloseDate = system.today();
                theOpp.NextStep = system.label.MovingRenewal_CreatedOppNextStep;
                if(SelectedUser <> '--Opportunity Owner--'){
                theOpp.OwnerId = SelectedUser;
                }
                else{
                theOpp.OwnerId = createOppWrap.contract.Opportunity__r.OwnerId;
                }
                newOppLst.add(theOpp);
            }
        }
        
        if(cnt == 0){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
        }
        try{
            //To bind the inserted opportunities in individual selected contracts.
            if(newOppLst != null && newOppLst.size() > 0){
                insert(newOppLst);
                
                insertOppLst = [Select Id,Contract_Auto_number_value__c from Opportunity 
                                where Contract_Auto_number_value__c <> null];
                                
                if(newOppLst != null && newOppLst.size() > 0){
                    for(Opportunity opp : newOppLst){
                        oppNumberMap.put(opp.Contract_Auto_number_value__c, opp.Id);
                    }
                }
                for(RenewalWrapper createOppWrap : RenewalWrapperLst){
                    createOppWrap.contract.Opportunity_Renewal__c = oppNumberMap.get(createOppWrap.contract.ContractNumber);
                    contractLst.add(createOppWrap.contract);
                }
                if(contractLst != null && contractLst.size() > 0){
                    upsert contractLst;
                   // displayUserPopUp = false;
               // apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Confirm,
                                                            // System.Label.MovingRenewal_SaveSuccessful);
                //apexpages.addmessage(msg);  
                displayUserPopUp = false;
                system.debug('****isRendered***'+isRendered);
                system.debug('****showThankyouPage***'+showThankyouPage);
                if(isRendered == false && showThankyouPage == false){
                   isRendered = true;
                   showThankyouPage = true; 
                }
                    
                }
            }
        }
       
        catch(Exception e){
            return null;
        }
        system.debug('***After Catch***');
        //CloseUserPopup();
        //displayUserPopUp = false;
       // showThankyouPage = true;  
        return null;
        
    }
    
    public PageReference SendEmail(){
    
    DestURL = MCAStringConstant.baseUrlOrg+'MCAStringConstant.baseUrlOrg/apex/SendAnEmail?OpportunityId=';
    Integer coun = 0;
    for(RenewalWrapper ContractWrap : RenewalWrapperLst){
           if(ContractWrap.isSelected) 
           {
                Task task = new Task ();
                system.debug('@@ContractWrap'+ContractWrap);
                if(coun == 0){
                    DestURL+='&AccountId=';
                }
                Account acc = [Select Name, Email__c From Account where Id =: ContractWrap.contract.AccountId];
                if(coun>0)
                    DestURL+=',';
                DestURL += acc.Email__c;
                ++coun;
                task.WhatId = ContractWrap.contract.Opportunity__r.Id;
                task.Status = 'Completed';
                task.Subject = mailsDetails[0].Subject__c;
                task.Description = messageBodyContent();
                taskLst.add(task);
                //accountId = RenewalWrapperLst.split(',',0);
           }
           
        }// end of wrapper list
        //accountId = RenewalWrapperLst.split(',',0);
        return null;
    
    }
    
    /*
    public PageReference SendMail(){
        //list<Task > lstActivityHistory = new list<Task >();
        taskLst.clear();
        Integer coun = 0;
        MessageBody = messageBodyContent();
        DestURL = '/_ui/core/email/author/EmailAuthor?template_id=00X90000000gGHv';  //+opportunity.Owner_1__r.Email+'&p2='+Opportunity.Owner_1__c+'&p2_lkid='+ Opportunity.Owner_1__c;
        for(RenewalWrapper ContractWrap : RenewalWrapperLst){
           if(ContractWrap.isSelected) 
           {
                Task task = new Task ();
                system.debug('@@ContractWrap'+ContractWrap);
                if(coun == 0){
                    DestURL+='&p24=';
                }
                Account acc = [Select Name, Email__c From Account where Id =: ContractWrap.contract.AccountId];
                if(coun>0)
                    DestURL+=',';
                DestURL += acc.Email__c;
                ++coun;
                task.WhatId = ContractWrap.contract.Opportunity__r.Id;
                task.Status = 'Completed';
                task.Subject = mailsDetails[0].Subject__c;
                task.Description = messageBodyContent();
                taskLst.add(task);
           }
        }// end of wrapper list
        system.debug('@@@DestURL'+DestURL);
        if(coun == 0)
        {
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
        }
        try{
            Integer taskCount = 0;
            if(taskLst != null && taskLst.size() > 0){
                system.debug('*****taskLst inside if loop****'+taskLst);
                DestURL += '&retURL=/apex/ManageRenewal?taskIDs=';
                for(Task taskobj : taskLst ){
                    if(taskobj.ID == null)
                        insert taskobj;
                    DestURL += taskobj.ID;
                    if(taskCount < taskLst.size()-1)
                        DestURL += ',';
                    ++taskCount;
                }
                if(isRendered == false && showThankyouPageTask == false){
                           isRendered = true;
                           showThankyouPageTask = true;      
               }   
            }  
        }       
        catch(Exception e){
                if(e.getMessage() != '' && e.getMessage() != null && e.getMessage().contains(EMAIL_LIMIT)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.Submission_EmailLimitExceeded));               
                }else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));   
        }
       return new PageReference(DestURL);
       //return apexpages.currentpage();
    }
    */
    
    public PageReference sendEmailCancelBtn(){
        system.debug('***sendEmailBtn');
         for(Task taskobj : taskLst ){
                    if(taskobj.ID == null)
                        delete taskobj;
         }
         return new PageReference('/apex/ManageRenewal');
    }
    
    public String messageBodyContent(){
        List<Document> docuLst = new List<Document>();
        String query = 'Select d.SystemModstamp, d.Name, d.Id From Document d where name = \''+LOGO_NAME+'\'';
        docuLst = Database.query(query);
        if(docuLst <> null && docuLst.size()>0){
           string strOrgId = UserInfo.getOrganizationId();
           string orgInst = URL.getSalesforceBaseUrl().getHost();
           string strDocUrl = URL.getSalesforceBaseUrl().getProtocol() + '://c.' + orgInst + '/servlet/servlet.ImageServer?id=' + docuLst[0].Id + '&oid=' + strOrgId;
           String messageBody = '<html><body><div align="center"><img src="'+strDocUrl+'" alt="Company Logo"></img></div>'+mailsDetails[0].Message_Body__c+'</body></html>';
           return messageBody;
        }
        else{
           String messageBody =  mailsDetails[0].Message_Body__c; 
           messageBody = messageBody.replaceAll('<[^>]+>',' ');
           system.debug('messageBody@@@'+messageBody);
           return messageBody;
        }
        
    }
    
    
    // To open Javascript pop-up for adding delay eligibility time in renewal date.
    public void displayDelayEligibility(){
        for(RenewalWrapper PopupWrap : RenewalWrapperLst){
            if(PopupWrap.isSelected){
                cnt++;
                displayPopup = true;
            }
        }
        if(cnt == 0){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
        }
    }

    // To open Javascript pop-up for adding Create Opportunities.
    public void displayCreateOpportunities(){
        system.debug('****displayUserPopUp****'+displayUserPopUp);
        for(RenewalWrapper PopupWrap : RenewalWrapperLst){
            if(PopupWrap.isSelected){
                cnt++;
                displayUserPopUp = true;
            }
        }
        if(cnt == 0){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
        }
    }
        
    //to close the popup window
    public void ClosePopup(){
        displayPopup = false; 
    }
    
    public void CloseUserPopup(){
        displayUserPopUp = false; 
    }
    
    // To open Javascript pop-up for Follow up task 
    public void displayCreateFollowupTask(){
        system.debug('****displayUserTaskPopUp****'+displayUserTaskPopUp);
        for(RenewalWrapper PopupWrap : RenewalWrapperLst){
            if(PopupWrap.isSelected){
                cnt++;
              displayUserTaskPopUp = true;
            }
        }
        if(cnt == 0){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
        }
    }
        
    //to close the popup window
    public void ClosePopupTask(){
        displayPopup = false; 
    }
    
    public void CloseUserTaskPopup(){
        displayUserTaskPopUp = false; 
    }
    //Blank method used to refrence in actionsupport method
    public void autoPopulate1(){
        
    }
    
    //The method will delay time to 'Renewal Date' i.e Anticipated Renewal Date.
    public void delayTime() {
        contractLst = new list<Contract>();
        if(!DelayTime.equalsIgnoreCase('0')){
            integer noOFDays = Integer.valueOf(DelayTime) * 7;
            
            for(RenewalWrapper wrapper: RenewalWrapperLst){
                if(wrapper.isSelected){
                    wrapper.contract.Anticipated_Renewal_Date__c = (wrapper.contract.Anticipated_Renewal_Date__c <> null) ? 
                                                                   (wrapper.contract.Anticipated_Renewal_Date__c.addDays(noOFDays)) :
                                                                   (system.today().addDays(noOFDays));
                    contractLst.add(wrapper.contract);
                }//End if
            }//End for
            
            try{
            if(contractLst != null && contractLst.size()>0){
                upsert contractLst;
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Confirm,
                                                             System.Label.MovingRenewal_SaveSuccessful);
                apexpages.addmessage(msg);  
            }
        }catch(Exception e){
            ApexPages.addMessages(e);
        }
        }//End if
        displayPopup = false;
    }//End Delay Time method
    
     
    
    public PageReference createFollowupTask(){
        //list<User> userList = [Select u.Name, u.IsActive, u.Id From User u where u.Name =: 'MCA Development Org'];
        
        system.debug('****RenewalWrapperLst****'+RenewalWrapperLst);
        for(RenewalWrapper followupTaskWrap : RenewalWrapperLst){
            if(followupTaskWrap.isSelected){
                cnt++;
                system.debug('****cnt***'+cnt);
                Task followupTask = new Task();
                followupTask.WhatId = followupTaskWrap.contract.Id;  
                followupTask.IsReminderSet = true;
                followupTask.ReminderDateTime = system.now();
                //followupTask.OwnerId = userList[0].Id;
                if(SelectedUserTask <> '--Opportunity Owner--'){
                followupTask.OwnerId = SelectedUserTask;
                
                }
                else{
                    system.debug('***Enter In Else****');
                followupTask.OwnerId = followupTaskWrap.contract.Opportunity__r.OwnerId;
                }
                //taskLst.add(followupTask);
                list<Account> accName= [select Name from Account where Id =: followupTaskWrap.contract.AccountId];
                followupTask.Subject = 'Follow up for Renewal -'+ accName[0].Name;
                followupTask.Status = 'In Progress';
                followupTask.ActivityDate = system.today();
                taskLst.add(followupTask);
                system.debug('*****followupTask****'+followupTask);
               
            }
            
             //newTaskLst.add(taskLst);
            system.debug('*****taskLst****'+taskLst);
            
            system.debug('*****newTaskLst****'+newTaskLst);
        }
        if(cnt == 0){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,System.Label.MovingRenewal_SelectCheckboxErr);
            apexpages.addmessage(msg);
        }
        try{
            if(taskLst != null && taskLst.size() > 0){
                system.debug('*****taskLst inside if loop****'+taskLst);
                for(Task taskobj : taskLst ){
                    if(taskobj.ID == null)
                        insert taskLst;
                }
                //return new PageReference('/' + newTaskLst[0].Id);
               // apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Confirm,
                                                              //system.label.MovingRenewal_FollowupTasksCreated);
                //apexpages.addmessage(msg);  
                system.debug('****isRendered Task***'+isRendered);
                system.debug('****showThankyouPage task***'+showThankyouPageTask);
                displayUserTaskPopUp = false;
                if(isRendered == false && showThankyouPageTask == false){
                   isRendered = true;
                   showThankyouPageTask = true;      
                }           
                
            }
        }
        catch(Exception e){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,e.getMessage());
            apexpages.addmessage(msg);
            return null;
        }
        return null;
    }
    
    //Wrapper Class contains Contract Object and isSelected to keep track of which Contract is selected 
    public class RenewalWrapper{
        
        public Contract contract          {get;set;}
        public boolean isSelected         {get; set;}

        public RenewalWrapper(Contract pcontract,Boolean pIsSelected){
            
            contract = pcontract;
            isSelected = pIsSelected;
        }
        
    }
    
    //Wrapper class to display bar chart statistics of all contracts and 
    //current balance amount associated to a bank. 
    public class PieWedgeData{  
        public String name { get; set; }  
        public Decimal data { get; set; }  
        public Integer idCount { get; set; } 
        public PieWedgeData(String pName, Decimal pData){  
            this.name = pName;  
            this.data = pData;  
        }  
        public PieWedgeData(Decimal pData, Integer pidcount){  
            this.idCount = pidcount;  
            this.data = pData;  
        }  
        
   }  
   
   public PageReference ViewSortedData_Contract() {
    getContractsAfterFilter();
        return null;
   }
   
   
}