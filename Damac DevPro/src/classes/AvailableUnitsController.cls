/**************************************************************************************************
* Name               : AvailableUnitsController                                                   *
* Description        : Controller class for AvailableUnits component, has below functions.        *
*                       - Get available campaigns list .                                          *
*                       - Associated units to campaign.                                           * 
* Created Date       : 05/02/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      05/02/2017      Initial Draft.  
  1.1         Naresh (Accely)   15/06/2017      Add  Bedroom_Type__c ,CM_Price_Per_Sqft__c,
                                                   Unit_Area_sft__c ,View_Type__c,Brand__c 
                                                  Parameter in SOQL on Invetory Object                                         *
**************************************************************************************************/
public class AvailableUnitsController{
    
    public String errorMessage {get; set;}
    public String agencyName {get; set;} 
    public String agencyType {get; set;} 
    public String inventoryName {get; set;}
    public String agentName {get; set;}
    public String selectedInventory {get; set;}
    public String loggedInUserId {get; set;}
    public String sortDirection {get; set;}
    public String sortField {get; set;} 
    public Boolean selectAll {get; set;}
    public Boolean resetPageNumber {get; set;}
    public Boolean showProperties {get; set;} 
    public Boolean hasPromotions {get; set;}
    public Boolean hasProjects {get; set;}
    public Boolean hasBuildings {get; set;}  
    public Boolean hasBedrooms {get; set;} 
    public Boolean hasPriceRange {get; set;}
    public Boolean disabledPriceSearch {get; set;}
    public List<Id> inventoryIdsList {get; set;}  
    public List<Id> campaignIdsList {get; set;}
    public FilterWrapper fwObject {get; set;}
    public UtilityWrapperManager availableInventoryList {get; set;}
    public Map<Id, UtilityWrapperManager.CampaignWrapper> cwObjectMap {get; set;}
    public List<UtilityWrapperManager.InventoryBuyerWrapper> inventoryWrapperPerPage {get; set;}
    
    public Boolean showNext {get; set;}
    public Boolean showprevious {get; set;}
    public Integer pageNumber {get; set;}
    public List<Integer> pagesToShowList {get; set;}
    public Integer totalPageNumber {get;set;}
    public static Integer PAGE_SIZE = 25;
    public static Integer MAX_PAGES = 10; 
    public List<Integer> recordsSizeList = new List<Integer>(); 
    public Integer priceRangeStartValue {get; set;}
    public Integer priceRangeEndValue {get; set;}
    @TestVisible private Integer filterLevel = 0;
    @TestVisible private static String generalInventoryStatus = system.Label.General_Unit_Status;
    @TestVisible private Set<Id> availableUnitsSet = new Set<Id>();
    @TestVisible private Map<String, Map<String, String>> campaignProjectNameMap = new Map<String, Map<String, String>>();
    @TestVisible private Map<String, String> buildingRelatedBedroomTypeMap = new Map<String, String>();
    @TestVisible private Map<String, String> projectRelatedBuildingMap = new Map<String, String>();
    @TestVisible private Map<String, String> floorIdMap = new Map<String, String>();
    @TestVisible private Map<String, String> packegeIdMap = new Map<String, String>();
    @TestVisible private transient List<UtilityWrapperManager.InventoryBuyerWrapper> inventoryWrapperMap = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
    
