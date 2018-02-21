/***********************************************************************************
 * Class : Pagination_Utils
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Helper class for pagination
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    02/05/2016    Initial Development
 **********************************************************************************/
public with sharing class Pagination_Utils {

    /**
     * Method returns offset value to be used for first page
     */
    public static Integer firstPage() {
        return 0;
    }

    /**
     * Method returns offset value to be used for previous page
     */
    public static Integer previousPage(Integer pOffset, Integer pLimit) {
        return ((pOffset - pLimit) > 0 ? (pOffset - pLimit) : 0);
    }

    /**
     * Method returns offset value to be used for next page
     */
    public static Integer nextPage(Integer pOffset, Integer pLimit) {
        return (pOffset + pLimit);
    }

    /**
     * Method returns offset value to be used for last page
     */
    public static Integer lastPage(Integer pLimit, Integer pRecordCount) {
        return pRecordCount - (Math.mod(pRecordCount, pLimit) == 0
                                ? pLimit
                                : Math.mod(pRecordCount, pLimit));
    }
}