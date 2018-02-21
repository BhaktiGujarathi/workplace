public with sharing class CompareTypeDouble implements CompareInterface {
	public CompareTypeDouble() {}

	public Boolean compareEquals(object value, object compareTo) {

        Double doubleValue = (value != null) ? Double.valueOf(value) : 0;
        Double doubleCompareTo = Double.valueOf(compareTo);


        return doubleValue == doubleCompareTo;      
    }


    public Boolean compareNotEquals(object value, object compareTo) {

        return !(compareEquals(value, compareTo));      
    }   


    public Boolean compareGreater(object value, object compareTo) {

        Double doubleValue = (value != null) ? Double.valueOf(value) : 0;
        Double doubleCompareTo = (compareTo != null) ? Double.valueOf(compareTo) : 0;

        return doubleValue > doubleCompareTo;           
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

        return false;
    }
}