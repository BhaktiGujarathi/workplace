public with sharing class CommissionEngineUtility
{
    //method to get list of Agreements for particular set of account IDs
    public static List<MCACE__Commission_Agreement__c> getCommissionAgreementByAccountID(Map<Id, List<MCACE__Commission_Agreement__c>> pAccIDToAgrmntListMap ,
                                                                            Set<Id> pAccIDSet)
    {
        List<MCACE__Commission_Agreement__c> tempComAgrmList = new List<MCACE__Commission_Agreement__c>();
        for(Id accID :pAccIDSet)
        {
            if(pAccIDToAgrmntListMap.containsKey(accID) && pAccIDToAgrmntListMap.get(accID) != null)
            {    
                tempComAgrmList.addAll(pAccIDToAgrmntListMap.get(accID));
            }    
        }
        return tempComAgrmList;
    }
    
    // method to get list of Rules for particular set of structure IDs
    public static List<MCACE__Commission_Rule__c> getCommissionRuleByStructureID(Map<Id, List<MCACE__Commission_Rule__c>> pStructIDToRuleListMap ,
                                                                            Set<Id> pStructIDSet)
    {
        List<MCACE__Commission_Rule__c> tempComRuleList = new List<MCACE__Commission_Rule__c>();
        for(Id structID :pStructIDSet)
        {
            if(pStructIDToRuleListMap.containsKey(structID) && pStructIDToRuleListMap.get(structID) != null)
            {    
                tempComRuleList.addAll(pStructIDToRuleListMap.get(structID));
            }    
        }
    
        return tempComRuleList;
    }
    
    // method to get list of Rule Entries for particular set of Rule IDs
    public static List<MCACE__Commission_Rule_Entry__c> getCommissionEntryByRuleID(Map<Id, List<MCACE__Commission_Rule_Entry__c>> pRuleIDToentryListMap ,
                                                                            Set<Id> pRuleIDSet)
    {
        List<MCACE__Commission_Rule_Entry__c> tempComEntryList = new List<MCACE__Commission_Rule_Entry__c>();
        for(Id structID :pRuleIDSet)
        {
            if(pRuleIDToentryListMap.containsKey(structID) && pRuleIDToentryListMap.get(structID) != null)
            {    
                tempComEntryList.addAll(pRuleIDToentryListMap.get(structID));
            }    
        }
    
        return tempComEntryList;
    }
}