public without sharing class MappingConstants {
	public static final SFMTAMappingCredentials__c MAPPING_CREDENTIALS	= SFMTAMappingCredentials__c.getInstance('MappingCredentials');

	public static final SFMTAMappingLayerURL__c GEOMETRY_SERVER			= SFMTAMappingLayerURL__c.getInstance('GeometryServer');

    public static final SFMTAMappingLayerURL__c BIKE_PARKING 			= SFMTAMappingLayerURL__c.getInstance('BikeParking');
    public static final SFMTAMappingLayerURL__c BIKE_PARKING_OAUTH 		= SFMTAMappingLayerURL__c.getInstance('BikeParkingOAUTH');

    public static final SFMTAMappingLayerURL__c COLOR_CURB 				= SFMTAMappingLayerURL__c.getInstance('ColorCurb');
    public static final SFMTAMappingLayerURL__c COLOR_CURB_OAUTH 		= SFMTAMappingLayerURL__c.getInstance('ColorCurbOAUTH');

    public static final SFMTAMappingLayerURL__c STREET_CLOSURE 			= SFMTAMappingLayerURL__c.getInstance('StreetClosure');
    public static final SFMTAMappingLayerURL__c STREET_CLOSURE_OAUTH 	= SFMTAMappingLayerURL__c.getInstance('StreetClosureOAUTH');

    public static final SFMTAMappingLayerURL__c TEMP_SIGNS 				= SFMTAMappingLayerURL__c.getInstance('TempSigns');
    public static final SFMTAMappingLayerURL__c TEMP_SIGNS_OAUTH 		= SFMTAMappingLayerURL__c.getInstance('TempSignsOAUTH');
}