/*
This Class used to create steps from Process Builder and Custom Buttons on SR
1) Deal rejectionStep Creation 
2) Deal Reinstatement step creation
*/

global class CreateStepOnDPOverDue{

    
    /*
    Name:createStep
    Desc:To Create Deal Rejection Step on SR from Process Builder
    */
    @InvocableMethod
    public static void createStep(List<Id> srIds){
        try{    
            list<NSIBPM__Step__c> checkDealRejection = new list<NSIBPM__Step__c>();
            checkDealRejection = [select id,NSIBPM__SR__c from NSIBPM__Step__c where NSIBPM__Step_Template__r.NSIBPM__Code__c='DEAL_REJECTION' and NSIBPM__SR__c IN:srIds];
            map<id,boolean> mapSrDealRejStep = new map<id,boolean>();
            if(checkDealRejection.size() > 0){
                // Prepare map of Sr Id and its Deal rejection setp            
                for(NSIBPM__Step__c step:checkDealRejection){
                    mapSrDealRejStep.put(step.NSIBPM__SR__c,true); //There is already a Deal Rejection Step under SR           
                }
            }
            
            
            NSIBPM__SR_Template__c template = new NSIBPM__SR_Template__c();
            template = [select id,(select id,NSIBPM__Start_Status__c,NSIBPM__Step_Template__c,NSIBPM__SR_Steps__c.OwnerId,NSIBPM__Step_No__c,NSIBPM__SR_Template__r.Name from  NSIBPM__SR_Steps_SR_Template__r where NSIBPM__Step_Template_Code__c='DEAL_REJECTION' and
                        NSIBPM__Start_Status__c!=null and 
                        NSIBPM__Step_Template__c!=null and 
                        ownerid != null and 
                        NSIBPM__Step_No__c!=null LIMIT 1 ) from NSIBPM__SR_Template__c where Name='Deal' limit 1];
                        
            system.debug(template+'>>>');
            system.debug(template.NSIBPM__SR_Steps_SR_Template__r +'>>>');
            
            if(template.NSIBPM__SR_Steps_SR_Template__r  != null){        
            list<NSIBPM__Step__c> newSteps = new list<NSIBPM__Step__c>();
                for(id srId:srIds){
                    if(!mapSrDealRejStep.containskey(srId)){
                        NSIBPM__Step__c newStep = new NSIBPM__Step__c();
                        newStep.NSIBPM__SR__c = srId;
                        newStep.NSIBPM__SR_Step__c = template.NSIBPM__SR_Steps_SR_Template__r[0].id;
                        newStep.NSIBPM__Status__c =  template.NSIBPM__SR_Steps_SR_Template__r[0].NSIBPM__Start_Status__c;
                        newStep.NSIBPM__Step_Template__c = template.NSIBPM__SR_Steps_SR_Template__r[0].NSIBPM__Step_Template__c;
                        //newStep.RecordTypeId = 
                        newStep.OwnerId = template.NSIBPM__SR_Steps_SR_Template__r[0].ownerid;
                        newStep.NSIBPM__Step_No__c  = template.NSIBPM__SR_Steps_SR_Template__r[0].NSIBPM__Step_No__c;
                        newStep.NSIBPM__Sys_Step_Loop_No__c= template.NSIBPM__SR_Steps_SR_Template__r[0].NSIBPM__Step_No__c+'_1';
                        newSteps.add(newStep);
                    }
                }
                insert newSteps;
            }
        }catch(exception e){
        
        }
        
    }
    
    /*
    Name:createStepFromButton
    Desc:To Create Deal Rejection Step on SR from Detail Page Button
    */
    webservice static string createStepFromButton(Id srId){
        
        list<NSIBPM__Step__c> checkDealRejection = new list<NSIBPM__Step__c>();
        checkDealRejection = [select id,NSIBPM__SR__c from NSIBPM__Step__c where NSIBPM__Step_Template__r.NSIBPM__Code__c='DEAL_REJECTION' and NSIBPM__SR__c =:srId];
        system.debug('--checkDealRejection --'+checkDealRejection.Size()+'--'+checkDealRejection );
        if(checkDealRejection.size() > 0){
            return 'Deal rejection step already exist';   
        }else{
        
            NSIBPM__SR_Template__c template = new NSIBPM__SR_Template__c();
            template = [select id,(select id,NSIBPM__Start_Status__c,NSIBPM__Step_Template__c,NSIBPM__SR_Steps__c.OwnerId,NSIBPM__Step_No__c,NSIBPM__SR_Template__r.Name from  NSIBPM__SR_Steps_SR_Template__r where NSIBPM__Step_Template_Code__c='DEAL_REJECTION' and
                        NSIBPM__Start_Status__c!=null and 
                        NSIBPM__Step_Template__c!=null and 
                        ownerid != null and 
                        NSIBPM__Step_No__c!=null LIMIT 1 ) from NSIBPM__SR_Template__c where Name='Deal' limit 1];
                        
            system.debug('--NSIBPM__SR_Template__c--'+template+'>>>');
            system.debug('--NSIBPM__SR_Steps_SR_Template__r--'+template.NSIBPM__SR_Steps_SR_Template__r +'>>>');
            
                if(template.NSIBPM__SR_Steps_SR_Template__r  != null){
                    try{            
                        
                        NSIBPM__Step__c newStep = new NSIBPM__Step__c();
                        newStep.NSIBPM__SR__c = srId;
                        newStep.NSIBPM__SR_Step__c = template.NSIBPM__SR_Steps_SR_Template__r[0].id;
                        newStep.NSIBPM__Status__c =  template.NSIBPM__SR_Steps_SR_Template__r[0].NSIBPM__Start_Status__c;
                        newStep.NSIBPM__Step_Template__c = template.NSIBPM__SR_Steps_SR_Template__r[0].NSIBPM__Step_Template__c;
                        //newStep.RecordTypeId = 
                        newStep.OwnerId = template.NSIBPM__SR_Steps_SR_Template__r[0].ownerid;
                        newStep.NSIBPM__Step_No__c  = template.NSIBPM__SR_Steps_SR_Template__r[0].NSIBPM__Step_No__c;
                        newStep.NSIBPM__Sys_Step_Loop_No__c= template.NSIBPM__SR_Steps_SR_Template__r[0].NSIBPM__Step_No__c+'_1';                                      
                        insert newStep;
                        return 'success';
                     }
                     catch(exception e){
                        system.debug('--exception --'+e.getMessage()+'>>>');
                        return 'error';
                     }
                }else {
                    return 'No Sufficient Data on SR';
                }
            }// End of Main Else
                
    }
    
    
    
    /*
    Name:reinstatementDeal
    Desc:To Create Deal Reinstatement Step on SR from Detail Page Button
    */
    webservice static string reinstatementDeal(Id srId){
        //boolean preChecksPassed = preChecksForReinstatement(srId);
        //if(preChecksPassed){
            //list<NSIBPM__Step__c> checkDealRejection = new list<NSIBPM__Step__c>();
            //checkDealRejection = [select id,NSIBPM__SR__c from NSIBPM__Step__c where NSIBPM__Step_Template__r.NSIBPM__Code__c='UPLOAD_POP' and NSIBPM__SR__c =:srId];
            
            //if(checkDealRejection.size() > 0){
                //return 'Deal Reinstatement step already exist';   
            //}else{
            
                NSIBPM__SR_Template__c template = new NSIBPM__SR_Template__c();
                template = [select id,(select id,NSIBPM__Start_Status__c,NSIBPM__Step_Template__c,NSIBPM__SR_Steps__c.OwnerId,NSIBPM__Step_No__c,NSIBPM__SR_Template__r.Name from  NSIBPM__SR_Steps_SR_Template__r where NSIBPM__Step_Template_Code__c='UPLOAD_POP' and
                            NSIBPM__Start_Status__c!=null and 
                            NSIBPM__Step_Template__c!=null and 
                            ownerid != null and 
                            NSIBPM__Step_No__c!=null LIMIT 1 ) from NSIBPM__SR_Template__c where Name='Deal' limit 1];
                            
                system.debug(template+'>>>');
                system.debug(template.NSIBPM__SR_Steps_SR_Template__r +'>>>');
                
                    if(template.NSIBPM__SR_Steps_SR_Template__r  != null){
                        try{            
                            NSIBPM__Step__c newStep = new NSIBPM__Step__c();
                            newStep.NSIBPM__SR__c = srId;
                            newStep.NSIBPM__SR_Step__c = template.NSIBPM__SR_Steps_SR_Template__r[0].id;
                            newStep.NSIBPM__Status__c =  template.NSIBPM__SR_Steps_SR_Template__r[0].NSIBPM__Start_Status__c;
                            newStep.NSIBPM__Step_Template__c = template.NSIBPM__SR_Steps_SR_Template__r[0].NSIBPM__Step_Template__c;
                            newStep.OwnerId = template.NSIBPM__SR_Steps_SR_Template__r[0].ownerid;
                            newStep.NSIBPM__Step_No__c  = template.NSIBPM__SR_Steps_SR_Template__r[0].NSIBPM__Step_No__c;
                            newStep.NSIBPM__Sys_Step_Loop_No__c= template.NSIBPM__SR_Steps_SR_Template__r[0].NSIBPM__Step_No__c+'_1';               
                            insert newStep;
                            return 'success';
                        }catch(exception e){
                            return 'error';
                        }
                    }else {
                        return 'No Sufficient Data on SR';
                    }
                //}// End of Main Else
        //}else{
        //    return 'Reinstatement cannot be done, Please contact your Administrator';
        //}
                
    }
    
    /*
    Name:preChecksForReinstatement
    Desc:To check various conditions before creating Deal Reinstatement Step on SR from Detail Page Button.
    */
    public static boolean preChecksForReinstatement(string srId){ 
        string sridval = srId.substring(0, 15);           
        //Get all Booking Units for the SR and all units with same area.
        list<Booking_Unit__c> bookingUnits = new list<Booking_Unit__c>();
        bookingUnits = [select id from Booking_Unit__c where SR_Id__c=:sridval LIMIT 50000];
        system.debug(bookingUnits); 
        
        if(bookingUnits.size() >0){    
            List<AggregateResult> bookingUnitsWithSameArea = new List<AggregateResult>();
            integer bookingUnitsWithSameAreaCount;            
            bookingUnitsWithSameArea = [select count(id) countval from Booking_Unit__c where SR_Id__c=:sridval and Is_Same_Area__c=:true and Release_Check__c='N'];
            system.debug(bookingUnitsWithSameArea[0].get('countval'));  
            if(bookingUnitsWithSameArea[0].get('countval') != null) {             
                bookingUnitsWithSameAreaCount = integer.valueof(bookingUnitsWithSameArea[0].get('countval'));
            }  
            system.debug(bookingUnits.size()+'--'+bookingUnitsWithSameAreaCount);              
            if(bookingUnits.size() == bookingUnitsWithSameAreaCount){       
                return true;
            } else {
                return false;
            }              
        }else{
            return false;
        }      
    }
    
}