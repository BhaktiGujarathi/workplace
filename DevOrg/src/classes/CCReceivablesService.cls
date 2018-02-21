/*
    A Utility class for Create Contract Controller to handle the mehthods specific to Receivables
*/
public with sharing class CCReceivablesService { 
    
    // method to fetch receivables from DB 
    public static list<Receivable__c> getReceivablesFromDB(Id oppId)
    {
        list<Receivable__c> receivablesListFromDB = [Select Name,
        Memo__c,
        Type__c,
        Status__c,
        Amount__c,
        Due_Date__c,
        Percentage__c,
        Payback_Funded__c,
        Deal_Amount_Used__c,
        Opportunity__c,
        Opportunity__r.Commission_Percentage__c,
        Due_From_Account__c,
        Due_From_Account__r.Commission_Percentage__c,
        Wizard_Check__c,
        Amount_Due__c,
        IsCreatedFromGrid__c
        From Receivable__c
        Where Opportunity__c =: oppId];
        return receivablesListFromDB;
    }
    
    //For checking receivales fields null value
    public static Boolean receivablesFieldsNullValidator(Receivable__c objReceivable){
        if(objReceivable.Type__c == null && objReceivable.Amount__c == null &&
            objReceivable.Percentage__c == null &&
            objReceivable.Payback_Funded__c == null &&
            objReceivable.Deal_Amount_Used__c == null &&
            objReceivable.Due_Date__c == null &&
            objReceivable.Status__c == null && objReceivable.Memo__c == null )
        {
            return true;
        }
        return false;
    }
    
    // to delete receivables
    public static void toDeletReceivables(List<Receivable__c> receivableList,Integer rowNum){
        list<Receivable__c> receivableDelList = new list<Receivable__c>();
        list<UserRecordAccess> UserRecordAccessListNullChk = new list<UserRecordAccess>();
        
        try
        {
            //rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'))+1;
            receivableDelList = CreateContractControllerUtility.deleteForSObject(receivableList,rowNum);
            if(receivableDelList.size()>0)
            {
                delete receivableDelList;
            }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
        }
    }
    
    public Static void onChangeOfRecPercentage(List<Receivable__c> receivableList, Decimal receivableAmtTotal)
    {
        receivableAmtTotal = 0.00;
        
        for(Receivable__c rec : receivableList)
        {
           
               // if(rec.Deal_Amount_Used__c != null && rec.Percentage__c != null)
                    rec.Amount__c = CreateContractControllerUtility.treateNullAsZero(rec.Deal_Amount_Used__c) * (CreateContractControllerUtility.treateNullAsZero(rec.Percentage__c)/100);
            
        }
        
        if(receivableList.size()>0)
        {
            for(Receivable__c rec:receivableList)
            {
                if(rec.Amount__c!=null)
                    receivableAmtTotal = receivableAmtTotal + rec.Amount__c;
            }
        }
        
    }
    
    public static void onChangeOfRecPaybackFunded(List<Receivable__c> receivableList, Decimal receivableAmtTotal, Opportunity objOpp)
    {
        receivableAmtTotal = 0.00;
        for(Receivable__c rec : receivableList)
        {
                if(rec.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                    rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                else if(rec.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                    rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                else if(rec.Payback_Funded__c == 'Net Funded Amount')
                    rec.Deal_Amount_Used__c = CreateContractControllerUtility.treateNullAsZero(objOpp.Funding_Amount__c) - CreateContractControllerUtility.treateNullAsZero(objOpp.Payoff_Amount__c);
               
               if(rec.Payback_Funded__c == null)
                  rec.Deal_Amount_Used__c = 0.00;
               
               rec.Amount__c = CreateContractControllerUtility.treateNullAsZero(rec.Deal_Amount_Used__c) * (CreateContractControllerUtility.treateNullAsZero(rec.Percentage__c)/100);
            
            
        }
        
        if(receivableList.size()>0)
        {
            for(Receivable__c rec:receivableList)
            {
                if(rec.Amount__c!=null)
                receivableAmtTotal = receivableAmtTotal + rec.Amount__c;
            }
        }
        
    }
}