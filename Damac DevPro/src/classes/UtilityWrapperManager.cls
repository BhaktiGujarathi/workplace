/**************************************************************************************************
* Name               : UtilityWrapperManager                                                      *
* Description        : This is a utility class to wrapper classes.                                *
* Created Date       : 17/01/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR          DATE                Comments                                        *
* 1.0         NSI             17/01/2017                                                          *
* 1.1         NSI-Sivasankar  24/02/2017          Added Price Range wrapper                       *
* 1.2         NSI-Sivasankar  06/03/2017          Added InventoryDetailsWrapper for booking       *
**************************************************************************************************/
public class UtilityWrapperManager {
    
    public String value {get; set;}
    public Boolean isSubmitted {get; set;}
    public NSIBPM__Service_Request__c dealRecord {get; set;}
    public List<InventoryBuyerWrapper> ibwList {get; set;} 
    
    /*********************************************************************************************
    * @Description : Wrapper class to handle sharing related data.                               *
    *********************************************************************************************/
    public class SharingWrapper{
        public String objectName;
        public String parentId;
        public String UserOrGroupId;
        public String AccessLevel;
        public String RowCause; 
        
        public SharingWrapper(String objectName, String parentId, String UserOrGroupId, String AccessLevel, String RowCause){
            this.objectName = objectName;
            this.parentId = parentId;   
            this.UserOrGroupId = UserOrGroupId; 
            this.AccessLevel = AccessLevel; 
            this.RowCause = RowCause;   
        }
    } 

    /*********************************************************************************************
    * @Description : Campaign Wrapper.                                                           *
    *********************************************************************************************/
    public class CampaignWrapper{
        public Boolean isPromotionAvailable {get; set;}
        public Campaign__c availableCampaign {get; set;}
        public List<Promotion__c> associatedPromotions {get; set;}
        
        public CampaignWrapper(Boolean isPromotionAvailable, Campaign__c availableCampaign, List<Promotion__c> associatedPromotions){
            this.isPromotionAvailable = isPromotionAvailable;
            this.availableCampaign = availableCampaign;
            this.associatedPromotions = associatedPromotions;
        }
    }
    
    /*********************************************************************************************
    * @Description : Inventory and buyer wrapper.                                                *
    *********************************************************************************************/
    public class InventoryBuyerWrapper{
        public Boolean isSelected {get; set;}
        public Boolean isExistingCustomer {get; set;}
        public Boolean specialPrice {get; set;}
        public Decimal requestedTokenAmount {get; set;}
        public Decimal requestedPrice {get; set;}
        public String selectedPaymentPlan {get; set;}
        public String selectedPaymentMethod {get; set;}
        public String selectedPromotion {get; set;}
        public String onlinePaymentParty {get; set;}
        public Integer numberOfParking {get; set;}
        public Inventory__c selectedInventory {get; set;}
        public Booking_Unit__c bookingUnit {get; set;}
        public Map<String, Payment_Plan__c> inventoryPaymentPlanMap {get; set;}
        public List<Buyer__c> jointBuyerList {get; set;}
        
        public InventoryBuyerWrapper(){ }
        public InventoryBuyerWrapper(Boolean isSelected, 
                                     Boolean isExistingCustomer,
                                     Boolean specialPrice,
                                     Decimal requestedTokenAmount,
                                     Decimal requestedPrice,
                                     String selectedPaymentPlan,
                                     String selectedPaymentMethod,
                                     String selectedPromotion,
                                     String onlinePaymentParty,
                                     Integer numberOfParking, 
                                     Inventory__c selectedInventory,
                                     Booking_Unit__c bookingUnit,
                                     Map<String, Payment_Plan__c> inventoryPaymentPlanMap,
                                     List<Buyer__c> jointBuyerList){
            this.isSelected = isSelected;
            this.isExistingCustomer = isExistingCustomer;
            this.specialPrice = specialPrice;
            this.requestedTokenAmount = requestedTokenAmount;
            this.requestedPrice = requestedPrice;
            this.selectedPaymentPlan = selectedPaymentPlan;
            this.selectedPaymentMethod = selectedPaymentMethod;
            this.selectedPromotion = selectedPromotion;
            this.onlinePaymentParty = onlinePaymentParty;
            this.numberOfParking = numberOfParking;
            this.selectedInventory = selectedInventory;
            this.bookingUnit = bookingUnit;
            this.inventoryPaymentPlanMap = inventoryPaymentPlanMap;
            this.jointBuyerList = jointBuyerList;
        }
    }
    
