public with sharing class OpportunityRollUpHandler {
    
    UWVerification__c[] verificationList = new UWVerification__c[] {};
    MerchantInterviewQuestion__c[] questionList = new MerchantInterviewQuestion__c[] {};
    UWVerification__c[] allVerifications= new UWVerification__c[] {};
    MerchantInterviewQuestion__c[] allQuestions = new MerchantInterviewQuestion__c[] {};
    Set<Id> oppIds = new Set<Id>();
    Opportunity[] opps = new Opportunity[]{};
    Opportunity[] oppsToUpdate = new Opportunity[]{};


   
    public OpportunityRollUpHandler(List<SObject> newassets) {
        

        if (newassets[0].getSObjectType() == Schema.UWVerification__c.getSObjectType()) {

            verificationList = (List<UWVerification__c>)newassets;
        }
        else if (newassets[0].getSObjectType() == Schema.MerchantInterviewQuestion__c.getSObjectType()) {

            questionList = (List<MerchantInterviewQuestion__c>)newassets;
        }


        updateValues();

    }

  
    public void updateValues() {

        if ( !verificationList.isEmpty() ) {

            for ( UWVerification__c auxVerification : verificationList ) {

                oppIds.add(auxVerification.Opportunity__c);
            }
        }

        else if (!questionList.isEmpty()) {

            for ( MerchantInterviewQuestion__c auxQuestion : questionList ) {

                oppIds.add(auxQuestion.Opportunity__c);
            }   
        }


        opps = [SELECT Id FROM Opportunity WHERE Id IN :oppIds];

        allVerifications = [SELECT Id, Completed__c, Stage__c, Opportunity__c FROM UWVerification__c WHERE Opportunity__c = :oppIds];
        allQuestions = [SELECT Id, Completed__c, Verification__c, Opportunity__c FROM MerchantInterviewQuestion__c WHERE Opportunity__c = :oppIds];


        for ( Opportunity opp : opps ) {

            opp.Interview_Completed_Count__c = countMerchantCompleted(opp);
            opp.Interview_Total_Count__c = countMerchantTotal(opp);
            opp.Verifications_Completed__c = countVerificationCompleted(opp);
            opp.Verifications_Total__c = countVerificationTotal(opp);

            oppsToUpdate.add(opp);

        }

        update oppsToUpdate;
    }


    public Integer countMerchantCompleted(Opportunity opp) {

        Integer result = 0;

        for ( MerchantInterviewQuestion__c question : allQuestions) {

            if ( question.Opportunity__c == opp.Id && question.Completed__c ) {
            
                result++;
            }
        }

        return result;
    }


    public Integer countMerchantTotal(Opportunity opp) {

        Integer result = 0;

        for ( MerchantInterviewQuestion__c question : allQuestions) {
            
            if (question.Opportunity__c == opp.Id ) {
                
                result++;    
            }
        }

        return result;
    }

    public Integer countVerificationPrequalificationCompleted(Opportunity opp) {

        Integer result = 0;

        for ( UWVerification__c verification : allVerifications) {
            
            if ( verification.Opportunity__c == opp.Id && verification.Stage__c == 'PreQualification' && verification.Completed__c ) {

                result++;
            }
        }

        return result;
    }

    public Integer countVerificationPrequalificationTotal(Opportunity opp) {

        Integer result = 0;

        for ( UWVerification__c verification : allVerifications) {
            
            if ( verification.Opportunity__c == opp.Id && verification.Stage__c == 'PreQualification' ) {

                result++;
            }
        }

        return result;
    }

    public Integer countVerificationCompleted(Opportunity opp) {

        Integer result = 0;

        for ( UWVerification__c verification : allVerifications) {
            
            if ( verification.Opportunity__c == opp.Id && verification.Completed__c ) {

                result++;
            }
        }

        return result;
    }

    public Integer countVerificationTotal(Opportunity opp) {

        Integer result = 0;

        for ( UWVerification__c verification : allVerifications) {
            
            if ( verification.Opportunity__c == opp.Id ) {
                
                result++;
            }
        }

        return result;
    }

}