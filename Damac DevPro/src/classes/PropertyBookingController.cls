/***********************************************************************************************************************************
* Name               : PropertyBookingController                                                                       *
* Description        : Controller class for PropertyBooking page, has below functions.                                 *
* Created Date       : 05/02/2017                                                                                      *
* Created By         : NSI                                                                                             *
* ---------------------------------------------------------------------------------------------------------------------*
* VERSION     AUTHOR               DATE            COMMENTS                                                               *
* 1.0         NSI - Vineet         05/02/2017      Initial Draft.                                                         *
* 1.1         NSI - Vineet         08/06/2017       Added field update on SR to store the names of the selected units.   
  1.2         Naresh (Accely)      24/06/2017      Call DroolWebService Class's Method(createRequestData) for Drool Web Service
  *
 
**************************************************************************************************************************************/

public class PropertyBookingController extends PaginationUtility{
    
    public String selectedCampaignId {get; set;}
    public String errorMessage {get; set;} 
    public String errorPrefix {get; set;} 
    public String mode {get; set;}
    public Boolean showScreen1 {get; set;} 
    public Boolean showScreen2 {get; set;} 
    public Boolean showScreen3 {get; set;}
    public Boolean showScreen4 {get; set;}
    public Boolean isError {get; set;}
    public Boolean isSuccess {get; set;}
    public Boolean isSubmitted {get; set;}
    public List<Id> inventoryIdsList {get; set;}
    public Set<Id> IDServiceRequest = new Set<Id>();
    public List<DH_PromotionsWrapper> finalWrap{get;set;}

    public UtilityWrapperManager availableInventoriesList {get; set;} 
    Set<Id> profileIds = new Set<Id>();
    //Map<Id, Profile> profileMap = new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE Name IN ('Contracts Team', 'System Administrator', 'Sales Admin')]);
    @TestVisible private static String generalInventoryStatus = system.Label.General_Unit_Status;
    @TestVisible private static String agencyEligibleCountryString = '';
    private void init(){
        isError = false;
        errorMessage = '';
        errorPrefix = system.Label.Error_Prefix;
    }
    
