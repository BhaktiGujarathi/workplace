public class TabsSetPreferenceController {

private String user;
    private static final Integer PriorityLimit = 5;
    
    private List<TabsObjectLabel> listNonPriorityTabs {get; private set;}
    private Tabs_Preference__c objUserPrefTab;
    
    public String strTabObject1 {get; set;}
    public Boolean isTabObject1  {get; private set;}
    
    public String strTabObject2 {get; set;}
    public Boolean isTabObject2  {get; private set;}
    
    public String strTabObject3 {get; set;}
    public Boolean isTabObject3  {get; private set;}
    
    public String strTabObject4 {get; set;}
    public Boolean isTabObject4  {get; private set;}
    
    public String strTabObject5 {get; set;}
    public Boolean isTabObject5  {get; private set;}
    
    public TabsSetPreferenceController () {
        user = UserInfo.getUserId();
        
        objUserPrefTab = TabsObjectClass.objUserPrefTab;
        
        listNonPriorityTabs = new List<TabsObjectLabel>();
        listNonPriorityTabs.addAll(TabsObjectClass.listNonPriorityTabs);
        
        isTabObject1  = isTabObject2  = isTabObject3  = isTabObject4  = isTabObject5  = false;
        
        if( listNonPriorityTabs.size() <= PriorityLimit) {
            if(listNonPriorityTabs.size()>=1){
                isTabObject1  = true;
                
                strTabObject1 = objUserPrefTab.preference_tab_1__c;
                
            } 
             if(listNonPriorityTabs.size()>=2){
                isTabObject1  = isTabObject2  = true;
                
               
                strTabObject2 = objUserPrefTab.preference_tab_2__c;
                
            } 
             if(listNonPriorityTabs.size()>=3){
                isTabObject1  = isTabObject2  = isTabObject3  = true;
               
                strTabObject3 = objUserPrefTab.preference_tab_3__c;
                
            } 
            if(listNonPriorityTabs.size()>=4){
                isTabObject1  = isTabObject2  = isTabObject3  = isTabObject4  = true;
                
               
                strTabObject4 = objUserPrefTab.preference_tab_4__c;
                
            } 
            if(listNonPriorityTabs.size()>=5) {
                isTabObject1  = isTabObject2  = isTabObject3  = isTabObject4  = isTabObject5  = true;
                
                strTabObject1 = objUserPrefTab.preference_tab_1__c;
                strTabObject2 = objUserPrefTab.preference_tab_2__c;
                strTabObject3 = objUserPrefTab.preference_tab_3__c;
                strTabObject4 = objUserPrefTab.preference_tab_4__c;
                strTabObject5 = objUserPrefTab.preference_tab_5__c;
            }
        } else {
            isTabObject1  = isTabObject2  = isTabObject3  = isTabObject4  = isTabObject5  = true;
            
            strTabObject1 = objUserPrefTab.preference_tab_1__c;
            strTabObject2 = objUserPrefTab.preference_tab_2__c;
            strTabObject3 = objUserPrefTab.preference_tab_3__c;
            strTabObject4 = objUserPrefTab.preference_tab_4__c;
            strTabObject5 = objUserPrefTab.preference_tab_5__c;
            
        }
            
    }
    
    public List<SelectOption> getOptions() {
    
       Tabs_Preference__c objUserPrefTab;
       List<SelectOption> options = new list<SelectOption>();
      
       for( TabsObjectLabel obj : TabsObjectClass.listNonPriorityTabs) {
           options.add(new SelectOption(obj.apiName, obj.Label)); 
       }
       return options;
    }
    
    public PageReference cancel(){
        
        PageReference returnPage = new PageReference(System.Label.Tabs_HomePage_URL);
        
        return returnPage;
    }
    
    public PageReference savePreference(){
        
         Tabs_Preference__c objUserPrefTab;

         PageReference page;
         
         if(strTabObject1.equals(strTabObject2)|| strTabObject1.equals(strTabObject3) 
           || strTabObject1.equals(strTabObject4) || strTabObject1.equals(strTabObject5)
           || strTabObject2.equals(strTabObject3) || strTabObject2.equals(strTabObject4)
           || strTabObject2.equals(strTabObject5) || strTabObject3.equals(strTabObject4)
           || strTabObject3.equals(strTabObject5) || strTabObject4.equals(strTabObject5)) {
           
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select Different Tabs'));
           return null;
           
        } else {

            List<Tabs_Preference__c> moreObj = [ SELECT id, userid__c, preference_tab_1__c, 
                                            preference_tab_2__c, preference_tab_3__c,
                                            preference_tab_4__c, preference_tab_5__c
                                      FROM Tabs_Preference__c
                                      WHERE userid__c = :user ];
                                      
            if(moreObj.size()==0) {

                objUserPrefTab= new Tabs_Preference__c();
                objUserPrefTab.userid__c = user;

                if(isTabObject1)
                    objUserPrefTab.preference_tab_1__c = strTabObject1;
                if(isTabObject2)
                    objUserPrefTab.preference_tab_2__c = strTabObject2;
                if(isTabObject3)
                    objUserPrefTab.preference_tab_3__c = strTabObject3;
                if(isTabObject4)
                    objUserPrefTab.preference_tab_4__c = strTabObject4;
                if(isTabObject5)
                    objUserPrefTab.preference_tab_5__c = strTabObject5;
                    
                INSERT objUserPrefTab;
            } else {

                objUserPrefTab= moreObj.get(0);
               
                if(isTabObject1)
                    objUserPrefTab.preference_tab_1__c = strTabObject1;
                if(isTabObject2)
                    objUserPrefTab.preference_tab_2__c = strTabObject2;
                if(isTabObject3)
                    objUserPrefTab.preference_tab_3__c = strTabObject3;
                if(isTabObject4)
                    objUserPrefTab.preference_tab_4__c = strTabObject4;
                if(isTabObject5)
                    objUserPrefTab.preference_tab_5__c = strTabObject5;
                                       
                UPDATE objUserPrefTab;
            }
            
            page = new PageReference(System.Label.Tabs_HomePage_URL);
            page.setRedirect(true);
        }
        
        return page;
    }
    
    


}