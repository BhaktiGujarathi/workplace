/*
Created By : Swapnil Gholap
Use : Call from process builder
*/

public class ValidateDocumentsOnSRattachment {
    
    @InvocableMethod 
    public static void ValidateDocument(List<SR_Attachments__c> lstSRAttachment){
        System.debug('--ValidateDocument lstSRAttachment---'+lstSRAttachment);
        boolean blnCallApproval = false;
        for(SR_Attachments__c objSR : lstSRAttachment){
            System.debug('---Sr-'+objSR.id+'---'+objSR.isValid__c+'---objSr.Case__c '+objSr.Case__c);
        }
        if(lstSRAttachment.Size()>0){
            lstSRAttachment = [Select id,name,isValid__c,Case__c from SR_Attachments__c 
                              where Case__c = :
                              lstSRAttachment[0].Case__c];
                              
            System.debug('---lstSRAttachment--'+lstSRAttachment);
            boolean blnFlag = true;
            for(SR_Attachments__c objSR : lstSRAttachment){
                if(objSR.isValid__c == false){
                    blnFlag = false;
                }
            }
            
            if(blnFlag){
                blnCallApproval = true;               
            }
        }
        if(blnCallApproval){
             
             System.debug('---blnCallApproval--'+blnCallApproval);
             Case objCase = [Select id, Submit_for_Approval__c,Active_Unit_Ids__c,
                            Document_Verified__c,RecordType.name, Status,Roles_from_Rule_Engine__c 
                            from Case 
                            where id=: lstSRAttachment[0].Case__c];
                         
             objCase.Document_Verified__c = true;
             
             if( String.isNotBlank( objCase.RecordType.name ) &&  String.isNotBlank( objCase.Status ) &&
                 objCase.RecordType.name.equalsIgnoreCase( 'Penalty_Waiver' ) && objCase.Status.equalsIgnoreCase( 'Submitted' ) ) {
                 objCase.Submit_for_Approval__c = true;
                 objCase.Approving_Authorities__c = 'VP - Operations,General Manager';
             }
             
             // Sales Admin approval process for deactivating Booking Unit only for token refund process
             if(String.isBlank(objCase.Active_Unit_Ids__c)){
                 objCase.Submit_for_Approval__c = true;
                 //objCase.Approving_Authorities__c = 'VP - Operations,General Manager';
                 if(String.isNotBlank(objCase.Roles_from_Rule_Engine__c)){
                     objCase.Approving_Authorities__c = objCase.Roles_from_Rule_Engine__c;
                 }
             }
             
             update objCase;
             
             
             if(String.isNotBlank(objCase.Active_Unit_Ids__c) && objCase.RecordType.name == 'Token Refund' ){
                 List<Booking_Unit__c> lstBookingUnit = new List<Booking_Unit__c>();
                 lstBookingUnit = [Select id,name,Booking__c,Booking__r.Deal_SR__c from Booking_Unit__c where id=:objCase.Active_Unit_Ids__c];
                 List<ID> lstApproverID = new List<ID>();
                 if(lstBookingUnit.Size()>0){
                     if(lstBookingUnit[0].Booking__r.Deal_SR__c != null){
                         List<Deal_Team__c> lstDealTeam = new List<Deal_Team__c>();
                         lstDealTeam = [Select id,name,Associated_DOS__c,Associated_HOS__c,Associated_DOS__r.isActive,Associated_HOS__r.isActive
                                       from Deal_Team__c where Associated_Deal__c =: lstBookingUnit[0].Booking__r.Deal_SR__c
                                       limit 1];
                         System.debug('---lstDealTeam--'+lstDealTeam.Size()+'---'+lstDealTeam);
                         if(lstDealTeam.Size()>0){
                             if(lstDealTeam[0].Associated_DOS__c != null && lstDealTeam[0].Associated_DOS__r.isActive){
                                 lstApproverID.add(lstDealTeam[0].Associated_DOS__c);
                             }
                             else if(lstDealTeam[0].Associated_HOS__c != null && lstDealTeam[0].Associated_HOS__r.isActive){
                                 lstApproverID.add(lstDealTeam[0].Associated_HOS__c);
                             }
                             else{
                                 list<User> lstUser = new list<User>();
                                 lstUser = [Select id,name from User where isActive =: true AND userRole.Name = 'HOD'];
                                 if(lstUser.Size()>0){
                                     lstApproverID.add(lstUser[0].id);
                                 }
                             }
                         }
                     }
                 }
                 System.debug('---lstApproverID---'+lstApproverID);      
                 if(lstApproverID.Size()>0){
                     System.debug('---ApprovalProcess--Deactivate_Booking_Unit_Approval---');                       
                     Approval.ProcessSubmitRequest objApprovalSubmitRequest =   new Approval.ProcessSubmitRequest();
                     objApprovalSubmitRequest.setComments('Automatic submit.');
                     objApprovalSubmitRequest.setObjectId(objCase.id);
                     //objApprovalSubmitRequest.setNextApproverIds(lstUser[0].id);
                     objApprovalSubmitRequest.setNextApproverIds(lstApproverID);
                     objApprovalSubmitRequest.setProcessDefinitionNameOrId('Deactivate_Booking_Unit_Approval');
                     objApprovalSubmitRequest.setSkipEntryCriteria(true);
                     // Submit the approval request for the Case
                     Approval.ProcessResult result = Approval.process(objApprovalSubmitRequest);
                 }
             }
        }
       
    }
    
}