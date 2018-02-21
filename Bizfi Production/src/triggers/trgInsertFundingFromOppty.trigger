/*************************Details*************************
Trigger    :  trgInsertFundingFromOppty
Details               :  This trigger will insert Funding Information Record
Any Comment           :  Done
created date          :  24th Sep 2015
Last modified date    :  1st Oct 2015
**********************************************************/
trigger trgInsertFundingFromOppty on Opportunity (after update) {
    
    if(PreventOpptyTriggerTwice.firstRun == false){
    List<Funding_Information__c> fundings = new List<Funding_Information__c>();
   
    Map<Id,Opportunity> Oppty = new Map<Id,Opportunity>([select id,name,McaApp__Date_Funded__c,McaApp__Estimated_Renewal_Date__c,McaApp__Bank_Name__c,
                 McaApp__Funded_Notes__c,McaApp__Deal_Type__c,McaApp__Funding_Amount__c,
                 McaApp__Payback_Amount__c,McaApp__Term_Months__c,McaApp__Factor_Rate__c,McaApp__Origination_Fee__c,
                 McaApp__Holdback_Percentage__c, McaApp__Payment_Amount__c, McaApp__Total_Commissions_Receivable__c,McaApp__Total_Receivables__c,
                 McaApp__Schedule__c,McaApp__Total_Payables__c, McaApp__Buy_Rate__c, Advance_Rate__c, APR__c, Interest_Rate__c, Credit_Line_Amount__c, Lease_Type__c, Fee__c from Opportunity where id in : trigger.newMap.keyset()]);


    for(Opportunity opp : trigger.new){
        if(trigger.oldMap.get(opp.id).McaApp__Deal_Entry_Wizard_Check__c == false && trigger.newMap.get(opp.id).McaApp__Deal_Entry_Wizard_Check__c==true){
            
            Funding_Information__c fi = new Funding_Information__c();  
            fi.Related_Opportunity__c = opp.id;
            fi.Date_Funded__c = Oppty.get(opp.id).McaApp__Date_Funded__c;
            fi.Estimated_Renewal_Date__c = Oppty.get(opp.id).McaApp__Estimated_Renewal_Date__c;
            fi.Bank_Name__c = Oppty.get(opp.id).McaApp__Bank_Name__c;
            fi.Funded_Notes__c = Oppty.get(opp.id).McaApp__Funded_Notes__c;
            fi.Deal_Type__c = Oppty.get(opp.id).McaApp__Deal_Type__c;
            fi.Funding_Amount__c = Oppty.get(opp.id).McaApp__Funding_Amount__c;
            
            fi.Payback_Amount__c = Oppty.get(opp.id).McaApp__Payback_Amount__c;
            fi.Term_Months__c = Oppty.get(opp.id).McaApp__Term_Months__c;
            fi.Factor_Rate__c = Oppty.get(opp.id).McaApp__Factor_Rate__c;
            fi.Origination_Fee__c = Oppty.get(opp.id).McaApp__Origination_Fee__c;
            
            fi.Holdback_Percentage__c = Oppty.get(opp.id).McaApp__Holdback_Percentage__c;
            fi.Payment_Amount__c = Oppty.get(opp.id).McaApp__Payment_Amount__c;
            fi.Schedule__c = Oppty.get(opp.id).McaApp__Schedule__c;
            fi.Buy_Rate__c = Oppty.get(opp.id).McaApp__Buy_Rate__c;

            fi.Advance_Rate__c       = Oppty.get(opp.id).Advance_Rate__c;
            fi.APR__c                = Oppty.get(opp.id).APR__c;
            fi.Interest_Rate__c      = Oppty.get(opp.id).Interest_Rate__c;
            fi.Credit_Line_Amount__c = Oppty.get(opp.id).Credit_Line_Amount__c;
            fi.Lease_Type__c         = Oppty.get(opp.id).Lease_Type__c;
            fi.Fee__c                = Oppty.get(opp.id).Fee__c;

            fundings.add(fi);
        }
    }
        PreventOpptyTriggerTwice.firstRun = true;  
        if(fundings!=null && fundings.size()>0) insert fundings;
        
    }
}