public with sharing class GRIDHomePageExtension{
    
    
   // declaration
    private final Opportunity oppStd;
    public Map<String, GRIDTabsSetting__mdt> tabToSettingMap{get; set;}
   
    // constructor
    public GRIDHomePageExtension(ApexPages.StandardController stdController) {
         this.oppStd = (Opportunity)stdController.getRecord();
         //syndDisplayTab = GRIDTabSetting__c.getValues('Syndications').Display_Tab__c;
         tabToSettingMap = new Map<String, GRIDTabsSetting__mdt> ();
         tabToSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
          
        
    }

}