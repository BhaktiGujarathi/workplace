/***********************************************************************************************************************************
* Name               : OptionDroolParameterSave*
* Created Date       : 11/07/2017                                                                                      *
* Created By         : Naresh(Accely) *
* ---------------------------------------------------------------------------------------------------------------------*
*Description        : Updation of Option i.e. PromotionName , CampaignName , OptionName , SchemeName
                      Records will not get Save If there is no Registration ID in Booking Unit
*

**************************************************************************************************************************************/
public class OptionDroolParameterSave{
 Public Static Boolean IsOnce = True ;
    public static void DroolParameterSave(Map<Id,Option__c> NewOption,Map<Id,Option__c> OldOption){
        IsOnce  =  false ;
        Set<Id> BUid=new  Set<Id>();
       // List<Option__c> OptList = new List<Option__c>();
        for(Option__c Op:NewOption.values()){
           BUid.add(Op.Booking_Unit__c);
        }
       
    for(Option__c Op:[SELECT Id,PromotionName__c ,OptionsName__c ,CampaignName__c , SchemeName__c ,Booking_Unit__r.Registration_ID__c FROM Option__c WHERE Booking_Unit__c=:BUid]){
           
           System.debug('After Update Opppppp:::::::::::::::::');
          
               if(string.isBlank(Op.Booking_Unit__r.Registration_ID__c)){
                 System.debug('After 5555555555555555555::');
              //   Op.addError('Please Provide Booking Registration ID');
                 
            }
    }
    }
}