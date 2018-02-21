/* Handler Class to copy contact ownership
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Nachiket R. Deshpande                    11/06/2014                              Initial Draft
 * 1.1             Yogesh Mahajan                           11/25/2015                              service class to update contact from 
                                                                                                    opportunity
 */ 
public with sharing class OpportunityService {

    //constructor
    public OpportunityService() {}
    
    //sort List of Opportunity by date in descending order
    public List<Opportunity> sortByDateOpp(List<Opportunity> pListOpportunity) {
        Opportunity oppInstance = new Opportunity();
        for(integer i = 0; i< pListOpportunity.size(); i++) {
            for(integer j = 1; j< pListOpportunity.size(); j++) {
                if((pListOpportunity[i].LastModifiedDate).Date() <> Null && (pListOpportunity[j].LastModifiedDate).Date() <> Null) {
                    if((pListOpportunity[i].LastModifiedDate).Date() > (pListOpportunity[j].LastModifiedDate).Date()) {
                        oppInstance = pListOpportunity[i];
                        pListOpportunity[i] = pListOpportunity[j];
                        pListOpportunity[j] = oppInstance;
                    }
                }
            }
        }
        return pListOpportunity;
    }
    
    //update Contact when List of Opportunity is inserted
    public void contactUpdate(List<Opportunity> listNewOpportunity) {
        
        //List Opportunity to add sorted list of opportunity
        List<Opportunity> listOpportunity = new List<Opportunity>();
        listOpportunity = sortByDateOpp(listNewOpportunity);
        
        //set to Store Owner1 Id
        Set<Id> setContactId = new Set<Id>();
        
        
        //Iterate Over list of opportunity which is coming from Trigger and add Contact Id into set
        if(listNewOpportunity.size() <> 0) {
            for(Opportunity objOpp :listNewOpportunity) {
                setContactId.add(objOpp.Owner_1__c);
                setContactId.add(objOpp.Owner_2__c);
            }
        }
        
        //List to add Contact to update
        List<Contact> listToUpdateContact1 = new List<Contact>();
        List<Contact> listToUpdateContact2 = new List<Contact>();
        
        if(!setContactId.isEmpty()) {
            
            //Query on Contact to get all contact which is related to List new opprtunity 
            Map<Id, Contact> mapOfContact = new Map<Id, Contact>(
                                                            [SELECT Id
                                                                  , LastName
                                                                  , FirstName
                                                                  , Of_Ownership__c
                                                               FROM Contact 
                                                              WHERE Id IN :setContactId 
            ]);
        
            //Contact to update ownership percent field on contact
            Contact cont1 = new Contact();
            Contact cont2 = new Contact();
            
            //Iterate Over sorted list of opportunity and Update Contact 
            for(Opportunity objOpp:listOpportunity) {
                
                if(mapOfContact.size() > 0) {
                    if(objOpp.Owner_1__c <> null) {
                        cont1 = mapOfContact.get(objOpp.Owner_1__c);
                        cont1.Of_Ownership__c = objOpp.Owner_1_Ownership__c;
                    }
                    if(objOpp.Owner_2__c <> null) {
                        cont2 = mapOfContact.get(objOpp.Owner_2__c);
                        cont2.Of_Ownership__c = objOpp.Owner_2_Ownership__c;
                    }
                    
                    listToUpdateContact1.add(cont1);
                    listToUpdateContact2.add(cont2);
                }
            }
        }
        
        //update list of contact
        try {
            if(!listToUpdateContact1.isEmpty()) 
                update listToUpdateContact1;
                if(!listToUpdateContact2.isEmpty())
                    update listToUpdateContact2;
        } catch (DMLException ex) {
            system.debug('>>>xe.getMessage()' +ex.getMessage());
        }
    }

    /**
     * when opportunity stage changed then populate its date for respective field 
     * and boolean variable to true
     */
    public void trackOpportunityStage(List<Opportunity> opportunities) {
        Map<String, String> stageToDateFieldMap = StatusFieldMapping.OPPORTUNITY_STAGE_DATE_FIELD_MAP;
        Map<String, String> stageToBooleanFieldMap = StatusFieldMapping.OPPORTUNITY_IS_STAGE_FIELD_MAP; 
        for(Opportunity opportunity :opportunities) {
            if(stageToDateFieldMap.containsKey(opportunity.StageName)) {
                opportunity.put(stageToDateFieldMap.get(opportunity.StageName), system.now());
            }
            if(stageToBooleanFieldMap.containsKey(opportunity.StageName)) {
                opportunity.put(stageToBooleanFieldMap.get(opportunity.StageName), true);
            }
        }
    }
}