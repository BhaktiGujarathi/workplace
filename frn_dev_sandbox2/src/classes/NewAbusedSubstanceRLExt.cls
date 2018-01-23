public class NewAbusedSubstanceRLExt {
    public String getretURL;
    public Abused_Substance__c newAbsSubsRecord{get;set;}
    public String absId{get;set;}
    
    public NewAbusedSubstanceRLExt(ApexPages.StandardController controller) {
        newAbsSubsRecord = new Abused_Substance__c();
        Opportunity newOpp = new Opportunity();
        getretURL = ApexPages.currentPage().getParameters().get('retURL');
        absId = ApexPages.currentPage().getParameters().get('id');
        System.debug('getretURL____________________________ '+getretURL);
        String[] s;
        if(getretURL != null && getretURL.length()>14){
            if(getretURL.contains('?')){
                String[] extraValue = getretURL.split('\\?');
                getretURL = extraValue[0];
                System.debug('pid>>>>>>>>>>'+getretURL);
            }
            s = getretURL.split('/');
            getretURL=s[s.size()-1];
            System.debug('pid>>>>>>>>>>'+getretURL);
        }
        String oppPrefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();              
        if(getretURL!= null && getretURL.length()>14 && getretURL.startsWith(oppPrefix)){
            newOpp = [SELECT Id, ContractId FROM Opportunity WHERE Id = :getretURL];
            newAbsSubsRecord.Opportunity__c = newOpp.Id;
            newAbsSubsRecord.Patient__c = newOpp.ContractId;           
        }             
        if(absId!= null && absId.length()>14){
            newAbsSubsRecord = [SELECT Id, Substance__c, Opportunity__c, Additional_Notes__c, Frequency__c, Age_of_First_Use__c, Method_of_Use__c, Duration_of_Current_Episode_of_Use__c, Stop_Long_Enough_to_Withdrawal__c, Date_of_Last_Use__c, Overdosed_on_this_Substance__c, Hospitalized_for_Overdose__c, Number_Times_Overdosed_on_this_Substance__c, Were_Any_Overdoses_Intentional__c, Most_Recent_Overdosed_Date__c, Explanation_of_Intentional_Overdose__c, Average_Amount_of_Use__c  FROM Abused_Substance__c WHERE Id = :absId];     
            getretURL = newAbsSubsRecord.Opportunity__c;
        }
    }
    public pagereference saveAndNew(){
        if(newAbsSubsRecord.Overdosed_on_this_Substance__c!='Yes'){
            newAbsSubsRecord.Hospitalized_for_Overdose__c = null;
            newAbsSubsRecord.Number_Times_Overdosed_on_this_Substance__c = null;
            newAbsSubsRecord.Were_Any_Overdoses_Intentional__c = null;
            newAbsSubsRecord.Most_Recent_Overdosed_Date__c = null;
            newAbsSubsRecord.Explanation_of_Intentional_Overdose__c = null;
        }
        upsert newAbsSubsRecord;
        System.debug('getretURL____________________________ '+newAbsSubsRecord);
        pageReference pg = new PageReference('/apex/NewAbusedSubstanceRL?retURL='+newAbsSubsRecord.Opportunity__c);
        //pg.getParameters().put('retURL', getretURL);
        pg.setRedirect(true);
        return pg;
    }
    
    public pagereference save(){
        if(newAbsSubsRecord.Overdosed_on_this_Substance__c!='Yes'){
            newAbsSubsRecord.Hospitalized_for_Overdose__c = null;
            newAbsSubsRecord.Number_Times_Overdosed_on_this_Substance__c = null;
            newAbsSubsRecord.Were_Any_Overdoses_Intentional__c = null;
            newAbsSubsRecord.Most_Recent_Overdosed_Date__c = null;
            newAbsSubsRecord.Explanation_of_Intentional_Overdose__c = null;
        }
        upsert newAbsSubsRecord;
        return new PageReference ('/' +newAbsSubsRecord.id);
    }
    public pagereference cancel(){
        return new PageReference ('/' +getretURL);
    }
    
    public PageReference redirectIfLocked() {
        if(absId != null) {
            return RecordLockUtility.redirectIfLocked(absId);
        } 
        else {
            return null;
        }
    }
}