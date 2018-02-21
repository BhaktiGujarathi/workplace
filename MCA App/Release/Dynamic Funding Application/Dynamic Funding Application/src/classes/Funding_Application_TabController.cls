/* 
*  Apex controller for funding Tabs
*  Revision History: 
* 
*  Version           Author                 Date                 Description 
*  1.0              Yogesh Mahajan        2-Feb 2016           Initial Draft 

*/
public with sharing class Funding_Application_TabController {
    // Constant Variable
    private static final String CUSTOM_SETTING_NAME = 'Tab Permission';
    private static final String NEWAPP_PARAM = 'newApplication';
    
    private String isNewApplication;
    // get set variable for tab visibility
    public Boolean isLonVisible         {get;set;}
    public Boolean isSalesVisible       {get;set;}

    
    public Funding_Application_TabController() {
        isLonVisible = true;
        isSalesVisible = true;
        system.debug('Inside check'+ApexPages.currentPage().getParameters().get(NEWAPP_PARAM));
        checkTabvisibility();
    }
    
    public void checkTabvisibility() {
        isNewApplication = ApexPages.currentPage().getParameters().get(NEWAPP_PARAM);
        system.debug('Inside check');
        // get custom setting value
        MCAExtension1__Show_Related_Object__c tabVisibility = 
            MCAExtension1__Show_Related_Object__c.getValues(CUSTOM_SETTING_NAME);
        system.debug('Inside check'+tabVisibility);
        if(tabVisibility <> null) {
            isLonVisible = tabVisibility.MCAExtension1__Loan_Balances__c;
            isSalesVisible = tabVisibility.MCAExtension1__Bank_Statements__c;
        }// end if
        system.debug('Inside check'+isLonVisible+'--'+isSalesVisible);
        
    }// end checkTabvisibility()
}// end Class