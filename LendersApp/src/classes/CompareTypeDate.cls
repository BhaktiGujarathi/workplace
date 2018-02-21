public with sharing class CompareTypeDate implements CompareInterface {
	
	public CompareTypeDate() {}

	public Boolean compareEquals(object value, object compareTo) {

        Date dateValue = (Date) value;
        Date dateCompareTo = (Date) compareTo;

        return dateValue == dateCompareTo;      
    }


    public Boolean compareNotEquals(object value, object compareTo) {

        return !(compareEquals(value, compareTo));      
    }   

    public Boolean compareGreater(object value, object compareTo) {

        Date dateValue = (Date) value;
        System.debug('###\n\n\n' + String.valueOf(compareTo));
        Date dateCompareTo = (Date) compareTo;

        return dateValue > dateCompareTo;           
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