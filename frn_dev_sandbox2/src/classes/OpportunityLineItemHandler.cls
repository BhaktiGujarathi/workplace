/**
 * Class OpportunityLineItemHandler
 *
 * Trigger Handler for the Contact SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class OpportunityLineItemHandler implements TriggerInterface {
    
    Map<String,List<OpportunityLineItem>> oppOLIListMap ;
    List<OpportunityLineItem> duplicateOLIs;
    
    // Constructor
    public OpportunityLineItemHandler(){
        System.debug('OpportunityLineItemHandler Constructor');
        oppOLIListMap = new Map<String,List<OpportunityLineItem>>();
        duplicateOLIs = new List<OpportunityLineItem>();
    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){        
        
    }
 
    public void bulkAfter(){
        System.debug('OpportunityLineItemHandler bulkAfter');
        Set<Id> oppIds = new Set<Id>();
        
        for(OpportunityLineItem oli:(List<OpportunityLineItem>)trigger.new){        
            oppIds.add(oli.OpportunityId);                              
        }
        
        List<OpportunityLineItem> oliListTemp;
        for(OpportunityLineItem oli : [SELECT Id,OpportunityId,PricebookEntryId,Product2Id from OpportunityLineItem where OpportunityId IN: oppIds AND Id NOT IN : trigger.newMap.keySet()]){
            if(oppOLIListMap.containsKey(oli.OpportunityId)){
                oppOLIListMap.get(oli.OpportunityId).add(oli);
            } else {
                oliListTemp = new List<OpportunityLineItem>();
                oliListTemp.add(oli);
                oppOLIListMap.put(oli.OpportunityId,oliListTemp);
            }           
        }
    }
 
    public void beforeInsert(SObject so){        
       
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
                   
    }
 
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so){
       
    }
 
    public void afterInsert(SObject so){ 
        System.debug('OpportunityLineItemHandler afterInsert');
        OpportunityLineItem newOLI = (OpportunityLineItem)so;
        if(oppOLIListMap.containsKey(newOLI.OpportunityId)){
            for(OpportunityLineItem oli:oppOLIListMap.get(newOLI.OpportunityId)){
                //Check for the OLIs whose Opportunity, PriceBookEntry and Product are same
                if(oli.PricebookEntryId==newOLI.PricebookEntryId && oli.Product2Id==newOLI.Product2Id){
                    duplicateOLIs.add(oli);
                }
            }
        }
    }
 
    public void afterUpdate(SObject oldSo, SObject so){ 
        
    }

    public void afterDelete(SObject so){
        
    }
 
    public void afterUndelete(SObject so){
        
    }
 
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally(){                        
        //Delete the duplicate OLIs
        if(duplicateOLIs.size()>0){
            delete duplicateOLIs;
        }
    }
}