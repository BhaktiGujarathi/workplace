/***********************************************************************************
 * Class : FullProfileHelper
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Helper class for Full Profile page controllers and reusable component
                 controllers.
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    21/04/2016    Initial Development
 **********************************************************************************/
public with sharing class FullProfileHelper {

    /**
     * Fetch custom setting record for specified page name and section name
     *
     * @param pageName    Name of the page for which custom setting instance is needed
     * @param sectionName Name of the section in page for which custom setting instance is needed
     *
     * @return  Full Profile Setting instance matching pageName and sectionName
     */
    public static Full_Profile_Setting__c getProfileSetting(String pageName, String sectionName) {
        Full_Profile_Setting__c profileSetting;
        for (Full_Profile_Setting__c setting : Full_Profile_Setting__c.getall().values()) {
            if (setting.Page_Name__c == pageName && setting.Section_Name__c == sectionName) {
                profileSetting = setting;
                break;
            }
        }
        return profileSetting;
    }

    /**
     * This method gives the records for object name passed to it which are related to a contact
     *
     * @param objectName Name of the related object
     * @param contactId  Id of the contact record whose related records are to be fetched
     */
    public static List<sObject> getRelatedRecordsForContact(
        String contactId,
        String objectName,
        String pageName
    ) {
        Set<String> fieldsApiNames = FullProfileHelper.getFullProfileFieldApiNames(
                                        objectName,
                                        pageName
                                    );
        List<sObject> records = new List<sObject>();
        if (fieldsApiNames.size() > 0) {
            String query = Query_Utils.queryBuilder(
                objectName,
                String.join(new List<String>(fieldsApiNames), Constant.COMMA),
                Constant.FIELD_EXPERTC + Constant.EQUALC + Constant.COLON + 'contactId',
                null,
                null,
                null
            );
            records = Database.query(query);
        }
        return records;
    }

    /**
     * Method used for getting field names in the fieldsets for specified object and page name
     * The field set names are first fetched for Full Profile Settings and then fields from that
     *  field set are fetched/returned.
     *
     * @param objectName Name of the object
     * @param pageName   Name of the page
     *
     * @return Set of field API names from the fieldsets stored in custom setting
     */
    public static Set<String> getFullProfileFieldApiNames(String objectName, String pageName) {
        List<String> fieldSetNames = new List<String>();
        for (Full_Profile_Setting__c setting : Full_Profile_Setting__c.getall().values()) {
            if (setting.Page_Name__c == pageName &&
                    setting.Object_Api_Name__c == objectName &&
                    setting.Layout__c == Label.Table_Layout) {
                if (String.isNotBlank(setting.Fields__c)) {
                    fieldSetNames.add(setting.Fields__c);
                }
            }
        }
        return SObject_Utils.getObjectFieldNames(fieldSetNames, objectName);
    }
}