/*
     Created by:Srikanth Pinnamaneni
*/     

Public Class CommissionAgreementTriggerHandler{
    
    Public Static void updateAgreementsOnInsert(List<Commission_Agreement__c > newAgreements){
    
        List<Commission_Agreement__c> AgreementList = [select id ,name,Active__c,Start_Date__c,End_Date__c,Account__c from Commission_Agreement__c ];
        List<Commission_Agreement__c> tempList = new List<Commission_Agreement__c>();
    
        for(Commission_Agreement__c  ca : newAgreements){
            for(Commission_Agreement__c  cd : AgreementList){
                if(ca.Account__c == cd.Account__C){
                    ca.Active__c = true;
                    ca.Start_Date__c = system.today();

            if(cd.End_date__c == null){
                        cd.Active__c = false;
                        cd.End_Date__c = system.today();
                        tempList.add(cd);
            }
                }
            
            }
        }
        update tempList;
    
    
    }
    
    Public Static void addErrorOnUpdate(List<Commission_Agreement__c > newAgreements){
        
        
        for(Commission_Agreement__c  cd : newAgreements){
            if(cd.Start_Date__c != null && cd.End_Date__c != null){
                if(cd.Active__c)
                cd.adderror('Agreement with Start and End dates cannot be Activated');
            
            }
        }
    
    }
    
    
    
    
}