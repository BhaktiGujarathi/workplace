/*
    A Utility class for Create Contract Controller to handle the mehthods specific to Payables
*/
public with sharing class DEWPayablesService {

    public static Boolean isPayableError = false;
    public static String payErrorMsg;
    //method to fetch Payables from DB
    public static list<Payable__c> getPayablesFromDB(Id oppId)
    {

        return [Select Name,
                Memo__c,
                Type__c,
                Status__c,
                Due_Date__c,
                Amount_Due__c,
                Opportunity__c,
                Payback_Funded__c,
                Deal_Amount_Used__c,
                Account__c,
                Account__r.type,
                Payee_Type__c,
                Percentage__c,
                Receivable_Dependency__c,
                Wizard_Check__c,
                IsCreatedFromGrid__c
                From Payable__c
                Where Opportunity__c =: oppId];
    }

    //For checking payables fields null value
    public static Boolean payablesFieldsNullValidator(Payable__c objPayable)
    {
        if(objPayable.Type__c == null && objPayable.Amount_Due__c == null &&
            objPayable.Percentage__c == null &&
            objPayable.Payback_Funded__c == null &&
            objPayable.Account__c == null && objPayable.Due_Date__c == null &&
            objPayable.Status__c == null && objPayable.Memo__c == null &&
            objPayable.Receivable_Dependency__c == null )
        {
            return true;
        }

        return false;
    }
    // to add a payable Row
    public static List<Payable__c> addPayableRow(
        Id OppId,
        Opportunity objOpp,
        List<Account> accList,
        List<Receivable__c> receivableList,
        List<Payable__c> payableList)
    {
        Receivable__c objRec = new Receivable__c();
        // null check for parameters

        if(accList != null && accList.size() > 0
            && receivableList != null && receivableList.size()>0
            && payableList.size()<=0
            && objOpp != null && OppId != null) {
            Account accObj = accList[0];
            // check if Payabck is 'Payback' or 'Funded'
            if(accObj.Payback_Funded__c == 'Payback'  || accObj.Payback_Funded__c == 'Funded') {
                for(Receivable__c rec : receivableList) {
                    if(rec.Type__c == 'Commission')
                        objRec = rec;
                }
                payableList.add(new Payable__c(
                    Opportunity__c = OppId,
                    Type__c = 'Commission',
                    Percentage__c = accObj.Commission_Percentage__c,
                    Payback_Funded__c = accObj.Payback_Funded__c,
                    Due_Date__c = Date.Today()+7,
                    Amount_Due__c = calculatePayableDueAmount(accObj, objOpp),
                    Status__c = 'Open - Needs Review',
                    Receivable_Dependency__c = objRec.Id,
                    Account__c = (accObj.Id == null ? null : accObj.ID),//account.Id,
                    Deal_Amount_Used__c = objRec.Deal_Amount_Used__c,
                    Wizard_Check__c = true,
                    Memo__c = objRec.Memo__c));
            } else {
                payableList.add(new Payable__c(Opportunity__c = OppId));
            }
        } else {
            payableList.add(new Payable__c(Opportunity__c = OppId));
        }
        return payableList;
    }

    // method to calculate Amount_Due__c for the payable
    public static Decimal calculatePayableDueAmount(Account accObj, Opportunity objOpp)
    {
        Decimal amountDue = ((DEWUtility.treateNullAsZero(accObj.Commission_Percentage__c))/100);
        if(accObj.Payback_Funded__c!=null && accObj.Payback_Funded__c=='Payback') {
            amountDue =amountDue * DEWUtility.treateNullAsZero(objOpp.Payback_Amount__c);
        }
        else {
            amountDue = amountDue * DEWUtility.treateNullAsZero(objOpp.Funding_Amount__c);
        }
        return amountDue;
    }

    public static void onChangeOfPayPaybackFunded(
        List<receivable__c> receivableList,
        List<payable__c> payableList,
        Opportunity objOpp,
        Map<String, Schema.SObjectField> mapApiToOppFields,
        List<FO_DEW_Calculate_Percentage_Of__c> lstCustomStngToCalculatePercentageOf
    )
    {
        decimal receivableAmountCommission = 0.00;
        decimal receivableAmountAllRevenue = 0.00;
        decimal receivableOrgFee = 0.00;

        for(Receivable__c rec:receivableList)
        {
            if(rec.Amount__c <> null && rec.Type__c == 'Commission'){
                receivableAmountCommission += rec.Amount__c;
            }

            if(rec.Amount__c <> null && rec.Type__c == 'Origination Fee')
            {
                receivableOrgFee += rec.Amount__c;
            }

            if(rec.Amount__c <> null && rec.Status__c != 'Cancelled'){
                receivableAmountAllRevenue += rec.Amount__c;
            }
        }
        Map<String, String> mapOppFieldApIFromCustomStng = new Map<String, String>();
        String objectType = 'Opportunity';
        Map<String, schema.sObjectType> schemaMap = schema.getGlobalDescribe();
        schema.SObjectType opportunitySchema = schemaMap.get(objectType);
        Map<String, Schema.SObjectField> fieldMap = opportunitySchema.getDescribe().fields.getMap();
        Schema.DisplayType fielddataType;
        for(FO_DEW_Calculate_Percentage_Of__c cstmStng : lstCustomStngToCalculatePercentageOf) {
            if(cstmStng.Payable__c == true) {
                mapOppFieldApIFromCustomStng.put(
                    cstmStng.Percentage_Of_Value__c, cstmStng.Opportunity_Field_API_Name__c
                );
            }
        }
        for(Payable__c pay : payableList)
        {
            if(/*!pay.Wizard_Check__c &&*/ pay.Payback_Funded__c != null && pay.Percentage__c != null)
            {
                if(!mapOppFieldApIFromCustomStng.containsKey(pay.Payback_Funded__c) ) {
                    if(pay.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null) {
                        pay.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                    }
                    if(pay.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null) {
                        pay.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                    }
                    if(pay.Payback_Funded__c == 'Net Funded Amount') {
                        pay.Deal_Amount_Used__c = DEWUtility.treateNullAsZero(objOpp.Funding_Amount__c)
                        - DEWUtility.treateNullAsZero(objOpp.Payoff_Amount__c);
                    }
                    if(pay.Payback_Funded__c == 'Net Commission Revenue') {
                        pay.Deal_Amount_Used__c = calculatePayNetCommissionRevenue(objOpp, mapApiToOppFields);
                    }
                    if(pay.Payback_Funded__c == 'Net Origination Fee') {
                        pay.Deal_Amount_Used__c = calculatePayNetOriginationFees(objOpp, mapApiToOppFields);
                    }
                    if(pay.Payback_Funded__c == 'Commission Revenue' && objOpp.Funding_Amount__c != null) {
                        pay.Deal_Amount_Used__c = receivableAmountCommission;
                    }
                    if(pay.Payback_Funded__c == 'All Revenue' && objOpp.Funding_Amount__c != null) {
                        pay.Deal_Amount_Used__c = receivableAmountAllRevenue;
                    }
                    if(pay.Payback_Funded__c == 'Origination Fee') {
                        pay.Deal_Amount_Used__c = receivableOrgFee ;
                    }
                }
                if(mapOppFieldApIFromCustomStng.containsKey(pay.Payback_Funded__c)) {
                    String oppField = mapOppFieldApIFromCustomStng.get(pay.Payback_Funded__c);
                    if(oppField == null || oppField == '') {
                        isPayableError = true;
                        payErrorMsg = System.Label.DEW_Configure_custom_setting_msg
                        +' Opportunity Field API Name, this should not be blank.';
                        ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.Error,  System.Label.DEW_Configure_custom_setting_msg
                            +' Opportunity Field API Name, this should not be blank.'));
                        return;
                    } else {
                        fielddataType = fieldMap.get(oppField).getDescribe().getType();
                    }
                    if(fielddataType == Schema.DisplayType.Double ||
                        fielddataType == Schema.DisplayType.Integer ||
                        fielddataType == Schema.DisplayType.Currency) {
                        pay.Deal_Amount_Used__c = (decimal)objOpp.get(mapOppFieldApIFromCustomStng.get(pay.Payback_Funded__c));
                    } else {
                        isPayableError = true;
                        payErrorMsg = System.Label.DEW_Configure_custom_setting_msg+pay.Payback_Funded__c;
                        ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.Error,
                            System.Label.DEW_Configure_custom_setting_msg+pay.Payback_Funded__c));
                    }
                }
                pay.Amount_Due__c = DEWUtility.treateNullAsZero(pay.Deal_Amount_Used__c)
                    * (DEWUtility.treateNullAsZero(pay.Percentage__c)/100);
            }
            else
            {
                if((pay.Payback_Funded__c != null && pay.Percentage__c == null)
                    ||(pay.Payback_Funded__c == null && pay.Percentage__c != null))
                {
                    pay.Amount_Due__c = 0.00;
                }
            }
        }
    }

    public Static void onChangeOfPayPercentage(
        List<receivable__c> receivableList,
        List<payable__c> payableList,
        Opportunity objOpp,
        Map<String, Schema.SObjectField> mapApiToOppFields,
        List<FO_DEW_Calculate_Percentage_Of__c> lstCustomStngToCalculatePercentageOf
    )
    {
        decimal receivableAmountCommission = 0.00;
        decimal receivableAmountAllRevenue = 0.00;
        decimal receivableOrgFee = 0.00;

        for(Receivable__c rec: receivableList)
        {
            if(rec.Amount__c <> null && rec.Type__c == 'Commission'){
                receivableAmountCommission += rec.Amount__c;
            }
            if(rec.Amount__c <> null && rec.Type__c == 'Origination Fee'){
                receivableOrgFee += rec.Amount__c;
            }
            if(rec.Amount__c <> null && rec.Status__c != 'Cancelled'){
                receivableAmountAllRevenue += rec.Amount__c;
            }
        }

        Map<String, String> mapOppFieldApIFromCustomStng = new Map<String, String>();
        String objectType = 'Opportunity';
        Map<String, schema.sObjectType> schemaMap = schema.getGlobalDescribe();
        schema.SObjectType opportunitySchema = schemaMap.get(objectType);
        Map<String, Schema.SObjectField> fieldMap = opportunitySchema.getDescribe().fields.getMap();
        Schema.DisplayType fielddataType;

        for(FO_DEW_Calculate_Percentage_Of__c cstmStng : lstCustomStngToCalculatePercentageOf) {
            if(cstmStng.Payable__c == true) {
                mapOppFieldApIFromCustomStng.put(
                    cstmStng.Percentage_Of_Value__c, cstmStng.Opportunity_Field_API_Name__c
                );
            }
        }
        for(Payable__c pay : payableList)
        {
            if(/*!pay.Wizard_Check__c &&*/ pay.Payback_Funded__c != null && pay.Percentage__c != null)
            {
                if(!mapOppFieldApIFromCustomStng.containsKey(pay.Payback_Funded__c) ) {
                    if(pay.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null) {
                        pay.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                    }
                    //For Payback
                    if(pay.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null) {
                        pay.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                    }
                    //For Net Funded Amount
                    if(pay.Payback_Funded__c == 'Net Funded Amount') {
                        pay.Deal_Amount_Used__c = DEWUtility.treateNullAsZero(objOpp.Funding_Amount__c) -
                        DEWUtility.treateNullAsZero(objOpp.Payoff_Amount__c);
                    }
                    //For Net Commission Revenue
                    if(pay.Payback_Funded__c == 'Net Commission Revenue') {
                        pay.Deal_Amount_Used__c =  calculatePayNetCommissionRevenue(objOpp, mapApiToOppFields);
                    }
                    //For Net Origination Fee
                    if(pay.Payback_Funded__c == 'Net Origination Fee') {
                        pay.Deal_Amount_Used__c =  calculatePayNetOriginationFees(objOpp, mapApiToOppFields);
                    }
                    //For Commision Revenue
                    if(pay.Payback_Funded__c == 'Commission Revenue' && objOpp.Funding_Amount__c != null) {
                        pay.Deal_Amount_Used__c = receivableAmountCommission;
                    }
                    //All revenue
                    if(pay.Payback_Funded__c == 'All Revenue' && objOpp.Funding_Amount__c != null) {
                        pay.Deal_Amount_Used__c = receivableAmountAllRevenue;
                    }
                    //Origination Fee
                    if(pay.Payback_Funded__c == 'Origination Fee') {
                        pay.Deal_Amount_Used__c = receivableOrgFee ;
                    }
                }

                //For Funded
                if(mapOppFieldApIFromCustomStng.containsKey(pay.Payback_Funded__c)) {
                    String oppField = mapOppFieldApIFromCustomStng.get(pay.Payback_Funded__c);
                    if(oppField == null || oppField == '') {
                        isPayableError = true;
                        payErrorMsg = System.Label.DEW_Configure_custom_setting_msg
                        +'Opportunity Field API Name, this should not be blank.';
                        ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.Error,System.Label.DEW_Configure_custom_setting_msg
                            +'Opportunity Field API Name, this should not be blank.'));
                        return;
                    } else {
                        fielddataType = fieldMap.get(oppField).getDescribe().getType();
                    }

                    if(fielddataType == Schema.DisplayType.Double ||
                        fielddataType == Schema.DisplayType.Integer ||
                        fielddataType == Schema.DisplayType.Currency) {
                        pay.Deal_Amount_Used__c = (decimal)objOpp.get(mapOppFieldApIFromCustomStng.get(pay.Payback_Funded__c));
                    }else {
                        isPayableError = true;
                        payErrorMsg =  System.Label.DEW_Configure_custom_setting_msg+pay.Payback_Funded__c;
                        ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.Error,  System.Label.DEW_Configure_custom_setting_msg+pay.Payback_Funded__c));
                    }
                }

                pay.Amount_Due__c = DEWUtility.treateNullAsZero(pay.Deal_Amount_Used__c)
                    * (DEWUtility.treateNullAsZero(pay.Percentage__c)/100);
            }
            else
            {
              if((pay.Payback_Funded__c != null && pay.Percentage__c == null)||
                (pay.Payback_Funded__c == null && pay.Percentage__c != null))
              {
                  pay.Amount_Due__c = 0.00;
              }
            }
        }
    }

    public static Decimal calculatePayNetCommissionRevenue(Opportunity oppObj,
        Map<String, Schema.SObjectField> mapApiToOppFields)
    {
        decimal val = 0.00;

        if(mapApiToOppFields.get(System.Label.MCAFieldTotal_Commissions_Receivable) !=Null
            && mapApiToOppFields.get(System.Label.MCACEField_Commissions_Payable_External) != Null)
        {
            String queryStr = 'Select '+System.Label.MCAFieldTotal_Commissions_Receivable
                +','+System.Label.MCACEField_Commissions_Payable_External
                +' From Opportunity Where id = \'' +oppObj.Id+'\'';
            List<Opportunity> tempOpp = database.Query(queryStr);
            if(tempOpp != null && tempOpp.size()>0)
            {
                oppObj.put(
                    System.Label.MCAFieldTotal_Commissions_Receivable,
                    tempOpp[0].get(System.Label.MCAFieldTotal_Commissions_Receivable)
                );
                oppObj.put(
                    System.Label.MCACEField_Commissions_Payable_External,
                    tempOpp[0].get(System.Label.MCACEField_Commissions_Payable_External)
                );
                val = DEWUtility.treateNullAsZero((Decimal)(oppObj.get(
                    System.Label.MCAFieldTotal_Commissions_Receivable)))
                    - DEWUtility.treateNullAsZero((Decimal)(oppObj.get(System.Label.MCACEField_Commissions_Payable_External)));
            }
        }
        else
            val = 0.00;
        return val;
     }

    public static Decimal calculatePayNetOriginationFees(Opportunity oppObj,
        Map<String, Schema.SObjectField> mapApiToOppFields)
    {
        decimal val = 0.00;
        if(mapApiToOppFields.get(System.Label.MCAField_Total_Origination_Fees_Receivable) !=Null
         && mapApiToOppFields.get(System.Label.MCACEField_Origination_Fees_Payable_External) != Null)
        {
            String queryStr = 'Select '+System.Label.MCAField_Total_Origination_Fees_Receivable+','
            +System.Label.MCACEField_Origination_Fees_Payable_External
            +' From Opportunity Where id = \'' +oppObj.Id+'\'';
            List<Opportunity> tempOpp = database.Query(queryStr);
            if(tempOpp != Null && tempOpp.size() >0)
            {
                oppObj.put(System.Label.MCAField_Total_Origination_Fees_Receivable,
                    tempOpp[0].get(System.Label.MCAField_Total_Origination_Fees_Receivable));
                oppObj.put(System.Label.MCACEField_Origination_Fees_Payable_External,
                    tempOpp[0].get(System.Label.MCACEField_Origination_Fees_Payable_External));
                val = DEWUtility.treateNullAsZero((Decimal)(oppObj.get(System.Label.MCAField_Total_Origination_Fees_Receivable)))
                - DEWUtility.treateNullAsZero((Decimal)(oppObj.get(System.Label.MCACEField_Origination_Fees_Payable_External)));
            }
        }
        else
            val = 0.00;
        return val;
    }

    public static List<payable__c> quickSavePayable(List<payable__c> payableList,Opportunity objOpp, Id OppId)
    {
        list<Payable__c> lstPayableToUpsert = new list<Payable__c> ();
        list<Payable__c> lstPayableToDisplay = new list<Payable__c> ();
        list<Payable__c> lstPayablesWithNullValueToDelete = new list<Payable__c> ();
        if(payableList.size() > 0 )
        {
            for(Integer i=0; i<payableList.size(); i++)
            {
                if(!DEWPayablesService.payablesFieldsNullValidator(payableList[i]))
                {
                    lstPayableToUpsert.add(payableList[i]);
                    lstPayableToDisplay.add(payableList[i]);
                }
                else
                {
                    if(payableList[i].Id != null)
                    lstPayablesWithNullValueToDelete.add(payableList[i]);
                }
            }
        }
        lstPayableToUpsert = DEWUtility.checkSaveAccessForSObject(lstPayableToUpsert,UserInfo.getUserId());
        DEWUtility.upsertForSObject(lstPayableToUpsert);
        delete lstPayablesWithNullValueToDelete;
        payableList = DEWPayablesService.getPayablesFromDB(OppId);
        return payableList;
    }

    // callCommissionCreatePayable
    public static Boolean callCommissionCreatePayable(
        Opportunity objOpp,
        Id OppId,
        String labelString,
        Boolean checkAdvCommCall,
        List<Payable__c> payableList)
    {
        List<Payable__C> advComPayableList = new List<Payable__C>();
        if(/*objOpp.Deal_Entry_Wizard_Check__c == false &&*/ checkAdvCommCall == false )
        {
            type t = type.forName(Label.CommissionEngineClassName);
            //type t = type.forName(labelString);
            if(t != Null)
            {
                MCAExtensionInterface_version McaExtension = (MCAExtensionInterface_version) t.newinstance();
                advComPayableList = McaExtension.commissioncal(OppId);
                if( advComPayableList.size() > 0)
                {
                    //To indicate the commision call has been made.
                    checkAdvCommCall = true;
                }
                payableList.addAll(advComPayableList);
            }
        }
        return checkAdvCommCall;
    }

    //standardsplitcreatePayable
    public static void standardSplitCreatePayable(
            Opportunity objOpp,
            Id OppId,
            List<Account> accList,
            List<receivable__c> receivableList,
            decimal CommissionPer,
            List<Payable__c> payableList,
            String  wizardType,
            String PREVIEW_SCREEN)
    {
        if(objOpp.Deal_Entry_Wizard_Check__c == false && accList.size() > 0
            && receivableList.size() >0 && receivableList <> null)
        {
            CommissionPer = DEWUtility.treateNullAsZero(accList[0].Commission_Percentage__c);
            for (integer i=0; i<receivableList.size();i++)
            {
                //if((receivableList[i].Type__c == 'Commission' && accList[0].Payback_Funded__c == 'Commission Revenue') && receivableList[i].Wizard_Check__c == false && objOpp.Deal_Entry_Wizard_Check__c == false && receivableList[i].IsCreatedFromGrid__c == false)
                if(receivableList[i] != null && receivableList[i].Amount__c!= null
                    && (receivableList[i].Type__c == 'Commission'
                    && accList[0].Payback_Funded__c == 'Commission Revenue')
                    && receivableList[i].Wizard_Check__c == false
                    && objOpp.Deal_Entry_Wizard_Check__c == false
                    && receivableList[i].IsCreatedFromGrid__c == false)
                {
                    payableList.add(new Payable__c(Opportunity__c = OppId,
                                    Type__c = receivableList[i].Type__c,
                                    Percentage__c = CommissionPer,
                                    Payback_Funded__c =accList[0].Payback_Funded__c,
                                    Due_Date__c = Date.Today()+7,
                                    Amount_Due__c = receivableList[i].Amount__c * (CommissionPer/100),
                                    Status__c = 'Open - Needs Review',
                                    Receivable_Dependency__c = receivableList[i].Id,
                                    Memo__c = receivableList[i].Memo__c,
                                    Deal_Amount_Used__c = receivableList[i].Deal_Amount_Used__c,
                                    Wizard_Check__c = true,
                                    Account__c = accList[0].Id));
                    receivableList[i].Wizard_Check__c = true;
                }//End If
                else if((accList[0].Payback_Funded__c == 'Payback'  || accList[0].Payback_Funded__c == 'Funded')
                && receivableList[i].Wizard_Check__c == false &&
                objOpp.Deal_Entry_Wizard_Check__c == false && receivableList[i].IsCreatedFromGrid__c == false)
                {
                    if(payableList.size()<=0 && wizardType != PREVIEW_SCREEN){
                            payableList = DEWPayablesService.addPayableRow(
                                OppId,
                                objOpp,
                                accList,
                                receivableList,
                                payableList
                          );
                    }
                    receivableList[i].Wizard_Check__c = true;
                }

                else if(receivableList.size() > 0 && (receivableList[i].Type__c <> null
                    && accList[0].Payback_Funded__c == 'All Revenue')
                    && receivableList[i].Wizard_Check__c == false &&
                    objOpp.Deal_Entry_Wizard_Check__c == false && receivableList[i].IsCreatedFromGrid__c == false)
                {
                    payableList.add(new Payable__c(Opportunity__c = OppId,
                                    Type__c = receivableList[i].Type__c,
                                    Percentage__c = CommissionPer,
                                    Payback_Funded__c =accList[0].Payback_Funded__c,
                                    Due_Date__c = Date.Today()+7,
                                    Amount_Due__c = DEWUtility.treateNullAsZero(receivableList[i].Amount__c) * (CommissionPer/100),
                                    Status__c = 'Open - Needs Review',
                                    Receivable_Dependency__c=receivableList[i].Id,
                                    Memo__c = receivableList[i].Memo__c,
                                    Deal_Amount_Used__c = receivableList[i].Deal_Amount_Used__c,
                                    Wizard_Check__c = true,
                                    Account__c = accList[0].Id));
                    receivableList[i].Wizard_Check__c = true;
                }
                else
                {
                    receivableList[i].Wizard_Check__c = true;
                }
            }
            update receivableList;
        }
    }

    public static decimal calculatePayAmtTotal(Decimal payableAmtTotal, List<Payable__c> payableList)
    {
         payableAmtTotal = 0.0;
         if(payableList.size()>0)
         {
            for(Payable__c pay:payableList){
                if(pay.Amount_Due__c!=null  && pay.Status__c != 'Cancelled')
                payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
            }
         }
         return payableAmtTotal;
    }
}