    /*********************************************************************************************
    * @Description : Method to initialize variable.                                              *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private void init(){
        pagenumber = 1; 
        resetPageNumber = true;
        showProperties = false;
        hasPromotions = false;
        hasProjects = false;
        hasBuildings = false;
        hasBedrooms = false;
        hasPriceRange = false; 
        disabledPriceSearch = false;
        pagesToShowList = new List<Integer>();
        sortDirection = 'ascending';
        priceRangeStartValue = 0;
        priceRangeEndValue = 0;
        fwObject = new FilterWrapper('', '', '', '', '', '', '', 0.00, 0.00);
        inventoryIdsList = new List<Id>();  
        fwObject.selectedCampaign = 'GeneralInventories';
        inventoryWrapperPerPage = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
    }

    /*********************************************************************************************
    * @Description : Controller class.                                                           *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public AvailableUnitsController(){
      system.debug('#### Available Units Controller');
        init();
        try{
            /* Calling method to get associated campaigns. */ 
            campaignIdsList = new List<Id>(getAssociatedCampaigns()); 
            if(!campaignIdsList.isEmpty()){
                /* Calling method to get associated campaign details. */
                cwObjectMap = getCampaignDetails(campaignIdsList);  
            }
            refreshthePropertyFilters();
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }    
    
    /*********************************************************************************************
    * @Description : Method to get the avialable campaign list.                                  *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
    public List<SelectOption> getCampaignList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select Inventory Type -- '));
        options.add(new SelectOption('GeneralInventories', 'General Inventories'));
        if(cwObjectMap != null){
            for(UtilityWrapperManager.CampaignWrapper thisCwObject : cwObjectMap.values()){
                options.add(new SelectOption(thisCwObject.availableCampaign.Id, thisCwObject.availableCampaign.Campaign_Name__c)); 
            }
        }
        return options; 
    }
    
    /*********************************************************************************************
    * @Description : Method to get the available floor ids related to the campaign.              *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
    public List<SelectOption> getFloorList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select a Floor -- '));
        if(!floorIdMap.isEmpty()){
            for(String thisFloor : floorIdMap.keySet()){
              if(floorIdMap.get(thisFloor) != null){
                options.add(new SelectOption(thisFloor, floorIdMap.get(thisFloor)));   
              }else{
                options.add(new SelectOption(thisFloor, thisFloor)); 
              }
            }
        }
        return options; 
    }
    
    /*********************************************************************************************
    * @Description : Method to get the available package ids related to the campaign.            *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
    public List<SelectOption> getPackageList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select a Package -- '));
        if(!packegeIdMap.isEmpty()){
            for(String thisPackage : packegeIdMap.keySet()){
              if(packegeIdMap.get(thisPackage) != null){
                options.add(new SelectOption(thisPackage, packegeIdMap.get(thisPackage)));   
              }else{
                options.add(new SelectOption(thisPackage, thisPackage));     
              }
            }
        }
        return options; 
    }
     
    /*********************************************************************************************
    * @Description : Method to get refresh the page filters value                                *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void refreshthePropertyFilters(){
      showProperties = false;
      inventoryName = '';
      agencyName = '';
      agentName = '';
        fwObject.selectedProject = '';
        fwObject.selectedBuilding = '';
        fwObject.selectedTypeOfBedroom = '';
        fwObject.selectedFloor = '';
      fwObject.selectedPackage = '';
        fwObject.priceRangeStartSelected = 0.00;
        fwObject.priceRangeEndSelected = 0.00;
        pageNumber = resetPageNumber ? 1 : pageNumber;
        try{
            system.debug('#### selected campaign = '+fwObject.selectedCampaign);
            if(String.isNotBlank(fwObject.selectedCampaign)){
                filterLevel = 1;
                inventoryWrapperMap = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
                if(fwObject.selectedCampaign.equalsIgnoreCase('GeneralInventories')){
                     /* Calling method to get general inventories. */
                    inventoryWrapperMap.addAll(getGeneralInventories()); 
                }else{
                    inventoryWrapperMap.addAll(getAssociatedProperties(fwObject.selectedCampaign));    
                }
            }else{
              inventoryWrapperMap = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
              fwObject.selectedCampaign = 'GeneralInventories';
              /* Calling method to get general inventories. */
                inventoryWrapperMap.addAll(getGeneralInventories()); 
            }
            if(inventoryWrapperMap != null && inventoryWrapperMap.size() > 0){
              getRelatedProperties();   
            }
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to get the avialable project list.                                   *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
    public List<SelectOption> getProjectList() { 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select Project -- '));
        try{
            system.debug('#### selected campaign = '+fwObject.selectedCampaign);
          if(String.isNotBlank(fwObject.selectedCampaign) && campaignProjectNameMap != null && 
             !campaignProjectNameMap.isEmpty() && 
             campaignProjectNameMap.containsKey(fwObject.selectedCampaign)){
            hasProjects = true;
            Map<String, String> projectMap = campaignProjectNameMap.get(fwObject.selectedCampaign);  
            for(String thisKey : projectMap.keySet()){
                    options.add(new SelectOption(thisKey, projectMap.get(thisKey)));
                }  
          }else{
                hasProjects = false;    
            }
            options.sort();
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
        return options;
    }
    
    /*********************************************************************************************
    * @Description : Method to get refreshed inventory related to the selected project.          *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void refreshtheBuildingFilters(){
      showProperties = false;
      inventoryName = '';
      agencyName = '';
      agentName = '';
        fwObject.selectedBuilding = '';
        fwObject.selectedTypeOfBedroom = '';
        fwObject.selectedFloor = '';
      fwObject.selectedPackage = '';
        fwObject.priceRangeStartSelected = 0.00;
    fwObject.priceRangeEndSelected = 0.00;
        projectRelatedBuildingMap = new Map<String, String>();
        pageNumber = resetPageNumber ? 1 : pageNumber;
        filterLevel = 2;
        inventoryWrapperMap = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
        try{
          for(Inventory__c thisInventory : Database.query(getQueryString(2))){
              /* Adding parameters to the wrpper in specified order :
                 selected flag, special price flag, selectedPaymentPlan, 
                 selectedSpaMethod, inventory related data, 
                 payment plan with payment terms, jointBuyerList. */
              inventoryWrapperMap.add(
                  new UtilityWrapperManager.InventoryBuyerWrapper(false, 
                                                                  false,
                                                                  false,
                                                                  40000.00,
                                                                  thisInventory.special_Price_calc__c,
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  0,
                                                                  thisInventory,
                                                                  new Booking_Unit__c(),
                                                                  new Map<String, Payment_Plan__c>(),
                                                                  new List<Buyer__c>{new Buyer__c(Primary_Buyer__c = true)}));
              if(String.isNotBlank(thisInventory.Building_Location__c) && String.isNotBlank(thisInventory.Building_Location__r.Building_Name__c)){
                  projectRelatedBuildingMap.put(thisInventory.Building_Location__c, thisInventory.Building_Location__r.Building_Name__c);  
              }
              /* Setting the maximum and minimum values. */
        if(thisInventory.special_Price_calc__c < fwObject.priceRangeStartSelected){
          fwObject.priceRangeStartSelected = thisInventory.special_Price_calc__c;
        }
        if(thisInventory.special_Price_calc__c > fwObject.priceRangeEndSelected){
          fwObject.priceRangeEndSelected = thisInventory.special_Price_calc__c;
        }
          }
          if(inventoryWrapperMap != null && inventoryWrapperMap.size() > 0){
            getRelatedProperties();
      }
    }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to get the avialable building list.                                  *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
    public List<SelectOption> getBuildingList() { 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select Building -- ')); 
        try{
            system.debug('#### selected project = '+fwObject.selectedProject);
            if(String.isNotBlank(fwObject.selectedProject) && projectRelatedBuildingMap != null && 
               !projectRelatedBuildingMap.isEmpty()){
            hasBuildings = true;
            for(String thisKey : projectRelatedBuildingMap.keySet()){
                    options.add(new SelectOption(thisKey, projectRelatedBuildingMap.get(thisKey)));
                }  
          }else{
                hasBuildings = false;    
            }
            options.sort();
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
        return options;
    }
    
    /*********************************************************************************************
    * @Description : Method to get refresh the page filters value                                *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void refreshtheBedroomFilters(){
      showProperties = false;
      inventoryName = '';
      agencyName = '';
      agentName = '';
        fwObject.selectedTypeOfBedroom = '';
        fwObject.selectedFloor = '';
      fwObject.selectedPackage = '';
        fwObject.priceRangeStartSelected = 0.00;
    fwObject.priceRangeEndSelected = 0.00;
        buildingRelatedBedroomTypeMap = new Map<String, String>();
        system.debug('#### Bedroom : Selected Project = '+fwObject.selectedProject);
        system.debug('#### Bedroom : Selected Building = '+fwObject.selectedBuilding);
        pageNumber = resetPageNumber ? 1 : pageNumber;
        filterLevel = 3;
        inventoryWrapperMap = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
        try{
          for(Inventory__c thisInventory : Database.query(getQueryString(3))){
              /* Adding parameters to the wrpper in specified order :
                 selected flag, special price flag, selectedPaymentPlan, 
                 selectedSpaMethod, inventory related data, 
                 payment plan with payment terms, jointBuyerList. */
              inventoryWrapperMap.add(
                  new UtilityWrapperManager.InventoryBuyerWrapper(false, 
                                                                  false,
                                                                  false,
                                                                  40000.00,
                                                                  thisInventory.special_Price_calc__c,
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  0,
                                                                  thisInventory,
                                                                  new Booking_Unit__c(),
                                                                  new Map<String, Payment_Plan__c>(),
                                                                  new List<Buyer__c>{new Buyer__c(Primary_Buyer__c = true)}));
              if(String.isNotBlank(thisInventory.IPMS_Bedrooms__c)){
                  buildingRelatedBedroomTypeMap.put(thisInventory.IPMS_Bedrooms__c, thisInventory.IPMS_Bedrooms__c);
              }
              /* Setting the maximum and minimum values. */
        if(thisInventory.special_Price_calc__c < fwObject.priceRangeStartSelected){
          fwObject.priceRangeStartSelected = thisInventory.special_Price_calc__c;
        }
        if(thisInventory.special_Price_calc__c > fwObject.priceRangeEndSelected){
          fwObject.priceRangeEndSelected = thisInventory.special_Price_calc__c;
        }
          }
          if(inventoryWrapperMap != null && inventoryWrapperMap.size() > 0){
            getRelatedProperties();
      }
    }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to get the avialable bedroom list.                                   *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
    public List<SelectOption> getBedroomTypeList() { 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select Bedroom Type -- '));
        system.debug('#### selected building = '+fwObject.selectedBuilding);
        try{
            if(String.isNotBlank(fwObject.selectedBuilding) && buildingRelatedBedroomTypeMap != null && 
               !buildingRelatedBedroomTypeMap.isEmpty()){
            hasBedrooms = true;
            for(String thisKey : buildingRelatedBedroomTypeMap.keySet()){
                    options.add(new SelectOption(thisKey, buildingRelatedBedroomTypeMap.get(thisKey)));
                }  
          }else{
                hasBedrooms = false;    
            }
            options.sort();
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
        return options;
    }
    
    /*********************************************************************************************
    * @Description : Method to get the related properties.                                       *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void getProperties(){
      showProperties = false;
      inventoryName = '';
      agencyName = '';
      agentName = '';
      fwObject.selectedFloor = '';
      fwObject.selectedPackage = '';
      fwObject.priceRangeStartSelected = 0.00;
    fwObject.priceRangeEndSelected = 0.00;
        system.debug('#### Properties : Selected Project = '+fwObject.selectedProject);
        system.debug('#### Properties : Selected Building = '+fwObject.selectedBuilding);
        system.debug('#### Properties : Selected Bedroom Type = '+fwObject.selectedTypeOfBedroom);
        pageNumber = resetPageNumber ? 1 : pageNumber;
        filterLevel = 4;
        inventoryWrapperMap = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
        try{
          for(Inventory__c thisInventory : Database.query(getQueryString(4))){
              /* Adding parameters to the wrpper in specified order :
                 selected flag, special price flag, selectedPaymentPlan, 
                 selectedSpaMethod, inventory related data, 
                 payment plan with payment terms, jointBuyerList. */
              inventoryWrapperMap.add(
                  new UtilityWrapperManager.InventoryBuyerWrapper(false, 
                                                                  false,
                                                                  false,
                                                                  40000.00,
                                                                  thisInventory.special_Price_calc__c,
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  0,
                                                                  thisInventory,
                                                                  new Booking_Unit__c(),
                                                                  new Map<String, Payment_Plan__c>(),
                                                                  new List<Buyer__c>{new Buyer__c(Primary_Buyer__c = true)}));
            /* Setting the maximum and minimum values. */
        if(thisInventory.special_Price_calc__c < fwObject.priceRangeStartSelected){
          fwObject.priceRangeStartSelected = thisInventory.special_Price_calc__c;
        }
        if(thisInventory.special_Price_calc__c > fwObject.priceRangeEndSelected){
          fwObject.priceRangeEndSelected = thisInventory.special_Price_calc__c;
        }
          }    
          if(inventoryWrapperMap != null && inventoryWrapperMap.size() > 0){
            getRelatedProperties();  
          }
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to refresh the units related to the selected floor.                  *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void refreshFloorList(){
      filterLevel = 8;
      disabledPriceSearch = true;
      showProperties = false;
      pageNumber = resetPageNumber ? 1 : pageNumber;
      fwObject.selectedProject = '';
        fwObject.selectedBuilding = '';
        fwObject.selectedTypeOfBedroom = '';
        fwObject.selectedPackage = '';
        fwObject.priceRangeStartSelected = 0.00;
        fwObject.priceRangeEndSelected = 0.00;  
        inventoryWrapperMap = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
        try{
          for(Inventory__c thisInventory : Database.query(getQueryString(8))){
              /* Adding parameters to the wrpper in specified order :
                 selected flag, special price flag, selectedPaymentPlan, 
                 selectedSpaMethod, inventory related data, 
                 payment plan with payment terms, jointBuyerList. */
              inventoryWrapperMap.add(
                  new UtilityWrapperManager.InventoryBuyerWrapper(false, 
                                                                  false,
                                                                  false,
                                                                  40000.00,
                                                                  thisInventory.special_Price_calc__c,
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  0,
                                                                  thisInventory,
                                                                  new Booking_Unit__c(),
                                                                  new Map<String, Payment_Plan__c>(),
                                                                  new List<Buyer__c>{new Buyer__c(Primary_Buyer__c = true)}));
          }    
          if(inventoryWrapperMap != null && inventoryWrapperMap.size() > 0){
            getRelatedProperties();  
          }
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }  
    }
    
    /*********************************************************************************************
    * @Description : Method to refresh the units related to the selected package.                *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void refreshPackageList(){
      filterLevel = 9;
        disabledPriceSearch = true;
      showProperties = false;
      pageNumber = resetPageNumber ? 1 : pageNumber;
      fwObject.selectedProject = '';
        fwObject.selectedBuilding = '';
        fwObject.selectedTypeOfBedroom = '';
        fwObject.selectedFloor = '';
        fwObject.priceRangeStartSelected = 0.00;
        fwObject.priceRangeEndSelected = 0.00;    
        inventoryWrapperMap = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
        try{
          for(Inventory__c thisInventory : Database.query(getQueryString(9))){
              /* Adding parameters to the wrpper in specified order :
                 selected flag, special price flag, selectedPaymentPlan, 
                 selectedSpaMethod, inventory related data, 
                 payment plan with payment terms, jointBuyerList. */
              inventoryWrapperMap.add(
                  new UtilityWrapperManager.InventoryBuyerWrapper(false, 
                                                                  false,
                                                                  false,
                                                                  40000.00,
                                                                  thisInventory.special_Price_calc__c,
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  0,
                                                                  thisInventory,
                                                                  new Booking_Unit__c(),
                                                                  new Map<String, Payment_Plan__c>(),
                                                                  new List<Buyer__c>{new Buyer__c(Primary_Buyer__c = true)}));
          }    
          if(inventoryWrapperMap != null && inventoryWrapperMap.size() > 0){
            getRelatedProperties();  
          }
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }  
    }
    
    /*********************************************************************************************
    * @Description : Method to create query string.                                              *
    * @Params      : void                                                                        *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    @TestVisible private String getQueryString(Integer filterLevel){
      String projectObjectPrefix = Property__c.sobjecttype.getDescribe().getKeyPrefix();
      String campaignObjectPrefix = Campaign__c.sobjecttype.getDescribe().getKeyPrefix();
        String queryString = 'SELECT Id, Property__c, Property__r.Name,Bedroom_Type__c ,CM_Price_Per_Sqft__c  ,Unit_Area_sft__c ,View_Type__c,Brand__c,Building_Location__c, '+
                  'IPMS_Bedrooms__c, Special_Price_2__c, Marketing_Name__c, '+
                  'Building_Name__c, Property_Name__c, Floor__c, Area_Sqft_2__c, '+
                  'Building_Location__r.Building_Name__c, Building_Location__r.Name, '+
                  'Bedrooms__c, Unit__c, Unit_Type__c, Property_Status__c, '+
                  'Area__c, Selling_Price__c, Special_Price__c, Price_Per_Sqft__c, '+
                  'MD_Price__c, List_Price__c, Property_Country__c, Status__c, CurrencyIsoCode, '+
                  'Floor_Package_ID__c, Floor_Package_Name__c, Floor_Package_Type__c, List_Price_calc__c, Special_Price_calc__c '+
                  'FROM Inventory__c WHERE ';
    if(String.isNotBlank(fwObject.selectedCampaign) && fwObject.selectedCampaign.equalsIgnoreCase('GeneralInventories')){
          queryString = queryString + 'Is_Assigned__c = false AND ';  
        }else if(String.isNotBlank(fwObject.selectedCampaign) && fwObject.selectedCampaign.startsWith(campaignObjectPrefix)){
          Set<String> inventoryIdsSet = new Set<String>(getCampaignRelatedInventory(fwObject.selectedCampaign));
          if(!inventoryIdsSet.isEmpty()){
            queryString = queryString + '(';
            for(String thisInventoryId : inventoryIdsSet){
              queryString = queryString + 'Id = '+'\''+thisInventoryId+'\' OR ';  
            }  
            if(queryString.endsWith('OR ')){
              queryString  = queryString.substringBeforeLast('OR ');  
            }
            queryString = queryString + ') AND ';
          }
          
          queryString = queryString + ' Is_Assigned__c = true AND ';  
        }
    if(String.isNotBlank(fwObject.selectedProject)){
      queryString = queryString +  '(Marketing_Name__c = \''+fwObject.selectedProject+'\'' +
             (fwObject.selectedProject.startsWith(projectObjectPrefix) ? ' OR Property__c = \''+fwObject.selectedProject+'\') AND ': ') AND ');
    }
    if(String.isNotBlank(fwObject.selectedBuilding)){
      queryString = queryString + 'Building_Location__c = \''+fwObject.selectedBuilding+'\' AND ';
    }
    if(String.isNotBlank(fwObject.selectedTypeOfBedroom)){
      queryString = queryString + 'IPMS_Bedrooms__c = \''+fwObject.selectedTypeOfBedroom+'\' AND ';
    }
        if(filterLevel == 5 && fwObject.priceRangeStartSelected != null && fwObject.priceRangeEndSelected != null){
          queryString = queryString + 'special_Price_calc__c >= '+fwObject.priceRangeStartSelected+' AND '+
                    'special_Price_calc__c <= '+fwObject.priceRangeEndSelected+' AND ';
        }
        if(filterLevel == 8 && String.isNotBlank(fwObject.selectedFloor)){
          queryString = queryString + 'Floor_Package_ID__c = \''+fwObject.selectedFloor+'\' AND '+
                    'Floor_Package_Type__c = \'Floor\' AND ';    
        }else if(filterLevel == 9 && String.isNotBlank(fwObject.selectedPackage)){
          queryString = queryString + 'Floor_Package_ID__c = \''+fwObject.selectedPackage+'\' AND '+
                    'Floor_Package_Type__c = \'Package\' AND ';    
        }else{
          queryString = queryString + 'Floor_Package_ID__c = null AND ';    
        }
    queryString = queryString + 'Status__c =: generalInventoryStatus AND List_Price_calc__c != null '+
                  'ORDER BY Unit__c ASC LIMIT '+LIMITS.getLimitQueryRows();
    system.debug('#### String query formed = '+queryString); 
    return queryString;
    }
    
    /*********************************************************************************************
    * @Description : Method to get the related properties.                                       *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void getPriceRelatedProperties(){
        system.debug('#### Price : Selected Project = '+fwObject.selectedProject);
        system.debug('#### Price : Selected Building = '+fwObject.selectedBuilding);
        system.debug('#### Price : Selected Bedroom Type = '+fwObject.selectedTypeOfBedroom);
        system.debug('#### Price : Start Range = '+fwObject.priceRangeStartSelected);
        system.debug('#### Price : End Range = '+fwObject.priceRangeEndSelected);
        filterLevel = 5;
      showProperties = false;
      fwObject.selectedFloor = '';
      fwObject.selectedPackage = '';
        pageNumber = resetPageNumber ? 1 : pageNumber;
        inventoryWrapperMap = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
        try{
          for(Inventory__c thisInventory : Database.query(getQueryString(5))){
              /* Adding parameters to the wrpper in specified order :
                 selected flag, special price flag, selectedPaymentPlan, 
                 selectedSpaMethod, inventory related data, 
                 payment plan with payment terms, jointBuyerList. */
              inventoryWrapperMap.add(
                  new UtilityWrapperManager.InventoryBuyerWrapper(false, 
                                                                  false,
                                                                  false,
                                                                  40000.00,
                                                                  thisInventory.special_Price_calc__c,
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  0,
                                                                  thisInventory,
                                                                  new Booking_Unit__c(),
                                                                  new Map<String, Payment_Plan__c>(),
                                                                  new List<Buyer__c>{new Buyer__c(Primary_Buyer__c = true)}));
            /* Setting the maximum and minimum values. */
        if(thisInventory.special_Price_calc__c < fwObject.priceRangeStartSelected){
          fwObject.priceRangeStartSelected = thisInventory.special_Price_calc__c;
        }
        if(thisInventory.special_Price_calc__c > fwObject.priceRangeEndSelected){
          fwObject.priceRangeEndSelected = thisInventory.special_Price_calc__c;
        }
          }    
          if(inventoryWrapperMap != null && inventoryWrapperMap.size() > 0){
            getRelatedProperties();  
          }
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to get SPA Method.                                                   *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
    public List<SelectOption> getSpaMethods() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Select a Delivery method -- '));
        if(NSIBPM__Service_Request__c.getSObjectType() != null && NSIBPM__Service_Request__c.getSObjectType().getDescribe() != null){
            Map<String, Schema.SObjectField> field_map = NSIBPM__Service_Request__c.getSObjectType().getDescribe().fields.getMap(); 
            if(field_map.containsKey('Delivery_Mode__c')){
                List<Schema.PicklistEntry> pick_list_values = field_map.get('Delivery_Mode__c').getDescribe().getPickListValues();
                for (Schema.PicklistEntry thisValue : pick_list_values) { 
                    options.add(new selectOption(thisValue.getValue(), thisValue.getLabel()));
                }   
            }
        }
        return options;
    }
    
    /*********************************************************************************************
    * @Description : Method to get next set of records. #pagination.                             *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void getNextRecords(){
        try{
            /*Fetching inventories based on the filter level selected. */
            system.debug('#### filterLevel = '+filterLevel);
            inventoryWrapperMap = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
            if(filterLevel == 1){
              refreshthePropertyFilters();    
          }else if(filterLevel == 2){
              refreshtheBuildingFilters();    
          }else if(filterLevel == 3){
              refreshtheBedroomFilters();    
          }else if(filterLevel == 4){
              getProperties();    
          }else if(filterLevel == 5){
            getPriceRelatedProperties();               
          }else if(filterLevel == 6){
              getAgencyRelatedInventories();   
          }else if(filterLevel == 7){
              getRelatedInventories();    
          }else if(filterLevel == 8){
              refreshFloorList();    
          }else if(filterLevel == 9){
              refreshPackageList();    
          }
            resetPageNumber = true;
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }

    /*********************************************************************************************
    * @Description : Method to get properties associated to a selected campaign.                 *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private void getRelatedProperties(){ 
      system.debug('#### Calling pagination stuff for records = '+inventoryWrapperMap.size());
        if(inventoryWrapperMap != null && !inventoryWrapperMap.isEmpty()){
            selectAll = false;
            showProperties = true;    
            /* Calling method to count the total number of pages. */
            countTotalPages();  
            /* Calling method to set the next and previous flags. */ 
            setPreviousNextFlags();
            /* Calling method to show the relevant records as per the pagination. */
            showNextRecords();
        }else{
            showProperties = false;    
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to count total number of pages #pagination.                          *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private void countTotalPages(){
        system.debug('#### counting pages');
        if(inventoryWrapperMap != null && !inventoryWrapperMap.isEmpty()){
            for(UtilityWrapperManager.InventoryBuyerWrapper thisRecord : inventoryWrapperMap){
                inventoryWrapperPerPage.add(thisRecord);
                if(inventoryWrapperPerPage.size() == PAGE_SIZE){
                    break;
                }
            }
            totalPageNumber =  ((math.mod(inventoryWrapperMap.size(), PAGE_SIZE) == 0) ? (inventoryWrapperMap.size() / PAGE_SIZE) : ((inventoryWrapperMap.size() / PAGE_SIZE) + 1)); 
            Integer maxPagesToShow = totalPageNumber > MAX_PAGES ? MAX_PAGES : totalPageNumber;
            pagesToShowList.clear();
            for(integer i = 1; i <= maxPagesToShow ; i++){
                pagesToShowList.add(i); 
            }
            system.debug('#### counting pages = '+totalPageNumber);
        }
    }
    
     /*********************************************************************************************
    * @Description : Method to set the visibility flags for previous, next buttons #pagination.  *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private void setPreviousNextFlags(){
        if(pageNumber == totalPageNumber){
            showNext = false;
            showPrevious = true;
        }
        if(pageNumber != 1 && totalPageNumber > 1 && pageNumber != totalPageNumber){
            showNext = true;
            showPrevious = true;
        }
        if(pageNumber == 1 && totalPageNumber > 1){
            showNext = true;
            showPrevious = false;
        }
        if(pageNumber == 1 && totalPageNumber == 1){
            showNext = false;
            showPrevious = false;
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to travel next #pagination.                                          *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void next(){
        try{
            pageNumber = pageNumber + 1;
            if(pageNumber <= totalPageNumber && pageNumber >= 1){
                setPreviousNextFlags();
                showNextRecords();
            }else{
                pageNumber = 1;
            }
        }catch(Exception ex){
             errorMessage = '#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage();
        }
    }

    /*********************************************************************************************
    * @Description : Method to travel previoud #pagination.                                      *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void previous(){
        try{
            pageNumber = pageNumber - 1;
            if(pageNumber >= 1 && pageNumber <= totalPageNumber){
                setPreviousNextFlags();
                showNextRecords(); 
            }else{
                pageNumber = 1;
            }
        }catch(Exception ex){
             errorMessage = '#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage();
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to show next set of records.                                         *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    **********************************************************************************************/
    @TestVisible private void showNextRecords(){
        system.debug('#### showNextRecords for page = '+pageNumber);
        inventoryWrapperPerPage = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
        /* Calling method to show the relevant records as per the pagination. */
        Integer max = pageNumber * PAGE_SIZE;
        Integer min = max - PAGE_SIZE;
        system.debug('#### maximum = '+max+' ,minimum = '+min);
        for(Integer i = min; i <= max; i++){
            if(inventoryWrapperMap != null && inventoryWrapperMap.size() > i){
                inventoryWrapperPerPage.add(inventoryWrapperMap[i]);
                if(inventoryWrapperPerPage.size() == PAGE_SIZE){
                    break;
                }
            }else{
                break;
            }
        }
    }
     
    /*********************************************************************************************
    * @Description : Method to the related inventories in the system.                            *
    *                - Inventory related to the PC's campaign.                                   *
    *                - Inventory related to the Team.                                            *
    *                - General inventories.                                                      *    
    * @Params      : String                                                                      *
    * @Return      : List<Inventory__c>                                                          *
    *********************************************************************************************/
    @RemoteAction 
    public static List<Inventory__c> getInventoryDetails(String searchKey){
        List<Inventory__c> inventoryList = new List<Inventory__c>();
        Set<Id> relatedInventoryIdsSet = new Set<Id>();
        /* Calling method to get team related inventories. */
        relatedInventoryIdsSet.addAll(getTeamUsers());
        system.debug('#### Team related inventory = '+relatedInventoryIdsSet);
        /* Calling method to get campaign inventories. */
        relatedInventoryIdsSet.addAll(getCampaignRelatedInventories());
        system.debug('#### Campaign related inventory = '+relatedInventoryIdsSet);
        for(Inventory__c thisInventory : [SELECT Id, Location_Code__c, Property_Country__c, Is_Assigned__c, CurrencyIsoCode, 
                              Floor_Package_ID__c, Floor_Package_Name__c, Floor_Package_Type__c, List_Price_calc__c, 
                              Special_Price_calc__c
                                          FROM Inventory__c 
                                          WHERE Location_Code__c LIKE: '%'+searchKey+'%' AND 
                                                Status__c =: generalInventoryStatus]){
            if(thisInventory.Is_Assigned__c){
                if(!relatedInventoryIdsSet.isEmpty() && relatedInventoryIdsSet.contains(thisInventory.Id)){
                    inventoryList.add(thisInventory);       
                }   
            }else{
                inventoryList.add(thisInventory);   
            }
        }   
        system.debug('#### inventoryList = '+inventoryList);
        return inventoryList;
    }
    
    /*********************************************************************************************
    * @Description : Method to get all the agencies related to the logged in PC.                 *
    *                - Tagged to Individual Agencies, passport not expired.                      *
    *                - Tagged to Corporate Agencies, not terminated, blacklisted or expired.     *
    * @Params      : void                                                                        *
    * @Return      : List<Account>                                                               *
    **********************************************************************************************/
    @RemoteAction 
    public static List<Account> getAgencyDetails(String searchKey){
        List<Account> agencyList = new List<Account>();
        List<Id> accountIdsList = new List<Id>();
        for(Agency_PC__c thisAgency : [SELECT Id, User__c, Agency__c
                                       FROM Agency_PC__c 
                                       WHERE User__c =: UserInfo.getUserId() AND 
                                             (Agency__r.RecordTypeId =: DamacUtility.getRecordTypeId('Account', 'Individual Agency'))]){
            accountIdsList.add(thisAgency.Agency__c);   
        }
        system.debug('#### accountIdsList = '+accountIdsList);
        for(Account thisAccount : [SELECT Id, Name, RecordTypeId, RecordType.Name
                                   FROM Account 
                                   WHERE Name LIKE: '%'+searchKey+'%' AND
                                        (Id IN: accountIdsList OR
                                        (RecordTypeId =: DamacUtility.getRecordTypeId('Account', 'Corporate Agency') AND 
                                         Blacklisted__c = false AND 
                                         Terminated__c = false))]){
            agencyList.add(thisAccount);    
        }   
        return agencyList;
    }
    
    /*********************************************************************************************
    * @Description : Method to get all the corporate agencies related to the selected agents.    *
    *                - All contacts with profiles as agent representative.                       *
    *                - Passport not expired.                                                     *
    *                - RERA / Broker Id not expired.                                             *
    * @Params      : String                                                                      *
    * @Return      : List<User>                                                                  *
    **********************************************************************************************/
    @RemoteAction 
    public static List<User> getCorporateAgents(String selectedCorporateAgency){
        List<User> agentsList = new List<User>();
        for(User thisAgent : [SELECT Id, Name 
                              FROM User 
                              WHERE Contact.AccountId =: selectedCorporateAgency AND 
                                    Contact.Agent_Representative__c = true AND
                                    isActive = true]){
            agentsList.add(thisAgent);  
        }
        return agentsList;
    }
    
    /*********************************************************************************************
    * @Description : Validate if already selected units are eligible for the selected agency.    *
    * @Params      : String, String                                                              *
    * @Return      : Boolean                                                                     *
    **********************************************************************************************/
    @RemoteAction
    public static Boolean validateSelectedUnits(String agencyId, String selectedUnits){
        Integer counter = 0;
        Boolean validate = false;
        Set<String> agencyEligibleCountry = new Set<String>();
        system.debug('#### agencyId = '+agencyId);
        system.debug('#### selectedUnits = '+selectedUnits);
        if(String.isNotBlank(selectedUnits) && String.isNotBlank(agencyId)){
            for(Account thisAccount : [SELECT Id, Name, 
                                              (SELECT Id, Name, Org_ID_formula__c, Org_ID__c
                                               FROM Agent_Sites__r 
                                               WHERE End_Date__c = NULL) 
                                       FROM Account 
                                       WHERE Id =: agencyId]){
                for(Agent_Site__c thisAgentSite : thisAccount.Agent_Sites__r){
                    if(String.isNotBlank(thisAgentSite.Org_ID_formula__c)){
                        agencyEligibleCountry.add(thisAgentSite.Org_ID_formula__c);  
                    }
                }   
            }
            if(!agencyEligibleCountry.isEmpty()){
                Set<String> selectedUnitIdsSet = new Set<String>(selectedUnits.split(','));
                for(Inventory__c thisInventory : [SELECT Id, Location_Code__c, Property_Country__c, Is_Assigned__c, 
                                     Org_ID__c, CurrencyIsoCode, Floor_Package_ID__c, Floor_Package_Name__c, 
                                     Floor_Package_Type__c, List_Price_calc__c, Special_Price_calc__c
                                                  FROM Inventory__c 
                                                  WHERE Id IN: selectedUnitIdsSet]){
                    if(String.isNotBlank(thisInventory.Org_ID__c) && 
                       agencyEligibleCountry.contains(thisInventory.Org_ID__c)){
                        validate = true;    
                    }else{
                        validate = false;   
                        break;
                    }   
                }
            }
        }
        return validate;
    }
    
    /*********************************************************************************************
    * @Description : Method to get inventory users list.                                         *
    * @Params      : String                                                                      *
    * @Return      : Set<Id>                                                                     *
    **********************************************************************************************/
    @TestVisible private static Set<Id> getInventoryUsersList(String agencyId){
        Set<Id> inventoryIdsSet = new Set<Id>();
        for(Inventory_User__c thisRecord : [SELECT Id, Inventory__c 
                                           FROM Inventory_User__c 
                                           WHERE User__r.Contact.AccountId =: agencyId AND 
                                                 Inventory__c != null AND 
                                                 Start_Date__c <= TODAY AND 
                                                 End_Date__c >= TODAY
                                           ORDER BY LastModifiedDate DESC LIMIT : LIMITS.getLimitQueryRows()]){
            if(thisRecord.Inventory__c != null){
                system.debug('#### Inventory Id = '+thisRecord.Inventory__c);
                inventoryIdsSet.add(thisRecord.Inventory__c);   
            }
        }
        return inventoryIdsSet;
    }
    
    /*********************************************************************************************
    * @Description : Method to add the selected inventory to the main list.                      *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    public void selectInventory(){
      Set<Id> existingInventoryIdsSet = new Set<Id>();
      try{
        for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : availableInventoryList.ibwList){
          existingInventoryIdsSet.add(thisInventory.selectedInventory.Id);  
        }
          if(String.isNotBlank(selectedInventory) && inventoryWrapperPerPage != null){
             for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : inventoryWrapperPerPage){
                 if(String.isNotBlank(fwObject.selectedFloor) || String.isNotBlank(fwObject.selectedPackage)){
                   thisInventory.isSelected = true;
                   availableInventoryList.ibwList.add(thisInventory);  
                 }else{
                   if(thisInventory.isSelected && 
                     ((!selectedInventory.equalsIgnoreCase('All') && 
                       Id.valueOf(selectedInventory) == thisInventory.selectedInventory.Id) || 
                      (selectedInventory.equalsIgnoreCase('All'))) && 
                      !existingInventoryIdsSet.contains(thisInventory.selectedInventory.Id)){
                       availableInventoryList.ibwList.add(thisInventory);   
                   }
                 }
             }
          }   
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to delete the selected inventory from the main list.                 *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    public void deleteInventory(){
      selectAll = false;
      PageReference page;
      Set<Id> floorPackageRelatedUnit = new Set<Id>();
      List<Booking_Unit__c> updateBookingUnitList = new List<Booking_Unit__c>();
      try{
        List<UtilityWrapperManager.InventoryBuyerWrapper> ibwList = new List<UtilityWrapperManager.InventoryBuyerWrapper>(availableInventoryList.ibwList);
          if(String.isNotBlank(selectedInventory) && inventoryWrapperPerPage != null){
             for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : inventoryWrapperPerPage){
                 if(String.isNotBlank(fwObject.selectedFloor) || String.isNotBlank(fwObject.selectedPackage)){
                   thisInventory.isSelected = false;
                   floorPackageRelatedUnit.add(thisInventory.selectedInventory.Id);
                 }else{
                   if(selectedInventory.equalsIgnoreCase('All')){
                       thisInventory.isSelected = false;
                   }else{
                      if(Id.valueOf(selectedInventory) == thisInventory.selectedInventory.Id){
                        thisInventory.isSelected = false;
                      }
                   }
                 }
             }
          }   
          if(!ibwList.isEmpty()){
            availableInventoryList.ibwList.clear();  
            for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : ibwList){
              if(selectedInventory.equalsIgnoreCase('All')){
                 }else{
                   if(String.isNotBlank(fwObject.selectedFloor) || String.isNotBlank(fwObject.selectedPackage)){
                     if(!floorPackageRelatedUnit.contains(thisInventory.selectedInventory.Id)){
                       availableInventoryList.ibwList.add(thisInventory);  
                     }
                   }else{
                     if(Id.valueOf(selectedInventory) != thisInventory.selectedInventory.Id){
                       availableInventoryList.ibwList.add(thisInventory);
                     }else{
                       if(thisInventory.bookingUnit != null && thisInventory.bookingUnit.Id != null){
                         updateBookingUnitList.add(new Booking_Unit__c(Id = thisInventory.bookingUnit.Id, Status__c = 'Removed'));
                       }
                     }
                   }
                 }  
            } 
          }
          if(!updateBookingUnitList.isEmpty()){
            update updateBookingUnitList;  
          }
          /*
          if(!removedBookingUnitIdsMap.isEmpty()){
            List<SObject> deleteList = new List<SObject>();
            Map<String, Integer> bookingRelatedRecordsCountMap = new Map<String, Integer>();
            Set<String> bookingIdsSet = new Set<String>(removedBookingUnitIdsMap.values());
            for(Booking__c thisBookingUnitRecord : [SELECT Id, (SELECT Id FROM Booking_Units__r) FROM Booking__c WHERE Id IN: bookingIdsSet]){
              bookingRelatedRecordsCountMap.put(thisBookingUnitRecord.Id, thisBookingUnitRecord.Booking_Units__r.size());  
            }
            
            for(String thisKey : removedBookingUnitIdsMap.keySet()){
              if(bookingRelatedRecordsCountMap.get(removedBookingUnitIdsMap.get(thisKey)) > 1){
                deleteList.add(new Booking_Unit__c(Id = thisKey));      
              }else{
                deleteList.add(new Booking__c(Id = removedBookingUnitIdsMap.get(thisKey)));    
              }  
            }
            delete deleteList;  
          }
          */
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to get selected inventory.                                           *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    **********************************************************************************************/
    public void getRelatedInventories(){
      showProperties = false;
      inventoryName = '';
      agencyName = '';
      agentName = '';
      fwObject.selectedProject = 'GeneralInventories';
      fwObject.selectedProject = '';
        fwObject.selectedBuilding = '';
      fwObject.selectedTypeOfBedroom = '';
      fwObject.selectedFloor = '';
      fwObject.selectedPackage = '';
        fwObject.priceRangeStartSelected = 0.00;
    fwObject.priceRangeEndSelected = 0.00;
        try{
            system.debug('#### selectedInventory = '+selectedInventory);
            if(String.isNotBlank(selectedInventory)){
              pageNumber = resetPageNumber ? 1 : pageNumber;
              filterlevel = 7;
              inventoryWrapperMap = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
                for(Inventory__c thisInventory : [SELECT Id, Property__c, Property__r.Name, Building_Location__c, Bedroom_Type__c ,CM_Price_Per_Sqft__c  ,Unit_Area_sft__c ,View_Type__c,Brand__c  ,
                                                   IPMS_Bedrooms__c, Special_Price_2__c, Marketing_Name__c, 
                                                   Building_Name__c, Property_Name__c, Floor__c, Area_Sqft_2__c,
                                                   Building_Location__r.Building_Name__c, Building_Location__r.Name, 
                                                   Bedrooms__c, Unit__c, Unit_Type__c, Property_Status__c,
                                                   Area__c, Selling_Price__c, Special_Price__c, Price_Per_Sqft__c,
                                                   MD_Price__c, List_Price__c, Property_Country__c, Status__c, 
                                                   CurrencyIsoCode, Floor_Package_ID__c, Floor_Package_Name__c, 
                                                   Floor_Package_Type__c, List_Price_calc__c, Special_Price_calc__c
                                            FROM Inventory__c 
                                            WHERE Id =: selectedInventory AND
                                                  Status__c =: generalInventoryStatus AND
                                                  List_Price_calc__c != null
                                            ORDER BY Unit__c ASC LIMIT : LIMITS.getLimitQueryRows()]){  
          /* Adding parameters to the wrpper in specified order :
                     selected flag, special price flag, selectedPaymentPlan, 
                     selectedSpaMethod, inventory related data, 
                     payment plan with payment terms, jointBuyerList. */
                  inventoryWrapperMap.add(
                      new UtilityWrapperManager.InventoryBuyerWrapper(false, 
                                              false,
                                                                      false,
                                                                      40000.00,
                                                                      thisInventory.special_Price_calc__c, 
                                                                      '',
                                                                      '',
                                                                      '',
                                                                      '',
                                                                      0,
                                                                      thisInventory,
                                                                      new Booking_Unit__c(),
                                                                      new Map<String, Payment_Plan__c>(),
                                                                      new List<Buyer__c>{new Buyer__c(Primary_Buyer__c = true)}));
        }
        if(inventoryWrapperMap != null && inventoryWrapperMap.size() > 0){
          getRelatedProperties();
        }
            }else{
        fwObject.selectedCampaign = 'GeneralInventories';
              refreshthePropertyFilters();            
            }   
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }
    
    /*********************************************************************************************
    * @Description : Calling method to get inventories related to the selected agency.           *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    **********************************************************************************************/
    public void getAgencyRelatedInventories(){
        system.debug('#### Selected Agency = '+availableInventoryList.dealRecord.Agency__c);
        showProperties = false;
        inventoryName = '';
      agencyName = '';
      agentName = '';
        fwObject.selectedProject = 'GeneralInventories';
      fwObject.selectedProject = '';
        fwObject.selectedBuilding = '';
      fwObject.selectedTypeOfBedroom = '';
      fwObject.selectedFloor = '';
      fwObject.selectedPackage = '';
        fwObject.priceRangeStartSelected = 0.00;
    fwObject.priceRangeEndSelected = 0.00;
    try{
          if(availableInventoryList.dealRecord.Agency__c != null){
              Set<Id> agencyRelatedUnits = new Set<Id>(AvailableUnitsController.getInventoryUsersList(availableInventoryList.dealRecord.Agency__c));
              system.debug('#### Selected Agency\'s Units = '+agencyRelatedUnits);
              pageNumber = resetPageNumber ? 1 : pageNumber;
            filterlevel = 6;
            inventoryWrapperMap = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
              for(Inventory__c thisInventory : [SELECT Id, Property__c, Property__r.Name, Building_Location__c,Bedroom_Type__c ,CM_Price_Per_Sqft__c  ,Unit_Area_sft__c ,View_Type__c,Brand__c ,
                                                   IPMS_Bedrooms__c, Special_Price_2__c, Marketing_Name__c, 
                                                   Building_Name__c, Property_Name__c, Floor__c, Area_Sqft_2__c,
                                                   Building_Location__r.Building_Name__c, Building_Location__r.Name, 
                                                   Bedrooms__c, Unit__c, Unit_Type__c, Property_Status__c,
                                                   Area__c, Selling_Price__c, Special_Price__c, Price_Per_Sqft__c,
                                                   MD_Price__c, List_Price__c, Property_Country__c, Status__c, 
                                                   CurrencyIsoCode, Floor_Package_ID__c, Floor_Package_Name__c, 
                                                   Floor_Package_Type__c, List_Price_calc__c, Special_Price_calc__c
                                            FROM Inventory__c 
                                            WHERE ((Id IN: agencyRelatedUnits AND Status__c =: generalInventoryStatus) OR 
                                                 (Status__c =: generalInventoryStatus AND Is_Assigned__c = false)) AND
                                                  Floor_Package_ID__c = null AND 
                                                  List_Price_calc__c != null
                                            ORDER BY Unit__c ASC LIMIT : LIMITS.getLimitQueryRows()]){  
                  /* Adding parameters to the wrpper in specified order :
                     selected flag, special price flag, selectedPaymentPlan, 
                     selectedSpaMethod, inventory related data, 
                     payment plan with payment terms, jointBuyerList. */
                  inventoryWrapperMap.add(
                      new UtilityWrapperManager.InventoryBuyerWrapper(false, 
                                              false,
                                                                      false,
                                                                      40000.00,
                                                                      thisInventory.special_Price_calc__c, 
                                                                      '',
                                                                      '',
                                                                      '',
                                                                      '',
                                                                      0,
                                                                      thisInventory,
                                                                      new Booking_Unit__c(),
                                                                      new Map<String, Payment_Plan__c>(),
                                                                      new List<Buyer__c>{new Buyer__c(Primary_Buyer__c = true)}));
        }
        if(inventoryWrapperMap != null && inventoryWrapperMap.size() > 0){
          getRelatedProperties();
        }
          }else{
              fwObject.selectedCampaign = 'GeneralInventories';
            refreshthePropertyFilters();     
          }  
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to get all existing campaigns in the system related to the PC.       *
    * @Params      : String                                                                      *
    * @Return      : Set<Id>                                                                     * 
    *********************************************************************************************/
    @TestVisible private Set<Id> getAssociatedCampaigns(){
        Set<Id> campaignIdsSet = new Set<Id>();
        if(Network.getNetworkId() == null){
            /* Calling method to get PC's related campaign. */
            campaignIdsSet = getRelatedCampaign();
        }else{ 
            for(Assigned_PC__c thisAssignedPc : [SELECT Id, User__c, Campaign__c 
                                                    FROM Assigned_PC__c 
                                                    WHERE User__c =: UserInfo.getUserId() AND Campaign__c != null AND 
                                                          ((User__r.Leave_Start_Date__c = null AND User__r.Leave_End_Date__c = null) OR 
                                                           (User__r.Leave_Start_Date__c < TODAY AND User__r.Leave_End_Date__c < TODAY) OR 
                                                           (User__r.Leave_Start_Date__c > TODAY AND User__r.Leave_End_Date__c > TODAY)) AND 
                                                          Campaign__r.Marketing_Start_Date__c <= TODAY AND 
                                                          Campaign__r.Marketing_End_Date__c >= TODAY AND 
                                                          Campaign__r.Active__c = true 
                                                    LIMIT : LIMITS.getLimitQueryRows()]){
                campaignIdsSet.add(thisAssignedPc.Campaign__c);
            }
        }
        return campaignIdsSet;
    }  
    
    /*********************************************************************************************
    * @Description : Method to get all existing campaigns in the system related to the PC.       *
    * @Params      : Map<Id, UtilityWrapperManager.CampaignWrapper>                              *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private Map<Id, UtilityWrapperManager.CampaignWrapper> getCampaignDetails(List<Id> campaignIdsList){
        Map<Id, UtilityWrapperManager.CampaignWrapper> cwObjectMap = new Map<Id, UtilityWrapperManager.CampaignWrapper>();
        for(Campaign__c thisCampaign : [SELECT Id, Name, Campaign_Name__c,
                                                (SELECT Id, Name, Promotion_Title__c  
                                                 FROM Promotions__r 
                                                 WHERE Start_Date__c <= TODAY AND End_Date__c >= TODAY)
                                        FROM Campaign__c WHERE Active__c = true AND Id IN: campaignIdsList
                                            AND (Status__c ='Planned' OR Status__c = 'In Progress')
                                            AND Marketing_Start_Date__c <= TODAY AND Marketing_End_Date__c >= TODAY 
                                            ORDER BY LastModifiedDate DESC LIMIT : LIMITS.getLimitQueryRows()]){
            if(!thisCampaign.Promotions__r.isEmpty()){
                cwObjectMap.put(thisCampaign.Id, new UtilityWrapperManager.CampaignWrapper(true,
                                                                                           thisCampaign,
                                                                                           new List<Promotion__c>(thisCampaign.Promotions__r)));    
            }else{
                cwObjectMap.put(thisCampaign.Id, new UtilityWrapperManager.CampaignWrapper(false,
                                                                                           thisCampaign,
                                                                                           new List<Promotion__c>()));
            }
        }
        return cwObjectMap;
    }  
    
    /*********************************************************************************************
    * @Description : Method to get campaign related inventory.                                   *
    * @Params      : String                                                                      *
    * @Return      : Set<Id>                                                                     *
    *********************************************************************************************/
    @TestVisible private Set<String> getCampaignRelatedInventory(String selectedCampaign){
      Set<String> associatedInventoryIdsSet = new Set<String>();
      for(Campaign_Inventory__c thisCampaignInventory : [SELECT Id, Campaign__c, Inventory__c
                                                           FROM Campaign_Inventory__c 
                                                           WHERE Campaign__c =: selectedCampaign AND 
                                                                 Start_Date__c <= TODAY AND 
                                                                 End_Date__c >= TODAY 
                                                           LIMIT : LIMITS.getLimitQueryRows()]){
            associatedInventoryIdsSet.add(thisCampaignInventory.Inventory__c);
        }  
        return associatedInventoryIdsSet;
    }
    
    /*********************************************************************************************
    * @Description : Calling method to fetch general inventories.                                *
    * @Params      : void                                                                        *
    * @Return      : Map<Id, UtilityWrapperManager.InventoryBuyerWrapper>                        *
    *********************************************************************************************/
    @TestVisible private List<UtilityWrapperManager.InventoryBuyerWrapper> getGeneralInventories(){
      campaignProjectNameMap = new Map<String, Map<String, String>>();
        Set<Id> inventoryIdsSet = new Set<Id>();    
      List<UtilityWrapperManager.InventoryBuyerWrapper> inventoryWrapperMap = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
      Map<String, String> projectMap = new Map<String, String>();
        /* Calling method to get team users. */
        inventoryIdsSet.addAll(getTeamUsers());
        for(Inventory__c thisInventory : [SELECT Id, Property__c, Property__r.Name, Building_Location__c,Bedroom_Type__c ,CM_Price_Per_Sqft__c  ,Unit_Area_sft__c ,View_Type__c,Brand__c,
                                                 IPMS_Bedrooms__c, Special_Price_2__c, Marketing_Name__c, 
                                                 Building_Name__c, Property_Name__c, Floor__c, Area_Sqft_2__c,
                                                 Building_Location__r.Building_Name__c, Building_Location__r.Name, 
                                                 Bedrooms__c, Unit__c, Unit_Type__c, Property_Status__c,
                                                 Area__c, Selling_Price__c, Special_Price__c, Price_Per_Sqft__c,
                                                 MD_Price__c, List_Price__c, Property_Country__c, Status__c, 
                                                 CurrencyIsoCode, Floor_Package_ID__c, Floor_Package_Name__c,
                                                 Floor_Package_Type__c, List_Price_calc__c, Special_Price_calc__c
                                          FROM Inventory__c
                                          WHERE (Id IN: inventoryIdsSet OR Is_Assigned__c = false) AND 
                                                Status__c =: generalInventoryStatus AND
                                                List_Price_calc__c != null
                                          ORDER BY Unit__c ASC LIMIT : LIMITS.getLimitQueryRows()]){
            if(String.isBlank(thisInventory.Floor_Package_ID__c)){
              /* Adding parameters to the wrpper in specified order :
                 selected flag, special price flag, selectedPaymentPlan, 
                 selectedSpaMethod, inventory related data, 
                 payment plan with payment terms, jointBuyerList. */
              inventoryWrapperMap.add(
                  new UtilityWrapperManager.InventoryBuyerWrapper(false, 
                                                                  false,
                                                                  false,
                                                                  40000.00,
                                                                  thisInventory.special_Price_calc__c,
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  0,
                                                                  thisInventory,
                                                                  new Booking_Unit__c(),
                                                                  new Map<String, Payment_Plan__c>(),
                                                                  new List<Buyer__c>{new Buyer__c(Primary_Buyer__c = true)}));
            /* Populate Marketing name or Project name if marketing name is blank */
            if(String.isNotBlank(thisInventory.Marketing_Name__c)){
              if(thisInventory.Marketing_Name__c.contains('\'S')){
                thisInventory.Marketing_Name__c = thisInventory.Marketing_Name__c.remove('\'S');
              }
                projectMap.put(thisInventory.Marketing_Name__c, thisInventory.Marketing_Name__c);
            }else if(String.isNotBlank(thisInventory.Property__c)){
              if(thisInventory.Property__r.Name.contains('\'S')){
                thisInventory.Property__r.Name = thisInventory.Property__r.Name.remove('\'S');
              }
                projectMap.put(thisInventory.Property__c, thisInventory.Property__r.Name);
            }
            /* Setting the maximum and minimum values. */
            if(thisInventory.special_Price_calc__c < fwObject.priceRangeStartSelected){
              fwObject.priceRangeStartSelected = thisInventory.special_Price_calc__c;
            }
            if(thisInventory.special_Price_calc__c > fwObject.priceRangeEndSelected){
              fwObject.priceRangeEndSelected = thisInventory.special_Price_calc__c;
            }  
            }else{
            /* Calling method to get the relevant floor and package plans. */
            if(String.isNotBlank(thisInventory.Floor_Package_Type__c) && thisInventory.Floor_Package_Type__c.equalsIgnoreCase('Floor')){
              floorIdMap.put(thisInventory.Floor_Package_ID__c, thisInventory.Floor_Package_Name__c);  
            }else if(String.isNotBlank(thisInventory.Floor_Package_Type__c) && thisInventory.Floor_Package_Type__c.equalsIgnoreCase('Package')){
              packegeIdMap.put(thisInventory.Floor_Package_ID__c, thisInventory.Floor_Package_Name__c);  
            }
            }
        }   
        /* Creating map of campaign and associated projects. */
        campaignProjectNameMap.put('GeneralInventories', projectMap);
        return inventoryWrapperMap;
    }      
    
    /*********************************************************************************************
    * @Description : Method to get campaign and associated inventory details.                    *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<String, Map<Id, UtilityWrapperManager.InventoryBuyerWrapper>>           *
    *********************************************************************************************/
    @TestVisible List<UtilityWrapperManager.InventoryBuyerWrapper> getAssociatedProperties(String selectedCampaign){
        campaignProjectNameMap = new Map<String, Map<String, String>>();
        Set<String> associatedInventoryIdsSet = new Set<String>();
        List<UtilityWrapperManager.InventoryBuyerWrapper> inventoryWrapperMap = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
        Map<String, String> projectMap = new Map<String, String>();
        /* Calling method to get campaign related inventory from campaign inventory junction object. */
        associatedInventoryIdsSet = getCampaignRelatedInventory(selectedCampaign);
        if(!associatedInventoryIdsSet.isEmpty()){
            for(Inventory__c thisInventory : [SELECT Id, Property__c, Property__r.Name, Building_Location__c, Bedroom_Type__c ,CM_Price_Per_Sqft__c  ,Unit_Area_sft__c ,View_Type__c,Brand__c,
                                             IPMS_Bedrooms__c, Special_Price_2__c, Marketing_Name__c, 
                                             Building_Name__c, Property_Name__c, Floor__c, Area_Sqft_2__c,
                                             Building_Location__r.Building_Name__c, Building_Location__r.Name, 
                                             Bedrooms__c, Unit__c, Unit_Type__c, Property_Status__c,
                                             Area__c, Selling_Price__c, Special_Price__c, Price_Per_Sqft__c,
                                             MD_Price__c, List_Price__c, Property_Country__c, Status__c, 
                                             CurrencyIsoCode,  Floor_Package_ID__c, Floor_Package_Name__c, 
                                             Floor_Package_Type__c, List_Price_calc__c, Special_Price_calc__c
                                      FROM Inventory__c 
                                      WHERE Id IN: associatedInventoryIdsSet AND
                                            Status__c =: generalInventoryStatus AND
                                            List_Price_calc__c != null
                                      ORDER BY Unit__c ASC LIMIT : LIMITS.getLimitQueryRows()]){  
                if(String.isBlank(thisInventory.Floor_Package_ID__c)){
                  /* Adding parameters to the wrpper in specified order :
                   selected flag, special price flag, selectedPaymentPlan, 
                   selectedSpaMethod, inventory related data, 
                   payment plan with payment terms, jointBuyerList. */
                  inventoryWrapperMap.add(
                      new UtilityWrapperManager.InventoryBuyerWrapper(false, 
                                                                      false,
                                                                      false,
                                                                      40000.00,
                                                                      thisInventory.special_Price_calc__c, 
                                                                      '',
                                                                      '',
                                                                      '',
                                                                      '',
                                                                      0,
                                                                      thisInventory,
                                                                      new Booking_Unit__c(),
                                                                      new Map<String, Payment_Plan__c>(),
                                                                      new List<Buyer__c>{new Buyer__c(Primary_Buyer__c = true)}));
                  /* Populate Marketing name or Project name if marketing name is blank */
                if(String.isNotBlank(thisInventory.Marketing_Name__c)){
                    projectMap.put(thisInventory.Marketing_Name__c, thisInventory.Marketing_Name__c);
                }else if(String.isNotBlank(thisInventory.Property__c)){
                    projectMap.put(thisInventory.Property__c, thisInventory.Property__r.Name);
                }
                /* Setting the maximum and minimum values. */
          if(thisInventory.special_Price_calc__c < fwObject.priceRangeStartSelected){ 
            fwObject.priceRangeStartSelected = thisInventory.special_Price_calc__c;
          }
          if(thisInventory.special_Price_calc__c > fwObject.priceRangeEndSelected){
            fwObject.priceRangeEndSelected = thisInventory.special_Price_calc__c;
          }
                /* Creating map of campaign and associated projects. */
                  campaignProjectNameMap.put(fwObject.selectedCampaign, projectMap);  
                }else{
                  /* Calling method to get the relevant floor and package plans. */
              if(String.isNotBlank(thisInventory.Floor_Package_Type__c) && thisInventory.Floor_Package_Type__c.equalsIgnoreCase('Floor')){
                floorIdMap.put(thisInventory.Floor_Package_ID__c, thisInventory.Floor_Package_Name__c);  
              }else if(String.isNotBlank(thisInventory.Floor_Package_Type__c) && thisInventory.Floor_Package_Type__c.equalsIgnoreCase('Package')){
                packegeIdMap.put(thisInventory.Floor_Package_ID__c, thisInventory.Floor_Package_Name__c);  
              }
                }
            }
        }
        return inventoryWrapperMap;
    } 
    
    /*********************************************************************************************
    * @Description : Method to the associated campaign related inventories.                      *
    * @Params      : void                                                                        *
    * @Return      : Set<Id>                                                                     *
    *********************************************************************************************/
    @TestVisible private static Set<Id> getCampaignRelatedInventories(){
        Set<Id> relatedInventoryIdsSet = new Set<Id>();
        /* Calling method to get the PC's related campaign. */
        Set<Id> campaignIdsSet = getRelatedCampaign();
        system.debug('#### campaignIdsSet = '+campaignIdsSet);
        if(!campaignIdsSet.isEmpty()){
            for(Campaign_Inventory__c thisCampaignInventory : [SELECT Id, Campaign__c, End_Date__c, Inventory__c, Start_Date__c
                                                               FROM Campaign_Inventory__c
                                                               WHERE Campaign__c IN: campaignIdsSet AND 
                                                                     Start_Date__c <= TODAY AND 
                                                                     End_Date__c >= TODAY
                                                               ORDER BY LastModifiedDate DESC LIMIT : LIMITS.getLimitQueryRows()]){
                relatedInventoryIdsSet.add(thisCampaignInventory.Inventory__c); 
            }       
        }
        return relatedInventoryIdsSet;
    }
    
    /*********************************************************************************************
    * @Description : Method to get team related inventories.                                     *
    * @Params      : void                                                                        *
    * @Return      : Set<Id>                                                                     *
    *********************************************************************************************/
    public static Set<Id> getTeamUsers(){
        Set<Id> relatedInventoryIdsSet = new Set<Id>();
        for(Inventory_User__c thisInventoryUser : [SELECT Id, User__c, Inventory__c
                                                   FROM Inventory_User__c
                                                   WHERE User__c =: UserInfo.getUserId() AND 
                                                         Inventory__c != null AND 
                                                         Start_Date__c <= TODAY AND 
                                                         End_Date__c >= TODAY
                                                   ORDER BY LastModifiedDate DESC LIMIT : LIMITS.getLimitQueryRows()]){
            if(thisInventoryUser.Inventory__c != null){
                relatedInventoryIdsSet.add(thisInventoryUser.Inventory__c); 
            }
        }       
        return relatedInventoryIdsSet;
    }
    
    /*********************************************************************************************
    * @Description : Method to toggle between ascending and descending order #pagination.        *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void sortToggle(){
        try{
            system.debug('#### sortDirection '+sortDirection);
            system.debug('#### sortField '+sortField);
            system.debug('#### filterLevel '+filterLevel);
            sortDirection = sortDirection != null && sortDirection.equalsIgnoreCase('ascending') ? 'descending' : 'ascending';    
            getSortedList();   
        }catch(Exception ex){
             errorMessage = '#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage();
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to sort table #pagination.                                           *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private void getSortedList(){
        List<InventoryWrapper> inventoryWrapperList = new List<InventoryWrapper>();
        Map<Id, UtilityWrapperManager.InventoryBuyerWrapper> inventoryMap = new Map<Id, UtilityWrapperManager.InventoryBuyerWrapper>();
        /*Fetching inventories based on the filter level selected. */
        if(filterLevel == 1){
            refreshthePropertyFilters();    
        }else if(filterLevel == 2){
            refreshtheBuildingFilters();    
        }else if(filterLevel == 3){
            refreshtheBedroomFilters();    
        }else if(filterLevel == 4){
            getProperties();    
        }else if(filterLevel == 5){
          getPriceRelatedProperties();               
        }else if(filterLevel == 6){
            getAgencyRelatedInventories();   
        }else if(filterLevel == 7){
            getRelatedInventories();    
        }else if(filterLevel == 8){
            refreshFloorList();    
        }else if(filterLevel == 9){
            refreshPackageList();    
        }
         
        system.debug('#### inventoryWrapperMap '+inventoryWrapperMap);
        for(UtilityWrapperManager.InventoryBuyerWrapper thisIbwObject : inventoryWrapperMap){
            inventoryMap.put(thisIbwObject.selectedInventory.Id, thisIbwObject);
            inventoryWrapperList.add(new InventoryWrapper(sortField,
                                                           thisIbwObject.selectedInventory.Id, 
                                                           thisIbwObject.selectedInventory.List_Price_calc__c , 
                                                           thisIbwObject.selectedInventory.special_Price_calc__c));
        }
        /* Sorting in ascending order. */
        inventoryWrapperList.sort();
        /* Sorting in descending order. */
        if(String.isNotBlank(sortDirection) && sortDirection.equalsIgnoreCase('descending')){
            List<InventoryWrapper> inventoryWrapperDescendingList = new List<InventoryWrapper>();
            for(Integer i = inventoryWrapperList.size()-1; i>=0; i--){
                inventoryWrapperDescendingList.add(inventoryWrapperList.get(i));
            }
            inventoryWrapperList.clear();
            inventoryWrapperList.addAll(inventoryWrapperDescendingList);
        }
        if(!inventoryWrapperList.isEmpty()){
            inventoryWrapperMap = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
            for(InventoryWrapper thisSortedInventory : inventoryWrapperList){
                if(inventoryMap.containsKey(thisSortedInventory.inventoryId)){
                    inventoryWrapperMap.add(inventoryMap.get(thisSortedInventory.inventoryId));
                }    
            }
            showNextRecords();
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to get related PC's campaign.                                        *
    * @Params      : void                                                                        *
    * @Return      : Set<Id>                                                                     *
    *********************************************************************************************/
    @TestVisible private static Set<Id> getRelatedCampaign(){
        Set<Id> campaignIdsSet = new Set<Id>();
        for(Assigned_PC__c thisAssignedPc : [SELECT Id, User__c, Campaign__c 
                                             FROM Assigned_PC__c 
                                             WHERE User__c =: UserInfo.getUserId() AND Campaign__c != null AND
                                                  ((User__r.Leave_Start_Date__c = null AND User__r.Leave_End_Date__c = null) OR 
                                                   (User__r.Leave_Start_Date__c < TODAY AND User__r.Leave_End_Date__c < TODAY) OR 
                                                   (User__r.Leave_Start_Date__c > TODAY AND User__r.Leave_End_Date__c > TODAY)) AND 
                                                  Campaign__r.Marketing_Start_Date__c <= TODAY AND 
                                                  Campaign__r.Marketing_End_Date__c >= TODAY AND 
                                                  Start_Date__c <= TODAY AND 
                                                  End_Date__c >= TODAY AND
                                                  Campaign__r.Active__c = true 
                                             LIMIT : LIMITS.getLimitQueryRows()]){
            campaignIdsSet.add(thisAssignedPc.Campaign__c);
        }   
        return campaignIdsSet;
    }
    
    /*********************************************************************************************
    * @Description : Filters wrapper class.                                                      *
    *********************************************************************************************/
    public class FilterWrapper{
        public String selectedCampaign {get; set;}
        public String selectedPromotion {get; set;}
        public String selectedProject {get; set;}
        public String selectedBuilding {get; set;}
        public String selectedTypeOfBedroom {get; set;}
        public String selectedFloor {get; set;}
        public String selectedPackage {get; set;}
        public Decimal priceRangeStartSelected {get; set;}
        public Decimal priceRangeEndSelected {get; set;}
        
        public FilterWrapper(String selectedCampaign, String selectedPromotion, 
                             String selectedProject, String selectedBuilding, 
                             String selectedTypeOfBedroom, String selectedFloor, 
                             String selectedPackage, Decimal priceRangeStartSelected, 
                             Decimal priceRangeEndSelected){
            this.selectedCampaign = selectedCampaign;
            this.selectedPromotion = selectedPromotion;
            this.selectedProject = selectedProject;
            this.selectedBuilding = selectedBuilding;
            this.selectedTypeOfBedroom = selectedTypeOfBedroom;
            this.selectedFloor = selectedFloor;
            this.selectedPackage = selectedPackage;
            this.priceRangeStartSelected = priceRangeStartSelected;
            this.priceRangeEndSelected = priceRangeEndSelected;
        }
    }
    
    /*********************************************************************************************
    * @Description : Wrapper class for inventory.                                                *
    *********************************************************************************************/
    public class InventoryWrapper implements Comparable{
        public String sortField {get; set;}
        public String inventoryId {get; set;}
        public Decimal sellingPrice {get; set;}
        public Decimal specialPrice {get; set;}
        
        public InventoryWrapper(){ } 
        public InventoryWrapper(String sortField, String inventoryId, Decimal sellingPrice, Decimal specialPrice){
            this.sortField = sortField;
            this.inventoryId = inventoryId;
            this.sellingPrice = sellingPrice;
            this.specialPrice = specialPrice;
        }
        
        /* Implementing the compareTo() method to add sorting support to sort list of wrapper. */
        public Integer compareTo(Object objToCompare) {
            InventoryWrapper compareToInventory = (InventoryWrapper)objToCompare;
            if(String.isNotBlank(compareToInventory.sortField) && compareToInventory.sortField.equalsIgnoreCase('sellingprice')){
                if (sellingPrice == compareToInventory.sellingPrice) return 0;
                if (sellingPrice > compareToInventory.sellingPrice) return 1;
                else return -1;
            }else if(String.isNotBlank(compareToInventory.sortField) && compareToInventory.sortField.equalsIgnoreCase('specialprice')){
                if (specialPrice == compareToInventory.specialPrice) return 0;
                if (specialPrice > compareToInventory.specialPrice) return 1;
                else return -1;
            }else{
                return -1;  
            }
        }
    }
}// End of class.