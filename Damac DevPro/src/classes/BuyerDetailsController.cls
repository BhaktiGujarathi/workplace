/**************************************************************************************************
* Name               : AvailableUnitsController                                                   *
* Description        : Controller class for AvailableUnits component, has below functions.        *
*                       - Get available campaigns list .                                          *
*                       - Associated units to campaign.                                           * 
* Created Date       : 05/02/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      05/02/2017      Initial Draft.                                    *
* 1.1         NSI - Sivasankar  06/03/2017      adding logic for general inventories.             *
**************************************************************************************************/
public class BuyerDetailsController { 
    
    public Boolean showSearchSection {get; set;}
    public Boolean matchingAccountFound {get; set;}
    public String BuyerType{get;set;}
    public String errorMessage {get; set;}  
    public String selectedInventory {get; set;}
    public Integer inventoryPosition {get; set;} 
    public Integer buyerPosition {get; set;}
    public Buyer__c searchAndSelectBuyer {get; set;} 
    public UtilityWrapperManager uwmObject {get; set;}
    public List<BuyerSectionWrapper> lstBuyerInfoSections{get; set;}
    public Map<String, list<BuyerSectionWrapper>> buyerTypeSectionMap {get; set;}
    public Integer totalInventorySelected {
    	get{
    		return inventoryIdsList != null ? inventoryIdsList.size() : getInventories(uwmObject.ibwList).keySet().size(); 	
    	} 
    	set;
    }
    public Set<Id> inventoryIdsList {
        get{
			return inventoryIdsList != null ? inventoryIdsList : getInventories(uwmObject.ibwList).keySet();
		}
		set;
    }
    public Map<Id, UtilityWrapperManager.InventoryBuyerWrapper> inventoryBuyerWrapperMap {
        get{
            return inventoryBuyerWrapperMap != null  ? inventoryBuyerWrapperMap : getInventories(uwmObject.ibwList);
        } 
        set;
    }
    
    public List<String> buyerFields {get; set;}
    public String tibitsBuyerMapJson {get; set;}
    public String buyerInquiryMappingJson {get; set;}  	
	public String buyerCorporateMappingJson {get; set;}
	public String buyerPersonAccountMappingJson {get; set;}
	
