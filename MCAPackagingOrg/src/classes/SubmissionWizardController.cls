/* 
 *  Description - Controller for Submission Wizard Page
 *   
 *  Date - 10-02-2014
 *  
 *  Created by - Sneha P.
 *  Modified by - Shraddha P.
 */
global with sharing class SubmissionWizardController {
    // Constant variable
    private static final String IS_CONSOLE_PARAM = 'isConsole';
    private static final String OPP_PRAMA_NAME = 'id';
    private static final String ACC_PRAMA_NAME = 'accId';
    private static final String FIELDSET_ERROR = 'Please add fields into Opportunity fieldset to view Deal Summary.';
    public static String sortExp = 'score';
    public static String sortDirection = 'DESC';
    private static final String ERROR_CHAR = 'Please enter numbers only into the filter.' ;
    // Mapped with Submission Channel field -to track the creation of Submission
    public static String channelVal                      {get; set;}
    public decimal countSubmissions;// Increase the Opp Submission Counter after visiting SW
    //if Program Bank is not of Bank record type
    public boolean isFunderError                         {get;set;}
    public boolean isNoEmailError                        {get;set;}
    public boolean isAttachmentAvailable                 {get;set;}
    //Paramter values 
    public ID oppId                                      {get; set;}
    public Boolean isFieldSet                            {get; set;}
    public String accId;
    //get set variable
    public Opportunity oppFieldSet                       {get; set;}
    //Program filter variables
    public String creditScore                            {get; set;}
    public String yearInBusiness                         {get; set;}
    public String minMonthlyDeposite                     {get; set;}
    public String minDepositeCount                       {get; set;}
    public String minAvgDailyBalance                     {get; set;}
    public String maxNSFs                                {get; set;}
    public String maxNDBs                                {get; set;}
    public Boolean restrictedIndustry                    {get; set;}
    public Boolean restrictedState                       {get; set;}
    public Boolean prefferedProgram                      {get; set;}
    public list<ProgramWrapper> programWrapperList       {get; set;}//query list
    public list<ProgramWrapper> programWrapListLimit     {get; set;}//limited list
    public map<String,list<String>> prgmDocMap           {get; set;}
    public Boolean showThankYouPage                      {get; set;}
    public List<AttachmentWrapper> attachmentWrapperList {get; set;}
    public String indexToRemove                          {get; set;}
    public Boolean showSelectList                        {get; set;} // to control the visiblity of Program in Available Attachment section
    public Integer startCount                            {get; set;}
    public Integer sizeOfProgram                         {get; set;}
    public Integer noofRecords                           {get; set;}// total number of programs present in org
    public boolean displayPopup                          {get; set;}
    public list<Program__c> applicationSentToPgm         {get; set;} //list stores the pgms to which the applications are sent
    public list<Program__c> lstApplicationNotSentToPgm   {get; set;} //list stores the pgms to which the applications are not sent - missing Submssion email
    public list<Program__c> applicationNotSentToPgm      {get; set;} //list stores the pgms to which the applications are not sent - Program Bank filter
    public boolean hideShowPrgCount                      {get; set;}
    public Boolean showHeader                            {get; set;}
    public Boolean isInConsole                           {get; set;}
    private map<Id,Attachment> mapAttachment;
    public Map<Id,Program__c> programMap; //selected Programs
    public map<Id,list<Attachment>> mapPgmAttachment;               //Create a map of programs n list of attachments
    private Boolean prefferedPgm; 
    public Integer limitval; //used for showmore link
    public boolean noExceptionForSubmissionCounter; // Increase the Opp Submission Counter if no exception found
    public set<String> oppStages; // set of Opporunity stages
    public Map<String, OrgwideEmailAddress__c> orgWidecustomSetting; // custom setting to assign the org wide email address while sending an email
    User userObj = [Select Id, LastName, FirstName, CompanyName From User where id=:userinfo.getuserid()];

    public String prevSortExp = '';
    public String prevSortdire = '';
    private Map<String, SWDefaultFilters__c> defaultFilter;
    
    // pciklist for FO-1357
    public List<SelectOption> submissionMethodOptions    {get; set;}
    public list<ProgramWrapper> programWrapListManual    {get; set;}
    public list<ProgramWrapper> programWrapListEmail     {get; set;}
    public Map<Id, ProgramWrapper> progrmWrprMap         {get; set;}
    
    public Boolean isEmail                               {get; set;}
    public Boolean isManual                              {get; set;}
    
    public Static Integer selectedProgramCount;
    public Boolean isCheckReqDoc=false;
    
    public SubmissionWizardController() {
        programMap = new map<Id,Program__c>();
        mapPgmAttachment = new map<Id,list<Attachment>>();
        attachmentWrapperList = new List<AttachmentWrapper>();
        programWrapListLimit = new List<ProgramWrapper>();
        programWrapperList = new List<ProgramWrapper>();
        prgmDocMap = new Map<String,list<String>>();
        applicationSentToPgm = new list<Program__c>();
        lstApplicationNotSentToPgm = new list<Program__c>();
        applicationNotSentToPgm = new list<Program__c>();
        prefferedPgm = true;
        showSelectList = false;
        displayPopup = false;
        isFunderError = false;
        isNoEmailError = false;
        hideShowPrgCount = true;
        showThankYouPage = false;
        isAttachmentAvailable = false;
        noExceptionForSubmissionCounter=true;
        isInConsole
            = ApexPages.currentPage().getParameters().get(IS_CONSOLE_PARAM) == '1' ? true : false;
        oppStages = new set<String>{'Prospecting','Application Sent','Application In',
                                        'Application Missing Info','Declined',
                                        'Closed Lost','Renewal Prospecting','Renewal Requested'};
        orgWidecustomSetting = OrgwideEmailAddress__c.getall();
        // Opportunity id
        oppId = ApexPages.currentPage().getParameters().get(OPP_PRAMA_NAME);
        // Account Id
        accId = ApexPages.currentPage().getParameters().get(ACC_PRAMA_NAME);
        // call function to fetch oppotunity data
        fetchOppUsingFieldset();
        countSubmissions = oppFieldSet.Submission_Counter__c == null? 0 : oppFieldSet.Submission_Counter__c;
        defaultFilter = SWDefaultFilters__c.getall();
        //default filter for program
        defaultFilter();
        // get program limit 
        getProgrmLimit();
        //Get program records
        getPrograms();
        // get submissionMethodOptions selectOption List
        submissionMethodOptions = new List<SelectOption>();
        programWrapListManual = new list<ProgramWrapper>();
        programWrapListEmail = new list<ProgramWrapper>();
        progrmWrprMap = new Map<Id, ProgramWrapper>();
        isEmail = false;
        isManual = false;
        getSubmissionMethodOptions();
        configureHeaderVisibility();
    }//  end SubmissionWizardController()
    
    // Method to set header visibility
    private void configureHeaderVisibility()
    {
        // Hide header when page is opened from console
        showHeader = !isInConsole;
    }
    
    public void closePopup() {
        displayPopup = false;
    }// end closePopup()
    
    // No of program limit
    public void getProgrmLimit() {
        try {
            if(Label.CountOfProgram <> '0' ){
                limitval = integer.valueof(Label.CountOfProgram);
            } else if(Label.CountOfProgram == '0'){
                limitval = 15;
            }//end else- if
        } catch(exception ex) {
            limitval = 0;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,''+'The Custom Label CountOfProgram has not been configured properly. Please go to Setup -> Custom Labels -> CountOfProgram and enter a whole number for the number of matching programs to be returned.'));
        }//end try- catch
    }// end getProgrmLimit()
    
    public String sortExpression {
         get { return sortExp; }
         set {
           //if the column is clicked on then switch between Ascending and Descending modes
           if (value == sortExp || prevSortExp == value)
             sortDirection = (prevSortdire == 'ASC' )? 'DESC' : 'ASC';
           else
             sortDirection = 'ASC';
           sortExp = value;
           prevSortExp = value;
           prevSortdire = sortDirection;
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

    // Used to fetch oppotunity data from the field set
    public void fetchOppUsingFieldset() {
        Set<String> setFieldAPIName = new Set<String>{'Opportunity.McaApp__Owner_1__c','McaApp__Submission_Counter__c','McaApp__Owner_1__r.Email',
            'McaApp__Average_Daily_Balance__c', 'McaApp__Avg_Number_Bank_Deposits__c', 'Account.Industry', 'Account.BillingState',
            'Account.McaApp__Gross_monthly_Sales__c','McaApp__Gross_monthly_Sales__c', 'Account.McaApp__Years_in_Business__c','StageName',
            'McaApp__Credit_Score__c','McaApp__NSFs_avg__c','McaApp__NDBs_avg__c' };
        isFieldSet = true;
        //iterate the field for dyanmic query
        for(Schema.FieldSetMember objFieldSet :this.getFields()) {
            if(isFieldSet)
                isFieldSet = false;
            if(!setFieldAPIName.contains(''+string.ValueOf(objFieldSet.getFieldPath())))
                setFieldAPIName.add(string.ValueOf(objFieldSet.getFieldPath()));
        }//end for
        if(isFieldSet) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, FIELDSET_ERROR));
        }
        String query = 'SELECT '+ MCAUtility.getStringfromSet(setFieldAPIName, null) + 
                        ' FROM Opportunity WHERE id = \'' + OppId + '\' ';
        oppFieldSet = database.query(query);
        
    }// end fetchOppUsingFieldset()
    
    // default program using cusom setting 
    public void defaultFilter() {
        if(!defaultFilter.isempty()) {
            if(boolean.valueOf((defaultFilter.values()[0]).Credit_Score__c)) {
                creditScore = string.valueOf(oppFieldSet.Credit_Score__c);
            }
            if(boolean.valueOf(defaultFilter.values()[0].Years_in_Business__c)) {
                yearInBusiness = string.valueOf(oppFieldSet.Account.Years_in_Business__c);
            }
            if(boolean.valueOf(defaultFilter.values()[0].Monthly_Deposits1__c)) {
                minMonthlyDeposite = string.valueOf(oppFieldSet.Gross_monthly_Sales__c);
            }
            if(boolean.valueOf(defaultFilter.values()[0].Monthly_Deposits__c)) {
                minDepositeCount = string.valueOf(oppFieldSet.Avg_Number_Bank_Deposits__c);
            }
            if(boolean.valueOf(defaultFilter.values()[0].Avg_Daily_Balance__c)) {
                minAvgDailyBalance = string.valueOf(oppFieldSet.Average_Daily_Balance__c);
            }
            if(boolean.valueOf(defaultFilter.values()[0].Max_NSFs__c)) {
                maxNSFs = string.valueOf(oppFieldSet.NSFs_Avg__c);
            }
            if(boolean.valueOf(defaultFilter.values()[0].Max_NDBs__c)) {
                maxNDBs = string.valueOf(oppFieldSet.NDBs_Avg__c);
            }
            if(boolean.valueOf(defaultFilter.values()[0].Industry__c))
                restrictedIndustry = true;
            if(boolean.valueOf(defaultFilter.values()[0].State__c))
                restrictedState = true;
            if(boolean.valueOf(defaultFilter.values()[0].Preferred_Programs__c))
                prefferedProgram = true;
        }// end if
    }// end defaultFilter()
    
    // Get all the fields from fieldset of Opportunity
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Opportunity.FieldSets.SWDealSummary.getFields();
    }//End method getFields()
    
    //get the programs to display on Submission Wizard page
    public void getPrograms() {
        getProgrmLimit();
        Boolean isError = false;
        showSelectList = false;
        programWrapperList.clear();
        programWrapListLimit.clear();
        programMap.clear();
        String query = 'Select Bank__r.Name,Bank__r.Main_Contact__c,Bank__r.Main_Contact__r.Name,Bank__r.recordtypeid,'+
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
                         SObjectType.Program__c.fields.Email_Template_Id__c.Name + ',' +
                         SObjectType.Program__c.fields.Submission_Method__c.Name + ',' +
                         SObjectType.Program__c.fields.Funding_Amt_of_Monthly_Gross_Sales__c.Name+' from '+
                         SObjectType.Program__c.Name;
        if( checknull(creditScore) || 
            checknull(yearInBusiness) || 
            checknullBoolean(restrictedIndustry) ||
            checknull(minMonthlyDeposite) ||
            checknull(maxNSFs) ||
            checknullBoolean(restrictedState) ||
            checknullBoolean(prefferedProgram) ||
            checknull(minDepositeCount) || 
            checknull(minAvgDailyBalance) ||
            checknull(maxNDBs)){
                // add where condition
                query += ' Where ';
                //credit score filter
                if(checknull(creditScore) && isNumberCheck(creditScore)) {
                    query += '('+ SObjectType.Program__c.fields.Credit_Score__c.Name+' <= '+ decimal.valueOf(creditScore);
                    if(decimal.valueOf(creditScore) == 0) {
                        query += ' OR ';
                        query += SObjectType.Program__c.fields.Credit_Score__c.Name+' = '+ null+')';
                    }else {
                        query += ' ) ';
                    }// end else - if
                } else if(creditScore <> null && creditScore <> '' && !isNumberCheck(creditScore)) {
                    isError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ERROR_CHAR));
                } // end else - if 

                // yearInBusiness Filter
                if(checknull(yearInBusiness) && isNumberCheck(yearInBusiness)) {
                    if(checknull(creditScore))
                        query += ' and ';
                    query += '('+SObjectType.Program__c.fields.Years_in_Business__c.Name+' <= '+decimal.valueOf(yearInBusiness);
                    if(decimal.valueOf(yearInBusiness) == 0) {
                        query += ' OR ';
                        query += SObjectType.Program__c.fields.Years_in_Business__c.Name+' = '+ null+')';
                    }else {
                        query += ' ) ';
                    }// end else - if
                } else if(yearInBusiness <> null && !isNumberCheck(yearInBusiness) && yearInBusiness <> '') {
                    isError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ERROR_CHAR));
                } // end else - if

                // restrictedIndustry filter
                if(checknullBoolean(restrictedIndustry)) {
                    if(checknull(creditScore) || checknull(yearInBusiness))
                        query += ' and ';
                    query += '('+SObjectType.Program__c.fields.Restricted_Industry_List__c.Name+' excludes (\''+oppFieldSet.Account.Industry+'\') ';
                    query += ' OR ';
                    query += SObjectType.Program__c.fields.Restricted_Industry_List__c.Name+' = '+ null+')';
                }//end if

                //minMonthlyDeposite filter
                if(checknull(minMonthlyDeposite) && isNumberCheck(minMonthlyDeposite)) {
                    if(checknull(creditScore) || checknull(yearInBusiness) || checknullBoolean(restrictedIndustry) )
                        query += ' and ';
                    query += '('+SObjectType.Program__c.fields.Min_Monthly_Deposits__c.Name+' <= '+ decimal.valueOf(minMonthlyDeposite);
                    if(decimal.valueOf(minMonthlyDeposite) == 0) {
                        query += ' OR ';
                        query += SObjectType.Program__c.fields.Min_Monthly_Deposits__c.Name+' = '+ null+')';
                    }else {
                        query += ' ) ';
                    }// end else - if
                } else if(minMonthlyDeposite <> null && !isNumberCheck(minMonthlyDeposite) && minMonthlyDeposite <> ''){
                    isError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ERROR_CHAR));
                } // end else - if

                // minDepositeCount filter
                if(checknull(minDepositeCount) && isNumberCheck(minDepositeCount)) {
                    if( checknull(creditScore) || checknull(yearInBusiness) || checknullBoolean(restrictedIndustry) ||
                        checknull(minMonthlyDeposite) )
                        query += ' and ';
                    query += '('+SObjectType.Program__c.fields.Minimum_Deposit_Count__c.Name+' <= '+decimal.valueOf(minDepositeCount);
                    if(decimal.valueOf(minDepositeCount) == 0) {
                        query += ' OR ';
                        query += SObjectType.Program__c.fields.Minimum_Deposit_Count__c.Name+' = '+ null+')';
                    }else {
                        query += ' ) ';
                    }// end else - if
                } else if(minDepositeCount <> null && !isNumberCheck(minDepositeCount) && minDepositeCount <> '') {
                    isError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ERROR_CHAR));
                } // end else - if  

                // maxNSFs filter
                if(checknull(maxNSFs) && isNumberCheck(maxNSFs)) {
                    if(checknull(creditScore) || checknull(yearInBusiness)|| checknullBoolean(restrictedIndustry) ||checknull(minMonthlyDeposite) ||checknull(minDepositeCount))
                        query += ' and ';
                    query += '('+SObjectType.Program__c.fields.Max_No_NSFs__c.Name+' >= '+decimal.valueOf(maxNSFs);
                    if(decimal.valueOf(maxNSFs) == 0) {
                        query += ' OR ';
                        query += SObjectType.Program__c.fields.Max_No_NSFs__c.Name+' = '+ null+')';
                    }else {
                        query += ' ) ';
                    }// end else - if
                } else if(maxNSFs <> null && !isNumberCheck(maxNSFs) && maxNSFs <> ''){
                    isError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ERROR_CHAR));
                } // end else - if 

                // restrictedState filter
                if(checknullBoolean(restrictedState)) {
                    if(checknull(creditScore) || checknull(yearInBusiness) || checknullBoolean(restrictedIndustry) || checknull(minMonthlyDeposite) ||checknull(minDepositeCount) || checknull(maxNSFs))
                        query += ' and ';
                    query += '('+SObjectType.Program__c.fields.Restricted_States__c.Name+'  excludes (\''+oppFieldSet.Account.BillingState+'\') ';
                    query += ' OR ';
                    query += SObjectType.Program__c.fields.Restricted_States__c.Name+' = '+ null+')';
                }//end if 

                if(prefferedProgram != null) {
                    if(checknull(creditScore) || checknull(yearInBusiness) || checknull(minMonthlyDeposite) || checknull(maxNSFs) || checknullBoolean(restrictedIndustry)  || checknull(minDepositeCount)
                    || checknullBoolean(restrictedState))
                        query += ' and ';
                    query += '('+SObjectType.Program__c.fields.Preffered_Programs__c.Name+' = '+prefferedProgram+')';
                }// end if

                // maxNDBs filter
                if(checknull(maxNDBs) && isNumberCheck(maxNDBs)) {
                    if(checknull(creditScore) || checknull(yearInBusiness) || checknullBoolean(restrictedIndustry) || checknull(minMonthlyDeposite) || checknull(maxNSFs) || restrictedState != false ||
                    checknull(minDepositeCount) || prefferedProgram != null)
                        query += ' and ';
                    query += '('+SObjectType.Program__c.fields.Max_NDBs__c.Name+' >= '+decimal.valueOf(maxNDBs);
                    if(decimal.valueOf(maxNDBs) == 0) {
                        query += ' OR ';
                        query += SObjectType.Program__c.fields.Max_NDBs__c.Name+' = '+ null+')';
                    }else {
                        query += ' ) ';
                    }// end else - if
                } else if(maxNDBs <> null && !isNumberCheck(maxNDBs) && maxNDBs <> ''){
                    isError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ERROR_CHAR));
                } // end else - if 

                // minAvgDailyBalance filter
                if(checknull(minAvgDailyBalance) && isNumberCheck(minAvgDailyBalance)) {
                    if(checknull(creditScore) || checknull(yearInBusiness) || checknullBoolean(restrictedIndustry) ||checknull(minMonthlyDeposite)|| checknull(maxNSFs) || restrictedState != false ||
                    checknull(minDepositeCount) || prefferedProgram != null ||checknull(maxNDBs))
                        query += ' and ';
                    query += '('+SObjectType.Program__c.fields.Min_Avg_Daily_Bal__c.Name+' <= '+decimal.valueOf( minAvgDailyBalance);
                    if(decimal.valueOf(minAvgDailyBalance) == 0) {
                        query += ' OR ';
                        query += SObjectType.Program__c.fields.Min_Avg_Daily_Bal__c.Name+' = '+ null+')';
                    }else {
                        query += ' ) ';
                    }// end else - if
                } else if(minAvgDailyBalance <> null && !isNumberCheck(minAvgDailyBalance)  && minAvgDailyBalance <> '') {
                    isError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ERROR_CHAR));
                }  // end else - if
            }//end if - Filters
            if(sortExpression!='Score') {
                string sortFullExp = sortExpression  + ' ' + sortDirection;
                query += ' order by '+sortFullExp+' NULLS LAST';
            }// end 

            // Create list program to store database query result
            List<Program__c> lstProgram = new List<Program__c> ();
            try {
                if(!isError)
                    lstProgram = Database.query(query);
            } catch(Exception e) {
                if(e.getMessage().contains('For input string:'))
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Too long number: '+e.getMessage().split(':')[1]));
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));  
            }// end try - catch
            
            createSymbol(lstProgram);

            // get attchments
            this.getAvailableAttachments();
            prefferedPgm = false;
            if(sortExpression=='Score')
                programWrapperList.sort();

            Integer initialSize = programWrapperList.size() > limitval ? limitval : programWrapperList.size();
            for(Integer i=0; i< initialSize; ++i) {
                if(programWrapperList!= null && programWrapperList.size() > 0 && programWrapperList[i] !=null){
                    programWrapListLimit.add(programWrapperList[i]);
                }//end if
            }// End for
            if(programWrapListLimit.size() == 0) {
                hideShowPrgCount = false;
                startCount = 0;
            } else {
                hideShowPrgCount = true;
                startCount =1;
            }
            noofRecords  = programWrapperList.size();
            sizeOfProgram = programWrapListLimit.size();
    }// end programs()

    //get symbol and add program into wrapper
    public void createSymbol(List<Program__c> lstProgram) {
        String symbolVal;
        for(Program__c prgm : lstProgram) {
            symbolVal='';
            Decimal score = 0;

            if(prgm.Credit_Score__c <= oppFieldSet.Credit_Score__c)
                        symbolVal += 'Credit_Score__c'; 
            if(prgm.Years_in_Business__c <= oppFieldSet.Account.Years_in_Business__c)
                        symbolVal += 'Years_in_Business__c';
            if(prgm.Min_Monthly_Deposits__c <= oppFieldSet.Gross_monthly_Sales__c)
                        symbolVal += 'Min_Monthly_Deposits__c';
            if(prgm.Max_No_NSFs__c >= oppFieldSet.NSFs_Avg__c)
                        symbolVal += 'Max_No_NSFs__c';
            if(prgm.Min_Avg_Daily_Bal__c <= oppFieldSet.Average_Daily_Balance__c)
                        symbolVal += 'Min_Avg_Daily_Bal__c';
            if(prgm.Max_NDBs__c >= oppFieldSet.NDBs_Avg__c)
                        symbolVal += 'Max_NDBs__c';
            if(prgm.Minimum_Deposit_Count__c <= oppFieldSet.Avg_Number_Bank_Deposits__c)
                        symbolVal += 'Minimum_Deposit_Count__c';

            // to calculate Matching %      
            if(oppFieldSet.Credit_Score__c != NULL ) {
                if(prgm.Credit_Score__c <= oppFieldSet.Credit_Score__c)
                    score++; 
            }

            if(oppFieldSet.Account.Years_in_Business__c != NULL) {
                if( prgm.Years_in_Business__c <= oppFieldSet.Account.Years_in_Business__c)
                    score++;
            }

            if(oppFieldSet.Gross_monthly_Sales__c != NULL ) {
                if( prgm.Min_Monthly_Deposits__c <= oppFieldSet.Gross_monthly_Sales__c )
                      score++;
            }

            if(oppFieldSet.Average_Daily_Balance__c != NULL) {
                if( prgm.Min_Avg_Daily_Bal__c <= oppFieldSet.Average_Daily_Balance__c )
                      score++;
            }

            if(oppFieldSet.Avg_Number_Bank_Deposits__c != NULL ) {
                if( prgm.Minimum_Deposit_Count__c <= oppFieldSet.Avg_Number_Bank_Deposits__c)
                      score++;
            }

            if(oppFieldSet.NSFs_Avg__c != NULL) {
                if( prgm.Max_No_NSFs__c >= oppFieldSet.NSFs_Avg__c)
                      score++;
            }
            
            if(oppFieldSet.NDBs_Avg__c != NULL ) {
                if( prgm.Max_NDBs__c >= oppFieldSet.NDBs_Avg__c )
                      score++;
            }

            if(prefferedProgram == true) {
                if( prgm.Preffered_Programs__c == prefferedProgram )
                     score++;
            }

            if(score != 0)
                score = ((score  / 8 ) *100);
            // Calculate Eligible Funding Amount= Gross Monthly Sales * Fun Amt - % of monthly gross sales
            Decimal eligibleFunAmt; 
            if(oppFieldSet.Account.Gross_monthly_Sales__c != null && prgm.Funding_Amt_of_Monthly_Gross_Sales__c != null)
                eligibleFunAmt = (oppFieldSet.Account.Gross_monthly_Sales__c * prgm.Funding_Amt_of_Monthly_Gross_Sales__c)/100;
            else
                eligibleFunAmt = 0;
            programWrapperList.add(new ProgramWrapper(prgm, false, Integer.valueOf(score), 
                                                          eligibleFunAmt, (Integer.valueOf(score) < 2 ? true : false ), symbolVal, prgm.Submission_Method__c));
                                                        
        }// end for
    }//end createSymbol()

    // show more program
    public void showMore() {
        Integer size = programWrapListLimit.size();
       
        for(Integer i = programWrapListLimit.size(); i < size+limitval; ++i) {
           
            if(programWrapperList != null && programWrapperList.size()>i){
                programWrapListLimit.add(programWrapperList[i]);
                
            }
        }
        sizeOfProgram = programWrapListLimit.size();
        //limitval = programWrapListLimit.size();
    }// end showMore()

    // use to sort the program
    public PageReference viewSortedData_Program() {
        programWrapperList.sort();
        programWrapListLimit.clear();
        for(Integer i=0; i<sizeOfProgram; ++i){
            if(programWrapperList!= null && programWrapperList.size() > i && programWrapperList[i] !=null){
                programWrapListLimit.add(programWrapperList[i]);
            }//end if
        }//end for
        return null;
    }// end viewSortedData_Program()

    // used to check is numberic 
    public Boolean isNumberCheck(String strFilterVal) {
        return (strFilterVal.replace('.','')).isNumeric();
    }// end isNumberCheck()

    // check null string
    public boolean checknull(string str) {
        if(str != null && str != '')
            return true;
        else
            return false;
    }

    // check null string
    public boolean checknull(Decimal str) {
        if(str != null)
            return true;
        else
            return false;
    }
    // check null boolean
    public boolean checknullBoolean(Boolean str) {
        if(str != null  && str != false)
            return true;
        else
            return false;
    }
    public boolean getMapSize(){
        if(prgmDocMap.size() == 0)
            return true;
        else
            return false;
    }
    
    // clear filter
    public void clearFilter(){
        creditScore = null;
        yearInBusiness = null;
        minMonthlyDeposite = null;
        minDepositeCount = null;
        minAvgDailyBalance = null;
        maxNSFs = null;
        maxNDBs = null;
        restrictedIndustry = false;
        restrictedState = false;
        prefferedProgram = false;
        showSelectList = false;
        this.getPrograms();
    }// end clearFilter()

    //check req. docs
    public void checkReqdDocument(){
        isCheckReqDoc = true;
        selectProgramForAtt();
        if(!programMap.isEmpty())
        {
            displayPopup = true;
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Select at least one program to view the required documents.'));
        }
        prgmDocMap.clear();
        // Query all the Document records of selected programs and display them 
        for(Required_Documents__c reqdDoc : [Select Name,Program__c,Program__r.Name from Required_Documents__c 
                                                    where Program__c IN: programMap.keySet()
                                                    order by Program__r.Name,Name]){
            if(prgmDocMap.isEmpty() || (!prgmDocMap.isEmpty() && !prgmDocMap.containsKey(reqdDoc.Program__r.Name)))
                prgmDocMap.put(reqdDoc.Program__r.Name, new list<String>{reqdDoc.Name});
            else if(prgmDocMap.containsKey(reqdDoc.Program__r.Name))
                prgmDocMap.get(reqdDoc.Program__r.Name).add(reqdDoc.Name);
        }// end for
        isCheckReqDoc = false;
    }// end checkReqdDocument()
    
    // select program for attchment - Select Attachment button
    public void selectProgramForAtt(){
        selectedProgramCount = 0;
        programMap.clear();
        for(ProgramWrapper wrapper: programWrapListLimit)
        {
            if(wrapper.isSelected == true) 
            {
                showSelectList = true;
                programMap.put(wrapper.prgm.Id,wrapper.prgm);
                selectedProgramCount++;
            }
        }
        if(selectedProgramCount == 0 && isCheckReqDoc == false)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Select at least one program to assign attachments.')); 
        }
        
        Set<String> setSelectedPrograms;
        Set<String> setOptions;
        //In attachment wrappper for all the att add the selected option
        for(AttachmentWrapper attWrapper : AttachmentWrapperList){
            setSelectedPrograms = new Set<String>();
            setSelectedPrograms.addAll(attWrapper.selectedPrograms);
            setOptions = new Set<String>();
            for(SelectOption selectopt : attWrapper.options) {
                setOptions.add(selectopt.getvalue());
            }
            attWrapper.selectedPrograms.clear();
            attWrapper.options.clear();
            for(ProgramWrapper wrapper: programWrapListLimit)
            {
                if(wrapper.isSelected == true && wrapper.submissionMethodValue.equalsIgnoreCase('Email')){
                    attWrapper.options.add(new selectOption(wrapper.prgm.Id, wrapper.prgm.Name));
                    if(setOptions.isEmpty() || !setOptions.contains(wrapper.prgm.Id))
                        setSelectedPrograms.add(wrapper.prgm.Id);
                }else if(setSelectedPrograms.contains(wrapper.prgm.Id))
                    setSelectedPrograms.remove(wrapper.prgm.Id);
                if(attWrapper.options.isEmpty())
                    showSelectList = false;
                else
                    showSelectList = true;
            }//end for ProgramWrapper
            attWrapper.selectedPrograms.addAll(setSelectedPrograms);
        }// end for attachment wrapper
    }//end selectProgramForAtt()
    
   // Used to update the attachment.
    public void saveme() {
        boolean isError = false;
        try{
            update mapAttachment.Values();
        }
        catch(Exception e){
            isError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage())); 
        }// end try - catch
    }// end saveme() 

    //Wrapper Class contains Program__c Object and isSelected to keep track of which Program__c is selected 
    public class ProgramWrapper implements Comparable{
        public Program__c prgm              {get; set;}
        public boolean isSelected           {get; set;}
        public Integer score                {get; set;}
        public Decimal PotentialFundingAmt  {get; set;}
        public Boolean missingInfo          {get; set;}
        public String matchingPer           {get; set;}
        public Decimal highValue;
        public Decimal lowValue;
        public String submissionMethodValue {get; set;}
        
        public ProgramWrapper(Program__c pProgram ,Boolean pIsSelected,Integer pScore,
                            Decimal pPotentialFundingAmt, boolean pMissingInfo, String pMatchingPer,String pSubmissionMethodValue ){
            prgm = pProgram;
            isSelected = pIsSelected;
            score = pScore;
            PotentialFundingAmt = pPotentialFundingAmt;
            missingInfo = pMissingInfo;
            matchingPer = pMatchingPer;
            highValue = 999999999999999999.99;
            lowValue = -999.999;
            submissionMethodValue = pSubmissionMethodValue;
        }

        public Decimal sortAscending(Decimal value, Decimal compareToValue){
            if((value==null?highValue:value) == (compareToValue==null?highValue:compareToValue))
                return 0;
            if((value==null?highValue:value) > (compareToValue==null?highValue:compareToValue))
                return 1;
            return -1;
        }
        public Decimal sortDescending(Decimal value, Decimal compareToValue){
            if((value==null?lowValue:value) == (compareToValue==null?lowValue:compareToValue))
                return 0;
            if((value==null?lowValue:value) > (compareToValue==null?lowValue:compareToValue))
                return -1;
            return 1;
        }
        public Integer compareTo(Object ObjToCompare) {
            ProgramWrapper compareTo =(ProgramWrapper)ObjToCompare;
            if(SubmissionWizardController.sortDirection.equals('ASC')){
                if(SubmissionWizardController.sortExp.equals('Funding_Amt_of_Monthly_Gross_Sales__c')){
                    return integer.valueOf(sortAscending(prgm.Funding_Amt_of_Monthly_Gross_Sales__c, compareTo.prgm.Funding_Amt_of_Monthly_Gross_Sales__c));
                }
                if(SubmissionWizardController.sortExp.equals('Commission_Percentage__c')){
                    return integer.valueOf(sortAscending(prgm.Commission_Percentage__c, compareTo.prgm.Commission_Percentage__c));
                }
                if(SubmissionWizardController.sortExp.equals('Max_Amount__c')){
                    return integer.valueOf(sortAscending(prgm.Max_Amount__c, compareTo.prgm.Max_Amount__c));
                }
                if(SubmissionWizardController.sortExp.equals('Max_No_NSFs__c')){
                    return integer.valueOf(sortAscending(prgm.Max_No_NSFs__c, compareTo.prgm.Max_No_NSFs__c));
                }
                if(SubmissionWizardController.sortExp.equals('Max_NDBs__c')){
                    return integer.valueOf(sortAscending(prgm.Max_NDBs__c, compareTo.prgm.Max_NDBs__c));
                }
                if(SubmissionWizardController.sortExp.equals('Min_Monthly_Deposits__c')){ 
                    return integer.valueOf(sortAscending(prgm.Min_Monthly_Deposits__c, compareTo.prgm.Min_Monthly_Deposits__c));
                }
                if(SubmissionWizardController.sortExp.equals('Minimum_Deposit_Count__c')){
                    return integer.valueOf(sortAscending(prgm.Minimum_Deposit_Count__c, compareTo.prgm.Minimum_Deposit_Count__c));
                }
                if(SubmissionWizardController.sortExp.equals('Years_in_Business__c')){
                    return integer.valueOf(sortAscending(prgm.Years_in_Business__c, compareTo.prgm.Years_in_Business__c));
                }
                if(SubmissionWizardController.sortExp.equals('Min_Avg_Daily_Bal__c')){
                    return integer.valueOf(sortAscending(prgm.Min_Avg_Daily_Bal__c, compareTo.prgm.Min_Avg_Daily_Bal__c));
                }
                if(SubmissionWizardController.sortExp.equals('Credit_Score__c')){
                    return integer.valueOf(sortAscending(prgm.Credit_Score__c, compareTo.prgm.Credit_Score__c));
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
                if(SubmissionWizardController.sortExp.equals('Funding_Amt_of_Monthly_Gross_Sales__c')){
                    return integer.valueOf(sortDescending(prgm.Funding_Amt_of_Monthly_Gross_Sales__c, compareTo.prgm.Funding_Amt_of_Monthly_Gross_Sales__c));
                }
                if(SubmissionWizardController.sortExp.equals('Commission_Percentage__c')){
                    return integer.valueOf(sortDescending(prgm.Commission_Percentage__c, compareTo.prgm.Commission_Percentage__c));
                }
                if(SubmissionWizardController.sortExp.equals('Max_Amount__c')){
                    return integer.valueOf(sortDescending(prgm.Max_Amount__c, compareTo.prgm.Max_Amount__c));
                }
                if(SubmissionWizardController.sortExp.equals('Max_No_NSFs__c')){
                    return integer.valueOf(sortDescending(prgm.Max_No_NSFs__c, compareTo.prgm.Max_No_NSFs__c));
                }
                if(SubmissionWizardController.sortExp.equals('Min_Avg_Daily_Bal__c')){
                    return integer.valueOf(sortDescending(prgm.Min_Avg_Daily_Bal__c, compareTo.prgm.Min_Avg_Daily_Bal__c));
                }
                if(SubmissionWizardController.sortExp.equals('Max_NDBs__c')){
                    return integer.valueOf(sortDescending(prgm.Max_NDBs__c, compareTo.prgm.Max_NDBs__c));
                }
                if(SubmissionWizardController.sortExp.equals('Min_Monthly_Deposits__c')){
                    return integer.valueOf(sortDescending(prgm.Min_Monthly_Deposits__c, compareTo.prgm.Min_Monthly_Deposits__c));
                }
                if(SubmissionWizardController.sortExp.equals('Minimum_Deposit_Count__c')){
                    return integer.valueOf(sortDescending(prgm.Minimum_Deposit_Count__c, compareTo.prgm.Minimum_Deposit_Count__c));
                }
                if(SubmissionWizardController.sortExp.equals('Years_in_Business__c')){
                    return integer.valueOf(sortDescending(prgm.Years_in_Business__c, compareTo.prgm.Years_in_Business__c));
                }
                if(SubmissionWizardController.sortExp.equals('Credit_Score__c')){
                    return integer.valueOf(sortDescending(prgm.Credit_Score__c, compareTo.prgm.Credit_Score__c));
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
            }//end else - if
            return null;
        }// end compareTo()
    }// end ProgramWrapper class

    //Used to show all attchments
    public void getAvailableAttachments() {
        Integer cnt = 1;
        AttachmentWrapperList.clear();
        mapAttachment = new map<Id, Attachment>([Select Name, Id,ContentType,BodyLength,
                                     Description,ParentId  From Attachment 
                                     where ParentId =: accId or ParentId =: oppId order by CreatedDate desc]);
        for(Attachment attachmnt : mapAttachment.values()){
            if(!defaultFilter.isEmpty() && boolean.valueOf((defaultFilter.values()[0]).Attachments_Selected_on_Load__c))
                AttachmentWrapperList.add(new AttachmentWrapper(cnt++,attachmnt,
                                                            true,programMap));
            else
                AttachmentWrapperList.add(new AttachmentWrapper(cnt++,attachmnt,
                                                            false,programMap));
        }// end for
    }// end getAvailableAttachments()
    
    //Used to get selected attchments
    public void getAttachments() {
        set<Id> attachmentId = new set<Id>();
        for(AttachmentWrapper wrapper:AttachmentWrapperList){
            if(wrapper.isRequired)
                attachmentId.add(wrapper.attachment.id);
        }
        mapAttachment = new map<Id, Attachment>([Select Name, Id,ContentType,Body,BodyLength,
                                     Description,ParentId  From Attachment 
                                     where Id IN: attachmentId order by CreatedDate desc]);
    }// end getAttachments()
    
    // delete attchment 
    public void deleteAttachment() {
        try{
            if (indexToRemove != null) {
                Attachment record = [SELECT Id 
                                    FROM Attachment 
                                    WHERE Id = :indexToRemove];
                delete record;
                AttachmentWrapperList = new list<AttachmentWrapper>();
                //oplist = new List<attachment>();
                getAvailableAttachments();
            }//end if
        }catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
        }// end try- catch
    }// end deleteAttachment()
    
    // reset all attachments
    public void resetAttachments() {
        AttachmentWrapperList.Clear();
        this.getAvailableAttachments();
    }// end resetAttachments()
    
    public PageReference cancel() {
        //return new PageReference('/'+OppId);
        return RedirectionHelper.getOpportunityDetailUrl(oppId, isInConsole);
    }
    
     public PageReference bckToOpportunity()
    {
        return RedirectionHelper.getOpportunityDetailUrl(oppId, isInConsole);
    }
    
    public PageReference openAttachment() {
        String pgRef =Page.OppMultipleAttachment.getUrl()+'?id='+oppId+'&retURL='+Page.SubmissionWizard.getUrl()+'?id='+oppId+'&accId='+accId+'&isStips=false&stipID=';
        return new PageReference(pgRef);
    }

    //upload all attachments
    public void CollectData() {
        OpportunityUtility utility = new OpportunityUtility();
        utility.CollectData();
        utility.getAllAttachment();
        resetAttachments();
    }

    //For Chatter Post
    private void postOnChatter() { 
        String chatterFeed = '' ;
        String programBankName = '';
        FeedItem oChatterFeedItem = new FeedItem();
        if(mapPgmAttachment != null) {
            for(Id pgmId : mapPgmAttachment.keySet()){
                if(programMap.get(pgmId)!= null)
                {
                    programBankName += (programBankName == '' ? '' : ', ') +programMap.get(pgmId).Bank__r.Name ;
                }
            }
        }else {
            for(Id pgmId : programMap.keySet())
            {
                if(programMap.get(pgmId)!= null)
                {
                    programBankName += (programBankName == '' ? '' : ', ') +programMap.get(pgmId).Bank__r.Name ;
                }
            }
        }
        chatterFeed = System.Label.Submission_ChatterFeedBody + ' ' + programBankName + 
                                ' by ' + userObj.FirstName + ' ' + userObj.LastName;
        PostToChatterUtility objClass = new PostToChatterUtility();
        try {
                insert objClass.postToChatter(chatterFeed , OppId);
        } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
        }
    }
    
    // start FO-1357.............................................

    //method to get picklist value
    public List<SelectOption> getSubmissionMethodOptions() {
        submissionMethodOptions.clear();
        Schema.DescribeFieldResult pgmPicklistValues = Program__c.Submission_Method__c.getDescribe();
        List <Schema.PicklistEntry> pgmlistPickListVal = pgmPicklistValues.getPicklistValues();
        for (Schema.PicklistEntry pgmPickValue: pgmlistPickListVal) {
            submissionMethodOptions.add(new SelectOption(pgmPickValue.getValue(),pgmPickValue.getLabel()));
        }
        return submissionMethodOptions;
    }
    // method to called on click of submit button
    public void submitToSend()
    {
        Savepoint svPntToSendSubmission = Database.setSavepoint();
        selectedProgramCount = 0;
        for(ProgramWrapper wrapper: programWrapListLimit)
        {
             if(wrapper.isSelected==true)
             {
                 selectedProgramCount ++;
                 if(wrapper.submissionMethodValue.equalsIgnoreCase('Manual') )//&& wrapper.isSelected==true)
                 {
                    programWrapListManual.add(wrapper);
                    if(!progrmWrprMap.containsKey(wrapper.prgm.Id))
                        progrmWrprMap.put(wrapper.prgm.Id, wrapper);
                 }
                 else
                 if(wrapper.submissionMethodValue.equalsIgnoreCase('Email'))// && wrapper.isSelected==true) 
                 {
                     programWrapListEmail.add(wrapper);
                     if(!progrmWrprMap.containsKey(wrapper.prgm.Id))
                         progrmWrprMap.put(wrapper.prgm.Id, wrapper);
                 }
             }
        }
        if(selectedProgramCount == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Select at least one program to proceed with submission.')); 
        }
        if(!programWrapListManual.isempty())
        {
            createWithoutSending(programWrapListManual, svPntToSendSubmission);
        }
        if(!programWrapListEmail.isempty())
        {
            sendWithSelectedAttachments(programWrapListEmail, svPntToSendSubmission);
        }
    }
    
    //Function used to create Submission records
    public Map<Id,Submission__c> createSubmission(Savepoint pSvPntToRollBck) {

        Map<Id,Submission__c> mapProgIdsubmission = new map<Id,Submission__c>();
        /*
        if(programMap.isEmpty()) {
            noExceptionForSubmissionCounter=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.Submission_SelectProgram)); 
        }
        
        if(AttachmentWrapperList.isEmpty() && isEmail == true) {
        //if(AttachmentWrapperList.isEmpty() && channelVal == 'Send with Attachments') {
            noExceptionForSubmissionCounter=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'There are no Attachments for Submission'));
        }
        */
        if(isEmail == true) {
            for(AttachmentWrapper wrapper : AttachmentWrapperList) {
                //If the Attachment is required then only send the attachment
                if(wrapper.isRequired) {
                    for(String pgm : wrapper.selectedPrograms) {
                        if(mapPgmAttachment.isEmpty() || (!mapPgmAttachment.isEmpty() && !mapPgmAttachment.containsKey((Id)pgm))){
                            mapPgmAttachment.put((Id)pgm, new list<Attachment>{wrapper.attachment});
                        } 
                        
                        else {
                            mapPgmAttachment.get((Id)pgm).add(wrapper.attachment);
                        }
                    }
                }
            }
        }
        
        if(mapPgmAttachment.isEmpty() && isEmail == true && !programMap.isEmpty()) {
            noExceptionForSubmissionCounter=false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select Attachments.'));
        }

        for(Id pgmId: progrmWrprMap.keySet()) 
        {
            if(progrmWrprMap.get(pgmId).prgm.Bank__r.recordtypeid != null && 
                    Schema.SObjectType.Account.getRecordTypeInfosById().get(progrmWrprMap.get(pgmId).prgm.Bank__r.recordtypeid).getname()!= null && 
                    Schema.SObjectType.Account.getRecordTypeInfosById().get(progrmWrprMap.get(pgmId).prgm.Bank__r.recordtypeid).getname() == 'Bank') {
                String strAttachmentIds;
                Decimal sizeofAttchmentsinMB;
                Boolean exceedSizePerFile;
                if(mapPgmAttachment != null && mapPgmAttachment.containsKey(pgmId)){
                    strAttachmentIds = '';
                    sizeofAttchmentsinMB = 0;
                    exceedSizePerFile = false;
                    for(Attachment attachment: mapPgmAttachment.get(pgmId)){
                        if(strAttachmentIds != '')
                            strAttachmentIds += ',';
                        strAttachmentIds += attachment.Id;
                        sizeofAttchmentsinMB += (((decimal.valueof(attachment.BodyLength))/1024)/1024).setScale(2);
                        if((((decimal.valueof(attachment.BodyLength))/1024)/1024).setScale(2) > 5){
                            exceedSizePerFile = true;
                        }
                    }
                }
                Submission__c tempSub = new Submission__c(Opportunity__c = OppId,
                                                     Contact__c = progrmWrprMap.get(pgmId).prgm.Bank__r.Main_Contact__c,
                                                     Status__c = 'UW',
                                                     Funder__c = progrmWrprMap.get(pgmId).prgm.Bank__c,
                                                     Program__c = pgmId,
                                                     Email__c = progrmWrprMap.get(pgmId).prgm.Submission_Email__c,
                                                     Channel__c = progrmWrprMap.get(pgmId).submissionMethodValue,
                                                     //Attachment_Size_Limit__c = (sizeofAttchmentsinMB>25? true: false);
                                                     Selected_Attachment_Id__c = strAttachmentIds!=null?strAttachmentIds:'',
                                                     Date_Submitted__c = system.now());
                                                     
                if(Integer.valueOf(System.Label.SubmissionSitesEmailValidityDuration) > 0 && progrmWrprMap.get(pgmId).submissionMethodValue.equalsIgnoreCase('Email'))                                       
                   tempSub.Time_Frame__c = Date.valueOf(system.Today().addDays(Integer.valueOf(System.Label.SubmissionSitesEmailValidityDuration)));
                  
                if((sizeofAttchmentsinMB > 25 || exceedSizePerFile == true) && System.Label.SubmissionWizardSitesPortalLink.equalsIgnoreCase('true'))
                    tempSub.Attachment_Size_Limit__c = true;
                else
                    tempSub.Attachment_Size_Limit__c = false;
                //include all submissions for Create Without Sending
                if(isManual == true) {
                    tempSub.SubmissionWizard_Counter__c = countSubmissions;
                    mapProgIdsubmission.put(pgmId,tempSub);
                    applicationSentToPgm.add(progrmWrprMap.get(pgmId).prgm);
                }
                else {
                    if(!progrmWrprMap.isEmpty() && progrmWrprMap.get(pgmId).prgm.Submission_Email__c <> null 
                                && progrmWrprMap.get(pgmId).prgm.Email_Template_Id__c <> null ) {
                        tempSub.SubmissionWizard_Counter__c = countSubmissions;
                        mapProgIdsubmission.put(pgmId,tempSub);
                        applicationSentToPgm.add(progrmWrprMap.get(pgmId).prgm);
                    }else {
                        lstApplicationNotSentToPgm.add(progrmWrprMap.get(pgmId).prgm);
                        showThankYouPage = true;
                        
                    }
                }
           } else {
                    applicationNotSentToPgm.add(progrmWrprMap.get(pgmId).prgm);
                    showThankYouPage = true;
                   
            }// end of record type check
        }
        if(lstApplicationNotSentToPgm.size() > 0 && applicationNotSentToPgm.size() > 0) {
           noExceptionForSubmissionCounter =false;
        }
        try {
            if(mapProgIdsubmission != null && !mapProgIdsubmission.isEmpty()) {
                if(isManual == true)
                    showThankYouPage = true;
                insert mapProgIdsubmission.values();
            }
        } catch(Exception ex) {
            Database.rollback(pSvPntToRollBck);
            showThankYouPage = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
          }
        return mapProgIdsubmission;
    }//end of create submission
     
     //Send Mail method
     public void sendMail(Map<Id,Submission__c> mapProgIdsubmission, Savepoint pSvPntAttSend) {
        list<Contact> tempContact;
        try{
            Integer i = 0;
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
            getAttachments();
            for(Id pgmId: mapProgIdsubmission.keySet()){
                ++i;
                List<String> CCAddress = new List<String>();
                List<String> senderOrgEmailAddresses = new List<String>();
                Messaging.Singleemailmessage message = new Messaging.Singleemailmessage();
                message.setTemplateId(progrmWrprMap.get(pgmId).prgm.Email_Template_Id__c);
                if(isEmail == true) {
                    Decimal sizeofAttchmentsinMB = 0;
                    Boolean exceedSizePerFile = false;
                    Messaging.EmailFileAttachment[] fileAttachments = new Messaging.EmailFileAttachment[]{};
                    if(mapPgmAttachment != null && mapPgmAttachment.get(pgmId) != null){
                        for( Attachment att: mapPgmAttachment.get(pgmId)){
                            sizeofAttchmentsinMB += (((decimal.valueof(att.BodyLength))/1024)/1024).setScale(2);
                            if((((decimal.valueof(att.BodyLength))/1024)/1024).setScale(2) > 5) {
                                exceedSizePerFile = true;
                            }
                            //Creating Messaging.EmailFileAttachment instance to create file attachment.
                            Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
                            fileAttachment.setFileName(att.Name);
                            fileAttachment.setContentType(att.ContentType);
                            if(att.BodyLength > 0)
                                fileAttachment.setBody(mapAttachment.get(att.Id).Body);
                            else
                                fileAttachment.setBody(Blob.valueOf('...'));
                            fileAttachment.setInline(false);
                            fileAttachments.add(fileAttachment);
                        }//End for.
                    }
                    if(!mapProgIdsubmission.get(pgmId).Attachment_Size_Limit__c)
                        message.setFileAttachments(fileAttachments);
                    /*if(exceedSizePerFile == false )
                        message.setFileAttachments(fileAttachments);
                    else if(sizeofAttchmentsinMB < 25 )
                        message.setFileAttachments(fileAttachments);*/ 
                }//end of if
                message.setWhatId(mapProgIdsubmission.get(pgmId).Id);
                tempContact = new list<Contact>{new Contact(Lastname = 'ESPL-'+ i + DateTime.Now(), email=progrmWrprMap.get(pgmId).prgm.Submission_Email__c)};
                insert tempContact;
                message.setTargetObjectId(tempContact[0].id);
                message.saveAsActivity = false;
                if(progrmWrprMap.get(pgmId).prgm.Submission_Email_CC_1__c <> null && progrmWrprMap.get(pgmId).prgm.Submission_Email_CC_1__c <> ''){
                    CCAddress.add(''+progrmWrprMap.get(pgmId).prgm.Submission_Email_CC_1__c);
                }
                if(progrmWrprMap.get(pgmId).prgm.Submission_Email_CC_2__c <> null && progrmWrprMap.get(pgmId).prgm.Submission_Email_CC_2__c <> ''){
                    CCAddress.add(''+progrmWrprMap.get(pgmId).prgm.Submission_Email_CC_2__c);
                }
                if(CCAddress.size()>0)
                    message.setCcAddresses(CCAddress);
                if(orgWidecustomSetting != null && (orgWidecustomSetting.values()[0]).IsOrgwideEmailAllowed__c == true){
                    OrgWideEmailAddress owea = [select Id,Address from OrgWideEmailAddress where Address =: (orgWidecustomSetting.values()[0]).OrgEmailAddress__c];
                    senderOrgEmailAddresses.add(owea.Address);
                    message.setOrgWideEmailAddressId(owea.Id);
                    
                }
                allMails.add(message);
            }// end of for
            if(allMails.size() > 0 ){
                List<Messaging.SendEmailResult> results =  Messaging.sendEmail(allMails);
                if(tempContact != null)
                    delete tempContact;
                postOnChatter();
                Opportunity opportunity = new Opportunity (Id = oppId);
                if(oppStages.contains(oppFieldSet.StageName)) {
                    opportunity.StageName = 'Underwriting';
                }
                if(noExceptionForSubmissionCounter) {
                    opportunity.Submission_Counter__c = countSubmissions;
                }
                update opportunity;
                showThankYouPage = true;
            }
         }
         catch(Exception e) {
            Database.rollback(pSvPntAttSend);
            showThankYouPage = false;
            try {
                if(tempContact != null && tempContact.size()>0 && tempContact[0].id != null)
                    delete tempContact;
                noExceptionForSubmissionCounter=false;
                if(mapProgIdsubmission != null && !mapProgIdsubmission.isEmpty() && mapProgIdsubmission.values()[0].Id!= null)
                    delete mapProgIdsubmission.values();
            } 
            catch(Exception exObj) 
            {
                /*
                    This try-catch block is added to handle any exception that occurs in catch block.
                    eg- Update of opportunity fails and so in catch block tempcontact cannot be deleted causing 
                    another DML exception.
                */
            }
            
            String error = MCAExceptionHandlerUtility.getErrorMessage(e);
            if(e.getTypeName() == 'System.QueryException' || e.getTypeName() == 'System.ListException')
            {
                error = system.Label.SubmissionWizardOrgWideEmailAddrError;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,error));
        }//end of catch
    }//end of send mail method 
    
     //select program for attchment - Select Attachment button
    public void selectedPrgrmForAttachmnt(list<ProgramWrapper> pProgramWrapperListLimit)
    {
        progrmWrprMap.clear();
        for( ProgramWrapper wrapper: pProgramWrapperListLimit)
        {
            if(wrapper.isSelected == true) 
            {
                showSelectList = true;
                progrmWrprMap.put(wrapper.prgm.Id,wrapper);
            }
        }
        Set<String> setSelectedPrograms;
        Set<String> setOptions;
        //In attachment wrappper for all the att add the selected option
        for(AttachmentWrapper attWrapper : AttachmentWrapperList)
        {
            setSelectedPrograms = new Set<String>();
            setSelectedPrograms.addAll(attWrapper.selectedPrograms);
            setOptions = new Set<String>();
            for(SelectOption selectopt : attWrapper.options) 
            {
                setOptions.add(selectopt.getvalue());
            }
            attWrapper.selectedPrograms.clear();
            attWrapper.options.clear();
            for(ProgramWrapper wrapper: pProgramWrapperListLimit)
            {
                if(wrapper.isSelected == true )
                {
                    attWrapper.options.add(new selectOption(wrapper.prgm.Id, wrapper.prgm.Name));
                    if(setOptions.isEmpty() || !setOptions.contains(wrapper.prgm.Id))
                        setSelectedPrograms.add(wrapper.prgm.Id);
                }
                else if(setSelectedPrograms.contains(wrapper.prgm.Id))
                {
                    setSelectedPrograms.remove(wrapper.prgm.Id);
                }
                if(attWrapper.options.isEmpty())
                    showSelectList = false;
                else
                    showSelectList = true;
            }
            attWrapper.selectedPrograms.addAll(setSelectedPrograms);
        }
    }
    
    //Sends an email with attachment on click of Send with Attachments button
    public PageReference sendWithSelectedAttachments(list<ProgramWrapper> pProgramWrapListEmail, Savepoint pSvPnt) 
    {
        //Savepoint svPntAttSend = Database.setSavepoint();
        isEmail = true;
        isManual= false;
        countSubmissions = countSubmissions + 1;
        selectedPrgrmForAttachmnt(pProgramWrapListEmail);
        Map<Id,Submission__c> mapProgIdsubmission = createSubmission(pSvPnt);
        sendMail(mapProgIdsubmission, pSvPnt);
        return null;
    }//end sendWithSelectedAttachments()

    //Function to Create Submission and Update Chatter w/o sending Email
    public PageReference createWithoutSending(list<ProgramWrapper> pProgramWrapListManual, Savepoint pSvPnt) 
    {
        isManual = true;
        isEmail= false;
        selectedPrgrmForAttachmnt(pProgramWrapListManual);
        Map<Id,Submission__c> mapProgIdsubmission = createSubmission(pSvPnt);
        return null; 
    }//end createWithoutSending()
    
    // end FO-1357...............................................
    
    //Wrapper Class contains Attachment Object and isRequired to keep track of which Attachment is isRequired 
    public class AttachmentWrapper {
        public Integer cnt                {get; set;}
        public Attachment attachment      {get; set;}
        public boolean isRequired         {get; set;}
        public List<selectOption> options {get; set;} // selected Program name in multi select picklist
        public list<String> selectedPrograms          {get; set;} // selected Programs
        //public string[] selectedPrograms          {get; set;}
        //public map<Id,Program__c> programMap {get; set;}
        public AttachmentWrapper(Integer pCnt, Attachment pAttachment ,Boolean pIsRequired, map<Id,Program__c> pProgramMap){
            cnt = pCnt;
            selectedPrograms = new list<String>();
            //selectedPrograms = new string[]{};
            for(String pgm : pProgramMap.keySet()){
                selectedPrograms.add(pgm);
            }
            attachment = pAttachment;
            isRequired = pIsRequired;
            //programMap = pProgramMap;
            options = new List<selectOption>();
            for(String pgm : pProgramMap.keySet()){
                 options.add(new selectOption(pgm, pProgramMap.get(pgm).Name));
            }
        }
    }// end AttachmentWrapper class
}// end class