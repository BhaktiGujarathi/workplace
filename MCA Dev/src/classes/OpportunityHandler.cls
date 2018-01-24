public with sharing class OpportunityHandler {

    //public List<Contract> listContract;
    public static final String FUNDED = Label.FUNDED;
    public static final String CLOSED_RENEWED = Label.CLOSED_RENEWED;
    OpportunityService service = new OpportunityService();
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
        new OpportunityService().ownerUpdateFromOpportunity(opportunityNewList, opportunityOldMap);
    }

    /**
   *
   */
   public void OnAfterInsert(map<Id, Opportunity> opportunityOldMap, list<Opportunity> opportunityNewList){
        //onAfter insert update contact from opportunity
        //new OpportunityService().ownerUpdateFromOpportunity(opportunityNewList, null);
   }//End OnAfterInsert

    public void updateStage(set<Id> setFundedOpportunity)
    {
        // commented for tkt FO-1512
        /*System.debug('####'+setFundedOpportunity);
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
        }*/
    }

    public void onBeforeInsert() {
        OpportunityService.updateOwnershipPercent((List<Opportunity>)trigger.new, null);
        service.trackOpportunityStage(trigger.new);
        OpportunityService.setActivityComment(trigger.new);
    }

    /*Update the stage of related Contract when Opportunity stage changes to funded.*/
    public void onBeforeUpdate() {
        List<Opportunity> opportunities = (List<Opportunity>)trigger.new;
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        Map<Id, Opportunity> opportunityOldMap = (Map<Id, Opportunity>)trigger.oldMap;
        OpportunityService.setActivityComment(opportunities);
        OpportunityService.updateOwnershipPercent(opportunities, opportunityOldMap);

        for(Opportunity opp : opportunities) {
            if(opportunityOldMap.get(opp.Id).StageName != opp.StageName) {
                opportunitiesToUpdate.add(opp);
            }
            if(opp.Stagename != null && opp.Stagename != opportunityOldMap.get(opp.id).Stagename ) {
                opp.Activities_in_Current_Stage__c =0;
            }
        }
        if(opportunitiesToUpdate.size() > 0) {
            service.trackOpportunityStage(opportunitiesToUpdate);
        }
    }

    /*Update the stage of related Contract when Opportunity stage changes to funded.*/
    /*public void onBeforeUpdate(map<Id, Opportunity> opportunityOldMap, list<Opportunity> opportunities){
        System.debug('update');
        set<Id> setFundedOpportunity = new set<Id>();
        for(Opportunity opp: opportunities){

            if(opportunityOldMap.get(opp.Id).StageName != opp.StageName)
            {
                setFundedOpportunity.add(opp.Id);
            }
        }

        this.updateStage(setFundedOpportunity);
    }*/
}