public with sharing class TabsObjectClass {

    private static String objRejected1 = System.Label.Tabs_Object_More_Neglect;
    private static String objRejected2 = System.Label.Tabs_Object_SystemTab_Neglect;
                                                        
    public static Map<String,String> mapStandardObjectsNameLabel = new Map<String,String>();
    public static Map<String,String> mapStandardObjectsNamePrefix = new Map<String,String>();

    public static Map<String,String> mapCustomObjectsNameLabel = new Map<String,String>();
    public static Map<String,String> mapCustomObjectsNamePrefix = new Map<String,String>();

    public static Map<String,Tabs_system__c> mapNameCustomObjects = new Map<String,Tabs_system__c>();

    public static List<TabsObjectLabel> listPriorityTabs = new List<TabsObjectLabel>();
    public static List<TabsObjectLabel> listNonPriorityTabs = new List<TabsObjectLabel>();
    private static final Integer PriorityLimit = 5;
    private static List<String> listApiName;

    private static Map<String, Schema.SObjectType> gd = new Map<String, Schema.SObjectType>();
    
    public static String tabValue {get; set;}   
    public static Set<String> customObjects = new Set<String>();
    public static Set<String> standardObjects = new Set<String>();
    public static Tabs_Preference__c objUserPrefTab;
    public static String user;
                                                    
    static {
        objUserPrefTab = null;
        user = UserInfo.getUserId();
        
        gd.clear();
        gd = Schema.getGlobalDescribe();
        
        List<Tabs_system__c> presentList = [ select Id, Label__c, Keep__c, Api_name__c, Key_prefix__c
                                            from  Tabs_system__c ];
        
        if(presentList.size()!=0) {
           for(Tabs_system__c sysTab : presentList) {
                 if(sysTab.Keep__c && gd.containsKey(sysTab.api_name__c)
                         && gd.get(sysTab.api_name__c).getDescribe().isAccessible()  ) {
                     mapNameCustomObjects.put(sysTab.api_name__c, sysTab); 
                    /* listNonPriorityTabs.add( new TabsObjectLabel(sysTab.label__c,
                                                    sysTab.api_name__c,
                                                    sysTab.key_prefix__c));*/
                }       
           }
        } else {
           for(Schema.SObjectType d : gd.Values()) {
                if(  d.getDescribe().isCustom() && d.getDescribe().isAccessible() 
                    && d.getDescribe().getKeyPrefix()!=null && !d.getDescribe().isCustomSetting()     
                           && !objRejected1.equalsIgnoreCase(d.getDescribe().getLabel())
                           && !objRejected2.equalsIgnoreCase(d.getDescribe().getLabel()) ) {
                     mapNameCustomObjects.put( d.getDescribe().getName(), 
                                               new Tabs_system__c(label__c = d.getDescribe().getLabel(), 
                                                               api_name__c = d.getDescribe().getName(), 
                                                               key_prefix__c = d.getDescribe().getKeyPrefix()) );
                   /*  listNonPriorityTabs.add( new TabsObjectLabel(d.getDescribe().getLabel(),
                                                    d.getDescribe().getName(),
                                                    d.getDescribe().getKeyPrefix()));*/
                }
           } 
        }      
        
        
        populateMaps();
        
        List<Tabs_Preference__c> moreObj = [ SELECT id, userid__c, 
                                        preference_tab_1__c, preference_tab_2__c, preference_tab_3__c,
                                        preference_tab_4__c, preference_tab_5__c
                                  FROM Tabs_Preference__c
                                  WHERE userid__c = :user LIMIT 1 ];

        listApiName = new List<String>(mapCustomObjectsNamePrefix.keySet());
       
       //List<String> listApiName = new List<String>(mapNameCustomObjects.keySet()); /*Merul's*/

       /* for(Tabs_system__c obj: mapNameCustomObjects.values() ) {
                       
            listNonPriorityTabs.add( new TabsObjectLabel(obj.label__c,
                                                    value,
                                                    ObjectClass.mapCustomObjectsNamePrefix.get(value)));
        }*/
        
        for(String value: mapCustomObjectsNameLabel.keySet() ) {
               
            listNonPriorityTabs.add( new TabsObjectLabel(TabsObjectClass.mapCustomObjectsNameLabel.get(value),
                                                    value,
                                                   TabsObjectClass.mapCustomObjectsNamePrefix.get(value)));
        }
        
        listNonPriorityTabs.sort();
        
       
        
        if(moreObj.size() != 0) {
            objUserPrefTab = moreObj.get(0);
            validatePreferences();
            if( listApiName.size() == 1 ) {
                objUserPrefTab.preference_tab_1__c = listApiName.get(0);
                //DELETE objUserPrefTab;
            }
            if( listApiName.size() == 2 ) {
                objUserPrefTab.preference_tab_1__c = listApiName.get(0);
                objUserPrefTab.preference_tab_2__c = returnNonRepeatValue(2);
                //DELETE objUserPrefTab;
            }
            if( listApiName.size() == 3 ) {
                objUserPrefTab.preference_tab_1__c = listApiName.get(0);
                objUserPrefTab.preference_tab_2__c = returnNonRepeatValue(2);
                objUserPrefTab.preference_tab_3__c = returnNonRepeatValue(3);
                //DELETE objUserPrefTab;
            }
            if( listApiName.size() == 4 ) {
                objUserPrefTab.preference_tab_1__c = listApiName.get(0);
                objUserPrefTab.preference_tab_2__c = returnNonRepeatValue(2);
                objUserPrefTab.preference_tab_3__c = returnNonRepeatValue(3);
                objUserPrefTab.preference_tab_4__c = returnNonRepeatValue(4);
                //DELETE objUserPrefTab;
            }
            if( listApiName.size() == 5 ) {
                objUserPrefTab.preference_tab_1__c = listApiName.get(0);
                objUserPrefTab.preference_tab_2__c = returnNonRepeatValue(2);
                objUserPrefTab.preference_tab_3__c = returnNonRepeatValue(3);
                objUserPrefTab.preference_tab_4__c = returnNonRepeatValue(4);
                objUserPrefTab.preference_tab_5__c = returnNonRepeatValue(5);
                //DELETE objUserPrefTab;
            }
            if( listApiName.size() > 5 ) {
                objUserPrefTab.preference_tab_1__c = listApiName.get(0);
                objUserPrefTab.preference_tab_2__c = returnNonRepeatValue(2);
                objUserPrefTab.preference_tab_3__c = returnNonRepeatValue(3);
                objUserPrefTab.preference_tab_4__c = returnNonRepeatValue(4);
                objUserPrefTab.preference_tab_5__c = returnNonRepeatValue(5);
                
                System.debug('$$$$Updating: '+objUserPrefTab.preference_tab_1__c+' '+objUserPrefTab.preference_tab_2__c+' '
                            +objUserPrefTab.preference_tab_3__c+' '+objUserPrefTab.preference_tab_4__c+' '
                            +objUserPrefTab.preference_tab_5__c);
                //UPDATE objUserPrefTab;
            }
        } else {
        
            objUserPrefTab  = new Tabs_Preference__c();
            if( listApiName.size() >=1 ) {
                  objUserPrefTab.preference_tab_1__c = listApiName.get(0);
            }
            if( listApiName.size() >=2 ) {
                objUserPrefTab.preference_tab_2__c = returnNonRepeatValue(2);
            }
            if( listApiName.size() >=3 ) {
                objUserPrefTab.preference_tab_3__c = returnNonRepeatValue(3);
            }
            if( listApiName.size() >=4 ) {
                objUserPrefTab.preference_tab_4__c = returnNonRepeatValue(4);
            }
            if( listApiName.size() >=5 ) {
                objUserPrefTab.preference_tab_5__c = returnNonRepeatValue(5);
            }
        }
        
        if(listNonPriorityTabs.size() >=1) {

            listPriorityTabs.add(new TabsObjectLabel(mapCustomObjectsNameLabel.get(objUserPrefTab.preference_tab_1__c), 
                                                objUserPrefTab.preference_tab_1__c,
                                                mapCustomObjectsNamePrefix.get(objUserPrefTab.preference_tab_1__c)));                                    
        }
        if(listNonPriorityTabs.size() >=2) {
            
            listPriorityTabs.add(new TabsObjectLabel(mapCustomObjectsNameLabel.get(objUserPrefTab.preference_tab_2__c), 
                                                objUserPrefTab.preference_tab_2__c,
                                                mapCustomObjectsNamePrefix.get(objUserPrefTab.preference_tab_2__c)));
        }
        if(listNonPriorityTabs.size() >=3) {
            
            listPriorityTabs.add(new TabsObjectLabel(mapCustomObjectsNameLabel.get(objUserPrefTab.preference_tab_3__c), 
                                                    objUserPrefTab.preference_tab_3__c,
                                                    mapCustomObjectsNamePrefix.get(objUserPrefTab.preference_tab_3__c)));
        }
        if(listNonPriorityTabs.size() >=4) {
            
            listPriorityTabs.add(new TabsObjectLabel(mapCustomObjectsNameLabel.get(objUserPrefTab.preference_tab_4__c), 
                                                objUserPrefTab.preference_tab_4__c,
                                                mapCustomObjectsNamePrefix.get(objUserPrefTab.preference_tab_4__c)));
        }
        if(listNonPriorityTabs.size() >=5) {
           
            listPriorityTabs.add(new TabsObjectLabel(mapCustomObjectsNameLabel.get(objUserPrefTab.preference_tab_5__c), 
                                                objUserPrefTab.preference_tab_5__c,
                                                mapCustomObjectsNamePrefix.get(objUserPrefTab.preference_tab_5__c)));
        }
        
                    
        if(listApiName!=null) {
            listApiName.clear();
        }
        if(presentList!=null) {
            presentList.clear();
        }        
    }
    
    private static void populateMaps() {
        
        mapCustomObjectsNamePrefix.clear();
        mapCustomObjectsNameLabel.clear();
        for( String str : mapNameCustomObjects.keySet()) {
                mapCustomObjectsNamePrefix.put(str, gd.get(str).getDescribe().getKeyPrefix());
                mapCustomObjectsNameLabel.put(str, gd.get(str).getDescribe().getLabel());
        }
       
    }
    
    public static Tabs_Preference__c checkValidTabs() {
         
        List<Tabs_system__c> presentList = [ SELECT id, Label__c, Keep__c, api_name__c, Key_prefix__c
                                            FROM  Tabs_system__c ];

        List<Tabs_Preference__c> moreObj = [ SELECT id, userid__c, 
                                        preference_tab_1__c, preference_tab_2__c, preference_tab_3__c,
                                        preference_tab_4__c, preference_tab_5__c
                                  FROM Tabs_Preference__c
                                  WHERE userid__c = :user LIMIT 1];
   
        gd.clear();
        gd = Schema.getGlobalDescribe();
        
        mapNameCustomObjects.clear();
        listNonPriorityTabs.clear();
        if(presentList.size()!=0) {
           for(Tabs_system__c sysTab : presentList) {
                 if(sysTab.Keep__c && gd.containsKey(sysTab.api_name__c)
                         && gd.get(sysTab.api_name__c).getDescribe().isAccessible()  ) {
                     mapNameCustomObjects.put(sysTab.api_name__c, sysTab); 
                    /* listNonPriorityTabs.add( new TabsObjectLabel(sysTab.label__c,
                                                    sysTab.api_name__c,
                                                    sysTab.key_prefix__c));*/
                }       
           }
        } else {
           for(Schema.SObjectType d : gd.Values()) {
                if(  d.getDescribe().isCustom() && d.getDescribe().isAccessible() 
                    && d.getDescribe().getKeyPrefix()!=null && !d.getDescribe().isCustomSetting()     
                           && !objRejected1.equalsIgnoreCase(d.getDescribe().getLabel())
                           && !objRejected2.equalsIgnoreCase(d.getDescribe().getLabel()) ) {
                     mapNameCustomObjects.put( d.getDescribe().getName(), 
                                               new Tabs_system__c(label__c = d.getDescribe().getLabel(), 
                                                               api_name__c = d.getDescribe().getName(), 
                                                               key_prefix__c = d.getDescribe().getKeyPrefix()) );
                    /* listNonPriorityTabs.add( new ObjectLabel(d.getDescribe().getLabel(),
                                                    d.getDescribe().getName(),
                                                    d.getDescribe().getKeyPrefix()));*/
                }
           } 
        }      
        
        populateMaps();
        
        listNonPriorityTabs.clear();
        for(String value: mapCustomObjectsNameLabel.keySet()) {
               
            listNonPriorityTabs.add( new TabsObjectLabel(TabsObjectClass.mapCustomObjectsNameLabel.get(value),
                                                    value,
                                                    TabsObjectClass.mapCustomObjectsNamePrefix.get(value)));
        }
        
        listNonPriorityTabs.sort();
        
        listApiName = new List<String>(mapNameCustomObjects.keySet());
        
        if(moreObj.size()!=0) {
            objUserPrefTab = moreObj.get(0);
            if(!validatePreferences()) {
                if( listApiName.size() == 1 ) {
                    objUserPrefTab.preference_tab_1__c = listApiName.get(0);
                    DELETE objUserPrefTab;
                }
                if( listApiName.size() == 2 ) {
                    objUserPrefTab.preference_tab_1__c = listApiName.get(0);
                    objUserPrefTab.preference_tab_2__c = returnNonRepeatValue(2);
                    DELETE objUserPrefTab;
                }
                if( listApiName.size() == 3 ) {
                    objUserPrefTab.preference_tab_1__c = listApiName.get(0);
                    objUserPrefTab.preference_tab_2__c = returnNonRepeatValue(2);
                    objUserPrefTab.preference_tab_3__c = returnNonRepeatValue(3);
                    DELETE objUserPrefTab;
                }
                if( listApiName.size() == 4 ) {
                    objUserPrefTab.preference_tab_1__c = listApiName.get(0);
                    objUserPrefTab.preference_tab_2__c = returnNonRepeatValue(2);
                    objUserPrefTab.preference_tab_3__c = returnNonRepeatValue(3);
                    objUserPrefTab.preference_tab_4__c = returnNonRepeatValue(4);
                    DELETE objUserPrefTab;
                }
                if( listApiName.size() == 5 ) {
                    objUserPrefTab.preference_tab_1__c = listApiName.get(0);
                    objUserPrefTab.preference_tab_2__c = returnNonRepeatValue(2);
                    objUserPrefTab.preference_tab_3__c = returnNonRepeatValue(3);
                    objUserPrefTab.preference_tab_4__c = returnNonRepeatValue(4);
                    objUserPrefTab.preference_tab_5__c = returnNonRepeatValue(5);
                    DELETE objUserPrefTab;
                }
                if( listApiName.size() > 5 ) {
                    objUserPrefTab.preference_tab_1__c = listApiName.get(0);
                    objUserPrefTab.preference_tab_2__c = returnNonRepeatValue(2);
                    objUserPrefTab.preference_tab_3__c = returnNonRepeatValue(3);
                    objUserPrefTab.preference_tab_4__c = returnNonRepeatValue(4);
                    objUserPrefTab.preference_tab_5__c = returnNonRepeatValue(5);
                    
                    System.debug('$$$$Updating: '+objUserPrefTab.preference_tab_1__c+' '+objUserPrefTab.preference_tab_2__c+' '
                                +objUserPrefTab.preference_tab_3__c+' '+objUserPrefTab.preference_tab_4__c+' '
                                +objUserPrefTab.preference_tab_5__c);
                    UPDATE objUserPrefTab;
                }
            }
        } else {
            objUserPrefTab  = new Tabs_Preference__c();
            if( listApiName.size() >=1 ) {
                objUserPrefTab.preference_tab_1__c = listApiName.get(0);
            }
            if( listApiName.size() >=2 ) {
                objUserPrefTab.preference_tab_2__c = returnNonRepeatValue(2);
            }
            if( listApiName.size() >=3 ) {
                objUserPrefTab.preference_tab_3__c = returnNonRepeatValue(3);
            }
            if( listApiName.size() >=4 ) {
                objUserPrefTab.preference_tab_4__c = returnNonRepeatValue(4);
            }
            if( listApiName.size() >=5 ) {
                objUserPrefTab.preference_tab_5__c = returnNonRepeatValue(5);
            }
        }
        
        
        if(listNonPriorityTabs.size() >=1) {
            
            listPriorityTabs.add(new TabsObjectLabel(mapCustomObjectsNameLabel.get(objUserPrefTab.preference_tab_1__c), 
                                                objUserPrefTab.preference_tab_1__c,
                                                mapCustomObjectsNamePrefix.get(objUserPrefTab.preference_tab_1__c)));                                    
        }
        if(listNonPriorityTabs.size() >=2) {
            
            listPriorityTabs.add(new TabsObjectLabel(mapCustomObjectsNameLabel.get(objUserPrefTab.preference_tab_2__c), 
                                                objUserPrefTab.preference_tab_2__c,
                                                mapCustomObjectsNamePrefix.get(objUserPrefTab.preference_tab_2__c)));
        }
        if(listNonPriorityTabs.size() >=3) {
            
            listPriorityTabs.add(new TabsObjectLabel(mapCustomObjectsNameLabel.get(objUserPrefTab.preference_tab_3__c), 
                                                    objUserPrefTab.preference_tab_3__c,
                                                    mapCustomObjectsNamePrefix.get(objUserPrefTab.preference_tab_3__c)));
        }
        if(listNonPriorityTabs.size() >=4) {
            
            listPriorityTabs.add(new TabsObjectLabel(mapCustomObjectsNameLabel.get(objUserPrefTab.preference_tab_4__c), 
                                                objUserPrefTab.preference_tab_4__c,
                                                mapCustomObjectsNamePrefix.get(objUserPrefTab.preference_tab_4__c)));
        }
        if(listNonPriorityTabs.size() >=5) {
            
            listPriorityTabs.add(new TabsObjectLabel(mapCustomObjectsNameLabel.get(objUserPrefTab.preference_tab_5__c), 
                                                objUserPrefTab.preference_tab_5__c,
                                                mapCustomObjectsNamePrefix.get(objUserPrefTab.preference_tab_5__c)));
        }
        
        if(listApiName!=null) {
            listApiName.clear();
        }
        if(presentList!=null) {
            presentList.clear();
        }
        
        return objUserPrefTab;
    }
    
    private static Boolean  validatePreferences(){
        Integer flag=0;
        System.debug('$$$$Validating : 1-'+mapNameCustomObjects.containsKey(objUserPrefTab.preference_tab_1__c)
                            +' 2-'+mapNameCustomObjects.containsKey(objUserPrefTab.preference_tab_2__c)
                            +' 3-'+mapNameCustomObjects.containsKey(objUserPrefTab.preference_tab_3__c)
                            +' 4-'+mapNameCustomObjects.containsKey(objUserPrefTab.preference_tab_4__c)
                            +' 5-'+mapNameCustomObjects.containsKey(objUserPrefTab.preference_tab_5__c));
        if(!mapNameCustomObjects.containsKey(objUserPrefTab.preference_tab_1__c)){
            objUserPrefTab.preference_tab_1__c = null;
            flag=1;
        }
        if(!mapNameCustomObjects.containsKey(objUserPrefTab.preference_tab_2__c)){
            objUserPrefTab.preference_tab_2__c = null;
            flag=1;
        }
        if(!mapNameCustomObjects.containsKey(objUserPrefTab.preference_tab_3__c)){
            objUserPrefTab.preference_tab_3__c = null;
            flag=1;
        }
        if(!mapNameCustomObjects.containsKey(objUserPrefTab.preference_tab_4__c)){
            objUserPrefTab.preference_tab_4__c = null;
            flag=1;
        }
        if(!mapNameCustomObjects.containsKey(objUserPrefTab.preference_tab_5__c)){
            objUserPrefTab.preference_tab_5__c = null;
            flag=1;
        }
        
        System.debug('$$$$Validated : 1-'+objUserPrefTab.preference_tab_1__c+' 2-'+objUserPrefTab.preference_tab_2__c
                            +' 3-'+objUserPrefTab.preference_tab_3__c+' 4-'+objUserPrefTab.preference_tab_4__c
                            +' 5-'+objUserPrefTab.preference_tab_5__c);
        if(flag==1){
            return false;
        }
        return true;
    }
    
    private static String returnNonRepeatValue(Integer tab){
        if(objUserPrefTab!=null){
            if(tab==2){
                System.debug('####listApiName:'+listApiName);
                System.debug('####Tab 2 objUserPrefTab.preference_tab_1__c: '+objUserPrefTab.preference_tab_1__c);
                System.debug('####Tab 2 objUserPrefTab.preference_tab_3__c: '+objUserPrefTab.preference_tab_3__c);
                System.debug('####Tab 2 objUserPrefTab.preference_tab_4__c: '+objUserPrefTab.preference_tab_4__c);
                System.debug('####Tab 2 objUserPrefTab.preference_tab_5__c: '+objUserPrefTab.preference_tab_5__c);
                //System.debug('####Tab 2: '+objUserPrefTab.preference_tab_1__c);
                for(String value : listApiName){
                    System.debug('####Tab 2 value:'+value);
                    if( value!= objUserPrefTab.preference_tab_1__c ){ 
                        System.debug('####Tab 2 Found: '+value);
                        return value;
                    }
                }
            } else if(tab==3){
                System.debug('####Tab 3: '+objUserPrefTab.preference_tab_1__c+' '+objUserPrefTab.preference_tab_2__c);
                for(String value : listApiName){
                    if( value!= objUserPrefTab.preference_tab_1__c
                        && value!= objUserPrefTab.preference_tab_2__c ){
                        System.debug('####Tab 3 Found: '+value);
                        return value;
                    }
                }
            } else if(tab==4){
                System.debug('####Tab 4: '+objUserPrefTab.preference_tab_1__c+' '+objUserPrefTab.preference_tab_2__c
                                +' '+objUserPrefTab.preference_tab_3__c);
                for(String value : listApiName){
                    if( value!= objUserPrefTab.preference_tab_1__c
                        && value!= objUserPrefTab.preference_tab_2__c
                        && value!= objUserPrefTab.preference_tab_3__c ){
                        System.debug('####Tab 4 Found: '+value);
                        return value;
                    }
                }
            } else if(tab==5){
                System.debug('####Tab 5: '+objUserPrefTab.preference_tab_1__c+' '+objUserPrefTab.preference_tab_2__c
                                +' '+objUserPrefTab.preference_tab_3__c+' '+objUserPrefTab.preference_tab_4__c);
                for(String value : listApiName){
                    if(value!= objUserPrefTab.preference_tab_1__c
                            && value!= objUserPrefTab.preference_tab_2__c
                            && value!= objUserPrefTab.preference_tab_3__c
                            && value!= objUserPrefTab.preference_tab_4__c){
                        System.debug('####Tab 5 Found: '+value);
                        return value;
                    }
                }
            }
        }
        return null;
    }
    
}