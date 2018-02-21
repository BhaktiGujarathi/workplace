public with sharing class CompareUtils {

	Map<String,Schema.SObjectField> fieldsMap;

	public CompareUtils() {}

	public Boolean compare(sObject record, String fieldName, String operator, String value) {

		Object compareTo = convertToObject(value, fieldName);

		CompareInterface compareI = getCompareInterface(getFieldType(fieldName));

	    if (operator.toLowerCase() == 'equals') {

	        return compareI.compareEquals(record.get(fieldName), compareTo);
	    }
	    else if (operator.toLowerCase() == 'not equals') {

	        return compareI.compareNotEquals(record.get(fieldName), compareTo);
	    }
	    else if (operator.toLowerCase() == 'greater') {

	        return compareI.compareGreater(record.get(fieldName), compareTo);  
	    }
	    else if (operator.toLowerCase() == 'lower') {

	        return compareI.compareLower(record.get(fieldName), compareTo);
	    }
	    else if (operator.toLowerCase() == 'greater equal') {

	        return compareI.compareGreaterEquals(record.get(fieldName), compareTo); 
	    }
	    else if (operator.toLowerCase() == 'lower equal') {

	        return compareI.compareLowerEquals(record.get(fieldName), compareTo);  
	    }    
	    else if (operator.toLowerCase() == 'contains') {

	        return compareI.compareContains(record.get(fieldName), compareTo);  
	    }    

	    return false;
	}        


	 private CompareInterface getCompareInterface(Schema.DisplayType fieldType) {

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


    private Schema.DisplayType getFieldType(String fieldAPI) {

		Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get('Opportunity').getDescribe();
        fieldsMap = objectDescribe.fields.getMap();
		return fieldsMap.get(fieldAPI).getDescribe().getType();	
	}


    private Object convertToObject(String compareTo, String fieldName) {

    	Schema.DisplayType fieldType = getFieldType(fieldName);
    		
    	if (fieldType == Schema.DisplayType.Boolean) {

    		return Boolean.valueOf(compareTo);
    	}
    	else if (fieldType == Schema.DisplayType.Date) {

    		return Date.valueOf(compareTo);
    	}
    	else if (fieldType == Schema.DisplayType.DateTime) {

    		return DateTime.valueOf(compareTo);
    	}
    	else if (fieldType == Schema.DisplayType.Currency || fieldType == Schema.DisplayType.Integer
                                                          || fieldType == Schema.DisplayType.Double) {
            
    		return Double.valueOf(compareTo);
    	}
    	
    	return compareTo;
    }


}