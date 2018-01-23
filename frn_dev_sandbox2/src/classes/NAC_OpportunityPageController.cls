public class NAC_OpportunityPageController {

    public List<Opportunity> lstOpportunity {get; set;}
    public Opportunity opportunityObj {get; set;}
    public List<Patient_Insurance__c> lstPI {get; set;}
    public Map<Id, List<Patient_Insurance__c>> opportunityIdlstPIMap {get; set;}
    Set<Id> setOpportunityIds = new Set<Id>();
    Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();   
    public List<OpportunityWrapper> OpportunityWrapperList {get; set;}
    public String determinationScriptPageRef {get; set;}
    public Id quoteId {get; set;}

    public NAC_OpportunityPageController() {
        //quoteId = '';
        Id currentOpportunityId = ApexPages.currentPage().getParameters().get('id');
        quoteId = ApexPages.currentPage().getParameters().get('Qid');
        opportunityObj = new Opportunity();
        lstOpportunity = [SELECT Id, 
                                 Name,
                                 Referral_Instruction__c
                          FROM Opportunity 
                          WHERE id =: currentOpportunityId];
        opportunityObj = lstOpportunity[0];
        opportunityIdlstPIMap = new Map<Id, List<Patient_Insurance__c>>();
        OpportunityWrapperList = new List<OpportunityWrapper>();
        if(lstOpportunity.size() > 0) {
            for(Opportunity objOpportunity: lstOpportunity) {
                setOpportunityIds.add(objOpportunity.Id);
                system.debug('>>> objOpportunity.quotes : '+objOpportunity.Quotes);
                //determinationScriptPageRef ='/apex/NAC_QuotePDF?Qid='+objOpportunity.Quotes[0].Id;
                //system.debug('>>> pageRef : '+determinationScriptPageRef);
                opportunityMap.put(objOpportunity.Id, objOpportunity);
            }
            lstPI = [SELECT Name, 
                            Id, 
                            Opportunity__c, 
                            (SELECT Id, 
                                    name 
                             FROM Insurance_Benefits__r) 
                     FROM Patient_Insurance__c 
                     WHERE Opportunity__c IN : setOpportunityIds];
        }
        if(lstPI.size() > 0) {
            for(Patient_Insurance__c objPi: lstPI) {
                if(!opportunityIdlstPIMap.containsKey(objPi.Opportunity__c)){
                    opportunityIdlstPIMap.put(objPi.Opportunity__c, new List<Patient_Insurance__c>());
                }
                opportunityIdlstPIMap.get(objPi.Opportunity__c).add(objPi);
            }
            for(Id objPIId: opportunityIdlstPIMap.keySet()) {
                OpportunityWrapperList.add(new OpportunityWrapper (opportunityMap.get(objPIId), opportunityIdlstPIMap.get(objPIId)));
            }
        }
    } 
    
    public class OpportunityWrapper {
        public Opportunity instanceOpportunity {get; set;}
        public List<Patient_Insurance__c> lstPI {get; set;}
        
        public OpportunityWrapper (Opportunity instanceOpportunity, List<Patient_Insurance__c> lstPI ) {
            this.instanceOpportunity = instanceOpportunity;
            this.lstPI = lstPI;
        }
    }
}