public class TabsCustomizeController {


    private static String objRejected1 = System.Label.Tabs_Object_More_Neglect;
    private static String objRejected2 = System.Label.Tabs_Object_SystemTab_Neglect;
     public List<String> alphabetsSet {get; private set;}
    Map<String, Schema.SObjectType> gd=new  Map<String, Schema.SObjectType>();

    Set<String> keyPrefixSet2=new Set<String>();
    Set<String> keyPrefixSet3=new Set<String>();

    List<Tabs_system__c> systemTabList= new List<Tabs_system__c>();
    List<Tabs_system__c> tempSortystemTabList= new List<Tabs_system__c>();
          
    public Set<String> getKeyPrefixSet2() {
        return keyPrefixSet2;
    }

    public List<Tabs_system__c> getSystemTabList () {
        return systemTabList;
    }
    
      
    

    public void onloadCustomizeTabsController() {
        
              
        List<String> presentFieldApiList = new List<String>(); 
        Schema.DescribeSObjectResult gdSObject;
        Tabs_system__c stc;
        

     
   
        List<Tabs_system__c> presentList = [SELECT id,Label__c,Keep__c,api_name__c FROM Tabs_system__c]; 
  
        gd = Schema.getGlobalDescribe();   
        
        alphabetsSet=new List<String>();
        for(Integer i=65;i<=90;i++) {
             alphabetsSet.add(String.fromCharArray(new Integer[]{i}));
        }
        alphabetsSet.add('ALL');  
       
          if(presentList.size()>0 && presentList!=null)   
         { 
          
                                    for(Tabs_system__c s1:presentList)
                                    {   
                                        presentFieldApiList.add(s1.api_name__c);
                                    }
                         
                                    systemTabList =sortList(presentList,'Label__c','asc');
                                                                     
                                                 
                                   for(String sObj : gd.keySet())  
                                   {
                                            gdSObject= gd.get(sObj).getDescribe();   
                                                
                                            if(gdSObject.getKeyPrefix()!=null && gdSObject.custom==true  && gdSObject.customSetting==false && gdSObject.accessible && !objRejected1.equalsIgnoreCase(gdSObject.getLabel())  && !objRejected2.equalsIgnoreCase(gdSObject.getLabel()) )     
                                         
                                           {
                                                keyPrefixSet2.add(sObj);  
                                           }                                                                    
                                   }
                                 
                                      
                                  if(!(keyPrefixSet2.containsAll(presentFieldApiList)) && presentFieldApiList.size()>keyPrefixSet2.size())   
                                    {
                                          
                                                keyPrefixSet3.addAll(presentFieldApiList);
                                            
                                                if( (keyPrefixSet3.removeAll(keyPrefixSet2))  )   
                                                {
                                                   // List<Tabs_system__c> slctemp1= [SELECT id,Label__c,Keep__c,api_name__c FROM Tabs_system__c where api_name__c IN :keyPrefixSet3];
                                                    DELETE [SELECT id,Label__c,Keep__c,api_name__c FROM Tabs_system__c where api_name__c IN :keyPrefixSet3];
                                                   systemTabList = [SELECT id,Label__c,Keep__c,api_name__c FROM Tabs_system__c limit 2000]; 
                                                    systemTabList = sortList(systemTabList,'Label__c','asc');
                                                }      
                                                    
                                    }    
                                    else  
                                    {
                                                if( ! (keyPrefixSet2.removeAll(presentFieldApiList) && keyPrefixSet2.size()==0 ))  
                                                {
                                                       for(String sObj : keyPrefixSet2)  
                                                       {
                                                               gdSObject= gd.get(sObj).getDescribe();   
                                                         
                                                               if(gdSObject.getKeyPrefix()!=null && gdSObject.custom==true  && gdSObject.customSetting==false && gdSObject.accessible && !objRejected1.equalsIgnoreCase(gdSObject.getLabel())  && !objRejected2.equalsIgnoreCase(gdSObject.getLabel()) )     
                                                                {
                                                                      systemTabList.add(new Tabs_system__c(Label__c= gdSObject.getLabel(),api_name__c= sObj ,Key_prefix__c= gdSObject.getKeyPrefix()));
                                                                }                                                                    
                                                      
                                                        }
                                                       systemTabList = sortList(systemTabList,'Label__c','asc');
                                                       UPSERT systemTabList;    
                                                
                                                }
                                     }     
                                   
                               
          }  
          else 
          {  
                      
                                                      
                            for(String sObj :  gd.keySet())    
                              {
                                
                                       gdSObject= gd.get(sObj).getDescribe();   
                                          
                                       if(gdSObject.getKeyPrefix()!=null && gdSObject.custom==true  && gdSObject.customSetting==false && gdSObject.accessible && !objRejected1.equalsIgnoreCase(gdSObject.getLabel())  && !objRejected2.equalsIgnoreCase(gdSObject.getLabel()) )     
                                                                          
                                        {
                                                                               
                                              systemTabList.add(new Tabs_system__c(Label__c= gdSObject.getLabel(),api_name__c= sObj ,Key_prefix__c= gdSObject.getKeyPrefix()));
                                                            
                                        }                                                                    
                           
                              }
                           systemTabList = sortList(systemTabList,'Label__c','asc');
                           UPSERT systemTabList;
                   
     
             } 
    }

    public PageReference save()
    {
    
        UPDATE systemTabList;
        
        PageReference acctPage = new PageReference(System.Label.Tabs_HomePage_URL);        
        acctPage.setRedirect(true);
        return acctPage;
         
    }
    
    
    
     public PageReference cancel(){
        
        PageReference returnPage = new PageReference(System.Label.Tabs_HomePage_URL);
        
        return returnPage;
    }


    public static List<sObject> sortList(List<sObject> items,String sortField,String order)
    {
        List<sObject> resultList = new List<sObject>();
        //Create a map that can be used for sorting 
        Map<object, List<sObject>> objectMap = new Map<object, List<sObject>>();
        
        for(sObject ob : items) {
            if(objectMap.get(ob.get(sortField)) == null) {
                // For non Sobject use obj.ProperyName
                objectMap.put(ob.get(sortField), new List<sObject>());
            }
            objectMap.get(ob.get(sortField)).add(ob);
        }
    
        //Sort the keys
        List<object> keys = new List<object>(objectMap.keySet());
        keys.sort();
        for(object key : keys) {
            resultList.addAll(objectMap.get(key));
        }
        
        //Apply the sorted values to the source list
        items.clear();
        if(order.toLowerCase() == 'asc') {
            for(Sobject ob : resultList)
                items.add(ob);
        }
        else if(order.toLowerCase() == 'desc') {
            for(integer i = resultList.size()-1; i >= 0; i--)
                items.add(resultList[i]);
        }
        
        return items;
    }



}