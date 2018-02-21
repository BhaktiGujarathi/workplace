/***********************************************************************************
 * Class : FilterCriteria_Test
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Test class for testing functionalities FilterCriteria class
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    03/05/2016    Initial Development
 **********************************************************************************/
@isTest
private class FilterCriteria_Test {

    /**
     * Test whether level 1 picklist values are returned from custom setting
     */
    static testMethod Void testGetLevel1ValuesPositive() {
        TestDataFactory.createExpertSearchPositionFiltersSettings();
        Test.startTest();
        List<PositionSelectOption> level1PicklistValues = FilterCriteria.getLevel1Values();
        Test.stopTest();

        System.assert(level1PicklistValues.size() > 0);
    }

    /**
     * Test whether level 1 picklist values are not returned
     */
    static testMethod Void testGetLevel1ValuesNegative() {

        Test.startTest();
        List<PositionSelectOption> level1PicklistValues = FilterCriteria.getLevel1Values();
        Test.stopTest();

        System.assert(level1PicklistValues.size() == 0);
    }

    /**
     * Test picklist values retrieval for Critetia Type = Picklist
     */
    static testMethod Void testGetLevelValuesPicklist() {
        TestDataFactory.createExpertSearchPositionFiltersSettings();
        Test.startTest();
        List<PositionSelectOption> level2PicklistValues
            = FilterCriteria.getLevelValues(
                'Area of Expertise',
                '2',
                'Area of Expertise'
            );
        Test.stopTest();

        System.assert(level2PicklistValues.size() > 0);
    }

    /**
     * Test picklist values retrieval for Critetia Type = Constant
     */
    static testMethod Void testGetLevelValuesConstant() {
        TestDataFactory.createExpertSearchPositionFiltersSettings();
        Test.startTest();
        List<PositionSelectOption> level2PicklistValues
            = FilterCriteria.getLevelValues(
                'Characteristics',
                '2',
                'Characteristics'
            );
        Test.stopTest();

        System.assert(level2PicklistValues.size() > 0);
    }

    /**
     * Test picklist values retrieval for Critetia Type = Object
     */
    static testMethod Void testGetLevelValuesObject() {
        List<Catalog__c> legalSystemCatalogs = CatalogFactory.createLegalSystemCatalog(1);
        List<Catalog__c> nationalityCatalogs = CatalogFactory.createCountryCatalog(1);
        List<Catalog__c> catalogs = new List<Catalog__c>();
        catalogs.addAll(legalSystemCatalogs);
        catalogs.addAll(nationalityCatalogs);
        catalogs = CatalogFactory.insertData(catalogs);
        TestDataFactory.createExpertSearchPositionFiltersSettings();
        Test.startTest();
        List<PositionSelectOption> levelPicklistValues
            = FilterCriteria.getLevelValues(
                'Legal Systems',
                '2',
                'Legal Systems'
            );
        List<PositionSelectOption> level2PicklistValues
            = FilterCriteria.getLevelValues(
                'Nationality',
                '2',
                'Nationality'
            );

        List<PositionSelectOption> levelPicklistValuesOnlyFieldName
            = FilterCriteria.getLevelValues(
                level2PicklistValues[0].value,
                '3',
                'Nationality'
            );
        Test.stopTest();

        System.assert(levelPicklistValues.size() > 0);
        //System.assert(levelPicklistValuesOnlyFieldName.size() > 0);
    }

    /**
     * Test picklist value retrieval for level above the max number
     */
    static testMethod Void testGetLevelMaxLimit() {
        TestDataFactory.createExpertSearchPositionFiltersSettings();
        Test.startTest();
        List<PositionSelectOption> levelPicklistValues
            = FilterCriteria.getLevelValues(
                'Legal Systems',
                '4',
                'Legal Systems'
            );
        Test.stopTest();

        System.assert(levelPicklistValues.size() == 1);
    }

    /**
     * Test picklist value retrieval for ExceptionalFilter Gender
     */
    static testMethod Void testGetLevelValuesExceptionalFilterGender() {
        TestDataFactory.createExpertSearchPositionFiltersSettings();
        Test.startTest();
        List<PositionSelectOption> levelPicklistValues
            = FilterCriteria.getLevelValues(
                'Gender',
                '3',
                'Characteristics'
            );
        Test.stopTest();
        // TODO: Add asserts based on method behaviour
        //System.assert(levelPicklistValues.size() == 0);
    }