    /*********************************************************************************************
    * @Description : Inventory and buyer wrapper.                                                *
    *********************************************************************************************/
    public class InventoryDetailsWrapper{
        public String inventoryID {get; set;}
        public String inventory_ID {get; set;}
        public String inventoryStatus {get; set;}
        public String inventoryProperty {get; set;}
        public String inventoryPropertyName {get; set;}
        public String inventoryBuildingLocation {get; set;}
        public String inventoryBuildingLocationName {get; set;}
        public String inventoryBedrooms {get; set;}
        public String inventoryFloor {get; set;}
        public String inventoryUnit {get; set;}
        public String inventoryMarketingName {get; set;}
        public Decimal inventoryArea {get; set;}
        public Decimal inventorySalesPrice {get; set;}
        public Decimal inventorySpecialPrice {get; set;}
        
        /* Wrapper to wrap inventory data in the following order: 
           InventoryId, InventoryId, Inventory Status, Inventory Property Id,
           Inventory Property Name, Inventory Building Location, 
           Inventory Building Location Name, Inventory Bedroom,
           Inventory Floor, Inventory Unit, Inventory Area,
           Inventory Marketing Name, Inventory Sales Price,
           Inventory Special Price. */
        public InventoryDetailsWrapper( String inventoryID,
                                        String inventory_ID,
                                        String inventoryStatus,
                                        String inventoryProperty,
                                        String inventoryPropertyName,
                                        String inventoryBuildingLocation,
                                        String inventoryBuildingLocationName,
                                        String inventoryBedrooms,
                                        String inventoryFloor,
                                        String inventoryUnit,
                                        String inventoryMarketingName,
                                        Decimal inventoryArea,
                                        Decimal inventorySalesPrice,
                                        Decimal inventorySpecialPrice){
            this.inventoryID = inventoryID;
            this.inventory_ID = inventory_ID;
            this.inventoryStatus = inventoryStatus;
            this.inventoryProperty = inventoryProperty;
            this.inventoryPropertyName = inventoryPropertyName;
            this.inventoryBuildingLocation = inventoryBuildingLocation;
            this.inventoryBuildingLocationName = inventoryBuildingLocationName;
            this.inventoryBedrooms = inventoryBedrooms;
            this.inventoryFloor = inventoryFloor;
            this.inventoryUnit = inventoryUnit;
            this.inventoryMarketingName = inventoryMarketingName;
            this.inventoryArea = inventoryArea;
            this.inventorySalesPrice = inventorySalesPrice;
            this.inventorySpecialPrice = inventorySpecialPrice;
        }
    } 
    
    /*********************************************************************************************
    * @Description : Class for storing the Range minimum and max values. for each type           *
    **********************************************************************************************/
    public class PriceRageWrapper {
        public Decimal minPrice {get;set;}
        public Decimal maxPrice {get;set;}

        public PriceRageWrapper(Decimal minVal, Decimal maxVal){
            this.minPrice = minVal;
            this.maxPrice = maxVal;
        }
    }

    /*********************************************************************************************
    * @Description : Class for storing the Building Information                                  *
    **********************************************************************************************/
    public class BuildingInorWrapper {
        public String bedRooms {get;set;}
        public Integer noOfUnits {get;set;}
        public Double mixPercent {get;set;}
        public Decimal minPrice {get;set;}
        public Decimal maxPrice {get;set;}
        public Decimal minAreasqft {get;set;}
        public Decimal maxAreasqft {get;set;}
        public String currencyIsoCode {get;set;}

        public BuildingInorWrapper(String bedRooms, Integer noOfUnits,Double mixPercent,Decimal minPrice,Decimal maxPrice,Decimal minAreasqft,Decimal maxAreasqft, String currencyIsoCode){
            this.bedRooms = bedRooms;
            this.noOfUnits = noOfUnits;
            this.mixPercent = mixPercent;
            this.minPrice = minPrice;
            this.maxPrice = maxPrice;
            this.minAreasqft = minAreasqft;
            this.maxAreasqft = maxAreasqft;
            this.currencyIsoCode = currencyIsoCode;
        }
    }

    /*********************************************************************************************
    * @Description : Class for storing the Booking Status Information                            *
    **********************************************************************************************/
    public class BookingWrapper{
        public String SRName{set;get;}
        public String bookingStatusStep{set;get;} //contains step1,step2,step3,step4 : Id's in UI
        public BookingWrapper(String SRName,String bookingStatusStep){
            this.SRName = SRName;
            this.bookingStatusStep = bookingStatusStep;
        }
    }
}// End of class.