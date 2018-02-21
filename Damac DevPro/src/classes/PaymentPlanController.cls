/**************************************************************************************************
* Name               : PaymentPlanController                                                      *
* Description        : This is a controller class for PaymentPlan Component.                      *
* Created Date       : 17/01/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR          DATE            COMMENTS                                              *
* 1.0         NSI             17/01/2017      Initial Draft 
  1.1         Naresh(Accely)  28/06/2017      Add  Method SelectedPromotionMethod  and 
                                              Call Three DroolWebService Class Methods      *                                        *
**************************************************************************************************/
public class PaymentPlanController {
   
  public String errorMessage {get; set;}  
  public String selectedInventory {get; set;}
  public Boolean showError {get; set;}
  public Boolean showPaymentTerms {get; set;}
  public string   AllOption {get;set;}
  public List<DH_PromotionsWrapper> promList {get; set;}
  public Date effectiveFrom {get; set;}
  public Date effectiveTo {get; set;}
  public UtilityWrapperManager uwmObject {get; set;}
  public Decimal tempTotalPaymentTerms {get; set;}
  public Decimal totalDealValue {
    get{
      return totalDealValue != null ? totalDealValue : getTotalDealValue(uwmObject.ibwList);  
    }
    set;
  }
  
  public List<Payment_Terms__c> tempPaymentTerms {get; set;}
  
   public Map<id,DH_PromotionsWrapper> promMap {get{
    return DroolWebService.createOptionsMapforInventories(promList);
  }
  set;
  }
  
  public Map<id,List<selectOption>> optMap{get {
  return DroolWebService.createOptionsForOptMap(promList); }
  set;}
  
  public Map<Id, UtilityWrapperManager.InventoryBuyerWrapper> inventoryBuyerWrapperMap {
    get{
      return inventoryBuyerWrapperMap != null  ? inventoryBuyerWrapperMap : getInventories(uwmObject.ibwList);
    }
    set;
  }
  
  public Set<Id> inventoryIdsList {
    get{
      return inventoryIdsList != null ? inventoryIdsList : getInventories(uwmObject.ibwList).keySet();
    }
    set;
  }
  
  public Map<String, List<SelectOption>> buildingPaymentPlansListMap {
    get{
      return buildingPaymentPlansListMap != null ? buildingPaymentPlansListMap : getPaymentPlanOptions(uwmObject.ibwList);
    }
    set;
  }
  
  public Set<Id> buildingIdsSet {
    get{
      return buildingIdsSet != null ? buildingIdsSet : getBuildings(buildingPaymentPlansListMap.keySet());
    }
    set;
  }
  public List<SelectOption> allPromotionList {get; set;}
  
