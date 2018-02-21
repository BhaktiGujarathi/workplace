/*
 *  Description - Controller for SubmissionSetting Page
 *   
 *  Date - 18-05-2016
 *  
 *  Created by - Ashwini Singh.
*/
public with sharing class SubmissionWizardSettingsController {
    
    public String page                                                                      {get; set;}
    public String iframeSource                                                              {get; set;}
    public List<ApexPage> pages = null;
    public List<AdminPanelMetadata__mdt> customMetadataList;
    public Map<String, Map<String, AdminPanelMetadata__mdt>> customMetaDataofParentMap;
    public static String mapKey                                                             {get; set;}
    public static Boolean isKeyInMap                                                        {get; set;}
    public static string keyValue                                                           {get; set;}

    public SubmissionWizardSettingsController () {
        
        iframeSource ='HomeSettings';
        mapKey = 'MCAHomeSettings';
        keyValue = '';
        isKeyInMap = true;
        pages = [SELECT Id, Name, NamespacePrefix FROM ApexPage];
        customMetadataList = new List<AdminPanelMetadata__mdt>();

    }
    
    // method to get meta data records fro DB
    public List<AdminPanelMetadata__mdt> getCustomMetadataList() {
        customMetadataList = [Select Id_Value__c, 
                                     Parent_Component_Name__c, 
                                     Type__c, 
                                     DeveloperName,
                                     Help_Text__c,
                                     Configuration_Name__c From AdminPanelMetadata__mdt];
        return customMetadataList;
    }
    
    public PageReference showSection() {
        
        getCustomMetaDataofParentMap();
        if(customMetaDataofParentMap.containsKey(mapKey)) 
        {
        if ( page == 'SubmissionWizardSettings') {
            iframeSource = '/apex/' + page;
        }
        
        else {
            for ( ApexPage p : pages) {
                if (page == p.Name ) {

                    if (p.NamespacePrefix != null){
                        iframeSource = '/apex/' + p.NamespacePrefix + '__' + p.Name;    
                        return null;
                    }
                    else {
                        iframeSource = '/apex/' + p.Name;
                        return null;
                    }
                   
                }
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'No such page is installed!'));
            iframeSource = '';
            return null;
        }
       }
       else
       {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'There are no labels/settings for this functionality!'));
            isKeyInMap = false;
            iframeSource = '';
        }
        return null;
    }
    
    // method to get map of custom metadata type
    public Map<String, Map<String, AdminPanelMetadata__mdt>> getCustomMetaDataofParentMap()
    {
        customMetaDataofParentMap = new Map<String, Map<String, AdminPanelMetadata__mdt>>();        
        Map<String, AdminPanelMetadata__mdt> customMetaDataMap;
        customMetadataList = getCustomMetadataList();
        if(!customMetadataList.isEmpty()) 
        {
            for(AdminPanelMetadata__mdt settingInstance :customMetadataList)
            {   
                if(customMetaDataofParentMap.containsKey(settingInstance.Parent_Component_Name__c))
                {
                    customMetaDataMap = customMetaDataofParentMap.get(settingInstance.Parent_Component_Name__c);
                    customMetaDataMap.put(settingInstance.DeveloperName, settingInstance);
                    customMetaDataofParentMap.put(settingInstance.Parent_Component_Name__c, customMetaDataMap);
                }
                else
                {
                    customMetaDataMap = new Map<String, AdminPanelMetadata__mdt>();
                    customMetaDataMap.put(settingInstance.DeveloperName, settingInstance);
                    customMetaDataofParentMap.put(settingInstance.Parent_Component_Name__c, customMetaDataMap);
                }
                
            }
        }
        for(String str: customMetaDataofParentMap.keySet())
        {
            keyValue += str+'><';
        }        
        
        return customMetaDataofParentMap;
    }
    
}