public with sharing class ObjectAccessUtils {

    private static final String NAMESPACE_PREFIX = '';

    // ********** FIELD LEVEL SECURITY METHODS ********** //

    private static Map<String, Schema.DescribeFieldResult> getObjectFieldMap(String sObjectName) {

        Map<String,Schema.SObjectField> fieldsMap;
        Map<String, Schema.DescribeFieldResult> fieldDescribe = new Map<String, Schema.DescribeFieldResult>();

        if (isCustomObject(sObjectName)) {
            sObjectName = NAMESPACE_PREFIX + sObjectName;
        }

        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
        fieldsMap = objectDescribe.fields.getMap();

        for (Schema.SObjectField a :fieldsMap.values()) {

            fieldDescribe.put(a.getDescribe().getName(), a.getDescribe());
        }

        return fieldDescribe;
    }

    public static Boolean hasFieldAccess(String sObjectName, String[] fieldNames) {

        Boolean result = true;

        Map<String, Schema.DescribeFieldResult> objectFieldDescribe = getObjectFieldMap(sObjectName);

        Set <String> keys = objectFieldDescribe.keySet();

        for (String fieldValue :fieldNames) {

            if (isCustomField(sObjectName, fieldValue)) {
                fieldValue = NAMESPACE_PREFIX + fieldValue;
            }

            result &= objectFieldDescribe.get(fieldValue).isAccessible();
        }

        return result;
    }

    public static Boolean hasFieldCreate(String sObjectName, String[] fieldNames) {

        Boolean result = true;
        Map<String, Schema.DescribeFieldResult> objectFieldDescribe = getObjectFieldMap(sObjectName);

        for (String fieldValue :fieldNames) {
            if (isCustomField(sObjectName, fieldValue)) {
                fieldValue = NAMESPACE_PREFIX + fieldValue;
            }

            result &= objectFieldDescribe.get(fieldValue).isCreateable();
        }

        return result;
    }

    public static Boolean hasFieldUpdate(String sObjectName, String[] fieldNames) {

        Boolean result = true;
        Map<String, Schema.DescribeFieldResult> objectFieldDescribe = getObjectFieldMap(sObjectName);

        for (String fieldValue :fieldNames) {
            if (isCustomField(sObjectName, fieldValue)) {
                fieldValue = NAMESPACE_PREFIX + fieldValue;
            }
            result &= objectFieldDescribe.get(fieldValue).isUpdateable();
        }

        return result;
    }

    // ********** OBJECT SECURITY METHODS ********** //

    private static Schema.DescribeSObjectResult getObjectDescribe(String objectName) {

        if (isCustomObject(objectName)) {
            objectName = NAMESPACE_PREFIX + objectName;

        }

        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();

        return objectDescribe;
    }

    public static Boolean isObjectAccessible(String objectName) {

        return getObjectDescribe(objectName).isAccessible();
    }

    public static Boolean isObjectCreateable(String objectName) {

        return getObjectDescribe(objectName).isCreateable();
    }

    public static Boolean isObjectUpdateable(String objectName) {

        return getObjectDescribe(objectName).isUpdateable();
    }


    private static Boolean isCustomObject(String objectName) {

        Map<String, Schema.SObjectType> objectsMap = Schema.getGlobalDescribe();

        if (objectsMap.containsKey(objectName)) {

            Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
            return objectDescribe.isCustom();
        }
        else if (objectsMap.containsKey(NAMESPACE_PREFIX + objectName)) {

            Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(NAMESPACE_PREFIX + objectName).getDescribe();
            return objectDescribe.isCustom();
        }

        return false;
    }

    private static Boolean isCustomField(String objectName, String fieldName) {

        Map<String, Schema.DescribeFieldResult> objectFieldDescribe = getObjectFieldMap(objectName);

        if (objectFieldDescribe.containsKey(fieldName)) {
            Schema.DescribeFieldResult fieldDescribe = objectFieldDescribe.get(fieldName);
            return fieldDescribe.isCustom();
        }
        else if (objectFieldDescribe.containsKey(NAMESPACE_PREFIX + fieldName)) {
            Schema.DescribeFieldResult fieldDescribe = objectFieldDescribe.get(NAMESPACE_PREFIX + fieldName);
            return fieldDescribe.isCustom();
        }

        return false;
    }

}