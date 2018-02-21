public with sharing class PenaltyWaiverController { 
    
    /*public list<SelectOption> lstCommunityUser {get; set;}
    public Id idSelectedUser {get; set;}
    //public PenaltyWaiverService.PenaltyWaiverResponseWrapper allRelatedUnits {get; set;}
    public Booking_Unit__c objSelectedUnit {get; set;} 
    public Id idSelectedUnit {get; set;}
    public Service_Request__c objRequest{get; set;}
    
    private map<Id, User> mapCommunityUser;
    private Id accountId ;
    
    public PenaltyWaiverController() {
        objRequest = new Service_Request__c();
    }
    
    public void getUserList() {
        mapCommunityUser = new map<Id, User>([SELECT Id
                                                   , FirstName
                                                   , LastName
                                                   , Email
                                                   , ContactId
                                                   , Contact.AccountId
                                                FROM User
                                               WHERE IsActive = true
                                                 AND ContactId != null]);
        
        lstCommunityUser = new list<SelectOption>();
        if( mapCommunityUser.values().isEmpty() == false ) {
            lstCommunityUser.add( new SelectOption( '','--NONE--') );
            for( User objUser : mapCommunityUser.values() ) {
               lstCommunityUser.add( new SelectOption( objUser.Id ,objUser.FirstName + ' ' + objUser.LastName ) ); 
            }
        }
        
        system.debug('--Community user list--'+lstCommunityUser );
    }
    
    /*public void getUnitDetails() {
        system.debug('--idSelectedUser--'+idSelectedUser );
        allRelatedUnits = new PenaltyWaiverService.PenaltyWaiverResponseWrapper();
        if( idSelectedUser != null ) {
            accountId = mapCommunityUser.get( idSelectedUser ).Contact.AccountId;
            system.debug('--Account Id--'+accountId);
            allRelatedUnits = PenaltyWaiverService.getPenaltyDetails( accountId );
        }
    }*/
    
   /*public void getSelectedUnit() {
        system.debug('--idSelectedUnit--'+idSelectedUnit);
        objSelectedUnit = allRelatedUnits.mapBookingUnit.get( idSelectedUnit );
    }*/
    
   /* public void submitSR() {
        //Populate all the required info to SR record.
        system.debug('Controller method called..');
        objRequest.Booking_Unit__c = objSelectedUnit.Id ;
        objRequest.Account__c = accountId ;
        objRequest.Penalty_Amount__c = objSelectedUnit.Penalty_Amount__c;
        //objRequest = PenaltyWaiverService.getApprovingDetails( objRequest );
        objRequest.RecordTypeId = TestApexApproval.getRecordTypeId('Penalty_Waiver');
        try {
            insert objRequest ;
            TestApexApproval.sendForApproval( new list<Service_Request__c>{ objRequest } );
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Request Raised Successfully.'));
         }
        catch( Exception e ) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }*/
}