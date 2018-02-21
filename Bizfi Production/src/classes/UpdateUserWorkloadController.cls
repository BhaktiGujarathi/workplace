public with sharing class UpdateUserWorkloadController {

    
    public UpdateUserWorkloadController() { }

    
    public PageReference updateUserWorkload() {

        String reportCardId = ApexPages.currentPage().getParameters().get('id');

        for (Sales_Rep_Report_Card__c reportCard : [SELECT Sales_Rep__c
                                                      FROM Sales_Rep_Report_Card__c 
                                                     WHERE Id = :reportCardId]) {

            if (reportCard.Sales_Rep__c != null) {
                
                UpdateUserWorkloadBatch.start(new Set<Id> { reportCard.Sales_Rep__c });    
            }
        }

        return new PageReference('/' + reportCardId);
    }
}