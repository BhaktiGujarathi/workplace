public without sharing class assignmentEndpoints {
    public static string fetchAssignmentDocs(Booking_Unit__c objUnit, Case objCase, String strProcess){
        String strNocIssued = 'No';
        if(objUnit.NOC_Issued_Date__c != null
        && objUnit.NOC_Issued_Date__c > date.today().addDays(-15)){
            strNocIssued = 'Yes';
        }
        AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint objClass = new AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint();
        objClass.timeout_x = 120000;
        system.debug('objUnit.Registration_ID__c=='+objUnit.Registration_ID__c+'');
        String strDocResponse = objClass.AssignmentDocument(objUnit.Registration_ID__c
                                                            ,''
                                                            ,strProcess
                                                            ,objCase.Buyer_Type__c
                                                            ,objUnit.Inventory__r.Property_City__c
                                                            ,objUnit.Inventory__r.Property__r.Name
                                                            ,objUnit.Inventory__r.Building_Code__c
                                                            ,objUnit.Permitted_Use__c
                                                            ,objUnit.Inventory__r.Bedroom_Type__c
                                                            ,''
                                                            ,objUnit.Unit_Type__c
                                                            ,objCase.Buyer_Type__c
                                                            ,''
                                                            ,''
                                                            ,objUnit.Inventory__r.Property_Status__c
                                                            ,''
                                                            ,objCase.Buyer_POA__c == true? 'Yes' : 'No'
                                                            ,objCase.Seller_POA__c == true? 'Yes' : 'No'
                                                            ,strNocIssued);
        system.debug('strDocResponse*****************'+strDocResponse);
        return strDocResponse;
    }
    
    public static string fetchAssignmentFees(Booking_Unit__c objUnit, Case objCase, String strProcess){
        String strNocIssued = 'No';
        String strPOA = 'No';
        if(objUnit.NOC_Issued_Date__c != null
        && objUnit.NOC_Issued_Date__c > date.today().addDays(-15)){
            strNocIssued = 'Yes';
        }
        AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint objClass = new AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint();
        objClass.timeout_x = 120000;
        system.debug('objUnit****'+objUnit);
        system.debug('objCase****'+objCase);
        system.debug('strPOA****'+strPOA);
        system.debug('strNocIssued****'+strNocIssued);
        String strFeeResponse = objClass.AssignmentFee(objUnit.Registration_ID__c
                                                       ,''
                                                       ,strProcess
                                                       ,objCase.Case_Type__c
                                                       ,objUnit.Inventory__r.Property_City__c
                                                       ,objUnit.Inventory__r.Property__r.Name
                                                       ,objUnit.Inventory__r.Building_Code__c
                                                       ,objUnit.Permitted_Use__c
                                                       ,objUnit.Inventory__r.Bedroom_Type__c
                                                       ,''
                                                       ,objUnit.Unit_Type__c
                                                       ,objCase.Buyer_Type__c
                                                       ,''
                                                       ,''
                                                       ,objUnit.Inventory__r.Property_Status__c
                                                       ,''
                                                       ,strPOA
                                                       ,strNocIssued);
        system.debug('strFeeResponse*****************'+strFeeResponse);
        return strFeeResponse;
    }

    public static string fetchAssignmentApprovers(Booking_Unit__c objUnit, Case objCase, String strProcess){
        AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint objClass = new AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint();
        objClass.timeout_x = 120000;
        String strAppResponse = objClass.AssignmentApproval(objUnit.Registration_ID__c
                                                            ,''
                                                            ,strProcess
                                                            ,objCase.Case_Type__c+'-'+objCase.Relationship_with_Seller__c
                                                            ,objUnit.Inventory__r.Property_City__c
                                                            ,objUnit.Inventory__r.Property__r.Name
                                                            ,objUnit.Inventory__r.Building_Code__c
                                                            ,objUnit.Permitted_Use__c
                                                            ,objUnit.Inventory__r.Bedroom_Type__c
                                                            ,''
                                                            ,objUnit.Unit_Type__c
                                                            ,objCase.Buyer_Type__c
                                                            ,''
                                                            ,''
                                                            ,''
                                                            ,objUnit.Inventory__r.Property_Status__c
                                                            ,''
                                                            ,'');
        system.debug('strAppResponse*****************'+strAppResponse);
        return strAppResponse;
    }
    
    public static string fetchAssignmentDues(Booking_Unit__c objUnit){
        AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint objClass = new AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint();
        objClass.timeout_x = 120000;
        String strDueResponse = objClass.getPendingDues(objUnit.Registration_ID__c,'');
        system.debug('strDueResponse*****************'+strDueResponse);
        return strDueResponse;
    }

    public static string fetchPDCDetails(Booking_Unit__c objUnit){
        AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint objClass = new AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint();
        objClass.timeout_x = 120000;
        String strPDCResponse = objClass.getPDCDetails(String.valueOf(System.currentTimeMillis()), 'GET_PDC_DETAILS', 'SFDC', objUnit.Registration_ID__c);
        system.debug('strPDCResponse*****************'+strPDCResponse);
        return strPDCResponse;
    }

    public static string updateRegStatus(Booking_Unit__c objUnit, String regStatus){
        AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint objClass = new AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint();
        objClass.timeout_x = 120000;
        String strRegStatusResponse = objClass.UpdateRegistrationStatus(String.valueOf(System.currentTimeMillis()), 'UPDATE_REG_STATUS', 'SFDC', objUnit.Registration_ID__c, regStatus);
        system.debug('strPDCResponse*****************'+strRegStatusResponse);
        return strRegStatusResponse;
    }
}