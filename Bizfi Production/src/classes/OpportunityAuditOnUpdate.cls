public with sharing class OpportunityAuditOnUpdate {
    public  List<Audit_Trail__c> lstAuditTrail;
    //public  Audit_Trail__c auditTrail;
    public  Audit_Trail__c auditTrailForOwnerChange;
    public  Audit_Trail__c auditTrailForOrgSubChange;
    public  Audit_Trail__c auditTrailForStageChange;
    public OpportunityAuditOnUpdate(){
        lstAuditTrail = new List<Audit_Trail__c>();
    }
    public void onOpportunityOwnerStatusUpdate(Map<Id,Opportunity> oldmap, List<Opportunity> newList)
    {
        
        for(Opportunity opportunity: newList)
        {
           
            if(oldmap.containsKey(opportunity.Id) && opportunity.OwnerId != oldmap.get(opportunity.Id).OwnerId)
            {
                auditTrailForOwnerChange = basicAuditTrailInfo(opportunity);
                auditTrailForOwnerChange.Old_owner__c =(oldmap.get(opportunity.Id).OwnerId);
                auditTrailForOwnerChange.New_owner__c = (opportunity.OwnerId);
                auditTrailForOwnerChange.Type__c = 'Owner';
                auditTrailForOwnerChange.Current_Stage__c = opportunity.StageName;
                lstAuditTrail.add(auditTrailForOwnerChange);
                
            }
            
           
            
            if(oldmap.containsKey(opportunity.Id) && opportunity.StageName != oldmap.get(opportunity.Id).StageName)
            {
                auditTrailForStageChange = basicAuditTrailInfo(opportunity);
                auditTrailForStageChange.Old_Status_Stage_value__c = oldmap.get(opportunity.Id).StageName;
                auditTrailForStageChange.New_Status_Stage_value__c = opportunity.StageName;
                auditTrailForStageChange.Type__c = 'Status / Stage';
                auditTrailForStageChange.Current_Owner__c = (opportunity.OwnerId);
                lstAuditTrail.add(auditTrailForStageChange ); 
            }
            
             // For organic Subs
            if(oldmap.containsKey(opportunity.Id) && opportunity.Organic_Sub__c != oldmap.get(opportunity.Id).Organic_Sub__c)
            {   
                //track Audit trail only id  OrgSub is checked 
                if(opportunity.Organic_Sub__c)
                {
                    auditTrailForOrgSubChange = basicAuditTrailInfo(opportunity);
                    auditTrailForOrgSubChange.Type__c = 'Organic Sub';
                    auditTrailForOrgSubChange.Current_Owner__c = opportunity.OwnerId;
                    auditTrailForOrgSubChange.Current_Stage__c = opportunity.StageName;
                    lstAuditTrail.add(auditTrailForOrgSubChange);
                }
                
            }
           
            
        }
        try
        {
            if(lstAuditTrail != null && lstAuditTrail.size() > 0)
            database.upsert(lstAuditTrail,false);
        }
        catch(Exception e)
        {
            system.debug('****'+e);
        }
        
    }
    
     public Audit_Trail__c basicAuditTrailInfo(Opportunity opportunity)
     {
            return new Audit_Trail__c(Object__c = 'Opportunity',
                                      Opportunity__c = opportunity.Id,
                                      Date_Time_change_was_made__c = opportunity.LastModifiedDate);
            
     
     }
    
}