  /********************************************************************************************* 
    * @Description : Controller class.                                                           *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
  public PaymentPlanController(){
    system.debug('#### Payment Plan Controller');
    try{
      showError = false;
      showPaymentTerms = false;
      tempTotalPaymentTerms = 0.0;
      /* Calling method to the list of available promotion list to select. */
      allPromotionList = new List<SelectOption>(getPromotionList());
    }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
  } 
  
  /***********************************************************************************************
    * @Description : Method to validate payment tersms.                                            *
    * @Params      : void                                                                          *
    * @Return      : void                                                                          *
    ************************************************************************************************/
  public void validatePaymentTerms(){
    Integer totalActualValue = 0;
    Integer totalModifiedValue = 0;
    try{
      if(tempPaymentTerms != null){
        for(Payment_Terms__c thisPaymentTerm : tempPaymentTerms){
          if(String.isNotBlank(thisPaymentTerm.Modified_Percent_Value__c)){
            Integer thisModifiedValue = String.isNotBlank(thisPaymentTerm.Modified_Percent_Value__c) ? 
                                    Integer.valueOf(thisPaymentTerm.Modified_Percent_Value__c) : 0;
            system.debug('#### thisModifiedValue = '+thisModifiedValue);
            if(thisModifiedValue < 5){
              showError = true;
              errorMessage = 'Value cannot be less than 5%.';  
              break;
            }  
            if(thisModifiedValue > 104){
              showError = true;
              errorMessage = 'Value cannot be greater than 104%.';  
              break;
            }
            totalActualValue = totalActualValue + (String.isNotBlank(thisPaymentTerm.Percent_Value__c) ? 
                                  Integer.valueOf(thisPaymentTerm.Percent_Value__c) : 0);
            totalModifiedValue = totalModifiedValue + thisModifiedValue;
          }
        }  
        if(totalActualValue != totalModifiedValue){
          showError = true;
          errorMessage = 'Total of modified values for payment terms should be equal to '+totalActualValue;  
        }
      }  
      if(String.isBlank(errorMessage)){
        showPaymentTerms = false;  
      }
      //showPaymentTerms = showError ? true : false;
      system.debug('#### showPaymentTerms = '+showPaymentTerms);
      system.debug('#### errorMessage = '+errorMessage);
    }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage(); 
            system.debug('#### errorMessage = '+errorMessage);    
        }
  }
  
  /***********************************************************************************************
    * @Description : Method to close payment terms window.                                         *
    * @Params      : void                                                                          *
    * @Return      : void                                                                          *
    ************************************************************************************************/
  public void closePaymentTerms(){
    showPaymentTerms = false;
  }
  
  /*********************************************************************************************
    * @Description : Method to get the avialable promotion list.                                 *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
    public List<SelectOption> getPromotionList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select Promotion -- '));
        for(Promotion__c thisPromotion : [SELECT Id, Name, Promotion_Title__c 
                          FROM Promotion__c 
                          WHERE Start_Date__c <= TODAY AND End_Date__c >= TODAY]){
            if(thisPromotion.Promotion_Title__c != null){
                options.add(new SelectOption(thisPromotion.Id, thisPromotion.Promotion_Title__c));
            }   
        }
        return options;
    }
  
  /***********************************************************************************************
    * @Description : Method to get related payment terms.                                          *
    * @Params      : void                                                                          *
    * @Return      : void                                                                          *
    ************************************************************************************************/
  public void getPaymentTerms(){
    try{
      system.debug('#### selectedInventory = '+selectedInventory); 
      system.debug('#### totalDealValue = '+totalDealValue); 
      if(String.isNotBlank(selectedInventory) && inventoryBuyerWrapperMap.containsKey(selectedInventory)){
        UtilityWrapperManager.InventoryBuyerWrapper thisIbwObject = inventoryBuyerWrapperMap.get(selectedInventory);
        system.debug('#### selectedPaymentPlan = '+thisIbwObject.selectedPaymentPlan); 
        if(String.isNotBlank(thisIbwObject.selectedPaymentPlan)){
          showPaymentTerms = true;
          /* Calling method to the get the payment terms related to selected payment plan. */
          Map<String, Payment_Plan__c> paymentPlanMap = getPaymentPlan(thisIbwObject.selectedPaymentPlan);
          thisIbwObject.inventoryPaymentPlanMap = new Map<String, Payment_Plan__c>();
          thisIbwObject.inventoryPaymentPlanMap.put(thisIbwObject.selectedInventory.Id, paymentPlanMap.get(thisIbwObject.selectedPaymentPlan));
          effectiveFrom = paymentPlanMap.get(thisIbwObject.selectedPaymentPlan).Effective_From__c;
          effectiveTo = paymentPlanMap.get(thisIbwObject.selectedPaymentPlan).Effective_To_calculated__c;
          tempPaymentTerms = new List<Payment_Terms__c> (paymentPlanMap.get(thisIbwObject.selectedPaymentPlan).Payment_Terms__r);
              tempTotalPaymentTerms = 0.0;
              for(Payment_Terms__c thisPaymentTerm : tempPaymentTerms){ 
                if(thisPaymentTerm.Percent_Value__c != null){
                  tempTotalPaymentTerms += Decimal.valueOf(thisPaymentTerm.Percent_Value__c);
                }
              }
        }else{
          thisIbwObject.inventoryPaymentPlanMap = new Map<String, Payment_Plan__c>();  
        }
      }
    }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
  }
  
  /*********************************************************************************************
    * @Description : Calling method to get the available payment plans.                          *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
  public Map<String, List<Payment_Plan__c>> getBuildingPaymentPlans(Set<Id> buildingIdsSet){
    Map<String, List<Payment_Plan__c>> buildingPaymentPlansListMap = new Map<String, List<Payment_Plan__c>>();
    for(Payment_Plan__c thisPaymentPlan : [SELECT Id, Building_ID__c, Name, Building_Location__c, Effective_From__c,
                            Effective_To_calculated__c, TERM_ID__c,
                            (SELECT Id, Description__c, Milestone_Event__c, Line_ID__c,
                                    Milestone_Event_Arabic__c, Percent_Value__c,
                                    Booking_Unit__c, Installment__c, Modified_Percent_Value__c 
                             FROM Payment_Terms__r)  
                                     FROM Payment_Plan__c 
                                   WHERE Building_Location__c IN: buildingIdsSet AND 
                                         Effective_From__c <= TODAY AND 
                                         Effective_To_calculated__c >= TODAY]){
            if(thisPaymentPlan.Building_Location__c != null){
                if(buildingPaymentPlansListMap.containsKey(thisPaymentPlan.Building_Location__c)){
                  buildingPaymentPlansListMap.get(thisPaymentPlan.Building_Location__c).add(thisPaymentPlan);
                }else{
                  buildingPaymentPlansListMap.put(thisPaymentPlan.Building_Location__c, new List<Payment_Plan__c>{thisPaymentPlan});  
                }
            }
        }  
        system.debug('#### buildingPaymentPlansListMap = '+buildingPaymentPlansListMap);
        return buildingPaymentPlansListMap;
  }
  
  /*********************************************************************************************
    * @Description : Calling method to get the available payment terms.                          *
    * @Params      : String                                                                      *
    * @Return      : Map<String, Payment_Plan__c>                                                *
    *********************************************************************************************/
  public Map<String, Payment_Plan__c> getPaymentPlan(String selectedPaymentPlan){
    Map<String, Payment_Plan__c> paymentPlanTermsListMap = new Map<String,Payment_Plan__c>();
    for(Payment_Plan__c thisPaymentPlan :  [SELECT Id, Building_ID__c, Name, Building_Location__c, Effective_From__c,
                            Effective_To_calculated__c, TERM_ID__c,
                            (SELECT Id, Description__c, Milestone_Event__c, Line_ID__c, 
                                    Milestone_Event_Arabic__c, Percent_Value__c,
                                    Booking_Unit__c, Installment__c, Modified_Percent_Value__c 
                             FROM Payment_Terms__r)  
                                     FROM Payment_Plan__c 
                                   WHERE Id =: selectedPaymentPlan AND 
                                         Effective_From__c <= TODAY AND 
                                         Effective_To_calculated__c >= TODAY]){
            if(thisPaymentPlan.Id == selectedPaymentPlan && !thisPaymentPlan.Payment_Terms__r.isEmpty()){
            paymentPlanTermsListMap.put(thisPaymentPlan.Id, thisPaymentPlan);
            }
        }  
        system.debug('#### paymentPlanTermsListMap = '+paymentPlanTermsListMap);
        return paymentPlanTermsListMap;
  }
    
  /*********************************************************************************************
    * @Description : Method to get selected inventory list.                                      *
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
    * @Description : Method to get the total deal value.                                         *
    * @Params      : List<UtilityWrapperManager.InventoryBuyerWrapper>                           *
    * @Return      : Decimal                                                                     *
    *********************************************************************************************/
  @TestVisible private Decimal getTotalDealValue(List<UtilityWrapperManager.InventoryBuyerWrapper> inventoryList){
    Decimal totalDealValue = 0.0;
    Map<Id, UtilityWrapperManager.InventoryBuyerWrapper> valueMap = new Map<Id, UtilityWrapperManager.InventoryBuyerWrapper>();
    if(inventoryList != null && !inventoryList.isEmpty()){
      for(UtilityWrapperManager.InventoryBuyerWrapper thisRecord : inventoryList){
        if(thisRecord.isSelected){ 
          if(thisRecord.selectedInventory.Special_Price_calc__c != null){
            totalDealValue = totalDealValue + thisRecord.selectedInventory.Special_Price_calc__c;  
          }
        }
      }
    }  
    system.debug('   '+totalDealValue);
    return totalDealValue;
  }
  
  /*********************************************************************************************
    * @Description : Method to get selected inventory list.                                      *
    * @Params      : List<UtilityWrapperManager.InventoryBuyerWrapper>                           *
    * @Return      : Set<Id>                                                                     *
    *********************************************************************************************/
  @TestVisible private Set<Id> getBuildings(Set<String> buildingIdsSet){
    Set<Id> valueList = new Set<Id>();
    for(String thisRecord : buildingIdsSet){
        valueList.add(thisRecord);
    }
    return valueList;
  }
  
  /*********************************************************************************************
    * @Description : Method to get payment plans options.                                        *
    * @Params      : List<UtilityWrapperManager.InventoryBuyerWrapper>                           *
    * @Return      : Map<String, List<SelectOption>>                                             *
    *********************************************************************************************/
  @TestVisible private Map<String, List<SelectOption>> getPaymentPlanOptions(List<UtilityWrapperManager.InventoryBuyerWrapper> inventoryList){
    Map<String, List<SelectOption>> buildingPaymentPlansSelectOption = new Map<String, List<SelectOption>>();
    Set<Id> valueList = new Set<Id>();
    if(inventoryList != null && !inventoryList.isEmpty()){
      for(UtilityWrapperManager.InventoryBuyerWrapper thisRecord : inventoryList){
        if(thisRecord.isSelected && thisRecord.selectedInventory.Building_Location__c != null){ 
            valueList.add(thisRecord.selectedInventory.Building_Location__c);    
        }
      }
    }
    if(!valueList.isEmpty()){
      /* Calling method to get payment plans related to the selected buildings. */
      Map<String, List<Payment_Plan__c>> buildingPaymentPlansListMap = getBuildingPaymentPlans(valueList);
      if(!buildingPaymentPlansListMap.keySet().isEmpty()){
          for(String thisKey : buildingPaymentPlansListMap.keySet()){
            List<SelectOption> options = new List<SelectOption>();
          options.add(new SelectOption('', '-- Select a payment plan --'));
            for(Payment_Plan__c thisPaymentPlan : buildingPaymentPlansListMap.get(thisKey)){
                  options.add(new SelectOption(thisPaymentPlan.Id, thisPaymentPlan.Name));
            }  
            buildingPaymentPlansSelectOption.put(thisKey, options);
          }
      }
    }
    return buildingPaymentPlansSelectOption;
  }
  
/**************************************************************************************************************
    * @Description : Method to Get Promotion , Option , Scheme ,Campaign value from PaymentPlan Component .
                     This Value is save on Newly Created Option Object      *
    * @Params      : void                       
    * @Return      : Void                                            
**************************************************************************************************************/
  public void SelectedPromotionMethod(){
  try{
    DroolWebService.SaveOption(AllOption);
    }
    
   catch(Exception Ex){
      System.debug('Error Message Is Option Save  '+Ex.getMessage());
      System.debug('Error Message Is @Line  '+Ex.getLineNumber());
      Log__c objLog = new Log__c();
      objLog.Description__c ='-Line No===>'+Ex.getLineNumber()+'---Message==>'+Ex.getMessage();
      objLog.Type__c = 'Error While Saving Option Records';
      insert objLog;     
     } 
   }
  
}// End of class.