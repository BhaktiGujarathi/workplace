/* Handler Class to copy contact ownership
 *
 * Revision History:
 *
 * Version      Author                  Date                Description
 * 1.0          Nachiket R. Deshpande   11/06/2014          Initial Draft
 * 1.1          Yogesh Mahajan          11/25/2015          service class to update contact from
                                                            opportunity
 * 1.2          Ajinkya H               19/02/2017          update functionality for owner 3 and owner 4
 * 1.3          Mujjammil Khan          29/06/2017          Added setActivityComment method
 */
public with sharing class OpportunityService {

    //constructor
    public OpportunityService() {}

    /**
     * Update owner1 and owner2 percentage from opportunity
     */
    public void ownerUpdateFromOpportunity(List<Opportunity> newOpportunities,
        Map<Id,Opportunity> oldOpportunityMap) {
        Set<Id> setownerId = new Set<Id>();
        for(Opportunity opp :newOpportunities) {
            setownerId.add(opp.Owner_1__c);
            if(!setownerId.contains(opp.Owner_2__c)) {
                setownerId.add(opp.Owner_2__c);
            }
            if(!setownerId.contains(opp.Owner_3__c)) {
                setownerId.add(opp.Owner_3__c);
            }
            if(!setownerId.contains(opp.Owner_4__c)) {
                setownerId.add(opp.Owner_4__c);
            }
        }
        Map<Id, Contact> mapOfContact = new Map<Id, Contact>(
                                                            [SELECT Id
                                                                  , LastName
                                                                  , FirstName
                                                                  , Of_Ownership__c
                                                               FROM Contact
                                                              WHERE Id IN :setownerId
        ]);
        Contact owner1 = new Contact();
        Contact owner2 = new Contact();
        Contact owner3 = new Contact();
        Contact owner4 = new Contact();
        List<Contact> owner1ListToUpdate = new List<Contact>();
        List<Contact> owner2ListToUpdate = new List<Contact>();
        List<Contact> owner3ListToUpdate = new List<Contact>();
        List<Contact> owner4ListToUpdate = new List<Contact>();

        for(Opportunity newOpportunity : newOpportunities) {
            if(oldOpportunityMap!= null && oldOpportunityMap.containsKey(newOpportunity.Id)) {
                Opportunity oldOpportunity = oldOpportunityMap.get(newOpportunity.Id);
                if(newOpportunity.Owner_1__c <> null &&
                    newOpportunity.Owner_1_Ownership__c != oldOpportunity.Owner_1_Ownership__c &&
                    newOpportunity.Owner_1_Ownership__c != mapOfContact.get(newOpportunity.Owner_1__c).Of_Ownership__c) {
                    owner1 = mapOfContact.get(newOpportunity.Owner_1__c);
                    owner1.Of_Ownership__c = newOpportunity.Owner_1_Ownership__c;
                    owner1ListToUpdate.add(owner1);
                }
                if(newOpportunity.Owner_2__c <> null &&
                    newOpportunity.Owner_2_Ownership__c != oldOpportunity.Owner_2_Ownership__c &&
                    newOpportunity.Owner_2_Ownership__c != mapOfContact.get(newOpportunity.Owner_2__c).Of_Ownership__c) {
                    owner2 = mapOfContact.get(newOpportunity.Owner_2__c);
                    owner2.Of_Ownership__c = newOpportunity.Owner_2_Ownership__c;
                    owner2ListToUpdate.add(owner2);
                }
                if(newOpportunity.Owner_3__c <> null &&
                    newOpportunity.Owner_3_Ownership__c != oldOpportunity.Owner_3_Ownership__c &&
                    newOpportunity.Owner_3_Ownership__c != mapOfContact.get(newOpportunity.Owner_3__c).Of_Ownership__c) {
                    owner3 = mapOfContact.get(newOpportunity.Owner_3__c);
                    owner3.Of_Ownership__c = newOpportunity.Owner_3_Ownership__c;
                    owner3ListToUpdate.add(owner3);
                }
                if(newOpportunity.Owner_4__c <> null &&
                    newOpportunity.Owner_4_Ownership__c != oldOpportunity.Owner_4_Ownership__c &&
                    newOpportunity.Owner_4_Ownership__c != mapOfContact.get(newOpportunity.Owner_4__c).Of_Ownership__c) {
                    owner4 = mapOfContact.get(newOpportunity.Owner_4__c);
                    owner4.Of_Ownership__c = newOpportunity.Owner_4_Ownership__c;
                    owner4ListToUpdate.add(owner4);
                }
            }/*else {
                if(newOpportunity.Owner_1__c <> null ) {
                    owner1 = mapOfContact.get(newOpportunity.Owner_1__c);
                    owner1.Of_Ownership__c = newOpportunity.Owner_1_Ownership__c;
                    owner1ListToUpdate.add(owner1);
                }
                if(newOpportunity.Owner_2__c <> null ) {
                    owner2 = mapOfContact.get(newOpportunity.Owner_2__c);
                    owner2.Of_Ownership__c = newOpportunity.Owner_2_Ownership__c;
                    owner2ListToUpdate.add(owner2);
                }
                if(newOpportunity.Owner_3__c <> null ) {
                    owner3 = mapOfContact.get(newOpportunity.Owner_3__c);
                    owner3.Of_Ownership__c = newOpportunity.Owner_3_Ownership__c;
                    owner3ListToUpdate.add(owner3);
                }
                if(newOpportunity.Owner_4__c <> null ) {
                    owner4 = mapOfContact.get(newOpportunity.Owner_4__c);
                    owner4.Of_Ownership__c = newOpportunity.Owner_4_Ownership__c;
                    owner4ListToUpdate.add(owner4);
                }
            }*/
        }
        //update list of contact
        try {
            if(!owner1ListToUpdate.isEmpty()) {
                update owner1ListToUpdate;
            }
            if(!owner2ListToUpdate.isEmpty()) {
                update owner2ListToUpdate;
            }
            if(!owner3ListToUpdate.isEmpty()) {
                update owner3ListToUpdate;
            }
            if(!owner4ListToUpdate.isEmpty()) {
                update owner4ListToUpdate;
            }
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

    /**
     * Update Ownership % fields based on Owner changes
     */
    public static void updateOwnershipPercent(
            List<Opportunity> newOpportunities,
            Map<Id, Opportunity> oldOpportunitiesMap
    ) {
        if(oldOpportunitiesMap == null) {
            updateOwnershipPercentInsert(newOpportunities);
        } else {
            updateOwnershipPercentUpdate(newOpportunities, oldOpportunitiesMap);
        }
    }

    /**
     * Update Ownership percentage on Insert
     */
    private static void updateOwnershipPercentInsert(List<Opportunity> newOpportunities) {
        Set<Id> ownerIds = new Set<Id>();
        for(Opportunity opp : newOpportunities) {
            if(opp.Owner_1__c != null)
                ownerIds.add(opp.Owner_1__c);
            if(opp.Owner_2__c != null)
                ownerIds.add(opp.Owner_2__c);
            if(opp.Owner_3__c != null)
                ownerIds.add(opp.Owner_3__c);
            if(opp.Owner_4__c != null)
                ownerIds.add(opp.Owner_4__c);
        }
        Map<Id, Contact> ownerMap = getOwners(ownerIds);
        for(Opportunity opp : newOpportunities) {
            if(opp.Owner_1__c != null)
                opp.Owner_1_Ownership__c = ownerMap.get(opp.Owner_1__c).Of_Ownership__c;
            if(opp.Owner_2__c != null)
                opp.Owner_2_Ownership__c = ownerMap.get(opp.Owner_2__c).Of_Ownership__c;
            if(opp.Owner_3__c != null)
                opp.Owner_3_Ownership__c = ownerMap.get(opp.Owner_3__c).Of_Ownership__c;
            if(opp.Owner_4__c != null)
                opp.Owner_4_Ownership__c = ownerMap.get(opp.Owner_4__c).Of_Ownership__c;
        }
    }

    /**
     * Update Ownership percentage on update
     */
    private static void updateOwnershipPercentUpdate(
            List<Opportunity> newOpportunities,
            Map<Id, Opportunity> oldOpportunitiesMap
    ) {
        Set<Id> ownerIds = new Set<Id>();
        for(Opportunity opp : newOpportunities) {
            if(opp.Owner_1__c != null)
                ownerIds.add(opp.Owner_1__c);
            if(opp.Owner_2__c != null)
                ownerIds.add(opp.Owner_2__c);
            if(opp.Owner_3__c != null)
                ownerIds.add(opp.Owner_3__c);
            if(opp.Owner_4__c != null)
                ownerIds.add(opp.Owner_4__c);
        }
        Map<Id, Contact> ownerMap = getOwners(ownerIds);
        for(Opportunity opp : newOpportunities) {
            if(opp.Owner_1__c == null) {
                opp.Owner_1_Ownership__c = null;
            } else if(opp.Owner_1__c != oldOpportunitiesMap.get(opp.Id).Owner_1__c) {
                opp.Owner_1_Ownership__c = ownerMap.get(opp.Owner_1__c).Of_Ownership__c;
            }
            if(opp.Owner_2__c == null) {
                opp.Owner_2_Ownership__c = null;
            } else if(opp.Owner_2__c != oldOpportunitiesMap.get(opp.Id).Owner_2__c) {
                opp.Owner_2_Ownership__c = ownerMap.get(opp.Owner_2__c).Of_Ownership__c;
            }
            if(opp.Owner_3__c == null) {
                opp.Owner_3_Ownership__c = null;
            } else if(opp.Owner_3__c != oldOpportunitiesMap.get(opp.Id).Owner_3__c) {
                opp.Owner_3_Ownership__c = ownerMap.get(opp.Owner_3__c).Of_Ownership__c;
            }
            if(opp.Owner_4__c == null) {
                opp.Owner_4_Ownership__c = null;
            } else if(opp.Owner_4__c != oldOpportunitiesMap.get(opp.Id).Owner_4__c) {
                opp.Owner_4_Ownership__c = ownerMap.get(opp.Owner_4__c).Of_Ownership__c;
            }
        }
    }

    private static Map<Id, Contact> getOwners(Set<Id> ownerIds) {
        return new Map<Id, Contact>([SELECT
                                        Id,
                                        Of_Ownership__c
                                    FROM
                                        Contact
                                    WHERE
                                        Id IN :ownerIds
                                    ]);
    }

    public static void setActivityComment(List<Opportunity> opportunities) {
        if(CheckRecursive.runOnceForAfter()) {
            for(Opportunity opp : opportunities) {
                if(String.isNotBlank(opp.Last_Activity_Comments__c) && opp.Last_Activity_Comments__c.length() >= 255) {
                    Integer trimMsgLen = Label.Activity_Comment_trimmed_message.length();
                    //opp.Last_Activity_Comments__c = ;
                    opp.Last_Activity_Comments__c = opp.Last_Activity_Comments__c.left(255 - (trimMsgLen + 1)) + Label.Activity_Comment_trimmed_message;
                }
            }
        }
    }
}