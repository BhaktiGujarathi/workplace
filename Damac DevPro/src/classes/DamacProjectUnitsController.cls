/**************************************************************************************************
* Name               : DamacProjectController                                               
* Description        : An apex page controller for                                              
* Created Date       : NSI - Diana                                                                        
* Created By         : 29/Jan/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          29/Jan/2017                                                               
**************************************************************************************************/

public without sharing class DamacProjectUnitsController {

    /**************************************************************************************************
            Variables used in the class
    **************************************************************************************************/
    public List<String> projectType{set;get;} // show type filter in VF
    public List<String> bedrooms{set;get;}
    public List<Inventory__c> inventories{set;get;}
    public String inventoryPrefix{set;get;}
    public Inventory_Area_range__c inventoryAreaRange{set;get;}
    public List<Inventory_Price__c> priceRangeValues{set;get;}
    public String areaSqftMin{set;get;}
    public String areaSqftMax{set;get;}
    public String priceMin{set;get;}
    public String priceMax{set;get;}
    public Decimal priceMinRange{set;get;}
    public Decimal priceMaxRange{set;get;}
    public Inventory_Price_Configuration__c inventoryPriceConfiguration{set;get;}
    public String marketingName{set;get;}
    public String userId{set;get;}
    private String inventoryIdQuery{set;get;}
    private Set<Id> InventoryIDs;
    private String generalInventoryQuery;
    public String bedroomsSelectedFromURL{set;get;}
    public String typeSelectedFromURL{set;get;}
    public String locationSelectedFromURL{set;get;}
    public String propertyName{set;get;}
    public string tabName{set;get;}
    public List<String> floorPackageType{set;get;}
    public String floorPackageTypeSelected{set;get;}
    public String floorPackageNameSelected{set;get;}
    public List<String> floorPackageName{set;get;}

    /**************************************************************************************************
    Method:         DamacProjectController
    Description:    Constructor executing model of the class 
    **************************************************************************************************/
    public DamacProjectUnitsController() {
        
        projectType = UtilityQueryManager.getAllProjectTypes();
        bedrooms = UtilityQueryManager.getAllBedRooms();
        floorPackageType = new List<String>();

        floorPackageType = DamacUtility.getPicklistValue(Inventory__c.SobjectType,'Floor_Package_Type__c');

        if(ApexPages.currentPage().getParameters().containsKey('floorPkgName') && null != ApexPages.currentPage().getParameters().get('floorPkgName'))
            floorPackageNameSelected = ApexPages.currentPage().getParameters().get('floorPkgName');
        else 
            floorPackageNameSelected = ' ';

        inventories = new List<Inventory__c>();
        inventoryPrefix = DamacUtility.getObjectPrefix('Inventory__c');

        if(ApexPages.currentPage().getParameters().containsKey('Location') && ApexPages.currentPage().getParameters().get('Location') != ''
            && ApexPages.currentPage().getParameters().get('Location') != 'All'){
            locationSelectedFromURL = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('Location'));
        }

         if(ApexPages.currentPage().getParameters().containsKey('sfdc.tabName')){
            tabName = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('sfdc.tabName'));
        }

        inventoryAreaRange = Inventory_Area_range__c.getValues(DAMAC_Constants.INVENTORY_AREA_RANGE);
        //priceRangeValues = UtilityQueryManager.getPriceRange();
        //inventoryPriceConfiguration = Inventory_Price_Configuration__c.getValues(DAMAC_Constants.INVENTORY_STEP);

        inventoryIdQuery ='SELECT Inventory__c from Inventory_User__c where Inventory__r.Status__c = \'RELEASED\' AND Inventory__r.Unit_Location__c != null'+ 
                                     ' AND Inventory__r.Address__c != null AND End_Date__c >= TODAY AND User__c=\''+UserInfo.getUserId()+'\'';
        
        generalInventoryQuery = 'SELECT Id from Inventory__c where Status__c=\'RELEASED\' AND Unit_Location__c != null'+
                                ' AND Address__c != null AND Is_Assigned__c = false';
                            
        InventoryIDs = UtilityQueryManager.getInventoryIDs(inventoryIdQuery);
        
        
        
        //get all inventories from the general inventory pool
        Set<ID> generalInventoryId = UtilityQueryManager.getAllGeneralInventories(generalInventoryQuery );
        InventoryIDs.addAll(generalInventoryId);
        
        marketingName = null;
        if(ApexPages.currentPage().getParameters().containsKey('Id')){
            marketingName = ApexPages.currentPage().getParameters().get('Id');
        }

        Map<String,Decimal> minMaxPriceMap = UtilityQueryManager.getMinMaxPrice(marketingName);

        if(ApexPages.currentPage().getParameters().containsKey('MinPrice') && null != ApexPages.currentPage().getParameters().get('MinPrice')){
            priceMin = ApexPages.currentPage().getParameters().get('MinPrice');
        }

        if(ApexPages.currentPage().getParameters().containsKey('MaxPrice') && null != ApexPages.currentPage().getParameters().get('MaxPrice')){
            priceMax = ApexPages.currentPage().getParameters().get('MaxPrice');
        }
        
        if( null !=  minMaxPriceMap){
            priceMinRange = minMaxPriceMap.get('min');
            priceMaxRange =  minMaxPriceMap.get('max');
            priceMin = (priceMin ==  null)?String.valueOf(priceMinRange):priceMin;
            priceMax= (priceMax == null)?String.valueOf(priceMaxRange):priceMax;
        }
        
        userId = UserInfo.getUserId();
        floorPackageName = new List<String>();
        floorPackageName = UtilityQueryManager.getAllFloorPackageName(InventoryIDs,marketingName);
        getAllInventories();
        
        //
       
    }

    public void getAllInventories(){

        if(null != marketingName){
            String condition= 'Id,Property_Name_2__c,Marketing_Name__c FROM Inventory__c WHERE Unit_Type__c != null AND Unit_Location__c != null '+
                        ' AND Id IN :InventoryIDs AND Marketing_Name__c = \''+marketingName+'\''+
                ' AND Status__c = \'Released\' ';

            
            if(ApexPages.currentPage().getParameters().containsKey('UnitBedrooms')){

                if(ApexPages.currentPage().getParameters().get('UnitBedrooms') != '' 
                    && ApexPages.currentPage().getParameters().get('UnitBedrooms') != 'All')
                    bedroomsSelectedFromURL = ApexPages.currentPage().getParameters().get('UnitBedrooms');
               
            }else if(ApexPages.currentPage().getParameters().containsKey('Bedrooms')){
                if(ApexPages.currentPage().getParameters().get('Bedrooms') != '' 
                    && ApexPages.currentPage().getParameters().get('Bedrooms') != 'All')
                    bedroomsSelectedFromURL = ApexPages.currentPage().getParameters().get('Bedrooms');
            }  

            if(null != bedroomsSelectedFromURL && bedroomsSelectedFromURL != ''){
                List<String> bedroomsSelectedLists = bedroomsSelectedFromURL.split(',');
                    
                if(null != bedroomsSelectedLists){
                  condition+= ' AND IPMS_Bedrooms__c IN (\''+String.join(bedroomsSelectedLists,'\',\'')+'\')'; 
                 }
            }

            if(ApexPages.currentPage().getParameters().containsKey('UnitType')){
                if(ApexPages.currentPage().getParameters().get('Type') != ''
                && ApexPages.currentPage().getParameters().get('Type') != 'All')
               typeSelectedFromURL= ApexPages.currentPage().getParameters().get('UnitType');
                       
            }else if(ApexPages.currentPage().getParameters().containsKey('Type')){
                if(ApexPages.currentPage().getParameters().get('Type') != ''
                && ApexPages.currentPage().getParameters().get('Type') != 'All')
                typeSelectedFromURL= ApexPages.currentPage().getParameters().get('Type');
            }

            if(null != typeSelectedFromURL && typeSelectedFromURL != ''){
                List<String> typeSelectedLists= typeSelectedFromURL.split(',');
                
                if(null != typeSelectedLists){
                   condition+= ' AND Unit_Type__c IN (\''+String.join(typeSelectedLists,'\',\'')+'\')'; 
                }
            }

            if(String.isNotEmpty(priceMin)){
                condition += ' AND ( List_Price_calc__c >=' + priceMin +' OR Special_Price_calc__c >= ' +priceMin + ') ';
            }
            
            if(String.isNotEmpty(priceMax)){
                condition += ' AND ( List_Price_calc__c <='+ priceMax +' OR Special_Price_calc__c <= ' +priceMax+ ') ';
            }

             if(String.isNotEmpty(floorPackageNameSelected.trim())){
                condition += ' AND Floor_Package_Name__c =\''+floorPackageNameSelected.trim()+'\'';
            }

          if(ApexPages.currentPage().getParameters().containsKey('floorPkgType') && 
            null != ApexPages.currentPage().getParameters().get('floorPkgType') &&
            '' != ApexPages.currentPage().getParameters().get('floorPkgType') &&
            'All' != ApexPages.currentPage().getParameters().get('floorPkgType')){
                floorPackageTypeSelected= ApexPages.currentPage().getParameters().get('floorPkgType');
                List<String> floorPackageTypeLst= floorPackageTypeSelected.split(',');
                
                if(null != floorPackageTypeLst){
                   condition+= ' AND Floor_Package_Type__c IN (\''+String.join(floorPackageTypeLst,'\',\'')+'\')'; 
                }
          }

            condition += ' LIMIT 10000'; 
        
            inventories = UtilityQueryManager.getInventoryList(condition,InventoryIDs);
            
            if(null != inventories && inventories.size()>0){
                propertyName = inventories[0].Marketing_Name__c;
            }
        }
    }
    
    public void filterInventories(){
        
        if(null != marketingName){
             String condition = 'Id FROM Inventory__c WHERE Unit_Type__c != null AND Unit_Location__c != null AND Id IN :InventoryIDs AND Marketing_Name__c = \''+marketingName+'\''+
                    ' AND Status__c = \'Released\'';
                    
             String BedroomsSelected = ApexPages.currentPage().getParameters().get('BedroomsSelected');
             String TypeSelected = ApexPages.currentPage().getParameters().get('TypeSelected');
             
             //BedroomsSelected Selected is blank or All then dont include it in query
            if(null != BedroomsSelected && '\'\'' != BedroomsSelected && BedroomsSelected != '\'All\'' ){
                condition += ' AND IPMS_Bedrooms__c IN ('+BedroomsSelected+')';
                system.debug('**location query '+condition);
            }
            
            if(null != TypeSelected && '\'\'' != TypeSelected && TypeSelected != '\'All\''){
                condition += ' AND Unit_Type__c IN '+
                                '('+TypeSelected+')';
                system.debug('**type query '+condition);
            }
            
            /*if(String.isNotEmpty(areaSqftMin) && String.isNotEmpty(areaSqftMax)){
                condition += ' AND Area_Sqft_2__c>='+areaSqftMin+' AND Area_Sqft_2__c<='+areaSqftMax;
            }*/
    
            if(String.isNotEmpty(priceMin)){
                condition += ' AND ( List_Price_calc__c >=' + priceMin +' OR Special_Price_calc__c >= ' +priceMin + ') ';
            }
            
            if(String.isNotEmpty(priceMax)){
                condition += ' AND ( List_Price_calc__c <='+ priceMax +' OR Special_Price_calc__c <= ' +priceMax+ ') ';
            }

            if(String.isNotEmpty(floorPackageNameSelected)){
                condition += ' AND Floor_Package_Name__c =\''+floorPackageNameSelected+'\'';
            }

            if(String.isNotEmpty(floorPackageTypeSelected) && null != floorPackageTypeSelected && '\'\'' != floorPackageTypeSelected && floorPackageTypeSelected != '\'All\'')
                condition += 'AND Floor_Package_Type__c IN '+
                                '('+floorPackageTypeSelected+')';
            
            
            system.debug('==condition=='+condition);
        
            inventories = UtilityQueryManager.getInventoryList(condition+' LIMIT 10000',InventoryIDs);
            
        }
    
    }
}