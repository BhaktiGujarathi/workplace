public with sharing class OpportunityHandler {
    
    public List<Contract> listContract;
    public static final String FUNDED = Label.FUNDED;
    public static final String CLOSED_RENEWED = Label.CLOSED_RENEWED;
    
    /*Update the stage of related Contract when Opportunity stage changes to funded.*/
    public void onAfterUpdate(map<Id, Opportunity> opportunityOldMap, list<Opportunity> opportunityNewList){
        System.debug('update');
        set<Id> setFundedOpportunity = new set<Id>();       
        for(Opportunity opp: opportunityNewList){
                
            if(opportunityOldMap.get(opp.Id).StageName != FUNDED && opp.StageName == FUNDED)
            {
                setFundedOpportunity.add(opp.Id);
            }
        }
        
        this.updateStage(setFundedOpportunity);
    }
    
    public void updateStage(set<Id> setFundedOpportunity)
    {
        System.debug('####'+setFundedOpportunity);
        try{
            listContract = [Select c.Stage__c, c.Opportunity__c, c.Id, Opportunity_Renewal__c From Contract c 
                                                    where Opportunity__c IN: setFundedOpportunity
                                                         or Opportunity_Renewal__c IN: setFundedOpportunity];
            
            for(Contract objContract:listContract){
                if(!setFundedOpportunity.isEmpty() && setFundedOpportunity.contains(objContract.Opportunity__c)){
                    System.debug('update Funded'+objContract);
                    objContract.Stage__c = FUNDED;
                    //objContract.Funded_Date__c = Date.today();
                }else if(!setFundedOpportunity.isEmpty() && setFundedOpportunity.contains(objContract.Opportunity_Renewal__c)){
                    objContract.Stage__c = CLOSED_RENEWED;
                    //objContract.Funded_Date__c = Date.today();
                    System.debug('update Closed won'+objContract);
                }
            }
            update listContract;
        }catch(Exception e){
            system.debug('-------'+e.getMessage());
        }
    }
}