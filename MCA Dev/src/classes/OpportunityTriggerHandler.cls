/* Handler Class to Reflect the Roll-up of Amount of Recivables and Payables from  Opportunity
 * on to fields of campaign
 * 
 * Revision History:
 *   
 * Version         Author                       Date            Description
 * 1.0             Nachiket R. Deshpande        11/06/2014      Initial Draft
 * 1.1             Yogesh Mahajan               11/25/2015      changes in Handler for opportunityservice 
 */ 


public class OpportunityTriggerHandler {
    public void onBefore(list<Opportunity> opportunityList){
        // Calculate Deal Score 
        //OpportunityAssignDealScoreHelper oOpportunityAssignDealScoreHelper = new OpportunityAssignDealScoreHelper();
       // OpportunityAssignDealScoreHelper.calculateDealScoreValue(opportunityList);
    }
    
    public void OnAfterInsert(Map<Id,Opportunity>pOpportunityoldMap,Map<Id,Opportunity>pOpportunitynewMap,
                              list<Opportunity> pOldOpportunityList ,list<Opportunity> pNewOpportunityList){
        
        CalculateRollupOnCampaign objCalculateRollupOnCampaign = new CalculateRollupOnCampaign();
        objCalculateRollupOnCampaign.PopulateValuesOnCampaign(pOpportunityoldMap,pOpportunitynewMap,pOldOpportunityList, pNewOpportunityList);

        //List<Opportunity> listOpportunity = checkInsertUpdateOpportunity(true);
        //onAfter insert update contact from opportunity
        new OpportunityService().ownerUpdateFromOpportunity(pNewOpportunityList, null);
        //new OpportunityService().contactUpdate(listOpportunity);
    }//End OnAfterInsert
    
    public void OnAfterUpdate(Map<Id,Opportunity>pOpportunityoldMap, Map<Id,Opportunity>pOpportunitynewMap,
                              list<Opportunity> pOldOpportunityList ,list<Opportunity> pNewOpportunityList){
            
        CalculateRollupOnCampaign objCalculateRollupOnCampaign = new CalculateRollupOnCampaign();
        objCalculateRollupOnCampaign.PopulateValuesOnCampaignOnUpdate(pOpportunityoldMap,pOpportunitynewMap,pOldOpportunityList, pNewOpportunityList);
        
        //List<Opportunity> listOpportunity = checkInsertUpdateOpportunity(false);
        //new OpportunityService().contactUpdate(listOpportunity);
        new OpportunityService().ownerUpdateFromOpportunity(pNewOpportunityList, pOpportunityoldMap);
    }//End OnAfterUpdate

    public void OnAfterDelete(Map<Id,Opportunity>pOpportunityoldMap,Map<Id,Opportunity>pOpportunitynewMap,
                              list<Opportunity> pOldOpportunityList ,list<Opportunity> pNewOpportunityList){

        CalculateRollupOnCampaign objCalculateRollupOnCampaign = new CalculateRollupOnCampaign();
        objCalculateRollupOnCampaign.PopulateValuesOnCampaignOnDelete(pOpportunityoldMap,pOpportunitynewMap,pOldOpportunityList, pNewOpportunityList);
        
    }//End OnAfterDelete
    /*
    public void updatePreviousOpportunity(list<Opportunity> pcurrentOpportunityList){
        system.debug('......******************'+pcurrentOpportunityList.size()+'@@@'+pcurrentOpportunityList);
        set<id> oppId = new set<id>();
        for(Opportunity opp:pcurrentOpportunityList){
            //if(pNewOpportunityList.StageName = 'Renewal Prospecting')
            oppId.add(opp.Next_Opportunity__c);
        }
        system.debug('***oppId'+oppId);
        //select id, Name from Opportunity 
        list<Opportunity> nextOpportunity = [select Id, Name from Opportunity where id IN: oppId];
        system.debug('***nextOpportunity'+nextOpportunity);
        for(Opportunity nextOpp: nextOpportunity)
        {
            system.debug('***nextOpp'+nextOpp);
            for(Opportunity currentOpp : pcurrentOpportunityList){
                system.debug('***currentOpp'+currentOpp);
                if( currentOpp.Next_Opportunity__c!=null && currentOpp.Next_Opportunity__c == nextOpp.Id)
                    nextOpp.Previous_Opportunity1__c = currentOpp.id;
                    system.debug('***nextOpp>>>>'+nextOpp);
            }
        }
        upsert nextOpportunity;
        //upsert pNewOpportunityList[0];
    }
    */
    //Contact is updated from opportunity only if the owner and owner percent field are not null
    /*public List<Opportunity> checkInsertUpdateOpportunity(Boolean isInsert) {
        List<Opportunity> listOpportunity = new List<Opportunity>();
        Set<Opportunity> setOpportunity = new Set<Opportunity>();
        Map<Id, Opportunity> oldOpportunityMap = (Map<Id, Opportunity>) trigger.oldMap;
        for(Opportunity newOpportunity : (List<Opportunity>) trigger.new) {
            if(!isInsert) {
                Opportunity oldOpportunity = oldOpportunityMap.get(newOpportunity.Id);
                System.debug('>>oldOpportunity>>>'+oldOpportunity);
                if(newOpportunity.Owner_1__c != oldOpportunity.Owner_1__c ||
                 newOpportunity.Owner_1_Ownership__c != oldOpportunity.Owner_1_Ownership__c) {
                    System.debug('>>if1>>>'+oldOpportunity);
                    setOpportunity.add(newOpportunity);
                }
                
                if(newOpportunity.Owner_2__c != oldOpportunity.Owner_2__c ||
                 newOpportunity.Owner_2_Ownership__c != oldOpportunity.Owner_2_Ownership__c) {
                    System.debug('>>if2>>>'+oldOpportunity);
                    setOpportunity.add(newOpportunity);
                }
            }
        }
        
        listOpportunity.addAll(setOpportunity);
        return listOpportunity;
    }
*/
}//End OpportunityTriggerHandler