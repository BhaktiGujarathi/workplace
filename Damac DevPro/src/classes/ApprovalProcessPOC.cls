/* Description: Class used for implementing the dynamic approval process based on the roles
 * returned from the rule engine
 */
public with sharing class ApprovalProcessPOC {
    
    public ApprovalProcessPOC() {
        
    }
    
    public static void initiateApprovalProcess() {
        List<Case> lstCase = [Select Id, Approving_Authorities__c From Case 
                              Where Id = '5007E000001q2hE' 
                              And Approving_Authorities__c != null];
    
        if(lstCase != null && !lstCase.isEmpty()) {
            String strApprovingAuthorities = lstCase[0].Approving_Authorities__c;
            String strRole = strApprovingAuthorities.contains(',') ? 
                             strApprovingAuthorities.subString(0, strApprovingAuthorities.indexOf(',')) :
                             strApprovingAuthorities;
            system.debug('--strRole--'+strRole);
            List<User> lstApprover = [Select Id,UserRole.Name From User Where UserRole.Name =: strRole
                                And IsActive = true];
            system.debug('--lstApprover--'+lstApprover);
            
            if(lstApprover != null && !lstApprover.isEmpty()) {
                // Create an approval request for the account
                Approval.ProcessSubmitRequest objApprovalSubmitRequest =
                    new Approval.ProcessSubmitRequest();
                objApprovalSubmitRequest.setComments('Submitting request for approval.');
                objApprovalSubmitRequest.setObjectId(lstCase[0].Id);
                // Submit on behalf of a specific submitter
                //objApprovalSubmitRequest.setSubmitterId(lstApprover[0].Id);
                // Submit the record to specific process and skip the criteria evaluation
                objApprovalSubmitRequest.setProcessDefinitionNameOrId('Dynamic_Approval_Process');
                objApprovalSubmitRequest.setSkipEntryCriteria(true);
                objApprovalSubmitRequest.setNextApproverIds(new Id[] {lstApprover[0].Id});
                
                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(objApprovalSubmitRequest);
                
                system.debug('-----result----'+result);
            }
        }
    }
    
}