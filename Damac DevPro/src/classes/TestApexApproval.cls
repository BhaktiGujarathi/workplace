public with sharing class TestApexApproval {
    
    private static final String PENALTY_WAIVER = 'Penalty_Waiver';
    private static final Id penaltyWaiver = getRecordTypeId( PENALTY_WAIVER );
    
    public static void sendForApproval( List<Service_Request__c> lstUpdatedRequest) {
        system.debug('--Approval Method Called--'+lstUpdatedRequest[0]);
        for( Service_Request__c objReq : lstUpdatedRequest ) {
            if( objReq.RecordTypeId == penaltyWaiver ) {
                system.debug('Penalty Waiver record');
                set<Id> setUserId = new set<Id>();
                
                //Check if values received from external system is not auto waived
                if( objReq.Approving_Authority_1__c != null ) {
                    //submitApprovalRequest( objReq.Approving_Authority_1__c, objReq.Id );
                }
                if( objReq.Approving_Authority_2__c != null ) {
                   // submitApprovalRequest( objReq.Approving_Authority_2__c, objReq.Id );
                }
                if( objReq.Approving_Authority_3__c != null ) {
                   // submitApprovalRequest( objReq.Approving_Authority_3__c, objReq.Id );
                }
                if( objReq.Approving_Authority_2_Role__c != null ) {
                    list<Id> lstUserIdSet = new list<Id>();
                    for( User objUser : getUserFromRole( objReq.Approving_Authority_2_Role__c )) {
                        system.debug('UserName = '+objUser.FirstName +' UserId = '+objUser.Id);
                        lstUserIdSet.add( objUser.Id );
                        break;
                    }
                    submitApprovalRequest( lstUserIdSet, objReq.Id );
                }
            }
        }
    }
    
    public static Id getRecordTypeId( String strDeveloperName ) {
        list<RecordType> lstRecordType = [Select Id
                                               , Name
                                               , DeveloperName
                                               , SobjectType 
                                            From RecordType 
                                           Where DeveloperName = :PENALTY_WAIVER 
                                             AND SobjectType = 'Service_Request__c'
                                             AND IsActive = true ];
        if( lstRecordType != null && lstRecordType.isEmpty() == false ) {
            return lstRecordType[0].Id;
        }
        return null;
    }
    
    public static list<User> getUserFromRole( String strRoleName ) {
        list<User> lstUser = [SELECT Id
                                   , FirstName
                                   , LastName
                                   , UserRole.Name
                                FROM User
                               WHERE UserRole.Name = :strRoleName 
                                 AND IsActive = true
                                 LIMIT 2];
        return lstUser ;
    }
    
    private static void submitApprovalRequest( list<Id> userId, Id recordId ) {
         system.debug('Sending for approval....');
         Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
         req.setComments('Submitting request for approval.');
         req.setObjectId( recordId );
         req.setSubmitterId( UserInfo.getUserId() );
         req.setNextApproverIds( userId );
         req.setProcessDefinitionNameOrId( 'Penalty_Waiver_Approval' );
         req.setSkipEntryCriteria(true) ;
         system.debug('Request--'+req);
         Approval.ProcessResult result2 =  Approval.process(req);
         //system.debug('result2--'+result2.getErrors());
    }
}