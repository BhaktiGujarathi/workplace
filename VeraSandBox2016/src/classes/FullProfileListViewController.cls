/***********************************************************************************
 * Class : FullProfileListViewController
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Controller class for FullProfileListView component
                 This class contains getter and setter methods to set the attribute values
                 Also, contains logic to query objects based on passed record Id.
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    22/04/2016    Initial Development
 **********************************************************************************/
public with sharing class FullProfileListViewController {

    /* Component attributes variables */
    public List<sObject> sobjects;
    public String page;
    public String section;

    /* Getters and setters */
    public List<sObject> filteredSobjects {get; set;}
    public List<String> fieldNames {get; set;}
    public Map<String, String> fieldApiNameLabelMap {get; set;}

    public Void setSobjects(List<sObject> values) {
        sobjects = values;
        init();
    }

    public List<sObject> getSobjects() {
        return sobjects;
    }

    public Void setPage(String value) {
        page = value;
        init();
    }

    public String getPage() {
        return page;
    }

    public Void setSection(String value) {
        section = value;
        init();
    }

    public String getSection() {
        return section;
    }

    /**
     * Constructor initializes all the properties
     */
    public FullProfileListViewController() {
        filteredSobjects = new List<sObject>();
        fieldNames = new List<String>();
        fieldApiNameLabelMap = new Map<String, String>();
    }

    /**
     * This method is called when component is loaded and all the attributes are set
     * Method queries the object based on the record Id passed to the component
     */
    public PageReference init() {

        // Following block checks whether all the attribute values are set by setter methods before
        // querying the object
        if (sobjects == null ||
            sobjects.isEmpty() ||
            String.isBlank(page) ||
            String.isBlank(section)
        ) {
            return null;
        }

        // Fetch the custom setting record
        Full_Profile_Setting__c profileSetting = FullProfileHelper.getProfileSetting(page, section);
        String objectName;

        // Filter records based on record type if filter exists
        if (profileSetting != null && String.isNotBlank(profileSetting.Filter_By_Record_Type__c)) {
            filteredSobjects = SObject_Utils.getSobjectsFilteredByRecordType(
                                    profileSetting.Filter_By_Record_Type__c,
                                    sobjects
                                );
            if (!filteredSobjects.isEmpty()) {
                objectName = filteredSobjects[0].getSObjectType().getDescribe().getName();
            }
        } else {
            objectName = sobjects[0].getSObjectType().getDescribe().getName();
        }

        if (String.isNotBlank(objectName)) {
            fieldNames = SObject_Utils.getObjectFieldNames(profileSetting.Fields__c, objectName);
            fieldApiNameLabelMap = SObject_Utils.getObjectFieldNamesMap(profileSetting.Fields__c,
                                    objectName);
        }
        return null;
    }
}