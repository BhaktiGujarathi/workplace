/**
* VF : Expert Search Filters for position
* Author : Ashwini kr singh
---------------------------------------------------------------------------------------------------
* Description: Allow user to add/update the filters for experts(Contacts) for:
*                                   1.Set and edit filters using remote action.
*                                   2.Fetch records/picklist values and other costant values.
*                                   3.Criterias are driven by custom setting (Expert Search Filter).
*              based on dynamic filter criteria with help of profile records and catalogue.
---------------------------------------------------------------------------------------------------
* Version History:  Name                   Dates                                 Comments
* 1.0               Ashwini kr. Singh      19/apr/2016 to 26/apr/2016            Initial Draft
*/

public with sharing class FilterCriteria {

    private static final List<ExpertSearchPositionFilters__c> searchFilters =
        ExpertSearchPositionFilters__c.getAll().values();
    private static final List<ExpertSearchPopulateFilters__c> positionFilters=
        ExpertSearchPopulateFilters__c.getAll().values();

    /**
     * Populate filters in case position object is populated
     * @param position as sObject Position__c
     *
     * @return List<List<String>> which will contain prepopulated filters
     */
    public static List<List<String>> populateFilter(Position__c position) {
        List<List<String>> filters = new List<List<String>>();
        for (ExpertSearchPopulateFilters__c positionFilter : positionFilters) {
            List<String> currentFilter = new List<String>();
            if (!positionFilter.Name.contains(Constant.PROFILERECORDFILTER) &&
                position.get(positionFilter.Name) != null &&
                position.get(positionFilter.Name) != false) {
                for (Integer i=1; i<=4; i++) {
                    String criteriaType = getValueFromSetting(
                        Utility.positionFilterCriteriaType,
                        String.valueOf(i),
                        positionFilter
                    );
                    String criteria = getValueFromSetting(
                        Utility.positionFilterCriteria,
                        String.valueOf(i),
                        positionFilter
                    );
                    String getLevelValue = getPreSelectedPositionValues(
                        String.valueOf(i),
                        criteriaType,
                        criteria,
                        position
                    );
                    if (String.isNotBlank(getLevelValue)) {
                        currentFilter.add(getLevelValue);
                    }
                }
            }
            if (!currentFilter.isEmpty()) {
               filters.add(currentFilter);
            }
        }
        filters.addAll(populateProfileBasedFilter(position.Expertise__r));
        return filters;
    }

    public static List<List<String>> populateProfileBasedFilter(
        List<Profile_Record__c> profileRecords
    ) {
        List<List<String>> filters = new List<List<String>>();
        Map<String, ExpertSearchPopulateFilters__c> prepopulateConditions
            = new Map<String, ExpertSearchPopulateFilters__c>();
        for (ExpertSearchPopulateFilters__c filter : positionFilters) {
            if(filter.Name.contains(Constant.PROFILERECORDFILTER)) {
                prepopulateConditions.put(filter.Name.substringBefore(' PR'), filter);
            }
        }
        for (Profile_Record__c profileRecord : profileRecords) {
            List<String> currentFilter = new List<String>();
            ExpertSearchPopulateFilters__c profileFilter
                = prepopulateConditions.get(profileRecord.RecordType.DeveloperName);
            for (Integer i=1; i<=4; i++) {
                String criteriaType = getValueFromSetting(
                    Utility.positionFilterCriteriaType,
                    String.valueOf(i),
                    profileFilter
                );
                String criteria = getValueFromSetting(
                    Utility.positionFilterCriteria,
                    String.valueOf(i),
                    profileFilter
                );
                String getLevelValue = getPreSelectedPositionValues(
                    String.valueOf(i),
                    criteriaType,
                    criteria,
                    profileRecord
                );
                if (String.isNotBlank(getLevelValue)) {
                    currentFilter.add(getLevelValue);
                }
            }
            filters.add(currentFilter);
        }
        return filters;
    }

    /*
     * Logic to get selected value of particular filter on basis of passed position
     * @param level as string defines filter level
     * @param criteriaType as string defining criteria type if null no value is returned
     * @param criteria as string the real criteria
     *
     * @return String the filtered value
    */
    private static String getPreSelectedPositionValues(
        String Level,
        String criteriaType,
        String criteria ,
        sObject position
    ) {
      String filteredValue = '';
        if (criteriaType == null) {
            filteredValue ='';
        } else if (criteriaType == Constant.CONSTANTC) {
            filteredValue = criteria;
        } else if (criteriaType == Constant.APIFIELDNAME) {
            if (criteria.contains('.')) {
                List<String> criteriaBreak = criteria.split('\\.');
                filteredValue = (String)position.getsObject(criteriaBreak[0]).get(criteriaBreak[1]);
            } else {
                filteredValue = (String)position.get(Criteria);
            }
        }
        return filteredValue;
    }

    /**
     * Used to convert level 1 values to select option from custom setting
     * @return list of select option
     */
    public static List<PositionSelectOption> getLevel1Values() {
        List<PositionSelectOption> level1PositionSelectOptions = new List<PositionSelectOption>();
        if (!searchfilters.isEmpty()) {
            for (ExpertSearchPositionFilters__c searchFilter : searchFilters) {
                level1PositionSelectOptions.add(
                    new PositionSelectOption(searchFilter.Name, searchFilter.name)
                );
            }
        }
        return level1PositionSelectOptions;
    }

    /**
     * Used to convert picklist values to select option
     * @param objectName as string for name of base object
     * @param criteria string name of picklist value
     *
     * @return list of select option
     */
    private static List<PositionSelectOption> getPicklistValue(String objectName, String criteria) {
        List<PositionSelectOption> picklistValuesFilter = new List<PositionSelectOption>();
        if (String.isNotBlank(objectName) && String.isNotBlank(Criteria)) {
            Schema.DescribeSObjectResult objDescribe = SObject_Utils.getSobjectDescribe(objectName);
            Map<String, Schema.SObjectField> objectFields = objDescribe.fields.getMap();
            Schema.DescribeFieldResult picklistField = objectFields.get(criteria).getDescribe();
            List<Schema.Picklistentry> picklistEntries = pickListField.getPickListValues();
            for (Schema.Picklistentry picklistEntry : picklistEntries) {
                picklistValuesFilter.add(new PositionSelectOption (picklistEntry.getValue(),
                picklistEntry.getValue()));
            }
        }
        return picklistValuesFilter;
    }

    /**
     * Used to convert object records to select option by creating query and fetching the records
     * @param objectName as string for name of base object
     * @param criteria string name of picklist value
     * @param value value on which next level filter is build
     *
     * @return list of select option
     */
    private static List<PositionSelectOption> getrecordValues(
        String objectname,
        String criteria,
        String value
    ) {
        String fieldName = Constant.ID + Constant.COMMA + Constant.NAME ;
        List<PositionSelectOption> recordValues = new List<PositionSelectOption>();
        if (!criteria.contains(Constant.EQUALC)) {
            criteria = criteria
                       + Constant.WHITE_SPACE
                       + Constant.EQUALC
                       + Constant.WHITE_SPACE
                       + Constant.ESCAPE_SINGLE_QUOTE
                       + value
                       + Constant.ESCAPE_SINGLE_QUOTE;
         }
        String query = Query_Utils.queryBuilder(
                           objectname,
                           fieldName,
                           criteria,
                           Constant.SORTEXPRESSIONC,
                           null,
                           null
                       );
        for(sObject recordValue : fetchRecords(query)) {
            recordValues.add(new PositionSelectOption(
                (String)recordValue.get(Constant.NAME),
                (String)recordValue.get(Constant.ID)
            ));
        }
        return recordValues;
    }

    /**
     * Used to fetch records from passed query
     * sometimes uses sets and all so need to be in scope of class
     * @param query  as string
     *
     * @return list of record
     */
    private static List<sObject> fetchRecords(String query) {
        return Database.query(query);
    }

    /**
     * Used to convert object records to select option
     * @param criteria string value in csv format
     *
     * @return list of select option
     */
    private static List<PositionSelectOption> getConstantValues(String criteria) {
        List<PositionSelectOption> constantFilters = new List<PositionSelectOption>();
        for (String constantValue : criteria.split(',')) {
            constantFilters.add(new PositionSelectOption(constantValue, constantValue));
        }
        return constantFilters;
    }

    /**
     * Used to get select option in case nothing fits into criteria
     * @param value as string for value of retrived result
     * @param level as string the level of filter
     *
     * @return list of select option
     */
    private static List<PositionSelectOption> getExceptionalFilter(
        String level,
        String value,
        String objectName
    ) {
        value = value.trim();
        List<PositionSelectOption> levelFilter = new List<PositionSelectOption>();
        if (value == System.Label.JRRLang) {
            levelFilter = getrecordValues(objectName, System.Label.JRRLangCriteria, null);
        } else if (value == System.Label.OtherLang) {
           levelFilter = getrecordValues(objectName, System.Label.OtherLangCriteria, null);
        } else if (value == System.Label.Gender) {
            levelFilter = getPicklistValue(objectName, System.Label.GenderCriteria);
        } else if (value == System.Label.GlobalSouth) {
            levelFilter = getConstantValues(System.Label.GlobalSouthCriteria);
        } else if (value == System.Label.Seniority) {
            levelFilter = getPicklistValue(objectName, System.Label.SeniorityCriteria);
        } else if (value == System.Label.SubRoster) {
            levelFilter = getConstantValues(System.Label.SubRosterCriteria);
        }
        return levelFilter;
    }

    /**
     * fetches value from utility map and set the value from  respective field according to level
     * utility map of level and fieldname
     *                                   1 positionFilterCriteriaType
     *                                   2 positionFilterCriteria
     *                                   3 positionFilterCriteriaObject
     * @param map of field selector as string(level)
     * @param searhFilter as sObject (custom setting) name of custom setting
     * @param level as string to know the level of filter
     *
     * @return name of field
     */
    private static String getValueFromSetting(
        Map<String,String> fieldSelector,
        String level,
        sObject searchFilter
    ) {
        String fieldValue = (String)searchFilter.get(fieldSelector.get(level));
        return fieldValue;
    }

    /*
    * Used to get select option by segregating types on base of critria type and level
    * @param value as string for value of retrived result
    * @param level as string the level of filter
    * @param searchFiltername defining the base for filterto identify row of custom setting
    *
    * @return list of select option
    */
    public static List<PositionSelectOption> getLevelValues(
        String value,
        String level,
        String searchFilterName
    ) {
        List<PositionSelectOption> levelFilter = new List<PositionSelectOption>();
        if (!searchfilters.isEmpty() && String.isNotBlank(value)) {
            for (ExpertSearchPositionFilters__c searchFilter : searchFilters) {
                if (searchfilter.Name == searchFilterName) {
                    String criteriaType = getValueFromSetting(
                                            Utility.positionFilterCriteriaType,
                                            level,
                                            searchfilter
                                         );
                    String criteria = getValueFromSetting(
                                        Utility.positionFilterCriteria,
                                        level,
                                        searchfilter
                                      );
                    String objectName = getValueFromSetting(
                                           Utility.positionFilterCriteriaObject,
                                           level,
                                           searchfilter
                                        );
                    if (criteriaType == null) {
                        levelFilter.add(
                            new PositionSelectOption(Constant.LAST_LEVEL, Constant.LAST_LEVEL)
                            );
                        break;
                    } else if (criteriaType == Constant.PICKLISTC) {
                        levelFilter = getPickListValue(objectName, criteria);
                    } else if (criteriaType == Constant.OBJECTC) {
                        levelFilter = getrecordValues(objectName, criteria, value);
                    } else if (criteriaType == Constant.CONSTANTC) {
                        levelFilter = getConstantValues(criteria);
                    } else if (criteriaType == Constant.EXEPTIONALFILTERC) {
                        levelFilter = getExceptionalFilter(level, value, objectName);
                    }
                    break;
                }
            }
        }
        return levelFilter;
    }
}