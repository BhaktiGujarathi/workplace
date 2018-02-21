/*
    A Utility class for Create Contract Controller to handle the mehthods specific to Receivables
*/
public with sharing class DEWReceivablesService { 
    
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
    public static Boolean receivablesFieldsNullValidator(Receivable__c objReceivable)
    {
        
        if(objReceivable.Type__c == null && (objReceivable.Amount__c == null || objReceivable.Amount__c == 0.00) &&
            objReceivable.Percentage__c == null &&
            objReceivable.Payback_Funded__c == null &&
            /*(objReceivable.Deal_Amount_Used__c == null || objReceivable.Deal_Amount_Used__c == 0.00) &&*/
            objReceivable.Due_Date__c == null &&
            objReceivable.Status__c == null && objReceivable.Memo__c == null )
        {
            return true;
        }
        return false;
    }
    
    // to delete receivables
   /* public static void toDeletReceivables(List<Receivable__c> receivableList,Integer rowNum)
    {
        list<Receivable__c> receivableDelList = new list<Receivable__c>();
        list<UserRecordAccess> UserRecordAccessListNullChk = new list<UserRecordAccess>();
        
        try
        {
            //rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'))+1;
            //receivableDelList = DEWUtility.deleteForSObject(receivableList,rowNum);
            if(receivableDelList.size()>0)
            {
                delete receivableDelList;
            }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
        }
        
    }*/
 
    public Static void onChangeOfRecPercentage(List<Receivable__c> receivableList, Opportunity objOpp)
    {       
        for(Receivable__c rec : receivableList)
        {
                 if( rec.Payback_Funded__c != null && rec.Percentage__c != null)
                 {
                     if(rec.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                        rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                    else if(rec.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                            rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                    else if(rec.Payback_Funded__c == 'Net Funded Amount')
                            rec.Deal_Amount_Used__c = DEWUtility.treateNullAsZero(objOpp.Funding_Amount__c) - DEWUtility.treateNullAsZero(objOpp.Payoff_Amount__c);
                   
                    rec.Amount__c = DEWUtility.treateNullAsZero(rec.Deal_Amount_Used__c) * (DEWUtility.treateNullAsZero(rec.Percentage__c)/100);
            
                 
                 }
                 else
                {
                  if((rec.Payback_Funded__c != null && rec.Percentage__c == null)||(rec.Payback_Funded__c == null && rec.Percentage__c != null))
                  {
                      rec.Amount__c = 0.00;
                  }
                
                }
              
        }
        
    }
    
    public static void onChangeOfRecPaybackFunded(List<Receivable__c> receivableList, Opportunity objOpp)
    {
        for(Receivable__c rec : receivableList)
        {
                 if( rec.Payback_Funded__c != null && rec.Percentage__c != null)
                 {
                     if(rec.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                        rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                    else if(rec.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                            rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                    else if(rec.Payback_Funded__c == 'Net Funded Amount')
                            rec.Deal_Amount_Used__c = DEWUtility.treateNullAsZero(objOpp.Funding_Amount__c) - DEWUtility.treateNullAsZero(objOpp.Payoff_Amount__c);
                   
                    rec.Amount__c = DEWUtility.treateNullAsZero(rec.Deal_Amount_Used__c) * (DEWUtility.treateNullAsZero(rec.Percentage__c)/100);
            
                 
                 }
                 else
                {
                  if((rec.Payback_Funded__c != null && rec.Percentage__c == null)||(rec.Payback_Funded__c == null && rec.Percentage__c != null))
                  {
                      
                      rec.Amount__c = 0.00;
                  }
                
                }
              
        }
    }
    
    public static void getReceivables(Integer recCount, Integer recWizardCount, List<Receivable__c> receivableList, Opportunity objOpp)
    {       
        if(recCount == 1 || recWizardCount==1)
        {
            recCount = 2;
            recWizardCount = 2;
            for(Receivable__c rec:receivableList)
            {
                if(objOpp.Funding_Amount__c!=null && rec.Payback_Funded__c == 'Funded')
                rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                else if(objOpp.Payback_Amount__c != null && rec.Payback_Funded__c == 'Payback')
                rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                else if(rec.Payback_Funded__c == 'Net Funded Amount')
                rec.Deal_Amount_Used__c = DEWUtility.treateNullAsZero(objOpp.Funding_Amount__c) - DEWUtility.treateNullAsZero(objOpp.Payoff_Amount__c);
                else{
                    if(objOpp.Funding_Amount__c!=null)
                    rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                }
                if(rec.Percentage__c != null && rec.Deal_Amount_Used__c != null)
                rec.Amount__c = rec.Deal_Amount_Used__c * (rec.Percentage__c/100);
            }
        }
    }
    
    public static void addRowReceivable(Program__c selProgram, List<Receivable__c> receivableList, Opportunity objOpp, Id OppId)
    {
        if(selProgram != null && receivableList.size()<=0){
            receivableList.add(new Receivable__c(Opportunity__c = OppId, Due_From_Account__c = objOpp.Bank_Name__c,
            Percentage__c = selProgram.Commission_Percentage__c,//selProgram.Commission_Percentage__c,
            Payback_Funded__c =selProgram.Payback_Funded__c,
            
            Amount__c = (selProgram.Commission_Percentage__c==null ? 0 :(selProgram.Commission_Percentage__c/100)) * (selProgram.Payback_Funded__c!=null && selProgram.Payback_Funded__c=='Payback' ? (objOpp.Payback_Amount__c==null ? 0 : objOpp.Payback_Amount__c):(objOpp.Funding_Amount__c==null ? 0 : objOpp.Funding_Amount__c)),
            Due_Date__c = Date.Today()+7,Type__c = 'Commission',Status__c = 'Pending' ));
        }
        else
        {
            receivableList.add(new Receivable__c(Opportunity__c = OppId, Due_From_Account__c = objOpp.Bank_Name__c ));
        }
    }

    public static void addRowReceivableForOriginationFeeType(List<Receivable__c> receivableList, 
                                                            String wizardType, 
                                                            String selOfferid, 
                                                            Opportunity objOpp, 
                                                            String PREVIEW_SCREEN, 
                                                            Id OppId)
    {
        //Logic for non repeation of origination fee generation in recieviable screen
        Boolean orignRec = false;
        for(Receivable__c recWizard:receivableList){
            if(recWizard.Type__c == 'Origination fee'){
                orignRec = true;
            }
        }
        
        if(!orignRec && wizardType != PREVIEW_SCREEN && !string.isblank(selOfferId) 
            && objOpp.Account.id!= null && objOpp.Origination_fee__c != null 
            && objOpp.Origination_fee__c != 0 /*&&
        orgFeeOfSelectedOffID != NULL*/)
        {
            receivableList.add(new Receivable__c(Opportunity__c = OppId,
                                                    Due_From_Account__c = objOpp.Account.id,
                                                    Type__c = 'Origination Fee',
                                                    Amount__c = objOpp.Origination_fee__c));
        }
    }
    
    public static List<Receivable__c> quickSaveReceivable(List<Receivable__c> receivableList, Opportunity objOpp, Id OppId)
    {

            list<Receivable__c> lstReceivableToUpsert = new list<Receivable__c> ();
            list<Receivable__c> lstReceivableToDisplay = new list<Receivable__c> ();
            list<Receivable__c> lstReceivableWithNullValueToDelete = new list<Receivable__c> ();
            if(receivableList.size() > 0 )
            {
                for(Integer i=0; i<receivableList.size(); i++)
                {
                    if(!DEWReceivablesService.receivablesFieldsNullValidator(receivableList[i]))
                    {
                       
                        lstReceivableToUpsert.add(receivableList[i]);
                        lstReceivableToDisplay.add(receivableList[i]);
                    }
                    else
                    {
                        
                        if(receivableList[i].Id != null)
                        lstReceivableWithNullValueToDelete.add(receivableList[i]);
                    }
                }//end of for
            }
            lstReceivableToUpsert = DEWUtility.checkSaveAccessForSObject(lstReceivableToUpsert,UserInfo.getUserId());
            DEWUtility.upsertForSObject(lstReceivableToUpsert);
            delete lstReceivableWithNullValueToDelete;
            
            //Refreshing opportunity from DB.
            //objOpp = new CreateContractController().refereshOpportunityByID(OppId);
            
            //receivableList = lstReceivableToDisplay;
            receivableList = DEWReceivablesService.getReceivablesFromDB(OppId);
        return receivableList;
    }
     
     public static decimal calculateRecAmtTotal(Decimal receivableAmtTotal, List<Receivable__c> receivableList) 
     {
         receivableAmtTotal = 0.0;
         if(receivableList.size()>0){
            for(Receivable__c rec:receivableList){
                if(rec.Amount__c!=null)
                receivableAmtTotal = receivableAmtTotal + rec.Amount__c;
            }
         }
         return receivableAmtTotal;
     }
}