	/*********************************************************************************************
    * @Description : Method to initialize.                                                       *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	@TestVisible private void init(){
		BuyerType = 'Individual';
		showSearchSection = false;
		matchingAccountFound = false;
    	searchAndSelectBuyer = new Buyer__c();
    	buyerFields = new List<String>();
	}
	
    /*********************************************************************************************
    * @Description : Controller class.                                                           *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public BuyerDetailsController(){
    	system.debug('#### Buyer Details Controller');
        try{
        	init();
        	/* Calling method to prepare form fields based on the buyer type. */
        	PrepareBuyerFields();
        	/* Calling method to prepare the auto-population mapping. */
        	getBuyerSearchFieldsMapping();
        	/* Calling method to prepare the tibits and buyer mapping. */
        	getTibitsBuyerFieldsMapping();
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    } 
    
    /*********************************************************************************************
    * @Description : Method to get title                                                         *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
    public List<SelectOption> getBuyerTypes(){
    	List<SelectOption> options = new List<SelectOption>();
        if(Buyer__c.getSObjectType() != null && Buyer__c.getSObjectType().getDescribe() != null){
        	Map<String, Schema.SObjectField> field_map = Buyer__c.getSObjectType().getDescribe().fields.getMap(); 
        	if(field_map.containsKey('Buyer_Type__c')){
				List<Schema.PicklistEntry> pick_list_values = field_map.get('Buyer_Type__c').getDescribe().getPickListValues();
				for (Schema.PicklistEntry thisValue : pick_list_values) { 
					options.add(new selectOption(thisValue.getValue(), thisValue.getLabel()));
				}	
        	}
        }
        return options;	
    }
    
    /*********************************************************************************************
    * @Description : Method to get tibits buyer mapping.                                         *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private void getTibitsBuyerFieldsMapping(){
    	Map<String, TibitsBuyerWrapper> tibitsBuyerMap = new Map<String, TibitsBuyerWrapper>();
    	for(Tibits_Buyer_Mapping__mdt thisMapping : [SELECT Id, Buyer_Field__c, Date_Type__c, Tibits_Field__c, Buyer_Hidden_Field__c 
													 FROM Tibits_Buyer_Mapping__mdt]){
			tibitsBuyerMap.put(thisMapping.Tibits_Field__c, new TibitsBuyerWrapper(thisMapping.Tibits_Field__c, thisMapping.Buyer_Field__c, thisMapping.Buyer_Field__c));											 	
		}	
		tibitsBuyerMapJson = JSON.serialize(tibitsBuyerMap);
    }
    
    /*********************************************************************************************
    * @Description : Method to get buyer search fields mapping.                                  *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
 	@TestVisible private void getBuyerSearchFieldsMapping(){ 
    	Map<String, String> buyerInquiryMapping = new Map<String, String>();  	
		Map<String, String> buyerCorporateMapping = new Map<String, String>();
		Map<String, String> buyerPersonAccountMapping = new Map<String, String>();
    	for(Inquiry_Conversion_Mapping__c thisMapping : [SELECT Id, Name, Business_Account_Field_Name__c, Business_Contact_Field_Name__c, 
    															Person_Account_Field_Name__c, Buyer__c, Order__c 
    													 FROM Inquiry_Conversion_Mapping__c 
    													 WHERE Order__c != null
    													 ORDER BY Order__c]){
			if(String.isNotBlank(thisMapping.Buyer__c)){
				buyerFields.add(thisMapping.Buyer__c);
				/* Creating a map of buyer and inquiry fields. */
				if(String.isNotBlank(thisMapping.Name)){
					buyerInquiryMapping.put(thisMapping.Buyer__c, thisMapping.Name);	
				}    
				/* Creating a map of buyer and business account fields. */													 	
	    		if(String.isNotBlank(thisMapping.Business_Contact_Field_Name__c)){
	    			buyerCorporateMapping.put(thisMapping.Buyer__c, thisMapping.Business_Contact_Field_Name__c);
	    		}else if(String.isNotBlank(thisMapping.Business_Account_Field_Name__c)){
	    			buyerCorporateMapping.put(thisMapping.Buyer__c, thisMapping.Business_Account_Field_Name__c);	
	    		}	
	    		/* Creating a map of buyer and person account fields. */
	    		if(String.isNotBlank(thisMapping.Person_Account_Field_Name__c)){
					buyerPersonAccountMapping.put(thisMapping.Buyer__c, thisMapping.Person_Account_Field_Name__c);	
				} 	
			}
    	}	
    	buyerInquiryMappingJson = JSON.serialize(buyerInquiryMapping);
    	buyerCorporateMappingJson = JSON.serialize(buyerCorporateMapping);
    	buyerPersonAccountMappingJson = JSON.serialize(buyerPersonAccountMapping);
    }
    
    /*********************************************************************************************
    * @Description : Method to get buyer fields to be displayed on the page based on selection.  *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void PrepareBuyerFields(){
    	buyerTypeSectionMap = new Map<String, list<BuyerSectionWrapper>>();
    	Map<String, List<BuyerFieldsWrapper>> IndividualMapSections = new Map<String, List<BuyerFieldsWrapper>>();
    	Map<String, List<BuyerFieldsWrapper>> CorporateMapSections = new Map<String, List<BuyerFieldsWrapper>>();
		for(Buyer_Information__mdt BI : [SELECT API_Name__c, Line_Break__c, Section__c, Buyer_Type__c, 
												Disabled__c, Field_Label__c, Order__c, Required__c,
												Custom_Style_Class__c 
										 FROM Buyer_Information__mdt 
										 WHERE Section__c != null 
										 ORDER BY Order__c]){
			BuyerFieldsWrapper obj = new BuyerFieldsWrapper();
			obj.FieldName = BI.API_Name__c;
			obj.FieldClass = BI.API_Name__c;
			obj.FieldLabel = BI.Field_Label__c;
			obj.iOrder = integer.valueof(BI.Order__c);
			obj.bRequired = BI.Required__c;
			obj.bDisabled = BI.Disabled__c;
			obj.LineBreak = BI.Line_Break__c;
			obj.LineBreakTag = '</div><div class="slds-form-element__row slds-size--3-of-4 row">';
			obj.SearchLineBreakTag = '</div><div class="slds-form-element__row slds-size--1-of-1 row">';
			obj.customStyleClass = BI.Custom_Style_Class__c;
			if(String.isNotBlank(BI.Buyer_Type__c) && BI.Buyer_Type__c.equalsIgnoreCase('Individual')){
				if(IndividualMapSections.containsKey(BI.Section__c)){
					IndividualMapSections.get(BI.Section__c).add(obj);		
				}else{
					IndividualMapSections.put(BI.Section__c, new List<BuyerFieldsWrapper>{obj});	
				}
			}else if(String.isNotBlank(BI.Buyer_Type__c) && BI.Buyer_Type__c.equalsIgnoreCase('Corporate')){
				if(CorporateMapSections.containsKey(BI.Section__c)){
					CorporateMapSections.get(BI.Section__c).add(obj);		
				}else{
					CorporateMapSections.put(BI.Section__c, new List<BuyerFieldsWrapper>{obj});	
				}
			}
		}
		List<BuyerSectionWrapper> individualSectionFields = new List<BuyerSectionWrapper>();
		List<BuyerSectionWrapper> corporateSectionFields = new List<BuyerSectionWrapper>();
		BuyerSectionWrapper objwrap = new BuyerSectionWrapper();
		objwrap.SectionTitle = 'Individual Details';
		objwrap.lstSectionFieldInfo.addAll(IndividualMapSections.get('Individual Details'));
		individualSectionFields.add(objwrap); 
    	buyerTypeSectionMap.put('Individual', individualSectionFields);
    	
		objwrap = new BuyerSectionWrapper();
		objwrap.SectionTitle = 'Organization Details';
		objwrap.lstSectionFieldInfo.addAll(CorporateMapSections.get('Organization Details'));
		corporateSectionFields.add(objwrap);
    	corporateSectionFields.addAll(individualSectionFields);
    	buyerTypeSectionMap.put('Corporate', corporateSectionFields);
    	/* Calling method to update the buyer type of other buyers. */
    	//updateJointBuyers();
    }
    
    /*********************************************************************************************
    * @Description : Method to update the buyer type of joint buyers in case the buyer type .    *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void updateJointBuyers(){
    	Buyer__c primaryBuyer = new Buyer__c();		
        try{
            if(inventoryBuyerWrapperMap != null && !inventoryBuyerWrapperMap.isEmpty()){
            	UtilityWrapperManager.InventoryBuyerWrapper thisRecord = inventoryBuyerWrapperMap.values()[inventoryPosition];
        		for(Buyer__c thisBuyer : thisRecord.jointBuyerList){
        			if(thisBuyer.Primary_Buyer__c){
						primaryBuyer = thisBuyer; 	
					}	
        		}
            	String buyerType = primaryBuyer != null && String.isNotBlank(primaryBuyer.Buyer_Type__c) ? primaryBuyer.Buyer_Type__c : 'Indivdual';
				if(thisRecord.isSelected){
					for(Buyer__c thisBuyer : thisRecord.jointBuyerList){
						if(!thisBuyer.Primary_Buyer__c){
							thisBuyer.Buyer_Type__c = buyerType;  				
						}
					}
				}
			}	
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }	
    }
    
    /*********************************************************************************************
    * @Description : Method to add joint buyers.                                                 *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void addJointBuyer(){
    	Buyer__c primaryBuyer = new Buyer__c();			
        try{
            if(inventoryBuyerWrapperMap != null && !inventoryBuyerWrapperMap.isEmpty()){
            	for(UtilityWrapperManager.InventoryBuyerWrapper thisRecord : inventoryBuyerWrapperMap.values()){
            		if(thisRecord.isSelected && thisRecord.selectedInventory.Id == selectedInventory){
                		for(Buyer__c thisBuyer : thisRecord.jointBuyerList){
                			if(thisBuyer.Primary_Buyer__c){
    							primaryBuyer = thisBuyer; 	
    						}	
                		}
            		}
            	}
            	String buyerType = primaryBuyer != null && String.isNotBlank(primaryBuyer.Buyer_Type__c) ? primaryBuyer.Buyer_Type__c : 'Individual';
				for(UtilityWrapperManager.InventoryBuyerWrapper thisRecord : inventoryBuyerWrapperMap.values()){
					if(thisRecord.isSelected && thisRecord.selectedInventory.Id == selectedInventory){
						thisRecord.jointBuyerList.add(new Buyer__c(Buyer_Type__c = buyerType, Booking__c = primaryBuyer.Booking__c));  
					}
				}
			}	
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to remove joint buyers.                                              *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void removeJointBuyer(){
    	List<Buyer__c> deleteBuyerList = new List<Buyer__c>();
    	List<Buyer__c> updateBuyerList = new List<Buyer__c>();
        try{
            if(buyerPosition != null && inventoryBuyerWrapperMap != null && !inventoryBuyerWrapperMap.isEmpty()){
				for(UtilityWrapperManager.InventoryBuyerWrapper thisRecord : inventoryBuyerWrapperMap.values()){
					if(thisRecord.isSelected && thisRecord.selectedInventory.Id == selectedInventory){
						thisRecord.jointBuyerList[buyerPosition].Status__c = 'Removed';
						updateBuyerList.add(thisRecord.jointBuyerList[buyerPosition]);
						thisRecord.jointBuyerList.remove(buyerPosition);  
					}
				}
			}	
			if(!updateBuyerList.isEmpty()){
				update updateBuyerList;	
			}
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to populate same primary buyer.                                      *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void populateSamePrimaryBuyers(){
    	errorMessage = '';
    	String firstUnit;
    	UtilityWrapperManager.InventoryBuyerWrapper firstUnitWrapper;
    	try{
    		List<UtilityWrapperManager.InventoryBuyerWrapper> selectedInventoryList = new List<UtilityWrapperManager.InventoryBuyerWrapper>(inventoryBuyerWrapperMap.values());
    		firstUnit = selectedInventoryList[0].selectedInventory.Unit__c;
    		firstUnitWrapper = selectedInventoryList[0];
    		String message = PropertyBookingController.validateBuyerFields(new List<UtilityWrapperManager.InventoryBuyerWrapper>{firstUnitWrapper}, true, false);
        	system.debug('#### message = '+message);
        	if(String.isNotBlank(message) && message.equalsIgnoreCase('success')){
	    		if(selectedInventoryList[0].jointBuyerList[0] != null){
		    		for(Integer counter = 1; counter < selectedInventoryList.size(); counter++){
						Buyer__c thisPrimaryBuyer = selectedInventoryList[counter].jointBuyerList[0];
						if(thisPrimaryBuyer.get('Primary_Buyer__c') != null && Boolean.valueOf(thisPrimaryBuyer.get('Primary_Buyer__c'))){
							if(uwmObject.dealRecord.All_Primary_Buyer_Same__c){
								thisPrimaryBuyer.put('Account__c', selectedInventoryList[0].jointBuyerList[0].get('Account__c'));
								thisPrimaryBuyer.put('Inquiry__c', selectedInventoryList[0].jointBuyerList[0].get('Inquiry__c'));
								thisPrimaryBuyer.put('Party_ID__c', selectedInventoryList[0].jointBuyerList[0].get('Party_ID__c'));
								thisPrimaryBuyer.put('Booking__c', selectedInventoryList[0].jointBuyerList[0].get('Booking__c'));
								thisPrimaryBuyer.put('Buyer_Type__c', selectedInventoryList[0].jointBuyerList[0].get('Buyer_Type__c'));
								thisPrimaryBuyer.put('Id', selectedInventoryList[0].jointBuyerList[0].get('Id')); // This cannot be done as for multiple units the pb's can be same but jb's can vary
								for(String thisBuyerField : buyerFields){ 
									thisPrimaryBuyer.put(thisBuyerField, selectedInventoryList[0].jointBuyerList[0].get(thisBuyerField));		
								}	
							}else{
								thisPrimaryBuyer.clear();
								thisPrimaryBuyer.put('Primary_Buyer__c', true);
							}
						}
					}	
	    		}else{
	    			uwmObject.dealRecord.All_Primary_Buyer_Same__c = false;
	    			errorMessage = 'Please enter the primary buyer detail for : '+firstUnit+', before making the all primary buyers same selection.';
	    		}
        	}else{
        		uwmObject.dealRecord.All_Primary_Buyer_Same__c = false;
        		errorMessage = message;
        	}
    		system.debug('#### errorMessage = '+errorMessage);	
    	}catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to populate same joint buyer.                                        *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void populateSameJointBuyers(){
    	errorMessage = '';
    	String firstUnit;
    	UtilityWrapperManager.InventoryBuyerWrapper firstUnitWrapper;
    	List<sObject> buyersList = new List<sObject>();
    	try{
    		List<UtilityWrapperManager.InventoryBuyerWrapper> selectedInventoryList = new List<UtilityWrapperManager.InventoryBuyerWrapper>(inventoryBuyerWrapperMap.values());
    		firstUnit = selectedInventoryList[0].selectedInventory.Unit__c;
    		firstUnitWrapper = selectedInventoryList[0];
    		for(Buyer__c thisBuyer : selectedInventoryList[0].jointBuyerList){ 
    			buyersList.add(thisBuyer);
    		}
    		String message = PropertyBookingController.validateBuyerFields(new List<UtilityWrapperManager.InventoryBuyerWrapper>{firstUnitWrapper}, false, true);
        	if(String.isNotBlank(message) && message.equalsIgnoreCase('success')){
	    		if(buyersList != null && buyersList.size() > 1){
					for(Integer counter = 1; counter < selectedInventoryList.size(); counter++){
						if(buyersList.size() == selectedInventoryList[counter].jointBuyerList.size()){
			    			for(Integer buyerCounter = 1; buyerCounter < selectedInventoryList[counter].jointBuyerList.size(); buyerCounter++){
								Buyer__c thisJointBuyer = selectedInventoryList[counter].jointBuyerList[buyerCounter];
								if(thisJointBuyer.get('Primary_Buyer__c') == null){
									if(uwmObject.dealRecord.All_Joint_Buyer_Same__c){ 
										thisJointBuyer.put('Account__c', buyersList[buyerCounter].get('Account__c'));
										thisJointBuyer.put('Inquiry__c', buyersList[buyerCounter].get('Inquiry__c'));
										thisJointBuyer.put('Party_ID__c', buyersList[buyerCounter].get('Party_ID__c'));
										thisJointBuyer.put('Booking__c', buyersList[buyerCounter].get('Booking__c'));
										thisJointBuyer.put('Buyer_Type__c', buyersList[buyerCounter].get('Buyer_Type__c'));
										thisJointBuyer.put('Id', buyersList[buyerCounter].get('Id'));
										for(String thisBuyerField : buyerFields){
											thisJointBuyer.put(thisBuyerField, buyersList[buyerCounter].get(thisBuyerField));		
										}
									}else{
										thisJointBuyer.clear();	
									}
								}
							}
						}else{
							uwmObject.dealRecord.All_Joint_Buyer_Same__c = false;
	    					errorMessage = 'Number of joint buyer is not same for one or more units.'; 	
	    					break;
	    				}
					}	
	    		}else{
	    			uwmObject.dealRecord.All_Joint_Buyer_Same__c = false;
	    			errorMessage = 'Please enter the joint buyer detail for : '+firstUnit+', before making the all joint buyers same selection.';
	    		}	
        	}else{
        		uwmObject.dealRecord.All_Joint_Buyer_Same__c = false;
        		errorMessage = message;	
        	}
        	system.debug('#### errorMessage = '+errorMessage);
    	}catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to get open the inquiry search and account search box.               *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void openSearchSection(){
    	showSearchSection = true;
    	searchAndSelectBuyer = new Buyer__c(Primary_Buyer__c = buyerPosition == 0 ? true : false, Buyer_Type__c = BuyerType);
    	if(String.isNotBlank(BuyerType) && buyerTypeSectionMap.containsKey(BuyerType)){
    		lstBuyerInfoSections = new List<BuyerSectionWrapper>(buyerTypeSectionMap.get(BuyerType));		
    	} 
    }
    
    /*********************************************************************************************
    * @Description : Method to close the inquiry search and account search box.                  *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void closeSearchSection(){
    	showSearchSection = false;
    }
    
    /*********************************************************************************************
    * @Description : Method to add joint buyers.                                                 *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void saveExistingBuyerDetails(){
    	try{
    		system.debug('#### inventoryPosition = '+inventoryPosition);
    		system.debug('#### buyerPosition = '+buyerPosition);
	    	if(inventoryPosition != null && buyerPosition != null && inventoryPosition <= uwmObject.ibwList.size()){ 
	    		if(String.isNotBlank(searchAndSelectBuyer.Account__c ) || String.isNotBlank(searchAndSelectBuyer.Inquiry__c)){
	    			uwmObject.ibwList[inventoryPosition].jointBuyerList[buyerPosition] = searchAndSelectBuyer;	
	    		}
	    		showSearchSection = false;
	    		system.debug('#### buyer '+String.valueOf(uwmObject.ibwList[inventoryPosition].jointBuyerList[buyerPosition]));
	        } 	
        }catch(Exception ex){ 
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
            system.debug('#### errorMessage = '+errorMessage);
        }
    }
   
    /*********************************************************************************************
    * @Description : Search for an customer in salesforce for the passport and nationality.      *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/   
   	public void searchForExistingAccount(){
   		String passportNumber;
   		String nationality;
   		Map<String, String> buyerPersonAccountMapping = (Map<String, String>)JSON.deserialize(buyerPersonAccountMappingJson, Map<String, String>.class); 
   		if(inventoryPosition != null && buyerPosition != null && inventoryPosition <= uwmObject.ibwList.size()){
   			passportNumber = uwmObject.ibwList[inventoryPosition].jointBuyerList[buyerPosition].Passport_Number__c;
    		nationality = uwmObject.ibwList[inventoryPosition].jointBuyerList[buyerPosition].Nationality__c = searchAndSelectBuyer.Nationality__c;	
    		if(String.isNotBlank(passportNumber) && String.isNotBlank(nationality)){
    			/* Calling method to search in account. */
    			Account searchedAccount = searchExistingAccount(passportNumber, nationality);	
    			if(searchedAccount != null){
    				matchingAccountFound = true;	
    				for(String thisKey : buyerPersonAccountMapping.keySet()){
    					uwmObject.ibwList[inventoryPosition].isExistingCustomer = true;
    					uwmObject.ibwList[inventoryPosition].jointBuyerList[buyerPosition].put(thisKey, searchedAccount.get(buyerPersonAccountMapping.get(thisKey)));	
    				}
    			}
    		}
   		}
   	}
   
	/*********************************************************************************************
    * @Description : Method to search customer based on passport number and nationality.         *
    * @Params      : String, String                                                              *
    * @Return      : CustomerWrapper                                                             *
    *********************************************************************************************/   
    @RemoteAction 
    public static Account searchExistingCustomer(String passportNumber, String nationality){
    	/* Calling method to search in account. */
    	Account searchedAccount = searchExistingAccount(passportNumber, nationality);	
    	return searchedAccount;
    }
    
    /*********************************************************************************************
    * @Description : Method to get existing inquiries in the system.                             *
    * @Params      : String                                                                      *
    * @Return      : List<Inquiry__c>                                                            *
    *********************************************************************************************/
    @RemoteAction 
    public static List<Inquiry__c> getCustomerRelatedInquiry(String searchKey){
    	List<Inquiry__c> inquiryList = new List<Inquiry__c>();
    	Id inquiryRecordTypeId = Schema.SObjectType.Inquiry__c.getRecordTypeInfosByName().get(DAMAC_Constants.INQUIRY_RT).getRecordTypeId();
    	for(Inquiry__c thisInquiry : [SELECT Id, First_Name__c, First_Name_Arabic__c, Last_Name__c, Last_Name_Arabic__c, 
    										 Nationality__c, Nationality_Arabic__c, Passport_Number__c, Passport_Expiry_Date__c, 
    										 Passport_Place_of_Issue__c, Passport_Place_of_Issue_Arabic__c, Email__c, Date_of_Birth__c, 
    										 Mobile_CountryCode__c, Mobile_Phone__c, Mobile_Phone_Encrypt__c, Address_Line_1__c, Address_Line_1_Arabic__c, 
    										 City__c, City_Arabic__c, Country__c, Country_Arabic__c
        	            			  FROM Inquiry__c 
	        	            		  WHERE OwnerId =: UserInfo.getUserId() AND
	        	            		  		RecordTypeId =: inquiryRecordTypeId AND
	        	            		  		(Inquiry_Status__c =: DAMAC_Constants.INQUIRY_ACTIVE_STATUS OR
                                             Inquiry_Status__c =: DAMAC_Constants.INQUIRY_NEW_STATUS) AND  
	        	            		  		((First_Name__c != null AND First_Name__c LIKE: '%'+searchKey+'%') OR 
	        	            				 (Last_Name__c != null AND Last_Name__c LIKE: '%'+searchKey+'%') OR 
	        	            				 (Organisation_Name__c != null AND Organisation_Name__c LIKE: '%'+searchKey+'%'))]){
    		inquiryList.add(thisInquiry);	
    	}	
    	return inquiryList;
    }
    
    /*********************************************************************************************
    * @Description : Method to get any existing customer in the system.                          *
    * @Params      : String                                                                      *
    * @Return      : List<Account>                                                               *
    *********************************************************************************************/
    @RemoteAction  
    public static List<Account> getCustomerRelatedAccount(String searchKey, String customerType){
    	List<Account> accountList = new List<Account>();
    	Boolean isPersonAccount = String.isNotBlank(customerType) && customerType.equalsIgnoreCase('Individual') ? true : false;
    	String recordTypeName = String.isNotBlank(customerType) && customerType.equalsIgnoreCase('Individual') ? 'Person Account' : 'Business Account';
    	for(Account thisAccount : [SELECT Id, OwnerId, Name, Name_Arabic__c, FirstName, LastName, PersonMobilePhone, PersonEmail, Address_Line_1__c, 
    									  Address_Line_1_Arabic__c, Address_Line_2__c, Address_Line_2_Arabic__c, Address_Line_3__c, 
    									  Address_Line_3_Arabic__c, Address_Line_4__c, Address_Line_4_Arabic__c, PersonContactId, 
    									  Party_ID__c, isPersonAccount
								   FROM Account 
								   WHERE OwnerId =: UserInfo.getUserId() AND 
								   		 isPersonAccount =: isPersonAccount AND 
								   		 RecordType.Name =: recordTypeName AND
								   		 ((FirstName != null AND FirstName LIKE: '%'+searchKey+'%') OR 
    	            				      (LastName != null AND LastName LIKE: '%'+searchKey+'%') OR 
    	            				      (Name != null AND Name LIKE: '%'+searchKey+'%') OR
    	            				      (Passport_Number__pc != null AND Passport_Number__pc LIKE: '%'+searchKey+'%'))]){
    			accountList.add(thisAccount);	
    		}	
    	return accountList;
    }
    
    /*********************************************************************************************
    * @Description : Method to validate buyers.                                                  *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Boolean                                                                     *
    *********************************************************************************************/
    @RemoteAction 
    public static Boolean validateBuyers(Set<Id> buyerIdsSet){
    	Boolean unverifiedBuyer = false;
    	if(!buyerIdsSet.isEmpty()){
    		List<Buyer__c> updateBuyerList = new List<Buyer__c>();
    		for(Buyer__c thisBuyer : [SELECT Id, Is_Buyer_Verified__c, Phone__c, First_Name__c, OTP__c 
    								  FROM Buyer__c 
    								  WHERE Id IN: buyerIdsSet]){
    			if(!thisBuyer.Is_Buyer_Verified__c){
    				unverifiedBuyer = true;
    			}
    		}	
    	}
    	return unverifiedBuyer;
    }
    
    /*********************************************************************************************
    * @Description : Method to search customer based on passport number and nationality.         *
    * @Params      : String, String                                                              *
    * @Return      : Account                                                                     *
    *********************************************************************************************/
    @TestVisible private static Account searchExistingAccount(String passportNumber, String nationality){
    	Account searchedAccount;
    	String queryString;
    	if(String.isNotBlank(passportNumber) && String.isNotBlank(nationality)){
    		queryString = 'SELECT Id, OwnerId ';
    		for(Inquiry_Conversion_Mapping__c thisMapping : [SELECT Id, Name, Business_Account_Field_Name__c, Business_Contact_Field_Name__c, 
	    															Person_Account_Field_Name__c, Buyer__c, Order__c 
	    													 FROM Inquiry_Conversion_Mapping__c 
	    													 WHERE Order__c != null
	    													 ORDER BY Order__c]){
    			if(String.isNotBlank(thisMapping.Person_Account_Field_Name__c)){
    				queryString = queryString +', '+thisMapping.Person_Account_Field_Name__c; 	
    			}
    		}
    		queryString = queryString +' FROM Account '+
    								   'WHERE isPersonAccount = true AND '+
    										  'Passport_Number__pc =: passportNumber AND '+
    										  'Nationality__pc =: nationality';
    		system.debug('#### queryString = '+queryString);
    		if(String.isNotBlank(queryString)){
    			for(Account thisAccount : Database.query(queryString)){
	    			searchedAccount = thisAccount;	
	    			break;	
	    		}	
    		}
    	}	
    	return searchedAccount;
    }
    
    /*********************************************************************************************
    * @Description : Method to set inventory values based on the previous page.                  *
    * @Params      : List<UtilityWrapperManager.InventoryBuyerWrapper>                           *
    * @Return      : Map<Id, UtilityWrapperManager.InventoryBuyerWrapper>                        *
    *********************************************************************************************/
    @TestVisible private Map<Id, UtilityWrapperManager.InventoryBuyerWrapper> getInventories(List<UtilityWrapperManager.InventoryBuyerWrapper> inventoryList){
		Map<Id, UtilityWrapperManager.InventoryBuyerWrapper> valueMap = new Map<Id, UtilityWrapperManager.InventoryBuyerWrapper>();
		if(inventoryList != null && !inventoryList.isEmpty()){
			for(UtilityWrapperManager.InventoryBuyerWrapper thisRecord : inventoryList){
				if(thisRecord.isSelected){
					valueMap.put(thisRecord.selectedInventory.Id, thisRecord);
				}
			}
		}	
		return valueMap;
	}
    
    /*********************************************************************************************
    * @Description : Tibits Buyer Fields Mapping Wrapper.                                        *
    *********************************************************************************************/
    public class TibitsBuyerWrapper{
    	public String tibitsField {get; set;}
    	public String buyerField {get; set;}
    	public String buyerHiddenField {get; set;}
    	public TibitsBuyerWrapper(String tibitsField, String buyerField, String buyerHiddenField){
    		this.tibitsField = tibitsField;
    		this.buyerField = buyerField;
    		this.buyerHiddenField = buyerHiddenField;	
    	}
    }
    
    /*********************************************************************************************
    * @Description : Buyer Section Fields Wrapper.                                               *
    *********************************************************************************************/
    public class BuyerSectionWrapper{
    	public String SectionTitle {get; set;}
    	public List<BuyerFieldsWrapper> lstSectionFieldInfo {get; set;}
    	public BuyerSectionWrapper(){
    		lstSectionFieldInfo = new List<BuyerFieldsWrapper>();
    	}
    }
    
    /*********************************************************************************************
    * @Description : Buyer Fields Wrapper.                                                       *
    *********************************************************************************************/
    public class BuyerFieldsWrapper{
    	public String FieldName {get; set;}
    	public String FieldClass {get; set;}
    	public String FieldLabel {get; set;}
    	public String LineBreakTag {get; set;}
    	public String SearchLineBreakTag {get; set;}
    	public String customStyleClass {get; set;}
    	public Integer iOrder {get; set;}
    	public Boolean bRequired {get; set;}
    	public Boolean bDisabled {get; set;}
    	public Boolean LineBreak {get; set;}
    }
    
	/*********************************************************************************************
    * @Description : Wrapper class to contain customer data.                                     *
    *********************************************************************************************/
	public class CustomerWrapper{
		public String firstName; 
		public String firstNameArabic; 
		public String lastName;
		public String lastNameArabic; 
		public String email;
		public String phoneCountryCode;
		public String phoneNumber;
		public String passportNumber;
		public String nationality;
		public String accountId;
		public String inquiryId;
		public Boolean accountExists;
		public Date passportExpiryDate;
		public Date dateOfBirth;
		
		public CustomerWrapper(String firstName, String firstNameArabic, String lastName, 
							   String lastNameArabic, String email, String phoneNumber,
							   String phoneCountryCode, String passportNumber, String nationality, 
							   String accountId, String inquiryId, Boolean accountExists, 
							   Date passportExpiryDate, Date dateOfBirth){
			this.firstName = firstName;
			this.firstNameArabic = firstNameArabic;
			this.lastName = lastName;
			this.lastNameArabic = lastNameArabic;
			this.email = email;
			this.phoneCountryCode = phoneCountryCode;
			this.phoneNumber = phoneNumber;
			this.passportNumber = passportNumber;
			this.nationality = nationality;
			this.accountId = accountId;
			this.inquiryId = inquiryId;
			this.accountExists = accountExists;
			this.passportExpiryDate = passportExpiryDate;
			this.dateOfBirth = dateOfBirth;
		}	
	}
}// End of class.