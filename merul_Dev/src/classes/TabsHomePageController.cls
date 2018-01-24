public class TabsHomePageController {

 private  final Integer PriorityLimit = 5;
    
    private  String user;
    
    private  Tabs_Preference__c objUserPrefTab;
    
  
    public String fromJS {get; set;}

    public Boolean isSetPreferenceTabLink {get; private set;}
    public Boolean  isDisplayTabPanel {get; private set;}
    public Boolean  isError {get; private set;}

       
    public List<String> alphabetsSet {get; private set;}
    
    public  List<TabsObjectLabel> listPartialNPTabs {get; private set;}
    public List<TabsObjectLabel> listNP1 {get; private set;}
    public List<TabsObjectLabel> listNP2 {get; private set;}
    
    public  List<TabsObjectLabel> listPriorityTabs {get; private set;}
    public  List<TabsObjectLabel> listNonPriorityTabs {get; private set;}
    
    public String strTabObject1 {get; set;}
    public String pObjectLabel1 {get; private set;}
    public String pObjectApi1 {get; private set;}
    public Boolean isPreferenceTab1 {get; private set;}
    
    public String strTabObject2 {get; set;}
    public String pObjectLabel2 {get; private set;}
    public String pObjectApi2 {get; private set;}
    public Boolean isPreferenceTab2 {get; private set;}
    
    public String strTabObject3 {get; set;}
    public String pObjectLabel3 {get; private set;}
    public String pObjectApi3 {get; private set;}
    public Boolean isPreferenceTab3  {get; private set;}
    
    public String strTabObject4 {get; set;}
    public String pObjectLabel4 {get; private set;}
    public String pObjectApi4 {get; private set;} 
    public Boolean isPreferenceTab4 {get; private set;} 
    
    public String strTabObject5 {get; set;}
    public String pObjectLabel5 {get; private set;}
    public String pObjectApi5 {get; private set;}
    public Boolean isPreferenceTab5 {get; private set;} 
    
    public Boolean isRenderedMore {get; private set;} 
  
     Cookie counter ;
  
    public void onloadSubTabsController() {
         objUserPrefTab =  TabsObjectClass.checkValidTabs();
        if(objUserPrefTab!=null) {
           setPagePrefTabs();
        }
        listPartialNPTabs.clear();
        listPartialNPTabs.addAll(listNonPriorityTabs);
        setListDisplay();
        
    }
    

    public TabsHomePageController() {
        
        user = UserInfo.getUserId();

        alphabetsSet=new List<String>();
        for(Integer i=65;i<=90;i++) {
             alphabetsSet.add(String.fromCharArray(new Integer[]{i}));
        }
        alphabetsSet.add('ALL');
        
        isRenderedMore = isSetPreferenceTabLink = false;
        isPreferenceTab1 = isPreferenceTab2 = isPreferenceTab3 = isPreferenceTab4 = isPreferenceTab5 = false;
        isDisplayTabPanel=true;
        isError=false;
            
        listPriorityTabs = new List<TabsObjectLabel>();
        listPriorityTabs.addAll(TabsObjectClass.listPriorityTabs);
        
        listNonPriorityTabs = new List<TabsObjectLabel>();
        listNonPriorityTabs.addAll(TabsObjectClass.listNonPriorityTabs);
        
        listPartialNPTabs = new List<TabsObjectLabel>();
        listNP1 = new List<TabsObjectLabel>();
        listNP2 = new List<TabsObjectLabel>();  
        
        
        
                
      
      if(listPriorityTabs.size()==0)  
      { 

        isDisplayTabPanel=false;
          isError=true;
        
      }
         
      else 
                   
      {       
                    
          if( listNonPriorityTabs.size() <= PriorityLimit)  
                             {
                                        if(listPriorityTabs.size()>=1){
                                            isPreferenceTab1 = true;
                                            
                                            pObjectApi1= listPriorityTabs.get(0).ApiName; 
                                            pObjectLabel1= listPriorityTabs.get(0).Label;
                                        }
                                        
                                         if(listPriorityTabs.size()>=2){
                                            isPreferenceTab1 = isPreferenceTab2 = true;
                                            
                                           
                                            pObjectApi2= listPriorityTabs.get(1).ApiName; pObjectLabel2= listPriorityTabs.get(1).Label;
                                        } 
                                         if(listPriorityTabs.size()>=3){
                                            isPreferenceTab1 = isPreferenceTab2 = isPreferenceTab3 = true;
                                            
                                           pObjectApi3= listPriorityTabs.get(2).ApiName; pObjectLabel3= listPriorityTabs.get(2).Label;
                                        }  
                                         if(listPriorityTabs.size()>=4){
                                            isPreferenceTab1 = isPreferenceTab2 = isPreferenceTab3 = isPreferenceTab4 = true;
                                            
                                           pObjectApi4= listPriorityTabs.get(3).ApiName; pObjectLabel4= listPriorityTabs.get(3).Label;
                                        }   
                                         if(listPriorityTabs.size()>=5) {
                                            isPreferenceTab1 = isPreferenceTab2 = isPreferenceTab3 = isPreferenceTab4 = isPreferenceTab5 = true;
                                            pObjectApi5= listPriorityTabs.get(4).ApiName; pObjectLabel5= listPriorityTabs.get(4).Label;
                                        }
                               }    
                               else
                              {
                                            
                                    isRenderedMore = isSetPreferenceTabLink = true;
                                    isPreferenceTab1 = isPreferenceTab2 = isPreferenceTab3 = isPreferenceTab4 = isPreferenceTab5 = true;
                                    objUserPrefTab = TabsObjectClass.objUserPrefTab;
                                    
                                    setPagePrefTabs();
                              }
  
    
          }
   
 
 
       }
    
    public PageReference save() {
 
        PageReference pageRef = new PageReference(
                    '/'+
                    TabsObjectClass.mapCustomObjectsNamePrefix.get(ApexPages.currentPage().getParameters().get('target')));
        pageRef.setRedirect(true);
        
        return pageRef;
    }
  
      
    public void sortList() {
       
   
       
         listPartialNPTabs.clear();
       
         String sortAlphabet =System.currentPageReference().getParameters().get('sortAlphabet');
       
       if(sortAlphabet.equalsIgnoreCase('ALL'))   
       {
           listPartialNPTabs.addAll(listNonPriorityTabs);
       }
       else     
       {
            
 
                    for(TabsObjectLabel temp : listNonPriorityTabs)   
                     {
                      if( temp.label.startsWithIgnoreCase(sortAlphabet))
                          listPartialNPTabs.add(temp);
                     }
       }
     
    
       setListDisplay();
       
    }
  
      

    public void setListDisplay() { 
 
        listNP1.clear();    
        listNP2.clear();

        Integer  totalSize = listPartialNPTabs.size();   
        Decimal  value = (Decimal) totalSize / 2;           
        Integer  size1 =  Math.ceil(value).intValue();
        Integer  size2 =  totalSize - size1;
        Integer  mod = Math.mod(totalSize,2);        
        
        if(mod == 0) {
            for(Integer i=0; i < size1; i++) {
                listNP1.add(listPartialNPTabs.get(i));
                listNP2.add(listPartialNPTabs.get(size2+i));
            }
        } else {
            for(Integer i=0; i < size1; i++) {
                listNP1.add(listPartialNPTabs.get(i));
                if(i!=size2)
                    listNP2.add(listPartialNPTabs.get(size2+1+i));
            }
        }
    }

    public void setPagePrefTabs() {
        pObjectApi1= objUserPrefTab.preference_tab_1__c;
        pObjectLabel1= TabsObjectClass.mapCustomObjectsNameLabel.get(objUserPrefTab.preference_tab_1__c);
        strTabObject1= pObjectLabel1;
                
        pObjectApi2= objUserPrefTab.preference_tab_2__c;
        pObjectLabel2= TabsObjectClass.mapCustomObjectsNameLabel.get(objUserPrefTab.preference_tab_2__c);
        strTabObject2= pObjectLabel2;
         
        pObjectApi3= objUserPrefTab.preference_tab_3__c;
        pObjectLabel3= TabsObjectClass.mapCustomObjectsNameLabel.get(objUserPrefTab.preference_tab_3__c);
        strTabObject3= pObjectLabel3;
        
        pObjectApi4= objUserPrefTab.preference_tab_4__c;
        pObjectLabel4= TabsObjectClass.mapCustomObjectsNameLabel.get(objUserPrefTab.preference_tab_4__c);
        strTabObject4= pObjectLabel4;
        
        pObjectApi5= objUserPrefTab.preference_tab_5__c;
        pObjectLabel5= TabsObjectClass.mapCustomObjectsNameLabel.get(objUserPrefTab.preference_tab_5__c);
        strTabObject5= pObjectLabel5;
    }

    
    public PageReference goToSetPreferenceTab(){
        
        PageReference returnPage = new PageReference(System.Label.Tabs_SetPreferenceTab_URL);
        
        return returnPage;
    }
    
     public PageReference cancel(){
        
        PageReference returnPage = new PageReference(System.Label.Tabs_HomePage_URL);
        
        return returnPage;
    }
    
  



}