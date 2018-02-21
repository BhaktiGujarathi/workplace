/*************************Details*************************
Trigger    :  trgUpdateFundingSectionOfOpportunity 
Details               :  This trigger will update the Funding Information Section on Opportunity
Any Comment           :  Done
created date          :  24th Sep 2015
Last modified date    :  1st Oct 2015
**********************************************************/
trigger trgUpdateFundingSectionOfOpportunity on Funding_Information__c (after insert) {
    Set<Id> opptyIds = new Set<Id>();
    for(Funding_Information__c fi : trigger.new){
        opptyIds.add(fi.Related_Opportunity__c);
    }

    Map<Id,Opportunity> Oppty = new Map<Id,Opportunity>([select id,name,McaApp__Date_Funded__c,McaApp__Estimated_Renewal_Date__c,McaApp__Bank_Name__c,
                 McaApp__Funded_Notes__c,McaApp__Deal_Type__c,McaApp__Funding_Amount__c,
                 McaApp__Payback_Amount__c,McaApp__Term_Months__c,McaApp__Factor_Rate__c,McaApp__Origination_Fee__c,
                 McaApp__Holdback_Percentage__c,McaApp__Payment_Amount__c,McaApp__Total_Commissions_Receivable__c,McaApp__Total_Receivables__c,
                 McaApp__Schedule__c,McaApp__Total_Payables__c, McaApp__Buy_Rate__c, Advance_Rate__c, APR__c, Interest_Rate__c, Credit_Line_Amount__c, Lease_Type__c, Fee__c from Opportunity where id in : opptyIds]);

    List<Opportunity> OpptyToUpdate = new List<Opportunity>();
    
    for(Funding_Information__c fi : trigger.new){
        Opportunity opp = Oppty.get(fi.Related_Opportunity__c);     
        opp.McaApp__Payback_Amount__c = fi.Payback_Amount__c;
        opp.McaApp__Date_Funded__c = fi.Date_Funded__c;
        opp.McaApp__Estimated_Renewal_Date__c=fi.Estimated_Renewal_Date__c;
        opp.McaApp__Bank_Name__c = fi.Bank_Name__c;
        opp.McaApp__Funded_Notes__c = fi.Funded_Notes__c;
        opp.McaApp__Deal_Type__c = fi.Deal_Type__c;
        opp.McaApp__Funding_Amount__c = fi.Funding_Amount__c;
        
        opp.McaApp__Payback_Amount__c = fi.Payback_Amount__c;
        opp.McaApp__Term_Months__c = fi.Term_Months__c;
        opp.McaApp__Factor_Rate__c = fi.Factor_Rate__c;
        opp.McaApp__Origination_Fee__c = fi.Origination_Fee__c;
        
        opp.McaApp__Holdback_Percentage__c = fi.Holdback_Percentage__c;
        opp.McaApp__Payment_Amount__c = fi.Payment_Amount__c;
        opp.McaApp__Schedule__c = fi.Schedule__c;
        opp.McaApp__Buy_Rate__c = fi.Buy_Rate__c;

        opp.Advance_Rate__c = fi.Advance_Rate__c;
        opp.APR__c = fi.APR__c;
        opp.Interest_Rate__c = fi.Interest_Rate__c;
        opp.Credit_Line_Amount__c = fi.Credit_Line_Amount__c;
        opp.Lease_Type__c = fi.Lease_Type__c;
        opp.Fee__c = fi.Fee__c;

        OpptyToUpdate.add(opp);
    }
    
    
    if(OpptyToUpdate!=null && OpptyToUpdate.size()>0) update OpptyToUpdate;
         
    
}