/**************************************************************************************************
* Name               : DamacProjectController                                               
* Description        : An apex page controller for                                              
* Created Date       : NSI - Diana                                                                        
* Created By         : 24/Jan/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          24/Jan/2017                                                               
**************************************************************************************************/

public without sharing class DamacProjectController {
    /**************************************************************************************************
            Variables used in the class
    **************************************************************************************************/
    public List<String> projectType{set;get;} // show type filter in VF
    public List<String> locationNames{set;get;} // show location filter in VF
    public List<String> bedrooms{set;get;}

    public List<List<Object>> mapMarkers{set;get;}
    public Integer noOfMarkers{set;get;}

    public List<ProjectWrapper> projectsAssigned{set;get;}

    private Set<Id> PropertyIDs;
    private Set<Id> InventoryIDs;

    private String inventoryIdQuery;
    private string groupByClause;
    private String generalInventoryQuery;

    public string tabName{set;get;}
    public String userId{set;get;}
    public String bedroomsSelectedFromURL{set;get;}
    public String typeSelectedFromURL{set;get;}
    public String locationSelectedFromURL{set;get;}
    

    /**************************************************************************************************
    Method:         DamacProjectController
    Description:    Constructor executing model of the class 
    **************************************************************************************************/
    
    public DamacProjectController() {
        
        projectType = UtilityQueryManager.getAllProjectTypes();
        system.debug('***projectType'+projectType);
        locationNames = UtilityQueryManager.getAllCities();
        bedrooms = UtilityQueryManager.getAllBedRooms();

        if(ApexPages.currentPage().getParameters().containsKey('sfdc.tabName')){
            tabName = ApexPages.currentPage().getParameters().get('sfdc.tabName');
        }
        
        userId = UserInfo.getUserId();
        
        getAllProperties();

        
    }

    /**************************************************************************************************
    Method:         DamacProjectController
    Description:    Constructor executing model of the class 
    **************************************************************************************************/
    public void filterProjects(){

        String LocationNameSelected = ApexPages.currentPage().getParameters().get('locationNamesSelected');
        String ProjectTypeSelected = ApexPages.currentPage().getParameters().get('projectTypeSelected');
        String BedroomsSelected = ApexPages.currentPage().getParameters().get('BedroomsSelected');

        inventoryIdQuery ='SELECT Inventory__c from Inventory_User__c where Inventory__r.Status__c = \'RELEASED\''+
                          ' AND Inventory__r.Unit_Location__c != null AND End_Date__c >= TODAY'+ 
                          ' AND Inventory__r.Address__c != null AND User__c=\''+UserInfo.getUserId()+'\'';

        system.debug('***locationNameSelected '+LocationNameSelected);
        system.debug('***ProjectTypeSelected '+ProjectTypeSelected);
        
        String generalInventoryQuery = 'SELECT Id from Inventory__c where Status__c=\'RELEASED\' AND Unit_Location__c != null'+
                                ' AND Address__c != null AND Is_Assigned__c = false';

        //Location Name Selected is blank or All then dont include it in query
        if(null != LocationNameSelected && '\'\'' != LocationNameSelected && LocationNameSelected != '\'All\'' ){
            inventoryIdQuery += ' AND Inventory__r.Address__r.City__c IN ('+LocationNameSelected+')';
            generalInventoryQuery += ' AND Address__r.City__c IN ('+LocationNameSelected+')';
            system.debug('**location query '+inventoryIdQuery);
        }
        
        if(null != ProjectTypeSelected && '\'\'' != ProjectTypeSelected && ProjectTypeSelected != '\'All\''){
            inventoryIdQuery +=  'AND Inventory__r.Unit_Type__c IN '+
                            '('+ProjectTypeSelected+')';
            generalInventoryQuery += ' AND Unit_Type__c IN '+
                            '('+ProjectTypeSelected+')';
            system.debug('**type query '+inventoryIdQuery);
        }
        
        if(null != BedroomsSelected && '\'\'' != BedroomsSelected && BedroomsSelected != '\'All\'' ){
            inventoryIdQuery += ' AND Inventory__r.IPMS_Bedrooms__c IN ('+BedroomsSelected+')';
            generalInventoryQuery += ' AND IPMS_Bedrooms__c IN ('+BedroomsSelected+')';
            system.debug('**location query '+inventoryIdQuery);
        }

        system.debug(inventoryIdQuery);

        InventoryIDs = UtilityQueryManager.getInventoryIDs(inventoryIdQuery);
        
        system.debug('**** InventoryIDs'+InventoryIDs);
        system.debug('**** generalInventoryQuery'+generalInventoryQuery);
        
        //get all inventories from the general inventory pool
        Set<ID> generalInventoryId = UtilityQueryManager.getAllGeneralInventories(generalInventoryQuery);
        system.debug('**** generalInventoryId '+generalInventoryId );
        InventoryIDs.addAll(generalInventoryId);
        system.debug('**** InventoryIDs'+InventoryIDs);
        
        PropertyIDs = UtilityQueryManager.getPropertyIDs(InventoryIDs);

        system.debug('***PropertyIDs '+PropertyIDs);
        
        projectsAssigned = new List<ProjectWrapper>();
        projectsAssigned =getProjectLists(PropertyIDs);
        
        system.debug('**projectsAssigned '+projectsAssigned);
        getMarkers();
    }

    public void getAllProperties(){
        inventoryIdQuery ='SELECT Inventory__c from Inventory_User__c where Inventory__r.Status__c = \'RELEASED\' AND Inventory__r.Unit_Location__c != null'+ 
                                     ' AND Inventory__r.Address__c != null AND End_Date__c >= TODAY AND User__c=\''+UserInfo.getUserId()+'\'';

        generalInventoryQuery = 'SELECT Id from Inventory__c where Status__c=\'RELEASED\' AND Unit_Location__c != null'+
                                ' AND Address__c != null AND Is_Assigned__c = false';

        if(ApexPages.currentPage().getParameters().containsKey('Bedrooms') && ApexPages.currentPage().getParameters().get('Bedrooms') != ''
                && ApexPages.currentPage().getParameters().get('Bedrooms') != 'All'){
             bedroomsSelectedFromURL = ApexPages.currentPage().getParameters().get('Bedrooms');
            
            List<String> bedroomsSelectedLists = bedroomsSelectedFromURL.split(',');
            
            if(null != bedroomsSelectedLists){
                inventoryIdQuery += ' AND Inventory__r.IPMS_Bedrooms__c IN (\''+String.join(bedroomsSelectedLists,'\',\'')+'\')';
                generalInventoryQuery += ' AND IPMS_Bedrooms__c IN (\''+String.join(bedroomsSelectedLists,'\',\'')+'\')';
                system.debug('**location query '+inventoryIdQuery);
            }
             
           
         }  
         
         if(ApexPages.currentPage().getParameters().containsKey('Type') && ApexPages.currentPage().getParameters().get('Type') != ''
            && ApexPages.currentPage().getParameters().get('Type') != 'All'){
           typeSelectedFromURL= ApexPages.currentPage().getParameters().get('Type');
            
            List<String> typeSelectedLists= typeSelectedFromURL.split(',');
            
            if(null != typeSelectedLists){
                inventoryIdQuery += ' AND Inventory__r.Unit_Type__c IN (\''+String.join(typeSelectedLists,'\',\'')+'\')';
                generalInventoryQuery += ' AND Unit_Type__c IN (\''+String.join(typeSelectedLists,'\',\'')+'\')';
                system.debug('**location query '+inventoryIdQuery);
            }
                   
         }


        if(ApexPages.currentPage().getParameters().containsKey('Location') && ApexPages.currentPage().getParameters().get('Location') != ''
            && ApexPages.currentPage().getParameters().get('Location') != 'All'){
          locationSelectedFromURL = ApexPages.currentPage().getParameters().get('Location');
            
            List<String> locationSelectedLists = locationSelectedFromURL.split(',');
            
            if(null != locationSelectedLists){
                inventoryIdQuery += ' AND Inventory__r.Address__r.City__c IN (\''+String.join(locationSelectedLists,'\',\'')+'\')';
                generalInventoryQuery += ' AND Address__r.City__c IN (\''+String.join(locationSelectedLists,'\',\'')+'\')';
                system.debug('**location query '+inventoryIdQuery);
            }
        }
         
        inventoryIdQuery += ' LIMIT 10000'; 

        InventoryIDs = UtilityQueryManager.getInventoryIDs(inventoryIdQuery);
        
      
         
        //get all inventories from the general inventory pool
        Set<ID> generalInventoryId = UtilityQueryManager.getAllGeneralInventories(generalInventoryQuery);
        InventoryIDs.addAll(generalInventoryId);
        
        PropertyIDs = UtilityQueryManager.getPropertyIDs(InventoryIDs);

        projectsAssigned = new List<ProjectWrapper>();
        projectsAssigned = getProjectLists(PropertyIDs);

        system.debug('**projectsAssigned '+projectsAssigned);
        getMarkers();
    }


    public void getMarkers(){

        mapMarkers = new List<List<Object>>();
        Map<String, Map<String,String>> addressMap = UtilityQueryManager.getAddressLocation(PropertyIDs,InventoryIDs);
        for(String propertyNames:addressMap.keySet()){
            List<Object> mapMarker = new List<Object>();
            Map<String,String> locationMap = addressMap.get(propertyNames);
            system.debug(locationMap);
            mapMarker.add('"'+propertyNames+'"');
            mapMarker.add(locationMap.get('Latitude'));
            mapMarker.add(locationMap.get('Longitude'));
            mapMarkers.add(mapMarker);
        }

        noOfMarkers = mapMarkers.size();
    }

    public List<ProjectWrapper> getProjectLists(Set<Id> propertyIDs){

      List<ProjectWrapper> property = new List<ProjectWrapper>();

      for(AggregateResult thisInventory:[SELECT Marketing_Name__c, Property__r.District__c district,Property__r.Property_Name__c propertyName from Inventory__c where
                                     Property__c in :propertyIDs AND Marketing_Name__c != null AND Status__c ='Released'
                                     AND Unit_Location__c != null AND Address__c != null
                                     GROUP BY Marketing_Name__c,Property__r.District__c,Property__r.Property_Name__c]){
        ProjectWrapper pWrap = new ProjectWrapper((String)thisInventory.get('Marketing_Name__c'),(String)thisInventory.get('district'),
                                                    (String)thisInventory.get('propertyName'));
       
        property.add(pWrap);
      }
      return property;
      
    }

    public class ProjectWrapper{
        public String marketingName{set;get;}
        public String propertyName{set;get;}
        public String district{set;get;}
        
        public ProjectWrapper(String marketingName,String district,String propertyName){
            if(null != marketingName)
                this.marketingName = marketingName.toUpperCase();
            if(null != district)
                this.district = district.toUpperCase();

            if(null != propertyName)
                this.propertyName = propertyName.toUpperCase();
        }
    }
}