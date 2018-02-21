/* 
 /*  Apex controller class call from MCA_Home page.
 *  Revision History: 
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Neena Tiwari           04/02/2014            Initial Draft 
 */
public with sharing class MCAHomeController {
                                                   
    //Count variables which will display under statistics section on page
    public Integer TotalFundedThisMonth             {get;set;}
    public Decimal TotalFundedAmtThisMonth          {get;set;}
    public Integer NewLeadsThisWeek                 {get;set;}
    public Integer UnderwriterOpp                   {get;set;}
    public Integer ApprovedOpp                      {get;set;}
    public Integer signedContractOpp                {get;set;}
    public Integer appSentOpp                       {get;set;}
    public Integer holdOpp                          {get;set;}
    public Integer termsCompletedContract           {get;set;}
    public Integer appRecievedOpp                   {get;set;}
    public Integer contractSentOpp                  {get;set;}
    public Integer renewalsProspectingOpp                  {get;set;}  
    public Integer renewalsRequestedOpp                  {get;set;}    
    public Integer agreementsRequestedOpp                  {get;set;}    
      
    public String s                                  {get; set;}
    public List<String> lstOfStages                  {get;set;}
    //Constructor
    public MCAHomeController(){
     
    }//controller ends
    
    
    
    public PageReference onLoad()
    {
    
        transient list<Opportunity> OppLst ;  
        //transient list<Contract> Contractlst;             
        transient list<Opportunity> oppFundedThisMonthlst;
        transient list<Opportunity> CountOfUnderwriterOppLst = new list<Opportunity>();
        transient list<Opportunity> CountOfApprovedOppLst = new list<Opportunity>();
        transient list<Opportunity> CountOfSignedOppLst = new list<Opportunity>();
        transient list<Opportunity> CountOfAppSentOppLst = new list<Opportunity>();
        //transient list<Contract> CountOfContractLst = new list<Contract>();
        transient list<Opportunity> CountOfHoldOppLst = new list<Opportunity>();
        transient list<Lead> countOfNewLeadThisWeek = new list<Lead>();
        transient list<Opportunity> CountOfAppReceivedOppLst = new list<Opportunity>();
        transient list<Opportunity> CountOfContractSentOppLst = new list<Opportunity>();
        transient list<Opportunity> CountOfRenewalsProspecting = new list<Opportunity>();          
        transient list<Opportunity> CountOfRenewalsRequested = new list<Opportunity>();          
        transient list<Opportunity> CountOfAgreementsRequested = new list<Opportunity>();          
        
        //initialization of list used for query the opportunity and leads
        OppLst = new list<Opportunity>();
        //Contractlst = new list<Contract>();
        oppFundedThisMonthlst = new list<Opportunity>();
        lstOfStages = new List<String>{System.Label.MCA_Home_Opportunity_Stage_Underwriting,
                                       System.Label.MCA_Home_Opportunity_Stage_Approved,
                                       System.Label.MCA_Home_Opportunity_Stage_Agreement_Signed,
                                       System.Label.MCA_Home_Opportunity_Stage_App_Sent,
                                       System.Label.MCA_Home_Opportunity_Stage_App_Missing,
                                       System.Label.MCA_Home_Opportunity_Stage_App_Received,
                                       System.Label.MCA_Home_Opportunity_Stage_Contract_Sent,
                                       System.Label.MCA_Home_Opportunity_Stage_Renewal_Prospecting,
                                       System.Label.MCA_Home_Opportunity_Stage_Renewal_Requested,
                                       System.Label.MCA_Home_Opportunity_Stage_Agreement_Requested};
       
        OppLst = [Select Name,stageName from Opportunity WHERE stagename IN : lstOfStages];
        //termsCompletedContract = [Select count() from Contract where Term_Completed__c>45];
        oppFundedThisMonthlst = [select Id,Funding_Amount__c from Opportunity where Date_Funded__c = THIS_MONTH];
       
        NewLeadsThisWeek = [select count() from Lead where createdDate = This_Week AND IsConverted = false];
      
       //This for loop will display the count of underwriter, approved and signed contract opportunity. 
        for(Opportunity opp1 : oppLst){
            if(opp1.stagename.equalsIgnoreCase(System.Label.MCA_Home_Opportunity_Stage_Underwriting)){
                CountOfUnderwriterOppLst.add(opp1);
                UnderwriterOpp = CountOfUnderwriterOppLst.size();
            }
            if(opp1.stagename.equalsIgnoreCase(System.Label.MCA_Home_Opportunity_Stage_Approved)){
                CountOfApprovedOppLst.add(opp1);
                ApprovedOpp = CountOfApprovedOppLst.size();
            }
            if(opp1.stagename.equalsIgnoreCase(System.Label.MCA_Home_Opportunity_Stage_Agreement_Signed)){
                CountOfSignedOppLst.add(opp1);
                signedContractOpp = CountOfSignedOppLst.size();
            }//
            if(opp1.stagename.equalsIgnoreCase(System.Label.MCA_Home_Opportunity_Stage_App_Sent)){
                CountOfAppSentOppLst.add(opp1);
                appSentOpp = CountOfAppSentOppLst.size();
            }//
            
            if(opp1.stagename.equalsIgnoreCase(System.Label.MCA_Home_Opportunity_Stage_App_Missing)){
                CountOfHoldOppLst.add(opp1);
                holdOpp = CountOfHoldOppLst.size();
            }
             if(opp1.stagename.equalsIgnoreCase(System.Label.MCA_Home_Opportunity_Stage_App_Received)){
                CountOfAppReceivedOppLst.add(opp1);
                appRecievedOpp = CountOfAppReceivedOppLst.size();
            }
            if(opp1.stagename.equalsIgnoreCase(System.Label.MCA_Home_Opportunity_Stage_Contract_Sent)){
                CountOfContractSentOppLst.add(opp1);
                contractSentOpp = CountOfContractSentOppLst.size();
            }
            if(opp1.stagename.equalsIgnoreCase(System.Label.MCA_Home_Opportunity_Stage_Renewal_Prospecting)){
                CountOfRenewalsProspecting.add(opp1);
                renewalsProspectingOpp = CountOfRenewalsProspecting.size();
            }        
            if(opp1.stagename.equalsIgnoreCase(System.Label.MCA_Home_Opportunity_Stage_Renewal_Requested)){
                CountOfRenewalsRequested.add(opp1);
                renewalsRequestedOpp = CountOfRenewalsRequested.size();
            } 
            if(opp1.stagename.equalsIgnoreCase(System.Label.MCA_Home_Opportunity_Stage_Agreement_Requested)){
                CountOfAgreementsRequested.add(opp1);
                agreementsRequestedOpp = CountOfAgreementsRequested.size();
            }                             
        }//for
        
        //This for loop will display total funded opportunity for current month 
        //and sum of funding amount all the opportunity funded this current month.
        if(oppFundedThisMonthlst.size() > 0){
            TotalFundedAmtThisMonth = 0.0;
            for(Opportunity opp2 :oppFundedThisMonthlst){
                if(opp2.Funding_Amount__c != null){
                    
                    TotalFundedAmtThisMonth += opp2.Funding_Amount__c;  
                }
            }
            List<String> args = new String[]{'0','number','$###,###'};
            s = String.format(TotalFundedAmtThisMonth.format(), args);
            
            TotalFundedThisMonth = oppFundedThisMonthlst.size(); 
        }
        else
        TotalFundedThisMonth = 0;
      
      return null;
    }
    
    
}