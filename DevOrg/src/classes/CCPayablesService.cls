/*
    A Utility class for Create Contract Controller to handle the mehthods specific to Payables
*/
public with sharing class CCPayablesService { 
    
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
    public static Boolean payablesFieldsNullValidator(Payable__c objPayable){
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
    
    //to delete Payables
    public static void toDeletPayables(list<Payable__c> payableList, Integer rowNum)
    {
        list<SObject> payableDelList = new list<SObject>();
        list<UserRecordAccess> UserRecordAccessListNullChk = new list<UserRecordAccess>();
        
        try
        {
            //rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
            payableDelList = CreateContractControllerUtility.deleteForSObject(payableList,rowNum);
            
            if(payableDelList.size()>0){
                delete payableDelList;
            }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
        }
    }
    
    // to add a payable Row
    public static List<Payable__c> addPayableRow(Id OppId, 
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
            && objOpp != null && OppId != null) 
        {
            Account accObj = accList[0];
            // check if Payabck is 'Payback' or 'Funded'
            if(accObj.Payback_Funded__c == 'Payback'  || accObj.Payback_Funded__c == 'Funded') 
            {
                for(Receivable__c rec : receivableList)
                {
                    if(rec.Type__c == 'Commission')
                        objRec = rec;
                }
                
                payableList.add(new Payable__c( Opportunity__c = OppId,
                                                Type__c = 'Commission',
                                                Percentage__c = accObj.Commission_Percentage__c,
                                                Payback_Funded__c = accObj.Payback_Funded__c,
                                                Due_Date__c = Date.Today()+7,
                                                Amount_Due__c = calculatePayableDueAmount(accObj, objOpp),
                                                Status__c = 'Open - Needs Review',
                                                Receivable_Dependency__c = objRec.Id,
                                                Account__c = (accObj.Id == null ? null : accObj.ID),//account.Id,
                                                Deal_Amount_Used__c = objRec.Deal_Amount_Used__c,
                                                Memo__c = objRec.Memo__c));
            }
        }else{
                payableList.add(new Payable__c(Opportunity__c = OppId));
        }
        return payableList;
    }
    
    
    
    // method to calculate Amount_Due__c for the payable
    public static Decimal calculatePayableDueAmount (Account accObj, Opportunity objOpp) 
    {
        Decimal amountDue = (accObj.Commission_Percentage__c==null ? 0 : (accObj.Commission_Percentage__c/100)) * (accObj.Payback_Funded__c!=null 
                             && accObj.Payback_Funded__c=='Payback' ? (objOpp.Payback_Amount__c==null ? 0 : objOpp.Payback_Amount__c) : (objOpp.Funding_Amount__c==null ? 0:objOpp.Funding_Amount__c));
        
        return amountDue;
    }
    
    

    public static void onChangeOrgFeeCalculation(List<receivable__c> receivableList,List<payable__c> payableList)
    {
    
        decimal receivableOrgFee =0.00;
        for(Receivable__c rec:receivableList)
        {
            if(rec.Amount__c <> null && rec.Type__c == 'Origination Fee')
            {
                receivableOrgFee += rec.Amount__c;
            }
        }
        
        
        for(Payable__c pay : payableList)
        {
            if(pay.Payback_Funded__c!=null /*&& pay.Type__c!= null*/ && pay.Percentage__c!=null)
            {
                if(/*pay.Id == null &&*/ pay.Wizard_Check__c == false && pay.Payback_Funded__c == 'Origination Fee' /*&& pay.Type__c== 'Origination Fee'*/)
                {
                    pay.Amount_Due__c = receivableOrgFee * (pay.Percentage__c/100);
                }
            }
        }
        
        
    }
    
    public static void onChangeOfPayPaybackFunded(List<receivable__c> receivableList,List<payable__c> payableList, Opportunity objOpp, Decimal payableAmtTotal, Map<String, Schema.SObjectField> mapApiToOppFields)
    {   
        decimal receivableAmountCommission = 0.00;
        decimal receivableAmountAllRevenue = 0.00;
        
        for(Receivable__c rec:receivableList)
        {
            if(rec.Amount__c <> null && rec.Type__c == 'Commission'){
                receivableAmountCommission += rec.Amount__c;
            }
            if(rec.Amount__c <> null && rec.Type__c <> null){
                receivableAmountAllRevenue += rec.Amount__c;
            }
        }
        
        for(Payable__c pay : payableList)
        {
            if(!pay.Wizard_Check__c)
            {
                if(pay.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                    pay.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                if(pay.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                    pay.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                if(pay.Payback_Funded__c == 'Net Funded Amount')
                    pay.Deal_Amount_Used__c = CreateContractControllerUtility.treateNullAsZero(objOpp.Funding_Amount__c) - CreateContractControllerUtility.treateNullAsZero(objOpp.Payoff_Amount__c);
                if(pay.Payback_Funded__c == 'Net Commission Revenue')
                    pay.Deal_Amount_Used__c = calculateNetCommissionRevenue(objOpp, mapApiToOppFields);
                if(pay.Payback_Funded__c == 'Net Origination Fee')
                    pay.Deal_Amount_Used__c = calculateNetOriginationFees(objOpp, mapApiToOppFields);
                
                if(pay.Payback_Funded__c == 'Commission Revenue' && objOpp.Funding_Amount__c != null)
                    pay.Deal_Amount_Used__c = receivableAmountCommission;
                
                if(pay.Payback_Funded__c == 'All Revenue' && objOpp.Funding_Amount__c != null)
                    pay.Deal_Amount_Used__c = receivableAmountAllRevenue;
                
                if(pay.Payback_Funded__c == null)
                     pay.Deal_Amount_Used__c = 0.00;
               
               
                    pay.Amount_Due__c = CreateContractControllerUtility.treateNullAsZero(pay.Deal_Amount_Used__c) * (CreateContractControllerUtility.treateNullAsZero(pay.Percentage__c)/100);
                
            }
            
            
            /*************Merul*************************/
            CCPayablesService.onChangeOrgFeeCalculation(receivableList,payableList);
            /*************Merul*************************/
            
        }
        payableAmtTotal =0.00;
        if(payableList.size()>0)
        {
            for(Payable__c pay:payableList)
            {
                if(pay.Amount_Due__c!=null)
                payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
            }
        }
        
    }
    
    public Static void onChangeOfPayPercentage(List<receivable__c> receivableList,
                                               List<payable__c> payableList, 
                                               Opportunity objOpp, 
                                               Decimal payableAmtTotal, 
                                               Map<String, Schema.SObjectField> mapApiToOppFields)
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
            if(rec.Amount__c <> null && rec.Type__c <> null){
                receivableAmountAllRevenue += rec.Amount__c;
            }
        }
       
        
        for(Payable__c pay : payableList)
        {
            
            if(!pay.Wizard_Check__c)
            {
                //For Funded
                if(pay.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                
                //For Payback
                if(pay.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                pay.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                
                //For Net Funded Amount
                if(pay.Payback_Funded__c == 'Net Funded Amount')
                pay.Deal_Amount_Used__c = CreateContractControllerUtility.treateNullAsZero(objOpp.Funding_Amount__c) - CreateContractControllerUtility.treateNullAsZero(objOpp.Payoff_Amount__c);
                
                //For Net Commission Revenue
                if(pay.Payback_Funded__c == 'Net Commission Revenue')
                pay.Deal_Amount_Used__c =  calculateNetCommissionRevenue(objOpp, mapApiToOppFields);
                
                //For Net Origination Fee
                if(pay.Payback_Funded__c == 'Net Origination Fee')
                pay.Deal_Amount_Used__c =  calculateNetOriginationFees(objOpp, mapApiToOppFields);
                
                //For Commision Revenue
                if(pay.Payback_Funded__c == 'Commission Revenue' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = receivableAmountCommission;
                
                //All revenue
                if(pay.Payback_Funded__c == 'All Revenue' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = receivableAmountAllRevenue;
                
                
                //if(pay.Deal_Amount_Used__c != null && pay.Percentage__c != null)
                pay.Amount_Due__c = CreateContractControllerUtility.treateNullAsZero(pay.Deal_Amount_Used__c) * (CreateContractControllerUtility.treateNullAsZero(pay.Percentage__c)/100);
                
            }
            
            /*************Merul*************************/
            CCPayablesService.onChangeOrgFeeCalculation(receivableList,payableList);
            /*************Merul*************************/
            
            
            
        }
        
        payableAmtTotal =0.00;
        if(payableList.size()>0)
        {
            for(Payable__c pay:payableList)
            {
                if(pay.Amount_Due__c!=null)
                payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
            }
        }
        
        
    }
    
    public static Decimal calculateNetCommissionRevenue(Opportunity oppObj, Map<String, Schema.SObjectField> mapApiToOppFields)
    {
        decimal val = 0.00;
        if(mapApiToOppFields.get(System.Label.MCAFieldTotal_Commissions_Receivable) !=Null  && mapApiToOppFields.get(System.Label.MCACEField_Commissions_Payable_External) != Null)
        {
            String queryStr = 'Select '+System.Label.MCAFieldTotal_Commissions_Receivable+','+System.Label.MCACEField_Commissions_Payable_External+' From Opportunity Where id = \'' +oppObj.Id+'\'';
            List<Opportunity> tempOpp = database.Query(queryStr);
            if(tempOpp != null && tempOpp.size()>0)
            {
                oppObj.put(System.Label.MCAFieldTotal_Commissions_Receivable,tempOpp[0].get(System.Label.MCAFieldTotal_Commissions_Receivable));
                oppObj.put(System.Label.MCACEField_Commissions_Payable_External,tempOpp[0].get(System.Label.MCACEField_Commissions_Payable_External));
                
                val = CreateContractControllerUtility.treateNullAsZero((Decimal)(oppObj.get(System.Label.MCAFieldTotal_Commissions_Receivable))) - CreateContractControllerUtility.treateNullAsZero((Decimal)(oppObj.get(System.Label.MCACEField_Commissions_Payable_External)));
            }
        }
        else
            val = 0.00;
        return val;
     }
    
    public static Decimal calculateNetOriginationFees(Opportunity oppObj,  Map<String, Schema.SObjectField> mapApiToOppFields)
    {
        decimal val = 0.00;
        if(mapApiToOppFields.get(System.Label.MCAField_Total_Origination_Fees_Receivable) !=Null  && mapApiToOppFields.get(System.Label.MCACEField_Origination_Fees_Payable_External) != Null)
        {
            String queryStr = 'Select '+System.Label.MCAField_Total_Origination_Fees_Receivable+','+System.Label.MCACEField_Origination_Fees_Payable_External+' From Opportunity Where id = \'' +oppObj.Id+'\'';
            List<Opportunity> tempOpp = database.Query(queryStr);
            if(tempOpp != Null && tempOpp.size() >0)
            {
                oppObj.put(System.Label.MCAField_Total_Origination_Fees_Receivable,tempOpp[0].get(System.Label.MCAField_Total_Origination_Fees_Receivable));
                oppObj.put(System.Label.MCACEField_Origination_Fees_Payable_External,tempOpp[0].get(System.Label.MCACEField_Origination_Fees_Payable_External));
                
                val = CreateContractControllerUtility.treateNullAsZero((Decimal)(oppObj.get(System.Label.MCAField_Total_Origination_Fees_Receivable))) - CreateContractControllerUtility.treateNullAsZero((Decimal)(oppObj.get(System.Label.MCACEField_Origination_Fees_Payable_External)));
            }
        }
        else
            val = 0.00;
        return val;
    }
}