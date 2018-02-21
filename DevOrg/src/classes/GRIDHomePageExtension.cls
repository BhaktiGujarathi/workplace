public with sharing class GRIDHomePageExtension{
    
    
   // declaration
    private final Opportunity oppStd;
    //public Boolean syndDisplayTab                                                       {get; set;}
    public Map<String, GRIDTabSetting__c> tabToSettingMap                                {get; set;}
    // constructor
    public GRIDHomePageExtension(ApexPages.StandardController stdController) {
         this.oppStd = (Opportunity)stdController.getRecord();
         //syndDisplayTab = GRIDTabSetting__c.getValues('Syndications').Display_Tab__c;
         tabToSettingMap = new Map<String, GRIDTabSetting__c> ();
         tabToSettingMap = GRIDTabSetting__c.getAll();
    }

}
