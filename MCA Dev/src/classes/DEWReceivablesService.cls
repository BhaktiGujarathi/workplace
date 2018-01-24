/*
    A Utility class for Create Contract Controller to handle the mehthods specific to Receivables
*/
public with sharing class DEWReceivablesService {

    public static Boolean isReceivableError = false;
    public static String recErrorMsg;
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

        if(objReceivable.Type__c == null && (objReceivable.Amount__c == null
            || objReceivable.Amount__c == 0.00) &&
            objReceivable.Percentage__c == null &&
            objReceivable.Payback_Funded__c == null &&
            objReceivable.Due_Date__c == null &&
            objReceivable.Status__c == null && objReceivable.Memo__c == null )
        {
            return true;
        }
        return false;
    }

    public Static void onChangeOfRecPercentage(
            List<Receivable__c> receivableList,
            Opportunity objOpp,
            List<FO_DEW_Calculate_Percentage_Of__c> lstCustomStngToCalculatePercentageOf)
    {
        Map<String, String> mapOppFieldApIFromCustomStng = new Map<String, String>();
        String objectType = 'Opportunity';
        Map<String, schema.sObjectType> schemaMap = schema.getGlobalDescribe();
        schema.SObjectType opportunitySchema = schemaMap.get(objectType);
        Map<String, Schema.SObjectField> fieldMap = opportunitySchema.getDescribe().fields.getMap();
        Schema.DisplayType fielddataType;
        for(FO_DEW_Calculate_Percentage_Of__c cstmStng : lstCustomStngToCalculatePercentageOf) {
            if(cstmStng.Receivable__c == true) {
                mapOppFieldApIFromCustomStng.put(
                    cstmStng.Percentage_Of_Value__c, cstmStng.Opportunity_Field_API_Name__c
                );
            }
        }
        for(Receivable__c rec : receivableList)
        {
            if( rec.Payback_Funded__c != null && rec.Percentage__c != null)
            {
                if(!mapOppFieldApIFromCustomStng.containsKey(rec.Payback_Funded__c) ) {
                    if(rec.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null) {
                        rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                    } else if(rec.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null) {
                        rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                    } else if(rec.Payback_Funded__c == 'Net Funded Amount') {
                        rec.Deal_Amount_Used__c = DEWUtility.treateNullAsZero(objOpp.Funding_Amount__c) 
                        - DEWUtility.treateNullAsZero(objOpp.Payoff_Amount__c);
                    }
                } else {
                    String oppField = mapOppFieldApIFromCustomStng.get(rec.Payback_Funded__c);
                    if(oppField == null || oppField == '') {
                        isReceivableError = true;
                        recErrorMsg = System.Label.DEW_Configure_custom_setting_msg
                        +' Opportunity Field API Name, this should not be blank';
                        ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.Error,System.Label.DEW_Configure_custom_setting_msg
                            +' Opportunity Field API Name, this should not be blank'));
                        return;
                    } else {
                        fielddataType = fieldMap.get(oppField).getDescribe().getType();
                    }

                    if(fielddataType == Schema.DisplayType.Double ||
                        fielddataType == Schema.DisplayType.Integer ||
                        fielddataType == Schema.DisplayType.Currency) {
                        rec.Deal_Amount_Used__c = (decimal)objOpp.get(mapOppFieldApIFromCustomStng.get(rec.Payback_Funded__c));
                    }else {
                        isReceivableError = true;
                        recErrorMsg = System.Label.DEW_Configure_custom_setting_msg+' '+rec.Payback_Funded__c
                        +'.';
                        ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.Error,System.Label.DEW_Configure_custom_setting_msg+' '+rec.Payback_Funded__c));
                    }
                }
                
                rec.Amount__c = setScale(
                    DEWUtility.treateNullAsZero(rec.Deal_Amount_Used__c) *
                    (DEWUtility.treateNullAsZero(rec.Percentage__c)/100),2);
            } else {
                if((rec.Payback_Funded__c != null && rec.Percentage__c == null)
                    || (rec.Payback_Funded__c == null && rec.Percentage__c != null)) {
                    rec.Amount__c = 0.00;
                }
            }
        }
    }

    public static void onChangeOfRecPaybackFunded(
            List<Receivable__c> receivableList,
            Opportunity objOpp,
            List<FO_DEW_Calculate_Percentage_Of__c> lstCustomStngToCalculatePercentageOf)
    {
        Map<String, String> mapOppFieldApIFromCustomStng = new Map<String, String>();
        for(FO_DEW_Calculate_Percentage_Of__c cstmStng : lstCustomStngToCalculatePercentageOf) {
            if(cstmStng.Receivable__c == true) {
                mapOppFieldApIFromCustomStng.put(
                    cstmStng.Percentage_Of_Value__c, cstmStng.Opportunity_Field_API_Name__c
                );
            }
        }
        String objectType = 'Opportunity';
        Map<String, schema.sObjectType> schemaMap = schema.getGlobalDescribe();
        schema.SObjectType opportunitySchema = schemaMap.get(objectType);
        Map<String, Schema.SObjectField> fieldMap = opportunitySchema.getDescribe().fields.getMap();
        Schema.DisplayType fielddataType;
        for(Receivable__c rec : receivableList)
        {
            if( rec.Payback_Funded__c != null && rec.Percentage__c != null)
            {
                
                if(!mapOppFieldApIFromCustomStng.containsKey(rec.Payback_Funded__c) ) {
                    if(rec.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null) {
                        rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                    } else if(rec.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null) {
                        rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                    } else if(rec.Payback_Funded__c == 'Net Funded Amount') {
                        rec.Deal_Amount_Used__c = DEWUtility.treateNullAsZero(objOpp.Funding_Amount__c) 
                        - DEWUtility.treateNullAsZero(objOpp.Payoff_Amount__c);
                    }
                } else {
                    String oppField = mapOppFieldApIFromCustomStng.get(rec.Payback_Funded__c);
                    if(oppField == null || oppField == '') {
                        isReceivableError = true;
                        recErrorMsg = System.Label.DEW_Configure_custom_setting_msg
                        +' Opportunity Field API Name, this should not be blank';
                        ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.Error, System.Label.DEW_Configure_custom_setting_msg
                            +' Opportunity Field API Name, this should not be blank'));
                        return;
                    } else {
                        fielddataType = fieldMap.get(oppField).getDescribe().getType();
                    }
                    if(fielddataType == Schema.DisplayType.Double ||
                        fielddataType == Schema.DisplayType.Integer ||
                        fielddataType == Schema.DisplayType.Currency) {
                        rec.Deal_Amount_Used__c = (decimal)objOpp.get(mapOppFieldApIFromCustomStng.get(rec.Payback_Funded__c));
                    } else {
                        isReceivableError = true;
                        recErrorMsg = System.Label.DEW_Configure_custom_setting_msg
                        +' '+rec.Payback_Funded__c+'.';
                        ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.Error, System.Label.DEW_Configure_custom_setting_msg
                            +' '+rec.Payback_Funded__c+'.'));
                    }
                }
                rec.Amount__c =setScale(DEWUtility.treateNullAsZero(rec.Deal_Amount_Used__c) *
                    (DEWUtility.treateNullAsZero(rec.Percentage__c)/100),2);
                
            } else {
                if((rec.Payback_Funded__c != null && rec.Percentage__c == null)||
                    (rec.Payback_Funded__c == null && rec.Percentage__c != null) ) {
                    rec.Amount__c = 0.00;
                }
            }
        }
    }

    public static void getReceivables(
        Integer recCount,
        Integer recWizardCount,
        List<Receivable__c> receivableList, Opportunity objOpp,
        List<FO_DEW_Calculate_Percentage_Of__c> lstCustomStngToCalculatePercentageOf)
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
                rec.Deal_Amount_Used__c = DEWUtility.treateNullAsZero(objOpp.Funding_Amount__c) -
                 DEWUtility.treateNullAsZero(objOpp.Payoff_Amount__c);
                else{
                    if(objOpp.Funding_Amount__c!=null)
                    rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                }
                if(rec.Percentage__c != null && rec.Deal_Amount_Used__c != null)
                rec.Amount__c = setScale(rec.Deal_Amount_Used__c * (rec.Percentage__c/100),2);
            }
        }
    }

    public static void addRowReceivable(
        Program__c selProgram,
        List<Receivable__c> receivableList,
        Opportunity objOpp,
        Id OppId) {
        if(selProgram != null && receivableList.size()<=0) {
            receivableList.add(new Receivable__c(Opportunity__c = OppId, Due_From_Account__c = objOpp.Bank_Name__c,
            Percentage__c = selProgram.Commission_Percentage__c,//selProgram.Commission_Percentage__c,
            Payback_Funded__c =selProgram.Payback_Funded__c,
            Amount__c =setScale((
                selProgram.Commission_Percentage__c==null ? 0 :(selProgram.Commission_Percentage__c/100))
                * (selProgram.Payback_Funded__c!=null
                && selProgram.Payback_Funded__c=='Payback'
                ? (objOpp.Payback_Amount__c==null ? 0 : objOpp.Payback_Amount__c):
                (objOpp.Funding_Amount__c==null ? 0 : objOpp.Funding_Amount__c)),2),
            Due_Date__c = Date.Today()+7,Type__c = 'Commission',Status__c = 'Pending' ));
        }
        else {
            receivableList.add(
                new Receivable__c(Opportunity__c = OppId, Due_From_Account__c = objOpp.Bank_Name__c)
            );
        }
    }

    public static void addRowReceivableForOriginationFeeType(
        List<Receivable__c> receivableList,
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
            && objOpp.Origination_fee__c != 0)
        {
            receivableList.add(
                new Receivable__c(
                    Opportunity__c = OppId,
                    Due_From_Account__c = objOpp.Account.id,
                    Type__c = 'Origination Fee',
                    Amount__c = setScale(objOpp.Origination_fee__c,2)
                )
            );
        }
    }

    public static List<Receivable__c> quickSaveReceivable(
        List<Receivable__c> receivableList,
        Opportunity objOpp,
        Id OppId)
    {
        list<Receivable__c> lstReceivableToUpsert = new list<Receivable__c> ();
        list<Receivable__c> lstReceivableToDisplay = new list<Receivable__c> ();
        list<Receivable__c> lstReceivableWithNullValueToDelete = new list<Receivable__c> ();
        if(receivableList.size() > 0 ) {
            for(Integer i=0; i<receivableList.size(); i++) {
                if(!DEWReceivablesService.receivablesFieldsNullValidator(receivableList[i])) {
                    lstReceivableToUpsert.add(receivableList[i]);
                    lstReceivableToDisplay.add(receivableList[i]);
                }else {
                    if(receivableList[i].Id != null)
                    lstReceivableWithNullValueToDelete.add(receivableList[i]);
                }
            }//end of for
        }
        lstReceivableToUpsert = DEWUtility.checkSaveAccessForSObject(lstReceivableToUpsert,UserInfo.getUserId());
        DEWUtility.upsertForSObject(lstReceivableToUpsert);
        delete lstReceivableWithNullValueToDelete;
        receivableList = DEWReceivablesService.getReceivablesFromDB(OppId);
        return receivableList;
    }

     public static decimal calculateRecAmtTotal(Decimal receivableAmtTotal, List<Receivable__c> receivableList) {
        receivableAmtTotal = 0.0;
        if(receivableList.size()>0){
            for(Receivable__c rec:receivableList)
            {
                if(rec.Amount__c!=null && rec.Status__c != 'Cancelled') {
                    receivableAmtTotal = receivableAmtTotal + setScale(rec.Amount__c,2);
                }
            }
        }
        return receivableAmtTotal;
    }

    private static Decimal setScale(Decimal amount,Integer precession) {
        return ((amount == null)? null:amount.setScale(precession));
    }
}