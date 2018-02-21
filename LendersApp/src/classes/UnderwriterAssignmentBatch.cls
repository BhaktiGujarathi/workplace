global class UnderwriterAssignmentBatch implements Database.Batchable <sObject>, Database.AllowsCallouts {

    private Set<Id> opportunitiesIds;


    public UnderwriterAssignmentBatch(Opportunity[] opportunities) {

        opportunitiesIds = new Set<Id>();

        for (Opportunity opportunity : opportunities) {

            opportunitiesIds.add(opportunity.Id);
        }
    }



    //This method will return all the payment records which need to be tracked.
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query;

        if (!opportunitiesIds.isEmpty()) {

            query = 'SELECT Id FROM Opportunity WHERE Id IN :opportunitiesIds AND Reassign_Underwriter__c = TRUE'; 
        }
        else {
            
            query = 'SELECT Id FROM Opportunity WHERE Reassign_Underwriter__c = TRUE'; 
        }
                
        return Database.getQueryLocator(query);
    }

    
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunities) {
        
        UnderwriterAssignmentHandler assignmentHandler = new UnderwriterAssignmentHandler(opportunities[0]);
        assignmentHandler.assign();
    }


    global void finish(Database.BatchableContext BC) {}
}