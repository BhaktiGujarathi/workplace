/*****************Methods for reinvoking the webservice**************/
global class RetryWebservice{

    webservice static string retrybooking(Id srId){     
        String res='Success';
        
        integer regcount=[select count() from Booking_Unit__c where Status__c!='Removed' and Registration_ID__c=null and Booking__r.Deal_SR__c=:srId];
        
        if(regcount==0)
        res='Registration already successful. Retry not allowed';
        
        else{
            try{
                //List<id>Bookingids= new List<id>();
                for(Booking__c bk :[select id from Booking__c where Deal_SR__c=:srId]){                    
                    List<id>Bookingids= new List<id>();
                    Bookingids.add(bk.id);
                    //system.enqueueJob(new AsyncReceiptWebservice (Bookingids,'Registration Creation'));
                    AsyncReceiptWebservice.sendRegistrationRequest(BookingIds); 
                }
                //if(BookingIds.size()>0)
                //AsyncReceiptWebservice.sendRegistrationRequest(BookingIds);            
            }
            catch(Exception ex) {
                 res=ex.getMessage();        
            }  
        }
        return res;
        
    }
    webservice static string retrySPA(Id srId){     
        String res='Success';        
        integer regcount=[select count() from Booking_Unit__c where Status__c!='Removed' and Registration_ID__c=null and Booking__r.Deal_SR__c=:srId];
        
        if(regcount>0)
        res='Registration not created yet. SPA cannot be generated';
        
        else{
	        try{
	            /*List<id>Bookingids= new List<id>();
	            for(Booking__c bk :[select id from Booking__c where Deal_SR__c=:srId]){
	                Bookingids.add(bk.id);
	            }
	            if(BookingIds.size()>0)
	            AsyncReceiptWebservice.invokeSPAGeneration(BookingIds); 
	            */
	            for(Booking_Unit__c BU :[select id,Booking__r.Deal_SR__c from Booking_Unit__c where Status__c!='Removed' and Booking__r.Deal_SR__c=:srId]){
	                List<Id> BUIds= new List<id>();
	                BUIds.add(BU.id);
	                system.enqueueJob(new AsyncReceiptWebservice (BUIds,'SPA'));
	            }           
	        }
	        catch(Exception ex) {
	             res=ex.getMessage();        
	        }  
        }
        return res;
        
    }
    
    webservice static string GetPayPlan(Id BUid){     
        String res='Success';        
        
        try{           
            //List<Id> BUIds= new List<id>();
            //BUIds.add(BUid);
            ///system.enqueueJob(new AsyncReceiptWebservice (BUIds,'Retrieve PayPlan'));
            AsyncReceiptWebservice.RetrievePayPlan(BUid);        
        }
        catch(Exception ex) {
             res=ex.getMessage();        
        }  
        
        return res;
        
    }
}