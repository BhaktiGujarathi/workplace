/**
* @author Bhakti Gujarathi
* @date 24-Apr-2016
*
* @description This class is developed to validate null values for the fields specified in the fieldset 
* named 'FieldsToValidate' of Opportunity.
* 
* 
*/

global with sharing class OpportunityFieldValidationService {
    
    public static Opportunity opportunityObj;
    
    public OpportunityFieldValidationService() {
        opportunityObj = new Opportunity();
    }
    
    // method to validate the fields of Opportunity validated.
    WebService static String validateForNullValue(Id pOpportunityId) {
        String queryStr = 'SELECT Id';
        String nullFieldsList = '';
        ID outpatientRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Outpatient Treatment').getRecordTypeId(); 
        List<Schema.FieldSetMember> fieldSetMemberList = SObjectType.Opportunity.FieldSets.FieldsToValidate.getFields();
        for(Schema.FieldSetMember fieldInstance : fieldSetMemberList) {
            queryStr += ','+fieldInstance.getFieldPath();
        }
        queryStr += ' FROM Opportunity WHERE Id =\''+pOpportunityId+ '\' LIMIT 1';
        opportunityObj = database.query(queryStr);
        for(Schema.FieldSetMember fieldInstance : fieldSetMemberList) {
            if(!String.valueOf(fieldInstance.getFieldPath()).contains('__r.') && 
                (opportunityObj.get(fieldInstance.getFieldPath()) == null 
                || opportunityObj.get(fieldInstance.getFieldPath()) == '')
              ) {
                    if(opportunityObj.get('RecordTypeId') == outpatientRecordTypeId && fieldInstance.getFieldPath() != 'Readmit__c') {
                        nullFieldsList += fieldInstance.getLabel() +'\n';
                    }
                    else if(opportunityObj.get('RecordTypeId') != outpatientRecordTypeId) {
                        nullFieldsList += fieldInstance.getLabel() +'\n';
                    }                       
            }
            else if(String.valueOf(fieldInstance.getFieldPath()).contains('__r.')  && 
                    (opportunityObj.getSobject(fieldInstance.getFieldPath().substringbefore('.')).get(fieldInstance.getFieldPath().substringAfter('.')) == null 
                    || opportunityObj.getSobject(fieldInstance.getFieldPath().substringbefore('.')).get(fieldInstance.getFieldPath().substringAfter('.')) == '')) {
                        if(fieldInstance.getFieldPath() == 'Contact__r.Identified_Gender__c') {
                            if(opportunityObj.getSobject('Contact__r').get('Gender__c') == 'Transgender') {
                                nullFieldsList += fieldInstance.getLabel() +'\n';
                            }
                        } else {
                            nullFieldsList += fieldInstance.getLabel() +'\n';
                        }
            }
        }
        nullFieldsList = nullFieldsList.removeEnd('\n');
        
        return nullFieldsList;
    }
    
}