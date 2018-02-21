public with sharing class CompareTypeString implements CompareInterface {
	
	public CompareTypeString() {}

	public Boolean compareEquals(object value, object compareTo) {

        String stringValue = (value != null) ? String.valueOf(value) : '';
        String stringCompareTo = String.valueOf(compareTo);

        List<String> splitList = stringCompareTo.split(',');

        Boolean match = false;

        if (!splitList.isEmpty()) {

            for (String aux : splitList) {
            
                aux = aux.trim();
                aux = aux.removeEnd(',');

                if (stringValue == aux) {
                    match = true;
                }
            }
        }

        return match;

          
    }


    public Boolean compareNotEquals(object value, object compareTo) {

        return !(compareEquals(value, compareTo));      
    }   


    public Boolean compareGreater(object value, object compareTo) {

        String stringValue = (value != null) ? String.valueOf(value) : '';
        String stringCompareTo = (compareTo != null) ? String.valueOf(compareTo) : '';

        return stringValue > stringCompareTo;           
    }


    public Boolean compareLower(object value, object compareTo) {

        return compareGreater(compareTo, value);
    }


    public Boolean compareGreaterEquals(object value, object compareTo) {

        return (compareEquals(value, compareTo) || compareGreater(value, compareTo));
    }


    public Boolean compareLowerEquals(object value, object compareTo) {

        return (compareEquals(value, compareTo) || compareLower(value, compareTo));
    }

    public Boolean compareContains(object value, object compareTo) {

        String stringValue = (value != null) ? String.valueOf(value) : '';
        String stringCompareTo = String.valueOf(compareTo);

        List<String> splitList = stringCompareTo.split(',');
        
        Boolean match = false;

        if (!splitList.isEmpty()) {

            for (String aux : splitList) {

                aux = aux.trim();
                aux = aux.removeEnd(',');
                Pattern regexPattern = Pattern.compile(aux.toLowerCase());
                Matcher regexMatcher = regexPattern.matcher(stringValue.toLowerCase());

                //system.assert(false, 'aux:' + aux + ' compareTo:' + stringValue + ' matcher:' + regexMatcher.find());

                if(regexMatcher.find()) {
                    
                    match = true;
                }
            }
        }

        return match;
    }
}