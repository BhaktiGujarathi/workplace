public interface CompareInterface {

	//Define the method signature to be implemented in classes that implements the interface
	//Example method
	Boolean compareEquals(object value, object compareTo);

    Boolean compareNotEquals(object value, object compareTo);

    Boolean compareGreater(object value, object compareTo);

    Boolean compareLower(object value, object compareTo);

    Boolean compareGreaterEquals(object value, object compareTo);

    Boolean compareLowerEquals(object value, object compareTo);

    Boolean compareContains(object value, object compareTo);

}