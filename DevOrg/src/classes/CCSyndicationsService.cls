/*
    A Utility class for Create Contract Controller to handle the mehthods specific to syndications
*/
public with sharing class CCSyndicationsService { 
    
    // method to fetch syndications from DB
    public static list<Syndication__c> getSyndicationFromDB(Id oppId)
    {
        list<Syndication__c> syndicationListFromDB = [Select Name,
        Commission_Fee__c,
        ROR_per__c,
        Disbursment_Schedule__c,
        Servicing_Bank__c,
        Opportunity__c,
        Anticipated_Term_Months__c,
        Syndication_Amt__c,
        Deal_Funding_Amount__c,
        Syndication_Percentage__c,
        Profit_Amount__c,
        Syndicated_By__c,
        Repayment_Amt__c,
        Memo__c
        From Syndication__c
        Where Opportunity__c =: OppId ];
        return syndicationListFromDB;
    }
    
    //For checking Syndication fields null value
    public static Boolean syndicationFieldsNullValidator(Syndication__c objSyndication)
    {
        if(objSyndication.Syndication_Amt__c == null &&
            objSyndication.Commission_Fee__c == null &&
            objSyndication.Deal_Funding_Amount__c == null &&
            objSyndication.Servicing_Bank__c == null &&
            objSyndication.Syndication_Percentage__c == null &&
            objSyndication.Profit_Amount__c == null &&
            objSyndication.Anticipated_Term_Months__c == null &&
            objSyndication.Disbursment_Schedule__c == null &&
            objSyndication.ROR_per__c == null &&
            objSyndication.Syndicated_By__c == null && objSyndication.Memo__c == null)
        {
            return true;
        }
        return false;
    }
    
    // to delete syndications
    public static void toDeletSyndications(list<Syndication__c> syndicationList,integer rowNum)
    {
        list<Syndication__c> syndicationdelList = new list<Syndication__c>();
        try
        {
            //rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
            syndicationdelList = CreateContractControllerUtility.deleteForSObject(syndicationList,rowNum);
            
            if(syndicationdelList.size()>0){
                delete syndicationdelList;
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
            
        }
    }
}