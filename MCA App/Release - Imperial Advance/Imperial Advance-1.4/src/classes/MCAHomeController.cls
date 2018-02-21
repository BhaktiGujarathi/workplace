/* 
 *  Apex controller class call from MCA_Home page.
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

    //Constructor
    public MCAHomeController(){
        //List used for display count
        transient list<Opportunity> OppLst ;               
        transient list<Lead> leadLst ;                     
        transient list<Lead> leadThisWeekLst    ;           
        transient list<Opportunity> oppFundedThisMonthlst;
        transient list<Opportunity> CountOfUnderwriterOppLst = new list<Opportunity>();
        transient list<Opportunity> CountOfApprovedOppLst = new list<Opportunity>();
        transient list<Opportunity> CountOfSignedOppLst = new list<Opportunity>();
        transient list<Lead> countofUnreadLeads = new list<Lead>();
        transient list<lead> countOfNewLeadThisWeek = new list<lead>();
        //initialization of list used for query the opportunity and leads
        OppLst = new list<Opportunity>();
        leadLst = new list<Lead>();
        leadThisWeekLst = new list<Lead>();
        oppFundedThisMonthlst = new list<Opportunity>();
        
        OppLst = [Select Name,stageName from Opportunity];
        oppFundedThisMonthlst = [select Id,Funding_Amount__c from Opportunity where Date_Funded__c = THIS_MONTH];
        leadLst = [Select IsUnreadByOwner,Id From Lead where IsUnreadByOwner = true];
        leadThisWeekLst = [select Id from Lead where createdDate = This_Week]; 

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
        
    }//controller ends
}