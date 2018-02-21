/* Class used for performing callouts related to Refunds process
 */
public with sharing class RefundsService {
    
    //Method to perform callout to fetch token amount
    public static RefundResponse getTokenRefund(String strRegId) {
        Refunds.CustomerFundAndTokenHttpSoap11Endpoint objReq = new Refunds.CustomerFundAndTokenHttpSoap11Endpoint();
        objReq.timeout_x = 120000;
        
        try {
            String strResponse = objReq.getTokenRefunds(strRegId, 'TOKEN_REF_AMOUNTS', 'SFDC', strRegId);
            if(String.isNotBlank(strResponse)) {
                Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(strResponse);
                if(mapResponse.get('Status') != null) {
                    String strStatus = (String)mapResponse.get('Status');
                    if(String.isNotBlank(strStatus) && strStatus.equalsIgnoreCase('S') &&
                       mapResponse.get('Amount_Paid') != null) {
                        System.debug('--mapResponse--'+mapResponse.get('Amount_Paid'));
                        //Decimal.valueOf(String.valueOf(mapResponse.get('Excess_Amount')));
                        Decimal decAmount = Decimal.valueOf((String)mapResponse.get('Amount_Paid'));
                        return new RefundResponse('Success', decAmount);
                    }
                    else {
                        return new RefundResponse('Error', null);
                    }
                }
            }
            else {
                return new RefundResponse('Error', null);
            }
        }
        catch(Exception excGen) {
            return new RefundResponse('Error', null);
        }
        return null;
    }
    
    //Method to perform callout to fetch excess amount
    public static RefundResponse getExcessAmount(String strRegId) {
        Refunds.CustomerFundAndTokenHttpSoap11Endpoint objReq = new Refunds.CustomerFundAndTokenHttpSoap11Endpoint();
        objReq.timeout_x = 120000;
        
        try {
            String strResponse = objReq.getExcessAmount(strRegId, 'GET_EXCESS_AMOUNT', 'SFDC', strRegId);
            if(String.isNotBlank(strResponse)) {
                Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(strResponse);
                if(mapResponse.get('Status') != null) {
                    String strStatus = (String)mapResponse.get('Status');
                    if(String.isNotBlank(strStatus) && strStatus.equalsIgnoreCase('S') &&
                       mapResponse.get('Excess_Amount') != null) {
                        Decimal decAmount = Decimal.valueOf((String)mapResponse.get('Excess_Amount'));
                        //Decimal decAmount = Decimal.valueOf(String.valueOf(mapResponse.get('Excess_Amount')));
                        return new RefundResponse('Success', decAmount);
                    }
                    else {
                        return new RefundResponse('Error', null);
                    }
                }
            }
            else {
                return new RefundResponse('Error', null);
            }
        }
        catch(Exception excGen) {
            return new RefundResponse('Error', null);
        }
        return null;
    }
    
    //Method to perform callout to rule engine and fetch approving authorities 
    public static RefundRuleResponse getApprovingAuthorities(String strRegId, String strProcessName, String strSubProcessName,
        String strProjectCity, String strProject, String strBuildingCode, String strBedroomType, String strUnitType,
        String strPermittedUse, String strUnits, String strReadyOffPlan, String strEHOFlag, String strHOFlag, String strNationality,
        String strCustClassification, String strPortfolioValue, String strRefundValue) {
        
        RefundsRule.TokenRefundsTransfersRuleHttpSoap11Endpoint objReq = new RefundsRule.TokenRefundsTransfersRuleHttpSoap11Endpoint();
        objReq.timeout_x = 120000;
        
        try {
            String strResponse = objReq.TokenRefundsTransfers(strRegId, strProcessName, strSubProcessName, strProjectCity,
                strProject, strBuildingCode, strBedroomType, strUnitType, strPermittedUse, strUnits, strReadyOffPlan, strEHOFlag, 
                strHOFlag, strNationality, strCustClassification, strPortfolioValue, strRefundValue, '', '', '', '', '', '', '', '');
                
            if(String.isNotBlank(strResponse)) {
                Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(strResponse);
                if(mapResponse.get('allowed') != null) {
                    String strAllowed = (String)mapResponse.get('allowed');
                    if(String.isNotBlank(strAllowed) && strAllowed.equalsIgnoreCase('Yes') &&
                       mapResponse.get('recommendingAuthorityOne') != null) {
                        String strAppAuth = (String)mapResponse.get('recommendingAuthorityOne');
                        
                        strAppAuth = RoleUtility.getSalesforceRole(strAppAuth);
                        
                        String strRecAuth2 = (String)mapResponse.get('recommendingAuthorityTwo');
                        String strRecAuth3 = (String)mapResponse.get('recommendingAuthorityThree');
                        String strRecAuth4 = (String)mapResponse.get('recommendingAuthorityFour');
                        String strAppAuth1 = (String)mapResponse.get('approvingAuthorityOne');
                        String strAppAuth2 = (String)mapResponse.get('approvingAuthorityTwo');
                        String strAppAuth3 = (String)mapResponse.get('approvingAuthorityThree');
                        
                        if(String.isNotBlank(strRecAuth2)) {
                            strRecAuth2 = RoleUtility.getSalesforceRole(strRecAuth2);
                            strAppAuth += ',' + strRecAuth2;
                        }
                        
                        if(String.isNotBlank(strRecAuth3)) {
                            strRecAuth3 = RoleUtility.getSalesforceRole(strRecAuth3);
                            strAppAuth += ',' + strRecAuth3;
                        }
                        
                        if(String.isNotBlank(strRecAuth4)) {
                            strRecAuth4 = RoleUtility.getSalesforceRole(strRecAuth4);
                            strAppAuth += ',' + strRecAuth4;
                        }
                        if(String.isNotBlank(strAppAuth1)) {
                            strAppAuth1 = RoleUtility.getSalesforceRole(strAppAuth1);
                            strAppAuth += ',' + strAppAuth1;
                        }
                        
                        if(String.isNotBlank(strAppAuth2)) {
                            strAppAuth2 = RoleUtility.getSalesforceRole(strAppAuth2);
                            strAppAuth += ',' + strAppAuth2;
                        }
                        
                        if(String.isNotBlank(strAppAuth3)) {
                            strAppAuth3 = RoleUtility.getSalesforceRole(strAppAuth3);
                            strAppAuth += ',' + strAppAuth3;
                        }
                        return new RefundRuleResponse(strAllowed, null, strAppAuth);
                    }
                    else if(String.isNotBlank(strAllowed) && strAllowed.equalsIgnoreCase('No')) {
                        String strMessage = (String)mapResponse.get('message');
                        return new RefundRuleResponse('No', strMessage, null);
                    }
                    else {
                        return new RefundRuleResponse('Error', null, null);
                    }
                }
            }
            else {
                return new RefundRuleResponse('Error', null, null);
            }
        }
        catch(Exception excGen) {
            return new RefundRuleResponse('Error', null, null);
        }
        return null;
    }
    
    public Class RefundResponse {
        public String strStatus;
        public Decimal decAmount;
        
        public RefundResponse(String strStatus, Decimal decAmount) {
            this.strStatus = strStatus;
            this.decAmount = decAmount;
        }
    }
    
    public Class RefundRuleResponse {
        public String strAllowed;
        public String strMessage;
        public String strApprovingAuthority;
        
        public RefundRuleResponse(String strAllowed, String strMessage, String strApprovingAuthority) {
            this.strAllowed = strAllowed;
            this.strMessage = strMessage;
            this.strApprovingAuthority = strApprovingAuthority;
        }
    }
}