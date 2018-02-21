/***********************************************************************************
 * Class : ExpertSearch_Test
 * Created By : Ashwini Singh
 -----------------------------------------------------------------------------------
 * Description : Test class for testing functionalities in ExpertSearch page and
                 it's controller
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ashwini Singh    27/04/2016    Initial Development
 **********************************************************************************/
@isTest
private class ExpertSearch_Test {

     /**
     * Test for checking whether filters values are prepopulated on position id is passed
     */
    static testMethod Void testfetchPosition() {
        List<Account> accounts = AccountFactory.createAndInsertAccounts(1);
        TestDataFactory.createExpertSearchPositionFiltersSettings();
        Test.startTest();
        List<PositionSelectOption> level1PicklistValues = FilterCriteria.getLevel1Values();
        Test.stopTest();
        System.assert(level1PicklistValues.size() > 0);
    }
}