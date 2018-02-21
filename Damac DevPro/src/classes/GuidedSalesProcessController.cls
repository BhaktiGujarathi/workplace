/**************************************************************************************************
* Name               : GuidedSalesProcessController                                                 
* Description        : Guided Sales process                                             
* Created Date       : NSI - Sivasankar                                                                        
* Created By         : 26/Feb/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Sivasankar          26/Feb/2017
* 1.1         NSI - Sivasankar          17/Apr/2017 - Removing the validation on field selection atleast three fields 
* 1.2         NSI - Sivasankar          17/Apr/2017 - 576 # Need to Remove dependency filter on the GSP wizard. All fields to be independent of each other                                             
***************************************************************************************************/
public with sharing class GuidedSalesProcessController extends PaginationUtility{
    
    public Guided_Sales__c newGuidedSales {get;set;}
    public Map<ID,Inventory__c> mapprojectrelatedAllInventories {get;set;}
    
    public Inventory__c selectedInventoryDetails {get;set;}
    public String selectedInventory {get;set;}
    public String errorMessage {get;set;}
    public String purposefor {get;set;}
    public String selectedProjectID {get;set;}
    public String selectedProjectName {get;set;}
    public String acdQuarter{get;set;}
    public String acdYear{get;set;}
    //variables for navigating pages
    public Integer previousPage {get;set;}
    public Integer currentPage {get;set;}
    public Integer nextPage {get;set;}

    //variables for rendering the pages
    public Boolean backFromInventory {get;set;}
    public Boolean displayHomePage {get;set;}
    public Boolean displayInquiryPage {get;set;}
    public Boolean displayProjects {get;set;}
    public Boolean displayProjectDetails {get;set;}
    public Boolean displayprojectInventories {get;set;}
    public Boolean displayInventoryDetail {get;set;}
    public Boolean renderNoUIJS {get;set;}
    public Boolean isMarketingNamePresent {get;set;}
    public Boolean isBuildingInfoAvailable {get;set;}
    //usage purpose
    public Boolean regularReturn {get;set;}
    public Boolean buyandHold {get;set;}
    public Boolean retirement {get;set;}
    public Boolean personalUse {get;set;}

    //Toast message
    public Boolean isError {get;set;}
    public Boolean isWarning {get;set;}
    public Boolean isSuccess {get;set;}

    //variables to display the picklist values in page
    public List<SelectOption> allCities {get;set;}
    public List<SelectOption> allPropertyDistricts {get;set;}
    public List<SelectOption> allProjects {get;set;}
    public List<SelectOption> allProjectsCategory {get;set;}
    public List<SelectOption> allUnitTypes {get;set;}
    public List<SelectOption> allBedroomTypes {get;set;}
    public List<SelectOption> allReadiness {get;set;}
    public List<SelectOption> allRelatedBuildings {get;set;}
    public List<SelectOption> allBrands {get;set;}
    public List<SelectOption> allViews {get;set;}
    public List<SelectOption> properyRelatedFeatures {get;set;}
    public List<SelectOption> allMasterDevelopers {get;set;}
    public List<SelectOption> allACDs {get;set;}
    public List<SelectOption> allACDYears {get;set;}
    public String[] selectedCommunityFeatures {get;set;}

    //Building Info
    public String errorMessages {get;set;}
    public Map<String,Map<String,UtilityWrapperManager.PriceRageWrapper>> mapMinMaxPrice {get;set;}
    public Map<String,List<UtilityWrapperManager.BuildingInorWrapper>> mapBuildingInfoTable {get;set;}
	public Map<String,String> mapMinMaxFloorOfUnitTypeInfo {get;set;}
	public Map<String,String> mapUnitTypeOfCategory {get;set;}
	public String unitTypeOfCategory {get;set;}
    //Promotional Campaigns
    public List<SObject> promotionalCampaigns {get;set;}
    public List<SObject> paymentPlanRec {get;set;}

    //Marketing Name Image URLs
    public Map<String,String> marketingNameLogos {get;set;}
    public Marketing_Documents__c marketingDocuments {get;set;}
    
    //Walkthrough Url parameters
   	public String redirectUrl {get; set;}
   	public String baseUrl {get; set;}

    public List<AggregateResult> allInventoryProperties {get;set;}
	@TestVisible private Set<ID> inventoryUserIds {get;set;}
    @TestVisible private Map<String,Set<String>> projectrelatedBuildings {get;set;}


    /*********************************************************************************************
    * @Description : Get the parameter from the URL which is Inquiry ID                          *
    * @Params      : ApexPages.StandardController                                                *
    * @Return      : String                                                                      *
    **********************************************************************************************/
    @testVisible private String inquiryId{
        get{
            inquiryId = ApexPages.currentPage().getParameters().get('id');
            return inquiryId;
        }
        set;
    }

    /*********************************************************************************************
    * @Description : Constructor                                                                 *
    * @Params      : ApexPages.StandardController                                                *
    **********************************************************************************************/
    public GuidedSalesProcessController(ApexPages.StandardController controller){
    	inventoryUserIds = getTeamUsers();
    	System.debug('inventoryUserIds = '+inventoryUserIds);
        newGuidedSales = new Guided_Sales__c();
        mapprojectrelatedAllInventories = new Map<ID,Inventory__c>();
        selectedInventoryDetails = new Inventory__c();
        marketingDocuments = new Marketing_Documents__c();
        marketingNameLogos = new Map<String,String>();

        //Building Info
        mapMinMaxPrice = new Map<String,Map<String,UtilityWrapperManager.PriceRageWrapper>>();
        mapBuildingInfoTable = new Map<String,List<UtilityWrapperManager.BuildingInorWrapper>>();
        mapMinMaxFloorOfUnitTypeInfo = new Map<String,String>();
        promotionalCampaigns = new List<SObject>();
        paymentPlanRec = new List<SObject>();
		mapUnitTypeOfCategory = new Map<String,String>();
		unitTypeOfCategory = '';
        //Toast
        isError = false;
        isWarning = false;
        isSuccess = false;

        purposefor = '';
        selectedInventory = '';
        errorMessage = null;
        //propetyUsage
        isMarketingNamePresent = false;
        isBuildingInfoAvailable = false;
        regularReturn = false;
        buyandHold = false;
        retirement = false;
        personalUse = false;
        renderNoUIJS = false;
        
        backFromInventory = false;
        displayHomePage = true;
        displayInquiryPage = false;
        displayProjects = false;
        displayProjectDetails = false;
        displayprojectInventories = false;
        displayInventoryDetail = false;

        pagesToShowList = new List<Integer>();
        previousPage = 0;
        currentPage = 1;
        nextPage = 2;
        pageNumber = 1;

        selectedProjectID = '';
        selectedProjectName = null;
        projectrelatedBuildings = new Map<String,Set<String>>();
        //get the picklist values
        projectrelatedBuildings = new Map<String,Set<String>>();
        allCities = new List<SelectOption>{new SelectOption('','--None--')};
        allPropertyDistricts = new List<SelectOption>{new SelectOption('','--None--')};
        allProjects = new List<SelectOption>{new SelectOption('','--None--')};
        allProjectsCategory = new List<SelectOption>{new SelectOption('','--None--')};
        allUnitTypes = new List<SelectOption>{new SelectOption('','--None--')};
        allBedroomTypes = new List<SelectOption>{new SelectOption('','--None--')};
        allReadiness = new List<SelectOption>{new SelectOption('','--None--')};
        allRelatedBuildings = new List<SelectOption>{new SelectOption('','--None--')};
        allBrands = new List<SelectOption>{new SelectOption('','--None--')};
        allViews = new List<SelectOption>{new SelectOption('','--None--')};
        allACDs = new List<SelectOption>{new SelectOption('','--None--')};
        allACDYears = new List<SelectOption>{new SelectOption('','--None--')};
        properyRelatedFeatures = new List<SelectOption>();
        selectedCommunityFeatures = new List<String>();
        allInventoryProperties = new List<AggregateResult>();
    }

    /*********************************************************************************************
    * @Description : Navigate between pages in Guided sales process                              *
    * @Params      : none                                                                        *
    * @Return      : void                                                                        *
    **********************************************************************************************/
    public void navigatePages(){
        
        System.debug('currentPage = '+currentPage);
        System.debug('nextPage = '+nextPage);
        System.debug('nextPage = '+purposefor);

        System.debug('selectedProjectID = '+selectedProjectID);
        System.debug('selectedProjectName = '+selectedProjectName);
        
        Blob encodedMName = Blob.valueOf(selectedProjectName);
        System.debug('Blob b: [' + encodedMName.toString() + ']');
        String b64 = EncodingUtil.base64Encode(encodedMName);
        System.debug('String b64: [' + b64 + ']');
        encodedMName = EncodingUtil.base64Decode(b64);
        System.debug('Blob b: [' + encodedMName.toString() + ']');
        b64 = encodedMName.toString();
        System.debug('String strUrlUTF8: [' + b64 + ']');
        selectedProjectName =  EncodingUtil.urlDecode(b64, 'UTF-8');
        System.debug('===> selectedProjectName = '+selectedProjectName);
        
        errorMessage = null;

        //Toast
        isError = false;
        isWarning = false;
        isSuccess = false;

        isMarketingNamePresent = (String.isNotBlank(selectedProjectName) ? false:true);
        try{
        	
            if(nextPage == 1){
                displayHomePage = true;
                displayInquiryPage = false;
                displayProjects = false;
                displayProjectDetails = false;
                displayprojectInventories = false;
                displayInventoryDetail = false;
                backFromInventory = false;
            }
            else if(nextPage == 2){
                //V1.2 getAllInventoryCities();
                getAllPicklistValues();

                if(String.isBlank(errorMessage)){
                    displayHomePage = false;
                    displayInquiryPage = true;
                    displayProjects = false;
                    displayProjectDetails = false;
                    displayprojectInventories = false;
                    displayInventoryDetail = false;
                    backFromInventory = false;
                    renderNoUIJS = false;
                }
            }
            else if(nextPage == 3){

                if(currentPage == 2){
                    createGuidedSales();
                    renderNoUIJS = true;
                }
                if(String.isBlank(errorMessage)){
                    getTotalRelatedProperties();
                    renderNoUIJS = false;
                    getAllPropertyRecords(newGuidedSales);

                    if(String.isBlank(errorMessage)){
                        displayHomePage = false;
                        displayInquiryPage = false;
                        displayProjects = true;
                        displayProjectDetails = false;
                        displayprojectInventories = false;
                        displayInventoryDetail = false;
                        backFromInventory = false;
                    }
                }
            }
            else if(nextPage == 4){
            	pageNumber = 1;
                if(currentPage == 3){

                    getProjectRelatedInventories();
                    getProjectRelatedBuildingInfo();
                    
                }
                renderNoUIJS = false;
                if(String.isBlank(errorMessage)){
                    displayHomePage = false;
                    displayInquiryPage = false;
                    displayProjects = false;
                    displayProjectDetails = true;
                    displayprojectInventories = true;
                    displayInventoryDetail = false;
                    backFromInventory = true;
                }
            }
            else if(nextPage == 5){
                inventoryDetailPage();
                
                renderNoUIJS = false;
                if(String.isBlank(errorMessage)){
                    displayHomePage = false;
                    displayInquiryPage = false;
                    displayProjects = false;
                    displayProjectDetails = false;
                    displayprojectInventories = false;
                    displayInventoryDetail = true;
                }
            }
        }Catch(Exception ex){
            errorMessage = (String.isNotBlank(errorMessage) ? errorMessage : '')+'\n<br/>'+ ex.getMessage();
            isError = true;
        }
    }

    /*********************************************************************************************
    * @Description : Display the selected Inventory record details                               *
    * @Params      : none                                                                        *
    * @Return      : void                                                                        *
    **********************************************************************************************/
    public void inventoryDetailPage(){
        System.debug('selectedInventory = '+selectedInventory);
        selectedInventoryDetails = new Inventory__c();
        try{
            errorMessage = null;
            if(String.isNotBlank(selectedInventory)){
                selectedInventoryDetails = [SELECT Id,ACD_Date__c,Unit_Plan__c,Marketing_Name__c,Anticipated_Completion_Date__c,Unit__c,Space_Type_Lookup_Code__c,View_Type__c,Parking__c,Building_Location__c,Building_Location__r.Number_of_Free_Parking__c,Property__c,Name,Property__r.Property_Name__c 
                                            FROM Inventory__c WHERE ID =:selectedInventory ];
                getpromotionalCampaigns();
                getpaymentPlanDetails();//calling Payment Plans
                newGuidedSales.Inventory__c = selectedInventory;
                newGuidedSales.Selected_Inventory__c = selectedInventory;
                update newGuidedSales;
                backFromInventory = true;
            }
        }Catch(Exception ex){
            errorMessage = (String.isNotBlank(errorMessage) ? errorMessage : '')+'\n<br/>'+ ex.getMessage();
            isError = true;
        }
    }

    /*********************************************************************************************
    * @Description : Display the selected Project Inventories record details                     *
    * @Params      : none                                                                        *
    * @Return      : void                                                                        *
    **********************************************************************************************/
    public void backtoProjectInventories(){
        displayprojectInventories = true;
        displayInventoryDetail = false;
    }

    public void doDone(){
        errorMessage = 'You have completed sales process successfully.';
        isSuccess = true;
    }

    /*********************************************************************************************
    * @Description : Create or update the Guided sales record for inquiry                        *
    * @Params      : none                                                                        *
    * @Return      : void                                                                        *
    **********************************************************************************************/
    @testVisible private void createGuidedSales(){
        System.debug('newGuidedSales = '+newGuidedSales);
        System.debug('regularReturn = '+regularReturn);
        System.debug('buyandHold = '+buyandHold);
        System.debug('retirement = '+retirement);
        System.debug('personalUse = '+personalUse);
        Integer counter = 0;
        
        try{
            errorMessage = null;
            if(regularReturn || buyandHold || retirement || personalUse){
                purposefor = (regularReturn ? 'Regular Return on Investment':'');
                purposefor += (buyandHold ? 'Buy and Hold for Investment Growth':'');
                purposefor += (retirement ? 'Retirement Use':'');
                purposefor += (personalUse ? 'Personal Use':'');
                purposefor = purposefor.replace('Buy',';Buy');
                purposefor = purposefor.replace('Retirement',';Retirement');
                purposefor = purposefor.replace('Personal',';Personal');
                System.debug('purposefor = '+purposefor );
                newGuidedSales.Expected_Usage_of_the_Property__c = purposefor;
            }
            //check how Many fields are populated in the guided sales.
            
            if(String.isBlank(errorMessage)){
                if(selectedCommunityFeatures != null && selectedCommunityFeatures.size() > 0){
                    newGuidedSales.Community_Features_Amenities__c = String.join(selectedCommunityFeatures,',');
                }
                if(newGuidedSales.Inquiry__c == null)
                    newGuidedSales.Inquiry__c = inquiryId;
                upsert newGuidedSales;

            }
        }
        Catch(Exception ex){
            errorMessage = (String.isNotBlank(errorMessage) ? errorMessage : '')+'\n<br/>'+ ex.getMessage();
            isError = true;
        }
    }

    /*********************************************************************************************
    * @Description : Marketing Collererals                                                       *
    * @Params      : none                                                                        *
    * @Return      : void                                                                        *
    **********************************************************************************************/
    public void getpromotionalCampaigns(){
        Set<ID> CampaignIDs = new Set<ID>();
        String query = 'SELECT ';

        System.debug('selectedInventoryDetails = '+selectedInventoryDetails);
        try{
            errorMessage = (String.isNotBlank(errorMessage) ? errorMessage : null);
            for(Campaign_Inventory__c campInv : [SELECT Campaign__c FROM Campaign_Inventory__c 
                                                WHERE Inventory__c =: selectedInventoryDetails.Id
                                                    AND Campaign__c!= null]){
                CampaignIDs.add(campInv.Campaign__c);
            }
            for(Schema.FieldSetMember fieldSets:DamacUtility.readFieldSet('GSP_Promotions','Promotion__c')){
              query += fieldSets.getFieldPath() + ', '; 
            }

            query += 'Campaign__r.Campaign_Name__c FROM Promotion__c WHERE Campaign__c IN:CampaignIDs';
            System.debug('query = '+query);
            promotionalCampaigns = (List<SObject>)(Database.query(query));
             System.debug('promotionalCampaigns = '+promotionalCampaigns);
        }
        Catch(Exception ex){
            System.debug('promotional Exception = '+ex.getMessage()+''+ex.getLineNumber());
            errorMessage = (String.isNotBlank(errorMessage) ? errorMessage : '')+'\n<br/>'+ ex.getMessage();
            isError = true;
            System.debug('errorMessage = '+errorMessage);
        }
    }

    /*********************************************************************************************
    * @Description : Marketing Collererals                                                       *
    * @Params      : none                                                                        *
    * @Return      : void                                                                        *
    **********************************************************************************************/
    public void getpaymentPlanDetails(){
        Set<ID> CampaignIDs = new Set<ID>();
        String query = 'SELECT ';
        Date currDate = Date.today();
        System.debug('selectedInventoryDetails = '+selectedInventoryDetails);
        String buildingID = selectedInventoryDetails.Building_Location__c;
        paymentPlanRec = new List<SObject>();
        try{
            errorMessage = (String.isNotBlank(errorMessage) ? errorMessage : null);
            if(selectedInventoryDetails.Building_Location__c != null){
                for(Schema.FieldSetMember fieldSets:DamacUtility.readFieldSet('PaymentTerm','Payment_Terms__c')){
                  query += fieldSets.getFieldPath() + ', '; 
                }
                query += 'Payment_Plan__r.Name FROM Payment_Terms__c WHERE Payment_Plan__r.Building_Location__c =: buildingID AND Payment_Plan__r.Effective_From__c <=:currDate AND Payment_Plan__r.Effective_To_calculated__c >=:currDate';
                System.debug('query = '+query);
                paymentPlanRec = (List<SObject>)(Database.query(query));
            }
            System.debug('paymentPlanRec = '+paymentPlanRec);
        }
        Catch(Exception ex){
            System.debug('paymentPlanRec Exception = '+ex.getMessage()+''+ex.getLineNumber());
            errorMessage = (String.isNotBlank(errorMessage) ? errorMessage : '')+'\n<br/>'+ ex.getMessage();
            isError = true;
            System.debug('errorMessage = '+errorMessage);
        }
    }

    /*********************************************************************************************
    * @Description : Get Building Information tableHeader                                        *
    * @Params      : none                                                                        *
    * @Return      : void                                                                        *
    **********************************************************************************************/
    public void getProjectRelatedBuildingInfo(){
        //Building Info
        mapMinMaxPrice = new Map<String,Map<String,UtilityWrapperManager.PriceRageWrapper>>();
        mapBuildingInfoTable = new Map<String,List<UtilityWrapperManager.BuildingInorWrapper>>();
        mapMinMaxFloorOfUnitTypeInfo = new Map<String,String>();
        mapUnitTypeOfCategory = new Map<String,String>();
        unitTypeOfCategory = '';
        List<UtilityWrapperManager.BuildingInorWrapper> lstRelatedUnits;
        Map<String,UtilityWrapperManager.PriceRageWrapper> mapRelatedBeedroomTypes;
        Map<String,Integer> mapMinFloor = new Map<String,Integer>();
        Map<String,Integer> mapMaxFloor = new Map<String,Integer>();
        
        UtilityWrapperManager.PriceRageWrapper priceWrapper;
        UtilityWrapperManager.BuildingInorWrapper buildinginfoWrapper;
        isBuildingInfoAvailable = false;
        Double mixPercent = null;
        String unitType = '',bedroomType = '',floorInfo = '',pCategory='';
        Integer minFloor = null,maxFloor=null;
        try{
            if(String.isNotBlank(selectedProjectName)){ 
                AggregateResult totalUnitsOfMarketingName = [SELECT count(ID) totalUnits FROM Inventory__c WHERE Marketing_Name__c =: String.escapeSingleQuotes(selectedProjectName) ];
                
                for(AggregateResult priceRange : [SELECT Min(Special_Price_calc__c) minPrice,IPMS_Bedrooms__c bedroom,
                                                    Max(Special_Price_calc__c) maxPrice,Marketing_Name__c,Unit_Type__c typeofUnit
                                                FROM Inventory__c 
                                                WHERE Marketing_Name__c != null 
                                                    AND Marketing_Name__c =:String.escapeSingleQuotes(selectedProjectName)//newGuidedSales.Project__c
                                                    AND Status__c = 'Released' AND (ID IN:inventoryUserIds OR Is_Assigned__c = false)
                                                GROUP BY Marketing_Name__c,Unit_Type__c,IPMS_Bedrooms__c]){
                    unitType = (String.isBlank((String)priceRange.get('typeofUnit')) ? 'N/A' :(String)priceRange.get('typeofUnit') );
                    priceWrapper = new UtilityWrapperManager.PriceRageWrapper((Decimal)priceRange.get('minPrice'),(Decimal)priceRange.get('maxPrice'));
                    bedroomType = (String)priceRange.get('bedroom');
                    
                    System.debug('unitType = '+unitType);
                    System.debug('bedroomType = '+bedroomType);
                    System.debug('priceWrapper = '+priceWrapper);

                    if(mapMinMaxPrice.containsKey(unitType)){
                        
                        mapRelatedBeedroomTypes = mapMinMaxPrice.get(unitType);
                        mapRelatedBeedroomTypes.put(bedroomType,priceWrapper);
                        System.debug('unitType 1= '+unitType);
                        System.debug('bedroomType = '+bedroomType);
                        System.debug('mapRelatedBeedroomTypes = '+mapRelatedBeedroomTypes);
                        mapMinMaxPrice.put(unitType,mapRelatedBeedroomTypes);
                    }
                    else {
                        System.debug('unitType 2= '+unitType);
                        System.debug('bedroomType = '+bedroomType);
                        mapRelatedBeedroomTypes = new Map<String,UtilityWrapperManager.PriceRageWrapper>{bedroomType => priceWrapper};
                        System.debug('mapRelatedBeedroomTypes = '+mapRelatedBeedroomTypes);
                        mapMinMaxPrice.put(unitType,mapRelatedBeedroomTypes);
                    }
                }
                System.debug('mapMinMaxPrice = '+mapMinMaxPrice );
                System.debug('totalUnitsOfMarketingName = '+totalUnitsOfMarketingName );

                for(AggregateResult aggResult : [SELECT Count(ID) units,IPMS_Bedrooms__c bedroom, CurrencyIsoCode currCode, Min(Special_Price_calc__c) minPrice,
                                                    Max(Special_Price_calc__c) maxPrice,Min(Area_Sqft_2__c) minArea,
                                                    Max(Area_Sqft_2__c) maxArea,Marketing_Name__c,Unit_Type__c typeofUnit,Project_Category__c projC,
                                                    Min(Floor_No__c) minFloor,Max(Floor_No__c) maxFloor 
                                                FROM Inventory__c 
                                                WHERE Marketing_Name__c != null AND Status__c = 'Released'
                                                    AND Marketing_Name__c =:String.escapeSingleQuotes(selectedProjectName)//newGuidedSales.Project__c 
                                                GROUP BY Marketing_Name__c,Unit_Type__c,IPMS_Bedrooms__c,Project_Category__c,CurrencyIsoCode]){

                    unitType = (String.isBlank((String)aggResult.get('typeofUnit')) ? 'N/A' :(String)aggResult.get('typeofUnit') );
                    pCategory = (String.isBlank((String)aggResult.get('projC')) ? 'N/A' :(String)aggResult.get('projC') );
                    bedroomType = (String)aggResult.get('bedroom');
                    priceWrapper = (mapMinMaxPrice.containsKey(unitType) && mapMinMaxPrice.get(unitType).containsKey(bedroomType) ? mapMinMaxPrice.get(unitType).get(bedroomType) : new UtilityWrapperManager.PriceRageWrapper(null,null));
                    
                    minFloor = (String.isBlank(String.valueOf(aggResult.get('minFloor'))) ? null :Integer.valueOf(aggResult.get('minFloor')));
                    maxFloor = (String.isBlank(String.valueOf(aggResult.get('maxFloor'))) ? null :Integer.valueOf(aggResult.get('maxFloor')));
                    
                    System.debug('minFloor= '+minFloor);
                    System.debug('maxFloor= '+maxFloor);
                    System.debug('unitType 21= '+unitType);
                    System.debug('bedroomType = '+bedroomType);
                    System.debug('priceWrapper = '+priceWrapper);

                    buildinginfoWrapper = new UtilityWrapperManager.BuildingInorWrapper( (String)aggResult.get('bedroom'),
                                                                                         (Integer)aggResult.get('units'),
                                                                                         ((Double)(((Integer)aggResult.get('units') / (Decimal)totalUnitsOfMarketingName.get('totalUnits'))*100).setScale(1)),//setScale(2, RoundingMode.HALF_UP);
                                                                                         priceWrapper.minPrice,
                                                                                         priceWrapper.maxPrice,
                                                                                         (Decimal)aggResult.get('minArea'),
                                                                                         (Decimal)aggResult.get('maxArea'),
                                                                                         (String)aggResult.get('currCode')
                                                                                        );
                    System.debug('buildinginfoWrapper = '+buildinginfoWrapper);
                    System.debug('mapMinFloor = '+mapMinFloor);
                    System.debug('mapMaxFloor = '+mapMaxFloor);
                    
                    if(mapBuildingInfoTable.containsKey(unitType)){
                        System.debug('unitType 11 = '+unitType);
                        lstRelatedUnits = mapBuildingInfoTable.get(unitType);
                        lstRelatedUnits.add(buildinginfoWrapper);
                        mapBuildingInfoTable.put(unitType,lstRelatedUnits);
                        mapUnitTypeOfCategory.put(unitType,pCategory);
                        //MinMax Floor
                        if(mapMinFloor.get(unitType) > minFloor)
                        	mapMinFloor.put(unitType,minFloor);
                        if(mapMaxFloor.get(unitType) < maxFloor)
                        	mapMaxFloor.put(unitType,maxFloor);
                    }
                    else {
                        System.debug('unitType 122= '+unitType);
                        lstRelatedUnits = new List<UtilityWrapperManager.BuildingInorWrapper>{buildinginfoWrapper};
                        mapBuildingInfoTable.put(unitType,lstRelatedUnits);
                        mapUnitTypeOfCategory.put(unitType,pCategory);
                        unitTypeOfCategory += (String.isNotBlank(unitTypeOfCategory) ? ',':'')+unitType;
                        //MinMax Floor
                        mapMinFloor.put(unitType,minFloor);
                        mapMaxFloor.put(unitType,maxFloor);
                        //mapMinMaxFloorOfUnitTypeInfo.put(unitType,floorInfo);
                    }
                }
                if(mapBuildingInfoTable.size() > 0){ isBuildingInfoAvailable = true; }
                
                for(String unitTypes : mapBuildingInfoTable.keySet()){
                	floorInfo = ':Floors ';
                	if(mapMinFloor != null && mapMinFloor.containsKey(unitTypes))
                		floorInfo += (mapMinFloor.get(unitTypes) == null ? 'N/A to ' :''+mapMinFloor.get(unitTypes)+' to ');
                	if(mapMaxFloor != null && mapMaxFloor.containsKey(unitTypes))
                		floorInfo += (mapMaxFloor.get(unitTypes) == null ? 'N/A' :''+mapMaxFloor.get(unitTypes));
                	mapMinMaxFloorOfUnitTypeInfo.put(unitTypes,floorInfo);
                }
                
                System.debug('mapMinMaxFloorOfUnitTypeInfo = '+mapMinMaxFloorOfUnitTypeInfo );
                System.debug('mapBuildingInfoTable = '+mapBuildingInfoTable );
                System.debug('mapUnitTypeOfCategory = '+mapUnitTypeOfCategory );
            }
        }Catch(Exception ex){
            errorMessage = (String.isNotBlank(errorMessage) ? errorMessage : '')+'\n<br/>'+ ex.getMessage();
            isError = true;
        }
    }

    /*********************************************************************************************
    * @Description : Search the Properties based on new Flters                                   *
    * @Params      : none                                                                        *
    * @Return      : void                                                                        *
    **********************************************************************************************/
    public void getProjectRelatedInventories(){
        System.debug('selectedProjectID = '+selectedProjectID);
        System.debug('selectedProjectName = '+selectedProjectName);
        String conditionalString = prepareconditionalString(newGuidedSales);
        System.debug('conditionalString = '+conditionalString);
        errorMessage = null;
        String stringAssignedIds = '';
        for(ID assID : inventoryUserIds)
        	stringAssignedIds += (String.isNotBlank(stringAssignedIds) ? ',':'')+'\''+assID+'\'';
        stringAssignedIds = (String.isNotBlank(stringAssignedIds) ? ' AND (ID IN('+stringAssignedIds+') OR Is_Assigned__c = false)' : ' AND Is_Assigned__c = false');
        System.debug('== > stringAssignedIds = '+stringAssignedIds);
        String condition= 'Id,Name FROM Inventory__c WHERE Status__c = \'Released\''+stringAssignedIds+
                            +((String.isNotBlank(selectedProjectName)) ? ' AND Marketing_Name__c = \''+String.escapeSingleQuotes(selectedProjectName)+'\'' : '')+
                            +((String.isNotBlank(conditionalString)) ? conditionalString : '')+
                            +' ORDER BY Unit__c,Floor__c LIMIT 50000 ';
        mapprojectrelatedAllInventories = new Map<ID,Inventory__c>();
        try{
            if(String.isNotBlank(selectedProjectName)){

                    System.debug('Final condition = '+condition);
                for(Inventory__c inv : UtilityQueryManager.getInventoryList(condition,null))
                    mapprojectrelatedAllInventories.put(inv.Id,inv);
                
                //Marketing Documents
                for(Marketing_Documents__c mDocs : [SELECT Brochure_URL__c,Walkthrough_URL__c,Master_Brochure_URL__c,Factsheet_URL__c,Building_URL__c,Features_Amenities_URL__c,Floor_Plan_URL__c,Logo_URL__c,Marketing_Collateral_URL__c,MD_URL__c,Project_URL__c,Unit_Features_URL__c 
                                                        FROM Marketing_Documents__c 
                                                        WHERE Name =:String.escapeSingleQuotes(selectedProjectName) LIMIT 1])
                    marketingDocuments = mDocs;

                System.debug('marketingDocuments = '+marketingDocuments);
                
                recordsList = new List<Id>(mapprojectrelatedAllInventories.keySet());
                
                //Pagination methods
                 /* Calling method to count the total number of pages. */
                countTotalPages();  
                /* Calling method to set the next and previous flags. */
                setPreviousNextFlags();
                /* Calling method to show the relevant records as per the pagination. */
                showRecords();
            }
        }
        Catch(Exception ex){
            System.debug('=====> '+ex+'=='+ex.getLineNumber());
            errorMessage = (String.isNotBlank(errorMessage) ? errorMessage : '')+'\n<br/>'+ ex.getMessage();
            isError = true;
        }
    }

    /*********************************************************************************************
    * @Description : get total properties                                                        *
    * @Params      : Guided_Sales__c                                                             *
    * @Return      : none                                                                        *
    **********************************************************************************************/
    public void getTotalRelatedProperties(){
        /*errorMessage = null;
        String conditionalString = prepareconditionalString(newGuidedSales);
        List<AggregateResult> lstAggResults = Database.query('SELECT Property__c FROM Inventory__c WHERE Status__c = \'Released\' AND Property__c != null'+((String.isNotBlank(conditionalString)) ? conditionalString : '')+' GROUP BY Property__c');
        //totalPropertyRecords = lstAggResults.size();
        */

    }

    /*********************************************************************************************
    * @Description : Get all property name                                                       *
    * @Params      : Guided_Sales__c                                                             *
    * @Return      : none                                                                        *
    **********************************************************************************************/
    @testVisible private void getAllPropertyRecords(Guided_Sales__c searchGuidedSales){
        
        String conditionalString = prepareconditionalString(searchGuidedSales);
        marketingNameLogos = new Map<String,String>();
        System.debug('conditionalString = '+conditionalString);
        errorMessage = null;
        allInventoryProperties = new List<AggregateResult>();
        for(AggregateResult agg : Database.query('SELECT Marketing_Name__c mName,'+//Property__c propID,
                                                        +'Marketing_Name_Doc__r.Name mdName'+
                                                +' FROM Inventory__c'+ 
                                                    ' WHERE Status__c =\'Released\' AND Marketing_Name__c != null AND (ID IN:inventoryUserIds OR Is_Assigned__c = false)'+
                                                    +((String.isNotBlank(conditionalString)) ? conditionalString : '') 
                                                +' GROUP BY Marketing_Name__c,Marketing_Name_Doc__r.Name'// Property__c,URL__c,Property__r.Property_Name__c//+
                                            )){
            System.debug('agg = '+agg);
            allInventoryProperties.add(agg);
            marketingNameLogos.put((String)agg.get('mdName'),'');
        }
        if(allInventoryProperties.isEmpty() || allInventoryProperties.size() == 0){
            errorMessage = (String.isNotBlank(errorMessage) ? errorMessage :'')+'\n<br/> Oops, you&#x27;ve no available units for current search, please modify the filters.';
            isWarning = true;
        } 
        else {
            System.debug('marketingNameLogos = '+marketingNameLogos);
            for(Marketing_Documents__c marketingDocuments : [SELECT Name,Logo_URL__c FROM Marketing_Documents__c WHERE Name IN:marketingNameLogos.keySet()]){
                if(marketingNameLogos.containsKey(marketingDocuments.Name))
                    marketingNameLogos.put(marketingDocuments.Name,marketingDocuments.Logo_URL__c);
            }
        }
        System.debug('marketingNameLogos = '+marketingNameLogos);
    }

    /*********************************************************************************************
    * @Description : It will prepare the conditional string based on customer filters            *
    * @Params      : Guided_Sales__c                                                             *
    * @Return      : String                                                                      *
    **********************************************************************************************/
    @testVisible private String prepareconditionalString(Guided_Sales__c guidedSales){
        System.debug('prepareconditionalString guidedSales = '+guidedSales);
        String conditionsString = '';
        Map<String,Integer> budgetRangeValues;
        errorMessage = null;
        conditionsString += ((String.isNotBlank(guidedSales.City__c)) ? ';Address__r.City__c = \''+guidedSales.City__c+'\'' : '');
        conditionsString += ((String.isNotBlank(guidedSales.Master_Development__c)) ? ';Property__r.District__c = \''+guidedSales.Master_Development__c+'\'' : '');
        conditionsString += ((String.isNotBlank(guidedSales.Project__c)) ? ';Marketing_Name__c = \''+ guidedSales.Project__c+'\'' : '');
        conditionsString += ((String.isNotBlank(guidedSales.Project_Category__c)) ? ';Project_Category__c = \''+guidedSales.Project_Category__c+'\'' : '');
        conditionsString += ((String.isNotBlank(guidedSales.Type__c)) ? ';Unit_Type__c = \''+guidedSales.Type__c+'\'' : '');
        conditionsString += ((String.isNotBlank(guidedSales.Bedroom_Type__c)) ? ';IPMS_Bedrooms__c = \''+guidedSales.Bedroom_Type__c+'\'' : '');
        conditionsString += ((String.isNotBlank(guidedSales.Readiness__c)) ? ';Property_Status__c = \''+guidedSales.Readiness__c+'\'' : '');
        
        conditionsString += ((String.isNotBlank(guidedSales.Views__c)) ? ';View_Type__c = \''+guidedSales.Views__c+'\'' : '');
        conditionsString += ((String.isNotBlank(guidedSales.Brand__c)) ? ';Brand__c = \''+guidedSales.Brand__c+'\'': '');
        //conditionsString += ((String.isNotBlank(guidedSales.ACD__c)) ? ';Anticipated_Completion_Date__c = \''+guidedSales.ACD__c+'\'': '');
        conditionsString +=((String.isNotBlank(acdYear)) ? ';Anticipated_Completion_Date__c LIKE \'%' + (String.isNotBlank(acdQuarter) ? acdQuarter : '') + ' ' + acdYear + '\'' : ''); 
        conditionsString += ((String.isNotBlank(guidedSales.Type_of_Booking__c) && !guidedSales.Type_of_Booking__c.containsIgnoreCase('Unit')) ? ';Floor_Package_Type__c = \''+guidedSales.Type_of_Booking__c+'\'': '');
        
        if(String.isNotBlank(guidedSales.Community_Features_Amenities__c) && guidedSales.Community_Features_Amenities__c.length() > 2){
            String propertyIDs = '';
            String commFutureVal = guidedSales.Community_Features_Amenities__c.replace('[','');
            commFutureVal = commFutureVal.replace(']','');
            String[] commfuture = commFutureVal.split(',');
            System.debug('!@ commfuture = '+commfuture);
            for(Community_Feature__c cFeature : new List<Community_Feature__c>([SELECT Name,Property__c 
                                                                                    FROM Community_Feature__c 
                                                                                    WHERE Name IN: commfuture
                                                                                    AND Property__c != null
                                                                                ])){
                propertyIDs += (String.isNotBlank(propertyIDs) ? ',':'')+'\''+cFeature.Property__c+'\'';
                
            }
            conditionsString += (String.isBlank(propertyIDs) ? '' : ';Property__c IN ('+propertyIDs+')');
            System.debug('!@ propertyIDs = '+propertyIDs);
        }
	
        if(String.isNotBlank(guidedSales.Budget__c)){
            budgetRangeValues = splitRangeString(guidedSales.Budget__c,true);
            conditionsString += ((budgetRangeValues.containsKey('startRange') && budgetRangeValues.get('startRange') != null) ? ';Special_Price__c > '+budgetRangeValues.get('startRange') : '');
            
            conditionsString += ((budgetRangeValues.containsKey('endRange') && budgetRangeValues.get('endRange') != null && budgetRangeValues.get('endRange') > 0 ) ? ';Special_Price__c <= '+budgetRangeValues.get('endRange') : '');
        }
        
        if(String.isNotBlank(guidedSales.Size__c)){
        	budgetRangeValues = splitRangeString(guidedSales.Size__c,false);
            conditionsString += ((budgetRangeValues.containsKey('startRange') && budgetRangeValues.get('startRange') != null) ? ';Area_Sqft_2__c > '+budgetRangeValues.get('startRange') : '');
            conditionsString += ((budgetRangeValues.containsKey('endRange') && budgetRangeValues.get('endRange') != null && budgetRangeValues.get('endRange') > 0 ) ? ';Area_Sqft_2__c <= '+budgetRangeValues.get('endRange') : '');
        }
        conditionsString = ((String.isNotBlank(conditionsString)) ? conditionsString.replace(';',' AND ') : '');
        System.debug('conditionsString'+conditionsString);

        return conditionsString;
    }

    /*********************************************************************************************
    * @Description : Get all the picklist values for the guided sales process                    *
    * @Params      : none                                                                        *
    * @Return      : void                                                                        *
    **********************************************************************************************/
    public void getAllPicklistValues(){
        
        Set<String> setPicklist = new Set<String>();
        Map<String,Set<String>> mapOfSetPicklist = new Map<String,Set<String>>();
        System.debug('Selected newGuidedSales = '+newGuidedSales);
        getProperyFetures();
        errorMessage = null;
        projectrelatedBuildings = new Map<String,Set<String>>();
        //Initialise the picklist values
        allCities = new List<SelectOption>{new SelectOption('','--None--')};
        allPropertyDistricts = new List<SelectOption>{new SelectOption('','--None--')};
        allProjects = new List<SelectOption>{new SelectOption('','--None--')};
        allProjectsCategory = new List<SelectOption>{new SelectOption('','--None--')};
        allUnitTypes = new List<SelectOption>{new SelectOption('','--None--')};
        allBedroomTypes = new List<SelectOption>{new SelectOption('','--None--')};

        allReadiness = new List<SelectOption>{new SelectOption('','--None--')};
        allRelatedBuildings = new List<SelectOption>{new SelectOption('','--None--')};
        allBrands = new List<SelectOption>{new SelectOption('','--None--')};
        allViews = new List<SelectOption>{new SelectOption('','--None--')};
        allACDs = new List<SelectOption>{new SelectOption('','--None--')};
        allACDYears = new List<SelectOption>{new SelectOption('','--None--')};

        try{
        	mapOfSetPicklist.put('city',new Set<String>());
        	mapOfSetPicklist.put('district',new Set<String>());
        	mapOfSetPicklist.put('marketingName',new Set<String>());
        	mapOfSetPicklist.put('pCategory',new Set<String>());
        	mapOfSetPicklist.put('types',new Set<String>());
        	mapOfSetPicklist.put('bedroom',new Set<String>());
        	mapOfSetPicklist.put('status',new Set<String>());
        	mapOfSetPicklist.put('views',new Set<String>());
        	mapOfSetPicklist.put('brand',new Set<String>());
        	mapOfSetPicklist.put('views',new Set<String>());
        	
        	
            for(AggregateResult thisInventory:[SELECT View_Type__c views,Brand__c brand,IPMS_Bedrooms__c bedroom,Unit_Type__c types,Address__r.City__c city,
                                                    Building_Location__r.Building_Name__c buildingName,
                                                    Project_Category__c pCategory,Property_Status__c status,Property__r.District__c district,Marketing_Name__c marketingName                                      
                                                FROM Inventory__c
                                                WHERE Status__c = 'Released' AND (ID IN:inventoryUserIds OR Is_Assigned__c = false)
                                                    //AND Marketing_Name__c =: newGuidedSales.Project__c
                                                GROUP BY Brand__c,View_Type__c,IPMS_Bedrooms__c,Unit_Type__c,Property_Status__c,Address__r.City__c,
                                                    Building_Location__r.Building_Name__c,Property__r.Property_Name__c,Property__r.District__c,Marketing_Name__c ,
                                                    Project_Category__c
                                            ]){
                System.debug('mapOfSetPicklist = '+mapOfSetPicklist);
                //V1.2
                if(String.isNotBlank((String)thisInventory.get('city')) && mapOfSetPicklist.containsKey('city') && !( mapOfSetPicklist.get('city').contains(((String)thisInventory.get('city')).toUpperCase() ) ) ){
                    allCities.add(new SelectOption((String)thisInventory.get('city'),(String)thisInventory.get('city')));
                    mapOfSetPicklist.get('city').add(((String)thisInventory.get('city')).toUpperCase() );
                }
                if(String.isNotBlank((String)thisInventory.get('district'))  && mapOfSetPicklist.containsKey('district') && !( mapOfSetPicklist.get('district').contains(((String)thisInventory.get('district')).toUpperCase() ) ) ){
                    allPropertyDistricts.add(new SelectOption((String)thisInventory.get('district'),(String)thisInventory.get('district')));
                    mapOfSetPicklist.get('district').add(((String)thisInventory.get('district')).toUpperCase() );
                }
                if(String.isNotBlank((String)thisInventory.get('marketingName'))  && mapOfSetPicklist.containsKey('marketingName') && !( mapOfSetPicklist.get('marketingName').contains(((String)thisInventory.get('marketingName')).toUpperCase() ) ) ){
                    allProjects.add(new SelectOption((String)thisInventory.get('marketingName'),(String)thisInventory.get('marketingName')));
                    mapOfSetPicklist.get('marketingName').add(((String)thisInventory.get('marketingName')).toUpperCase() );
                }
                //V1.2
                if(String.isNotBlank((String)thisInventory.get('pCategory'))  && mapOfSetPicklist.containsKey('pCategory') && !( mapOfSetPicklist.get('pCategory').contains(((String)thisInventory.get('pCategory')).toUpperCase() ) ) ){
                    allProjectsCategory.add(new SelectOption((String)thisInventory.get('pCategory'),(String)thisInventory.get('pCategory')));
                    mapOfSetPicklist.get('pCategory').add(((String)thisInventory.get('pCategory')).toUpperCase() );
                }
                if(String.isNotBlank((String)thisInventory.get('types'))  && mapOfSetPicklist.containsKey('types') && !( mapOfSetPicklist.get('types').contains(((String)thisInventory.get('types')).toUpperCase() ) ) ){
                    allUnitTypes.add(new SelectOption((String)thisInventory.get('types'),(String)thisInventory.get('types')));
                    mapOfSetPicklist.get('types').add(((String)thisInventory.get('types')).toUpperCase() );
                }
                if(String.isNotBlank((String)thisInventory.get('bedroom'))  && mapOfSetPicklist.containsKey('bedroom') && !( mapOfSetPicklist.get('bedroom').contains(((String)thisInventory.get('bedroom')).toUpperCase() ) ) ){
                    allBedroomTypes.add(new SelectOption((String)thisInventory.get('bedroom'),(String)thisInventory.get('bedroom')));
                    mapOfSetPicklist.get('bedroom').add(((String)thisInventory.get('bedroom')).toUpperCase() );
                }
                if(String.isNotBlank((String)thisInventory.get('status'))  && mapOfSetPicklist.containsKey('status') && !( mapOfSetPicklist.get('status').contains(((String)thisInventory.get('status')).toUpperCase() ) ) ){
                    allReadiness.add(new SelectOption((String)thisInventory.get('status'),(String)thisInventory.get('status')));
                    mapOfSetPicklist.get('status').add(((String)thisInventory.get('status')).toUpperCase() );
                    setPicklist.add((String)thisInventory.get('status'));
                }
                if(String.isNotBlank((String)thisInventory.get('views'))  && mapOfSetPicklist.containsKey('views') && !( mapOfSetPicklist.get('views').contains(((String)thisInventory.get('views')).toUpperCase() ) ) ){
                    allViews.add(new SelectOption((String)thisInventory.get('views'),(String)thisInventory.get('views')));
                    mapOfSetPicklist.get('views').add(((String)thisInventory.get('views')).toUpperCase() );
                    setPicklist.add((String)thisInventory.get('views'));
                }
                if(String.isNotBlank((String)thisInventory.get('brand'))  && mapOfSetPicklist.containsKey('brand') && !( mapOfSetPicklist.get('brand').contains(((String)thisInventory.get('brand')).toUpperCase() ) ) ){
                    allBrands.add(new SelectOption((String)thisInventory.get('brand'),(String)thisInventory.get('brand')));
                    mapOfSetPicklist.get('brand').add(((String)thisInventory.get('brand')).toUpperCase() );
                    setPicklist.add((String)thisInventory.get('brand'));
                }
            }
			setPicklist.clear();
			/*for(Inventory__c thisInventory : [SELECT Anticipated_Completion_Date__c FROM Inventory__c
                                                WHERE Status__c = 'Released' AND Anticipated_Completion_Date__c != null])
				if(String.isNotBlank(thisInventory.Anticipated_Completion_Date__c) && !setPicklist.contains(thisInventory.Anticipated_Completion_Date__c) ){
                    allACDs.add(new SelectOption(thisInventory.Anticipated_Completion_Date__c,thisInventory.Anticipated_Completion_Date__c));
                    setPicklist.add(thisInventory.Anticipated_Completion_Date__c);
                }
			*/
			for(Inventory__c thisInventory : [SELECT ACD_Date__c FROM Inventory__c
											  WHERE Status__c = 'Released' AND ACD_Date__c != null])
				if(String.isNotBlank(thisInventory.ACD_Date__c)){
					Date d = Date.valueOf(thisInventory.ACD_Date__c);

					if(!setPicklist.contains(String.valueOf(d.year())))
						allACDYears.add(new SelectOption(String.valueOf(d.year()), String.valueOf(d.year())));
					setPicklist.add(String.valueOf(d.year()));
				}
				
            System.debug('setPicklist = '+setPicklist);
            System.debug('allCities = '+allCities);
            System.debug('allPropertyDistricts = '+allPropertyDistricts);
            System.debug('allProjects = '+allProjects);

            //if the pick list has one value then auto populate the values in it.
            if(allCities.size() == 2) { newGuidedSales.City__c = allCities[1].getValue(); }
            if(allPropertyDistricts.size() == 2) { newGuidedSales.Master_Development__c = allPropertyDistricts[1].getValue(); }
            if(allProjects.size() == 2) { newGuidedSales.Project__c = allProjects[1].getValue(); }

            if(allProjectsCategory.size() == 2) { newGuidedSales.Project_Category__c = allProjectsCategory[1].getValue(); }
            if(allUnitTypes.size() == 2) { newGuidedSales.Type__c = allUnitTypes[1].getValue(); }
            if(allBedroomTypes.size() == 2) { newGuidedSales.Bedroom_Type__c = allBedroomTypes[1].getValue(); }
            if(allReadiness.size() == 2) { newGuidedSales.Readiness__c = allReadiness[1].getValue(); }
            if(allBrands.size() == 2) { newGuidedSales.Brand__c = allBrands[1].getValue(); }
            if(allViews.size() == 2) { newGuidedSales.Views__c = allViews[1].getValue(); }
            //Sort the Bedroom types
            allCities.sort();
            allPropertyDistricts.sort();
            allProjects.sort();
            //allACDs.sort();
            allACDYears.sort();
            allProjectsCategory.sort();
            allBrands.sort();
            allBedroomTypes.sort();
            allUnitTypes.sort();
            allReadiness.sort();
            allViews.sort();

            System.debug('allProjectsCategory = '+allProjectsCategory);
            System.debug('allUnitTypes = '+allUnitTypes);
            System.debug('allBedroomTypes = '+allBedroomTypes);
            System.debug('allReadiness = '+allReadiness);
            System.debug('allViews = '+allViews);
            System.debug('allBrands = '+allBrands);
        }
        Catch(Exception ex){
            errorMessage = (String.isNotBlank(errorMessage) ? errorMessage : '')+'\n<br/>'+ ex.getMessage();
            isError = true;
        }
    }

    /*********************************************************************************************
    * @Description : Get related property Features                                               *
    * @Params      : none                                                                        *
    * @Return      : void                                                                        *
    **********************************************************************************************/
    public void getProperyFetures(){
        properyRelatedFeatures = new List<SelectOption>();
        errorMessage = null;
        Set<String> setfutureNames = new Set<String>();
        properyRelatedFeatures.add(new SelectOption('','--None--'));
        System.debug('selectedProjectName  = '+newGuidedSales.Project__c);
        //V1.2
        for(Community_Feature__c cFeature : new List<Community_Feature__c>([SELECT Name//,Property__c 
                                                                                FROM Community_Feature__c ORDER By Name ASC LIMIT 1000//,Property__c LIMIT 1000
                                                                                //WHERE Property__r.Property_Name__c =:newGuidedSales.Project__c
                                                                                //V1.2 WHERE Property__c =:inventory.Property__c
                                                                                ]))
            if(!setfutureNames.contains(cFeature.Name)){
            	properyRelatedFeatures.add(new SelectOption(cFeature.Name,cFeature.Name));
            	setfutureNames.add(cFeature.Name);
            }
    }

    /*********************************************************************************************
    * @Description : Method to split the budget string.                              *
    * @Params      : none                                                                        *
    * @Return      : void                                                                        *
    **********************************************************************************************/
    @testVisible private Map<String,Integer> splitRangeString(String splitTheRange, Boolean isBudget){
    	System.debug('startRage = '+splitTheRange+' : endRange = '+isBudget);
        errorMessage = null;
        Map<String,Integer> mapRange = new Map<String,Integer>();
        String[] budgetRangeList ;
        Integer startRange,endRange;
        
        if(String.isNotBlank(splitTheRange)){
            
            if(!isBudget){
                splitTheRange = ( !isBudget ? splitTheRange.replace('-',' - ') : splitTheRange);
                splitTheRange = ( !isBudget ? splitTheRange.replace('<','< ') : splitTheRange);
                splitTheRange = ( !isBudget ? splitTheRange.replace('>','> ') : splitTheRange);
            }
            
            //Split the range
            splitTheRange = (String.isNotBlank(splitTheRange) ? splitTheRange.replace('K','000') : splitTheRange);
            splitTheRange = (String.isNotBlank(splitTheRange) ? splitTheRange.replace('M','000000') : splitTheRange);
            budgetRangeList = (String.isNotBlank(splitTheRange) ? splitTheRange.split(' '):new List<String>());
            System.debug('budgetRangeList = '+budgetRangeList);
            startRange = ((budgetRangeList.size() == 3 ) ? Integer.valueOf(budgetRangeList[0]) : ((budgetRangeList.size() == 2 ) ? (String.isNotBlank(budgetRangeList[0].trim()) ? (budgetRangeList[0].trim().equalsIgnoreCase('<') ? 0 :Integer.valueOf(budgetRangeList[1])) : null) : null));
            endRange = ((budgetRangeList.size() == 3 ) ? Integer.valueOf(budgetRangeList[2]) : ((budgetRangeList.size() == 2 ) ? (String.isNotBlank(budgetRangeList[0].trim()) ? (budgetRangeList[0].trim().equalsIgnoreCase('<') ? Integer.valueOf(budgetRangeList[1]) : 0) : null) : null));
            System.debug('startRage = '+startRange+' : endRange = '+endRange);
            mapRange.put('startRange',startRange);
            mapRange.put('endRange',endRange);
        }
        return mapRange;
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
    * @Description : Method to get walkthrough URL.                                              *
    * @Params      : String                                                                      *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void getWalkthroughUrl(){

		system.debug('#### baseUrl ==>'+ baseUrl);
		try{
			HttpRequest req = new HttpRequest();
			req.setEndpoint(baseUrl);
			req.setMethod('GET');
			Http http = new Http();
			HTTPResponse res = http.send(req);
			System.debug(res.getBody());
			String responseUrl = res.getBody(); 
			if(String.isNotBlank(responseUrl) && responseUrl.containsIgnoreCase('URL=') && responseUrl.containsIgnoreCase('\n')){
				redirectUrl = responseUrl.substringBetween('URL=','\n');
			}else{
				redirectUrl = '';
			 }
		}catch(Exception ex){
			system.debug('Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage()); 
		}
    }
}