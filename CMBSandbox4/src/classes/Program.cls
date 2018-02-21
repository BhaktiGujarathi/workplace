global with sharing class Program {

    public String  name;
    public String  bkPolicy;
    public String  externalBank;
    public Double  fundingAmtofMonthlyGrossSales;
    public Double  maxAmount;
    public Double  maxNoNSFs;
    public Double  minAvgDailyBal;
    public String  methodsOfRepayment;
    public Double  creditScore;
    public Double  minCreditScore;
    public Double  minimumDepositCount;
    public Double  minMonthlyCCAvg;
    public Double  minMonthlyDeposits;
    public Double  yearsinBusiness;
    public Double  minimumAdvance;
    public String  notes;
    public Double  ownershipPercentageRequirement;
    public Double  percentageNetAfterPayoff;
    public String  programId;
    public String  programDirectoryStatus;
    public String  restrictedIndustryList;
    public String  restrictedStates;
    public Boolean siteInspection;
    public String  submissionEmail;
    public String  taxLeanPolicy;
    public String  tradeReferences;
    public Double  transactionCount;
    public Double  turnaroundTime;
    public RequiredDocument[] requiredDocuments;
    
    
    public Program(Program__c p) {
    	name                           = p.Name;
	    bkPolicy                       = p.BK_Policy__c;
	    externalBank                   = p.External_Bank__c;
	    fundingAmtofMonthlyGrossSales  = p.Funding_Amt_of_Monthly_Gross_Sales__c;
	    maxAmount                      = p.Max_Amount__c;
	    maxNoNSFs                      = p.Max_No_NSFs__c;
	    minAvgDailyBal                 = p.Min_Avg_Daily_Bal__c;
	    methodsOfRepayment             = p.Methods_of_Repayment__c;
	    creditScore                    = p.Credit_Score__c;
	    minCreditScore                 = p.Min_Credit_Score__c;
	    minimumDepositCount            = p.Minimum_Deposit_Count__c;
	    minMonthlyCCAvg                = p.Min_Monthly_CC_Avg__c;
	    minMonthlyDeposits             = p.Min_Monthly_Deposits__c;
	    yearsinBusiness                = p.Years_in_Business__c;
	    minimumAdvance                 = p.Minimum_Advance__c;
	    notes                          = p.Notes__c;
	    ownershipPercentageRequirement = p.Ownership_Percentage_Requirement__c;
	    percentageNetAfterPayoff       = p.Percentage_Net_After_Payoff__c;
	    programId                      = p.Program_Id__c;
	    programDirectoryStatus         = p.Program_Directory_Status__c;
	    restrictedIndustryList         = p.Restricted_Industry_List__c;
	    restrictedStates               = p.Restricted_States__c;
	    siteInspection                 = p.Site_Inspection__c;
	    submissionEmail                = p.Submission_Email__c;
	    taxLeanPolicy                  = p.Tax_Lean_Policy__c;
	    tradeReferences                = p.Trade_References__c;
	    transactionCount               = p.Transaction_Count__c;
	    turnaroundTime                 = p.Turnaround_Time__c;
	    requiredDocuments              = new RequiredDocument[]{};
    }

}