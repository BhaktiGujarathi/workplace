/**
 *  This class is a helper class for setting default values
 *
 *  Version     Author                      Date(DD/MM/YYYY)            Description
 *  1.0         Ajinkya Hingne              13/10/2016                  Initial draft[]
 */

public with sharing class DefaultValueHelper {

    public static Map<String, Schema.SObjectField> MAP_OBJECT_FIELD;
    public static Map<String, String> MAP_OF_FIELD_AND_DEFAULT_VALS;
    public static Map<String, String> MAP_OF_FIELD_AND_DFAULT_FORMULA_VALS;

    /*private static final Set<Schema.DisplayType> DEFAULT_VALUE_TYPES = new Set<Schema.DisplayType> {
        DisplayType.Boolean,
        DisplayType.Picklist,
        DisplayType.MultiPicklist
    };*/

    private static final Set<Schema.DisplayType> DEFAULT_VALUE_FORMULA_TYPES
        = new Set<Schema.DisplayType> {
            DisplayType.String,
            DisplayType.Currency,
            DisplayType.Phone,
            DisplayType.Email,
            DisplayType.Double,
            DisplayType.Percent,
            DisplayType.TextArea,
            DisplayType.URL
        };

    /**
     * This method populates the default values on the given instance and for the given fields
     *
     * @param pObjInstance
     * @param pFields
     * @param pDescSObjResult
     */
    public static void populateValues(
            sObject pObjInstance,
            List<Schema.FieldSetMember> pFields,
            Schema.DescribeSObjectResult pDescSObjResult
    ) {
        MAP_OBJECT_FIELD = pDescSObjResult.fields.getMap();
        MAP_OF_FIELD_AND_DFAULT_FORMULA_VALS = new Map<String, String>();
        
        for(Schema.FieldSetMember fieldSetMemb : pFields) {
            Schema.SObjectField sObjFields = MAP_OBJECT_FIELD.get(fieldSetMemb.getfieldPath());
            Schema.DescribeFieldResult descFieldResult = sObjFields.getDescribe();
            // Un-comment this when salesforce start to support default value.
            /*if(DEFAULT_VALUE_TYPES.contains(fieldSetMemb.getType())) {
                pObjInstance.put(
                    fieldSetMemb.getFieldPath(),
                    descFieldResult.getDefaultValue()
                );
            } else*/
            if(DEFAULT_VALUE_FORMULA_TYPES.contains(fieldSetMemb.getType())) {
                if(descFieldResult.getDefaultValueFormula() != null &&
                    descFieldResult.getDefaultValueFormula() != '') {
                    String value = stripQuotes(descFieldResult.getDefaultValueFormula());
                    if(fieldSetMemb.getType() == DisplayType.Email ||
                        fieldSetMemb.getType() == DisplayType.TextArea ||
                        fieldSetMemb.getType() == DisplayType.String ||
                        fieldSetMemb.getType() == DisplayType.URL ||
                        fieldSetMemb.getType() == DisplayType.Phone) {
                        pObjInstance.put(
                            fieldSetMemb.getFieldPath(), 
                            value
                        );
                    }
                    if(fieldSetMemb.getType() == DisplayType.Currency ||
                        fieldSetMemb.getType() == DisplayType.Double ||
                        fieldSetMemb.getType() == DisplayType.Percent) {
                       pObjInstance.put(
                            fieldSetMemb.getFieldPath(), 
                            decimal.valueOf(value)
                        );
                    }
                    System.debug('value---: '+value);
                }
            }
        }
    }

    /**
     * To remove starting and ending quotes from default value
     */
    private static String stripQuotes(String defaultValue) {
        if(defaultValue.startsWith('\'')) {
            return defaultValue.removeStart('\'').removeEnd('\'');
        } 
        else if(defaultValue.startsWith('"')) {
            return defaultValue.removeStart('"').removeEnd('"');
        }
        return defaultValue;
    }
}