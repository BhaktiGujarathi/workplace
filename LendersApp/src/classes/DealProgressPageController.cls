public with sharing class DealProgressPageController{

    public Double verificationPercent {get;set;}
    public Double stipsPercent {get;set;}
    public Double merchantPercent{get;set;}

    public Opportunity opp {get;set;}

    public Decimal completedCount{get;set;}
    public Decimal totalCount{get;set;}
    public Decimal stipsCompletedCount{get;set;}
    public Decimal stipsTotalCount{get;set;}
    public Decimal verificationTotalCount{get;set;}
    public Decimal verificationCompletedCount{get;set;}



    public DealProgressPageController(ApexPages.StandardController controller) {

        verificationPercent = 0;
        stipsPercent = 0;
        merchantPercent = 0;

        if (controller.getid() != null) {
            
            opp = [SELECT Id, 
                          Verifications_Completed__c, 
                          Verifications_Total__c, 
                          Total_Stip_Count__c, 
                          McaApp__Closed_Stips__c,
                          Interview_Completed_Count__c, 
                          Interview_Total_Count__c 
                     FROM Opportunity 
                    WHERE Id = :controller.getId()]; 

            verificationCompletedCount = opp.Verifications_Completed__c;
            verificationTotalCount = opp.Verifications_Total__c;

            if (verificationCompletedCount == null) {
                verificationCompletedCount = 0;
            }

            if (verificationTotalCount == null) { 
                verificationTotalCount = 0;
            }

            if (opp.Interview_Completed_Count__c == null) {
                opp.Interview_Completed_Count__c = 0;
            }

            if (opp.Interview_Total_Count__c == null) { 
                opp.Interview_Total_Count__c = 0;
            }

            
            if (verificationTotalCount != 0 && verificationTotalCount != null) {

                verificationPercent = ((opp.Verifications_Completed__c * 100) / opp.Verifications_Total__c).round();
            }

            stipsCompletedCount = opp.McaApp__Closed_Stips__c;
            stipsTotalCount = opp.Total_Stip_Count__c;

            if (stipsTotalCount != 0 && stipsTotalCount != null) {

                stipsPercent = ((opp.McaApp__Closed_Stips__c * 100) / opp.Total_Stip_Count__c).round();
            }

            completedCount = opp.Interview_Completed_Count__c;
            totalCount = opp.Interview_Total_Count__c;

            if (totalCount != 0 && totalCount != null) {

                merchantPercent = ((opp.Interview_Completed_Count__c * 100) / opp.Interview_Total_Count__c).round();
            }
        }
    }


    public String getVerificationPercentText() {

        return String.valueOf(verificationPercent.intValue());
    }


    public String getStipsPercentText() {

        return String.valueOf(stipsPercent.intValue());
    }


    public String getMerchantPercentText() {

        return String.valueOf(merchantPercent.intValue());
    }
}