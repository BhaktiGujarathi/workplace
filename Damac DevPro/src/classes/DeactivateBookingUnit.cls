/* Call from button of token refund detail page
   Created By : Swapnil Gholap
*/



global class DeactivateBookingUnit{

    // method called from button - Token refund page layout 
    webservice static string updateCaseRecord(String caseId,String bookingUnitId){
        try{
            if(String.isNotBlank(caseId) && String.isNotBlank(bookingUnitId)){
                
                System.debug('--bookingUnitId--'+bookingUnitId);
                List<String> lstBookingUnitIds = new List<String>();
                if(bookingUnitId.contains(',')){
                    lstBookingUnitIds = bookingUnitId.split(',');
                }
                else{
                    lstBookingUnitIds.add(bookingUnitId); // only 1 id present
                }
              
                List<Booking_Unit__c> lstBookingUnit = new List<Booking_Unit__c>();                
                lstBookingUnit = [Select id,name, Registration_Status__c 
                                 from Booking_Unit__c
                                 where id IN : lstBookingUnitIds];
                for(Booking_Unit__c objBU : lstBookingUnit ){
                    objBU.Registration_Status__c = 'Agreement Rejected By Sales Admin';
                }
                
                update lstBookingUnit ;
                
                Case objCase = new Case();
                objCase = [Select id,RecordType.name,POA_Name__c,Status,SR_Type__c,
                          POA_Relationship_with_Buyer__c,POA_Expiry_Date__c ,POA_Issued_By__c, Power_of_Attorney__c,
                          (select id,SR__c,Booking_Unit__c
                          from SR_Booking_Units__r),
                          (Select id,name,SR__c,View__c,Attachment__c,type__c,Case__r.CaseNumber,isValid__c
                          from SR_Attachments__r),
                          (Select id,subject,status from Tasks where subject=:'Deactivate Booking Unit' 
                          AND status != 'Completed' 
                          AND status != 'Closed' limit 1)
                          from Case where id =: caseId ];                                
                              
                if(objCase.tasks.Size()>0){
                    objCase.tasks[0].status = 'Completed';
                    update objCase.tasks;
                }
                objCase.Task_Created_for_Sales_Admin__c = false;
                objCase.Active_Unit_Ids__c = '';
                objCase.Submit_for_Approval__c = true; // after Sales admin approval, regular approval will triggered
                objCase.Approving_Authorities__c = 'VP - Operations,General Manager';
                update objCase;
                
                return 'success';
            }
            else{
                return 'No Case ID present';
            }
        }
        catch(exception ex){
            return ex.getMessage();
        }
        return null;
    }

}