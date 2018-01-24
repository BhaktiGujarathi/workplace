public with sharing class MCACEFieldValidator {
    
    // method to validate string/Id/Phone field type
    public Static MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper validatStringAndPhone(MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper pWrapper) {
         try {
             String tempVar = String.valueOf(pWrapper.valueString);
             if(pWrapper.operatorString.equalsIgnoreCase('equals') || pWrapper.operatorString.equalsIgnoreCase('not equal to')) {
                 pWrapper.isValid = true;
             }
             else {
                 pWrapper.isValid = false;
                 pWrapper.errorString = 'For '+pWrapper.datatypeName+' fields the Operator can either be \'equals\' or \'not equal to\'';                 
             }
        } catch (Exception Ex) {
            pWrapper.errorString  = pWrapper.errorString + 'The value entered for '+pWrapper.fieldName+ ' is not correct. The value must be in '+pWrapper.datatypeName+' format.';
            pWrapper.isValid = false;
        }        
        return pWrapper;
    }
    
    //method to validate number/decimal field type
    public Static MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper validateNumber(MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper pWrapper) {
        /*Pattern patternVal = Pattern.compile('((([0-9](,)){0,1}[0-9]+)+[.])?[0-9]+');
        Matcher matcherVal = patternVal.matcher(pWrapper.valueString);
        if(matcherVal.matches()) {
            pWrapper.isValid = true;
        } else {
            pWrapper.errorString  = 'The value entered for '+pWrapper.fieldName+ ' is not correct. The value must be in '+pWrapper.datatypeName+' format: 50,000.00';
            pWrapper.isValid = false;
        } */
        try {
             Decimal tempVar = Decimal.valueOf((pWrapper.valueString).replaceAll(',',''));
             pWrapper.isValid = true;
        } catch (Exception Ex) {
            if(pWrapper.datatypeName.equalsIgnoreCase('Percent')) {
                pWrapper.errorString  = 'The value entered for '+pWrapper.fieldName+ ' is not correct. The value must be in '+pWrapper.datatypeName+' format: 99.99';
            } else {
                pWrapper.errorString  = 'The value entered for '+pWrapper.fieldName+ ' is not correct. The value must be in '+pWrapper.datatypeName+' format: 50,000.00';
            }
            pWrapper.isValid = false;
        }        
               
        return pWrapper;
    }
    
    // method to validate email field type 
    public static MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper validateEmail(MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper pWrapper) {
        Pattern patternVal = Pattern.compile('[a-zA-Z0-9]+@[a-zA-Z0-9]+(.)[a-zA-z0-9]+');
        Matcher matcherVal = patternVal.matcher(pWrapper.valueString);
        if(matcherVal.matches()) {
            if(pWrapper.operatorString.equalsIgnoreCase('equals') || pWrapper.operatorString.equalsIgnoreCase('not equal to')) {
                 pWrapper.isValid = true;
             }
             else {
                 pWrapper.isValid = false;
                 pWrapper.errorString = 'For '+pWrapper.datatypeName+' fields the Operator can either be \'equals\' or \'not equal to\'';                 
             }
        } else {
            pWrapper.errorString  = 'The value entered for '+pWrapper.fieldName+ ' is not correct. The value must be in '+pWrapper.datatypeName+' format: abc@xyz.com';
            pWrapper.isValid = false;
        }        
        return pWrapper;
    }
   
    // method to validate Boolean field type
    public static MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper validateBoolean(MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper pWrapper) {       
        if(pWrapper.valueString.equalsIgnoreCase('true') || pWrapper.valueString.equalsIgnoreCase('false')) {
             if(pWrapper.operatorString.equalsIgnoreCase('equals') || pWrapper.operatorString.equalsIgnoreCase('not equal to')) {
                 pWrapper.isValid = true;
             }
             else {
                 pWrapper.isValid = false;
                 pWrapper.errorString = 'For '+pWrapper.datatypeName+' fields the Operator can either be \'equals\' or \'not equal to\'';                 
             }
        } else {
             pWrapper.errorString  = 'The value entered for '+pWrapper.fieldName+ ' is not correct. The value must be either (True/False).';
             pWrapper.isValid = false;
        }
        
        return pWrapper;
    }
    
    // method to validate picklistvalue field type
    public Static MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper validatePickList(MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper pWrapper) 
    {
        Set<String> pickListValueSet = new Set<String>();
        Schema.Sobjecttype objectToken = Schema.getGlobalDescribe().get(pWrapper.objectName);
        Map<String, Schema.SObjectField> fieldMap = objectToken.getDescribe().fields.getMap();
        List<Schema.PicklistEntry> pickListValues = fieldMap.get(pWrapper.fieldName).getDescribe().getPickListValues();  
        
        for(Schema.PicklistEntry picklistInstance :pickListValues) 
        {
            pickListValueSet.add(String.valueOf(picklistInstance.getLabel()).tolowerCase());
        }
        if(pickListValueSet.contains(pWrapper.valueString.tolowerCase())) 
        {
            if(pWrapper.operatorString.equalsIgnoreCase('equals') || pWrapper.operatorString.equalsIgnoreCase('not equal to'))
             {
                 pWrapper.isValid = true;
             }
             else {
                 pWrapper.isValid = false;
                 pWrapper.errorString = 'For '+pWrapper.datatypeName+' fields the Operator can either be \'equals\' or \'not equal to\'';                 
             }       
        } 
        else 
        {
            pWrapper.errorString  = 'The value entered for '+pWrapper.fieldName+ ' is not correct. The value must be present in the PickList field.';
            pWrapper.isValid = false;
        }
        
        return pWrapper;
    }
    
    // method to validate Date field type
    public static MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper validateDate(MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper pWrapper) {
        /*try 
        {
          DateTime dt1 = DateTime.valueOfGMT(pWrapper.valueString);
          //string s1 = d1.format();
          // Date d = date.parse(s1);
           String dt2 = dt1.format('M/d/yyyy h:mm a');
          Date d = dt1.date();
         system.debug('#### Date:'+dt2);
          pWrapper.isValid = true; 
        } 
        catch (Exception ex)
        {
           pWrapper.errorString  = 'The value entered for '+pWrapper.fieldName+ ' is not correct. The value must be in '+pWrapper.datatypeName+' format: YYYY-MM-DD HH:MM:SS';
           pWrapper.isValid = false;
        }*/
        
        Pattern  patternVal = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)');
        Matcher matcherVal = patternVal.matcher(pWrapper.valueString);
        if(matcherVal.matches()) {
           pWrapper.isValid = true;  
        } else {
            pWrapper.errorString  = 'The value entered for '+pWrapper.fieldName+ ' is not correct. The value must be in DATE format: MM/DD/YYYY';
            pWrapper.isValid = false;
        }
        return pWrapper;
    }
    
    // method to validate DateTime field
   //public static MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper validateDatetime(MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper pWrapper) {
        /*****try {
           Datetime d = DateTime.valueOfGMT(pWrapper.valueString);
           pWrapper.isValid = true; 
        } catch (Exception ex) {
            pWrapper.errorString  = 'The value entered for '+pWrapper.fieldName+ ' is not correct. The value must be in '+pWrapper.datatypeName+' format: YYYY-MM-DD HH:MM:SS';
            pWrapper.isValid = false;
        }******/
        
        /*Pattern  patternVal = Pattern.compile('((19|20)\\d\\d)-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01]) ([0-1]?[0-9]|[2][0-3]):([0-5][0-9]):([0-5][0-9])');
        Matcher matcherVal = patternVal.matcher(pWrapper.valueString);
        if(matcherVal.matches()) {
           pWrapper.isValid = true;  
        } else {
            pWrapper.errorString  = 'The value entered for '+pWrapper.fieldName+ ' is not correct. The value must be in '+pWrapper.datatypeName+' format: YYYY-MM-DD HH:MM:SS';
            pWrapper.isValid = false;
        }
        
        return pWrapper;
    }*/   
}