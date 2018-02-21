public with sharing class Utility {
	// Static variables
	public static final String  STR_ASSIGNED  							= 'Assigned';
	public static final String  STR_UNASSIGNED 							= 'Unassigned';
	public static final Integer INT_SEQUENCE_START 						= 1;
	public static final Integer INT_SEQUENCE_JUMP  						= 1;
	public static final String  STR_APPROVED   							= 'Approved';
    public static final String  STR_ACTIVE     							= 'Active';
	public static final String  STR_CUSTOM_LABEL_ERROR					= ' Custom label error : ';
	public static String  		STR_VEHICLE_STICKER_BUFFER				= System.Label.Vehicle_Sticker_Buffer;
    public static String  		STR_VEHICLE_STICKER_BUFFER_PERCENTAGE   = System.Label.Vehicle_Sticker_Buffer_Percentage;
	// method to format the sequence number
	public static String formatNumber( Decimal decInputNumber, Integer intPrefixColCount ){
		return (('00')+decInputNumber).right(intPrefixColCount);
	}// end of formatNumber

}// end of main class