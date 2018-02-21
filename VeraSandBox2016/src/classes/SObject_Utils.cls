/***********************************************************************************
 * Class : SObject_Utils
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Helper class for operations related to Sobject
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    02/05/2016    Initial Development
 **********************************************************************************/
public with sharing class SObject_Utils {

    /**
     * Variables to cache describe data
     */
    private static Map<String, Schema.SObjectType> globalDescribeCache = Schema.getGlobalDescribe();
    private static Map<String, DescribeSObjectResult> sobjectDescribeCache
        = new Map<String, DescribeSObjectResult>();
    private static Map<String, Schema.FieldSet> sobjectFieldSetCache
        = new Map<String, Schema.FieldSet>();

    /**
     * This method gives list of field api names contained in specified field set
     *
     * @param fieldSetName  Name of the field set which contains required fields
     * @param objectName    Name of the object which contains field set
     *
     * @return  List of field API names
     */
    public static List<String> getObjectFieldNames(String fieldSetName, String objectName) {
        Schema.FieldSet fieldSetObj = fetchFieldSetData(fieldSetName, objectName);
        List<String> fieldApiNames = new List<String>();
        if (fieldSetObj != null) {
            for (FieldSetMember fieldSetMember : fieldSetObj.getFields()) {
                fieldApiNames.add(fieldSetMember.getFieldPath());
            }
        }
        return fieldApiNames;
    }

    /**
     * This method gives list of field api names contained in all the field sets specified
     *
     * @param fieldSetNames  Name of the field sets which contains required fields
     * @param objectName     Name of the object which contains field sets
     *
     * @return  Set of field API names
     */
    public static Set<String> getObjectFieldNames(List<String> fieldSetNames, String objectName) {
        Schema.DescribeSObjectResult describeSObjectResultObj = getSobjectDescribe(objectName);
        Map<String, Schema.FieldSet> fieldSetMap = describeSObjectResultObj.FieldSets.getMap();
        Set<String> fieldApiNames = new Set<String>();
        for (String fieldSetName : fieldSetNames) {
            if (fieldSetMap.containsKey(fieldSetName)) {
                for (FieldSetMember fieldSetMember : fieldSetMap.get(fieldSetName).getFields()) {
                    fieldApiNames.add(fieldSetMember.getFieldPath());
                }
            }
        }
        return fieldApiNames;
    }

    /**
     * Return map of field names having key as field api name and value as field label
     *
     * @param fieldSetName  Name of the field set which contains required fields
     * @param objectName    Name of the object which contains field set
     *
     * @return  Returns a map having field API name and field label
     */
    public static Map<String, String> getObjectFieldNamesMap(
        String fieldSetName,
        String objectName
    ) {
        Schema.FieldSet fieldSetObj = fetchFieldSetData(fieldSetName, objectName);
        Map<String,String> fieldApiNames = new Map<String,String>();
        if (fieldSetObj != null) {
            for (FieldSetMember fieldSetMember : fieldSetObj.getFields()) {
                fieldApiNames.put(fieldSetMember.getFieldPath(), fieldSetMember.getLabel());
            }
        }
        return fieldApiNames;
    }

    /**
     * Return object name when a valid id is passed to the method
     *
     * @param recordId  Id of the record
     *
     * @return  Object API name
     */
    public static String getSobjectNameFromId(Id recordId) {
        return recordId != null ? recordId.getSObjectType().getDescribe().getName() : null;
    }

    /**
     * Method to fetch FieldSet describe for specified field set name and sobject
     */
    public static Schema.FieldSet getFieldSetDescribe(String fieldSetName, String objectName) {
        Schema.DescribeSObjectResult describeSObjectResultObj = getSobjectDescribe(objectName);
        Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj;
    }

    /*
     * Filters the List of sobject based on record type passed to it
     *
     * @param recordTypeName    Developer Name of the record type used to filter out records
     * @param sobjects          List of sobjects on which filterting is to be done
     *
     * @return List of filtered sobjects
     */
    public static List<sObject> getSobjectsFilteredByRecordType(
        String recordTypeName,
        List<sObject> sobjects
    ) {
        List<sObject> filteredSobjects = new List<sObject>();
        if (String.isNotBlank(recordTypeName) && sobjects != null && !sobjects.isEmpty()) {
            // Get record type id based on record type developer name
            String objectName = SObject_Utils.getSobjectNameFromId(sobjects[0].Id);
            Id recordTypeId = RecordType_Utils.getRecordTypeId(objectName, recordTypeName);
            // Iterate over passed List and filter based on record type id
            for (sObject thisSobject : sobjects) {
                if ((Id)thisSobject.get(Constant.FIELD_RECORDTYPEID) == recordTypeId) {
                    filteredSobjects.add(thisSobject);
                }
            }
        }
        return filteredSobjects;
    }

    /**
     * This method returns DescribeSobjectResult for specified sobject api name
     */
    public static Schema.DescribeSObjectResult getSobjectDescribe(String sobjectName) {
        Schema.DescribeSObjectResult sobjectDescribe;
        if(sobjectDescribeCache != null && sobjectDescribeCache.containsKey(sobjectName)) {
            sobjectDescribe = sobjectDescribeCache.get(sobjectName);
        } else {
            Schema.SObjectType sobjectType = globalDescribeCache.get(sobjectName);
            sobjectDescribe = sobjectType.getDescribe();
            if(sobjectDescribeCache == null) {
                sobjectDescribeCache = new Map<String, DescribeSObjectResult>();
            }
            sobjectDescribeCache.put(sobjectName, sobjectDescribe);
        }
        return sobjectDescribe;
    }

    /**
     * This method is a helper method for fetching field set.
     * If field set data exists in cache map, FieldSet object is returned from cache.
     * Else a describe call is done.
     */
    private static Schema.FieldSet fetchFieldSetData(String fieldSetName, String objectName) {
        String sobjectFieldSetKey = Utility.joinStringsWithSeparator(
            objectName,
            fieldSetName,
            Constant.HASH
        );
        Schema.FieldSet fieldSetObj;
        if (sobjectFieldSetCache != null &&
            sobjectFieldSetCache.containsKey(sobjectFieldSetKey)) {
            fieldSetObj = sobjectFieldSetCache.get(sobjectFieldSetKey);
        } else {
            if(sobjectFieldSetCache == null) {
                sobjectFieldSetCache = new Map<String, Schema.FieldSet>();
            }
            fieldSetObj = getFieldSetDescribe(fieldSetName, objectName);
            sobjectFieldSetCache.put(sobjectFieldSetKey, fieldSetObj);
        }
        return fieldSetObj;
    }
}