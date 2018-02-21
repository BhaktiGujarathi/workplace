/**************************************************************************************************
* Name               : UtilityWrapperManagerTest                                                  *
* Description        : Test class for UtilityWrapperManager class.                                *
* Created Date       : 21/02/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      21/02/2017      Initial Draft.                                    *
**************************************************************************************************/
@isTest 
private class UtilityWrapperManagerTest {

    static testMethod void myUnitTest() {
        UtilityWrapperManager UWM = new UtilityWrapperManager();
        System.debug('UWM = '+UWM.value);
        System.debug('UWM = '+UWM.isSubmitted);
        System.debug('UWM = '+UWM.dealRecord); 
        System.debug('UWM = '+UWM.ibwList);
        UtilityWrapperManager.SharingWrapper ser = new UtilityWrapperManager.SharingWrapper('test', 'test', 'test', 'test', 'test');
        UtilityWrapperManager.CampaignWrapper cam = new UtilityWrapperManager.CampaignWrapper(false, new Campaign__c (), new List<Promotion__c> ());
        UtilityWrapperManager.BookingWrapper BW = new UtilityWrapperManager.BookingWrapper('Damac','Start');
        UtilityWrapperManager.BuildingInorWrapper BInfo = new UtilityWrapperManager.BuildingInorWrapper('1',1,Double.valueOf('10.2'),12.1,15.3,13.3,43.2,'ABC');
        UtilityWrapperManager.PriceRageWrapper pt = new UtilityWrapperManager.PriceRageWrapper(12.3, 23.2);
        UtilityWrapperManager.InventoryDetailsWrapper idw = new UtilityWrapperManager.InventoryDetailsWrapper( '1233245324','1231','test','123432423','Damac','dsfw','test','one','2','2','marketing',12.1,23.2,21.2);
        UtilityWrapperManager.InventoryBuyerWrapper ibw = new UtilityWrapperManager.InventoryBuyerWrapper();
        UtilityWrapperManager.InventoryBuyerWrapper ibwn = new UtilityWrapperManager.InventoryBuyerWrapper(false,false, false, 32.2,3432432.234,'test','test','test','test',3,new Inventory__c(),new Booking_Unit__c(),new Map<String, Payment_Plan__c>(),new List<Buyer__c> ());
        
    }
}// End of class.