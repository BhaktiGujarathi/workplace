public with sharing class RelatedListComponentExtension {
    
    public String recordId { get; set; }
    public Boolean inlineFlag { get; set; }
    
    public RelatedListComponentExtension(ApexPages.StandardController stdController) {
        system.debug('>>> currentPage : '+ApexPages.currentPage());
        recordId = string.valueOf(ApexPages.currentPage()).substringBetween('id=', '&');
        if(string.valueOf(ApexPages.currentPage()).contains('inline')) {
            inlineFlag = true;
        }else {
            inlineFlag = false;
        }
        system.debug('>>> inlineFlag : '+inlineFlag);
        system.debug('>>> recordId : '+recordId);
    }
}