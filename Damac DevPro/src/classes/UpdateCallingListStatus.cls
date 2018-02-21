public class UpdateCallingListStatus {
  
    @InvocableMethod public static void checkCallingListStatus(List<ID> lstCaseID) {    
        System.debug('---lstCaseID--'+lstCaseID);
        list<Case> lstCase = new list<Case>();
        lstCase = [Select id,CaseNumber,status,
                  (Select id,name,Calling_List__c from AOPT_Cases__r)
                  from Case where id IN: lstCaseID ];
        
        list<String> lstCallingListID = new list<String>();
        for(Case objCase : lstCase){
            if(objCase.AOPT_Cases__r.Size()>0){
                for(AOPT_Case__c objAOPT : objCase.AOPT_Cases__r){
                    if(objAOPT.Calling_List__c != null){
                        lstCallingListID.add(objAOPT.Calling_List__c);
                    }
                }
            }
        } 
        list<Calling_List__c> lstCallingList = new list<Calling_List__c>();
        lstCallingList = [Select id,name, AOPT_Status__c,
                         (Select id,name,Case__c,Case__r.status from AOPT_Case_Calling_List__r
                         where Case__c != null)
                         from Calling_List__c where id IN : lstCallingListID];
        
        list<Calling_List__c> lstCallingListUpdate = new list<Calling_List__c>();
        for(Case objCase : lstCase){
            if(objCase.status == 'Closed'){
                for(Calling_List__c objCalling : lstCallingList){
                    if(objCalling.AOPT_Status__c != 'Closed' && objCalling.AOPT_Case_Calling_List__r.Size()>0){
                        boolean isAllClosedCases = false;
                        for(AOPT_Case__c objAOPT : objCalling.AOPT_Case_Calling_List__r){
                            if(objAOPT.Case__r.status == 'Closed'){
                                isAllClosedCases = true;
                            }
                            else{
                                isAllClosedCases = false;
                            }
                        }
                        if(isAllClosedCases){
                            objCalling.AOPT_Status__c = 'Closed';
                            lstCallingListUpdate.add(objCalling);
                        }
                    }
                }
            }
            else if(objCase.status == 'Rejected'){
                for(Calling_List__c objCalling : lstCallingList){
                    objCalling.AOPT_Status__c = 'Rejected';
                    lstCallingListUpdate.add(objCalling);
                }
            }
        } 
        if(lstCallingListUpdate.Size()>0){
            update lstCallingListUpdate;
        }                         
                  
    }
}