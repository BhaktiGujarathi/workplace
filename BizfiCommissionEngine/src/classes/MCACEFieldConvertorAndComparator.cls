public with sharing class MCACEFieldConvertorAndComparator {
    // get global map by schema call
    public static Map<String,Schema.SObjectType> globalMap = Schema.getGlobalDescribe(); 
    
   
    
    // method to get the datatype of a feild of a particular object from schema call
    public static DatatypeAndValidWrapper getDatatypeAndValidate(MCACE__Commission_Rule_Entry__c pRuleEntry) 
    {
        
        DatatypeAndValidWrapper responseObj = new DatatypeAndValidWrapper();
        String objectString;
        String fieldstring;
        Schema.Sobjecttype objectToken;
        String datatypeString;

        // get name of object
        if(pRuleEntry.get('MCACE__Object_API__c') != null) 
        {
            objectString = String.valueOf(pRuleEntry.get('MCACE__Object_API__c'));
            responseObj.objectName = objectString;
            // get token name of object
            if(globalMap.containsKey(objectString)) {
                objectToken = globalMap.get(objectString);
                
                // get field name
                if(pRuleEntry.get('MCACE__Field_API__c') != null) {
                    fieldstring = string.ValueOf(pRuleEntry.get('MCACE__Field_API__c'));
                    responseObj.fieldName = fieldstring;
                    
                    // get field map from schema call
                    Map<String, Schema.SObjectField> fieldMap = objectToken.getDescribe().fields.getMap();
                   
                    // if field map contains field than get its datatype by schema call
                    if(fieldMap.containsKey(fieldstring)) {
                        Schema.DescribeFieldResult fieldDescription = fieldMap.get(fieldstring).getDescribe();
                        datatypeString = String.valueOf(fieldDescription.getType());
                        responseObj.datatypeName = datatypeString; 
                    
                        if(pRuleEntry.get('MCACE__Text__c') != null) {
                            responseObj.valueString = String.valueOf(pRuleEntry.get('MCACE__Text__c'));
                            if(pRuleEntry.get('MCACE__Operator__c') != null) {
                                responseObj.operatorString = String.valueOf(pRuleEntry.get('MCACE__Operator__c'));
                               
                                // if datatype is string
                                if(datatypeString.equalsIgnoreCase('String')) {             
                                    responseObj = MCACEFieldValidator.validatStringAndPhone(responseObj);
                                } 
                                // if datatype is Email
                                else if(datatypeString.equalsIgnoreCase('Email')) {        
                                    responseObj = MCACEFieldValidator.validateEmail(responseObj);
                                } else if(datatypeString.equalsIgnoreCase('REFERENCE')) {    // if datatype is Reference
                                    responseObj.refenceToString = (String.valueOf(fieldDescription.getReferenceTo())).removeStart('(').removeEnd(')');
                                    responseObj.relationShipNameString = String.valueOf(fieldDescription.getRelationshipName());
                                    responseObj = MCACEFieldValidator.validatStringAndPhone(responseObj);
                                } else if(datatypeString.equalsIgnoreCase('Boolean')) {      // if datatype is Boolean
                                    responseObj = MCACEFieldValidator.validateBoolean(responseObj);
                                } else if(datatypeString.equalsIgnoreCase('PickList')) {     // if datatype is PickList
                                    responseObj = MCACEFieldValidator.validatePickList(responseObj);
                                } else if(datatypeString.equalsIgnoreCase('Currency')) {     // if datatype is Currency
                                    responseObj = MCACEFieldValidator.validateNumber(responseObj);
                                } else if(datatypeString.equalsIgnoreCase('Percent')) {    // if datatype is Percentage
                                    responseObj = MCACEFieldValidator.validateNumber(responseObj);
                                } else if(datatypeString.equalsIgnoreCase('Date')) {          // if datatype is Date
                                    responseObj = MCACEFieldValidator.validateDate(responseObj);
                                } else if(datatypeString.equalsIgnoreCase('Datetime')) {      // if datatype is Datetime
                                    //responseObj = MCACEFieldValidator.validateDatetime(responseObj);
                                    //responseObj.datatypeName = 'Date';
                                    responseObj = MCACEFieldValidator.validateDate(responseObj);
                                } else if(datatypeString.equalsIgnoreCase('Phone')) {         // if datatype is Phone
                                    responseObj = MCACEFieldValidator.validatStringAndPhone(responseObj);
                                } else if(datatypeString.equalsIgnoreCase('Number')) {        // if datatype is number
                                    responseObj = MCACEFieldValidator.validateNumber(responseObj);
                                } else if(datatypeString.equalsIgnoreCase('Double')) {        // if datatype is Double
                                    responseObj = MCACEFieldValidator.validateNumber(responseObj);
                                } else if(datatypeString.equalsIgnoreCase('URL')){
                                    responseObj = MCACEFieldValidator.validatStringAndPhone(responseObj);
                                } else {                                                      // if datatype is not valid
                                    responseObj.isValid = false;
                                    responseObj.errorString  =  'Select a proper field and proper object!';
                                }
                            }
                            else {
                                responseObj.errorString  =  'Please select an operator!';
                            }
                        }
                        else {
                            responseObj.errorString  =  'Please enter a value!';
                        }
                   }
                   else {
                       responseObj.errorString  =  'No such field for selected object!';
                   }
               }
               else {
                   responseObj.errorString  =  'Enter a field Api!';
               }
           }
           else {
               responseObj.errorString  =  'No such object exists!';
           }
       }
       else {
           responseObj.errorString  =  'Enter an object value!';
       }
        
        // return response wrapper
        return responseObj;
    }
    
    
    public static Boolean convertAndCompareLookUp(DatatypeAndValidWrapper pWrapperObj, String pTextValue, object pobjectValue, String pOperator) {
        Boolean returnFlag = false;
        if (String.valueOf(pobjectValue) != null ) {
            String lookupQueryString = 'SELECT Name From ' +pWrapperObj.refenceToString+ ' Where Id =\'' +String.valueOf(pobjectValue)+ '\'' ;
        
            List<Sobject> objInstanceList = database.query(lookupQueryString);
            if(objInstanceList.size() > 0 )
            {
                if(pOperator == 'equals') {
                    if(String.valueOf(pTextValue).equalsIgnoreCase(String.valueOf(objInstanceList[0].get('Name')))) {
                        returnFlag = true;
                    }
                } else if(pOperator == 'not equal to') {
                    if(!(String.valueOf(pTextValue).equalsIgnoreCase(String.valueOf(objInstanceList[0].get('Name'))))) {
                        returnFlag = true;
                    }
                }
            }  
        } else if(String.valueOf(pobjectValue) == null && pOperator == 'not equal to') {
            returnFlag = true;
        } else if(String.valueOf(pobjectValue) == null && pOperator == 'equals') {
            returnFlag = false;
        }     
        
        return returnFlag ;
    }
     
    public static Boolean convertAndComparePhone(String pTextValue, object pobjectValue, String pOperator) {
       Boolean returnFlag = false;
      
       String objValue = String.valueOf(pobjectValue);
       if(objValue.contains('(') || objValue.contains(')') || objValue.contains(' ') || objValue.contains('-')) {
           String tempObjValueStr = objValue.replace('(', ' ').replace(')', ' ' ).replace('-', ' ').replace(' ', '');
           objValue = tempObjValueStr;
       }
       String textValue = String.valueOf(pTextValue);
       if(textValue.contains('(') || textValue.contains(')') || textValue.contains(' ') || textValue.contains('-')) {
           String tempTextValueStr = objValue.replace('(', '').replace(')', '' ).replace('-', '').replace(' ', '');
           textValue = tempTextValueStr;
       }
       returnFlag = convertAndCompareString(textValue, objValue, pOperator);
       return returnFlag; 
    }
    
    public static Boolean convertAndCompareString(String pTextValue, object pobjectValue, String pOperator) {
        Boolean returnFlag = false;
        String strObjValue = '';
        
        if(String.valueOf(pobjectValue) != null) {
            strObjValue = String.valueOf(pobjectValue);
        }
        else {
            strObjValue = '';
        }
        
        if(pOperator == 'equals') {
            if(String.valueOf(pTextValue).equalsIgnoreCase(String.valueOf(pobjectValue))) {
                returnFlag = true;
            }
        }else if(pOperator == 'not equal to'){
            if(!(String.valueOf(pTextValue).equalsIgnoreCase(String.valueOf(pobjectValue)))) {
                returnFlag = true;
            }
            
        }
        return returnFlag;
    }
    
    public static Boolean convertAndCompareDecimal(String pTextValue, object pobjectValue, String pOperator) {
        Boolean returnFlag = false;
        pTextValue = pTextValue.replaceAll(',','');
        if(pOperator == 'equals') {
            if(Decimal.valueOf(pTextValue) == (Decimal)(pobjectValue)) {
                returnFlag = true;
            }
        }
        else if(pOperator == 'not equal to') {
            if(Decimal.valueOf(pTextValue) != (Decimal)(pobjectValue)) {
                returnFlag = true;
            }
        } 
        else if(pOperator == 'greater than') {
            if(Decimal.valueOf(pTextValue) < (Decimal)(pobjectValue)) {
                returnFlag = true;
            }
        }
        else if(pOperator == 'less than') {
            if(Decimal.valueOf(pTextValue) > (Decimal)(pobjectValue)) {
                returnFlag = true;
            }
        }
        else if(pOperator == 'less or equal') {
            if(Decimal.valueOf(pTextValue) >= (Decimal)(pobjectValue)) {
                returnFlag = true;
            }
        }
        else if(pOperator == 'greater or equal') {
            if(Decimal.valueOf(pTextValue) <= (Decimal)(pobjectValue)) {
                returnFlag = true;
            }
        }
        return returnFlag;
    }
    
    public static Boolean convertAndCompareDate(String pTextValue, object pobjectValue, String pOperator) {
        
       /* Boolean returnFlag = false;
        system.debug('#####   Date.value(pTextValue): '+Date.valueOf(pTextValue));
         system.debug('#####   Date.valueOf(pobjectValue)): '+Date.valueOf(pobjectValue));
        if(pOperator == 'equals') {        
            if( Date.valueOf(pTextValue) == Date.valueOf(pobjectValue)) 
            {
                returnFlag = true;
            }
        }*/
        
        
        Boolean returnFlag = false;
       /* date tempDate = Date.parse(pTextValue);
        String tempString = tempDate.format();
        system.debug('>>>tempString  : '+tempString);
        system.debug('>>>Date.parse(tempString) : '+Date.parse(tempString));
        system.debug('>>>pobjectValue : '+pobjectValue);
        system.debug('>>>Date.valueOf(pobjectValue) : '+Date.valueOf(pobjectValue));*/
        if(pOperator == 'equals') {        
            if(Date.valueOf(pTextValue) == Date.valueOf(pobjectValue)) 
            {
                returnFlag = true;
            }
        }
        else if(pOperator == 'not equal to') {
            if(Date.valueOf(pTextValue) != Date.valueOf(pobjectValue)) {
                returnFlag = true;
            }
        } 
        else if(pOperator == 'greater than') {
            if(Date.valueOf(pTextValue) < Date.valueOf(pobjectValue)) {
                returnFlag = true;
            }
        }
        else if(pOperator == 'less than') {
            if(Date.valueOf(pTextValue) > Date.valueOf(pobjectValue)) {
                returnFlag = true;
            }
        }
        else if(pOperator == 'less or equal') {
            if(Date.valueOf(pTextValue) >= Date.valueOf(pobjectValue)) {
                returnFlag = true;
            }
        }
        else if(pOperator == 'greater or equal') {
            if(Date.valueOf(pTextValue) <= Date.valueOf(pobjectValue)) {
                returnFlag = true;
            }
        }
        return returnFlag;
    }
    
   /* public static Boolean convertAndCompareDateTime(String pTextValue, object pobjectValue, String pOperator) {
        Boolean returnFlag = false;
        
        if(pOperator == 'equals') {        
            if(Datetime.valueOf(pTextValue).formatLong() == DateTime.valueOf(pobjectValue).formatLong()) 
            {
                returnFlag = true;
            }
        }
        else if(pOperator == 'not equal to') {
            if(Datetime.valueOf(pTextValue).formatLong() != DateTime.valueOf(pobjectValue).formatLong()) {
                returnFlag = true;
            }
        } 
        else if(pOperator == 'greater than') {
            if(Datetime.valueOf(pTextValue).formatLong() < DateTime.valueOf(pobjectValue).formatLong()) {
                returnFlag = true;
            }
        }
        else if(pOperator == 'less than') {
            if(Datetime.valueOf(pTextValue).formatLong() > DateTime.valueOf(pobjectValue).formatLong()) {
                returnFlag = true;
            }
        }
        else if(pOperator == 'less or equal') {
            if(Datetime.valueOf(pTextValue).formatLong() >= DateTime.valueOf(pobjectValue).formatLong()) {
                returnFlag = true;
            }
        }
        else if(pOperator == 'greater or equal') {
            if(Datetime.valueOf(pTextValue).formatLong() <= DateTime.valueOf(pobjectValue).formatLong()) {
                returnFlag = true;
            }
        }
        return returnFlag;
    }*/
    
    // wrapper to hold object and its field together
    public class DatatypeAndValidWrapper {
        public String objectName;
        public String fieldName;
        public String datatypeName;
        public String valueString;
        public Boolean isValid; 
        public String errorString;
        public String refenceToString;
        public String relationShipNameString;
        public String operatorString;
        
        public DatatypeAndValidWrapper() {
            isValid = false;
            objectName = '';
            fieldName = '';
            datatypeName = '';
            valueString = '';
            errorString = '';
            refenceToString = '';
            relationShipNameString = '';
            operatorString = '';
        }   
    }
}