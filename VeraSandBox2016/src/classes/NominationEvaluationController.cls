/***********************************************************************************
 * Class : NominationEvaluationController
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Controller for NominationEvaluation page
                 Class provides getter and setters for nomination records and evaluation records.
                 Also contains methods to save an evaluation record.
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    18/04/2016    Initial Development
 **********************************************************************************/
public with sharing class NominationEvaluationController {

    /* Getters and Setters */
    public List<Nomination__c> nominatedExperts {get; set;}
    public List<Evaluation__c> evaluations {get; set;}
    public Integer nominationCount {get; set;}
    public Integer evaluationCount {get; set;}
    public Integer nominationOffset {get; set;}
    public Integer nominationLimit {get; set;}

    // This variable is used only when page is opened through tab for selection of Training record
    public Nomination__c nominationForLookup {get; set;}
    public Nomination__c selectedNomination {get; set;}
    public Evaluation__c newEvaluation {get; set;}
    public Id trainingId {get; set;}
    public Id selectedNominationId {
        get;
        set {
            selectedNominationId = value;
        }
    }
    public Boolean isEditMode {get; set;}
    public Boolean isSaveSuccess {get; set;}
    private Map<Id, Nomination__c> nominationsIdRecordMap = new Map<Id, Nomination__c>();

    /**
     * Constructor
     * If page contains id parameter, nominations are loaded while initialization
     */
    public NominationEvaluationController() {
        trainingId = ApexPages.currentPage().getParameters().get(Constant.PARAM_ID);
        nominatedExperts = new List<Nomination__c>();
        evaluations = new List<Evaluation__c>();
        nominationCount = 0;
        evaluationCount = 0;
        isEditMode = false;
        isSaveSuccess = false;
        setDefaultOffsetLimit();
        selectedNomination = new Nomination__c();

        // Check whether page is opened from tab or training record
        if (String.isNotBlank(trainingId)) {
            loadNominations();
        } else {
            nominationForLookup = new Nomination__c();
        }
    }

    /**
     * Queries nomination object based on selected Training and populates the list of nominations
     * related to specified training
     */
    public PageReference loadNominations() {
        Boolean isTrainingChanged = false;

        // Set trainingId from the lookup variable and flag for identifying if training has changed
        if (nominationForLookup != null && nominationForLookup.Training__c != trainingId) {
            trainingId = nominationForLookup.Training__c;
            isTrainingChanged = true;
        } else if (nominationForLookup == null) {
            isTrainingChanged = true;
        }

        // Fetch nomination records related to training
        if (String.isNotBlank(trainingId) && nominationOffset >= 0) {
            nominatedExperts = [
                SELECT
                    Id,
                    Name,
                    Contact__r.JRRID__c,
                    Contact__r.Name,
                    Contact__r.Main_Profession__c,
                    Contact__r.Secondary_Profession__c,
                    Contact__r.Core_Expertise_1__c,
                    Contact__r.Core_Expertise_2__c,
                    Contact__r.Core_Expertise_3__c,
                    Contact__r.Gender__c,
                    Contact__r.Global_South__c,
                    Application_Summary__c,
                    (SELECT
                        Id
                    FROM
                        Evaluations__r
                    WHERE
                        CreatedById = :UserInfo.getUserId()
                    )
                FROM
                    Nomination__c
                WHERE
                    Training__c = :trainingId
                LIMIT
                    :nominationLimit
                OFFSET
                    :nominationOffset
            ];
            nominationsIdRecordMap = new Map<Id, Nomination__c>(nominatedExperts);
            if (isTrainingChanged) {
                nominationCount = [
                    SELECT
                        COUNT()
                    FROM
                        Nomination__c
                    WHERE
                        Training__c = :trainingId
                ];
            }
        }
        return null;
    }

    /**
     * Function called on click of a nomination record to show data related to selected nomination
     */
    public PageReference showSelectedNominationData() {
        selectedNomination = nominationsIdRecordMap.get(selectedNominationId);
        loadEvaluations();
        return null;
    }

    /**
     * Instantiates a new evaluation and toggles edit mode
     */
    public PageReference addEvaluation() {
        newEvaluation
            = new Evaluation__c(
                Nomination__c = selectedNominationId,
                RecordTypeId = RecordType_Utils.getRecordTypeId(
                    Constant.OBJECT_EVALUATION,
                    Label.Nominations_Record_Type
                )
            );
        isEditMode = true;
        isSaveSuccess = false;
        return null;
    }

    /**
     * Saves the Evaluation record to database
     */
    public PageReference saveEvaluation() {
        if (!validateRequiredFields()) {
            Utility.addPageMessage(ApexPages.Severity.ERROR, Label.All_Fields_Required_Message);
            return null;
        }
        try {
            insert newEvaluation;
            isSaveSuccess = true;
            loadNominations();
            loadEvaluations();
        } catch (DmlException dmlException) {
            Utility.addPageMessage(ApexPages.Severity.ERROR, dmlException.getMessage());
        }
        isEditMode = false;
        return null;
    }

    /**
     * Cancel returns to view mode and removes the ediatble row from table
     */
    public PageReference cancelEvaluation() {
        isEditMode = false;
        return null;
    }

    /**
     * Returns true if user has already evaluated the selected nomination
     */
    public Boolean getIsUserEvaluated() {
        Boolean isUserEvaluated = false;
        if (String.isNotBlank(selectedNominationId) &&
            nominationsIdRecordMap.containsKey(selectedNominationId)) {
            isUserEvaluated = nominationsIdRecordMap
                                .get(selectedNominationId)
                                .Evaluations__r.size() > 0;
        }
        return isUserEvaluated;
    }

    /**
     * Navigate to first page
     */
    public Void firstPage() {
        nominationOffset = Pagination_Utils.firstPage();
        loadNominations();
    }

    /**
     * Navigate to previous page
     */
    public Void previousPage() {
        nominationOffset = Pagination_Utils.previousPage(nominationOffset, nominationLimit);
        loadNominations();
    }

    /**
     * Navigate to next page
     */
    public Void nextPage() {
        nominationOffset = Pagination_Utils.nextPage(nominationOffset, nominationLimit);
        loadNominations();
    }

    /**
     * Navigate to last page
     */
    public Void lastPage() {
        nominationOffset = Pagination_Utils.lastPage(nominationLimit, nominationCount);
        loadNominations();
    }

    /**
     * Queries Evaluation object based on selected nomination
     */
    private Void loadEvaluations() {
        if (String.isNotBlank(selectedNominationId)) {
            evaluations = [
                SELECT
                    Id,
                    CreatedBy.Name,
                    CreatedById,
                    Name,
                    Overall_Evaluation__c,
                    Overall_Comments__c
                FROM
                    Evaluation__c
                WHERE
                    Nomination__c = :selectedNominationId
            ];
            evaluationCount = evaluations.size();
            isEditMode = false;
        }
    }

    /**
     * Validates required fields for Evaluation
     */
    private Boolean validateRequiredFields() {
        Boolean isValid = true;
        if (String.isBlank(newEvaluation.Overall_Comments__c) ||
            String.isBlank(newEvaluation.Overall_Evaluation__c)) {
                isValid = false;
        }
        return isValid;
    }

    /**
     * Sets default values for offset and limit
     */
    private Void setDefaultOffsetLimit() {
        nominationOffset = 0;
        nominationLimit = Integer.valueOf(System.Label.Nomination_Record_Limit);
    }

}