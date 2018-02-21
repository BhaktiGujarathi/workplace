public class CallSetApproversClass {
     @InvocableMethod public static void checkServiceRequest(List<ID> lstBookingUnitID) {
         System.debug('--CallSetApproversClass lstBookingUnitID---'+lstBookingUnitID);
         list<SR_Booking_Unit__c> lstSRbookingUnit = new list<SR_Booking_Unit__c>();
         lstSRbookingUnit = [Select id,name, booking_unit__c,Case__c
                            from SR_Booking_Unit__c
                            where booking_unit__c
                            IN: lstBookingUnitID 
                            AND booking_unit__c != null
                            AND Case__c != null
                            AND Case__r.RecordType.DeveloperName = 'Token_Refund'
                            AND Case__r.status = 'Submitted'
                            AND Case__r.Submit_for_Approval__c =: false];
         list<String> lstCaseID = new list<String>();
         for(SR_Booking_Unit__c objSR : lstSRbookingUnit){
             lstCaseID.add(objSR.Case__c);
         }
         list<Case> lstCase = new list<Case>();
         lstCase = [Select id,Approving_Authorities__c,Approval_Status__c,Submit_for_Approval__c,
                   Active_Unit_Ids__c ,Roles_from_Rule_Engine__c                  
                   from Case where id IN:lstCaseID 
                   And Active_Unit_Ids__c != null ];
                   
         List<Task> lstTask = new List<Task>();
         lstTask = [Select id,Subject from task where subject = 'Deactivate Booking Unit' 
                   AND (Status != 'Completed' OR Status != 'Closed')
                   AND whatID != null
                   AND whatID IN:lstCaseID ];
                   
         for(Case objCase : lstCase){
             //objCase.Approving_Authorities__c = 'VP - Operations,General Manager';
             if(String.isNotBlank(objCase.Roles_from_Rule_Engine__c)){
                     objCase.Approving_Authorities__c = objCase.Roles_from_Rule_Engine__c;
                 }
             objCase.Submit_for_Approval__c = true;
             
         }
         if(lstCase.Size()>0){
             update lstCase;
         }
         if(lstTask.Size()>0){
             lstTask[0].status = 'Completed';
             update lstTask;
         }                            
     }
}