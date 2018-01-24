public with sharing class GRIDHomePageExtension{
    
    public String opportunityId;
   // declaration
    private final Opportunity oppStd;
    public Map<String, GRIDTabsSetting__mdt> tabToSettingMap{get; set;}
   
    // constructor
    public GRIDHomePageExtension(ApexPages.StandardController stdController) {
         opportunityId = Apexpages.currentPage().getParameters().get('id');
         if(opportunityId == null || opportunityId == '') {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, System.Label.GridOpportunityNotExist));
             //stipsIsDisable = true; 
         }
         this.oppStd = (Opportunity)stdController.getRecord();
         //syndDisplayTab = GRIDTabSetting__c.getValues('Syndications').Display_Tab__c;
         tabToSettingMap = new Map<String, GRIDTabsSetting__mdt> ();
         tabToSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
          
        
    }

}