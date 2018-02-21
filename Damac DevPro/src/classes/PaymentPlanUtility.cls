public with sharing class PaymentPlanUtility {
    
    //Method to compute and return the payment plan type
    public static String getPaymentPlanType(List<Payment_Terms__c> lstTerms) {
        Integer intNumberOfStructurePPType = 0;
        Integer intNumberOfCompletionPPType = 0;
        String paymentPlanType = 'Date Based Payment Plan';
        
        List<String> lstStructureKeywords = new List<String>{'Floor', 'Structure', 'Foundation', 'Basement',
            'Podium', 'Level', 'Works', 'Piling', 'Excavation', 'Shoring'};
            
        List<String> lstCompletionKeywords = new List<String>{'Project completion', 'Building completion',
            'Villa completion'};
        
        for(Payment_Terms__c objPT: lstTerms) {
            if(String.isNotBlank(objPT.Milestone_Event__c)) {
                for(String strStructureKW: lstStructureKeywords) {
                    system.debug('strStructureKW '+strStructureKW);
                    system.debug('objPT.Milestone_Event__c '+objPT.Milestone_Event__c);
                    if(objPT.Milestone_Event__c.containsIgnoreCase(strStructureKW)) {
                        intNumberOfStructurePPType += 1;
                    }
                }
                
                for(String strCompletionKW: lstCompletionKeywords) {
                    if(objPT.Milestone_Event__c.containsIgnoreCase(strCompletionKW)) {
                        intNumberOfCompletionPPType += 1;
                    }
                }
            }
        }
        system.debug('intNumberOfStructurePPType '+intNumberOfStructurePPType);
        system.debug('intNumberOfCompletionPPType '+intNumberOfCompletionPPType);
        if(intNumberOfStructurePPType >= 3) {
            paymentPlanType = 'Structure Based Payment Plan';
        }
        
        if(intNumberOfCompletionPPType >= 3) {
            paymentPlanType = 'Completion Based payment Plan';
        }
        
        return paymentPlanType;
    }


    //Method to compute and return the payment plan type
    public static String getPaymentPlanTypeFromWrapper(List<AOPTServiceRequestControllerLDS.NewPaymentTermsWrapper> lstTermsWrapper) 
    {
        Integer intNumberOfStructurePPType = 0;
        Integer intNumberOfCompletionPPType = 0;
        String paymentPlanType = 'Date Based Payment Plan';
        
        List<String> lstStructureKeywords = new List<String>{'Floor', 'Structure', 'Foundation', 'Basement',
            'Podium', 'Level', 'Works', 'Piling', 'Excavation', 'Shoring'};
            
        List<String> lstCompletionKeywords = new List<String>{'Project completion', 'Building completion',
            'Villa completion'};
        
        for(AOPTServiceRequestControllerLDS.NewPaymentTermsWrapper objPT: lstTermsWrapper) {
            if(String.isNotBlank(objPT.strMileStoneEvent)) {
                for(String strStructureKW: lstStructureKeywords) {
                    system.debug('strStructureKW '+strStructureKW);
                    system.debug('objPT.strMileStoneEvent '+objPT.strMileStoneEvent);
                    if(objPT.strMileStoneEvent.containsIgnoreCase(strStructureKW)) {
                        intNumberOfStructurePPType += 1;
                    }
                }
                
                for(String strCompletionKW: lstCompletionKeywords) {
                    if(objPT.strMileStoneEvent.containsIgnoreCase(strCompletionKW)) {
                        intNumberOfCompletionPPType += 1;
                    }
                }
            }
        }
        system.debug('intNumberOfStructurePPType '+intNumberOfStructurePPType);
        system.debug('intNumberOfCompletionPPType '+intNumberOfCompletionPPType);
        if(intNumberOfStructurePPType >= 3) {
            paymentPlanType = 'Structure Based Payment Plan';
        }
        
        if(intNumberOfCompletionPPType >= 3) {
            paymentPlanType = 'Completion Based payment Plan';
        }
        
        return paymentPlanType;
    }
}