    /*********************************************************************************************
    * @Description : Controller class.                                                           *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public PropertyBookingController(){ 
      system.debug('#### Property Booking Controller');
        try{
            for(Profile thisProfile : [SELECT Id, Name FROM Profile WHERE Name IN ('Contracts Team', 'System Administrator', 'Sales Admin')]){
                profileIds.add(thisProfile.Id);
            }
          init();
          showScreen1 = true;
          showScreen2 = false;
          showScreen3 = false;
          showScreen4 = false;   
          isSubmitted = false; 
          availableInventoriesList = new UtilityWrapperManager(); 
          availableInventoriesList.dealRecord = new NSIBPM__Service_Request__c();
          availableInventoriesList.ibwList = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
          String dealId = apexpages.currentpage().getparameters().get('id');
        if(String.isNotBlank(dealId)){ 
            /* Calling method to pre-populate deal data.*/
        prePopulateData(dealId);
        }else if(String.isNotBlank(availableInventoriesList.dealRecord.Id)){
        /* Calling method to pre-populate deal data.*/
        prePopulateData(availableInventoriesList.dealRecord.Id);  
      }
        }catch(Exception ex){
          isError = true;
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();   
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to show units.                                                       *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void selectUnits(){
        init();
        Set<Id> selectedInventoryIdsSet = new Set<Id>();
        try{
          /* Calling method to check the availability of inventories. */
          for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : availableInventoriesList.ibwList){
              if(thisInventory.isSelected){
                selectedInventoryIdsSet.add(thisInventory.selectedInventory.Id);
              }
            }
          if(String.isNotBlank(availableInventoriesList.dealRecord.Booking_Wizard_Level__c) && 
         availableInventoriesList.dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 5')){
          isError = true;
              isSuccess = true;
              isSubmitted = true;
              errorPrefix = '';
              errorMessage = system.Label.Error_Deal_Submitted.replace('#DEAL_RECORD_ID#', '\'' + availableInventoriesList.dealRecord.Id + '\'').replace('#DEAL_ID#', String.isNotBlank(availableInventoriesList.dealRecord.Deal_ID__c) ? availableInventoriesList.dealRecord.Deal_ID__c : 'here');
        }else if(String.isNotBlank(availableInventoriesList.dealRecord.Token_Amount_Approval_Status__c ) && 
             availableInventoriesList.dealRecord.Token_Amount_Approval_Status__c .equalsIgnoreCase('Approved')){
        isError = true;
              isSuccess = false;
              errorPrefix = '';
              errorMessage = system.Label.Error_Unit_Modification_Not_Allowed;     
      }else{
          showScreen1 = true;
            showScreen2 = false; 
            showScreen3 = false;  
            showScreen4 = false;    
            if((String.isBlank(availableInventoriesList.dealRecord.Booking_Wizard_Level__c)) || 
               (String.isNotBlank(availableInventoriesList.dealRecord.Booking_Wizard_Level__c) && 
               !availableInventoriesList.dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 2') && 
               !availableInventoriesList.dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 3') && 
               !availableInventoriesList.dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 4') && 
               !availableInventoriesList.dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 5'))){
              availableInventoriesList.dealRecord.Booking_Wizard_Level__c = 'Level 1';  
            }
        }
      }catch(Exception ex){
          isError = true;
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();   
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to get inventories related to the available package.                 *
    * @Params      : Set<String>                                                                 *
    * @Return      : Map<String, List<Inventory__c>>                                             *
    **********************************************************************************************/
    public Map<String, List<Inventory__c>> getPackageRelatedInventories(Set<String> packageIdsSet){ 
      Map<String, List<Inventory__c>> packageRelatedInventoryMap = new Map<String, List<Inventory__c>>();
      for(Inventory__c thisInventory : [SELECT Id, Floor_Package_ID__c, Floor_Package_Type__c, List_Price_calc__c, Special_Price_calc__c   
                        FROM Inventory__c 
                        WHERE Floor_Package_ID__c IN: packageIdsSet AND 
                              Floor_Package_Type__c != null AND 
                              Status__c =: generalInventoryStatus AND 
                              List_Price_calc__c != null]){
        if(String.isNotBlank(thisInventory.Floor_Package_ID__c)){
          if(packageRelatedInventoryMap.containsKey(thisInventory.Floor_Package_ID__c)){
            packageRelatedInventoryMap.get(thisInventory.Floor_Package_ID__c).add(thisInventory);  
          }else{
            packageRelatedInventoryMap.put(thisInventory.Floor_Package_ID__c, new List<Inventory__c>{ thisInventory });  
          }  
        }
      }  
      system.debug('#### packageRelatedInventoryMap = '+packageRelatedInventoryMap);
      return packageRelatedInventoryMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to set portfolios component flag.                                    *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void createPortfolio(){
        Savepoint sp = Database.setSavepoint();
        init();
        Boolean isValid = true;
        Set<Id> selectedInventoryIdsSet = new Set<Id>();
        List<String> bookedInventoryList = new List<String>();
        List<UtilityWrapperManager.InventoryBuyerWrapper> selectedInventory = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
        Map<String, List<Inventory__c>> packageInventoryMap = new Map<String, List<Inventory__c>>();
        try{
          for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : availableInventoriesList.ibwList){
              if(thisInventory.isSelected){
                selectedInventoryIdsSet.add(thisInventory.selectedInventory.Id);
                if(String.isNotBlank(thisInventory.selectedInventory.Floor_Package_ID__c)){
              if(packageInventoryMap.containsKey(thisInventory.selectedInventory.Floor_Package_ID__c)){
                packageInventoryMap.get(thisInventory.selectedInventory.Floor_Package_ID__c).add(thisInventory.selectedInventory);  
              }else{
                packageInventoryMap.put(thisInventory.selectedInventory.Floor_Package_ID__c, new List<Inventory__c>{ thisInventory.selectedInventory });  
              }  
            }
              }
            }
            system.debug('#### selectedInventory = '+selectedInventoryIdsSet); 
            if(!selectedInventoryIdsSet.isEmpty()){
              /* Calling method to check the availability of inventories. */
        bookedInventoryList = checkInventoryAvailable(selectedInventoryIdsSet);
              if(String.isNotBlank(availableInventoriesList.dealRecord.Booking_Wizard_Level__c) && 
                 availableInventoriesList.dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 5')){
            isError = true;
                isSuccess = true;
                isSubmitted = true;
                errorPrefix = '';
                errorMessage = system.Label.Error_Deal_Submitted.replace('#DEAL_RECORD_ID#', '\'' + availableInventoriesList.dealRecord.Id + '\'').replace('#DEAL_ID#', String.isNotBlank(availableInventoriesList.dealRecord.Deal_ID__c) ? availableInventoriesList.dealRecord.Deal_ID__c : 'here');
          }else if(!bookedInventoryList.isEmpty()){
          isError = true;
          isSuccess = false;
          errorPrefix = '';
          String bookedUnitsString = '';
          for(String thisUnit : bookedInventoryList){
            bookedUnitsString = '<br/>'+thisUnit+bookedUnitsString;  
          }
          errorMessage = bookedInventoryList.size() > 1 ? 
            system.Label.Error_Unit_Booked_Multiple.replace('#BOOKED_UNIT_LIST#', bookedUnitsString) : 
            system.Label.Error_Unit_Booked_Single.replace('#BOOKED_UNIT_LIST#', bookedUnitsString);
        }else{
                  if(String.isNotBlank(availableInventoriesList.dealRecord.Agency__c)){
                    /* Calling method to validate the selected unit against the tagged agency. 
                       - Validation says, that the agency is allowed to sell only in site defined country. */
                    if(!selectedInventoryIdsSet.isEmpty()){
                      isValid = validateSelectedUnits(availableInventoriesList.dealRecord.Agency__c, selectedInventoryIdsSet);  
                    }
                    system.debug('#### isValid = '+isValid);
                    if(!isValid){
                      isError = true;
                      errorPrefix = '';
                      if(String.isNotBlank(agencyEligibleCountryString)){
                        errorMessage = system.Label.Error_Validate_Agency.replace('#COUNTRY_OF_SALE#', agencyEligibleCountryString);       
                      }else{
                        errorMessage = system.Label.Error_Agency_Not_Allowed_Anywhere;      
                      }
                    }
                  }
                  if(!packageInventoryMap.isEmpty()){
                    /* Calling method to get total number of units associated to a package. 
                       -  Validation says that the floor and package selection is only allowed for all or no units. 
                           individual or part selection is not allowed. */
            Map<String, List<Inventory__c>> packageRelatedInventoryMap = getPackageRelatedInventories(packageInventoryMap.keySet());
                    system.debug('#### packageRelatedInventoryMap = '+packageRelatedInventoryMap);
            system.debug('#### packageInventoryMap = '+packageInventoryMap);
                    for(String thisKey : packageInventoryMap.keySet()){
                      if(packageRelatedInventoryMap.containsKey(thisKey) && 
                         packageInventoryMap.get(thisKey).size() != packageRelatedInventoryMap.get(thisKey).size()){
                        isValid = false;  
                      }  
                    }  
                    if(!isValid){
                      isError = true;
                      errorPrefix = '';
                      errorMessage = system.Label.Error_Floor_Package_Validation;
                    }
                  }
                    
                  if(isValid){
                    showScreen1 = false;
                    showScreen2 = true; 
                    showScreen3 = false;  
                    showScreen4 = false;
                    if((String.isBlank(availableInventoriesList.dealRecord.Booking_Wizard_Level__c)) || 
                   (String.isNotBlank(availableInventoriesList.dealRecord.Booking_Wizard_Level__c) && 
                   !availableInventoriesList.dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 3') && 
                   !availableInventoriesList.dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 4') && 
                   !availableInventoriesList.dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 5'))){
                  availableInventoriesList.dealRecord.Booking_Wizard_Level__c = 'Level 2';  
                }
                    availableInventoriesList.dealRecord.recordTypeId = DamacUtility.getRecordTypeId('NSIBPM__Service_Request__c', 'Deal');
                    availableInventoriesList.dealRecord.NSIBPM__finalizeAmendmentFlg__c = true;
                    upsert availableInventoriesList.dealRecord;
                    /* Calling method to create deal team related to an agent and the logged in PC. */
                    Set<Id> teamMembersSet = new Set<Id>();
                        if(profileIds.isEmpty() || (!profileIds.isEmpty() && !profileIds.contains(UserInfo.getProfileId()))){
                      teamMembersSet.add(UserInfo.getUserId());
                        }
                    if(!teamMembersSet.isEmpty()){
                      /* Invoking method to create deal team. */
                        createDealTeam(availableInventoriesList.dealRecord, teamMembersSet);
                    }
                  }
              }
          }else{ 
                isError = true;
                isSuccess = false;
                errorMessage = system.Label.Error_Validate_Inventory;
            }
        }catch(Exception ex){
          isError = true;
          errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();
          if(errorMessage.containsIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){errorMessage = errorMessage.subStringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', '[');}  
            clearIds();
            Database.rollback(sp);    
        }
    }
    
    /*********************************************************************************************
    * @Description : Validate if already selected units are eligible for the selected agency.    *
    * @Params      : String, Set<Id>                                                             *
    * @Return      : Boolean                                                                     *
    **********************************************************************************************/
    public static Boolean validateSelectedUnits(String agencyId, Set<Id> selectedUnitsSet){
        Integer counter = 0;
        Boolean validate = false;
        Set<String> agencyEligibleCountryName = new Set<String>();
        Set<String> agencyEligibleCountry = new Set<String>();
        system.debug('#### agencyId = '+agencyId);
        system.debug('#### selectedUnitsSet = '+selectedUnitsSet);
        if(String.isNotBlank(agencyId) && !selectedUnitsSet.isEmpty()){
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
                    if(String.isNotBlank(thisAgentSite.Name)){
                      agencyEligibleCountryName.add(thisAgentSite.Name);  
                    }
                }   
            }
            for(String thisCountry : agencyEligibleCountryName){
              agencyEligibleCountryString = '<br/>'+ thisCountry + agencyEligibleCountryString;  
            }
            system.debug('#### agencyEligibleCountryString = '+agencyEligibleCountryString);
            system.debug('#### agencyEligibleCountry = '+agencyEligibleCountry);
            if(!agencyEligibleCountry.isEmpty() && !selectedUnitsSet.isEmpty()){
                for(Inventory__c thisInventory : [SELECT Id, Location_Code__c, Property_Country__c, Is_Assigned__c, Org_ID__c,
                                     Floor_Package_ID__c, Floor_Package_Type__c, List_Price_calc__c, Special_Price_calc__c
                                                  FROM Inventory__c 
                                                  WHERE Id IN: selectedUnitsSet]){
                    system.debug('#### Org Id = '+thisInventory.Org_ID__c);
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
    * @Description : Method to set payment plan component flag.                                  *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void selectPaymentPlan(){
       
        try{
          finalWrap = DroolWebService.createRequestData(availableInventoriesList);
          }
          catch(Exception Ex){
            errorMessage  = 'Drool Web Service Call Out Failed Due to No Response from Drool';
           }

        Savepoint sp = Database.setSavepoint();
        init();
        Set<Id> selectedInventoryIdsSet = new Set<Id>();
        List<String> bookedInventoryList = new List<String>();
        String dealId = apexpages.currentpage().getparameters().get('id');
        try{
          String message = PropertyBookingController.validateBuyerFields(availableInventoriesList.ibwList, true, true);
          if(String.isNotBlank(message) && message.equalsIgnoreCase('success')){
            /* Calling method to check the availability of inventories. */
            for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : availableInventoriesList.ibwList){
                system.debug('#### thisInventory = '+thisInventory);
                if(thisInventory.isSelected){
                  selectedInventoryIdsSet.add(thisInventory.selectedInventory.Id);
                }
              }
              if(!selectedInventoryIdsSet.isEmpty()){
          bookedInventoryList = checkInventoryAvailable(selectedInventoryIdsSet);
              }
              system.debug('#### bookedInventoryList = '+bookedInventoryList);
            if(String.isNotBlank(availableInventoriesList.dealRecord.Booking_Wizard_Level__c) && 
           availableInventoriesList.dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 5')){
            if(availableInventoriesList.dealRecord.NSIBPM__Steps_SR__r.isEmpty() && String.isNotBlank(dealId)){
              isError = true;
                  isSuccess = true;
                  isSubmitted = true;
                  errorPrefix = '';
                  //errorMessage = system.Label.Message_Buyer_Details_Saved.replace('#DEAL_RECORD_ID#', availableInventoriesList.dealRecord.Id).replace('#DEAL_ID#', String.isNotBlank(availableInventoriesList.dealRecord.Deal_ID__c) ? availableInventoriesList.dealRecord.Deal_ID__c : 'here');
                        errorMessage = system.Label.Message_Buyer_Details_Saved.replace('#DEAL_RECORD_ID#','\'' + availableInventoriesList.dealRecord.Id + '\'').replace('#DEAL_ID#', String.isNotBlank(availableInventoriesList.dealRecord.Deal_ID__c) ? availableInventoriesList.dealRecord.Deal_ID__c : 'here');
                        /* Saving record in salesforce. */
                  saveBooking(); 
            }else{
              isError = true;
                  isSuccess = true;
                  isSubmitted = true;
                  errorPrefix = '';
                  //errorMessage = system.Label.Error_Deal_Submitted.replace('#DEAL_RECORD_ID#', availableInventoriesList.dealRecord.Id).replace('#DEAL_ID#', String.isNotBlank(availableInventoriesList.dealRecord.Deal_ID__c) ? availableInventoriesList.dealRecord.Deal_ID__c : 'here');
                        errorMessage = system.Label.Error_Deal_Submitted.replace('#DEAL_RECORD_ID#', '\'' + availableInventoriesList.dealRecord.Id + '\'').replace('#DEAL_ID#', String.isNotBlank(availableInventoriesList.dealRecord.Deal_ID__c) ? availableInventoriesList.dealRecord.Deal_ID__c : 'here');
                        
                    }
          }else if(!bookedInventoryList.isEmpty()){
          isError = true;
          isSuccess = false;
          errorPrefix = '';
          String bookedUnitsString = '';
          for(String thisUnit : bookedInventoryList){
            bookedUnitsString = '<br/>'+thisUnit+bookedUnitsString;  
          }
          errorMessage = bookedInventoryList.size() > 1 ? 
            system.Label.Error_Unit_Booked_Multiple.replace('#BOOKED_UNIT_LIST#', bookedUnitsString) : 
            system.Label.Error_Unit_Booked_Single.replace('#BOOKED_UNIT_LIST#', bookedUnitsString);
        }else{
                if(availableInventoriesList.ibwList != null && availableInventoriesList.ibwList.size() > 0){
                  if(String.isNotBlank(mode) && mode.equalsIgnoreCase('draft')){
                    isError = true;
                    isSuccess = true;
                    errorPrefix = '';
                    errorMessage = system.Label.Error_Deal_Saved_As_Draft.replace('#DEAL_RECORD_ID#', '\'' + availableInventoriesList.dealRecord.Id + '\'').replace('#DEAL_ID#', String.isNotBlank(availableInventoriesList.dealRecord.Deal_ID__c) ? availableInventoriesList.dealRecord.Deal_ID__c : 'here');
                  }else{
                      showScreen1 = false;
                      showScreen2 = false; 
                      showScreen3 = true;  
                      showScreen4 = false; 
                      if((String.isBlank(availableInventoriesList.dealRecord.Booking_Wizard_Level__c)) || 
                     (String.isNotBlank(availableInventoriesList.dealRecord.Booking_Wizard_Level__c) && 
                     !availableInventoriesList.dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 5'))){
                    availableInventoriesList.dealRecord.Booking_Wizard_Level__c = 'Level 3';
                  }
                  }
                  /* Saving record in salesforce. */
                  saveBooking();
                }
            }
          }else{
              isError = true;
              isSuccess = false;
              errorPrefix = '';
              errorMessage = message;  
            }
        }catch(Exception ex){
          isError = true;
          errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();
          if(errorMessage.containsIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){errorMessage = errorMessage.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', '[');}
            clearIds();
            Database.rollback(sp);  
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to set payment method component flag and submit for approval.        *
    *           - If total selling price is less than 15 million:                           *
    *             No approval required, but validate that the requested price              *
    *             can't be less than special price.                                        *
    *         - If total selling price is more than 15 million:                           *
    *                Requested Price is >= Special Price : No approval                        *
    *             Requested Price between Special Price and CM price : DOS-HOS-GM          *
    *             Requested Price > CM :  DOS-HOS-GM-CM                                    *
    *         - Payment Plan modification goes for DOS-HOS-GM                             *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public pageReference selectPaymentMethod(){
        Savepoint sp = Database.setSavepoint();
        PageReference page;
        init();
        String level = 'Level 1';
        Decimal totalSellingPrice = 0.0;
        Set<Id> selectedInventoryIdsSet = new Set<Id>();
        List<String> bookedInventoryList = new List<String>();
        Map<String ,Option__c> OptionList =  new Map<String ,Option__c> ();
        Set<Id> BookingUId= new Set<Id>();
        try{
          
          system.debug('#### selecting payment method');
          /* Calling method to check the availability of inventories. */
          for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : availableInventoriesList.ibwList){
               BookingUId.add(thisInventory.bookingUnit.Id);
              if(thisInventory.isSelected){
                selectedInventoryIdsSet.add(thisInventory.selectedInventory.Id);
              }
            }
           
            if(!BookingUId.isEmpty()){
                
                OptionList  =  DroolWebService.getOptionDetails(BookingUId);
             }
             
            
            
             system.debug('##### OptionList=== '+OptionList);
             
            if(!selectedInventoryIdsSet.isEmpty()){
              bookedInventoryList = checkInventoryAvailable(selectedInventoryIdsSet);
            }
            system.debug('#### bookedInventoryList = '+bookedInventoryList);
          if(String.isNotBlank(availableInventoriesList.dealRecord.Booking_Wizard_Level__c) && 
         availableInventoriesList.dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 5')){
          isError = true;
              isSuccess = true;
              isSubmitted = true;
              errorPrefix = '';
              errorMessage = system.Label.Error_Deal_Submitted.replace('#DEAL_RECORD_ID#', '\'' + availableInventoriesList.dealRecord.Id + '\'').replace('#DEAL_ID#', String.isNotBlank(availableInventoriesList.dealRecord.Deal_ID__c) ? availableInventoriesList.dealRecord.Deal_ID__c : 'here');
        }else if(!bookedInventoryList.isEmpty()){
        isError = true;
        isSuccess = false;
        errorPrefix = '';
        String bookedUnitsString = '';
        for(String thisUnit : bookedInventoryList){
          bookedUnitsString = '<br/>'+thisUnit+bookedUnitsString;  
        }
        errorMessage = bookedInventoryList.size() > 1 ? 
          system.Label.Error_Unit_Booked_Multiple.replace('#BOOKED_UNIT_LIST#', bookedUnitsString) : 
          system.Label.Error_Unit_Booked_Single.replace('#BOOKED_UNIT_LIST#', bookedUnitsString);
      }else{ 
            if(availableInventoriesList.ibwList != null && availableInventoriesList.ibwList.size() > 0){
                  for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : availableInventoriesList.ibwList){
                      if(thisInventory.isSelected && thisInventory.selectedInventory.Selling_Price__c != null){
                        totalSellingPrice += thisInventory.selectedInventory.Selling_Price__c;     
                      }
                  }
            }
            system.debug('#### totalSellingPrice = '+totalSellingPrice);
              if(availableInventoriesList.ibwList != null && availableInventoriesList.ibwList.size() > 0){
                  for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : availableInventoriesList.ibwList){
                      if(thisInventory.isSelected){
                          if(thisInventory.inventoryPaymentPlanMap != null && !thisInventory.inventoryPaymentPlanMap.isEmpty()){ 
                            for(Payment_Plan__c thisPaymentPlan : thisInventory.inventoryPaymentPlanMap.values()){
                  for(Payment_Terms__c thisPaymentTerm : thisPaymentPlan.Payment_Terms__r){
                    if(String.isNotBlank(thisPaymentTerm.Modified_Percent_Value__c) && 
                       String.isNotBlank(thisPaymentTerm.Percent_Value__c) &&
                       thisPaymentTerm.Modified_Percent_Value__c != thisPaymentTerm.Percent_Value__c){
                      level = 'Level 3';
                      break;  
                    }  
                  }    
                }   
                              Decimal minimumAmount = Decimal.valueOf(Label.Mininum_Token_Amount);
                              Decimal intermediateAmount = Decimal.valueOf(Label.Intermediate_Token_Amount);
                              Decimal maximumAmount = Decimal.valueOf(Label.Maximum_Token_Amount);
                              system.debug('#### Selling Price = '+thisInventory.selectedInventory.List_Price_calc__c);
                              system.debug('#### Special Price = '+thisInventory.selectedInventory.Special_Price_calc__c);
                              system.debug('#### Requested Token Amount = '+thisInventory.requestedTokenAmount);
                              for(Option__c Op : OptionList.values()){
                              system.debug('#### CM Price Option= '+Op.CM_Price_Per_Sqft__c );
                              if(totalSellingPrice > 15000000 && thisInventory.requestedPrice != null &&
                                 thisInventory.requestedPrice < Op.CM_Price_Per_Sqft__c){
                                level = 'Level 4';    
                                break; 
                              }else if(totalSellingPrice > 15000000 && thisInventory.requestedPrice != null &&
                                   thisInventory.requestedPrice >= Op.CM_Price_Per_Sqft__c && 
                                        thisInventory.requestedPrice < thisInventory.selectedInventory.Special_Price_calc__c){
                                level = level != 'Level 4' ? 'Level 3' : level;      
                              }else if(thisInventory.requestedTokenAmount != null &&  
                                      thisInventory.requestedTokenAmount >= minimumAmount && 
                                      thisInventory.requestedTokenAmount <= intermediateAmount){
                  level = level != 'Level 4' ? 'Level 3' : level;    
                }else if(thisInventory.requestedTokenAmount != null && 
                         thisInventory.requestedTokenAmount > intermediateAmount && 
                         thisInventory.requestedTokenAmount < maximumAmount){
                  level = level != 'Level 4' && level != 'Level 3' ? 'Level 2' : level;    
                }
                          }}else{
                              isError = true;
                              errorMessage = system.Label.Error_Payment_Plan_Missing;  
                          }
                      }
                  }
          if(availableInventoriesList != null && availableInventoriesList.dealRecord != null && 
             availableInventoriesList.dealRecord.Id != null && !Approval.isLocked(availableInventoriesList.dealRecord.Id)){
            /* Saving record in salesforce, putting save here as payment plan needs to be tagged before submitting it for approval. */
            saveBooking();
            if(String.isNotBlank(mode) && mode.equalsIgnoreCase('draft')){
                    isError = true;
                    isSuccess = true;
                    errorPrefix = '';
                    errorMessage = system.Label.Error_Deal_Saved_As_Draft.replace('#DEAL_RECORD_ID#', '\'' + availableInventoriesList.dealRecord.Id + '\'').replace('#DEAL_ID#', String.isNotBlank(availableInventoriesList.dealRecord.Deal_ID__c) ? availableInventoriesList.dealRecord.Deal_ID__c : 'here');
                  }else{
              /* Calling method to submit the SR for approval proces.*/
              errorMessage = submitApprovalProcess(availableInventoriesList.dealRecord.Id, level); 
              if(String.isNotBlank(errorMessage) && !errorMessage.equalsIgnoreCase('N/A')){
                        isError = true;
                        page = new PageReference('/'+availableInventoriesList.dealRecord.Id);
                      }else{
                        isError = false;
                          showScreen1 = false;
                          showScreen2 = false; 
                          showScreen3 = false; 
                          showScreen4 = true;
                          if((String.isBlank(availableInventoriesList.dealRecord.Booking_Wizard_Level__c)) || 
                       (String.isNotBlank(availableInventoriesList.dealRecord.Booking_Wizard_Level__c) && 
                       !availableInventoriesList.dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 5'))){
                      availableInventoriesList.dealRecord.Booking_Wizard_Level__c = 'Level 4';
                      update availableInventoriesList.dealRecord;
                    }
                      }   
            }
          }else{
            isError = true;
            errorMessage = system.Label.Error_Wait_for_Approval;
          }
              }
          }
        }catch(Exception ex){
          isError = true;
          errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();
          if(errorMessage.containsIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){errorMessage = errorMessage.subStringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', '[');}  
            clearIds();
            Database.rollback(sp);     
        }
        return page;
    }
    
    /*********************************************************************************************
    * @Description : Method to submit booking records.                                           *
    *         - Time out duration based on value configured in custom metadata.           *
    *         - For payment method other than online payment to go for approval.          *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    * @Change Logs : Version 1.1                                                                 *
    *********************************************************************************************/
    public void submitBooking(){
      Savepoint sp = Database.setSavepoint();
        init();
        String selectedUnitsString = '';
      Integer duration = 0;
      Boolean submitForApproval = false;
      PageReference page;
      Set<Id> selectedInventoryIdsSet = new Set<Id>();
      List<String> bookedInventoryList = new List<String>();
        Map<Id, Inventory__c> updateUnitStatusListMap = new Map<Id, Inventory__c>();
        Map<String, Integer> paymentMethodDurationMap = new Map<String, Integer>();
        Map<String, Boolean> paymentMethodPopRequiredMap = new Map<String, Boolean>();
        Map<String, Boolean> paymentMethodFinanceApprovalRequiredMap = new Map<String, Boolean>();
        try{
          /* Calling method to check the availability of inventories. */
          for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : availableInventoriesList.ibwList){
              if(thisInventory.isSelected){
                selectedInventoryIdsSet.add(thisInventory.selectedInventory.Id);
              }
            }
            /* Calling method to get payment method and duration mapping. */
      for(Payment_Method_Mapping__mdt thisMapping : [SELECT MasterLabel, Payment_Method_Type__c, Time_Out_Duration__c, 
                                  Proof_of_Payment_Required__c, Finance_Approval_Required__c 
                               FROM Payment_Method_Mapping__mdt]) {
        paymentMethodDurationMap.put(thisMapping.Payment_Method_Type__c, Integer.valueOf(thisMapping.Time_Out_Duration__c));
        paymentMethodPopRequiredMap.put(thisMapping.Payment_Method_Type__c, thisMapping.Proof_of_Payment_Required__c);
        paymentMethodFinanceApprovalRequiredMap.put(thisMapping.Payment_Method_Type__c, thisMapping.Finance_Approval_Required__c);
      }
            if(!selectedInventoryIdsSet.isEmpty()){
        bookedInventoryList = checkInventoryAvailable(selectedInventoryIdsSet);
            }
            system.debug('#### bookedInventoryList = '+bookedInventoryList);
            if(String.isNotBlank(availableInventoriesList.dealRecord.Booking_Wizard_Level__c) && 
         availableInventoriesList.dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 5')){
          isError = true;
              isSuccess = true;
              isSubmitted = true;
              errorPrefix = '';
              errorMessage = system.Label.Error_Deal_Submitted.replace('#DEAL_RECORD_ID#', '\'' + availableInventoriesList.dealRecord.Id + '\'').replace('#DEAL_ID#', String.isNotBlank(availableInventoriesList.dealRecord.Deal_ID__c) ? availableInventoriesList.dealRecord.Deal_ID__c : 'here');
        }else if(!bookedInventoryList.isEmpty()){
            isError = true;
            isSuccess = false;
            errorPrefix = '';
            String bookedUnitsString = '';
            for(String thisUnit : bookedInventoryList){
              bookedUnitsString = '<br/>'+thisUnit+bookedUnitsString;  
            }
            errorMessage = bookedInventoryList.size() > 1 ? 
          system.Label.Error_Unit_Booked_Multiple.replace('#BOOKED_UNIT_LIST#', bookedUnitsString) : 
          system.Label.Error_Unit_Booked_Single.replace('#BOOKED_UNIT_LIST#', bookedUnitsString);
        }else{ 
              /* Calculating time out duration. */
              if(availableInventoriesList.ibwList != null){
                  for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : availableInventoriesList.ibwList){
                    system.debug('#### payment method = '+thisInventory.bookingUnit.Payment_Method__c);
                      if(thisInventory.isSelected && String.isNotBlank(thisInventory.bookingUnit.Payment_Method__c)){
                        if(paymentMethodDurationMap.containsKey(thisInventory.bookingUnit.Payment_Method__c)){
                          duration = duration < paymentMethodDurationMap.get(thisInventory.bookingUnit.Payment_Method__c) ? 
                                  paymentMethodDurationMap.get(thisInventory.bookingUnit.Payment_Method__c) : duration;      
                        }else{
                          duration = Integer.valueOf(system.label.Inventory_Block_Duration);  
                        }  
                        if(paymentMethodFinanceApprovalRequiredMap.containsKey(thisInventory.bookingUnit.Payment_Method__c) && 
                           paymentMethodFinanceApprovalRequiredMap.get(thisInventory.bookingUnit.Payment_Method__c)){
                          submitForApproval = true;  
                        }
                      }
                      system.debug('##### paymentMethodPopRequiredMap = '+paymentMethodPopRequiredMap);
                      system.debug('##### selected payment plan = '+thisInventory.bookingUnit.Payment_Method__c);
                      system.debug('##### proof of payment submitted = '+thisInventory.bookingUnit.Proof_of_Payment_Submitted__c);
            if(String.isNotBlank(thisInventory.bookingUnit.Payment_Method__c) && 
               paymentMethodPopRequiredMap.containsKey(thisInventory.bookingUnit.Payment_Method__c) && 
               paymentMethodPopRequiredMap.get(thisInventory.bookingUnit.Payment_Method__c) && 
               !thisInventory.bookingUnit.Proof_of_Payment_Submitted__c){
                        isError = true;
                  isSuccess = false;
                  errorPrefix = '';
                    errorMessage = system.Label.Error_Check_POP.replace('#UNIT#', thisInventory.selectedInventory.Unit__c);  
                    break;
                      }   
                  }   
              }
              if(!isError){
                system.debug('#### Booking Inventory List = '+availableInventoriesList.ibwList);
                /* Booking the unit in salesforce. */
                if(availableInventoriesList.ibwList != null){
                    for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : availableInventoriesList.ibwList){
                        if(thisInventory.isSelected){
                            thisInventory.selectedInventory.Status__c = 'Booked';
                            thisInventory.selectedInventory.OwnerId = UserInfo.getUserId();
                            updateUnitStatusListMap.put(thisInventory.selectedInventory.Id, thisInventory.selectedInventory); 
                            selectedUnitsString = thisInventory.selectedInventory.Unit__c+','+selectedUnitsString; 
                        }   
                    }   
                    if(!updateUnitStatusListMap.isEmpty()){
                        update updateUnitStatusListMap.values();    
                    }
                    system.debug('#### Booking Inventory = '+updateUnitStatusListMap);
                }
                
                /*Calling webservice method to intiate Registration, calling inside a look because it needs to be done per booking. */
                for(Booking__c thisBooking : [SELECT Id FROM Booking__c WHERE Deal_SR__c =: availableInventoriesList.dealRecord.Id]){
                  //AsyncReceiptWebservice.sendRegistrationRequest(new List<Id>{thisBookingId});
                    system.enqueueJob(new AsyncReceiptWebservice (new List<Id>{thisBooking.Id},'Registration Creation'));
                }
                if(String.isNotBlank(selectedUnitsString) && selectedUnitsString.endsWith(',')){
                  selectedUnitsString = selectedUnitsString.removeEnd(',');    
                }
                availableInventoriesList.dealRecord.Booking_Wizard_Level__c = 'Level 5';
                availableInventoriesList.dealRecord.List_of_Units__c = selectedUnitsString;
                //availableInventoriesList.dealRecord.Is_Submitted_For_Approval__c = true;
                  availableInventoriesList.dealRecord.Token_Deposit_Due_Date_Time__c = system.now().addHours(duration);
                  /* Saving record in salesforce. */
                saveBooking();
                  isError = true;
                  isSuccess = true;
                  isSubmitted = true;
                  errorPrefix = '';
                  errorMessage = system.Label.Message_Deal_Submission.replace('#DURATION#', String.valueOf(duration)).replace('#DEAL_RECORD_ID#', '\'' + availableInventoriesList.dealRecord.Id + '\'').replace('#DEAL_ID#', String.isNotBlank(availableInventoriesList.dealRecord.Deal_ID__c) ? availableInventoriesList.dealRecord.Deal_ID__c : 'here');
                page = new PageReference('/'+availableInventoriesList.dealRecord.Id);
                if(!Approval.isLocked(availableInventoriesList.dealRecord.Id) && submitForApproval){
                  /*Submitting approval process. */
                Approval.ProcessSubmitRequest financeApprovalProcess = new Approval.ProcessSubmitRequest();
                financeApprovalProcess.setComments('Submitting request for approval.');
                financeApprovalProcess.setObjectId(availableInventoriesList.dealRecord.Id);
                financeApprovalProcess.setSubmitterId(UserInfo.getUserId());
                financeApprovalProcess.setProcessDefinitionNameOrId('Finance_Approval');
                Approval.ProcessResult result = Approval.process(financeApprovalProcess);
                }
              }
            }
        }catch(Exception ex){
            isError = true;
          errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();
          if(errorMessage.containsIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){errorMessage = errorMessage.subStringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', '[');}  
            clearIds();
            Database.rollback(sp);     
        } 
    }
    
    /*********************************************************************************************
    * @Description : Method to save records.                                                     *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    private void saveBooking(){ 
      Set<String> uniqueKeySet = new Set<String>();
        Map<String, Booking__c> bookingUniqueKeyMap = new Map<String, Booking__c>();
        Map<String, Map<String, Buyer__c>> updateBuyerUniqueMap = new Map<String, Map<String, Buyer__c>>();
        Map<String, List<Buyer__c>> newBuyerUniqueMap = new Map<String, List<Buyer__c>>();
        Map<String, List<Booking_Unit__c>> unitUniqueMap = new Map<String, List<Booking_Unit__c>>();
        Map<String, Payment_Plan__c> inventoryPaymentPlanMap = new Map<String, Payment_Plan__c>();
        Map<String, List<Payment_Terms__c>> inventoryPaymentTermsMap = new Map<String, List<Payment_Terms__c>>();
        /* Creating deal/service request. */
        system.debug('#### availableInventoriesList = '+availableInventoriesList);
        if(availableInventoriesList != null && String.isNotBlank(availableInventoriesList.dealRecord.Delivery_Mode__c)){
            availableInventoriesList.dealRecord.recordTypeId = DamacUtility.getRecordTypeId('NSIBPM__Service_Request__c', 'Deal');
            TriggerFactoryCls.setBYPASS_UPDATE_TRIGGER();
            upsert availableInventoriesList.dealRecord;
            TriggerFactoryCls.resetBYPASS_UPDATE_TRIGGER();
            system.debug('#### Here');
            if(availableInventoriesList.dealRecord.Id != null){ 
                /* Calling method to create deal team. */
                Set<Id> teamMembersSet = new Set<Id>();
                if(profileIds.isEmpty() || (!profileIds.isEmpty() && !profileIds.contains(UserInfo.getProfileId()))){
                teamMembersSet.add(UserInfo.getUserId());
                }
                if(!teamMembersSet.isEmpty()){
                    createDealTeam(availableInventoriesList.dealRecord, teamMembersSet);
                }
                system.debug('#### Main list = '+availableInventoriesList.ibwList);
                if(availableInventoriesList.ibwList != null){
                    for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : availableInventoriesList.ibwList){
                        if(thisInventory.isSelected && thisInventory.selectedInventory.Id != null){
                          system.debug('#### selected inventory = '+thisInventory.selectedInventory);
                            if(thisInventory.jointBuyerList != null){
                                String uniqueKey = availableInventoriesList.dealRecord.Id;
                                /* Creating map of units related to the booking unique key. */
                                Booking_Unit__c buObject = thisInventory.bookingUnit;
                                buObject.Inventory__c = thisInventory.selectedInventory.Id;
                                buObject.Unit_Selling_Price__c = thisInventory.selectedInventory.List_Price_calc__c; 
                                buObject.Unit_s_Current_Status__c = thisInventory.selectedInventory.Status__c;
                                buObject.Property_Country__c = thisInventory.selectedInventory.Property_Country__c;
                                buObject.CurrencyIsoCode = thisInventory.selectedInventory.CurrencyIsoCode;
                                buObject.Requested_Price__c = thisInventory.requestedPrice; 
                                buObject.Requested_Token_Amount__c = thisInventory.requestedTokenAmount;
                                //buObject.Payment_Method__c = thisInventory.selectedPaymentMethod;
                                //buObject.Online_Payment_Party__c = thisInventory.onlinePaymentParty;
                                //buObject.No_of_parking__c = thisInventory.numberOfParking;
                                if(String.isNotBlank(thisInventory.selectedPromotion)){
                                   // buObject.Related_Promotion__c = thisInventory.selectedPromotion;
                                }
                                Map<String, Buyer__c> thisInventoryAssociatedBuyer = new Map<String, Buyer__c>();
                                for(Buyer__c thisBuyer : thisInventory.jointBuyerList){
                                  system.debug('#### thisBuyer = '+thisBuyer); 
                                  if(String.isNotBlank(thisBuyer.CR_Number__c)){
                                    if(!uniqueKey.containsIgnoreCase(thisBuyer.CR_Number__c)){
                                      uniqueKey = thisBuyer.CR_Number__c +' - '+ uniqueKey;  
                                    }
                                  }else if(String.isNotBlank(thisBuyer.Passport_Number__c)){
                                    if(!uniqueKey.containsIgnoreCase(thisBuyer.Passport_Number__c)){
                                      uniqueKey = thisBuyer.Passport_Number__c +' - '+ uniqueKey;    
                                    }
                                  }
                                  /* Updating primary buyers details on the booking unit record. */
                                    if(thisBuyer.Primary_Buyer__c){
                                        buObject.Primary_Buyer_s_Email__c = thisBuyer.Email__c; 
                                        buObject.Primary_Buyer_s_Name__c = thisBuyer.First_Name__c != null ? thisBuyer.First_Name__c : thisBuyer.Last_Name__c;
                                      buObject.Primary_Buyer_Country__c = thisBuyer.Country__c;
                                      buObject.Primary_Buyer_s_Nationality__c = thisBuyer.Nationality__c;
                                    }
                                    system.debug('#### Is the structure ready = '+thisInventory.bookingUnit.booking__c);
                                    /* If update is being performed, identified it by checking if the booking lookup is populated on the booking unit or not. */
                                    if(String.isNotBlank(thisInventory.bookingUnit.booking__c)){
                                      /* Creating map of buyers for updating or new buyer is being added to the existing booking. */
                                      if(String.isNotBlank(thisBuyer.CR_Number__c)){
                                      if(!thisInventoryAssociatedBuyer.containsKey(thisBuyer.CR_Number__c)){
                                        thisInventoryAssociatedBuyer.put(thisBuyer.CR_Number__c, thisBuyer);  
                                      }
                                    }else if(String.isNotBlank(thisBuyer.Passport_Number__c)){
                                        if(!thisInventoryAssociatedBuyer.containsKey(thisBuyer.Passport_Number__c) ){
                                          thisInventoryAssociatedBuyer.put(thisBuyer.Passport_Number__c, thisBuyer);  
                                        }
                                    }
                                    
                                    /* Added to prevent duplicate overriding of details of the very first record. */
                                    if(!updateBuyerUniqueMap.containsKey(thisInventory.bookingUnit.booking__c)){
                                      updateBuyerUniqueMap.put(thisInventory.bookingUnit.booking__c, thisInventoryAssociatedBuyer);  
                                    }
                                    }else{
                                      /* Creating map of buyers related to the booking unique key. */
                                    newBuyerUniqueMap.put(uniqueKey, new List<Buyer__c>(thisInventory.jointBuyerList));  
                                    // splitting the above in the short form will create issue, as only one buyer will get inserted.
                                    }
                                }
                                uniqueKeySet.add(uniqueKey);
                                /* Creating map of unit related to the booking unique key. */  
                                if(unitUniqueMap.containsKey(uniqueKey)){
                                    unitUniqueMap.get(uniqueKey).add(buObject); 
                                }else{
                                    unitUniqueMap.put(uniqueKey, new List<Booking_Unit__c>{buObject});  
                                }
                                /* Creating map of payment plan related to inventory Id. 
                                   Creating map of payment terms related to inventory Id. */
                                for(String thisKey : thisInventory.inventoryPaymentPlanMap.keySet()){ 
                                    inventoryPaymentPlanMap.put(thisKey, thisInventory.inventoryPaymentPlanMap.get(thisKey));
                                    inventoryPaymentTermsMap.put(thisKey, new List<Payment_Terms__c>(thisInventory.inventoryPaymentPlanMap.get(thisKey).Payment_Terms__r));
                                }
                                system.debug('#### inventoryPaymentPlanMap = '+inventoryPaymentPlanMap);
                                system.debug('#### inventoryPaymentTermsMap = '+inventoryPaymentTermsMap);
                            }
                            
                        }
                    }
                    /* Calling method to create booking related to the deal. */
                    if(!newBuyerUniqueMap.isEmpty()){
                       bookingUniqueKeyMap.putAll(createBookingRecords(availableInventoriesList.dealRecord, uniqueKeySet));
                    }
                    /* Calling method to update associated booking record in case a new buyer is added. */
                    if(!updateBuyerUniqueMap.isEmpty()){
                      bookingUniqueKeyMap.putAll(updateBookingRecords(availableInventoriesList.dealRecord, updateBuyerUniqueMap));    
                    }
                    system.debug('#### Dynamic structure created by this time.');
                    system.debug('#### Master Unique Key Set = '+uniqueKeySet);
                    system.debug('#### New Buyer Unique Map = '+newBuyerUniqueMap);
                    system.debug('#### Update Buyer Unique Map = '+updateBuyerUniqueMap);
                    system.debug('#### Booking Unique Key Map = '+bookingUniqueKeyMap);
                    system.debug('#### Unit Unique Map = '+unitUniqueMap);
                  /* Calling method to create booking unit details. */
                    Map<String, String> inventoryBookingUnitMap = createBookingUnitRecords(bookingUniqueKeyMap, unitUniqueMap);
                    /* Calling method to create / update buyer details. */
                    // Create
                    if(!newBuyerUniqueMap.isEmpty()){
            createBuyerRecords(bookingUniqueKeyMap, uniqueKeySet, newBuyerUniqueMap);                      
                    }
                    // Update
                    if(!updateBuyerUniqueMap.isEmpty()){
                      updateBuyerRecords(bookingUniqueKeyMap, updateBuyerUniqueMap);            
                    }
                    if(!inventoryBookingUnitMap.isEmpty()){
                        /* Calling method to create payment plans. */
                        Map<String, String> bookingUnitInventoryMap = new Map<String, String>();
                        for(String thisKey : inventoryBookingUnitMap.keySet()){
                            bookingUnitInventoryMap.put(inventoryBookingUnitMap.get(thisKey), thisKey); 
                        }
                        system.debug('#### bookingUnitInventoryMap = '+bookingUnitInventoryMap);
                        Map<String, String> insertedPaymentPlanMap = createPaymentPlans(bookingUnitInventoryMap, inventoryPaymentPlanMap, inventoryBookingUnitMap);
                        if(!insertedPaymentPlanMap.isEmpty()){
                            /* Calling method to create payment terms. */   
                            createPaymentTerms(insertedPaymentPlanMap, inventoryPaymentTermsMap);
                        }
                    }
                }
            }
            system.debug('#### mode = '+mode);
            if(String.isNotBlank(mode) && mode.equalsIgnoreCase('draft')){
            isError = true;
              isSuccess = true;
              errorPrefix = '';
              errorMessage = system.Label.Error_Deal_Saved_As_Draft.replace('#DEAL_RECORD_ID#', '\'' + availableInventoriesList.dealRecord.Id + '\'').replace('#DEAL_ID#', String.isNotBlank(availableInventoriesList.dealRecord.Deal_ID__c) ? availableInventoriesList.dealRecord.Deal_ID__c : 'here');
          }
          if(String.isNotBlank(availableInventoriesList.dealRecord.Id)){
        /* Calling method to pre-populate deal data.*/
        prePopulateData(availableInventoriesList.dealRecord.Id);  
      }
        }else{
          errorMessage = system.Label.Error_Validate_SPA;
        }
    }
  
  /*********************************************************************************************
    * @Description : Method to auto submit approval process.                                     *
    * @Params      : String, String                                                              *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    private String submitApprovalProcess(String dealId, String approvalLevel){
      system.debug('#### dealId = '+dealId);
      system.debug('#### approvalLevel = '+approvalLevel);
      String message = 'N/A';
      if(String.isNotBlank(dealId) && String.isNotBlank(approvalLevel) && !approvalLevel.equalsIgnoreCase('Level 1')){
        availableInventoriesList.dealRecord = getSrDetails(availableInventoriesList.dealRecord.Id);
        if(!Approval.isLocked(dealId) && 
          (String.isBlank(availableInventoriesList.dealRecord.Token_Amount_Approval_Status__c) ||
          (String.isNotBlank(availableInventoriesList.dealRecord.Token_Amount_Approval_Status__c) && 
               !availableInventoriesList.dealRecord.Token_Amount_Approval_Status__c.equalsIgnoreCase('Approved')))){
          /*Updating the level of approval required. */
          availableInventoriesList.dealRecord.Approval_Level_Required__c = approvalLevel;
          availableInventoriesList.dealRecord.Is_Submitted_For_Approval__c = true;
          update availableInventoriesList.dealRecord;
          
          /*Submitting approval process. */
            Approval.ProcessSubmitRequest tokenApprovalProcess = new Approval.ProcessSubmitRequest();
            tokenApprovalProcess.setComments('Submitting request for approval.');
            tokenApprovalProcess.setObjectId(dealId);
            tokenApprovalProcess.setSubmitterId(UserInfo.getUserId());
            tokenApprovalProcess.setProcessDefinitionNameOrId('Token_Approval');
            Approval.ProcessResult result = Approval.process(tokenApprovalProcess);
            isError = true;
                isSuccess = true;
                errorPrefix = '';
            message = 'Deal has been submitted for approval. Please wait for the approval before proceeding for payment.';
        }else if(Approval.isLocked(dealId) && String.isNotBlank(availableInventoriesList.dealRecord.Token_Amount_Approval_Status__c) && 
                !availableInventoriesList.dealRecord.Token_Amount_Approval_Status__c.equalsIgnoreCase('Approved')){
          isError = true;
                isSuccess = true;
                errorPrefix = '';
          message = 'Deal is already submitted for approval. Please wait for the approval before proceeding for payment';
        }else{
          message = 'N/A';
        }
      }
      return message;
    }
    
    /*********************************************************************************************
    * @Description : Method to clear populated Id's in case of rollback.                         *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    private void clearIds(){
        if(availableInventoriesList != null && availableInventoriesList.ibwList != null){
            for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : availableInventoriesList.ibwList){
                if(thisInventory.isSelected){
                    if(thisInventory.jointBuyerList != null){
                        for(Buyer__c thisBuyer : thisInventory.jointBuyerList){
                            thisBuyer.Id = null;
                            thisBuyer.Booking__c = null;
                            thisBuyer.Inquiry__c = null;
                        }
                    }
                    thisInventory.bookingUnit = new Booking_Unit__c();
                }
            }   
        }   
    }
    
    /*********************************************************************************************
    * @Description : Method to get active campaign related to the inventory.                     *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<Id, Id>                                                                 *
    *********************************************************************************************/
    public Map<Id, Id> getCampaignRelatedBookingUnit(Set<Id> inventoryIdsSet){
    Map<Id, Id> inventoryCampaignMap = new Map<Id, Id>();
    for(Campaign_Inventory__c thisCampaignInventory : [SELECT Id, Campaign__c, Inventory__c 
                               FROM Campaign_Inventory__c 
                               WHERE Inventory__c IN: inventoryIdsSet AND 
                                    Start_Date__c <= TODAY AND 
                                                             End_Date__c >= TODAY 
                                                       ORDER BY LastModifiedDate ASC LIMIT : LIMITS.getLimitQueryRows()]){
         if(thisCampaignInventory.Inventory__c != null){
        inventoryCampaignMap.put(thisCampaignInventory.Inventory__c, thisCampaignInventory.Campaign__c);
         }
    }
    return inventoryCampaignMap;
  }
    
    /*********************************************************************************************
    * @Description : Method to create deal teams.                                                *
    * @Params      : NSIBPM__Service_Request__c, Set<Id>                                         *
    * @Return      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    private void createDealTeam(NSIBPM__Service_Request__c dealRecord, Set<Id> teamMemberIdSet){
        Map<String, Deal_Team__c> insertDealTeamMap = new Map<String, Deal_Team__c>();
        for(Id thisTeamMember : teamMemberIdSet){
            Deal_Team__c dtRecord = new Deal_Team__c();
            dtRecord.Associated_Deal__c = dealRecord.Id;
            dtRecord.Associated_PC__c = thisTeamMember;
            dtRecord.Status__c = 'Active';
            dtRecord.Unique_Key__c = dealRecord.Id + ' - ' + thisTeamMember;
            insertDealTeamMap.put(dtRecord.Unique_Key__c, dtRecord);        
        }   
        if(!insertDealTeamMap.isEmpty()){
            upsert insertDealTeamMap.values() Unique_Key__c; 
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to create inquiries.                                                 *
    * @Params      : List<Buyer__c>                                                              *
    * @Return      : Map<String, String>                                                         *
    *********************************************************************************************/
    private Map<String, String> createInquiry(List<Buyer__c> buyerList){
      Id inquiryRecordTypeId = DamacUtility.getRecordTypeId('Inquiry__c', 'Inquiry');
      List<Inquiry__c> insertInquiryList = new List<Inquiry__c>();
      Map<Id, Inquiry__c> updateExistingInquiryList = new Map<Id, Inquiry__c>();
      Map<Id, Inquiry__c> buyerInquiryMap = new Map<Id, Inquiry__c>();
      Map<String, String> passportInquiryMap = new Map<String, String>();
      for(Buyer__c thisBuyer : buyerList){
        system.debug('#### what is the buyer = '+thisBuyer);
        if(String.isBlank(thisBuyer.Account__c)){
          Inquiry__c inquiryRecord = new Inquiry__c();
          inquiryRecord.By_Pass_Validation__c = true;
          inquiryRecord.Party_ID__c = thisBuyer.Party_ID__c;
          if(String.isNotBlank(thisBuyer.Agency__c)){
            inquiryRecord.Agency_Name__c = thisBuyer.Agency__c;
          }
          if(String.isNotBlank(thisBuyer.Agent__c)){
            inquiryRecord.Agent_Name__c = thisBuyer.Agent__c;   
          }
          inquiryRecord.Title__c = thisBuyer.Title__c;
          inquiryRecord.Title_Arabic__c = thisBuyer.Title_Arabic__c;
          inquiryRecord.First_Name__c = thisBuyer.First_Name__c;
          inquiryRecord.First_Name_Arabic__c = thisBuyer.First_Name_Arabic__c;
          inquiryRecord.Last_Name__c = thisBuyer.Last_Name__c;
          inquiryRecord.Last_Name_Arabic__c = thisBuyer.Last_Name_Arabic__c;
        inquiryRecord.Date_of_Birth__c = Date.parse(thisBuyer.Date_of_Birth__c);
        inquiryRecord.Nationality__c = thisBuyer.Nationality__c;
        inquiryRecord.Nationality_Arabic__c = thisBuyer.Nationality_Arabic__c;
        inquiryRecord.Passport_Expiry_Date__c = Date.parse(thisBuyer.Passport_Expiry_Date__c);
        inquiryRecord.Passport_Number__c = thisBuyer.Passport_Number__c;
        inquiryRecord.Passport_Place_of_Issue__c = thisBuyer.Place_of_Issue__c;
        inquiryRecord.Passport_Place_of_Issue_Arabic__c = thisBuyer.Place_of_Issue_Arabic__c;
          inquiryRecord.Address_Line_1__c = thisBuyer.Address_Line_1__c; 
          inquiryRecord.Address_Line_1_Arabic__c = thisBuyer.Address_Line_1_Arabic__c; 
          inquiryRecord.Address_Line_2__c = thisBuyer.Address_Line_2__c; 
          inquiryRecord.Address_Line_2_Arabic__c = thisBuyer.Address_Line_2_Arabic__c; 
          inquiryRecord.Address_Line_3__c = thisBuyer.Address_Line_3__c; 
          inquiryRecord.Address_Line_3_Arabic__c = thisBuyer.Address_Line_3_Arabic__c; 
          inquiryRecord.Address_Line_4__c = thisBuyer.Address_Line_4__c; 
          inquiryRecord.Address_Line_4_Arabic__c = thisBuyer.Address_Line_4_Arabic__c; 
          inquiryRecord.City_new__c = thisBuyer.City__c;
          inquiryRecord.City_Arabic__c = thisBuyer.City_Arabic__c;
          inquiryRecord.Country__c = thisBuyer.Country__c;
          inquiryRecord.Country_Arabic__c = thisBuyer.Country_Arabic__c;
          if(String.isBlank(thisBuyer.Inquiry__c)){
            inquiryRecord.Mobile_Phone_Encrypt__c = thisBuyer.Phone__c;
          inquiryRecord.Mobile_CountryCode__c = thisBuyer.Phone_Country_Code__c;  
          inquiryRecord.Inquiry_Source__c = 'Prospecting';
          }else{
            inquiryRecord.Mobile_Phone_Encrypt_2__c = thisBuyer.Phone__c;
          inquiryRecord.Mobile_Country_Code_2__c = thisBuyer.Phone_Country_Code__c;    
          }
        inquiryRecord.Email__c = thisBuyer.Email__c;
        /* Mapping fields for corporate buyers. */
          if(String.isNotBlank(thisBuyer.Buyer_Type__c) && thisBuyer.Buyer_Type__c.equalsIgnoreCase('Corporate')){
            inquiryRecord.Organisation_Name__c = thisBuyer.Organisation_Name__c; 
            inquiryRecord.Organisation_Name_Arabic__c = thisBuyer.Organisation_Name_Arabic__c; 
            inquiryRecord.CR_Number__c = thisBuyer.CR_Number__c;
            inquiryRecord.CR_Registration_Expiry_Date__c = Date.parse(thisBuyer.CR_Registration_Expiry_Date__c);
            inquiryRecord.CR_Registration_Place__c = thisBuyer.CR_Registration_Place__c;
            inquiryRecord.CR_Registration_Place_Arabic__c = thisBuyer.CR_Registration_Place_Arabic__c; 
          }
        inquiryRecord.RecordTypeId = inquiryRecordTypeId;  
        if(String.isNotBlank(thisBuyer.Inquiry__c)){
            inquiryRecord.Id = thisBuyer.Inquiry__c;
            updateExistingInquiryList.put(inquiryRecord.Id, inquiryRecord);
          }else{
            insertInquiryList.add(inquiryRecord);  
          }
        buyerInquiryMap.put(thisBuyer.Id, inquiryRecord);
        }
      }  
      system.debug('#### insertInquiryList = '+insertInquiryList);
      system.debug('#### updateExistingInquiryList = '+updateExistingInquiryList);
      if(!insertInquiryList.isEmpty()){
          insert insertInquiryList; 
          for(Inquiry__c thisInquiry : insertInquiryList){
          if(String.isNotBlank(thisInquiry.Passport_Number__c)){
            passportInquiryMap.put(thisInquiry.Passport_Number__c, thisInquiry.Id);    
          }else if(String.isNotBlank(thisInquiry.CR_Number__c)){
            passportInquiryMap.put(thisInquiry.CR_Number__c, thisInquiry.Id);       
          }
        }   
      }
      if(!updateExistingInquiryList.isEmpty()){
        update updateExistingInquiryList.values();  
        for(Inquiry__c thisInquiry : updateExistingInquiryList.values()){
          if(String.isNotBlank(thisInquiry.Passport_Number__c)){
            passportInquiryMap.put(thisInquiry.Passport_Number__c, thisInquiry.Id);    
          }else if(String.isNotBlank(thisInquiry.CR_Number__c)){
            passportInquiryMap.put(thisInquiry.CR_Number__c, thisInquiry.Id);       
          }
        }
      }
      if(!buyerInquiryMap.isEmpty()){
        /* creating associated campaign record. */
      createAssociatedCampaign(buyerInquiryMap);  
      }
      return passportInquiryMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to create associated campaign record.                                *
    * @Params      : Map<Id, Inquiry__c>                                                         *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    private void createAssociatedCampaign(Map<Id, Inquiry__c> buyerInquiryMap){
        Map<Id, Set<Id>> bookingIdBuyerIdsMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> bookingIdCampaignIdsMap = new Map<Id, Set<Id>>();
        List<Campaign_Member__c> relatedCampaignList = new List<Campaign_Member__c>();
        Map<Id, Set<Id>> inquiryAssoCampMap = new Map<Id, Set<Id>>();
        Set<Id> inquiryIds = new Set<Id>();
        for(Buyer__c thisBuyer : [SELECT Id, Booking__c FROM Buyer__c WHERE Id IN: buyerInquiryMap.keySet()]){
            if(thisBuyer.Booking__c != null){
                if(bookingIdBuyerIdsMap.containsKey(thisBuyer.Booking__c)){
                    bookingIdBuyerIdsMap.get(thisBuyer.Booking__c).add(thisBuyer.Id);  
                }else{
                    bookingIdBuyerIdsMap.put(thisBuyer.Booking__c, new Set<Id>{thisBuyer.Id});  
                }
            }  
        }
        for(Inquiry__c thisInq : buyerInquiryMap.values()){
            inquiryIds.add(thisInq.Id);
        }
        system.debug(inquiryIds);
        if(!inquiryIds.isEmpty()){
            for(Campaign_Member__c thisCampMem : [SELECT Id, Name, Campaign__c, Inquiry__c FROM Campaign_Member__c WHERE Inquiry__c IN: inquiryIds]){
                if(inquiryAssoCampMap.containsKey(thisCampMem.Inquiry__c)){
                    inquiryAssoCampMap.get(thisCampMem.Inquiry__c).add(thisCampMem.Campaign__c);
                }else{
                    inquiryAssoCampMap.put(thisCampMem.Inquiry__c, new Set<Id>{thisCampMem.Campaign__c});
                }
            }
        }
        system.debug(inquiryAssoCampMap);
        if(!bookingIdBuyerIdsMap.isEmpty()){
            for(Booking_Unit__c thisBookingUnit : [SELECT Id, Related_Campaign__c, Booking__c, Related_Promotion__c 
                                                   FROM Booking_Unit__c 
                                                   WHERE Booking__c IN: bookingIdBuyerIdsMap.keySet()])
            {
                if(thisBookingUnit.Related_Campaign__c != null){
                    if(bookingIdCampaignIdsMap.containsKey(thisBookingUnit.Booking__c)){
                        bookingIdCampaignIdsMap.get(thisBookingUnit.Booking__c).add(thisBookingUnit.Related_Campaign__c);  
                    }else{
                        bookingIdCampaignIdsMap.put(thisBookingUnit.Booking__c, new Set<Id>{thisBookingUnit.Related_Campaign__c});  
                    }
                }  
            }  
            if(!bookingIdCampaignIdsMap.isEmpty()){
                for(Id thisKey : bookingIdCampaignIdsMap.keySet()){
                    if(bookingIdBuyerIdsMap.containsKey(thisKey)){
                        for(Id thisBuyerId : bookingIdBuyerIdsMap.get(thisKey)){
                            if(buyerInquiryMap.containsKey(thisBuyerId)){
                                for(Id thisCampaignId : bookingIdCampaignIdsMap.get(thisKey)){
                                    if(inquiryAssoCampMap.isEmpty()){
                                        Campaign_Member__c campaignMemberRecord = new Campaign_Member__c();
                                        campaignMemberRecord.Campaign__c = thisCampaignId;
                                        campaignMemberRecord.Inquiry__c = buyerInquiryMap.get(thisBuyerId).Id;
                                        relatedCampaignList.add(campaignMemberRecord);
                                    } else if(inquiryAssoCampMap.containsKey(buyerInquiryMap.get(thisBuyerId).Id)){
                                        if(!inquiryAssoCampMap.get(buyerInquiryMap.get(thisBuyerId).Id).contains(thisCampaignId)){
                                            Campaign_Member__c campaignMemberRecord = new Campaign_Member__c();
                                            campaignMemberRecord.Campaign__c = thisCampaignId;
                                            campaignMemberRecord.Inquiry__c = buyerInquiryMap.get(thisBuyerId).Id;
                                            relatedCampaignList.add(campaignMemberRecord);
                                        }
                                    }
                                }
                            }
                        }    
                    }
                }  
            }
            system.debug('#### relatedCampaignList = '+relatedCampaignList);
            if(!relatedCampaignList.isEmpty()){
                insert relatedCampaignList;  
            }
        }
    }
    /*********************************************************************************************
    * @Description : Method to save booking records.                                             *
    * @Params      : NSIBPM__Service_Request__c, Map<String, List<Buyer__c>>                     *
    * @Return      : Map<String, Booking__c>                                                     *
    *********************************************************************************************/
    private Map<String, Booking__c> createBookingRecords(NSIBPM__Service_Request__c dealRecord, Set<String> uniqueKeySet){
        system.debug('#### Creating new booking records.');
        Map<String, Booking__c> upsertBookingMap = new Map<String, Booking__c>();
        for(String thisKey : uniqueKeySet){
            Booking__c bookingRecord = new Booking__c();
            bookingRecord.Booking_Channel__c = 'Office';
            bookingRecord.Deal_SR__c = dealRecord.Id;
            bookingRecord.Status__c = 'New';
            bookingRecord.Unique_Key__c = thisKey;  
            upsertBookingMap.put(bookingRecord.Unique_Key__c, bookingRecord);
        }
        if(!upsertBookingMap.isEmpty()){
            upsert upsertBookingMap.values() Unique_Key__c;   
        }
        system.debug('#### Insert booking records = '+upsertBookingMap);
        return upsertBookingMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to update booking record in case a new buyer is added.               *
    * @Params      : Map<String, Buyer__c>                                                       *
    * @Return      : Map<String, Booking__c>                                                     *
    *********************************************************************************************/
    private Map<String, Booking__c> updateBookingRecords(NSIBPM__Service_Request__c dealRecord, Map<String, Map<String, Buyer__c>> updateBuyerUniqueMap){
    system.debug('#### Updating new booking records.');
    Map<String, Booking__c> bookingUniqueKeyMap = new Map<String, Booking__c>();
    for(Id thisBookingId : updateBuyerUniqueMap.keySet()){
      String uniqueKey = dealRecord.Id;
      Booking__c bookingRecord = new Booking__c(Id = thisBookingId);
      for(Buyer__c thisBuyer : updateBuyerUniqueMap.get(thisBookingId).values()){
        if(String.isNotBlank(thisBuyer.Passport_Number__c)){
          if(!uniqueKey.containsIgnoreCase(thisBuyer.Passport_Number__c)){
            uniqueKey = thisBuyer.Passport_Number__c +' - '+ uniqueKey;  
          }
            }
            if(String.isNotBlank(thisBuyer.CR_Number__c)){
              if(!uniqueKey.containsIgnoreCase(thisBuyer.CR_Number__c)){
                uniqueKey = thisBuyer.CR_Number__c +' - '+ uniqueKey;  
              }
            }  
      }
      bookingRecord.Unique_Key__c = uniqueKey;
      bookingUniqueKeyMap.put(uniqueKey, bookingRecord);  
    }  
    /* Update the booking unique key. */
    if(!bookingUniqueKeyMap.isEmpty()){
      update bookingUniqueKeyMap.values();  
    }
    system.debug('#### Updating booking records = '+bookingUniqueKeyMap);
    return bookingUniqueKeyMap;  
    }
    
    /*********************************************************************************************
    * @Description : Method to update the buyers record, in case the existing buyer records      *
    *                are updated or a new record is being added.                                 *
    * @Params      : Map<String, Booking__c>, Map<String, List<Buyer__c>>                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    private void updateBuyerRecords(Map<String, Booking__c> bookingUniqueKeyMap, Map<String, Map<String, Buyer__c>> updateBuyerUniqueMap){
      Map<String, Buyer__c> newBuyerMap = new Map<String, Buyer__c>();
      Map<String, Buyer__c> existingBuyerMap = new Map<String, Buyer__c>();
      /* Calling method to get the phone code and value map. */
        Map<String, String> phoneCodeValueMap = getPhoneCodeValueMap();
        for(String thisKey : updateBuyerUniqueMap.keySet()){
            for(Buyer__c thisBuyer : updateBuyerUniqueMap.get(thisKey).values()){
                if(String.isNotBlank(thisBuyer.CR_Number__c)){
                  thisBuyer.Unique_Key__c = thisBuyer.CR_Number__c+' - '+thisKey;    
                }else if(String.isNotBlank(thisBuyer.Passport_Number__c)){
                   thisBuyer.Unique_Key__c = thisBuyer.Passport_Number__c+' - '+thisKey;  
                }
                if(String.isNotBlank(thisBuyer.Phone_Country_Code__c) && phoneCodeValueMap.containsKey(thisBuyer.Phone_Country_Code__c)){
                  thisBuyer.Phone_Country_Code__c = phoneCodeValueMap.get(thisBuyer.Phone_Country_Code__c);  
                }
                thisBuyer.Booking__c = thisKey;
                /* Since this method handles the update, we are splitting into two different transactions. 
                   - Insert if it is a new buyer, as it will not have any salesforce Id populated. 
                   - Update if it's and existing buyer, as it will have salesforce Id populated. */
                if(!existingBuyerMap.containsKey(thisBuyer.Unique_Key__c) && 
                   !newBuyerMap.containsKey(thisBuyer.Unique_Key__c)){
                  if(String.isBlank(thisBuyer.Id)){
                    newBuyerMap.put(thisBuyer.Unique_Key__c, thisBuyer);  
                  }else{
                    existingBuyerMap.put(thisBuyer.Unique_Key__c, thisBuyer);  
                  }
                }
            }
        }   
        system.debug('#### newBuyerMap = '+newBuyerMap);
        system.debug('#### existingBuyerMap = '+existingBuyerMap);
        if(!newBuyerMap.isEmpty()){
          /* Calling method to create inquiries and update it to the buyer record, in case a new buyer is added. */
          Map<String, String> passportInquiryMap = createInquiry(newBuyerMap.values());
          for(Buyer__c thisBuyer : newBuyerMap.values()){
            if(String.isNotBlank(thisBuyer.Passport_Number__c) && passportInquiryMap.containsKey(thisBuyer.Passport_Number__c)){
              thisBuyer.Inquiry__c = passportInquiryMap.get(thisBuyer.Passport_Number__c);
            }
            if(String.isNotBlank(thisBuyer.CR_Number__c) && passportInquiryMap.containsKey(thisBuyer.CR_Number__c)){
              thisBuyer.Inquiry__c = passportInquiryMap.get(thisBuyer.CR_Number__c);
            }
          }
          insert newBuyerMap.values();
        }
        if(!existingBuyerMap.isEmpty()){
          Map<Id, Buyer__c> uniqueBuyer = new Map<Id, Buyer__c>();
          /* Calling method to create inquiries and update it to the buyer record, in case a new buyer is added. */
          Map<String, String> passportInquiryMap = createInquiry(existingBuyerMap.values());
          for(Buyer__c thisBuyer : existingBuyerMap.values()){
            if(String.isNotBlank(thisBuyer.Passport_Number__c) && passportInquiryMap.containsKey(thisBuyer.Passport_Number__c)){
              thisBuyer.Inquiry__c = passportInquiryMap.get(thisBuyer.Passport_Number__c);
            }
            if(String.isNotBlank(thisBuyer.CR_Number__c) && passportInquiryMap.containsKey(thisBuyer.CR_Number__c)){
              thisBuyer.Inquiry__c = passportInquiryMap.get(thisBuyer.CR_Number__c);
            }
            uniqueBuyer.put(thisBuyer.Id, thisBuyer);  
          }
          update uniqueBuyer.values();  
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to create new buyers records, and associated inquiry record.         *
    *                reversably update the associated inquiry lookup on the buyer.               *
    * @Params      : Map<String, Booking__c>, Map<String, List<Buyer__c>>                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    private void createBuyerRecords(Map<String, Booking__c> bookingUniqueKeyMap, Set<String> uniqueKeySet, Map<String, List<Buyer__c>> newBuyerUniqueMap){
        Map<String, Buyer__c> insertBuyerMap = new Map<String, Buyer__c>();  
        /* Calling method to get the phone code and value map. */
        Map<String, String> phoneCodeValueMap = getPhoneCodeValueMap();
        for(String thisKey : uniqueKeySet){
          if(newBuyerUniqueMap.containsKey(thisKey)){
            for(Buyer__c thisBuyer : newBuyerUniqueMap.get(thisKey)){
              system.debug('#### thisBuyer = '+thisBuyer);
              Buyer__c newBuyerRecord = thisBuyer.clone(false, true, false, false);
                  if(bookingUniqueKeyMap != null && bookingUniqueKeyMap.containsKey(thisKey)){
                      if(String.isNotBlank(newBuyerRecord.CR_Number__c)){
                        newBuyerRecord.Unique_Key__c = newBuyerRecord.CR_Number__c+' - '+bookingUniqueKeyMap.get(thisKey).Id;    
                      }else if(String.isNotBlank(newBuyerRecord.Passport_Number__c)){
                         newBuyerRecord.Unique_Key__c = newBuyerRecord.Passport_Number__c+' - '+bookingUniqueKeyMap.get(thisKey).Id;  
                      }
                      if(String.isNotBlank(newBuyerRecord.Phone_Country_Code__c) && phoneCodeValueMap.containsKey(newBuyerRecord.Phone_Country_Code__c)){
                      newBuyerRecord.Phone_Country_Code__c = phoneCodeValueMap.get(newBuyerRecord.Phone_Country_Code__c);  
                    }
                    newBuyerRecord.Booking__c = bookingUniqueKeyMap.get(thisKey).Id;
                    if(!insertBuyerMap.containsKey(newBuyerRecord.Unique_Key__c)){
                       insertBuyerMap.put(newBuyerRecord.Unique_Key__c, newBuyerRecord);
                    }
                  }
              }  
          }
        }   
        system.debug('#### insertBuyerMap = '+insertBuyerMap);
        /* Calling method to create inquiries and update it to the buyer record. */
        Map<String, String> passportInquiryMap = createInquiry(insertBuyerMap.values());
        for(Buyer__c thisBuyer : insertBuyerMap.values()){
          if(String.isNotBlank(thisBuyer.Passport_Number__c) && passportInquiryMap.containsKey(thisBuyer.Passport_Number__c)){
            thisBuyer.Inquiry__c = passportInquiryMap.get(thisBuyer.Passport_Number__c);
          }
          if(String.isNotBlank(thisBuyer.CR_Number__c) && passportInquiryMap.containsKey(thisBuyer.CR_Number__c)){
            thisBuyer.Inquiry__c = passportInquiryMap.get(thisBuyer.CR_Number__c);
          }
        }
        if(!insertBuyerMap.isEmpty()){
          upsert insertBuyerMap.values() Unique_Key__c; 
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to get phone code and value map.                                     *
    * @Params      : void                                                                        *
    * @Return      : Map<String, String>                                                         *
    *********************************************************************************************/
    private Map<String, String> getPhoneCodeValueMap(){
      Map<String, String> phoneCodeValueMap = new Map<String, String>();
      if(Buyer__c.getSObjectType() != null && Buyer__c.getSObjectType().getDescribe() != null){
          Map<String, Schema.SObjectField> field_map = Buyer__c.getSObjectType().getDescribe().fields.getMap(); 
          if(field_map.containsKey('Phone_Country_Code__c')){
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Phone_Country_Code__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry thisValue : pick_list_values) { 
          phoneCodeValueMap.put(thisValue.getLabel().subStringAfter(': '), thisValue.getLabel());
        }  
          }
        }
        return phoneCodeValueMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to get associated campaign to the booking.                           *
    *         - If associated PC is a part of roadshow, stamp that campaign.              *
    *         - If above not found, then stamp the inventory campaign.                    *
    *         - If above not found, then stamp the related campaign.                      *
    *         - If above not found, then stamp the latest associated campaign.            *
    * @Params      : Map<String, List<Booking_Unit__c>>                                          *
    * @Return      : Map<Id, Id>                                                                 *
    *********************************************************************************************/
    private Map<Id, Id> getAssociatedCampaign(Map<String, List<Booking_Unit__c>> unitUniqueMap){
      String roadshowCampaign;
      Set<Id> inventoryIdsSet = new Set<Id>();
      Map<Id, Id> inventoryCampaignMap = new Map<Id, Id>();
      for(String thisKey : unitUniqueMap.keySet()){
        for(Booking_Unit__c thisBookingUnit : unitUniqueMap.get(thisKey)){
          if(thisBookingUnit.Inventory__c != null){
            inventoryIdsSet.add(thisBookingUnit.Inventory__c);
          }  
        }  
      }
        if(!inventoryIdsSet.isEmpty()){
          /* Calling method to get the roadshows*/
        roadshowCampaign = getRoadshowCampaign();
        system.debug('#### roadshowCampaign = '+roadshowCampaign);
        if(String.isNotBlank(roadshowCampaign)){
          for(Id thisInventoryId : inventoryIdsSet){
            inventoryCampaignMap.put(thisInventoryId, Id.valueOf(roadshowCampaign));   
          }  
        }else{
          /* Calling method to return inventory related campaign. */
          inventoryCampaignMap = getCampaignRelatedBookingUnit(inventoryIdsSet);  
          if(inventoryCampaignMap.isEmpty() || !inventoryIdsSet.containsAll(inventoryCampaignMap.keySet())){
            /* Calling method to return inquiry related campaign. */
            inventoryCampaignMap = getInquiryRelatedCampaign(unitUniqueMap);  
          }
        }
        }
      return inventoryCampaignMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to get inquiry related campaign.                                     *
    * @Params      : Map<Id, Id>                                                                 *
    * @Return      : Map<Id, Id>                                                                 *
    *********************************************************************************************/
    private Map<Id, Id> getInquiryRelatedCampaign(Map<String, List<Booking_Unit__c>> unitUniqueMap){
      Map<Id, Id> inventoryCampaignMap = new Map<Id, Id>();  
      Map<Id, String> inquiryIdBookingIdMap = new Map<Id, String>();
      Map<String, Id> bookingIdCampaignIdMap = new Map<String, Id>();
      Map<String, List<Booking_Unit__c>> bookingIdUnitListMap = new Map<String, List<Booking_Unit__c>>();
      for(String thisKey : unitUniqueMap.keySet()){
        for(Booking_Unit__c thisBookingUnit : unitUniqueMap.get(thisKey)){
          if(bookingIdUnitListMap.containsKey(thisBookingUnit.Booking__c)){
            bookingIdUnitListMap.get(thisBookingUnit.Booking__c).add(thisBookingUnit);
          }else{
            bookingIdUnitListMap.put(thisBookingUnit.Booking__c, new List<Booking_Unit__c>{thisBookingUnit});    
          }
        }  
      }
      if(!bookingIdUnitListMap.isEmpty()){
        for(Buyer__c thisBuyer : [SELECT Id, Inquiry__c, Booking__c, Booking__r.Unique_Key__c
                      FROM Buyer__c 
                      WHERE Booking__c IN: bookingIdUnitListMap.keySet() AND 
                          Primary_Buyer__c = true]){
          if(thisBuyer.Inquiry__c != null && thisBuyer.Booking__c != null){
            inquiryIdBookingIdMap.put(thisBuyer.Inquiry__c, thisBuyer.Booking__c);      
          }
        }
        system.debug('#### inquiryIdBookingIdMap = '+inquiryIdBookingIdMap);
        if(!inquiryIdBookingIdMap.isEmpty()){
          for(Inquiry__c thisInquiry : [SELECT Id, Campaign__c, 
                             (SELECT Id, Campaign__c FROM Associated_Campaigns__r ORDER BY CreatedDate DESC) 
                          FROM Inquiry__c 
                          WHERE Id IN: inquiryIdBookingIdMap.keySet()]){ 
            if(thisInquiry.Campaign__c != null){
              if(inquiryIdBookingIdMap.containsKey(thisInquiry.Id)){
                bookingIdCampaignIdMap.put(inquiryIdBookingIdMap.get(thisInquiry.Id), thisInquiry.Campaign__c);    
              }
            }else{
              if(inquiryIdBookingIdMap.containsKey(thisInquiry.Id)){
                for(Campaign_Member__c thisCampaignMember : thisInquiry.Associated_Campaigns__r){
                  bookingIdCampaignIdMap.put(inquiryIdBookingIdMap.get(thisInquiry.Id), thisCampaignMember.Campaign__c);  
                  break;
                }
              }  
            }
          }  
          for(String thisBookingKey : bookingIdUnitListMap.keySet()){
            for(Booking_Unit__c thisBookingUnit : bookingIdUnitListMap.get(thisBookingKey)){
              if(thisBookingUnit.Inventory__c != null){
                inventoryCampaignMap.put(thisBookingUnit.Inventory__c, bookingIdCampaignIdMap.get(thisBookingKey));    
              }  
            }
          }
        }  
      }
      return inventoryCampaignMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to save booking unit records.                                        *
    * @Params      : Map<String, Booking__c>, Map<String, List<Booking_Unit__c>>                 *
    * @Return      : Map<String, String>                                                         *
    *********************************************************************************************/
    private Map<String, String> createBookingUnitRecords(Map<String, Booking__c> bookingUniqueKeyMap, Map<String, List<Booking_Unit__c>> unitUniqueMap){
        Map<String, Booking_Unit__c> insertBookingUnitMap = new Map<String, Booking_Unit__c>();
        Map<String, String> inventoryBookingUnitMap = new Map<String, String>();
        Map<Id, Id> inventoryCampaignMap = new Map<Id, Id>();
        User loggedInUserDetails;
        for(User thisUserInfo : [SELECT Id, Location__c, Sales_Office__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1]){
          loggedInUserDetails = thisUserInfo;
          break;  
        }
        /* Calling method to get the associated campaign. */
    inventoryCampaignMap = getAssociatedCampaign(unitUniqueMap);
    system.debug('#### inventoryCampaignMap = '+inventoryCampaignMap);
        for(String thisKey : unitUniqueMap.keySet()){
            for(Booking_Unit__c thisUnit : unitUniqueMap.get(thisKey)){
              thisUnit.Booking_Location__c = loggedInUserDetails.Sales_Office__c;
                if(thisUnit.Booking__c == null && bookingUniqueKeyMap.containsKey(thisKey)){
                    thisUnit.Booking__c = bookingUniqueKeyMap.get(thisKey).Id;
                    thisUnit.Unique_Key__c = bookingUniqueKeyMap.get(thisKey).Id+' - '+thisUnit.Inventory__c;
                }
                if(inventoryCampaignMap.containsKey(thisUnit.Inventory__c)){
                  thisUnit.Related_Campaign__c = inventoryCampaignMap.get(thisUnit.Inventory__c);
                }
                insertBookingUnitMap.put(thisUnit.Unique_Key__c, thisUnit);    
            }
        }   
        
        if(!insertBookingUnitMap.isEmpty()){
            upsert insertBookingUnitMap.values() Unique_Key__c;
            for(Booking_Unit__c thisUnit : insertBookingUnitMap.values()){
                inventoryBookingUnitMap.put(thisUnit.Inventory__c, thisUnit.Id);    
            }
        }
        system.debug('#### insertBookingUnitMap = '+insertBookingUnitMap);
        system.debug('#### inventoryBookingUnitMap = '+inventoryBookingUnitMap);
        return inventoryBookingUnitMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to save payment plans.                                               *
    * @Params      : Map<String, Payment_Plan__c>, Map<String, String>                           *
    * @Return      : Map<String, String>                                                         *
    *********************************************************************************************/
    private Map<String, String> createPaymentPlans(Map<String, String> bookingUnitInventoryMap, 
                                                   Map<String, Payment_Plan__c> inventoryPaymentPlanMap, 
                                                   Map<String, String> inventoryBookingUnitMap){
        List<Payment_Plan__c> insertPaymentPlanList = new List<Payment_Plan__c>();
        Map<String, String> insertedPaymentPlanMap = new Map<String, String>();
        for(String thisKey : inventoryPaymentPlanMap.keySet()){
            Payment_Plan__c thisPaymentPlan = inventoryPaymentPlanMap.get(thisKey).clone(false, true, false, false);
            thisPaymentPlan.Building_ID__c = '';
            thisPaymentPlan.Building_Location__c = null;
            thisPaymentPlan.TERM_ID__c = null;
            thisPaymentPlan.Unique_Key__c = inventoryPaymentPlanMap.get(thisKey).TERM_ID__c+' - '+inventoryBookingUnitMap.get(thisKey);
            thisPaymentPlan.Booking_Unit__c = inventoryBookingUnitMap.get(thisKey); 
            thisPaymentPlan.Parent_Payment_Plan__c = inventoryPaymentPlanMap.get(thisKey).Id;
            insertPaymentPlanList.add(thisPaymentPlan);
        } 
        if(!insertPaymentPlanList.isEmpty()){
            upsert insertPaymentPlanList Unique_Key__c; 
            for(Payment_Plan__c thisPaymentPlan : insertPaymentPlanList){
                insertedPaymentPlanMap.put(bookingUnitInventoryMap.get(thisPaymentPlan.Booking_Unit__c), thisPaymentPlan.Id);       
            }
        }   
        system.debug('#### insertedPaymentPlanMap = '+insertedPaymentPlanMap);
        return insertedPaymentPlanMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to save payment terms.                                               *
    * @Params      : Map<String, String>, Map<String, List<Payment_Terms__c>>                    *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    private void createPaymentTerms(Map<String, String> insertedPaymentPlanMap, Map<String, List<Payment_Terms__c>> inventoryPaymentTermsMap){
        List<Payment_Terms__c> insertPaymentTermList = new List<Payment_Terms__c>();
        for(String thisKey : inventoryPaymentTermsMap.keySet()){
            for(Payment_Terms__c thisPaymentTerm : inventoryPaymentTermsMap.get(thisKey)){
              system.debug('#### thisPaymentTerm = '+thisPaymentTerm.Line_ID__c);
                Payment_Terms__c paymentTermObject = thisPaymentTerm.clone(false, true, false, false);
                paymentTermObject.Unique_Key__c = thisPaymentTerm.Line_ID__c+' - '+insertedPaymentPlanMap.get(thisKey);
                paymentTermObject.Line_ID__c = null;
                paymentTermObject.Payment_Plan__c = insertedPaymentPlanMap.get(thisKey);
                insertPaymentTermList.add(paymentTermObject);      
            }
        }
        if(!insertPaymentTermList.isEmpty()){
            upsert insertPaymentTermList Unique_Key__c;   
        }   
    } 
    
    /*********************************************************************************************
    * @Description : Method to clear the error box.                                              *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void closeErrorBox(){
      isError = false;
      errorMessage = '';  
    }
    
    /*********************************************************************************************
    * @Description : Method to check if required fields are populated on the buyer or not.       *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public static String validateBuyerFields(List<UtilityWrapperManager.InventoryBuyerWrapper> selectedInventoryList, Boolean allPrimaryBuyerSame, Boolean allJointbuyerSame){
      String message = 'success';
      Map<String, List<Buyer_Information__mdt>> buyerFieldsMap = getBuyerFields(); 
      if(selectedInventoryList != null && selectedInventoryList.size() > 0){
            for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : selectedInventoryList){
                if(thisInventory.isSelected){
                    if(thisInventory.jointBuyerList != null){ 
                        for(Buyer__c thisBuyer : thisInventory.jointBuyerList){ 
                          if((thisBuyer.Primary_Buyer__c && allPrimaryBuyerSame) || 
                             (!thisBuyer.Primary_Buyer__c && allJointbuyerSame)){
                            sObject buyerRecord = thisBuyer;
                            if(String.isNotBlank(thisBuyer.Buyer_Type__c) && buyerFieldsMap.containsKey(thisBuyer.Buyer_Type__c)){
                              for(Buyer_Information__mdt thisField : buyerFieldsMap.get(thisBuyer.Buyer_Type__c)){
                                String fieldValue = String.valueOf(buyerRecord.get(thisField.API_Name__c));
                                system.debug('#### fieldValue = '+fieldValue);
                                if(Boolean.valueOf(thisField.Required__c) && String.isBlank(fieldValue)){
                                  message = system.Label.Error_Mandatory_Fields;
                                  break;    
                                }  
                                if(thisField.API_Name__c.equalsIgnoreCase('Passport_Expiry_Date__c')){
                                  String passportExpiryDateString = String.valueOf(buyerRecord.get('Passport_Expiry_Date__c'));
                                if(String.isNotBlank(passportExpiryDateString)){
                                  Date passportExpiryDate = Date.parse(passportExpiryDateString);
                                  if(passportExpiryDate <= system.today().addDays(30)){
                                    message = system.Label.Error_Passport_Validity;
                                    break;    
                                  }
                                }
                                }
                                if(thisField.API_Name__c.equalsIgnoreCase('CR_Registration_Expiry_Date__c')){
                                  if(thisBuyer.Buyer_Type__c.equalsIgnoreCase('Corporate')){
                                    String crRegistrationExpiryDateString =  String.valueOf(buyerRecord.get('CR_Registration_Expiry_Date__c'));
                                    if(String.isNotBlank(crRegistrationExpiryDateString)){
                                      Date thisDate = Date.parse(crRegistrationExpiryDateString);
                                      if(thisDate <= system.today().addDays(30)){
                                        message = system.Label.Error_CR_Registration_Date;
                                        break;    
                                      }  
                                    }
                                  }
                                }
                                if(thisField.API_Name__c.equalsIgnoreCase('Email__c')){
                                  String emailAddress = String.valueOf(buyerRecord.get('Email__c'));
                                  system.debug('#### Email = '+emailAddress);
                                  if(String.isNotBlank(emailAddress)){
                                    if(!validateEmailAddress(String.valueOf(buyerRecord.get('Email__c')))){
                                      message = system.Label.Error_Validate_Email;
                                    break;  
                                    }
                                  }
                                }
                                if(thisField.API_Name__c.equalsIgnoreCase('Phone__c')){
                                  String phoneString = String.valueOf(buyerRecord.get('Phone__c'));
                                  if(String.isNotBlank(phoneString)){
                                    if(!phoneString.isNumeric()){
                                      message = system.Label.Error_Validate_Phone;
                                    break;  
                                    }  
                                  }
                                }
                                if(thisField.API_Name__c.equalsIgnoreCase('Date_of_Birth__c')){
                                  String dateOfBirthString = String.valueOf(buyerRecord.get('Date_of_Birth__c'));
                                  if(String.isNotBlank(dateOfBirthString)){
                                    if(!validateDateOfBirth(Date.parse(dateOfBirthString))){
                                      message = system.Label.Error_Validate_Date_of_Birth;
                                    break;  
                                    }  
                                  }
                                }
                              }  
                            }  
                          }
                        }  
                    }
                }
            }
      }  
      return message;
    }
    
    /*********************************************************************************************
    * @Description : Method to   pulate data is SR has already been created.                      *
    * @Params      : String                                                                      *
    * @Return      : void                                                                        *
    *********************************************************************************************/
  public void prePopulateData(String dealId){
    List<UtilityWrapperManager.InventoryBuyerWrapper> ibwList = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
    Set<Id> selectedBookingUnitIdsSet = new Set<Id>();
    Set<Id> selectedInventoryIdsSet = new Set<Id>();
    Set<Id> bookingIdsSet = new Set<Id>();
    Set<Id> selectedPaymentPlanIdsSet = new Set<Id>();
    Map<Id, Id> inventoryBuildingLocationMap = new Map<Id, Id>();
      Map<Id, Booking_Unit__c> inventoryBookingUnitsMap = new Map<Id, Booking_Unit__c>();
      Map<Id, List<Buyer__c>> inventoryBuyersListMap = new Map<Id, List<Buyer__c>>();
      Map<String, Payment_Plan__c> buildingLocationPaymentPlanMap = new Map<String, Payment_Plan__c>();
      Map<String, Payment_Plan__c> inventorySelectedPaymentPlanMap = new Map<String, Payment_Plan__c>();
      Map<String, Payment_Plan__c> inventoryPaymentPlanMap = new Map<String, Payment_Plan__c>();
      Map<String, Payment_Plan__c> parentPaymentPlanMap = new Map<String, Payment_Plan__c>();
      
      /* Calling method to get the deal details. */
      availableInventoriesList.dealRecord = getSrDetails(dealId);
      for(Booking__c thisBooking : availableInventoriesList.dealRecord.Bookings__r){
      if(String.isNotBlank(thisBooking.Id)){
              bookingIdsSet.add(thisBooking.Id);
            }
    }
      
      /* Calling method to set the wizard screen level. */
      system.debug('#### Deal Record details = '+availableInventoriesList.dealRecord);
      setWizardLevel(availableInventoriesList.dealRecord);
      /* Calling method to get the associated booking details. */
      if(!bookingIdsSet.isEmpty()){
        for(Booking__c thisBooking : getBookingDetails(bookingIdsSet)){ 
        for(Booking_Unit__c thisUnit : thisBooking.Booking_Units__r){
             IDServiceRequest.add(thisUnit.ID);
          selectedInventoryIdsSet.add(thisUnit.Inventory__c);
          selectedBookingUnitIdsSet.add(thisUnit.Id);
          inventoryBuildingLocationMap.put(thisUnit.Inventory__c, thisUnit.Inventory__r.Building_Location__c);
          inventoryBookingUnitsMap.put(thisUnit.Inventory__c, thisUnit);
          for(Buyer__c thisBuyer : thisBooking.Buyers__r){
            if(inventoryBuyersListMap.containsKey(thisUnit.Inventory__c)){
              inventoryBuyersListMap.get(thisUnit.Inventory__c).add(thisBuyer.clone(true, true, true, true));    
            }else{
              inventoryBuyersListMap.put(thisUnit.Inventory__c, new List<Buyer__c>{thisBuyer.clone(true, true, true, true)});    
            }  
          }
        }
      }  
      }  
      /* Calling method to get the associated payment plan details for the selected units. */
      system.debug('#### Inventory Building Location Map = '+inventoryBuildingLocationMap);
      if(!selectedBookingUnitIdsSet.isEmpty()){
        Map<String, Payment_Plan__c> bookingUnitPaymentPlanMap = getPaymentPlanDetails(selectedBookingUnitIdsSet);
        for(Payment_Plan__c thisPaymentPlan : bookingUnitPaymentPlanMap.values()){
          selectedPaymentPlanIdsSet.add(thisPaymentPlan.Parent_Payment_Plan__c);
          inventorySelectedPaymentPlanMap.put(thisPaymentPlan.Booking_Unit__r.Inventory__c, thisPaymentPlan); 
        } 
      }
      if(!selectedPaymentPlanIdsSet.isEmpty()){
        parentPaymentPlanMap = getSelectedPaymentPlanDetails(selectedPaymentPlanIdsSet);
      }
      
      system.debug('#### Building Location Payment Plan Map = '+buildingLocationPaymentPlanMap);
      for(Id thisKey : inventoryBuildingLocationMap.keySet()){
        if(inventoryBuildingLocationMap.get(thisKey) != null && 
           buildingLocationPaymentPlanMap.containsKey(inventoryBuildingLocationMap.get(thisKey))){
          inventoryPaymentPlanMap.put(thisKey, buildingLocationPaymentPlanMap.get(inventoryBuildingLocationMap.get(thisKey)));    
        }
      }
      system.debug('#### Deal Inventory Payment Plan Map = '+inventoryPaymentPlanMap);
      /* Calling method to prepopulate the selected inventory details. */
      if(!selectedInventoryIdsSet.isEmpty()){
        Map<Id, Inventory__c> inventoryMap = getInventoryDetails(selectedInventoryIdsSet);  
        for(Inventory__c thisInventory : inventoryMap.values()){ 
          ibwList.add(new UtilityWrapperManager.InventoryBuyerWrapper(true, 
                                                                        false,
                                                                        false,
                                                                        !inventoryBookingUnitsMap.isEmpty() && inventoryBookingUnitsMap.containsKey(thisInventory.Id) ? 
                                                                          inventoryBookingUnitsMap.get(thisInventory.Id).Requested_Token_Amount__c : 40000,
                                                                        !inventoryBookingUnitsMap.isEmpty() && inventoryBookingUnitsMap.containsKey(thisInventory.Id) ? 
                                                                          inventoryBookingUnitsMap.get(thisInventory.Id).Requested_Price__c : 0.0,
                                                                        !inventorySelectedPaymentPlanMap.isEmpty() && inventorySelectedPaymentPlanMap.containsKey(thisInventory.Id) ? 
                                                                          inventorySelectedPaymentPlanMap.get(thisInventory.Id).Parent_Payment_Plan__c : null,
                                                                        !inventoryBookingUnitsMap.isEmpty() && inventoryBookingUnitsMap.containsKey(thisInventory.Id) ? 
                                                                          inventoryBookingUnitsMap.get(thisInventory.Id).Payment_Method__c : '',
                                                                        !inventoryBookingUnitsMap.isEmpty() && inventoryBookingUnitsMap.containsKey(thisInventory.Id) ? 
                                                                          inventoryBookingUnitsMap.get(thisInventory.Id).Related_Promotion__c : '',
                                                                        !inventoryBookingUnitsMap.isEmpty() && inventoryBookingUnitsMap.containsKey(thisInventory.Id) ? 
                                                                          inventoryBookingUnitsMap.get(thisInventory.Id).Online_Payment_Party__c : '',
                                                                        !inventoryBookingUnitsMap.isEmpty() && inventoryBookingUnitsMap.containsKey(thisInventory.Id) && 
                                                                         inventoryBookingUnitsMap.get(thisInventory.Id).No_of_parking__c != null ? 
                                                                          Integer.valueOf(inventoryBookingUnitsMap.get(thisInventory.Id).No_of_parking__c) : 0,
                                                                        thisInventory,
                                                                        !inventoryBookingUnitsMap.isEmpty() && inventoryBookingUnitsMap.containsKey(thisInventory.Id) ? 
                                                                          inventoryBookingUnitsMap.get(thisInventory.Id) : new Booking_Unit__c(),
                                                                        !inventorySelectedPaymentPlanMap.isEmpty() && inventorySelectedPaymentPlanMap.containsKey(thisInventory.Id) && 
                                                                        !parentPaymentPlanMap.isEmpty() && parentPaymentPlanMap.containsKey(inventorySelectedPaymentPlanMap.get(thisInventory.Id).Parent_Payment_Plan__c) ? 
                                                                          new Map<String, Payment_Plan__c>{thisInventory.Id => parentPaymentPlanMap.get(inventorySelectedPaymentPlanMap.get(thisInventory.Id).Parent_Payment_Plan__c)} : new Map<String, Payment_Plan__c>(),
                                                                        !inventoryBuyersListMap.isEmpty() && inventoryBuyersListMap.containsKey(thisInventory.Id) ? 
                                                                          new List<Buyer__c>(inventoryBuyersListMap.get(thisInventory.Id)) : new List<Buyer__c>{new Buyer__c(Primary_Buyer__c = true)}));  
        }
      }
      system.debug('#### Prepopulated Data = '+ibwList);
      availableInventoriesList.ibwList = ibwList;
      
       try{
        List<option__c> listOption = new List<option__c>();
        listOption = [select ID,
                             PromotionName__c,
                             OptionsName__c,
                             CampaignName__c,
                             SchemeName__c,
                             Booking_Unit__c,
                             Net_Price__c,
                             UnitID__c,
                             Booking_Unit__r.Inventory__c
                      FROM Option__c 
                      WHERE Booking_Unit__c IN : IDServiceRequest
                     AND Booking_Unit__r.Booking__r.Deal_SR__r.Token_Amount_Approval_Status__c ='Approved'
                     ];
         if(!listOption.isEmpty()){ 
              finalWrap = DroolWebService.createRequestDataApproved(availableInventoriesList,listOption);
         }
         else{
          finalWrap = DroolWebService.createRequestData(availableInventoriesList);
         }
        }
     catch(Exception Ex){
      errorMessage  = 'Drool Web Service Call Out Failed Due to No Response from Drool';
     }

      
  }
     
    /*********************************************************************************************
    * @Description : Method to land on the correct wizard level.                                 *
    * @Params      : NSIBPM__Service_Request__c                                                  *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    private void setWizardLevel(NSIBPM__Service_Request__c dealRecord){
        system.debug('#### dealRecord.Booking_Wizard_Level__c = '+dealRecord.Booking_Wizard_Level__c);
    if(String.isNotBlank(dealRecord.Booking_Wizard_Level__c) && 
       dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 1')){
      showScreen1 = true;
          showScreen2 = false; 
          showScreen3 = false;  
          showScreen4 = false;    
    }else if(String.isNotBlank(dealRecord.Booking_Wizard_Level__c) && 
         dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 2')){
      showScreen1 = false;
          showScreen2 = true; 
          showScreen3 = false;  
          showScreen4 = false;    
    }else if(String.isNotBlank(dealRecord.Booking_Wizard_Level__c) && 
         dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 3')){
      showScreen1 = false;
          showScreen2 = false; 
          showScreen3 = true;  
          showScreen4 = false;    
    }   else if(String.isNotBlank(dealRecord.Booking_Wizard_Level__c) && 
         (dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 4'))){
      showScreen1 = false;
          showScreen2 = false; 
          showScreen3 = true;         
          showScreen4 = false;       
    }else if(String.isNotBlank(dealRecord.Booking_Wizard_Level__c) && 
         dealRecord.Booking_Wizard_Level__c.equalsIgnoreCase('Level 5') && 
         !dealRecord.NSIBPM__Steps_SR__r.isEmpty()){
            isError = true;
            isSuccess = true;
            isSubmitted = true;
            showScreen1 = false;
            showScreen2 = false; 
            showScreen3 = false;  
            showScreen4 = true; 
            errorPrefix = '';
            errorMessage = system.Label.Error_Deal_Submitted.replace('#DEAL_RECORD_ID#', '\'' + availableInventoriesList.dealRecord.Id + '\'').replace('#DEAL_ID#', String.isNotBlank(availableInventoriesList.dealRecord.Deal_ID__c) ? availableInventoriesList.dealRecord.Deal_ID__c : 'here');
    }else{
            isSubmitted = true;
            showScreen1 = false;
          showScreen2 = true; 
          showScreen3 = false;  
          showScreen4 = false; 
      }
    }
    
    /*********************************************************************************************
    * @Description : Method to check if the unit is still available.                             *
    * @Params      : String                                                                      *
    * @Return      : List<String>                                                                *
    *********************************************************************************************/
    private List<String> checkInventoryAvailable(Set<Id> selectedInventoryIdsSet){
        List<String> bookedInventoryList = new List<String>();
        for(Inventory__c thisInventory : [SELECT Id, Status__c, Location_Code__c, Floor_Package_ID__c, Floor_Package_Type__c, 
                             List_Price_calc__c, Special_Price_calc__c
                                          FROM Inventory__c 
                                          WHERE Id IN: selectedInventoryIdsSet]){
            if(String.isNotBlank(thisInventory.Status__c) && 
               !thisInventory.Status__c.equalsIgnoreCase('Released') && 
               String.isNotBlank(thisInventory.Location_Code__c)){
                bookedInventoryList.add(thisInventory.Location_Code__c);           
            }   
        }  
        system.debug('#### bookedInventoryList = '+bookedInventoryList);
        return bookedInventoryList;
    }
    
    /*********************************************************************************************
    * @Description : Method to get SR Detail after insertion.                                    *
    * @Params      : String                                                                      *
    * @Return      : NSIBPM__Service_Request__c                                                  *
    *********************************************************************************************/
    private NSIBPM__Service_Request__c getSrDetails(String srId){
        NSIBPM__Service_Request__c dealSr = new NSIBPM__Service_Request__c();
        for(NSIBPM__Service_Request__c thisSr : [SELECT Id, Name, NSIBPM__Submitted_Date__c, NSIBPM__Submitted_DateTime__c, 
                                                        Token_Deposit_Due_Date_Time__c, NSIBPM__Internal_SR_Status__c, 
                                                        NSIBPM__External_SR_Status__c, RecordTypeId, Deal_ID__c, Delivery_Mode__c,
                                                        Agent_Name__c, Agency__c, Booking_Wizard_Level__c, Token_Amount_Approval_Status__c,
                                                        NSIBPM__Internal_Status_Name__c, Is_Submitted_For_Approval__c, All_Primary_Buyer_Same__c,
                                                        All_Joint_Buyer_Same__c,
                                                     (SELECT Id, Unique_Key__c FROM Bookings__r),
                                                     (SELECT Id, Step_Name__c, NSIBPM__Step_Template__c, NSIBPM__Step_Template__r.NSIBPM__Code__c 
                                                      FROM NSIBPM__Steps_SR__r 
                                                      WHERE NSIBPM__Step_Template__r.NSIBPM__Code__c =: 'DOS_APPROVAL' LIMIT 1)
                                                 FROM NSIBPM__Service_Request__c 
                                                 WHERE Id =: srId]){
            dealSr = thisSr;
            break;  
        }   
        return dealSr;
    }
    
    /*********************************************************************************************
    * @Description : Calling method to get inventory details.                                    *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<Id, Inventory__c>                                                       *
    *********************************************************************************************/
    private Map<Id, Inventory__c> getInventoryDetails(Set<Id> inventoryIdsSet){
      Map<Id, Inventory__c> inventoryMap = new Map<Id, Inventory__c>(); 
      for(Inventory__c thisInventory : [SELECT Id, Property__c, Property__r.Name, Building_Location__c,View_Type__c , Unit_Area_sft__c , Brand__c ,Bedroom_Type__c,CM_Price_Per_Sqft__c,
                                                 IPMS_Bedrooms__c, Special_Price_2__c, Marketing_Name__c, 
                                                 Building_Name__c, Property_Name__c, Floor__c, Area_Sqft_2__c,
                                                 Building_Location__r.Building_Name__c, Building_Location__r.Name, 
                                                 Bedrooms__c, Unit__c, Unit_Type__c, Property_Status__c,
                                                 Area__c, Selling_Price__c, Special_Price__c, Price_Per_Sqft__c,
                                                 MD_Price__c, List_Price__c, Property_Country__c, Status__c, 
                                                 Floor_Package_ID__c, Floor_Package_Type__c, List_Price_calc__c, Special_Price_calc__c 
                                          FROM Inventory__c
                                          WHERE Id IN: inventoryIdsSet]){  
          inventoryMap.put(thisInventory.Id, thisInventory);                                    
    }  
    return inventoryMap;
    }
    
    /*********************************************************************************************
    * @Description : Calling method to get payment plan details.                                 *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<String, Payment_Plan__c>                                                *
    *********************************************************************************************/
    private Map<String, Payment_Plan__c> getPaymentPlanDetails(Set<Id> selectedBookingUnitIdsSet){
      Map<String, Payment_Plan__c> bookingUnitPaymentPlanMap = new Map<String, Payment_Plan__c>();
      for(Payment_Plan__c thisPaymentPlan : [SELECT Id, Building_ID__c, Name, Booking_Unit__r.Inventory__c, Building_Location__c, Unique_Key__c,
                              Booking_Unit__c, Parent_Payment_Plan__c, TERM_ID__c,
                            (SELECT Id, Description__c, Milestone_Event__c, Unique_Key__c, 
                                    Milestone_Event_Arabic__c, Percent_Value__c, Modified_Percent_Value__c,
                                    Booking_Unit__c, Line_ID__c 
                             FROM Payment_Terms__r)  
                                     FROM Payment_Plan__c 
                                   WHERE Booking_Unit__c IN: selectedBookingUnitIdsSet
                                   ORDER BY CreatedDate DESC]){
      bookingUnitPaymentPlanMap.put(thisPaymentPlan.Booking_Unit__c, thisPaymentPlan);                                 
    }
    return bookingUnitPaymentPlanMap;  
    }
    
    /*********************************************************************************************
    * @Description : Calling method to get payment plan details.                                 *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<String, Payment_Plan__c>                                                *
    *********************************************************************************************/
    private Map<String, Payment_Plan__c> getSelectedPaymentPlanDetails(Set<Id> selectedPaymentPlanIdsSet){
      Map<String, Payment_Plan__c> paymentPlanMap = new Map<String, Payment_Plan__c>();
      for(Payment_Plan__c thisPaymentPlan : [SELECT Id, Building_ID__c, Name, Booking_Unit__r.Inventory__c, Building_Location__c, Unique_Key__c,
                              Booking_Unit__c, Parent_Payment_Plan__c, TERM_ID__c,
                            (SELECT Id, Description__c, Milestone_Event__c, Unique_Key__c, 
                                    Milestone_Event_Arabic__c, Percent_Value__c, Modified_Percent_Value__c,
                                    Booking_Unit__c, Line_ID__c 
                             FROM Payment_Terms__r)   
                                     FROM Payment_Plan__c 
                                   WHERE Id IN: selectedPaymentPlanIdsSet 
                                   ORDER BY CreatedDate DESC]){
      paymentPlanMap.put(thisPaymentPlan.Id, thisPaymentPlan);                                 
    }
    return paymentPlanMap;  
    }
    
    /*********************************************************************************************
    * @Description : Calling method to get booking details.                                      *
    * @Params      : Set<Id>                                                                     *
    * @Return      : List<Booking__c>                                                            *
    *********************************************************************************************/
    private List<Booking__c> getBookingDetails(Set<Id> bookingIdsSet){
      List<Booking__c> bookingList = new List<Booking__c>();
      for(Booking__c thisBooking : [SELECT Id, Name, Unique_Key__c, Account__c, Booking_Channel__c,
                        (SELECT Id, Name, Booking__c, Date_of_Birth__c, Email__c, First_Name__c, Last_Name__c, 
                            Nationality__c, Passport_Expiry_Date__c, Passport_Number__c, Phone__c, 
                            Primary_Buyer__c, Inquiry__c, First_Name_Read__c, Last_Name_Read__c, 
                            First_Name_Arabic__c, Last_Name_Arabic__c, Otp__c, Address_Line_1__c, 
                                  Address_Line_1_Arabic__c, Address_Line_2__c, Address_Line_2_Arabic__c, Address_Line_3__c, 
                                  Address_Line_3_Arabic__c, Address_Line_4__c, Address_Line_4_Arabic__c, City__c,
                            Country__c, Nationality_Read__c, Passport_Expiry_Date_Read__c, Date_of_Birth_Read__c, 
                            Passport_Number_Read__c, Buyer_Type__c, Unique_Key__c, Is_3rd_Party__c, Account__c,
                            City_Arabic__c, Country_Arabic__c, CR_Number__c, CR_Registration_Expiry_Date__c, 
                            CR_Registration_Place__c, CR_Registration_Place_Arabic__c, Is_Buyer_Verified__c,
                            Nationality_Arabic__c, Organisation_Name__c, Organisation_Name_Arabic__c, Payer__c,
                            Phone_Country_Code__c, Place_of_Issue__c, Place_of_Issue_Arabic__c, Title__c, Title_Arabic__c,
                            Party_ID__c, Status__c, National_ID__c , National_ID_Read__c, Agent__c, Agency__c 
                          FROM Buyers__r WHERE Status__c != 'Inactive' AND Status__c != 'Removed' 
                          ORDER BY Name ASC),
                        (SELECT Id, Name, Deal__c ,Booking__r.Deal_SR__r.Name ,Booking__c, Inventory__c, Payment_Method__c, Registration_ID__c, Requested_Token_Amount__c,
                            Requested_Price__c, Selling_Price__c, Unique_Key__c, Unit_Selling_Price__c, Online_Payment_Party__c,
                            Inventory__r.Building_Location__c, No_of_parking__c, Related_Campaign__c, Related_Promotion__c,
                            CurrencyIsoCode, Property_Country__c, Proof_of_Payment_Submitted__c, Inventory__r.Floor_Package_ID__c, 
                            Inventory__r.Floor_Package_Type__c, Inventory__r.List_Price_calc__c, Inventory__r.Special_Price_calc__c,
                            Unit_Location__c
                          FROM Booking_Units__r WHERE Status__c != 'Removed'
                          ORDER BY CreatedDate ASC) 
                    FROM Booking__c
                    WHERE Id IN: bookingIdsSet 
                    ORDER BY Name DESC]){
        bookingList.add(thisBooking);  
      }  
      return bookingList;
    }
    
    /*********************************************************************************************
    * @Description : Method to validate email address.                                           *
    * @Params      : String                                                                      *
    * @Return      : Boolean                                                                     *
    *********************************************************************************************/
    private static Boolean validateEmailAddress(String email){
      Boolean isValid = true;
      String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
    Pattern MyPattern = Pattern.compile(emailRegex);
      Matcher MyMatcher = MyPattern.matcher(email);
      if (!MyMatcher.matches()){
         isValid = false;
      }  
      return isValid;
    }
    
    /*********************************************************************************************
    * @Description : Method to validate phone numbers.                                           *
    * @Params      : String                                                                      *
    * @Return      : Boolean                                                                     *
    *********************************************************************************************/
    private static Boolean validatePhone(String phone){
      return phone.isNumeric();
    }
    
    /*********************************************************************************************
    * @Description : Method to validate date of birth to be above 21 years.                      *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    private static Boolean validateDateOfBirth(Date dateOfBirth){
      Integer days = dateOfBirth.daysBetween(Date.Today());
        Integer age = Integer.valueOf(days/365);
         return age >= Integer.valueOf(system.Label.Eligible_Age) ? true : false;
    }
    
    /*********************************************************************************************
    * @Description : Method to get all the relevant buyer fields.                                *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    private static Map<String, List<Buyer_Information__mdt>> getBuyerFields(){
      Map<String, List<Buyer_Information__mdt>> buyerFieldsMap = new Map<String, List<Buyer_Information__mdt>>();
      for(Buyer_Information__mdt thisField : [SELECT API_Name__c, Line_Break__c, Section__c, Buyer_Type__c, 
                            Disabled__c, Field_Label__c, Order__c, Required__c,
                            Custom_Style_Class__c 
                         FROM Buyer_Information__mdt 
                         ORDER BY Order__c]){
        if(buyerFieldsMap.containsKey(thisField.Buyer_Type__c)){
          buyerFieldsMap.get(thisField.Buyer_Type__c).add(thisField);
        }else{
          buyerFieldsMap.put(thisField.Buyer_Type__c, new List<Buyer_Information__mdt>{ thisField });
        }
      }
      return buyerFieldsMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to get PC's roadhshow campaign if it exists.                         *
    * @Params      : void                                                                        *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    private String getRoadshowCampaign(){
      String roadshowCampaign;
      for(Assigned_PC__c thisAssignedPc: [SELECT Id, Campaign__c, User__c, Start_Date__c, End_Date__c  
                        FROM Assigned_PC__c 
                        WHERE User__c =: UserInfo.getUserId() AND 
                            Start_Date__c <= TODAY AND 
                            End_Date__c >= TODAY AND 
                            Campaign__r.RecordType.Name = 'Roadshows']){
        roadshowCampaign = thisAssignedPc.Campaign__c;
        break;  
      }  
      return roadshowCampaign;
    }
}// End of class.