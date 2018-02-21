public with sharing class CallingListGenerator {
    
    public void onAfterInsert( list<Case> lstNewCases ) {
        if( lstNewCases != null && !lstNewCases.isEmpty() ) {
            list<Case> lstCasesForCallingList = new list<Case>();
            for( Case objCase : lstNewCases ) {
                if( String.isNotBlank( objCase.Bounced_Reason__c ) && !objCase.Do_Not_Call__c ) {
                    lstCasesForCallingList.add( objCase );
                }
            }
            generateCallingList( lstCasesForCallingList );
        }
    }
    
    public void onAfterUpdate( list<Case> lstUpdatedCases, map<Id, Case> mapOldCases ) {
        if( lstUpdatedCases != null && !lstUpdatedCases.isEmpty() &&
            mapOldCases != null && !mapOldCases.isEmpty() ) {
            list<Case> lstCasesForCallingList = new list<Case>();
            for( Case objCase : lstUpdatedCases ) {
                if( objCase.Bounced_Reason__c != null && 
                    String.isBlank( mapOldCases.get( objCase.Id ).Bounced_Reason__c ) && 
                    !objCase.Do_Not_Call__c ) {
                    lstCasesForCallingList.add( objCase );
                }
            }
            generateCallingList( lstCasesForCallingList ) ;
        }
    }
    
    public void generateCallingList( list<Case> lstCasesForCallingList ) {
        if( lstCasesForCallingList != null && !lstCasesForCallingList.isEmpty() ) {
            list<Calling_List__c> lstBounceChequeCalling = new list<Calling_List__c>();
            Id ownerId = CallingListUtility.getGroupIdFromDeveloperName( 'Collection_Manager_Queue','Queue' );
            
            list<ID> lstCaseId = new list<ID>();
            for( Case objCase : lstCasesForCallingList ){
                lstCaseId.add(objCase.id);
            }
            list<Case> lstCase = new list<Case>();
            lstCase = [Select Id,CaseNumber, SR_Type__c, Booking_Unit__c,RecordType.developerName,
                      (select id,Case__c,Booking_Unit__c from SR_Booking_Units__r where Booking_Unit__c != null)
                      from Case 
                      Where Booking_Unit__c = null 
                      AND id IN: lstCaseId];            
            
            map<ID,List<SR_Booking_Unit__c>> mapSRBookingUnit = new map<ID,List<SR_Booking_Unit__c>>();
            map<ID,List<ID>> mapOpenSR = new map<ID,List<ID>>();
            list<ID> lstBookingUnitID = new list<ID>();
            list<SR_Booking_Unit__c> lstSRbookingUnit = new list<SR_Booking_Unit__c>();
            
            for(Case objCase : lstCase){
                if(objCase.SR_Booking_Units__r.Size()>0){
                    mapSRBookingUnit.put(objCase.id,objCase.SR_Booking_Units__r);
                    for(SR_Booking_Unit__c objSRbooking : objCase.SR_Booking_Units__r){
                        lstBookingUnitID.add(objSRbooking.Booking_Unit__c);
                    }
                }
            }            
            if(!lstBookingUnitID.isEmpty()){
                lstSRbookingUnit = [Select id,Case__c,Case__r.id,Case__r.SR_Type__c,Case__r.CaseNumber,
                                   Case__r.RecordType.developerName,
                                   Booking_Unit__c from SR_Booking_Unit__c where
                                   Booking_Unit__c IN : lstBookingUnitID
                                   AND Booking_Unit__c != null
                                   AND Case__c != null                           
                                   AND Case__r.Status != 'Closed'
                                   AND Case__r.Status != 'Rejected'
                                   AND Case__r.RecordType.developerName = 'AOPT'];
                
            }
            
            for(SR_Booking_Unit__c objSRbookingUnit : lstSRbookingUnit){                           
                if(mapOpenSR.containsKey(objSRbookingUnit.Booking_Unit__c)){
                    list<ID> lstBookingUnitCasesID = new list<ID>();
                    lstBookingUnitCasesID = mapOpenSR.get(objSRbookingUnit.Booking_Unit__c);                                        
                    lstBookingUnitCasesID.add(objSRbookingUnit.Case__r.id);                
                    mapOpenSR.put(objSRbookingUnit.Booking_Unit__c,lstBookingUnitCasesID);   
                }
                else{
                    list<ID> lstBookingUnitNewCaseID = new list<ID>();               
                    lstBookingUnitNewCaseID.add(objSRbookingUnit.Case__r.id);                               
                    mapOpenSR.put(objSRbookingUnit.Booking_Unit__c,lstBookingUnitNewCaseID); 
                }
            }
            
            for( Case objCase : lstCasesForCallingList ) {
                Calling_List__c objCalling = new Calling_List__c();
                objCalling.Calling_List_Type__c = 'BC Calling';
                objCalling.Case__c = objCase.Id ;
                objCalling.Calling_List_Status__c = 'New';                                                           
                
                            
                if(!lstSRbookingUnit.isEmpty()){
	                if(mapSRBookingUnit.containsKey(objCase.id)){
	                    list<SR_Booking_Unit__c> lstSRBookingUnitCase = new list<SR_Booking_Unit__c>();
	                    lstSRBookingUnitCase = mapSRBookingUnit.get(objCase.id);
	                    objCalling.AOPT_Open_Cases_ID__c = '';                    
	                    Set<ID> setAOPTid = new Set<ID>();
	                    
	                    for(SR_Booking_Unit__c objSRbooking : lstSRBookingUnitCase){
	                        if(mapOpenSR.containsKey(objSRbooking.booking_unit__c)){
	                            objCalling.AOPT_Under_Process__c = true;
	                            List<ID> lstID = new List<ID>();
	                            lstID = mapOpenSR.get(objSRbooking.booking_unit__c);
	                            setAOPTid.addAll(lstID);
	                            
	                        }
	                    }                    
	                    for(ID objID : setAOPTid){                                               
	                        objCalling.AOPT_Open_Cases_ID__c += objID+',';                                                      
	                    }                                                   
	                    if(objCalling.AOPT_Open_Cases_ID__c.Contains(',')){
	                        objCalling.AOPT_Open_Cases_ID__c = objCalling.AOPT_Open_Cases_ID__c.removeEnd(',');                       
	                    }                        
	                }  
                }
                          
                if( objCase.AccountId != null ) {
                    objCalling.Account__c = objCase.AccountId ;
                }
                if( String.isNotBlank( ownerId ) ) {
                    objCalling.OwnerId = ownerId ;
                }
                objCalling.Call_Date__c = system.now();
                lstBounceChequeCalling.add( objCalling );
            }
            
            if( lstBounceChequeCalling != null && !lstBounceChequeCalling.isEmpty() ) {
                insert lstBounceChequeCalling ;
                
                list<AOPT_Case__c> lstAOPTcase = new list<AOPT_Case__c>();
                
                for(Calling_List__c objCall : lstBounceChequeCalling){
                    if(String.isNotBlank(objCall.AOPT_Open_Cases_ID__c)){                        
                        list<String> lstAOPTcaseId = new list<String>();
                        if(objCall.AOPT_Open_Cases_ID__c.contains(',')){
                            lstAOPTcaseId = objCall.AOPT_Open_Cases_ID__c.split(',');
                        }
                        else{
                            lstAOPTcaseId.add(objCall.AOPT_Open_Cases_ID__c); // if only 1 id present
                        }
                        for(String strCaseId : lstAOPTcaseId){
                            AOPT_Case__c objAOPTcase = new AOPT_Case__c();
                            objAOPTcase.Case__c = strCaseId;
                            objAOPTcase.Calling_List__c = objCall.id;
                            lstAOPTcase.add(objAOPTcase);                                                   
                        }                                                                     
                        
                    }
                }
                if(lstAOPTcase.Size()>0){
                    insert lstAOPTcase;
                }
            }
        }
    }
    
}