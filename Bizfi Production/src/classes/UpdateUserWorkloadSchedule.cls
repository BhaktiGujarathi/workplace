global class UpdateUserWorkloadSchedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {

        Set<Id> salesRepsIds = new Set<Id>();

        for (Sales_Rep_Report_Card__c scoreCard : [SELECT Sales_Rep__c FROM Sales_Rep_Report_Card__c]) {

            salesRepsIds.add(scoreCard.Sales_Rep__c);
        }        

        Database.executeBatch(new UpdateUserWorkloadBatch(salesRepsIds), 1);
    }


    public static void start() {

        System.schedule('Agent Workload Recalculation', '0 0 6 * * ?', new UpdateUserWorkloadSchedule());
    }
}