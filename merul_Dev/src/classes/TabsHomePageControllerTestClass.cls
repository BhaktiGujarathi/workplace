@isTest(seeAllData = false)
private class TabsHomePageControllerTestClass {



    static testMethod void validateSubTabsController() {
    
        // test.startTest();
        
          Tabs_system__c objSysTab;
       
        List<Tabs_system__c> systemTabList= new List<Tabs_system__c>();
        Schema.DescribeSObjectResult gdSObject;
        Map<String, Schema.SObjectType> gd=new  Map<String, Schema.SObjectType>();
        List<String> listOfApiName=new  List<String>();
             gd = Schema.getGlobalDescribe();     
                          for(String sObj :  gd.keySet())    
                              {
                                
                                       gdSObject= gd.get(sObj).getDescribe();   
                                          
                                       if(gdSObject.getKeyPrefix()!=null && gdSObject.custom==true  && gdSObject.customSetting==false && gdSObject.accessible )     
                                                                          
                                        {
                                                                               
                                              systemTabList.add(new Tabs_system__c(Keep__c=true,Label__c= gdSObject.getLabel(),api_name__c= sObj ,Key_prefix__c= gdSObject.getKeyPrefix()));
                                              listOfApiName.add(sObj);              
                                         }                                                                    
                           
                              }
                       
                        systemTabList.add(new Tabs_system__c(Keep__c=true,Label__c= 'test',api_name__c= 'test__c' ,Key_prefix__c= '100'));
                                              
                         UPSERT systemTabList;
   
  
            
        
        /*  Tabs_Preference__c objUserPrefTab= new Tabs_Preference__c(  userid__c= UserInfo.getUserId() , 
                                        preference_tab_1__c=listOfApiName[0], preference_tab_2__c=listOfApiName[1], 
                                        preference_tab_3__c=listOfApiName[2], preference_tab_4__c=listOfApiName[3], 
                                        preference_tab_5__c=listOfApiName[4]);*/
                                        
                                        
                                        
         Tabs_Preference__c objUserPrefTab= new Tabs_Preference__c(  userid__c= UserInfo.getUserId(), 
                                        preference_tab_1__c='abc1__c', preference_tab_2__c='abc2__c', 
                                        preference_tab_3__c='abc3__c', preference_tab_4__c='abc3__c', 
                                        preference_tab_5__c='abc4__c');                                
       
       INSERT objUserPrefTab;                            
      
      
      
        
        TabsObjectClass objAfter = new TabsObjectClass ();
        
        TabsHomePageController objSubTabsTest = new TabsHomePageController ();
    
        objSubTabsTest.onloadSubTabsController();
                       
        ApexPages.currentPage().getParameters().put('sortAlphabet','ALL');
        objSubTabsTest.sortList();

        ApexPages.currentPage().getParameters().put('sortAlphabet','B');
        objSubTabsTest.sortList();
        
        ApexPages.currentPage().getParameters().put('save','B');
        objSubTabsTest.sortList();
        
        objSubTabsTest.goToSetPreferenceTab();
        objSubTabsTest.cancel();
        objSubTabsTest.save();
        
        
        
         TabsSetPreferenceController objPref=new TabsSetPreferenceController();
         objPref.savePreference();
         objPref.getOptions();
         objPref.cancel();
         
         
         
         TabsCustomizeController tabc=new TabsCustomizeController();
         tabc.onloadCustomizeTabsController();
         tabc.save();
         tabc.cancel();
         
         
       //  test.stopTest();
      }     
    
   static testMethod void validateSubTabsController1()   
    {
  
      //   test.startTest();
  
  
        TabsObjectClass objAfter = new TabsObjectClass ();
        
        TabsHomePageController objSubTabsTest = new TabsHomePageController ();
    
        objSubTabsTest.onloadSubTabsController();
        
        
         TabsSetPreferenceController objPref=new TabsSetPreferenceController();
         objPref.savePreference();
         objPref.getOptions();
         objPref.cancel();
         
         
         TabsCustomizeController tabc=new TabsCustomizeController();
         tabc.onloadCustomizeTabsController();
        /* tabc.save();
         tabc.cancel();*/
        
       // test.stopTest();
    }
    
