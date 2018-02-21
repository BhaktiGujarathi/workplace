public with sharing class ShraddhaSubmissionWizardController {
    public Id OppId                                      {get; set;}
    public String pAccId                                 {get; set;}
    public String whereClause;
    public Opportunity oppFieldSet                      {get;set;}
    public List<Opportunity> opportunityList            {get;set;}
    public string creditScore                           {get;set;}
    public string yearInBusiness                        {get;set;}
    public string monthlyDeposits                       {get;set;}
    public string monthlyDeposits1                      {get;set;}
    public string minAvgDailyBalance                    {get;set;}
    public Boolean industry                              {get;set;}
    public string maxNSFs                               {get; set;}
    public string maxNDBs                               {get; set;}
    public Boolean state                                 {get;set;}
    public Boolean prefferedProgram                     {get; set;}
    
    //Controller of ShraddhaSubmissionWizardController Class
    public ShraddhaSubmissionWizardController() {
        opportunityList = new List<Opportunity>();
        whereClause='';
        OppId = ApexPages.currentPage().getParameters().get('id');
        system.debug('***OppId ***'+OppId);
        pAccId = ApexPages.currentPage().getParameters().get('accId');
        whereClause += ' id = \'' + OppId + '\' ';
        system.debug('*** whereClause *** '+whereClause);
        oppFieldSet = this.getOpportunities();
        getSWDefaultFilters();
    }//End of Controller

    // Get all the fields from fieldset of Opportunity
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Opportunity.FieldSets.SWDealSummary.getFields();
    }//End method getFields()

    //To display field in opportunity deal summary section
    public Opportunity getOpportunities() {
        string query;
        String commaSepratedFields = '';
        for(Schema.FieldSetMember objFieldSet :this.getFields()) {
            if(commaSepratedFields == null || commaSepratedFields == ''){
                //String str =string.ValueOf(objFieldSet.getFieldPath());
                commaSepratedFields = string.ValueOf(objFieldSet.getFieldPath());
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + string.ValueOf(objFieldSet.getFieldPath());
            }
            system.debug('******** commaSepratedFields *******'+commaSepratedFields);
        }
        query = 'SELECT ' + commaSepratedFields + ' FROM Opportunity WHERE ' + whereClause;
        system.debug('******** query *******'+query);
        return database.query(query);
    }//End method getOpportunities()
    
    public void getSWDefaultFilters() {
        Opportunity oppVar;
        Map<String, SWDefaultFilters__c> sWDefaultFiltersMap = SWDefaultFilters__c.getAll();
        system.debug('******* sWDefaultFiltersMap ********'+sWDefaultFiltersMap);
        oppVar = this.getOpportunities();
            if(oppVar.Credit_Score__c!=null && boolean.valueOf(sWDefaultFiltersMap.get('DefaultFilter').Credit_Score__c)) {
                creditScore = string.valueof(oppVar.Credit_Score__c);
                system.debug('****** creditScore *********'+creditScore);
            }
            if(oppVar.Account.Years_in_Business__c!=null && boolean.valueOf(sWDefaultFiltersMap.get('DefaultFilter').Years_in_Business__c)) {
                yearInBusiness = string.valueof(oppVar.Account.Years_in_Business__c);
                system.debug('****** yearInBusiness *********'+yearInBusiness);
            }
             if(oppVar.Average_Daily_Balance__c!=null && boolean.valueOf(sWDefaultFiltersMap.get('DefaultFilter').Avg_Daily_Balance__c)) {
                minAvgDailyBalance = string.valueof(oppVar.Average_Daily_Balance__c);
                system.debug('****** minAvgDailyBalance *********'+minAvgDailyBalance);
            }
             if(oppVar.NDBs_Avg__c!=null && boolean.valueOf(sWDefaultFiltersMap.get('DefaultFilter').Max_NDBs__c)) {
                maxNDBs = string.valueof(oppVar.NDBs_Avg__c);
                system.debug('****** maxNDBs *********'+maxNDBs);
            }
            if(oppVar.NSFs_Avg__c!=null && boolean.valueOf(sWDefaultFiltersMap.get('DefaultFilter').Max_NSFs__c)) {
                maxNSFs = string.valueof(oppVar.NSFs_Avg__c);  
                system.debug('****** creditScore *********'+maxNSFs);
            }
            if(oppVar.Gross_monthly_Sales__c!=null && boolean.valueOf(sWDefaultFiltersMap.get('DefaultFilter').Monthly_Deposits1__c)) {
                monthlyDeposits1 = string.valueof(oppVar.Gross_monthly_Sales__c);
                system.debug('****** monthlyDeposits1 *********'+monthlyDeposits1);
            }
            if(oppVar.Avg_Number_Bank_Deposits__c!=null && boolean.valueOf(sWDefaultFiltersMap.get('DefaultFilter').Monthly_Deposits__c)) {
                monthlyDeposits = string.valueof(oppVar.Avg_Number_Bank_Deposits__c);
                system.debug('****** monthlyDeposits *********'+monthlyDeposits);
            }
            if(oppVar.Account.Industry!=null && boolean.valueOf(sWDefaultFiltersMap.get('DefaultFilter').Industry__c)) {
                industry = true;
                system.debug('****** industry *********'+industry);
            }
            if(boolean.valueOf(sWDefaultFiltersMap.get('DefaultFilter').Preferred_Programs__c)) {
                prefferedProgram = true;
                system.debug('****** creditScore *********'+prefferedProgram);
            }
            /*if(oppVar.Account.BillingState!=null && boolean.valueOf(sWDefaultFiltersMap.get('DefaultFilter').State__c)) {
                state = true;
                system.debug('****** state *********'+state);
            }*/
        
    }
    
}