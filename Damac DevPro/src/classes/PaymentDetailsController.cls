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
**************************************************************************************************/
public class PaymentDetailsController {
    
    public String sessionId {get; set;}
    public String selectedInventory {get; set;}
    public String errorMessage {get; set;}  
    public UtilityWrapperManager uwmObject {get; set;}  
    public Map<Id, UtilityWrapperManager.InventoryBuyerWrapper> inventoryBuyerWrapperMap {
        get{
            return inventoryBuyerWrapperMap != null  ? inventoryBuyerWrapperMap : getInventories(uwmObject.ibwList);
        } set{
            inventoryBuyerWrapperMap = inventoryBuyerWrapperMap != null  ? inventoryBuyerWrapperMap : getInventories(uwmObject.ibwList);    
        }
    }
    public Set<Id> inventoryIdsList {
        get{
            return inventoryIdsList != null ? inventoryIdsList : getInventories(uwmObject.ibwList).keySet();
        }set{
            inventoryIdsList = inventoryIdsList != null ? inventoryIdsList : getInventories(uwmObject.ibwList).keySet();    
        }
    }
    public Buyer__c thirdParty {get; set;}
    
    /*********************************************************************************************
    * @Description : Controller class.                                                           *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public PaymentDetailsController(){
        system.debug('#### Payment Details Controller');
        try{
            sessionId = UserInfo.getSessionId();
            thirdParty = new Buyer__c(Is_3rd_Party__c = true);  
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();     
        }
    }  
    
    /*********************************************************************************************
    * @Description : Getter method for payment methods.                                          *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
    public List<SelectOption> getPaymentParty() {
        List<SelectOption> options = new List<SelectOption>();
        if(Booking_Unit__c.getSObjectType() != null && Booking_Unit__c.getSObjectType().getDescribe() != null){
            Map<String, Schema.SObjectField> field_map = Booking_Unit__c.getSObjectType().getDescribe().fields.getMap(); 
            if(field_map.containsKey('Online_Payment_Party__c')){
                List<Schema.PicklistEntry> pick_list_values = field_map.get('Online_Payment_Party__c').getDescribe().getPickListValues();
                for (Schema.PicklistEntry thisValue : pick_list_values) { 
                    options.add(new selectOption(thisValue.getValue(), thisValue.getLabel()));
                }   
            }
        }
        return options;
    }
    
    /*********************************************************************************************
    * @Description : Getter method for payment methods.                                          *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
    public List<SelectOption> getPaymentMethods() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Select a option -- '));
        if(Booking_Unit__c.getSObjectType() != null && Booking_Unit__c.getSObjectType().getDescribe() != null){
            Map<String, Schema.SObjectField> field_map = Booking_Unit__c.getSObjectType().getDescribe().fields.getMap(); 
            if(field_map.containsKey('Payment_Method__c')){
                List<Schema.PicklistEntry> pick_list_values = field_map.get('Payment_Method__c').getDescribe().getPickListValues();
                for (Schema.PicklistEntry thisValue : pick_list_values) { 
                    options.add(new selectOption(thisValue.getValue(), thisValue.getLabel()));
                }   
            }
        }
        return options;
    }
    
    /*********************************************************************************************
    * @Description : Method to save third party details.                                         *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void saveThirdPartyDetails(){
        String uniqueKey = '';
        try{    
            for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory : uwmObject.ibwList){
                if(thisInventory.isSelected && thisInventory.selectedInventory.Id == selectedInventory){
                    if(thisInventory.jointBuyerList != null){
                        uniqueKey = uwmObject.dealRecord.Id;
                        for(Buyer__c thisBuyer : thisInventory.jointBuyerList){
                            uniqueKey = thisBuyer.Passport_Number__c +' - '+ uniqueKey;
                        }
                    }
                }
            }
            if(String.isNotBlank(uniqueKey)){
                for(Booking__c thisBooking : [SELECT Id FROM Booking__c WHERE Unique_Key__c =: uniqueKey]){
                    thirdParty.Booking__c = thisBooking.Id;
                    break; 
                }   
                if(thirdParty.Booking__c != null){
                    insert thirdParty;
                    /* Updating primary buyer's detail on the booking unit, in case 3rd party is selected. */
                    List<Booking_Unit__c> bookingUnitList = new List<Booking_Unit__c>();
                    for(Booking_Unit__c thisBookingUnit : [SELECT Id, Primary_Buyer_s_Email__c, Primary_Buyer_s_Name__c, 
                                                                  Primary_Buyer_Country__c, Primary_Buyer_s_Nationality__c, 
                                                                  Unique_Key__c 
                                                           FROM Booking_Unit__c 
                                                           WHERE Booking__c =: thirdParty.Booking__c]){
                        thisBookingUnit.Primary_Buyer_s_Email__c = thirdParty.Email__c; 
                        thisBookingUnit.Primary_Buyer_s_Name__c = thirdParty.First_Name__c != null ? thirdParty.First_Name__c : thirdParty.Last_Name__c;
                        thisBookingUnit.Primary_Buyer_Country__c = thirdParty.Country__c;    
                        thisBookingUnit.Primary_Buyer_s_Nationality__c = thirdParty.Nationality__c;
                        bookingUnitList.add(thisBookingUnit);
                    }
                    if(!bookingUnitList.isEmpty()){
                        update bookingUnitList;
                    }
                } 
            }
        }catch(Exception ex){
            errorMessage = 'Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage();       
        }   
    }
    
    /*********************************************************************************************
    * @Description : Method to get countries.                                                    *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
    public List<SelectOption> getCountries(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Select a Country -- '));
        if(Buyer__c.getSObjectType() != null && Buyer__c.getSObjectType().getDescribe() != null){
            Map<String, Schema.SObjectField> field_map = Buyer__c.getSObjectType().getDescribe().fields.getMap(); 
            if(field_map.containsKey('Country__c')){
                List<Schema.PicklistEntry> pick_list_values = field_map.get('Country__c').getDescribe().getPickListValues();
                for (Schema.PicklistEntry thisValue : pick_list_values) { 
                    options.add(new selectOption(thisValue.getValue(), thisValue.getLabel()));
                }   
            }
        }
        return options; 
    }
    
    /*********************************************************************************************
    * @Description : Method to get cities/                                                       *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
    public List<SelectOption> getCities(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Select a City -- '));
        if(Buyer__c.getSObjectType() != null && Buyer__c.getSObjectType().getDescribe() != null){
            Map<String, Schema.SObjectField> field_map = Buyer__c.getSObjectType().getDescribe().fields.getMap(); 
            if(field_map.containsKey('City__c')){
                List<Schema.PicklistEntry> pick_list_values = field_map.get('City__c').getDescribe().getPickListValues();
                for (Schema.PicklistEntry thisValue : pick_list_values) { 
                    options.add(new selectOption(thisValue.getValue(), thisValue.getLabel()));
                }   
            }
        }
        return options; 
    }
    
    /*********************************************************************************************
    * @Description : Method to upload proof of payment.                                          *
    * @Params      : String, String, String                                                      *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    @RemoteAction 
    public static String uploadProof(String attachmentBody, String srId, String bookingUnitId, String fileName, String fileType){
        String result = '';
        system.debug('#### attachmentBody = '+attachmentBody);
        try{
            if(String.isNotBlank(srId) && String.isNotBlank(attachmentBody) && 
               attachmentBody.containsIgnoreCase(';base64')){
                Attachment attachmentRecord = new Attachment();
                attachmentRecord.body = EncodingUtil.base64Decode(attachmentBody.subStringAfter(';base64,'));
                attachmentRecord.name = 'Proof of payment - '+fileName;
                attachmentRecord.ContentType = fileType;
                attachmentRecord.ParentId = srId;
                insert attachmentRecord;
                result = 'success';
                system.debug('#### attachmentRecord = '+attachmentRecord);  
            }   
            if(String.isNotBlank(bookingUnitId)){
                Booking_Unit__c updateBookingUnit = new Booking_Unit__c(Id = bookingUnitId, Proof_of_Payment_Submitted__c = true);
                update updateBookingUnit;
            }
        }catch(Exception ex){
            result =  'Unable to upload file : Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage();   
        }
        return result;
    }
    
    /*********************************************************************************************
    * @Description : Method to parse only selected inventories.                                  *
    * @Params      : List<UtilityWrapperManager.InventoryBuyerWrapper>                           *
    * @Return      : Map<Id, UtilityWrapperManager.InventoryBuyerWrapper>                        *
    *********************************************************************************************/
    private Map<Id, UtilityWrapperManager.InventoryBuyerWrapper> getInventories(List<UtilityWrapperManager.InventoryBuyerWrapper> inventoryList){
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
}//End of class.