/***********************************************************************************
 * Class : Utility
 * Created By : Ashwini Singh
 -----------------------------------------------------------------------------------
 * Description : Utility class provides various reusable methods
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ashwini Singh     20/04/2016    Initial Development
 **********************************************************************************/
public with sharing class Utility {

    /**
     * Utility map of level and fieldname
     * positionFilterCriteriaType for criteria type and level
     * positionFilterCriteria for criteria and level
     * positionFilterCriteriaObject for object and level
     */
    public static Map<String, String> positionFilterCriteriaType = new Map<String, String> {
        '1' => 'Level_1_Criteria_Type__c',
        '2' => 'Level_2_Criteria_Type__c',
        '3' => 'Level_3_Criteria_Type__c',
        '4' => 'Level_4_Criteria_Type__c'
    };

    public static Map<String, String> positionFilterCriteria = new Map<String, String> {
        '1' => 'Level_1_Criteria__c',
        '2' => 'Level_2_Criteria__c',
        '3' => 'Level_3_Criteria__c',
        '4' => 'Level_4_Criteria__c'
    };

    public static Map<String, String> positionFilterCriteriaObject = new Map<String, String> {
        '2' => 'Level_2_ObjectName__c',
        '3' => 'Level_3_ObjectName__c',
        '4' => 'Level_4_ObjectName__c'
    };

    /**
     * Map for language general level to it's level number
     */
    public static Map<String, Double> generalLevelNumber = new Map<String, Double> {
        'Basic' => 1,
        'Fair' => 2,
        'Proficient' => 3,
        'Fluent' => 4,
        'Mother Tongue' => 5
    };

    /**
     * Method concatenates two strings with a separator in between
     *
     * @param value1       First string for concatenation
     * @param value2       Second string for concatenation
     * @param separator    separator to be used while concatenation
     *
     * @return Concatenated strings
     */
    public static String joinStringsWithSeparator(String value1, String value2, String separator) {
        return (value1 + separator + value2);
    }

    /**
     * Adds page message to the current page
     *
     * @param severity  Severity to be shown
     * @param message   Message to be shown
     */
    public static Void addPageMessage(ApexPages.Severity severity, String message) {
        ApexPages.addMessage(new ApexPages.message(severity, message));
    }

    /**
     * Converting Set to string to be used in dynamic query
     * @param ids as Set of Ids
     *
     * @return SetforQuery as String for dynamic query as ('id1','id2')
     */
    public static String SetToString(set<Id> ids) {
        String SetforQuery = '(' ;
        for (Id idToconvert : ids) {
            SetforQuery += '\'' + idToconvert + '\',';
        }
        SetforQuery = SetforQuery.substringBeforeLast(',');
        SetforQuery += ')';
        if (SetforQuery == '()') {
        SetforQuery = '(\'\')';
        }
        return SetforQuery;
    }

}