     static testMethod void validateSubTabsController2()   
    {
  
  
      //  test.startTest();
        
        List<Tabs_system__c> systemTabList= new List<Tabs_system__c>();
        Schema.DescribeSObjectResult gdSObject;
        Map<String, Schema.SObjectType> gd=new  Map<String, Schema.SObjectType>();
         List<String> listOfApiName=new  List<String>();
           
           
             gd = Schema.getGlobalDescribe();     
             Integer i=0 ;
                          for(String sObj :  gd.keySet())    
                              {
                                
                                       gdSObject= gd.get(sObj).getDescribe();   
                                          
                                       if(gdSObject.getKeyPrefix()!=null && gdSObject.custom==true  && gdSObject.customSetting==false && gdSObject.accessible )     
                                                                          
                                        {
                                                                               
                                              systemTabList.add(new Tabs_system__c(Keep__c=true,Label__c= gdSObject.getLabel(),api_name__c= sObj ,Key_prefix__c= gdSObject.getKeyPrefix()));
                                               listOfApiName.add(sObj); 
                                              i++;
                                              
                                              if(i==5)
                                              {
                                                break;
                                              } 
                                         }                                                                    
                           
                              }
                              
                              
                              
                         UPSERT systemTabList;
                         
                         
                         
         Tabs_Preference__c objUserPrefTab= new Tabs_Preference__c(  userid__c= UserInfo.getUserId(), 
                                        preference_tab_1__c='abc1__c', preference_tab_2__c='abc2__c', 
                                        preference_tab_3__c='abc3__c', preference_tab_4__c='abc3__c', 
                                        preference_tab_5__c='abc4__c');
       
       INSERT objUserPrefTab;    
       
         
                    
       
        TabsObjectClass objAfter = new TabsObjectClass();
        
        TabsHomePageController objSubTabsTest = new TabsHomePageController ();
        
       
        objSubTabsTest.onloadSubTabsController();
        
        
         TabsSetPreferenceController objPref=new TabsSetPreferenceController();
      
         
         
         
        TabsCustomizeController tabc=new TabsCustomizeController();
         tabc.onloadCustomizeTabsController();
        
         
      //   test.stopTest();
         
    }
    
    
 
 
     static testMethod void validateSubTabsController3()   
    {
  
  
       // test.startTest();
        
        List<Tabs_system__c> systemTabList= new List<Tabs_system__c>();
        Schema.DescribeSObjectResult gdSObject;
        Map<String, Schema.SObjectType> gd=new  Map<String, Schema.SObjectType>();
         List<String> listOfApiName=new  List<String>();
           
           
             gd = Schema.getGlobalDescribe();     
             Integer i=0 ;
                          for(String sObj :  gd.keySet())    
                              {
                                
                                       gdSObject= gd.get(sObj).getDescribe();   
                                          
                                       if(gdSObject.getKeyPrefix()!=null && gdSObject.custom==true  && gdSObject.customSetting==false && gdSObject.accessible )     
                                                                          
                                        {
                                                                               
                                              systemTabList.add(new Tabs_system__c(Keep__c=true,Label__c= gdSObject.getLabel(),api_name__c= sObj ,Key_prefix__c= gdSObject.getKeyPrefix()));
                                               listOfApiName.add(sObj); 
                                              i++;
                                              
                                              if(i==4)
                                              {
                                                break;
                                              } 
                                         }                                                                    
                           
                              }
                              
                              
                              
                         UPSERT systemTabList;
                         
                         
                         
         Tabs_Preference__c objUserPrefTab= new Tabs_Preference__c(  userid__c= UserInfo.getUserId(), 
                                        preference_tab_1__c='abc1__c', preference_tab_2__c='abc2__c', 
                                        preference_tab_3__c='abc3__c', preference_tab_4__c='abc3__c', 
                                        preference_tab_5__c='abc4__c');
       
       INSERT objUserPrefTab;    
       
         
                    
       
        TabsObjectClass objAfter = new TabsObjectClass();
        
        TabsHomePageController objSubTabsTest = new TabsHomePageController ();
        
       
        objSubTabsTest.onloadSubTabsController();
        
        
         TabsSetPreferenceController objPref=new TabsSetPreferenceController();
      
         
         
         
        TabsCustomizeController tabc=new TabsCustomizeController();
         tabc.onloadCustomizeTabsController();
        
         
      //  test.stopTest();
         
    }
 
 
 
    
}