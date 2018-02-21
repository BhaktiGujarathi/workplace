public with sharing class UnderwriterAssignmentRuleEntry {

    public String objectAPI { get; set; }
    public String fieldAPI { get; set; }
    public String operator { get; set; }
    public String value { get; set; }


    public UnderwriterAssignmentRuleEntry(Underwriter_Assignment_Rule_Entry__c assignmentRuleEntry) {
        
        objectAPI = 'Opportunity';
        fieldAPI = assignmentRuleEntry.Field_API_Name__c;
        operator = assignmentRuleEntry.Operator__c;
        value = assignmentRuleEntry.Value__c;
    }


    public Boolean evaluateRuleEntry(sObject record) {
        
        CompareInterface ruleEntryField = getRuleEntryField();        

        if (ruleEntryField != null) {

            if (operator == 'equal') {

                return ruleEntryField.compareEquals(record.get(fieldAPI), value);
            }
            else if (operator == 'contains') {

                return ruleEntryField.compareContains(record.get(fieldAPI), value);
            }
            else if (operator == 'not equal to') {

                return ruleEntryField.compareNotEquals(record.get(fieldAPI), value);
            }
            else if (operator == 'greater than') {

                return ruleEntryField.compareGreater(record.get(fieldAPI), value);  
            }
            else if (operator == 'less than') {

                return ruleEntryField.compareLower(record.get(fieldAPI), value);
            }
            else if (operator == 'greater or equal') {

                return ruleEntryField.compareGreaterEquals(record.get(fieldAPI), value); 
            }
            else if (operator == 'less or equal') {

                return ruleEntryField.compareLowerEquals(record.get(fieldAPI), value);  
            }            
        }

        return false;       
    }


    private CompareInterface getRuleEntryField() {

        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectAPI).getDescribe();
        Map<String,Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();
        Schema.DisplayType fieldType = fieldsMap.get(fieldAPI).getDescribe().getType();


        if (fieldType == Schema.DisplayType.Date) {

            return new CompareTypeDate();
        } 
        else if (fieldType == Schema.DisplayType.Datetime) {

            return new CompareTypeDateTime();
        }
        else if (fieldType == Schema.DisplayType.Currency || fieldType == Schema.DisplayType.Integer
                                                          || fieldType == Schema.DisplayType.Double) {
            
            return new CompareTypeDouble();
        } 
        else if (fieldType == Schema.DisplayType.Boolean) {
            
            return new CompareTypeBoolean();
        } 
        else {
            
            return new CompareTypeString();
        }
    }
}