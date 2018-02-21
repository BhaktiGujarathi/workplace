public with sharing class CompareTypeDateTime implements CompareInterface {
	
	public CompareTypeDateTime() {}

	 public Boolean compareEquals(object value, object compareTo) {

        Datetime datetimeValue = (Datetime) value;
        Datetime datetimeCompareTo = (Datetime) compareTo;

        return datetimeValue == datetimeCompareTo;      
    }


    public Boolean compareNotEquals(object value, object compareTo) {

        return !(compareEquals(value, compareTo));      
    }   


    public Boolean compareGreater(object value, object compareTo) {

        Datetime datetimeValue = (Datetime) value;
        Datetime datetimeCompareTo = (Datetime) compareTo;

        return datetimeValue > datetimeCompareTo;           
    }


    public Boolean compareLower(object value, object compareTo) {

        return (!compareGreater(value, compareTo) && !compareEquals(value, compareTo));
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