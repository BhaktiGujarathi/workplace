public with sharing class UnderwriterAssignmentRuleEntryValidator {
	public UnderwriterAssignmentRuleEntryValidator() {}
	

	// As a user, I want the operator picklist to update depending on the Field API, so that I do not incorrectly select an operator that is not logical.
    public static Boolean checkForNulls(Underwriter_Assignment_Rule_Entry__c assignmentRuleEntry) {

        Boolean result = true;

        
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get('Opportunity').getDescribe();
        Map<String,Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();
        Schema.DisplayType fieldType;

        if (String.isBlank(assignmentRuleEntry.Field_API_Name__c)) {

            assignmentRuleEntry.addError('The Field API cannot be blank.');

        }
        else if (String.isBlank(assignmentRuleEntry.Operator__c)) {

            assignmentRuleEntry.addError('The Operator cannot be blank.');
        }
        else {

            result = false;
        }
    
        return result;
    }

    public static Boolean checkOperator(Underwriter_Assignment_Rule_Entry__c assignmentRuleEntry){

        Boolean result = false;

        String objectAPI = 'Opportunity';
        String fieldAPI  = assignmentRuleEntry.Field_API_Name__c;
        String operator  = assignmentRuleEntry.Operator__c;
        String value     = assignmentRuleEntry.Value__c;

        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectAPI).getDescribe();
        Map<String,Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();
        Schema.DisplayType fieldType;

        try {

            fieldType = fieldsMap.get(fieldAPI).getDescribe().getType();   
        }
        catch(Exception e) {

            assignmentRuleEntry.addError('The referenced Field API doesn\'t exist.');
        }
        
        
        if (operator == 'equals' || operator == 'not equal to') {

            result = true;
        }
        else if (String.isBlank(value) && (fieldType == Schema.DisplayType.Date || fieldType == Schema.DisplayType.Datetime) || fieldType == Schema.DisplayType.Percent || fieldType == Schema.DisplayType.URL) {
 
            //Check special cases first.
            result = false;
        }
        else {

            if (fieldType == Schema.DisplayType.Date) {

                result = checkOperatorForFieldType('Date', assignmentRuleEntry.Operator__c);    
            } 
            else if (fieldType == Schema.DisplayType.Datetime) {

                result = checkOperatorForFieldType('Datetime', assignmentRuleEntry.Operator__c);
            }
            else if (fieldType == Schema.DisplayType.Currency || fieldType == Schema.DisplayType.Integer || fieldType == Schema.DisplayType.Double || fieldType == Schema.DisplayType.Percent) {
    
            result = checkOperatorForFieldType('Double', assignmentRuleEntry.Operator__c);
            } 
            else if (fieldType == Schema.DisplayType.Boolean) {

                result = checkOperatorForFieldType('Boolean', assignmentRuleEntry.Operator__c);
            } 
            else {
            
                result = checkOperatorForFieldType('String', assignmentRuleEntry.Operator__c);
            }
        }

        return result;
    }

    //Depending on field type redirect to the corresponding function.
    private static Boolean checkOperatorForFieldType(String fieldType, String operator) {

        Boolean result = false;
        
        if (operator == 'greater than' || operator == 'greater or equal' || operator == 'less than' || operator == 'less or equal') {
        
            result = checkOperatorForGreaterOrLess(fieldType);
        }
        else if (operator == 'contains') {

            result = checkOperatorForContains(fieldType);
        }
        else {

            result = true;
        }

        return result;
    }

    private Static Boolean checkOperatorForGreaterOrLess(String fieldType) {

        Boolean result = false;

        if (fieldType != 'String' && fieldType != 'Boolean') {
            result = true;
        }

        return result;
    }

    private Static Boolean checkOperatorForContains(String fieldType) {

        Boolean result = false;     

        if (fieldType == 'String') {
            result = true;
        }

        return result;
    }


    public static Boolean checkValue(Underwriter_Assignment_Rule_Entry__c assignmentRuleEntry) {

        Boolean result = false;

        String objectAPI = 'Opportunity';
        String fieldAPI  = assignmentRuleEntry.Field_API_Name__c;
        String operator  = assignmentRuleEntry.Operator__c;
        String value     = assignmentRuleEntry.Value__c;
        String fieldValue = '';
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';

        Schema.DescribeSObjectResult    objectDescribe = Schema.getGlobalDescribe().get(objectAPI).getDescribe();
        Map<String,Schema.SObjectField> fieldsMap      = objectDescribe.fields.getMap();
        Schema.DisplayType fieldType;

        try {

            fieldType = fieldsMap.get(fieldAPI).getDescribe().getType();
        }
        catch(Exception e) {

            assignmentRuleEntry.addError('The referenced Field API doesn\'t exist.');
        }

        if (!String.isBlank(value)) {

            Pattern MyPattern = Pattern.compile(emailRegex);
            Matcher MyMatcher = MyPattern.matcher(value);

            if (MyMatcher.matches()) {

                fieldValue = 'EMAIL';
            }
            else if (value.toLowerCase() == 'true' || value.toLowerCase() == 'false') {

                fieldValue = 'BOOLEAN';
            }
            else {

                try {

                    Date.parse(value);
                    fieldValue = 'DATE';
                }
                catch (TypeException e) {

                    try {

                        Date.valueOf(value);
                        fieldValue = 'DATE';
                    }
                    catch (TypeException g) {

                        try{

                            Datetime.parse(value);
                            fieldValue = 'DATETIME';
                        } catch (TypeException h) {
                          
                            try {
                                
                                Datetime.valueOf(value);
                                fieldValue = 'DATETIME';
                            }
                            catch (TypeException i) {

                                try {

                                    Double.valueOf(value);
                                    fieldValue = 'INTEGER';
                                }
                                catch (TypeException f) {

                                    fieldValue = 'STRING';
                                }
                            }
                        }
                    }
                }
            }

            String fieldTypeString = '';

            if (fieldType == Schema.DisplayType.Date) {

                fieldTypeString = 'DATE';
            } 
            else if (fieldType == Schema.DisplayType.Datetime) {

                fieldTypeString = 'DATETIME';
            }
            else if (fieldType == Schema.DisplayType.Currency || fieldType == Schema.DisplayType.Integer || fieldType == Schema.DisplayType.Double || fieldType == Schema.DisplayType.Percent) {
            
                fieldTypeString = 'INTEGER';
            } 
            else if (fieldType == Schema.DisplayType.Boolean) {
            
                fieldTypeString = 'BOOLEAN';
            } else if(fieldType == Schema.DisplayType.Email){

                fieldTypeString = 'EMAIL';
            } else if(fieldType ==  Schema.DisplayType.phone){
                
                fieldTypeString = 'PHONE';
            } else {
    
                fieldTypeString = 'STRING';
            }

            if (fieldType == Schema.DisplayType.Picklist) {
               
                if (checkIfValueExistsForPicklist(objectAPI, fieldAPI, value)) {

                    result = true;                
                }
                else {
                    assignmentRuleEntry.addError('The value you entered does not exists in the field you selected.');
                }
            } 
            else if (fieldType == Schema.DisplayType.MultiPicklist) {

                if (checkIfValueExistsForMultiPicklist(objectAPI, fieldAPI, value)) {

                    result = true;
                } 
                else {

                    assignmentRuleEntry.addError('The value you entered does not exists in the field you selected.');
                }
            }
            else if (fieldTypeString == fieldValue || fieldTypeString == 'PHONE' && fieldValue == 'STRING' || fieldTypeString == 'STRING' && fieldValue == 'INTEGER'  ) {

                result = true;
            }
            else {

                assignmentRuleEntry.addError('The value entered for Field API is not correct. The value must be in ' + fieldTypeString + ' format.');
            }            
        } 
        else if(operator == 'equals' || operator == 'not equal to' || operator == 'contains') {

            //This is an special case in which is valid for Boolean or String.
            result = true;
        }

        return result;
    }

    // In case the user entered a field of type picklist check if the value entered corresponds with that picklist
    private static Boolean checkIfValueExistsForPicklist(String objectAPI, String fieldAPI, String value) {

        Integer index = 0;
        Boolean found = false;
        Map<String,String> keys = new Map<String,String>();
        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();

        // Get the object type of the SObject.
        Schema.sObjectType objType;

        for (String s:describe.keyset()) {
            
            Schema.sObjectType current = describe.get(s);
            
            if (current.getDescribe().getName() == objectAPI) {

                objType = current;
            }
        }

        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();   

        // Get a map of fields for the SObject
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 

        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> values = fieldMap.get(fieldAPI).getDescribe().getPickListValues();

        while (index < values.size() && !found) {

            Schema.PicklistEntry currentRecord = values[index];

            if (currentRecord.getValue() == value) {

                found = true;
            }

            index++;
        }

        return found;
    }


    // In case the user entered a field of type picklist check if the value entered corresponds with that picklist
    private static Boolean checkIfValueExistsForMultiPicklist(String objectAPI, String fieldAPI, String value) {

        Integer index  = 0;
        Boolean result = false;

        Map<String,String> keys = new Map<String,String>();

        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();

        // Get the object type of the SObject.
        Schema.sObjectType objType;

        for (String s:describe.keyset()) {
        
            Schema.sObjectType current = describe.get(s);
            
            if (current.getDescribe().getName() == objectAPI) {

                objType = current;
            }
        }

        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();   

        // Get a map of fields for the SObject
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 

        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> values = fieldMap.get(fieldAPI).getDescribe().getPickListValues();
        
        List<String> stringValues = (List<String>)value.split(';');
        
        Integer countOfValuesFound = 0;

        Integer listSize = stringValues.size() - 1;

        for (Integer j = 0; j < listSize; j++) {

            String currentValue = stringValues[j];
            currentValue = currentValue.trim();
            Boolean found = false;
            
            while (index < values.size() && !found) {

                Schema.PicklistEntry currentRecord = values[index];

                if (currentRecord.getValue() == currentValue) {

                    countOfValuesFound++;
                    found = true;
                }

                index++;
            }            
        }

        if (countOfValuesFound == listSize) {

            result = true;
        }

        return result;
    }
}