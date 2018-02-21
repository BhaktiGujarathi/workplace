/***********************************************************************************
 * Class : RecordType_Utils
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Helper class for record type related operations
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    02/05/2016    Initial Development
 **********************************************************************************/
public with sharing class RecordType_Utils {

    private static Map<String, Id> recordTypeNameIdCache = new Map<String, Id>();

    /**
     * Returns record type id for specified object based on record type developer name
     *
     * @param objectName                Name of the object
     * @param recordTypeDeveloperName   Record type developer name
     *
     * @return Id of the requested record type. If record type name doesn't match, returns null
     */
    public static Id getRecordTypeId(String objectName, String recordTypeDeveloperName) {
        Id recordTypeId = null;
        if (String.isNotBlank(objectName) && String.isNotBlank(recordTypeDeveloperName)) {
            String objectRecordTypeKey = Utility.joinStringsWithSeparator(
                objectName,
                recordTypeDeveloperName,
                Constant.HASH
            );
            if (recordTypeNameIdCache != null &&
                    recordTypeNameIdCache.containsKey(objectRecordTypeKey)) {
                recordTypeId = recordTypeNameIdCache.get(objectRecordTypeKey);
            } else {
                if (recordTypeNameIdCache == null) {
                    recordTypeNameIdCache = new Map<String, Id>();
                }
                List<RecordType> recordTypes = [
                    SELECT
                        Id,
                        DeveloperName
                    FROM
                        RecordType
                    WHERE
                        DeveloperName = :recordTypeDeveloperName
                        AND SobjectType = :objectName
                ];
                if (!recordTypes.isEmpty()) {
                    recordTypeId = recordTypes[0].Id;
                    recordTypeNameIdCache.put(objectRecordTypeKey, recordTypeId);
                }
            }
        }
        return recordTypeId;
    }

}