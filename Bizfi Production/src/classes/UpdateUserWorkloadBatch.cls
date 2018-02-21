global class UpdateUserWorkloadBatch implements Database.Batchable<sObject> {
    
    private Set<Id> salesRepsIds;


    global UpdateUserWorkloadBatch(Set<Id> userIds) {

        salesRepsIds = userIds;        
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT Sales_Rep__c FROM Sales_Rep_Report_Card__c WHERE Sales_Rep__c = :salesRepsIds';

        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, List<Sales_Rep_Report_Card__c> salesReps) {

        calculateScorecards(salesReps[0]);
    }

    
    global void finish(Database.BatchableContext BC) { }    


    public static void calculateScorecards(Sales_Rep_Report_Card__c salesRep) {

        UpdateUserWorkloadHandler.updateOpportunityCount(salesRep);

        UpdateUserWorkloadHandler.updateLeadCount(salesRep);

        update salesRep;        
    }


    @future
    public static void calculateScorecardsFuture(Set<Id> userIds) {

        Sales_Rep_Report_Card__c[] salesReps = [SELECT Sales_Rep__c FROM Sales_Rep_Report_Card__c WHERE Sales_Rep__c = :userIds];

        if (!salesReps.isEmpty()) {

            calculateScorecards(salesReps[0]);
        }
    }


    public static void start(Set<Id> userIds) {

        if (userIds.size() > 1) {

            Database.executeBatch(new UpdateUserWorkloadBatch(userIds), 1);
        }
        else {

            calculateScorecardsFuture(userIds);
        }
    }
}