/***********************************************************************************
 * Class : Constant
 * Created By : Ashwini Singh
 -----------------------------------------------------------------------------------
 * Description : Contains all the constant declarations
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ashwini Singh    20/04/2016    Initial Development
 **********************************************************************************/
public with sharing class Constant {
    public static final String WHITE_SPACE = ' ';
    public static final String COMMA = ',';
    public static final String HASH = '#';
    public static final String SORTEXPRESSIONC = 'NAME, ID ASC';
    public static final String PICKLISTC ='Picklist';
    public static final String OBJECTC ='Object';
    public static final String CONSTANTC ='Constant';
    public static final String EXEPTIONALFILTERC ='ExceptionalFilter';
    public static final String COLON = ':';
    public static final String ESCAPE_SINGLE_QUOTE = '\'';
    public static final String LAST_LEVEL = 'last level';
    public static final String BRACKET_START = '(';
    public static final String BRACKET_END = ')';
    public static final String APIFIELDNAME = 'ApiFieldName';
    public static final String PROFILERECORDFILTER = 'PR';
    public static final String TRUEC = 'True';

    /* Field Name Constants */
    public static final String FIELD_RECORDTYPEID = 'RecordTypeId';
    public static final String ID = 'Id';
    public static final String NAME ='Name';
    public static final String FIELD_EXPERTC = 'Expert__c';
    public static final String FIELD_CONTACT = 'Contact__c';
    public static final String FIELD_MAIN_PROFFESSION = 'Main_Profession__c';
    public static final String FIELD_SECONDARY_PROFFESSION = 'Secondary_Profession__c';
    public static final String FIELD_GENDER = 'Gender__c';
    public static final String FIELD_GLOBAL_SOUTH = 'Global_South__c';
    public static final String FIELD_SENIORITY = 'Seniority__c';
    public static final String FIELD_SGBV = 'SGBV_SR__c';
    public static final String FIELD_CVIC = 'CVIC_SR__c';
    public static final String FIELD_FOR = 'FOR_SR__c';
    public static final String FIELD_FIAR = 'FIAR_SR__c';
    public static final String FIELD_CORE_EXPERTISE_1 = 'Core_Expertise_1__c';
    public static final String FIELD_CORE_EXPERTISE_2 = 'Core_Expertise_2__c';
    public static final String FIELD_CORE_EXPERTISE_3 = 'Core_Expertise_3__c';
    public static final String FIELD_CATALOG_ENTRY = 'Entry_from_Catalog__c';
    public static final String FIELD_LANGUAGE_LEVEL = 'Language_Level_Number__c';
    public static final String FIELD_RT_DEV_NAME='RecordType.DeveloperName';

    /* Object Name Constants */
    public static final String OBJECT_EVALUATION = 'Evaluation__c';
    public static final String OBJECT_CONTACT = 'Contact';
    public static final String OBJECT_POSITION = 'Position__c';
    public static final String OBJECT_DEPLOYMENT = 'Deployment__c';
    public static final String OBJECT_PROFILE_RECORD = 'Profile_Record__c';
    public static final String COUNT_FUNCTION = 'COUNT()';

    /* URL parameter name constants */
    public static final String PARAM_ID = 'id';

    /* Operator constants*/
    public static final String EQUALC = '=';
    public static final String GREATER_EQUAL ='>=';
    public static final String LESSER_EQUAL ='<=';
    public static final String ANDC = 'AND';
    public static final String ORC = 'OR';
    public static final String INC = 'IN';

    public static final String PROFESSION = 'Profession';
    public static final String CHARACTERITICS = 'Characteristics';
    public static final String CORE_EXPERTISE = 'Core Expertise';
    public static final String AREA_OF_EXPERTISE = 'Area of Expertise';
    public static final String NATIONALITY = 'Nationality';
    public static final String COUNTRY_EXPERTISE = 'Country Expertise';
    public static final String LANGUAGE = 'Language';
    public static final String LEGAL_SYSTEMS = 'Legal Systems';
    public static final String GENDER = 'Gender';
    public static final String GLOBAL_SOUTH = 'Global South';
    public static final String SENIORITY = 'Seniority';
    public static final String SUB_ROSTER = 'Sub-Roster';
    public static final String NATIONALITY_RECORD_TYPE ='A_Nationality';
    public static final String COUNTRY_EXPERTISE_RECORD_TYPE = 'F_Country_Expertise';
}