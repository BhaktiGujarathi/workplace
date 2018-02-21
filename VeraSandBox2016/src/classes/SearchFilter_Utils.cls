/***********************************************************************************
 * Class : SearchFilter_Utils
 * Created By : Ashwini Singh
 -----------------------------------------------------------------------------------
 * Description : Helper class for Search filters in ExpertSearch page
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ashwini Singh    02/05/2016    Initial Development
 **********************************************************************************/
public with sharing class SearchFilter_Utils {

    /**
    * This function concats for filter criteria based on passed paramater
    * @param fieldName as String for name of field to be compare
    * @param comparatorValue as String for value to be comapared with
    * @param comparatorSymbol as String for comparision like <=, = , In, NotIn...
    * @param binder as String as String for all logical Operator AND,OR etc.
    * @param bracket as String for placing brackets appropriately values in consideration are (, )
    * and ()
    *
    * @return filters as String for where clause
    */
    public static String addFilters(
        String fieldName,
        String comparatorSymbol,
        String comparatorValue,
        String binder,
        String bracket
    ) {
        String filterToReturn = '';
        if (fieldName != null && comparatorSymbol != null && comparatorValue != null) {
            filterToReturn += binder!=null? Constant.WHITE_SPACE + Binder:'';
            if (bracket == Constant.BRACKET_START) {
                filterToReturn += Constant.WHITE_SPACE + Constant.BRACKET_START;
            }
            filterToReturn += Constant.WHITE_SPACE + fieldName;
            filterToReturn += Constant.WHITE_SPACE + comparatorSymbol;
            if (bracket == Constant.BRACKET_START + Constant.BRACKET_END) {
                filterToReturn +=
                    Constant.WHITE_SPACE +
                    Constant.BRACKET_START +
                    comparatorValue +
                    Constant.BRACKET_END;
            } else {
                filterToReturn += Constant.WHITE_SPACE + comparatorValue;
            }
            if (bracket == Constant.BRACKET_END) {
                filterToReturn += Constant.WHITE_SPACE + Constant.BRACKET_END;
            }
        }
        return filterToReturn ;
    }

}