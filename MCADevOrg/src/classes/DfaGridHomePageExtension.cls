public with sharing class DfaGridHomePageExtension{    
    
   // declaration
    private final Opportunity oppStd;
    public Map<String, DfaGrid__mdt> tabToSettingMap{get; set;}
   
    // constructor
    public DfaGridHomePageExtension(ApexPages.StandardController stdController) {
         this.oppStd = (Opportunity)stdController.getRecord();
         tabToSettingMap = new Map<String, DfaGrid__mdt> ();
         List<DfaGrid__mdt> customMetadataList = [Select Display_Check__c,
                                                                       EditAll_Check__c,
                                                                       sObject_Name__c, 
                                                                       Tab_Name__c, 
                                                                       DeveloperName From DfaGrid__mdt];
         if(!customMetadataList.isEmpty()) 
         {
            for(DfaGrid__mdt settingInstance :customMetadataList)
            {
                tabToSettingMap.put(settingInstance.DeveloperName, settingInstance);
            }
         }
         
    }

}