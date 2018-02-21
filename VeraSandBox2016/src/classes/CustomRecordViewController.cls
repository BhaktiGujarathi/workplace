/***********************************************************************************
 * Class : CustomRecordViewController
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Controller class for CustomRecordView component
                 This class contains getter and setter methods to set the attribute values
                 Also, contains logic to query object based on passed record Id.
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    20/04/2016    Initial Development
 **********************************************************************************/
public with sharing class CustomRecordViewController {

    /* Component attributes variables */
    public Id sobjectInstanceId;
    public String page;
    public String section;

    /* Getters and setters */
    public Integer sectionColumns {get; set;}
    public sObject sobjectInstance {get; set;}
    public List<String> fieldNames {get; set;}
    public Map<String, String> fieldApiNameLabelMap {get; set;}

    public Void setSobjectInstanceId(Id value) {
        sobjectInstanceId = value;
        init();
    }

    public String getSobjectInstanceId() {
        return sobjectInstanceId;
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
     * This method is called when component is loaded and all the attributes are set
     * Method queries the object based on the record Id passed to the component
     */
    public PageReference init() {

        // Following block checks whether all the attribute values are set by setter methods before
        // querying the object
        if (String.isBlank(sobjectInstanceId) || String.isBlank(page) || String.isBlank(section)) {
            return null;
        }

        Full_Profile_Setting__c profileSetting = FullProfileHelper.getProfileSetting(page, section);
        if (profileSetting != null) {
            String objectName = sobjectInstanceId.getSObjectType().getDescribe().getName();
            fieldNames = SObject_Utils.getObjectFieldNames(profileSetting.Fields__c, objectName);
            fieldApiNameLabelMap
                = SObject_Utils.getObjectFieldNamesMap(profileSetting.Fields__c, objectName);

            String query = Query_Utils.queryBuilder(
                objectName,
                String.join(fieldNames, Constant.COMMA),
                Constant.ID + Constant.EQUALC + ': sobjectInstanceId',
                null,
                null,
                null
            );

            try {
                sobjectInstance = Database.query(query);
            } catch(Exception caughtException) {
                Utility.addPageMessage(ApexPages.Severity.ERROR, caughtException.getMessage());
            }
        }
        return null;
    }

}