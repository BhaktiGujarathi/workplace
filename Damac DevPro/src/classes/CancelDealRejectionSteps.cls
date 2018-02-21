/*
Custom code to Cancel all the closed steps under SR when a Cancelled step is updated to cancelled.

*/

global without sharing class CancelDealRejectionSteps implements NSIBPM.CustomCodeExecutable {
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step){
        String retStr = 'Success';
        List<Id> BookingIds= new List<id>();
        try{
            NSIBPM__Service_Request__c objSR = SRUtility.getSRDetails(step.NSIBPM__SR__c);
            NSIBPM__Status__c cancelledStatus = [select id from NSIBPM__Status__c  where NSIBPM__Code__c='CANCELLED' LIMIT 1];
            /*
            // Check if there are any Docs 
            list<NSIBPM__SR_Doc__c> srDocs = new list<NSIBPM__SR_Doc__c>();
            list<NSIBPM__SR_Doc__c> updateSrDocs = new list<NSIBPM__SR_Doc__c>();
            srDocs = [select id,NSIBPM__SR_Template_Doc__c from NSIBPM__SR_Doc__c where NSIBPM__Service_Request__c=:objSR.id];
            system.debug('SRDOCS>>>>'+srDocs.size());
            if(srDocs.size() > 0){
                for(NSIBPM__SR_Doc__c eachDoc:srDocs){
                    eachDoc.NSIBPM__Is_Not_Required__c= true;
                    updateSrDocs.add(eachDoc);
                }
                update updateSrDocs;
            }
            */
            //Get all steps of SR which are Open and set status to Cancelled
            list<NSIBPM__Step__c> getAllsteps = new list<NSIBPM__Step__c>();
            getAllsteps = [select id,NSIBPM__Status__c from NSIBPM__Step__c where NSIBPM__SR__c=:objSR.id and Id !=:step.id and Is_Closed__c=:false LIMIT 50000];            
            if(getAllsteps.size()>0){
                for(NSIBPM__Step__c stp:getAllsteps){
                    stp.NSIBPM__Status__c = cancelledStatus.id;
                }
                update getAllsteps;
            }     
            for(Booking__c Bookings :[select id from Booking__c where Deal_SR__c=: step.NSIBPM__SR__c]){
                BookingIds.add(Bookings.id);
            }
            if(BookingIds.size()>0){
                system.debug('#### invoking CancelDealRejectionSteps');
                system.enqueueJob(new AsyncReceiptWebservice (BookingIds,'StatusUpdate'));  
            }
            return retStr;
        }
        catch(exception ex){
            return ex.getMessage();
        }
    }
}