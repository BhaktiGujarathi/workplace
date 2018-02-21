/***********************************************************************************
 * Class : Query_Utils
 * Created By : Ashwini Singh
 -----------------------------------------------------------------------------------
 * Description : Class includes methods related to SOQL/SOSL queries
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ashwini Singh     03/05/2016    Initial Development
 **********************************************************************************/
public with sharing class Query_Utils {

    /**
     * Dynamic query builder
     *
     * @param objectName as String
     * @param fieldName as string
     * @param filters as string as generated from apply filter;
     * @param sortExpression as string for Order by Clause
     * @param recordLimit set the limit to no. of records to be fetched
     * @param recordOffset set the Offset to fetch the records
     *
     * @return query String
     */
    public static String queryBuilder(
        String objectName,
        String fieldName,
        String filters,
        String sortExpression,
        Integer recordLimit,
        Integer recordOffset
    ) {
        return (Constant.WHITE_SPACE +
                'SELECT' + Constant.WHITE_SPACE +
                    fieldName + Constant.WHITE_SPACE +
                'FROM' + Constant.WHITE_SPACE +
                    objectName + Constant.WHITE_SPACE +
                (String.isNotBlank(filters) ?
                ('WHERE' + Constant.WHITE_SPACE + filters + Constant.WHITE_SPACE ) : '') +
                (String.isNotBlank(sortExpression) ?
                ('ORDER BY' + Constant.WHITE_SPACE + sortExpression + Constant.WHITE_SPACE) : '') +
                (recordLimit != null ?
                ('LIMIT' + Constant.WHITE_SPACE + recordLimit + Constant.WHITE_SPACE) : '') +
                (recordOffset != null ?
                ('OFFSET' + Constant.WHITE_SPACE + recordOffset + Constant.WHITE_SPACE) : ''));
    }

    /**
     * fetching records from query
     * @param query
     *
     * @return List of sObject after fetching records
     */
    public static List<sObject> fetchRecords(String query) {
        return Database.query(query);
    }

    /**
     * fetching records from query\
     * @param queryCount
     *
     * @return value of aggregate funtion
     */
    public static Integer searchRecordCount(String queryCount) {
        return (Database.countQuery(queryCount));
    }

}