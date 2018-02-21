/* Description: Class used to send approval request to the next approver dynamically
 */
public with sharing class ApprovalHandler {
    
    //Method used to send approval request to the next approver dynamically based on the
    //comma separated roles defined in the Approving_Authorities__c field on Case
    @future
    public static void processApprovals(Set<Id> setCaseId) {
        List<Case> lstCase = [Select Id, Approving_Authorities__c, RecordTypeId From Case 
                              Where Id IN: setCaseId
                              And Approving_Authorities__c != null];
        
        if(lstCase != null && !lstCase.isEmpty()) {
            List<ApprovalWrapper> lstApprovalWrapper = new List<ApprovalWrapper>();
            Set<String> setRolesToQuery = new Set<String>();
            
            for(Case objCase: lstCase) {
                if(objCase.Approving_Authorities__c != null) {
                    String strApprovingAuthorities = objCase.Approving_Authorities__c;
                    String strRole = strApprovingAuthorities.contains(',') ? 
                        strApprovingAuthorities.subString(0, strApprovingAuthorities.indexOf(',')) :
                        strApprovingAuthorities;
                    system.debug('--strRole--'+strRole);
                    setRolesToQuery.add(strRole);
                    
                    ApprovalWrapper objApprovalWrapper = new ApprovalWrapper();
                    objApprovalWrapper.strUserRole = strRole;
                    objApprovalWrapper.objCase = objCase;
                    lstApprovalWrapper.add(objApprovalWrapper);
                }
            }
            
            List<User> lstApprovers = [Select Id, UserRole.Name From User Where UserRole.Name IN: setRolesToQuery
                                And IsActive = true];
            for(ApprovalWrapper objApproverWrapper: lstApprovalWrapper) {
                for(User objUser: lstApprovers) {
                    if(objApproverWrapper.strUserRole.equals(objUser.UserRole.Name)) {
                        objApproverWrapper.approverUserId = objUser.Id;
                        break;
                    }
                }
            }
            system.debug('--lstApprovalWrapper post approver population--'+lstApprovalWrapper);
            
            Id idPenaltyWaiverRecord = PenaltyWaiverUtility.getRecordTypeId( 'Penalty_Waiver','Case' );
            //Id CustomerRefundRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Refund').getRecordTypeId();
            //Id TokenRefundRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Token Refund').getRecordTypeId();
            
            for(ApprovalWrapper objApproverWrapper: lstApprovalWrapper) {
                // Create an approval request for the account
                Approval.ProcessSubmitRequest objApprovalSubmitRequest =
                    new Approval.ProcessSubmitRequest();
                objApprovalSubmitRequest.setComments('Submitting request for approval.');
                objApprovalSubmitRequest.setObjectId(objApproverWrapper.objCase.Id);
                // Submit on behalf of a specific submitter
                //objApprovalSubmitRequest.setSubmitterId(lstApprover[0].Id);
                // Submit the record to specific process and skip the criteria evaluation
                if( objApproverWrapper.objCase.RecordTypeId == idPenaltyWaiverRecord ) {
                    objApprovalSubmitRequest.setProcessDefinitionNameOrId('Penalty_Waiver_Approval');
                }
                /*else if(objApproverWrapper.objCase.RecordTypeId == CustomerRefundRecordTypeId ||
                        objApproverWrapper.objCase.RecordTypeId == TokenRefundRecordTypeId ){
                    objApprovalSubmitRequest.setProcessDefinitionNameOrId('Refund_Process_Approval');
                }*/
                else {
                    objApprovalSubmitRequest.setProcessDefinitionNameOrId('Dynamic_Approval_Process');
                }
                objApprovalSubmitRequest.setSkipEntryCriteria(true);
                objApprovalSubmitRequest.setNextApproverIds(new Id[] {objApproverWrapper.approverUserId});
                
                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(objApprovalSubmitRequest);
                
                system.debug('--result--'+result+'--for case--'+objApproverWrapper.objCase.Id);
            }
        }
    }
    
    @future 
    public static void processCallingListApproval( set<Id> setCallingListIds ) {
    	system.debug('=== Method processCallingListApproval Called ===');
    	list<Calling_List__c> lstCallingListForApproval = CallingListUtility.getCallingLists( setCallingListIds );
    	set<String> setRoleNames = new set<String>();
    	list<ApprovalWrapper> lstApprovalWrapper = new list<ApprovalWrapper>();
    	for( Calling_List__c objCall : lstCallingListForApproval ) {
    		if( String.isNotBlank( objCall.Approving_Authorities__c ) ) {
    			String strApprovingAuthorities = objCall.Approving_Authorities__c ;
    			String strRoleName = strApprovingAuthorities.contains( ',' ) ? 
	                        		 strApprovingAuthorities.subString( 0, strApprovingAuthorities.indexOf(',') ) :
	                        		 strApprovingAuthorities ;
    			setRoleNames.add( strRoleName );
    			lstApprovalWrapper.add( new ApprovalWrapper( strRoleName, objCall ) );  
    		}
    	}
    	if( !setRoleNames.isEmpty() && !lstApprovalWrapper.isEmpty() ) {
    		list<User> lstUsers = CallingListUtility.getUserFromRoles( setRoleNames );
    		for( User objUser : lstUsers ) {
    			for( ApprovalWrapper objWrap : lstApprovalWrapper ) {
    				if( objUser.UserRole.Name != null && objUser.UserRole.Name.equalsIgnoreCase( objWrap.strUserRole ) ) {
    					objWrap.approverUserId = objUser.Id ;
    				}
    			}
    		}
    		system.debug( '=== lstApprovalWrapper ==='+lstApprovalWrapper );
    		for( ApprovalWrapper objWrap : lstApprovalWrapper ) {
    			if( objWrap.objCallingList != null && objWrap.approverUserId != null ) {
    				Approval.ProcessSubmitRequest objApprovalSubmitRequest = new Approval.ProcessSubmitRequest();
    				objApprovalSubmitRequest.setComments( 'Submitting request for approval.' );
                	objApprovalSubmitRequest.setObjectId( objWrap.objCallingList.Id );
    				objApprovalSubmitRequest.setProcessDefinitionNameOrId( 'Bounced_Cheque_Calling_List_Approval' );
    				objApprovalSubmitRequest.setSkipEntryCriteria( true );
                	objApprovalSubmitRequest.setNextApproverIds( new list<Id>{ objWrap.approverUserId } );
    				Approval.ProcessResult result = Approval.process( objApprovalSubmitRequest );
    			}
    		}
    	}
    }
    
    public class ApprovalWrapper {
        public String strUserRole;
        public Id approverUserId;
        public Case objCase;
        public Calling_List__c objCallingList ;
		
		ApprovalWrapper() {
			
		}
		
		ApprovalWrapper( String strUserRole, Calling_List__c objCallingList ) {
			this.strUserRole = strUserRole ;
			this.objCallingList = objCallingList ;
		}
    }
}