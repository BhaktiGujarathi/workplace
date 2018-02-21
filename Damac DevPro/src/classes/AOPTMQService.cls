public with sharing class AOPTMQService 
{
    // method to make callout to fetch the master milestone events for payment terms
    public static MileStoneEventsWrapper.MileStoneEvents getMasterMilestone(String strRegID)
    {
        AOPTMQClass.AOPTHttpSoap11Endpoint objHttpsoap = new AOPTMQClass.AOPTHttpSoap11Endpoint();
        String strResponse = objHttpsoap.getMasterMilestone(strRegID);
        system.debug('strResponse '+strResponse);
        MileStoneEventsWrapper.MileStoneEvents objMileStoneEvents = MileStoneEventsWrapper.parse(strResponse);
        system.debug('objMileStoneEvents '+objMileStoneEvents);
        return objMileStoneEvents;
    }

    // method to make callout to fetch the milestone payment details from MQ
    public static MileStonePaymentDetailsWrapper.MileStonePaymentDetails getMilestonePaymentDetails(String strRegID)
    {
        AOPTMQClass.AOPTHttpSoap11Endpoint objHttpsoap = new AOPTMQClass.AOPTHttpSoap11Endpoint();
        String strResponse = objHttpsoap.getMilestonePaymentDetails(strRegID);
        system.debug('strResponse '+strResponse);
        MileStonePaymentDetailsWrapper.MileStonePaymentDetails objMileStonePaymentDetails 
                                      = MileStonePaymentDetailsWrapper.parse(strResponse);
        system.debug('objMileStoneEvents '+objMileStonePaymentDetails);
        return objMileStonePaymentDetails;
    }
    
    // Method to call rule engine to check AOPT eligibility and fetch approving authorities
    public static AOPTRuleResponse checkAOPTEligibility(String strRegId, String strSubProcessName, String strProjectCity, 
        String strProject, String strBuildingCode, String strBedroomType, String strUnitType, String strPermittedUse, 
        String strEHOFlag, String strHOFlag, String strNationality, String strPortfolioValue, String strProposedPaymentPlanType,
        String strPerCompletionInstallmentInProposedPlan, String strDiffCurAcdAndLastNonCompletionInstallmentInProposedPlan,
        String strMaximumMovementInAnInstallmentDays, String strNumberOfInstallmentsMoved, String strPriorAopt, 
        String strPaymentsEquallyDistributed, String strPaymentPlanExtendedBeyondAcd, String strOriginalPaymentPlanType) {
            
        AOPTRule.AOPTRuleHttpSoap11Endpoint objReq = new AOPTRule.AOPTRuleHttpSoap11Endpoint();
        objReq.timeout_x = 120000;
        
        try {
            String strResponse = objReq.AoptDetails(strRegId, strSubProcessName, strProjectCity, strProject, strBuildingCode, 
                strBedroomType, strUnitType, strPermittedUse, strEHOFlag, strHOFlag, strNationality, strPortfolioValue, 
                strProposedPaymentPlanType, strPerCompletionInstallmentInProposedPlan, strDiffCurAcdAndLastNonCompletionInstallmentInProposedPlan, 
                strMaximumMovementInAnInstallmentDays, strNumberOfInstallmentsMoved, strPriorAopt, strPaymentsEquallyDistributed, 
                strPaymentPlanExtendedBeyondAcd, strOriginalPaymentPlanType, '', '', '', '', '', '', '', '');
                
            if(String.isNotBlank(strResponse)) {
                Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(strResponse);
                if(mapResponse.get('allowed') != null) {
                    String strAllowed = (String)mapResponse.get('allowed');
                    if(String.isNotBlank(strAllowed) && strAllowed.equalsIgnoreCase('Yes') &&
                       mapResponse.get('approvingAuthorityOne') != null) {
                        String strAppAuth = (String)mapResponse.get('approvingAuthorityOne');
                        String strAppAuth2 = (String)mapResponse.get('approvingAuthorityTwo');
                        String strAppAuth3 = (String)mapResponse.get('approvingAuthorityThree');
                        
                        if(String.isNotBlank(strAppAuth2)) {
                            strAppAuth += ',' + strAppAuth2;
                        }
                        
                        if(String.isNotBlank(strAppAuth3)) {
                            strAppAuth += ',' + strAppAuth3;
                        }
                        return new AOPTRuleResponse(strAllowed, null, strAppAuth);
                    }
                    else if(String.isNotBlank(strAllowed) && strAllowed.equalsIgnoreCase('No')) {
                        String strMessage = (String)mapResponse.get('message');
                        return new AOPTRuleResponse('No', strMessage, null);
                    }
                    else {
                        return new AOPTRuleResponse('Error', null, null);
                    }
                }
            }
            else {
                return new AOPTRuleResponse('Error', null, null);
            }
        }
        catch(Exception excGen) {
            return new AOPTRuleResponse('Error', null, null);
        }
        return null;
    }

    public static String createPaymentPlanIPMS(String strRegID,String strCaseNumber,String strSRType,paymentPlanCreationXxdcAoptPkgWsP.APPSXXDC_AOPT_PKG_WSX1843128X6X5 [] lstPaymentTermInIPMS)
    { 
      AOPTMQClass.AOPTHttpSoap11Endpoint objReq = new AOPTMQClass.AOPTHttpSoap11Endpoint();
      objReq.timeout_x = 120000;
      
      AOPTMQClass.AOPTHttpSoap11Endpoint objHttpsoap = new AOPTMQClass.AOPTHttpSoap11Endpoint();
      String strResponse = objHttpsoap.PaymentPlanCreation(strRegID,strCaseNumber,strSRType,lstPaymentTermInIPMS);
      return strResponse;
    }

    //method to generate the offer and acceptance letter for booking units
    public static String generateOfferAccetanceLetter(AOPTDocumentGenerationXsd.DocGenDTO objDocGenDTO)
    {
      AOPTDocumentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint objGenerateLetter = new AOPTDocumentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint();
      objGenerateLetter.timeout_x = 120000;
      String strResponse = objGenerateLetter.DocGeneration( 'AOPT_Payment_Plan_Addendum' , objDocGenDTO );
      return strResponse;
    }
    
    public Class AOPTRuleResponse {
        public String strAllowed;
        public String strMessage;
        public String strApprovingAuthority;
        
        public AOPTRuleResponse(String strAllowed, String strMessage, String strApprovingAuthority) {
            this.strAllowed = strAllowed;
            this.strMessage = strMessage;
            this.strApprovingAuthority = strApprovingAuthority;
        }
    }
}