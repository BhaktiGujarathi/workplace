/***********************************************************************************
 * Class : NominationFullProfileController
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Controller class for NominationFullProfile page
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    25/04/2016    Initial Development
 **********************************************************************************/
public with sharing class NominationFullProfileController {

    /* Getters and Setters */
    public List<Profile_Record__c> profileRecords {get; set;}

    /*
     * Constructor with StandardController
     * Fetches all the required records to be passed to component
     */
    public NominationFullProfileController(ApexPages.StandardController controller) {
        Id contactId = (Id)controller.getRecord().get(Constant.FIELD_CONTACT);
        profileRecords = new List<Profile_Record__c>();
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
                Label.NominationFullProfile_Page_Name
            );
        } catch(Exception caughtException) {
            Utility.addPageMessage(ApexPages.Severity.ERROR, caughtException.getMessage());
        }
    }
}