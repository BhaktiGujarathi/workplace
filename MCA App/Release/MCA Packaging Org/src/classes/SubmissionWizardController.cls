/* 
 *  Description - Controller for Submission Wizard Page
 *   
 *  Date - 10-02-2014
 *  
 *  Created by - Sneha P.
 *  Modified by - Shraddha P.
 */
global with sharing class SubmissionWizardController {
     
    private Boolean prefferedPgm; 
    private list<Attachment> attachmentList;
    public map<Id,Program__c> programMap;
    User userObj = [Select LastName, FirstName, CompanyName From User where id=:userinfo.getuserid()];
    //Properties
    public Opportunity opp                               {get; set;}
    public Id OppId                                      {get; set;}
    public String pAccId                                 {get; set;}
    public list<Program__c> applicationSentToPgm         {get; set;} //list stores the pgms to which the applications are sent
    public list<Program__c> applicationNotSentToPgm      {get; set;} //list stores the pgms to which the applications are not sent
    public boolean showThankYouPage                      {get; set;}
    public Program__c program                            {get; set;}
    public list<ProgramWrapper> programWrapperList       {get; set;} 
    public list<ProgramWrapper> programWrapperList1       {get; set;}
    public list<AttachmentWrapper> AttachmentWrapperList {get; set;} 
    public boolean displayPopup                          {get; set;}   
    public map<String,list<String>> prgmDocMap           {get; set;}
    public String var                                    {get; set;}
    public static String sortDirection = 'DESC';
    public static String sortExp = 'score';
    public String prevSortExp = '';
    public String prevSortdire = '';
    public string MessageBody = '';
    public list<Submission_Mails_Detail__c> mailsDetails ;
    public static final String LOGO_NAME = Label.SubmissionWizard_LogoName;
    public static String EMAIL_LIMIT = 'EMAIL_LIMIT_EXCEEDED';
    public static String channelVal                     {get; set;}
    public string empty='';
    public integer limitval  {get;set;}
    public integer limitvalCnt = 1;
    public string orgWideEmailAddress;
    public boolean isOrgWideEmailAllowed;
    public decimal countSubmissions ;
    public boolean noExceptionForSubmissionCounter;
    public boolean restrictedIndustry                    {get; set;}
    public boolean restrictedState                       {get; set;}
    public set<String> oppStages;
    public string creditScore                           {get; set;}
    public string yearInBusiness                        {get; set;}
    public string minMonthlyDeposite                    {get; set;}
    public string minDepositeCount                      {get; set;}
    public string minAvgDailyBalance                    {get; set;}
    public string maxNSFs                               {get; set;}
    public string maxNDBs                               {get; set;}
    public Boolean prefferedProgram                     {get; set;}
    //public String check= 'Unckeck';
    //public String countPrograms = label.CountOfProgram;
    public String sortExpression
    {
         get { return sortExp; }
         set
         { 
           //if the column is clicked on then switch between Ascending and Descending modes
           if (value == sortExp || prevSortExp == value){
             sortDirection = (prevSortdire == 'ASC' )? 'DESC' : 'ASC';
           }
           else
             sortDirection = 'ASC';
           sortExp = value;
           prevSortExp = value;
           prevSortdire = sortDirection;
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

    public List<SelectOption> getStates()
    {
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult = Program__c.Restricted_States__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       options.add(new SelectOption('--None--','--None--'));
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }

    //Constructor
    public SubmissionWizardController(){
        channelVal = '';
        creditScore = '';
        yearInBusiness = '';
        minMonthlyDeposite = '';
        minDepositeCount = '';
        minAvgDailyBalance = '';
        maxNSFs = '';
        maxNDBs = '';
        noExceptionForSubmissionCounter=true;
        var = '';
        limitval = 15;        
        opp = new Opportunity();
        showThankYouPage = false;
        displayPopup = false;
        //program = new Program__c();
        prgmDocMap = new map<String,list<String>>();
        programWrapperList = new list<ProgramWrapper>();
        programWrapperList1 = new list<ProgramWrapper>();
        attachmentList = new list<Attachment>();
        programMap = new Map<Id,Program__c>();
        applicationSentToPgm = new list<Program__c>();
        applicationNotSentToPgm = new list<Program__c>();
        AttachmentWrapperList = new list<AttachmentWrapper>();
        
        prefferedPgm = true;
        mailsDetails = new List<Submission_Mails_Detail__c>(); 
         
        OppId = ApexPages.currentPage().getParameters().get('Id');
        pAccId = ApexPages.currentPage().getParameters().get('accId');

        oppStages = new set<String>{'Prospecting','Application Sent','Application In',
                                        'Application Missing Info','Declined',
                                        'Closed Lost','Renewal Prospecting','Renewal Requested'};

        //Get the Opportunity 
        Opp = [Select Total_Loan_Balance__c,
                      No_of_Funders__c,
                      Credit_Score__c,
                      Gross_monthly_Sales__c, 
                      AccountId,
                      StageName,
                      Amount_Requested__c,
                      Credit_Card_Sales__c,
                      Average_Daily_Balance__c,
                      Avg_Number_Bank_Deposits__c,
                      NSFs_avg__c,
                      NDBs_avg__c,
                      Account.Credit_Card_Sales__c,
                      Account.Name,
                      Account.Number_Bank_Statements_Available__c,
                      Account.Number_CC_Statements_Available__c,
                      Account.Monthly_CC_Avg_All__c,
                      Account.Monthly_Bank_Deposit_Avg_All__c,
                      Account.NumberofLocations__c,
                      Account.Gross_monthly_Sales__c,
                      Account.Industry,
                      Account.Years_in_Business__c,
                      Account.BillingState,
                      Submission_Counter__c,
                      Submission_Notes__c
                      from Opportunity where Id =: OppId];
                      system.debug('****countSubmissions before***'+Opp.Submission_Counter__c);
                      if(Opp.Submission_Counter__c == null){
                         countSubmissions = 0;
                      }
                      else{
                        countSubmissions = Opp.Submission_Counter__c;
                      }
                      system.debug('****countSubmissions before 1***'+countSubmissions);
        mailsDetails = [Select Is_Active__c,
                               Message_Body__c,
                               Subject__c,
                               CC_Address__c,
                               Bcc_Address__c
                        From Submission_Mails_Detail__c 
                        where Is_Active__c= true AND (Subject__c = 'New Submission' OR Name = 'Submission Email')];
        if(Opp.Credit_Score__c !=null) {
            creditScore = string.valueOf(Opp.Credit_Score__c);
        }
        
        if(Opp.Account.Years_in_Business__c != null) {
            yearInBusiness = string.valueOf(Opp.Account.Years_in_Business__c);
        }
        
        if(Opp.Gross_monthly_Sales__c != null) {
            minMonthlyDeposite = string.valueOf(Opp.Gross_monthly_Sales__c);
        }
        
        if(Opp.Avg_Number_Bank_Deposits__c != null) {
            minDepositeCount = string.valueOf(Opp.Avg_Number_Bank_Deposits__c);
        }
        
        if(Opp.Average_Daily_Balance__c != null) {
            minAvgDailyBalance = string.valueOf(Opp.Average_Daily_Balance__c);
        }
        
        if(Opp.NSFs_Avg__c != null) {
            maxNSFs = string.valueOf(Opp.NSFs_Avg__c);
        }
        
        if(Opp.NDBs_Avg__c != null) {
            maxNDBs = string.valueOf(Opp.NDBs_Avg__c);
        }
        
        if(Opp.Account.Industry != null)
            restrictedIndustry = true;
        if(Opp.Account.BillingState != null)
            restrictedState = true;
        //program.Preffered_Programs__c = true;

        this.getPrograms();
        OrgwideEmailAddress__c customSetting = OrgwideEmailAddress__c.getInstance('SubmissionOrgWideEmail');
        if(customSetting != null){
            isOrgWideEmailAllowed = customSetting.IsOrgwideEmailAllowed__c;  
            orgWideEmailAddress =  customSetting.OrgEmailAddress__c;}
        system.debug('isOrgWideEmailAllowed '+isOrgWideEmailAllowed );
    }

    public void closePopup() {
        displayPopup = false;
    }

    public boolean getMapSize(){
        if(prgmDocMap.size() == 0)
            return true;
        else
            return false; 
    }

    public void clearFilter(){
        creditScore = '';
        yearInBusiness = '';
        minMonthlyDeposite = '';
        minDepositeCount = '';
        minAvgDailyBalance = '';
        maxNSFs  = '';
        maxNDBs = '';
        restrictedIndustry = false;
        restrictedState = false;
        prefferedProgram = false;
        this.getPrograms();
    }

    public PageReference openAttachment(){
        
        String pgRef =Page.OppMultipleAttachment.getUrl()+'?id='+OppId+'&retURL='+Page.SubmissionWizard.getUrl()+'?id='+OppId+'&accId='+pAccId;
        return new PageReference(pgRef);
    }
    
    public boolean checknull(string str) {
        if(str != null && str != '') {
            return true;
        }
        else {
            return false;
        }
    }
    //get the programs to display on Submission Wizard page
    public void getPrograms(){
        
        programMap.clear();
        programWrapperList.clear();
        programWrapperList1.clear();
        String query = 'Select Bank__r.Name,Bank__r.Main_Contact__c,Bank__r.Main_Contact__r.Name,'+
                         SObjectType.Program__c.fields.Name.Name + ','+
                         SObjectType.Program__c.fields.Bank__c.Name + ','+
                         SObjectType.Program__c.fields.Submission_Email__c.Name + ','+
                         SObjectType.Program__c.fields.Industry__c.Name + ','+
                         SObjectType.Program__c.fields.Max_No_NSFs__c.Name + ','+
                         SObjectType.Program__c.fields.Credit_Score__c.Name + ','+
                         SObjectType.Program__c.fields.Years_in_Business__c.Name + ','+
                         SObjectType.Program__c.fields.Min_Monthly_Deposits__c.Name + ','+
                         SObjectType.Program__c.fields.Max_Amount__c.Name + ',' +
                         SObjectType.Program__c.fields.Commission_Percentage__c.Name + ',' +
                         SObjectType.Program__c.fields.Preffered_Programs__c.Name + ',' +
                         SObjectType.Program__c.fields.Submission_Email_CC_1__c.Name + ',' +
                         SObjectType.Program__c.fields.Submission_Email_CC_2__c.Name + ',' +
                         SObjectType.Program__c.fields.Restricted_States__c.Name + ',' +
                         SObjectType.Program__c.fields.Restricted_Industry_List__c.Name + ',' +
                         SObjectType.Program__c.fields.Minimum_Deposit_Count__c.Name + ',' +
                         SObjectType.Program__c.fields.Max_NDBs__c.Name + ',' +
                         SObjectType.Program__c.fields.Min_Avg_Daily_Bal__c.Name + ',' +
                         SObjectType.Program__c.fields.Funding_Amt_of_Monthly_Gross_Sales__c.Name+' from '+
                         SObjectType.Program__c.Name; 

        if( checknull(creditScore) || 
            checknull(yearInBusiness) || 
            restrictedIndustry != false ||
            checknull(minMonthlyDeposite) || 
            checknull(maxNSFs) ||
            restrictedState != false || 
            prefferedProgram != false ||
            checknull(minDepositeCount) || 
            checknull(minAvgDailyBalance)||
            checknull(maxNDBs) )
            query += ' Where '; 

        if(checknull(creditScore)){
             //program.Credit_Score__c +=10;
            query += SObjectType.Program__c.fields.Credit_Score__c.Name+' <= '+ decimal.valueOf(creditScore);
        }
        if(checknull(yearInBusiness)){
            if(checknull(creditScore))
                query += ' and ';
            query += SObjectType.Program__c.fields.Years_in_Business__c.Name+' <= '+decimal.valueOf(yearInBusiness);
        }
        if(restrictedIndustry != false){
            if(checknull(creditScore) || checknull(yearInBusiness))
                query += ' and ';
            query += SObjectType.Program__c.fields.Restricted_Industry_List__c.Name+' excludes (\''+Opp.Account.Industry+'\') ';
        }
        if(checknull(minMonthlyDeposite)){
            if(checknull(creditScore) || checknull(yearInBusiness) || restrictedIndustry != false)
                query += ' and ';
            query += SObjectType.Program__c.fields.Min_Monthly_Deposits__c.Name+' <= '+ decimal.valueOf(minMonthlyDeposite);
        }
        if(checknull(minDepositeCount)){
            if(checknull(creditScore) || checknull(yearInBusiness) || restrictedIndustry != false || checknull(minMonthlyDeposite)
              )
                query += ' and ';
            query += SObjectType.Program__c.fields.Minimum_Deposit_Count__c.Name+' <= '+decimal.valueOf(minDepositeCount);
        }
        if(checknull(maxNSFs)){
            if(checknull(creditScore) || checknull(yearInBusiness)|| restrictedIndustry != false ||checknull(minMonthlyDeposite) ||checknull(minDepositeCount))
                query += ' and ';
            query += SObjectType.Program__c.fields.Max_No_NSFs__c.Name+' >= '+decimal.valueOf(maxNSFs);
        }
        if(restrictedState != false){
            if(checknull(creditScore) || checknull(yearInBusiness) || restrictedIndustry != false || checknull(minMonthlyDeposite) ||checknull(minDepositeCount) || checknull(maxNSFs))
                query += ' and ';
            query += SObjectType.Program__c.fields.Restricted_States__c.Name+'  excludes (\''+Opp.Account.BillingState+'\') ';
        }
        if(prefferedProgram != false){
            if(checknull(creditScore) || checknull(yearInBusiness) || restrictedIndustry != false || checknull(minMonthlyDeposite) || checknull(maxNSFs) || restrictedState != false || checknull(minDepositeCount))
                query += ' and ';
            query += SObjectType.Program__c.fields.Preffered_Programs__c.Name+' = '+prefferedProgram;
        }
        if(checknull(maxNDBs)){
            if(checknull(creditScore) || checknull(yearInBusiness) || restrictedIndustry != false || checknull(minMonthlyDeposite) || checknull(maxNSFs) || restrictedState != false ||
            checknull(minDepositeCount) || prefferedProgram == true)
                query += ' and ';                
            query += SObjectType.Program__c.fields.Max_NDBs__c.Name+' >= '+decimal.valueOf(maxNDBs);
        }
        if(checknull(minAvgDailyBalance)){
            if(checknull(creditScore) || checknull(yearInBusiness) || restrictedIndustry != false ||checknull(minMonthlyDeposite)|| checknull(maxNSFs) || restrictedState != false ||checknull(minDepositeCount) || prefferedProgram == true ||checknull(maxNDBs))
                query += ' and ';
            query += SObjectType.Program__c.fields.Min_Avg_Daily_Bal__c.Name+' <= '+decimal.valueOf( minAvgDailyBalance);
        }
        
        if(sortExpression!='Score'){
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        query += ' order by '+sortFullExp;
        }
        //programList = Database.query(query);  
        list<Program__c> lstProgram = new list<Program__c> ();
        //query += ' LIMIT '+ limitval;
        
        lstProgram = Database.query(query);
        
        
        map<Id,Submission__c> mapOfSubmissionStatus = new map<Id,Submission__c>([SELECT Program__c, Status__c FROM Submission__c WHERE Program__c IN :lstProgram]);
        
        for(Program__c prgm : lstProgram){
            var='';
            //programMap.put(prgm.Id,prgm);
            Decimal score = 0; 
            Integer totalScore = 0;

            if(prgm.Credit_Score__c <= opp.Credit_Score__c)
                        var += 'Credit_Score__c'; 
            if(prgm.Years_in_Business__c <= Opp.Account.Years_in_Business__c)
                        var += 'Years_in_Business__c';
            if(prgm.Min_Monthly_Deposits__c <= Opp.Gross_monthly_Sales__c)
                        var += 'Min_Monthly_Deposits__c';
            if(prgm.Max_No_NSFs__c >= Opp.NSFs_Avg__c)
                        var += 'NSFs_Avg__c';
            if(prgm.Min_Avg_Daily_Bal__c <= Opp.Average_Daily_Balance__c)
                        var += 'Min_Avg_Daily_Bal__c';
            if(prgm.Max_NDBs__c >= Opp.NDBs_Avg__c)
                        var += 'Max_NDBs__c';
            if(prgm.Minimum_Deposit_Count__c <= Opp.Avg_Number_Bank_Deposits__c)
                        var += 'Minimum_Deposit_Count__c';
           

            // to calculate Matching %      
            if(checknull(creditScore) ){
                totalScore++;
                //system.debug('###program.Credit_Score__c'+program.Credit_Score__c);
                if(prgm.Credit_Score__c == decimal.valueOf(creditScore)){
                    score++; 
                    
                }
            }
            if(checknull(yearInBusiness)){
                totalScore++;
                if( prgm.Years_in_Business__c == decimal.valueOf(yearInBusiness) ){
                    score++;
                   
                }
            }
            if(checknull(minMonthlyDeposite) ){
                totalScore++;
                if( prgm.Min_Monthly_Deposits__c == decimal.valueOf(minMonthlyDeposite) ){
                      score++;
                }
            }  
            if(checknull(minAvgDailyBalance)){
                totalScore++;
                if( prgm.Min_Avg_Daily_Bal__c == decimal.valueOf(minAvgDailyBalance) ){
                      score++;
                }
            }
            if(checknull(minDepositeCount) ){
                totalScore++;
                if( prgm.Minimum_Deposit_Count__c == decimal.valueOf(minDepositeCount)){
                      score++;
                }
            }
            if(checknull(maxNSFs )){
                totalScore++;
                if( prgm.Max_No_NSFs__c == decimal.valueOf(maxNSFs)){
                      score++;
                      system.debug('###score-Max_No_NSFs__c'+score);
                }
            }
            if(checknull(maxNDBs ) ){
                totalScore++;
                if( prgm.Max_NDBs__c == decimal.valueOf(maxNDBs) ){
                      score++;
                }
            }
            /*if(restrictedIndustry != false ){
                totalScore++;
                if( prgm.Industry__c == program.Industry__c)
                {
                     score++;
                }
            }*/
            if(prefferedProgram != false){
                totalScore++;
                if( prgm.Preffered_Programs__c == prefferedProgram ){
                     score++;
                }
            }
            
            if(score != 0)
                score = ((score  / totalScore) *100);

            // Calculate Eligible Funding Amount= Gross Monthly Sales * Fun Amt - % of monthly gross sales
            Decimal eligibleFunAmt; 
            if(Opp.Account.Gross_monthly_Sales__c != null && prgm.Funding_Amt_of_Monthly_Gross_Sales__c != null)
                eligibleFunAmt = (Opp.Account.Gross_monthly_Sales__c * prgm.Funding_Amt_of_Monthly_Gross_Sales__c)/100;
            else
                eligibleFunAmt = 0;
            
            programWrapperList.add(new ProgramWrapper(prgm, false, Integer.valueOf(score), 
                                                          eligibleFunAmt, (totalScore < 2 ? true : false ),var));   
             
        }
        
        this.getAvailableAttachments();
        
        prefferedPgm = false;   
        if(sortExpression=='Score')
            programWrapperList.sort();
            
        Integer initialSize = programWrapperList.size()>15 ? 15 : programWrapperList.size();
        for(Integer i=0; i<initialSize; ++i){
            if(programWrapperList!= null && programWrapperList.size() > 0 && programWrapperList[i] !=null){
                programWrapperList1.add(programWrapperList[i]);
                }
        }
    }
    
    public void getAvailableAttachments(){
        Integer cnt = 1;
        AttachmentWrapperList.clear();
        attachmentList = [Select Name, Id,ContentType,
                                     Description,ParentId  From Attachment 
                                     where ParentId =: pAccId or ParentId =: OppId];
            
        for(Attachment attachmnt : attachmentList){
            AttachmentWrapperList.add(new AttachmentWrapper(cnt++,attachmnt,
                                                            true,programMap));
        }
    }
    
    public void checkReqdDocument(){
        displayPopup = true; 
                selectDeselectAtt1();
        prgmDocMap.clear();   
        
        // Query all the Document records of selected programs and display them 
        for(Required_Documents__c reqdDoc : [Select Name,Program__c,Program__r.Name from Required_Documents__c 
                                                    where Program__c IN: programMap.keySet()
                                                    order by Program__r.Name,Name]){
            if(prgmDocMap.isEmpty() || (!prgmDocMap.isEmpty() && !prgmDocMap.containsKey(reqdDoc.Program__r.Name)))
                prgmDocMap.put(reqdDoc.Program__r.Name, new list<String>{reqdDoc.Name});
            else if(prgmDocMap.containsKey(reqdDoc.Program__r.Name))
                prgmDocMap.get(reqdDoc.Program__r.Name).add(reqdDoc.Name);
        }
    }
    
    // Function to Create Submission and Update Chatter w/o sending Email
    public void createWithoutSending(){
        channelVal = 'Create without Sending';
        
        countSubmissions = countSubmissions + 1;
        
        selectDeselectAtt1();
        if(programMap.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Select Program')); 
            return;
        }
        
        list<Submission__c> submissionList = new list<Submission__c>();
        for(Id pgmId : programMap.keySet()){
        
               Submission__c tempSub = createSubmission(programMap.get(pgmId).Bank__r.Main_Contact__c,
                                                                                programMap.get(pgmId).Bank__c,
                                                                                pgmId,
                                                                                programMap.get(pgmId).Submission_Email__c);
                tempSub.SubmissionWizard_Counter__c = countSubmissions;
                submissionList.add(tempSub);
                applicationSentToPgm.add(programMap.get(pgmId));
        }
        try{
                        if(submissionList.size() > 0){
                                insert submissionList;
                                system.debug('***submissionList***'+submissionList);
                                Opportunity tempOpp = new Opportunity(id=oppId);
                                if(opp.StageName == 'Prospecting' || opp.StageName == 'Application Sent' || opp.StageName == 'Application In' ||
                opp.StageName == 'Application Missing Info' || opp.StageName == 'Declined' || opp.StageName == 'Closed Lost' ||
                opp.StageName == 'Renewal Prospecting' || opp.StageName == 'Renewal Requested' )
                {
                        
                       // update (new Opportunity (Id = oppId ,StageName = 'Underwriting'));
                       tempOpp.StageName='Underwriting';
                }
                
                tempOpp.Submission_Counter__c = countSubmissions;
                update tempOpp;
               // update (new Opportunity (Id = oppId , Submission_Counter__c = countSubmissions));
                                postOnChatter(null);
                                showThankyouPage = true;
            }
        }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage())); 
        }
    }// End CreateWithoutSending
    
    public void sendSelectedAttachments(){
    try{
            channelVal = 'Send with Attachments';
            countSubmissions = countSubmissions + 1;
           
            selectDeselectAtt1();
            //Create a map of programs n list of attachments
            map<Id,list<Attachment>> mapPgmAttachment = new map<Id,list<Attachment>>();
            for(AttachmentWrapper wrapper : AttachmentWrapperList){
                //If the Attachment is required then only send the attachment
                if(wrapper.isRequired){
                    for(String pgm : wrapper.selectedPrograms){
                        
                        if(mapPgmAttachment.isEmpty() || (!mapPgmAttachment.isEmpty() && !mapPgmAttachment.containsKey((Id)pgm))){
                            
                            mapPgmAttachment.put((Id)pgm, new list<Attachment>{wrapper.attachment});
                        }else
                            mapPgmAttachment.get((Id)pgm).add(wrapper.attachment);
                    }   
                }
            }
            
            if(AttachmentWrapperList.isEmpty()){
                noExceptionForSubmissionCounter=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'There are no Attachments for Submission'));        
            }
            else if(mapPgmAttachment.isEmpty()){
                noExceptionForSubmissionCounter=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.label.Submission_SelectProgram));    
            }
            else if(mailsDetails.isEmpty()){
                noExceptionForSubmissionCounter=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.label.Submission_TemplateMissingError)); 
                
                return;   
            }
            else{
                this.sendMail(mapPgmAttachment);
            }
        
        
        }
        catch(Exception e)
        {  noExceptionForSubmissionCounter=false;
          
        }
        
      if(noExceptionForSubmissionCounter)
        {
         update new Opportunity(id=oppId ,Submission_Counter__c = countSubmissions);
        
        }
    }
    
    public void sendWithoutAttachment(){
        channelVal = 'Send without Attachments';
        countSubmissions = countSubmissions + 1;
        selectDeselectAtt1();
        if(mailsDetails.isEmpty()){
            noExceptionForSubmissionCounter=false; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.label.Submission_TemplateMissingError)); 
            return;
        }
        try{
            list<Submission__c> submissionList = new list<Submission__c>();
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
                
            if(programMap.isEmpty()){
                noExceptionForSubmissionCounter=false; 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.label.Submission_SelectProgram)); 
                return;
                
            }
            for(Id pgmId: programMap.keySet()){
                if(!programMap.isEmpty() && programMap.get(pgmId).Submission_Email__c <> null ){
    
                    Messaging.EmailFileAttachment[] fileAttachments = new Messaging.EmailFileAttachment[]{};
                    //Creating Messaging.Singleemailmessage instance to create a message.
                    Messaging.Singleemailmessage message = new Messaging.Singleemailmessage();
                    
                    List<String> senderAddresses = new List<String>();
                    List<String> senderOrgEmailAddresses = new List<String>();
                    List<String> CCAddress = new List<String>();
                    List<String> BCCAddress = new List<String>();
                    
                    
                    if(mailsDetails <> null && mailsDetails[0].CC_Address__c <> null && mailsDetails[0].CC_Address__c <> '' &&
                                                                   mailsDetails[0].CC_Address__c.contains('@')){
                        CCAddress = mailsDetails[0].CC_Address__c.split(',');
                    }
                   
                    if(programMap.get(pgmId).Submission_Email_CC_1__c <> null && programMap.get(pgmId).Submission_Email_CC_1__c <> ''){
                        CCAddress.add(''+programMap.get(pgmId).Submission_Email_CC_1__c);
                    }
                    
                    if(programMap.get(pgmId).Submission_Email_CC_2__c <> null && programMap.get(pgmId).Submission_Email_CC_2__c <> ''){
                        CCAddress.add(''+programMap.get(pgmId).Submission_Email_CC_2__c);
                    }
                    
                    if(mailsDetails <> null && mailsDetails[0].Bcc_Address__c <> null && mailsDetails[0].Bcc_Address__c <> '' && 
                                                                  mailsDetails[0].Bcc_Address__c.contains('@') ){
                        BCCAddress = mailsDetails[0].Bcc_Address__c.split(',');
                    }
                   
                    if(programMap.get(pgmId).Submission_Email__c <> null){
                        senderAddresses.add(programMap.get(pgmId).Submission_Email__c); //Adding Email Id.
                    }
                    
                    if(isOrgWideEmailAllowed == true){
                        OrgWideEmailAddress owea = [select Id,Address from OrgWideEmailAddress where Address =: orgWideEmailAddress];
                        senderOrgEmailAddresses.add(owea.Address);
                        message.setOrgWideEmailAddressId(owea.Id);
                    }
                    if(senderAddresses.size()>0)
                        message.setToAddresses(senderAddresses);
                    if(CCAddress.size()>0)
                        message.setCcAddresses(CCAddress);
                    if(BCCAddress.size()>0)
                        message.setBccAddresses(BCCAddress);
                    String Subject = '';
                    if(opp.AccountId != null)
                    Subject = mailsDetails[0].Subject__c + ': ' + opp.Account.Name;
                    else
                    Subject = mailsDetails[0].Subject__c;
                    
                    message.setSubject(Subject);
                    
                    MessageBody = messageBodyContent();
                    
                    message.setHtmlBody(MessageBody); 
                    //Send the Attachment Email to Banks Email address
                    allMails.add(message);
                    
                    Submission__c tempSub = createSubmission(programMap.get(pgmId).Bank__r.Main_Contact__c,
                                                                                programMap.get(pgmId).Bank__c,
                                                                                pgmId,
                                                                                programMap.get(pgmId).Submission_Email__c);
                    tempSub.SubmissionWizard_Counter__c = countSubmissions;
                    submissionList.add(tempSub);
                    
                    applicationSentToPgm.add(programMap.get(pgmId));
                }else if(programMap.get(pgmId).Submission_Email__c == null){
                    applicationNotSentToPgm.add(programMap.get(pgmId));
                }
            }
            
            if(applicationNotSentToPgm.size() > 0)
            {
              
               noExceptionForSubmissionCounter =false;
            }
            if(allMails.size() > 0 && submissionList.size() > 0 ){
                  
                
                 List<Messaging.SendEmailResult> results =  Messaging.sendEmail(allMails); 
                 postOnChatter(null);
                insert submissionList;
                //After the mail has been sent show a thankyou Page
                showThankYouPage = true;
                if(opp.StageName == 'Prospecting' || opp.StageName == 'Application Sent' || opp.StageName == 'Application In' ||
                opp.StageName == 'Application Missing Info' || opp.StageName == 'Declined' || opp.StageName == 'Closed Lost' ||
                opp.StageName == 'Renewal Prospecting' || opp.StageName == 'Renewal Requested' )
                {
                        update (new Opportunity (Id = oppId ,StageName = 'Underwriting'));
                }
            }else{
                //No email sent
                showThankYouPage = true;
            }
        }//try ends
        catch(Exception e){
                if(e.getMessage() != '' && e.getMessage() != null && e.getMessage().contains(EMAIL_LIMIT)){ 
                noExceptionForSubmissionCounter=false; 
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.Submission_EmailLimitExceeded));    
                                  
                }else{
                noExceptionForSubmissionCounter=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));   
                }
        }
        
        if(noExceptionForSubmissionCounter)
        {
         update new Opportunity(id=oppId ,Submission_Counter__c = countSubmissions);
        }
    }
    
    public void sendMail(map<Id,list<Attachment>> mapPgmAttachment){
   
        try{
            map<Id,Attachment> attachmentMap2 =new map<Id,Attachment>([Select Name, Id,ContentType,
                                                                             Body,
                                                                             Description,ParentId  From Attachment 
                                                                             where ParentId =: pAccId or ParentId =: OppId]);

            list<Submission__c> submissionList = new list<Submission__c>();
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
            String accName = [Select Account.Name from Opportunity where Id =: oppId ].Account.Name;
            //Send an Email to banks email Id
            for(Id pgmId : mapPgmAttachment.keySet()){
                 
                 if(programMap.get(pgmId).Submission_Email__c <> null){
                    
                    Messaging.EmailFileAttachment[] fileAttachments = new Messaging.EmailFileAttachment[]{};
                    //Creating Messaging.Singleemailmessage instance to create a message.
                    Messaging.Singleemailmessage message = new Messaging.Singleemailmessage();

                    for( Attachment att: mapPgmAttachment.get(pgmId)){
                        //Creating Messaging.EmailFileAttachment instance to create file attachment.
                        Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
                        fileAttachment.setFileName(att.Name);
                        fileAttachment.setContentType(att.ContentType);
                        fileAttachment.setBody(attachmentMap2.get(att.Id).Body);
                        fileAttachment.setInline(false);
                        
                        // Add the created attachment to the Messaging Attachments
                        fileAttachments.add(fileAttachment);
                    }//End if.

                    //Adding attachments to message.
                    message.setFileAttachments(fileAttachments); 
                    List<String> senderOrgEmailAddresses = new List<String>();
                    List<String> senderAddresses = new List<String>();
                    List<String> CCAddress = new List<String>();
                    List<String> BCCAddress = new List<String>();
                    if(mailsDetails != null && mailsDetails[0].CC_Address__c != null && mailsDetails[0].CC_Address__c != '' &&
                                                                   mailsDetails[0].CC_Address__c.contains('@')){ 
                        CCAddress = mailsDetails[0].CC_Address__c.split(',');
                    }
                    if(programMap.get(pgmId).Submission_Email_CC_1__c!=null && programMap.get(pgmId).Submission_Email_CC_1__c!='')
                        CCAddress.add(''+programMap.get(pgmId).Submission_Email_CC_1__c);
                    if(programMap.get(pgmId).Submission_Email_CC_2__c!=null && programMap.get(pgmId).Submission_Email_CC_2__c!='')
                        CCAddress.add(''+programMap.get(pgmId).Submission_Email_CC_2__c);
                    if(mailsDetails != null && mailsDetails[0].Bcc_Address__c != null && mailsDetails[0].Bcc_Address__c != '' && 
                                                                  mailsDetails[0].Bcc_Address__c.contains('@') ){
                        BCCAddress = mailsDetails[0].Bcc_Address__c.split(',');
                    }
                    senderAddresses.add(programMap.get(pgmId).Submission_Email__c); //Adding Email Id.
                    if(isOrgWideEmailAllowed == true){
                        OrgWideEmailAddress owea = [select Id,Address from OrgWideEmailAddress where Address =: orgWideEmailAddress];
                        senderOrgEmailAddresses.add(owea.Address);
                        message.setOrgWideEmailAddressId(owea.Id);
                    }
                    if(senderAddresses.size() > 0)
                        message.setToAddresses(senderAddresses);
                    if(CCAddress.size() > 0)
                        message.setCcAddresses(CCAddress);
                    if(BCCAddress.size() > 0)
                        message.setBccAddresses(BCCAddress);
                    String Subject = '';
                    if(opp.AccountId != null)
                    Subject = mailsDetails[0].Subject__c + ': ' + opp.Account.Name;
                    else
                    Subject = mailsDetails[0].Subject__c;
                    message.setSubject(Subject);
                    MessageBody = messageBodyContent();
                    message.setHtmlBody(MessageBody); 
                    //Send the Attachment Email to Banks Email address
                    allMails.add(message);
                    
                    Submission__c tempSub = createSubmission(programMap.get(pgmId).Bank__r.Main_Contact__c,
                                                                                programMap.get(pgmId).Bank__c,
                                                                                pgmId,
                                                                                programMap.get(pgmId).Submission_Email__c);
                    tempSub.SubmissionWizard_Counter__c = countSubmissions;
                    submissionList.add(tempSub);
                    
                    applicationSentToPgm.add(programMap.get(pgmId));
                }else if(programMap.get(pgmId).Submission_Email__c == null){
                    applicationNotSentToPgm.add(programMap.get(pgmId));
                }
            }
            if(allMails.size() > 0 && submissionList.size() > 0){
               
                
                 List<Messaging.SendEmailResult> results =  Messaging.sendEmail(allMails); 
                 postOnChatter(mapPgmAttachment);
                  insert submissionList;
                //After the mail has been sent show a thankyou Page
                showThankYouPage = true;
                if(opp.StageName == 'Prospecting' || opp.StageName == 'Application Sent' || opp.StageName == 'Application In' ||
                opp.StageName == 'Application Missing Info' || opp.StageName == 'Declined' || opp.StageName == 'Closed Lost' ||
                opp.StageName == 'Renewal Prospecting' || opp.StageName == 'Renewal Requested' )
                        update (new Opportunity (Id = oppId ,StageName = 'Underwriting'));

            }else{
                //No email sent
                showThankYouPage = true;
            }
        }
        catch(Exception e){
                
                if(e.getMessage() != '' && e.getMessage() != null && e.getMessage().contains(EMAIL_LIMIT)){
                 noExceptionForSubmissionCounter=false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.Submission_EmailLimitExceeded));               
                }
                else if(e.getMessage() != '' && e.getMessage() != null && e.getMessage().contains('MAXIMUM_SIZE_OF_ATTACHMENT')){
                noExceptionForSubmissionCounter=false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Total attachment size is exceeded. Please reduce the number of attachements till total 10MB'));
                }
                else
                {noExceptionForSubmissionCounter=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));}
            //return null;  
        }
    }

    public String messageBodyContent(){
        List<Document> docuLst = new List<Document>();
        String query = 'Select d.SystemModstamp, d.Name, d.Id From Document d where name = \''+LOGO_NAME+'\'';
        docuLst = Database.query(query);
        if(docuLst <> null && docuLst.size()>0){
           string strOrgId = UserInfo.getOrganizationId();
           string orgInst = URL.getSalesforceBaseUrl().getHost();
           string strDocUrl = URL.getSalesforceBaseUrl().getProtocol() + '://' + orgInst + '/servlet/servlet.ImageServer?id=' + docuLst[0].Id + '&oid=' + strOrgId;           
           if(opp.Submission_Notes__c != null)
            messageBody = '<html><body><div align="center"><img src="'+strDocUrl+'" alt="Company Logo"></img></div>'+ mailsDetails[0].Message_Body__c.replace('{!SubmissionNotes}', 'Notes: '+opp.Submission_Notes__c) +'</body></html>';
           else
           messageBody = '<html><body><div align="center"><img src="'+strDocUrl+'" alt="Company Logo"></img></div>'+ mailsDetails[0].Message_Body__c.replace('{!SubmissionNotes}', '') +'</body></html>';
           //messageBody = '<html><body><div align="center"><img src="'+strDocUrl+'" alt="Company Logo"></img></div>'+mailsDetails[0].Message_Body__c+'</body></html>';
          
           return messageBody;
        }
        else{
           String messageBody =  mailsDetails[0].Message_Body__c;
           if(opp.Submission_Notes__c != null)
            messageBody = messageBody.replace('{!SubmissionNotes}', opp.Submission_Notes__c);
           else
            messageBody = messageBody.replace('{!SubmissionNotes}', '');
           
           return messageBody;
        }
    }

    public PageReference cancel(){
        return new PageReference('/'+OppId);
    }

    //For Chatter Post
    private void postOnChatter(map<Id,list<Attachment>> mapPgmAttachment){  

        String chatterFeed = '' ;
        String programBankName = '';
        FeedItem oChatterFeedItem = new FeedItem();
        
        if(mapPgmAttachment != null){
            for(Id pgmId : mapPgmAttachment.keySet()){
                
                programBankName += (programBankName == '' ? '' : ', ') +programMap.get(pgmId).Bank__r.Name ; 
                
            }
        }else{
            for(Id pgmId : programMap.keySet()){
                
                programBankName += (programBankName == '' ? '' : ', ') +programMap.get(pgmId).Bank__r.Name ; 
                
            }
        }
        chatterFeed = System.Label.Submission_ChatterFeedBody + ' ' + programBankName + 
                                ' by ' + userObj.FirstName + ' ' + userObj.LastName;

        PostToChatterUtility objClass = new PostToChatterUtility();
        try{
                insert objClass.postToChatter(chatterFeed , OppId);
        }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));   
        }
    }
    
    public void showMore(){
        
        
        Integer size = programWrapperList1.size();
        for(Integer i=programWrapperList1.size(); i<size+10; ++i)
        {
            if(programWrapperList != null && programWrapperList.size()>i)
            programWrapperList1.add(programWrapperList[i]);
        }
        limitval = programWrapperList1.size();
        
       
    }
    
    public PageReference ViewSortedData_Program(){
        
        programWrapperList.sort();
        programWrapperList1.clear();
        for(Integer i=0; i<limitval; ++i){
            if(programWrapperList!= null && programWrapperList.size() > i && programWrapperList[i] !=null){
            programWrapperList1.add(programWrapperList[i]);
       }
    }
         return null;
    }
    
    public void checkUncheckAttachements(){
        String isSelected = ApexPages.CurrentPage().getParameters().get('isSelected');
        String attId = ApexPages.CurrentPage().getParameters().get('attId');
        
        if(attId != null && attId != '' ){
                for(AttachmentWrapper attWrapper : AttachmentWrapperList){
                        if(attWrapper.attachment.id == attId){
                                if(isSelected == 'true'){
                                        attWrapper.selectedPrograms.clear(); 
                                }else{
                                        //attWrapper.selectedPrograms.addAll(attWrapper.options);
                                        for(Id pgmId : attWrapper.ProgramMap.keySet()){
                                                attWrapper.selectedPrograms.add(pgmId);
                                        }
                                }
                        }
                }       
        }
    }

    public void resetAttachments(){
        this.populateProgramMap();
        this.getAvailableAttachments();
    }
    
    public void populateProgramMap(){
        programMap.clear();
        for( ProgramWrapper wrapper: programWrapperList1){
            if(wrapper.isSelected){
                programMap.put(wrapper.prgm.Id,wrapper.prgm);
            }
        }
    }

     public void selectDeselectAtt1(){
        
       
        programMap.clear();
        for( ProgramWrapper wrapper: programWrapperList1){
                
                if(wrapper.isSelected == true)
                        programMap.put(wrapper.prgm.Id,wrapper.prgm);
                        
            }
        
        //In attachment wrappper for all the att add the selected option
                for(AttachmentWrapper attWrapper : AttachmentWrapperList){
                        attWrapper.selectedPrograms.clear();
                        for(ProgramWrapper wrapper: programWrapperList1){
                        if(wrapper.isSelected == true){         
                                //Auto select the recently added program
                                attWrapper.selectedPrograms.add(wrapper.prgm.Id); 
                                
                        }
                        
                        //Also populate the program map with the recently selected value
                        if(programMap.size() > 0 && programMap.containsKey(wrapper.prgm.Id)){
                                attWrapper.programMap.put(wrapper.prgm.Id, programMap.get(wrapper.prgm.Id));
                        }               
                        else if(attWrapper.programMap.size() >  0 && attWrapper.programMap.containsKey(wrapper.prgm.Id) ){
                        attWrapper.programMap.remove(wrapper.prgm.Id);
                        }
                        
                        attWrapper.options.clear();
                        
                        for(String pgm : attWrapper.selectedPrograms){
                         attWrapper.options.add(new selectOption(pgm, attWrapper.programMap.get(pgm).Name)); 
                    }
                }//
        }
     }


    // Function used to create Submission records
    public Submission__c createSubmission(Id pMainContact, Id pBank,Id pPgmId, String pEmail){
       
        Submission__c submission = new Submission__c(Opportunity__c = OppId,
                                                     Contact__c = pMainContact,
                                                     Status__c = 'UW',
                                                     Funder__c = pBank,
                                                     Program__c = pPgmId,
                                                     Email__c = pEmail,
                                                     Channel__c = channelVal,
                                                     Date_Submitted__c = system.now()); 
        
        return submission;      
    }

    //Wrapper Class contains Attachment Object and isRequired to keep track of which Attachment is isRequired 
    public class AttachmentWrapper{
        public Integer cnt                {get; set;}
        public Attachment attachment      {get; set;}
        public boolean isRequired         {get; set;}
        public List<selectOption> options {get; set;}
        public String[] selectedPrograms          {get; set;} 
        public map<Id,Program__c> programMap {get; set;}
        public AttachmentWrapper(Integer pCnt, Attachment pAttachment ,Boolean pIsRequired, map<Id,Program__c> pProgramMap){
            cnt = pCnt;
            selectedPrograms = new String[]{};
            for(String pgm : pProgramMap.keySet()){
                selectedPrograms.add(pgm);
            }
            attachment = pAttachment;
            isRequired = pIsRequired;
            programMap = pProgramMap;
            options = new List<selectOption>();
            for(String pgm : pProgramMap.keySet()){
                 options.add(new selectOption(pgm, pProgramMap.get(pgm).Name));
            }
        }
    }

    //Wrapper Class contains Program__c Object and isSelected to keep track of which Program__c is selected 
    public class ProgramWrapper implements Comparable{
        public Program__c prgm              {get; set;}
        public boolean isSelected           {get; set;}
        public Integer score                {get; set;}
        public Decimal PotentialFundingAmt  {get; set;}
        public Boolean missingInfo          {get; set;}
        public String matchingPer           {get; set;}
        //public string submissionStatus          {get; set;}

        public ProgramWrapper(Program__c pProgram ,Boolean pIsSelected,Integer pScore,Decimal pPotentialFundingAmt, boolean pMissingInfo, String pMatchingPer ){
            prgm = pProgram;
            isSelected = pIsSelected;
            score = pScore;
            PotentialFundingAmt = pPotentialFundingAmt;
            missingInfo = pMissingInfo;
            matchingPer = pMatchingPer;
            //submissionStatus = psubmissionStatus;
        }

        public Integer compareTo(Object ObjToCompare) {
            ProgramWrapper compareTo =(ProgramWrapper)ObjToCompare;
            if(SubmissionWizardController.sortDirection.equals('ASC')){
                system.debug('ASC....');
                    if(SubmissionWizardController.sortExp.equals('Funding_Amt_of_Monthly_Gross_Sales__c')){
                        if((prgm.Funding_Amt_of_Monthly_Gross_Sales__c==null?0:prgm.Funding_Amt_of_Monthly_Gross_Sales__c) ==
                           (compareTo.prgm.Funding_Amt_of_Monthly_Gross_Sales__c==null?0:compareTo.prgm.Funding_Amt_of_Monthly_Gross_Sales__c))
                        return 0;
                        if((prgm.Funding_Amt_of_Monthly_Gross_Sales__c==null?0:prgm.Funding_Amt_of_Monthly_Gross_Sales__c) >
                           (compareTo.prgm.Funding_Amt_of_Monthly_Gross_Sales__c==null?0:compareTo.prgm.Funding_Amt_of_Monthly_Gross_Sales__c))
                        return 1;
                        return -1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Commission_Percentage__c')){
                        if((prgm.Commission_Percentage__c==null?0:prgm.Commission_Percentage__c) ==
                           (compareTo.prgm.Commission_Percentage__c==null?0:compareTo.prgm.Commission_Percentage__c))
                        return 0;
                        if((prgm.Commission_Percentage__c==null?0:prgm.Commission_Percentage__c) >
                           (compareTo.prgm.Commission_Percentage__c==null?0:compareTo.prgm.Commission_Percentage__c))
                        return 1;
                        return -1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Max_Amount__c')){
                        if((prgm.Max_Amount__c==null?0:prgm.Max_Amount__c) == 
                           (compareTo.prgm.Max_Amount__c==null?0:compareTo.prgm.Max_Amount__c))
                        return 0;
                        if((prgm.Max_Amount__c==null?0:prgm.Max_Amount__c) >
                            (compareTo.prgm.Max_Amount__c==null?0:compareTo.prgm.Max_Amount__c))return 1;
                        return -1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Max_No_NSFs__c')){
                        if((prgm.Max_No_NSFs__c==null?0:prgm.Max_No_NSFs__c) ==
                           (compareTo.prgm.Max_No_NSFs__c==null?0:compareTo.prgm.Max_No_NSFs__c))
                        return 0;
                        if((prgm.Max_No_NSFs__c==null?0:prgm.Max_No_NSFs__c) >
                            (compareTo.prgm.Max_No_NSFs__c==null?0:compareTo.prgm.Max_No_NSFs__c))
                        return 1;
                        return -1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Max_NDBs__c')){
                        if((prgm.Max_NDBs__c==null?0:prgm.Max_NDBs__c)==
                           (compareTo.prgm.Max_NDBs__c==null?0:compareTo.prgm.Max_NDBs__c))
                        return 0;
                        if((prgm.Max_NDBs__c==null?0:prgm.Max_NDBs__c) >
                          (compareTo.prgm.Max_NDBs__c==null?0:compareTo.prgm.Max_NDBs__c))return 1;
                        return -1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Min_Monthly_Deposits__c')){ 
                        if((prgm.Min_Monthly_Deposits__c==null?0:prgm.Min_Monthly_Deposits__c) ==
                          (compareTo.prgm.Min_Monthly_Deposits__c==null?0:compareTo.prgm.Min_Monthly_Deposits__c))
                        return 0;
                        if((prgm.Min_Monthly_Deposits__c==null?0:prgm.Min_Monthly_Deposits__c) >
                          (compareTo.prgm.Min_Monthly_Deposits__c==null?0:compareTo.prgm.Min_Monthly_Deposits__c))
                        return 1;
                        return -1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Minimum_Deposit_Count__c')){
                        if((prgm.Minimum_Deposit_Count__c==null?0:prgm.Minimum_Deposit_Count__c) ==
                           (compareTo.prgm.Minimum_Deposit_Count__c==null?0:compareTo.prgm.Minimum_Deposit_Count__c))
                           return 0;
                        if((prgm.Minimum_Deposit_Count__c==null?0:prgm.Minimum_Deposit_Count__c) >
                           (compareTo.prgm.Minimum_Deposit_Count__c==null?0:compareTo.prgm.Minimum_Deposit_Count__c))
                           return 1;
                        return -1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Years_in_Business__c')){
                        if((prgm.Years_in_Business__c==null?0:prgm.Years_in_Business__c) ==
                          (compareTo.prgm.Years_in_Business__c==null?0:compareTo.prgm.Years_in_Business__c))
                        return 0;
                        if((prgm.Years_in_Business__c==null?0:prgm.Years_in_Business__c) >
                          (compareTo.prgm.Years_in_Business__c==null?0:compareTo.prgm.Years_in_Business__c))
                        return 1;
                        return -1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Min_Avg_Daily_Bal__c')){
                        if((prgm.Min_Avg_Daily_Bal__c==null?0:prgm.Min_Avg_Daily_Bal__c) ==
                           (compareTo.prgm.Min_Avg_Daily_Bal__c==null?0:compareTo.prgm.Min_Avg_Daily_Bal__c))
                        return 0;
                        if((prgm.Min_Avg_Daily_Bal__c==null?0:prgm.Min_Avg_Daily_Bal__c) >
                            (compareTo.prgm.Min_Avg_Daily_Bal__c==null?0:compareTo.prgm.Min_Avg_Daily_Bal__c))
                        return 1;
                        return -1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Credit_Score__c')){
                        if((prgm.Credit_Score__c==null?0:prgm.Credit_Score__c) ==
                           (compareTo.prgm.Credit_Score__c==null?0:compareTo.prgm.Credit_Score__c))
                        return 0;
                        if((prgm.Credit_Score__c==null?0:prgm.Credit_Score__c) >
                           (compareTo.prgm.Credit_Score__c==null?0:compareTo.prgm.Credit_Score__c))
                        return 1;
                        return -1;
                    }
                    if(SubmissionWizardController.sortExp.equals('score')){
                        if(score == compareTo.score)return 0;
                        if(score > compareTo.score)return 1;
                        return -1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Bank__r.Name')){
                        return (prgm.Bank__r.Name==null?'':prgm.Bank__r.Name.toUpperCase()).CompareTo(compareTo.prgm.Bank__r.Name==null?'':compareTo.prgm.Bank__r.Name.toUpperCase());}
                    if(SubmissionWizardController.sortExp.equals('Name')){
                        return prgm.Name.toUpperCase().CompareTo(compareTo.prgm.Name.toUpperCase());}
            }
            else{
                system.debug('DESC....');                  
                    if(SubmissionWizardController.sortExp.equals('Funding_Amt_of_Monthly_Gross_Sales__c')){
                        if((prgm.Funding_Amt_of_Monthly_Gross_Sales__c==null?0:prgm.Funding_Amt_of_Monthly_Gross_Sales__c) ==
                           (compareTo.prgm.Funding_Amt_of_Monthly_Gross_Sales__c==null?0:compareTo.prgm.Funding_Amt_of_Monthly_Gross_Sales__c))
                        return 0;
                        if((prgm.Funding_Amt_of_Monthly_Gross_Sales__c==null?0:prgm.Funding_Amt_of_Monthly_Gross_Sales__c) >
                            (compareTo.prgm.Funding_Amt_of_Monthly_Gross_Sales__c==null?0:compareTo.prgm.Funding_Amt_of_Monthly_Gross_Sales__c))
                        return -1;
                        return 1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Commission_Percentage__c')){
                        if((prgm.Commission_Percentage__c==null?0:prgm.Commission_Percentage__c) ==
                           (compareTo.prgm.Commission_Percentage__c==null?0:compareTo.prgm.Commission_Percentage__c))
                        return 0;
                        if((prgm.Commission_Percentage__c==null?0:prgm.Commission_Percentage__c) >
                           (compareTo.prgm.Commission_Percentage__c==null?0:compareTo.prgm.Commission_Percentage__c))
                        return -1;
                        return 1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Max_Amount__c')){
                        if((prgm.Max_Amount__c==null?0:prgm.Max_Amount__c) == 
                           (compareTo.prgm.Max_Amount__c==null?0:compareTo.prgm.Max_Amount__c))
                        return 0;
                        if((prgm.Max_Amount__c==null?0:prgm.Max_Amount__c) >
                           (compareTo.prgm.Max_Amount__c==null?0:compareTo.prgm.Max_Amount__c))
                        return -1;
                        return 1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Max_No_NSFs__c')){
                        if((prgm.Max_No_NSFs__c==null?0:prgm.Max_No_NSFs__c) ==
                           (compareTo.prgm.Max_No_NSFs__c==null?0:compareTo.prgm.Max_No_NSFs__c))
                        return 0;
                        if((prgm.Max_No_NSFs__c==null?0:prgm.Max_No_NSFs__c) >
                           (compareTo.prgm.Max_No_NSFs__c==null?0:compareTo.prgm.Max_No_NSFs__c))
                        return -1;
                        return 1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Min_Avg_Daily_Bal__c')){
                        if((prgm.Min_Avg_Daily_Bal__c==null?0:prgm.Min_Avg_Daily_Bal__c) ==
                           (compareTo.prgm.Min_Avg_Daily_Bal__c==null?0:compareTo.prgm.Min_Avg_Daily_Bal__c))
                        return 0;
                        if((prgm.Min_Avg_Daily_Bal__c==null?0:prgm.Min_Avg_Daily_Bal__c) >
                            (compareTo.prgm.Min_Avg_Daily_Bal__c==null?0:compareTo.prgm.Min_Avg_Daily_Bal__c))
                        return -1;
                        return 1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Max_NDBs__c')){
                        if((prgm.Max_NDBs__c==null?0:prgm.Max_NDBs__c)==
                           (compareTo.prgm.Max_NDBs__c==null?0:compareTo.prgm.Max_NDBs__c))return 0;
                        if((prgm.Max_NDBs__c==null?0:prgm.Max_NDBs__c) >
                           (compareTo.prgm.Max_NDBs__c==null?0:compareTo.prgm.Max_NDBs__c))return -1;
                        return 1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Min_Monthly_Deposits__c')){
                        if((prgm.Min_Monthly_Deposits__c==null?0:prgm.Min_Monthly_Deposits__c) ==
                          (compareTo.prgm.Min_Monthly_Deposits__c==null?0:compareTo.prgm.Min_Monthly_Deposits__c))
                        return 0;
                        if((prgm.Min_Monthly_Deposits__c==null?0:prgm.Min_Monthly_Deposits__c) >
                          (compareTo.prgm.Min_Monthly_Deposits__c==null?0:compareTo.prgm.Min_Monthly_Deposits__c))
                        return -1;
                        return 1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Minimum_Deposit_Count__c')){
                        if((prgm.Minimum_Deposit_Count__c==null?0:prgm.Minimum_Deposit_Count__c) ==
                          (compareTo.prgm.Minimum_Deposit_Count__c==null?0:compareTo.prgm.Minimum_Deposit_Count__c))
                        return 0;
                        if((prgm.Minimum_Deposit_Count__c==null?0:prgm.Minimum_Deposit_Count__c) >
                            (compareTo.prgm.Minimum_Deposit_Count__c==null?0:compareTo.prgm.Minimum_Deposit_Count__c))return -1;
                        return 1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Years_in_Business__c')){
                        if((prgm.Years_in_Business__c==null?0:prgm.Years_in_Business__c) == 
                          (compareTo.prgm.Years_in_Business__c==null?0:compareTo.prgm.Years_in_Business__c))
                        return 0;
                        if((prgm.Years_in_Business__c==null?0:prgm.Years_in_Business__c) >
                          (compareTo.prgm.Years_in_Business__c==null?0:compareTo.prgm.Years_in_Business__c))
                        return -1;
                        return 1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Credit_Score__c')){
                        if((prgm.Credit_Score__c==null?0:prgm.Credit_Score__c) ==
                           (compareTo.prgm.Credit_Score__c==null?0:compareTo.prgm.Credit_Score__c))
                        return 0;
                        if((prgm.Credit_Score__c==null?0:prgm.Credit_Score__c) >
                           (compareTo.prgm.Credit_Score__c==null?0:compareTo.prgm.Credit_Score__c))
                        return -1;
                        return 1;
                    }
                    if(SubmissionWizardController.sortExp.equals('score')){
                        if(score == compareTo.score)return 0;
                        if(score > compareTo.score)return -1;
                        return 1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Bank__r.Name')){
                        if((prgm.Bank__r.Name==null?'':prgm.Bank__r.Name.toUpperCase()).CompareTo(compareTo.prgm.Bank__r.Name==null?'':compareTo.prgm.Bank__r.Name.toUpperCase())==0)
                           return 0;
                        if((prgm.Bank__r.Name==null?'':prgm.Bank__r.Name.toUpperCase()).CompareTo(compareTo.prgm.Bank__r.Name==null?'':compareTo.prgm.Bank__r.Name.toUpperCase())==1)
                           return -1;
                        return 1;
                    }
                    if(SubmissionWizardController.sortExp.equals('Name')){
                        //return prgm.Name.CompareTo(compareTo.prgm.Name);
                        if((prgm.Name==null?'':prgm.Name.toUpperCase()).CompareTo(compareTo.prgm.Name==null?'':compareTo.prgm.Name.toUpperCase())==0)
                           return 0;
                        if((prgm.Name==null?'':prgm.Name.toUpperCase()).CompareTo(compareTo.prgm.Name==null?'':compareTo.prgm.Name.toUpperCase())==1)
                           return -1;
                        return 1;                        
                    }
            }
            return null;
        }
    }
}