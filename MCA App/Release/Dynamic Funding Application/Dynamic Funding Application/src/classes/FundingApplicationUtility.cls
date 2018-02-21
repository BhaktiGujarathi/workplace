/* 
 *  Utility class to retrun query for each field sets.
 *  Function will return query by fetching fields from field sets.
 *  Revision History: 
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Ripal Patel            10-July 2015           Initial Draft 

 */


public with sharing class FundingApplicationUtility {

    
    public FundingApplicationUtility() {}
     
    // It is used to create contact query using field set.
    public String getContactQuery(List<Schema.FieldSetMember> conFields, String conAPIName) {
        Boolean isFieldPresent = false;
        String contactQuery = 'SELECT Id,';
        // Iterate contact1 fields.
        for(Schema.FieldSetMember field : conFields) {
            if((field.getFieldPath()).contains(conAPIName)) {
                contactQuery += (field.getFieldPath()).replace(conAPIName, '');
                contactQuery += ',';
                isFieldPresent = true;
            }    
        }//End For 
        
        contactQuery = contactQuery.removeEnd(',');
        
        contactQuery += ' FROM Contact';
        if(isFieldPresent)
            return contactQuery;
        return null;
    }// End getContact1Value()
    
     
     // Use to create query using fieldset
     public String generateQuery(String objectAPIName, String fieldSetName) {
        // To store dynamic query
        String query = '';
        Boolean isFieldPresent = false;
        try{
            if( objectAPIName != null ){
                query = 'SELECT ';
                
                //Get field set values.
                //List<Schema.FieldSetMember> lstFields = Id.valueOf(objectID).getSObjectType().getDescribe().fieldsets.getMap().get(fieldSetName).getFields();
                List<Schema.FieldSetMember> lstFields = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
                
                for(Schema.FieldSetMember strField : lstFields) {
                    isFieldPresent = true;
                    query += strField.getFieldPath() + ',';
                } //End of for loop for fields
                query = query .substring(0,query.length()-1);
                query += ' FROM ' + objectAPIName;
            }//End IF
        } catch(Exception e) {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.error, e.getMessage()));
        }
        if(isFieldPresent)
            return query;
        else 
            return null;
    }// End generateQuery()
}