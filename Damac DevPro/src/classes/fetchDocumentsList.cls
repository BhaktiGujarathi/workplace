public without sharing class fetchDocumentsList {
    public static void fetchAssignmentDocs(Booking_Unit__c objUnit, Case objCase, Buyer__c objBuyer, String strProcess){
        String strNocIssued = 'No';
        if(objUnit.NOC_Issued_Date__c != null
        && objUnit.NOC_Issued_Date__c > date.today().addDays(-15)){
            strNocIssued = 'Yes';
        }
        assignmentComm.AssignmentHttpSoap11Endpoint objClass = new assignmentComm.AssignmentHttpSoap11Endpoint();
		objClass.timeout_x = 120000;
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
                                                            ,objBuyer.Nationality__c
		                                                    ,objCase.Buyer_POA__c == true? 'Yes' : 'No'
		                                                    ,objCase.Seller_POA__c == true? 'Yes' : 'No'
		                                                    ,strNocIssued);
        system.debug('strDocResponse*****************'+strDocResponse);
    }
    
    public static void fetchAssignmentFees(Booking_Unit__c objUnit, Case objCase, Buyer__c objBuyer, String strProcess){
        String strNocIssued = 'No';
        String strPOA = 'No';
        if(objUnit.NOC_Issued_Date__c != null
        && objUnit.NOC_Issued_Date__c > date.today().addDays(-15)){
            strNocIssued = 'Yes';
        }
        assignmentComm.AssignmentHttpSoap11Endpoint objClass = new assignmentComm.AssignmentHttpSoap11Endpoint();
        objClass.timeout_x = 120000;
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
                                                       ,objBuyer.Nationality__c
                                                       ,strPOA
                                                       ,strNocIssued);
        system.debug('strFeeResponse*****************'+strFeeResponse);
    }
    
    public static void fetchAssignmentApprovers(){
        assignmentComm.AssignmentHttpSoap11Endpoint objClass = new assignmentComm.AssignmentHttpSoap11Endpoint();
        objClass.timeout_x = 120000;
        String strAppResponse = objClass.AssignmentApproval('33','','Assignment','','Dubai','Aster','','','','','','Individual','','','','Ready','','');
        system.debug('strAppResponse*****************'+strAppResponse);
    }
    
    public static void fetchAssignmentDues(Booking_Unit__c objUnit){
        assignmentComm.AssignmentHttpSoap11Endpoint objClass = new assignmentComm.AssignmentHttpSoap11Endpoint();
        objClass.timeout_x = 120000;
        String strDueResponse = objClass.getPendingDues(objUnit.Registration_ID__c,'');
        system.debug('strDueResponse*****************'+strDueResponse);
    }
}