/**
  * @Class Name: RelatedListComponentExtension
  * @Description: Extension to show history records in detail page
  * ======================================================================================================
  *         Version   | Date        | Author             | Comments
  * ------------------------------------------------------------------------------------------------------
  *         1.0       | 16/01/2017  | Eternus Solutions  | 1. Initial Draft
  * =======================================================================================================
  **/
global with sharing class RelatedListComponentExtension {
    
    global String recordId { get; set; }
    public Boolean inlineFlag { get; set; }
     /**
      * @Author: Eternus Solutions
      * @Description: RelatedListComponentExtension constructor
      * @Param: Current package installation context.
      * @Return: NA
      * @Date: 16/01/2017
      **/
    global RelatedListComponentExtension(ApexPages.StandardController stdController) {
        recordId = string.valueOf(ApexPages.currentPage()).substringBetween('id=', '&');
        if(string.valueOf(ApexPages.currentPage()).contains('inline')) {
            inlineFlag = true;
        }else {
            inlineFlag = false;
        }
    }
}