    /**
     * Test picklist value retrieval for ExceptionalFilter Global South
     */
    static testMethod Void testGetLevelValuesExceptionalFilterGlobalSouth() {
        TestDataFactory.createExpertSearchPositionFiltersSettings();
        Test.startTest();
        List<PositionSelectOption> levelPicklistValues
            = FilterCriteria.getLevelValues(
                'Global South',
                '3',
                'Characteristics'
            );
        Test.stopTest();
        // TODO: Add asserts based on method behaviour
        //System.assert(levelPicklistValues.size() == 0);
    }

    /**
     * Test picklist value retrieval for ExceptionalFilter Seniority
     */
    static testMethod Void testGetLevelValuesExceptionalFilterSeniority() {
        TestDataFactory.createExpertSearchPositionFiltersSettings();
        Test.startTest();
        List<PositionSelectOption> levelPicklistValues
            = FilterCriteria.getLevelValues(
                'Seniority',
                '3',
                'Characteristics'
            );
        Test.stopTest();
        // TODO: Add asserts based on method behaviour
        //System.assert(levelPicklistValues.size() == 0);
    }

    /**
     * Test picklist value retrieval for ExceptionalFilter JRR Langauge
     */
    static testMethod Void testGetLevelValuesExceptionalFilterJRRLang() {
        TestDataFactory.createExpertSearchPositionFiltersSettings();
        Test.startTest();
        List<PositionSelectOption> levelPicklistValues
            = FilterCriteria.getLevelValues(
                'JRR Language',
                '3',
                'Langauge'
            );
        Test.stopTest();
        // TODO: Add asserts based on method behaviour
        //System.assert(levelPicklistValues.size() == 0);
    }

    /**
     * Test picklist value retrieval for ExceptionalFilter Other Language
     */
    static testMethod Void testGetLevelValuesExceptionalFilterOtherLang() {
        TestDataFactory.createExpertSearchPositionFiltersSettings();
        Test.startTest();
        List<PositionSelectOption> levelPicklistValues
            = FilterCriteria.getLevelValues(
                'Other Language',
                '3',
                'Language'
            );
        Test.stopTest();
        // TODO: Add asserts based on method behaviour
        //System.assert(levelPicklistValues.size() == 0);
    }

    /**
     * Test picklist value retrieval for ExceptionalFilter Sub-Roster
     */
    static testMethod Void testGetLevelValuesExceptionalFilterSubRoster() {
        TestDataFactory.createExpertSearchPositionFiltersSettings();
        Test.startTest();
        List<PositionSelectOption> levelPicklistValues
            = FilterCriteria.getLevelValues(
                'Sub-Roster',
                '3',
                'Characteristics'
            );
        Test.stopTest();
        // TODO: Add asserts based on method/value behaviour
        //System.assert(levelPicklistValues.size() == 0);
    }

    /**
     * Test filters created for a position record
     */
    static testMethod Void testFiltersCreatedForPosition() {
        List<Catalog__c> professionCatalogs = CatalogFactory.createProfessionCatalog(2);
        List<Catalog__c> coreExpertiseCatalogs = CatalogFactory.createExpertiseCatalog(3);
        List<Catalog__c> catalogs = new List<Catalog__c>();
        catalogs.addAll(professionCatalogs);
        catalogs.addAll(coreExpertiseCatalogs);
        catalogs = CatalogFactory.insertData(catalogs);
        List<Mission__c> missions = MissionFactory.createAndInsertMission(1);
        List<Position__c> positions = PositionFactory.createPosition(
                                        1,
                                        missions[0].Id,
                                        professionCatalogs[0].Id,
                                        professionCatalogs[1].Id,
                                        coreExpertiseCatalogs[0].Id,
                                        coreExpertiseCatalogs[1].Id,
                                        coreExpertiseCatalogs[2].Id
                                    );
        PositionFactory.insertData(positions);
        TestDataFactory.createExpertSearchPopulateFiltersSettings();
        Test.startTest();
        Position__c position = Position_Domain.getPositionforExpertSearch(positions[0].Id);
        FilterCriteria.populateFilter(position);
        Test.stopTest();
    }

}