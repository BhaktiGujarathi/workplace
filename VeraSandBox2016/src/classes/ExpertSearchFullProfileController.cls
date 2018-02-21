/***********************************************************************************
 * Class : ExpertSearchFullProfileController
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Controller class for ExpertSearchFullProfile page
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    21/04/2016    Initial Development
 **********************************************************************************/
public with sharing class ExpertSearchFullProfileController {

    /* Getters and Setters */
    public List<Profile_Record__c> profileRecords {get; set;}
    public List<Deployment__c> deployments {get; set;}

    /*
     * Constructor with StandardController
     * Fetches all the required records to be passed to component
     */
    public ExpertSearchFullProfileController(ApexPages.StandardController controller) {
        Id contactId = controller.getId();
        profileRecords = new List<Profile_Record__c>();
        deployments = new List<Deployment__c>();
        fetchRelatedRecords(contactId);
    }

    /**
     * This method fetches and assigns all the required related records for listing them on page
     *
     * @param contactId Id of the contact record whose related records are to be fetched
     */
    private Void fetchRelatedRecords(Id contactId) {
        try {
            profileRecords = FullProfileHelper.getRelatedRecordsForContact(
                contactId,
                Constant.OBJECT_PROFILE_RECORD,
                Label.ExpertSearchFullProfile_Page_Name
            );

            deployments = FullProfileHelper.getRelatedRecordsForContact(
                contactId,
                Constant.OBJECT_DEPLOYMENT,
                Label.ExpertSearchFullProfile_Page_Name
            );
        } catch (Exception caughtException) {
            Utility.addPageMessage(ApexPages.Severity.ERROR, caughtException.getMessage());
        }
    }

}