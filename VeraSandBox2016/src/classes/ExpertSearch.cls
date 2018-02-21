/**
* Class : Expert Search for position
* Author : Ashwini kr singh
---------------------------------------------------------------------------------------------------
* Description: Allow user to search and select eligible experts(Contacts) for:
*                                   1.Specified position.
*                                   2.Generic eligibility.
*              based on dynamic filter criteria with help of profile records and catalogue.
---------------------------------------------------------------------------------------------------
* Version History:  Name                   Dates                                 Comments
* 1.0               Ashwini kr. Singh      13/apr/2016 to 28/apr/2016            Initial Draft
*/

public with sharing class ExpertSearch {
    private static final String CALLER_DEFAULT_VALUE = 'all';
    private static final String SEARCH = 'Search';
    private static final String SELECTED = 'Selected';
    private static final String CONTACTFIELDS
        = String.join(
            SObject_Utils.getObjectFieldNames('Expert_Search', Constant.OBJECT_CONTACT),
            Constant.COMMA
        );
    private static final Integer DEFAULT_OFFSET_LIMIT =
        PaginationLimits__c.getValues('Default Offset Limit').value__c.intValue();
    private static final Integer SEARCH_EXPERT_LIMIT =
        PaginationLimits__c.getValues('Search Expert Limit').value__c.intValue();
    private static final Integer SELECTED_EXPERT_LIMIT =
        PaginationLimits__c.getValues('Selected Expert Limit').value__c.intValue();

    /**
     * Map of Contact with Ids to trace selected eligible expert but with/without deployment plans
     */
    public List<WrapFilterResult> filterResults {get; set;}
    public List<WrapExpertDeployment> selectedExperts {get; set;}
    public Position__c position {get; set;}
    public String filters {get; set;}
    public String contactSearchFilters {get; set;}
    public String positionFiltersApplied {get; set;}
    public Integer limitFilteredExpert {get; set;}
    public Integer offsetFilteredExpert {get; set;}
    public Integer limitSelectedExpert {get; set;}
    public Integer offsetSelectedExpert {get; set;}
    public Integer searchCriteriaRecordCount {get; set;}
    public Integer selectedRecordCount {get; set;}
    public Integer eligibleExpertCount {get; set;}
    /**
     * To catch the passing parameter from table from command buttons
     */
    public String caller {
        get;
        set {
            caller = value;
        }
    }

    private List<Deployment__c> deployments;
    private Set<Id> expertIdsFromProfileRecords;
    private Set<Id> alreadySelectedExpertIds;
    private Map<Id, Contact> eligibleExperts;
    private Map<Id, String> catalogProfileRecordTypeHolder;
    private Map<Id, Set<Id>> catalogContactIdsHolder;
    private Map<Id, Double> catalogLanguageLevelHolder;
    private Boolean globalSouthExists;
    private Id positionId = ApexPages.currentPage().getParameters().get(Constant.ID);

    public ExpertSearch() {
        limitFilteredExpert = SEARCH_EXPERT_LIMIT;
        offsetFilteredExpert = 0;
        limitSelectedExpert = SELECTED_EXPERT_LIMIT;
        offsetSelectedExpert = 0;
        filterResults = new List<WrapFilterResult>();
        eligibleExperts = new Map<id,Contact>();
        selectedExperts = new List<WrapExpertDeployment>();
        eligibleExpertCount = 0;
        alreadySelectedExpertIds = new Set<Id>();
        position = new Position__c();
        searchCriteriaRecordCount = 0;
        selectedRecordCount = 0;
        caller = CALLER_DEFAULT_VALUE;
    }

    /**
     * Initializing function after Dom load of page
     */
    public Void init() {
        position = new Position__c();
        if (positionId != null) {
            selectedContacts();
            List<List<String>> positionFiltersPopulated = FilterCriteria.populateFilter(position);
            positionFiltersApplied = JSON.serialize(positionFiltersPopulated);
            addAndRemoveContactFiters();
        }
    }

    /**
     * Query on the position to get the record of position object on the basis of passed Id
     */
    public Position__c getPosition(Id positionId) {
        return Position_Domain.getPositionforExpertSearch(positionId);
    }

    /**
     * To poulate the list of WrapExpertDeployment if position is selected
     */
    public Void selectedContacts() {
        selectedExperts = new List<WrapExpertDeployment>();
        if (positionId != null) {
                position = getPosition(positionId);
            if (position != null) {
                Map<Id, Deployment__c> deploys = new Map<Id, Deployment__c>();
                for (Deployment__c deploy:position.Deployments__r) {
                    alreadySelectedExpertIds.add(deploy.Expert__c);
                    deploys.put(deploy.Expert__c, deploy);
                }
                selectedRecordCount = alreadySelectedExpertIds.size();
                String alreadySelectedExperts = Utility.SetToString(alreadySelectedExpertIds);
                String filters = Constant.WHITE_SPACE + Constant.ID + Constant.WHITE_SPACE
                                    +'in ' + alreadySelectedExperts;
                String selectedQuery = Query_Utils.queryBuilder(
                                           Constant.OBJECT_CONTACT,
                                           CONTACTFIELDS,
                                           filters,
                                           Constant.SORTEXPRESSIONC,
                                           limitSelectedExpert,
                                           offsetSelectedExpert
                                       );
                for (sObject selectedContact: Query_Utils.fetchRecords(selectedQuery)) {
                    selectedExperts.add(
                        new WrapExpertDeployment(
                            (Contact)selectedContact,
                            deploys.get((Id)selectedContact.get(Constant.ID))
                        )
                    );
                }
            }
        }
    }

    /**
     * Calling filters when position filters are there or after search button is clicked.
     * getting all the filters from page and spliting it in list of list String
     * Innerlist is segregated from level to level
     * Outerlist contains fiters and list of their respective levels.
     */
    public Void addAndRemoveContactFiters() {
        //catalogIds = new set<Id>();
        catalogContactIdsHolder = new Map<Id, Set<Id>>();
        catalogProfileRecordTypeHolder = new Map<Id, String>();
        catalogLanguageLevelHolder = new Map<Id, Double>();
        globalSouthExists = false;
        contactSearchFilters = ' Training_Status__c  IN (\'CERT\',\'TB-CERT\')';
        contactSearchFilters += ' AND Roster_Status__c = \'O\' ';
        contactSearchFilters += ' AND RecordType.DeveloperName = \''+ System.Label.Contact_Expert + '\'';
        Type listType = Type.forName('List<List<String>>');
        if (positionFiltersApplied != null) {
            List<List<String>> filtersList =
                (List<List<String>>)JSON.deserialize(positionFiltersApplied, listType);
            for (List<String> filterLevel : filtersList) {
                applyFilter(filterLevel);
            }
        }
        if(!catalogContactIdsHolder.isEmpty()) {
            addProfileRecordFilters();
        }
        searchContact();
    }

    /**
     * Checking and adding filters to contact search for following list
     * Profession,
     * Characteristics,
     * Core Expertise,
     * Area of Expertise,
     * Nationality,
     * Country Expertise,
     * Language,
     * Legal Systems
     *
     * @param profileFilter as String the filter criteria
     *
     * @return where clause for profile records
     */
    public String profileSearchFilter(String profileFilter) {
        String profileQuery = Query_Utils.queryBuilder(
                                 Constant.OBJECT_PROFILE_RECORD,
                                 Constant.FIELD_EXPERTC,
                                 profileFilter,
                                 null,
                                 null,
                                 null
                               );
        return (SearchFilter_Utils.addFilters(
                   Constant.ID,
                   Constant.INC,
                   profileQuery,
                   Constant.ANDC,
                   Constant.BRACKET_START + Constant.BRACKET_END)
                );
    }

    /**
     * On the basis of passed filter this function creates the WHERE clause for contact
     * @param filterLevel as List<String> whic holds the filter
     */
    public Void applyFilter(List<String> filterLevel) {
        String profileQuery = '';
        String profileFilter = '';
        if (filterLevel[0] == Constant.PROFESSION && filterLevel[2] != null ) {
            contactSearchFilters += SearchFilter_Utils.addFilters(
                Constant.FIELD_MAIN_PROFFESSION,
                Constant.EQUALC,
                Constant.ESCAPE_SINGLE_QUOTE + filterLevel[2] + Constant.ESCAPE_SINGLE_QUOTE,
                Constant.ANDC,
                Constant.BRACKET_START
            );
            contactSearchFilters +=  SearchFilter_Utils.addFilters(
                Constant.FIELD_SECONDARY_PROFFESSION,
                Constant.EQUALC,
                Constant.ESCAPE_SINGLE_QUOTE + filterLevel[2] + Constant.ESCAPE_SINGLE_QUOTE,
                Constant.ORC,
                Constant.BRACKET_END
            );
        } else if (filterLevel[0] == Constant.CHARACTERITICS && filterLevel[2] != null ) {
            if (filterLevel[1] == Constant.GENDER) {
                    contactSearchFilters += SearchFilter_Utils.addFilters(
                        Constant.FIELD_GENDER,
                        Constant.EQUALC,
                        Constant.ESCAPE_SINGLE_QUOTE + filterLevel[2] + Constant.ESCAPE_SINGLE_QUOTE,
                        Constant.ANDC,
                        ''
                    );
            } else if (filterLevel[1] == Constant.GLOBAL_SOUTH && !globalSouthExists) {
                profileFilter = SearchFilter_Utils.addFilters(
                    Constant.FIELD_GLOBAL_SOUTH,
                    Constant.EQUALC,
                    Constant.TRUEC,
                    '',
                    ''
                 );
                profileFilter += SearchFilter_Utils.addFilters(
                    Constant.FIELD_RT_DEV_NAME,
                    Constant.EQUALC,
                    Constant.ESCAPE_SINGLE_QUOTE +Constant.NATIONALITY_RECORD_TYPE + Constant.ESCAPE_SINGLE_QUOTE,
                    Constant.ANDC,
                    ''
                );
                contactSearchFilters += profileSearchFilter(profileFilter);
                globalSouthExists = true;
            } else if (filterLevel[1] == Constant.SENIORITY) {
                contactSearchFilters +=SearchFilter_Utils.addFilters(
                    Constant.FIELD_SENIORITY,
                    Constant.EQUALC,
                    Constant.ESCAPE_SINGLE_QUOTE + filterLevel[2] + Constant.ESCAPE_SINGLE_QUOTE,
                    Constant.ANDC,
                    ''
                );
            } else if (filterLevel[1] == Constant.SUB_ROSTER) {
                if (filterLevel[2] == 'SGBV') {
                    contactSearchFilters += SearchFilter_Utils.addFilters(
                        Constant.FIELD_SGBV,
                        Constant.EQUALC,
                        Constant.TRUEC,
                        Constant.ANDC,
                        ''
                    );
                } else if (filterLevel[2] == 'CVIC') {
                    contactSearchFilters += SearchFilter_Utils.addFilters(
                        Constant.FIELD_CVIC,
                        Constant.EQUALC,
                        Constant.TRUEC,
                        Constant.ANDC,
                        ''
                    );
                } else if (filterLevel[2] == 'FOR') {
                    contactSearchFilters += SearchFilter_Utils.addFilters(
                        Constant.FIELD_FOR,
                        Constant.EQUALC,
                        Constant.TRUEC,
                        Constant.ANDC,
                        ''
                    );
                } else if (filterLevel[2] == 'FIAR') {
                    contactSearchFilters += SearchFilter_Utils.addFilters(
                        Constant.FIELD_FIAR,
                        Constant.EQUALC,
                        Constant.TRUEC,
                        Constant.ANDC,
                        ''
                    );
                }
            }
        } else if (filterLevel[0] == Constant.CORE_EXPERTISE && filterLevel[2] != null ) {
            contactSearchFilters += SearchFilter_Utils.addFilters(
                Constant.FIELD_CORE_EXPERTISE_1,
                Constant.EQUALC,
                Constant.ESCAPE_SINGLE_QUOTE + filterLevel[2] + Constant.ESCAPE_SINGLE_QUOTE,
                Constant.ANDC,
                Constant.BRACKET_START
            );
            contactSearchFilters += SearchFilter_Utils.addFilters(
                Constant.FIELD_CORE_EXPERTISE_2,
                Constant.EQUALC,
                Constant.ESCAPE_SINGLE_QUOTE + filterLevel[2] + Constant.ESCAPE_SINGLE_QUOTE,
                Constant.ORC,
                ''
            );
            contactSearchFilters += SearchFilter_Utils.addFilters(
                Constant.FIELD_CORE_EXPERTISE_3,
                Constant.EQUALC,
                Constant.ESCAPE_SINGLE_QUOTE + filterLevel[2] + Constant.ESCAPE_SINGLE_QUOTE,
                Constant.ORC,
                Constant.BRACKET_END
            );
        } else if (filterLevel[0] == Constant.AREA_OF_EXPERTISE && filterLevel[2] != null) {
            catalogContactIdsHolder.put(filterLevel[2], null);
        } else if (filterLevel[0] == Constant.NATIONALITY && filterLevel[2] != null) {
            catalogProfileRecordTypeHolder.put(
                filterLevel[2],
                Constant.NATIONALITY_RECORD_TYPE
            );
        } else if (filterLevel[0] == Constant.COUNTRY_EXPERTISE && filterLevel[2] != null) {
           catalogProfileRecordTypeHolder.put(
                filterLevel[2],
                Constant.COUNTRY_EXPERTISE_RECORD_TYPE
           );
        } else if (filterLevel[0] == Constant.LANGUAGE &&
            filterLevel[2] != null &&
            filterLevel[3] != null
          ) {
           catalogLanguageLevelHolder.put(
                filterLevel[2],
                Utility.generalLevelNumber.get(filterLevel[3])
            );
           catalogContactIdsHolder.put(filterLevel[2], null);
        } else if (filterLevel[0] == Constant.LEGAL_SYSTEMS && filterLevel[1] != null) {
            catalogContactIdsHolder.put(filterLevel[1], null);
        }
    }

    /**
     * Method to create profile record filters for search based on Catalog,
     * This method extracts set of common experts who fulfill all the profile criteria
     * mentioned in the filters based on Profile Records apart from GLobal South.
     */
    private Void addProfileRecordFilters() {
        Set<Id> expertIds = new Set<Id>();
        for (Catalog__c catalog : [
                                    SELECT
                                        Id,
                                        (
                                            SELECT
                                                Expert__c,
                                                RecordType.DeveloperName,
                                                Language_Level_Number__c
                                            FROM
                                                Profile_Record__r
                                        )
                                    FROM
                                        Catalog__c
                                    WHERE
                                        Id IN :catalogContactIdsHolder.keySet()
                                 ]
        ) {
            expertIds = new Set<Id>();
            for (Profile_Record__c profileRecord : catalog.Profile_Record__r) {
                if (catalogProfileRecordTypeHolder.containsKey(catalog.Id)) {
                    if (profileRecord.Expert__c != null &&
                        catalogProfileRecordTypeHolder.get(catalog.Id) ==
                            profileRecord.RecordType.DeveloperName)
                    {
                        expertIds.add(profileRecord.Expert__c);
                    }
                } else if (catalogLanguageLevelHolder.containsKey(catalog.Id)) {
                    if (profileRecord.Expert__c != null &&
                        catalogLanguageLevelHolder.get(catalog.Id)
                            <= profileRecord.Language_Level_Number__c)
                    {
                        expertIds.add(profileRecord.Expert__c);
                    }
                } else if (profileRecord.Expert__c != null) {
                    expertIds.add(profileRecord.Expert__c);
                }
            }
            catalogContactIdsHolder.put(catalog.Id, expertIds);
        }
        expertIdsFromProfileRecords =  new Set<Id>();
        for (Set<Id> expertIdSet : catalogContactIdsHolder.values()) {
            if (expertIdSet.isEmpty()) {
                expertIdsFromProfileRecords =  new Set<Id>();
                break;
            }
            if (expertIdsFromProfileRecords.isEmpty()) {
                expertIdsFromProfileRecords.addAll(expertIdSet);
            } else {
                expertIdsFromProfileRecords.retainAll(expertIdSet);
            }
        }
        String expertIdsFromProfile = Utility.SetToString(expertIdsFromProfileRecords);
        contactSearchFilters += SearchFilter_Utils.addFilters(
            Constant.ID,
            Constant.INC,
            expertIdsFromProfile,
            Constant.ANDC,
            ''
        );
    }

    /**
     * On click of search  it will apply all the filters and search the contacts accordingly
     */
    public PageReference searchContact() {
        filterResults = new List<WrapFilterResult>();
        String alreadySelectedExperts = Utility.SetToString(alreadySelectedExpertIds);
        contactSearchFilters += ' AND Id NOT IN ' + alreadySelectedExperts;
        String filters = contactSearchFilters;
        String countQuery = Query_Utils.queryBuilder(
                                Constant.OBJECT_CONTACT,
                                Constant.COUNT_FUNCTION,
                                filters,
                                null,
                                null,
                                null
                            );
         system.debug(countQuery);
        searchCriteriaRecordCount = Query_Utils.searchRecordCount(countQuery);
        if (searchCriteriaRecordCount > DEFAULT_OFFSET_LIMIT) {
            ApexPages.addmessage(new Apexpages.Message(
                                    ApexPages.Severity.Info,
                                    System.Label.Record_Overflow_Warning
                                ));
        }
        String searchQuery = Query_Utils.queryBuilder(
                                 Constant.OBJECT_CONTACT,
                                 CONTACTFIELDS,
                                 filters,
                                 Constant.SORTEXPRESSIONC,
                                 limitFilteredExpert,
                                 offsetFilteredExpert
                             );
        for (sObject filteredContact: Query_Utils.fetchRecords(searchQuery)) {
            Boolean eligibleExpert = eligibleExperts.containsKey((Id)filteredContact.get(Constant.ID));
            filterResults.add(new WrapFilterResult((Contact)filteredContact, eligibleExpert));
        }
        return null;
    }

    /**
     * Confirm experts is called on click of conifirm button and it passes all the eligible experts
     * in Selected experts.
     */
    public PageReference confirmExperts() {
        saveRemoveExpert();
        for (Id eligibleExpertId : eligibleExperts.keySet()) {
            alreadySelectedExpertIds.add(eligibleExpertId);
        }
        selectedRecordCount = alreadySelectedExpertIds.size();
        eligibleExperts.clear();
        eligibleExpertCount = 0;
        caller = CALLER_DEFAULT_VALUE;
        searchContact();
        selectedContacts();
        return null;
    }

    /**
     * Delete the deployment record for selected expert for related position
     */
    public PageReference deleteExpertDeployment() {
        Id expertToBeRemoved = Apexpages.currentPage().getParameters().get('expertIdtoRemove');
        List<Deployment__c> deploymentsToBeDeleted = new List<Deployment__c>();
        for (WrapExpertDeployment selectedExpert : selectedExperts) {
            if (selectedExpert.expert.id == expertToBeRemoved) {
                if (selectedexpert.deployment != null) {
                    deploymentsToBeDeleted.add(selectedexpert.deployment);
                }
            }
            for (Id expertId :alreadySelectedExpertIds) {
                if (expertId == expertToBeRemoved) {
                    alreadySelectedExpertIds.remove(expertId);
                }
            }
        }
        if (!deploymentsToBeDeleted.isEmpty()) {
            try {
                delete deploymentsToBeDeleted;
            } catch(DMLException e) {
                ApexPages.addmessage(new Apexpages.Message(
                                            ApexPages.Severity.Info,
                                            e.getMessage()
                                    ));
            }
        }
        caller = CALLER_DEFAULT_VALUE;
        callFirst();
        return null;
    }

    /**
     * Create deployment for all the experts who are confirmed for the position
     * populate Expert as contact
     *          Position and Mission from Position__c object
     *          Status as search
     */
    public PageReference saveSelectedExpertDeployment() {
        deployments = new List<Deployment__c>();
        for (WrapExpertDeployment selectedExpert : selectedExperts) {
            if (selectedExpert.deployment == null) {
                Deployment__c deployment = new Deployment__c();
                deployment.Expert__c = selectedExpert.expert.id;
                deployment.Position__c = position.id ;
                deployment.Mission__c = position.Mission__c;
                deployment.Status__c = System.Label.Default_Deployment_status;
                deployments.add(deployment);
                selectedExpert.deployment = deployment;
            }
        }
        if (!deployments.isEmpty()) {
            try {
                insert deployments;
            } catch(DMLException e) {
                Utility.addPageMessage(ApexPages.Severity.Error, e.getMessage());
            }
        }
        searchContact();
        selectedContacts();
        return null;
    }

    /**
     * functions for pagination: CallFirst
     *
     * @param caller= to identify the calling table
     */
    public Void callFirst() {
        if (caller != SELECTED) {
            offsetFilteredExpert = Pagination_Utils.firstPage();
            saveRemoveExpert();
            searchContact();
        }
        if (caller != SEARCH) {
            offsetSelectedExpert = Pagination_Utils.firstPage();
            selectedContacts();
        }
    }

    /**
     * functions for pagination: CallLast
     *
     * @param caller= to identify the calling table
     *
     */
    public Void callLast() {
        if (caller == SEARCH ) {
            saveRemoveExpert();
            if (searchCriteriaRecordCount < DEFAULT_OFFSET_LIMIT) {
                offsetFilteredExpert = Pagination_Utils.lastPage(
                    limitFilteredExpert,
                    searchCriteriaRecordCount
                );
            } else {
                offsetFilteredExpert = (DEFAULT_OFFSET_LIMIT - limitFilteredExpert);
            }
            searchContact();
        } else if (caller == SELECTED) {
            if (selectedRecordCount < DEFAULT_OFFSET_LIMIT) {
                offsetSelectedExpert = Pagination_Utils.lastPage(
                    limitSelectedExpert,
                    selectedRecordCount
                );
            } else {
                offsetSelectedExpert = (DEFAULT_OFFSET_LIMIT - limitSelectedExpert);
            }
            selectedContacts();
        }
    }

    /**
     * functions for pagination: CallPrevious
     *
     * @param caller= to identify the calling table
     *
     */
    public Void callPrevious() {
        if (caller == SEARCH ) {
            saveRemoveExpert();
            offsetFilteredExpert = Pagination_Utils.previousPage(offsetFilteredExpert, limitFilteredExpert);
            searchContact();
        } else if (caller == SELECTED) {
            offsetSelectedExpert = Pagination_Utils.previousPage(offsetSelectedExpert, limitSelectedExpert);
            selectedContacts();
        }
    }

    /**
     * functions for pagination: CallNext
     *
     * @param caller= to identify the calling table
     *
     */
    public Void callNext() {
         if (caller == SEARCH ) {
            saveRemoveExpert();
            offsetFilteredExpert = Pagination_Utils.nextPage(offsetFilteredExpert, limitFilteredExpert);
            searchContact();
        } else if (caller == SELECTED) {
            offsetSelectedExpert = Pagination_Utils.nextPage(offsetSelectedExpert, limitSelectedExpert);
            selectedContacts();
        }
    }

    /**
     * Function would be called from filter on Expert search page and will return the list of
     * select options selected for different level on the basis of passed paramateter
     *
     * @param level as string for getting level of the filter.
     * @param value as string to get the selected value.
     * @param searchFiltername to get the level1 value as custom setting is depending on that.
     *
     * @value returns positionSelectOptions as object for label and value,
     *  to provide picklist options of nextlevel
     */
    @RemoteAction
    public Static List<PositionSelectOption> getFilterValues(
        String level,
        String value,
        String searchFilterName
    ) {
        List<PositionSelectOption> positionSelectOptions = new List<PositionSelectOption>();
        Integer filterLevel = integer.valueof(level);
        if (filterLevel == 1) {
            positionSelectOptions = FilterCriteria.getLevel1Values();
        } else if (filterLevel == 2){
           positionSelectOptions = FilterCriteria.getLevelValues(value, level, searchFilterName);
        } else if (filterLevel == 3) {
           positionSelectOptions = FilterCriteria.getLevelValues(value, level, searchFilterName);
        } else if (filterLevel == 4) {
           positionSelectOptions = FilterCriteria.getLevelValues(value, level, searchFilterName);
        }
        return positionSelectOptions;
    }

    /**
     * Note : Call this function prior to any action function saving the selected record in Map
     *       for all the later use until experts are confirmed
     * This function populates Map of all eligible experts
     */
    public Void saveRemoveExpert() {
       for (WrapFilterResult eligibleExpert : filterResults) {
            if (eligibleExpert.isSelected) {
                eligibleExperts.put(eligibleExpert.expert.id, eligibleExpert.expert);
            } else if (eligibleExperts.containsKey(eligibleExpert.expert.id)) {
                eligibleExperts.remove(eligibleExpert.expert.id);
            }
            eligibleExpertCount = eligibleExperts.size();
       }
    }

    /**
     * Wrapper class for searched expert(contact)
     */
    public class WrapFilterResult {
        public Contact expert {get; set;}
        public Boolean isSelected {get; set;}
        public WrapFilterResult(Contact expert, Boolean isSelected) {
            this.expert = expert;
            this.isSelected = isSelected;
        }
    }

    /**
     * wrapper class for selected expert(contact)
     */
    public class WrapExpertDeployment {
        public Contact expert {get; set;}
        public Deployment__c deployment {get; set;}
        public WrapExpertDeployment(Contact expert, Deployment__c deployment) {
            this.expert = expert;
            this.deployment = deployment;
        }
    }
}