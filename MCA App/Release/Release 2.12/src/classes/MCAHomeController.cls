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
    public Integer UnreadLeads                      {get;set;}
    public Integer NewLeadsThisWeek                 {get;set;}
    public Integer UnderwriterOpp                   {get;set;}
    public Integer ApprovedOpp                      {get;set;}
    public Integer signedContractOpp                {get;set;}
    public Integer appSentOpp                       {get;set;}
    public Integer holdOpp                          {get;set;}
    public Integer termsCompletedContract           {get;set;}
    public Integer appRecievedOpp                   {get;set;}
    public Integer contractSentOpp                  {get;set;}
    public String s                                  {get; set;}
    public List<String> lstOfStages                  {get;set;}
    //Constructor
    public MCAHomeController(){
        //List used for display count   
      /*  transient list<Opportunity> OppLst ;  
        transient list<Contract> Contractlst;             
        transient list<Lead> leadLst ;                     
        transient list<Lead> leadThisWeekLst    ;           
        transient list<Opportunity> oppFundedThisMonthlst;
        transient list<Opportunity> CountOfUnderwriterOppLst = new list<Opportunity>();
        transient list<Opportunity> CountOfApprovedOppLst = new list<Opportunity>();
        transient list<Opportunity> CountOfSignedOppLst = new list<Opportunity>();
        transient list<Opportunity> CountOfAppSentOppLst = new list<Opportunity>();
        transient list<Contract> CountOfContractLst = new list<Contract>();
        transient list<Opportunity> CountOfHoldOppLst = new list<Opportunity>();
        transient list<Lead> countofUnreadLeads = new list<Lead>();
        transient list<Lead> countOfNewLeadThisWeek = new list<Lead>();
        transient list<Opportunity> CountOfAppReceivedOppLst = new list<Opportunity>();
        transient list<Opportunity> CountOfContractSentOppLst = new list<Opportunity>();
          
        
        //initialization of list used for query the opportunity and leads
        OppLst = new list<Opportunity>();
        Contractlst = new list<Contract>();
        leadLst = new list<Lead>();
        leadThisWeekLst = new list<Lead>();
        oppFundedThisMonthlst = new list<Opportunity>();
        
        OppLst = [Select Name,stageName from Opportunity];
        termsCompletedContract = [Select count() from Contract where Term_Completed__c>45];
        oppFundedThisMonthlst = [select Id,Funding_Amount__c from Opportunity where Date_Funded__c = THIS_MONTH];
        leadLst = [Select IsUnreadByOwner,Id From Lead where IsUnreadByOwner = true AND IsConverted = false];
        leadThisWeekLst = [select Id,createdDate from Lead where createdDate = This_Week AND IsConverted = false]; 
        system.debug('***leadThisWeekLst***'+leadThisWeekLst);

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
        //TotalFundedAmtThisMonth = 0.0;
        
        
        //this for loop will display the unread leads/ 
        for(Lead leads: leadLst){
            if(leads.IsUnreadByOwner){
                countofUnreadLeads.add(leads);
                
            }
        }
        UnreadLeads = countofUnreadLeads.size();
        
        //This if will display all leads which are created in this week. 
        if(leadThisWeekLst != null && leadThisWeekLst.size()>0){
            NewLeadsThisWeek = leadThisWeekLst.size();
        }
        else
        NewLeadsThisWeek = 0;
        */
    }//controller ends
    
    
    
    public PageReference onLoad()
    {
    
        transient list<Opportunity> OppLst ;  
        transient list<Contract> Contractlst;             
        //transient list<Lead> leadLst ;                     
        //transient list<Lead> leadThisWeekLst    ;           
        transient list<Opportunity> oppFundedThisMonthlst;
        transient list<Opportunity> CountOfUnderwriterOppLst = new list<Opportunity>();
        transient list<Opportunity> CountOfApprovedOppLst = new list<Opportunity>();
        transient list<Opportunity> CountOfSignedOppLst = new list<Opportunity>();
        transient list<Opportunity> CountOfAppSentOppLst = new list<Opportunity>();
        transient list<Contract> CountOfContractLst = new list<Contract>();
        transient list<Opportunity> CountOfHoldOppLst = new list<Opportunity>();
        transient list<Lead> countofUnreadLeads = new list<Lead>();
        transient list<Lead> countOfNewLeadThisWeek = new list<Lead>();
        transient list<Opportunity> CountOfAppReceivedOppLst = new list<Opportunity>();
        transient list<Opportunity> CountOfContractSentOppLst = new list<Opportunity>();
          
        
        //initialization of list used for query the opportunity and leads
        OppLst = new list<Opportunity>();
        Contractlst = new list<Contract>();
        //leadLst = new list<Lead>();
        //leadThisWeekLst = new list<Lead>();
        oppFundedThisMonthlst = new list<Opportunity>();
        lstOfStages = new List<String>{System.Label.MCA_Home_Opportunity_Stage_Underwriting,
                                       System.Label.MCA_Home_Opportunity_Stage_Approved,
                                       System.Label.MCA_Home_Opportunity_Stage_Agreement_Signed,
                                       System.Label.MCA_Home_Opportunity_Stage_App_Sent,
                                       System.Label.MCA_Home_Opportunity_Stage_App_Missing,
                                       System.Label.MCA_Home_Opportunity_Stage_App_Received,
                                       System.Label.MCA_Home_Opportunity_Stage_Contract_Sent};
       
        OppLst = [Select Name,stageName from Opportunity WHERE stagename IN : lstOfStages];
        system.debug('$$$$$$$ oppLst'+OppLst.size());
        termsCompletedContract = [Select count() from Contract where Term_Completed__c>45];
        oppFundedThisMonthlst = [select Id,Funding_Amount__c from Opportunity where Date_Funded__c = THIS_MONTH];
       
       /*Commetnted for solving Heap size limit by Merul*/
       // leadLst = [Select IsUnreadByOwner,Id From Lead where IsUnreadByOwner = true AND IsConverted = false];
       UnreadLeads = [Select count() From Lead where IsUnreadByOwner = true AND IsConverted = false];
       
       /*Commetnted for solving Heap size limit by Merul*/
       // leadThisWeekLst = [select Id,createdDate from Lead where createdDate = This_Week AND IsConverted = false]; 
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
        //TotalFundedAmtThisMonth = 0.0;
        
        
        //this for loop will display the unread leads/ 
       /* for(Lead leads: leadLst){
            if(leads.IsUnreadByOwner){
                countofUnreadLeads.add(leads);
                
            }
        }
        UnreadLeads = countofUnreadLeads.size();  */
        
        //This if will display all leads which are created in this week. 
        /*if(leadThisWeekLst != null && leadThisWeekLst.size()>0){
            NewLeadsThisWeek = leadThisWeekLst.size();
        }
        else
        NewLeadsThisWeek = 0;*/
    
    
      return null;
    }
    
    
}