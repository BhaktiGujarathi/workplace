@isTest
private class PaginationUtility_Test {

    static testMethod void myUnitTest() {
        PaginationUtility pagenation = new PaginationUtility();
        System.debug(pagenation.showNext);
        System.debug(pagenation.showprevious);
        System.debug(pagenation.pageNumber);
        System.debug(pagenation.errorMessage);
        System.debug(pagenation.pagesToShowList);
        System.debug(pagenation.recordsList);
        System.debug(pagenation.recordsPerPageList);
        System.debug(pagenation.totalPageNumber);
        System.debug(PaginationUtility.PAGE_SIZE);
        System.debug(PaginationUtility.MAX_PAGES);
        System.debug(pagenation.recordsSizeList);
        PaginationUtility.PAGE_SIZE = 1;
        PaginationUtility.MAX_PAGES = 2;
        pagenation.pageNumber = 1;
        pagenation.showNext = false;
        pagenation.showprevious = false;
        pagenation.errorMessage = '';
        pagenation.recordsPerPageList = new List<ID>();
        List<Account> lst = new List<Account>();
       
        for(Integer i=0;i<10;i++){
        	lst.add(InitialiseTestData.getCorporateAccount('Test'+i));
        }
        insert lst;
        pagenation.recordsList = new List<ID>();
        pagenation.pagesToShowList = new List<Integer>();
        for(Account ac:lst)
        	pagenation.recordsList.add(ac.id);
        pagenation.countTotalPages();
        
        pagenation.next();
        pagenation.previous();
        pagenation.showRecords();
        pagenation.setPreviousNextFlags();
    }
}