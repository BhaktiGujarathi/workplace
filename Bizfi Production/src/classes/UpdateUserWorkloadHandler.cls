public with sharing class UpdateUserWorkloadHandler {
    

    public static void updateLeadCount(Sales_Rep_Report_Card__c salesRep) {

        Lead[] leads = getLeads(salesRep);

        salesRep.Lead_Count__c = leads.size();
    }


    public static void updateOpportunityCount(Sales_Rep_Report_Card__c salesRep) {

        Opportunity[] opportunities = getOpportunities(salesRep);
        Map<String, AWDynamicCategories__c> dynamicCategories = getDynamicCategories();


        for (AWDynamicCategories__c dynamicCategory : dynamicCategories.values()) {

            salesRep.put(dynamicCategory.Count__c, 0);
        }

        for (Opportunity opportunity : opportunities) {

            if (dynamicCategories.containsKey(opportunity.StageName)) {

                AWDynamicCategories__c dynamicCategory = dynamicCategories.get(opportunity.StageName);

                salesRep.put(dynamicCategory.Count__c, Integer.valueOf(salesRep.get(dynamicCategory.Count__c)) + 1);
            }     
        }
    }


    private static Map<String, AWDynamicCategories__c> getDynamicCategories() {

        Map<String, AWDynamicCategories__c> dynamicCategories = AWDynamicCategories__c.getAll();

        return dynamicCategories;
    }


    private static Lead[] getLeads(Sales_Rep_Report_Card__c salesRep) {        

        Lead[] leads = new Lead[]{};

        for (Lead lead : [SELECT Id FROM Lead WHERE OwnerId = :salesRep.Sales_Rep__c AND Counts_Against_Pipeline__c = true]) {

            leads.add(lead);
        }

        return leads;
    }


    private static Opportunity[] getOpportunities(Sales_Rep_Report_Card__c salesRep) {

        Opportunity[] opportunities = new Opportunity[]{};
        Set<String> stageNames = getDynamicCategories().keySet();

        for (Opportunity opportunity : [SELECT StageName FROM Opportunity WHERE OwnerId =: salesRep.Sales_Rep__c AND StageName IN :stageNames]) {

            opportunities.add(opportunity);
        }

        return opportunities;
    }


    private static Sales_Rep_Report_Card__c[] getUserReportCards(Sales_Rep_Report_Card__c salesRep) {

        String salesRepId = salesRep.Id;
        String query = 'SELECT Id';

        for (Schema.SObjectField fld: Schema.SObjectType.Sales_Rep_Report_Card__c.fields.getMap().values()) {

            if (fld.getDescribe().getName() != 'Id') {
                
                query += ',' + fld.getDescribe().getName();
            }
        }

        query += ' FROM Sales_Rep_Report_Card__c WHERE Id = :salesRepId';

        Sales_Rep_Report_Card__c[] userReportCards = new Sales_Rep_Report_Card__c[]{};

        for (Sales_Rep_Report_Card__c userReportCard : (Sales_Rep_Report_Card__c[]) Database.query(query)) {
            userReportCards.add(userReportCard);
        }

        return userReportCards;
    }

}