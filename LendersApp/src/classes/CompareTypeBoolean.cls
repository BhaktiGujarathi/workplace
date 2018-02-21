public with sharing class CompareTypeBoolean implements CompareInterface {
	
	public CompareTypeBoolean() {}



	public Boolean compareEquals(object value, object compareTo) {

        Boolean booleanValue = Boolean.valueOf(value);
        Boolean booleanCompareTo = Boolean.valueOf(compareTo);

        return booleanValue == booleanCompareTo;      
    }


    public Boolean compareNotEquals(object value, object compareTo) {

        return !(compareEquals(value, compareTo));      
    }   


    public Boolean compareGreater(object value, object compareTo) {

        return false;
    }


    public Boolean compareLower(object value, object compareTo) {

        return false;
    }


    public Boolean compareGreaterEquals(object value, object compareTo) {

        return false;
    }


    public Boolean compareLowerEquals(object value, object compareTo) {

        return false;
    }

    public Boolean compareContains(object value, object compareTo) {

        return false;
    }

}