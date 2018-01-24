public with sharing class DummyHomePageController {
    private final Opportunity oppStd;
    public Map<String, GRIDTabsSetting__mdt> tabToSettingMap{get; set;}
    //public Map<Integer, Component.Apex.Tab> indexToTabMap;
    
    public DummyHomePageController(ApexPages.StandardController stdController) {
         this.oppStd = (Opportunity)stdController.getRecord();
         tabToSettingMap = new Map<String, GRIDTabsSetting__mdt> ();
         tabToSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
         //indexToTabMap = new Map<Integer, Component.Apex.Tab>();
    }
    
    public Component.Apex.TabPanel getTabPanel() {
        
        Component.Apex.TabPanel tabPnl = new Component.Apex.TabPanel();
        tabPnl.switchType='client';
        
        Component.Apex.Tab offerTab = new Component.Apex.Tab();
        offerTab.label='Offers';
        offerTab.expressions.rendered ='{!AND(tabToSettingMap["Offers"].Display_Tab__c, $ObjectType.Offer__c.accessible)}';
        Component.c.GRIDOffersComponent offerComponent = new Component.c.GRIDOffersComponent();
        offerTab.childComponents.add(offerComponent);
        tabPnl.childComponents.add(offerTab);
        
        /*indexToTabMap.put(Integer.valueOf(tabToSettingMap.get('Offers').TabIndex__c), offerTab);
        system.debug('>>>1 indexToTabMap : '+indexToTabMap);
        */
        Component.Apex.Tab submissionTab = new Component.Apex.Tab();
        submissionTab.label='Submissions';
        submissionTab.expressions.rendered ='{!AND(tabToSettingMap["Submissions"].Display_Tab__c, $ObjectType.Submission__c.accessible)}';
        Component.c.GRIDSubmissionComponent submissionComponent = new Component.c.GRIDSubmissionComponent();
        submissionTab.childComponents.add(submissionComponent);
        tabPnl.childComponents.add(submissionTab);
        
        /*indexToTabMap.put(Integer.valueOf(tabToSettingMap.get('Submissions').TabIndex__c), submissionTab);
        system.debug('>>>2 indexToTabMap : '+indexToTabMap);
        */
        /*
        for(Integer i : indexToTabMap.keyset())
        {
            tabPnl.childComponents.add(indexToTabMap.get(i));
        }
        */
        
        return tabPnl;
    }
}