/*
* SR -> All Bookings -> All Booking Units -> if(DP_OK__c) is checked then on SR -> DP_OK__c should be checked.
* 
*/ 
public class BookingUnitTriggerHandler {
    public static Map<Id,Boolean> mpSRRegStatusCodeLE;
    public static Map<Id,Boolean> mpSRRegStatusCodeAR;
    
    private static User getUserDetails(){
    	User currentUser = [SELECT Id, HR_Employee_ID__c, IPMS_Employee_ID__c, HOS_Name__c, Sales_Office__c, ManagerId, Manager.Name, Manager.HR_Employee_ID__c, 
    	Manager.IPMS_Employee_ID__c FROM User WHERE Id=: UserInfo.getUserId() LIMIT 1];
    	return currentUser;	
    }
    
    public static void updateCampaignTotal(Map<Id, Booking_Unit__c> newBookingUnit){
    	Map<Id, Decimal> campaignTotalMap = new Map<Id, Decimal>();
    	Set<Id> campaignIds = new Set<Id>();
    	List<Booking_Unit__c> bookingUnitsList = new List<Booking_Unit__c>();
    	List<Campaign__c> updateCampaignList = new List<Campaign__c>();
    	Map<Id, List<Booking_Unit__c>> campaignBookingMap = new Map<Id, List<Booking_Unit__c>>();
    	
    	system.debug(newBookingUnit);
    	try{
	    	for(Booking_Unit__c thisBookingUnit : newBookingUnit.values()){
	    		if(String.isNotBlank(thisBookingUnit.Status__c) && !thisBookingUnit.Status__c.equalsIgnoreCase('Removed') && 
	    		   String.isNotBlank(thisBookingUnit.Related_Campaign__c )){
	    			campaignIds.add(thisBookingUnit.Related_Campaign__c);
	    		}
	    	}
	    	
	    	for(Booking_Unit__c thisBookingUnit : [SELECT Id, Related_Campaign__c, Requested_Price_AED__c, Status__c FROM Booking_Unit__c WHERE Related_Campaign__c IN :campaignIds]){
	    		if(campaignBookingMap.containsKey(thisBookingUnit.Related_Campaign__c)){
	    			campaignBookingMap.get(thisBookingUnit.Related_Campaign__c).add(thisBookingUnit);		
	    		}else{
	    			campaignBookingMap.put(thisBookingUnit.Related_Campaign__c, new List<Booking_Unit__c>{ thisBookingUnit });	
	    		}	
	    	}
	    	
	    	Decimal totalSum;
	    	if(!campaignBookingMap.isEmpty()){
	    		for(Id campaignId : campaignBookingMap.keySet()){
		    		Campaign__c thisCampaign = new Campaign__c();
		    		thisCampaign.Id = campaignId;
		    		totalSum = 0.00;
		    		for(Booking_Unit__c thisBookingUnit: campaignBookingMap.get(campaignId)){
		    			totalSum += thisBookingUnit.Requested_Price_AED__c;
		    		}
		    		system.debug(totalSum);
		    		thisCampaign.Total_Sales__c = totalSum;
		    		updateCampaignList.add(thisCampaign);
	    		}	
	    	}
	
	    	if(!updateCampaignList.isEmpty()){
	    		update updateCampaignList;	
	    	}
    	}catch(Exception ex){
    		System.debug('Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage());
    	}
    } 
    
    public static void updateBookingUnitType(Map<Id, Booking_Unit__c> newBookingUnitMap, Map<Id, Booking_Unit__c> oldBookingUnitMap){
    	 
    	List<Booking_Unit__c> updateBookingUnitList = new List<Booking_Unit__c>();
    	try{
	    	if((Trigger.isUpdate || Trigger.isInsert) && newBookingUnitMap!=null && !newBookingUnitMap.isEmpty()){
	    		system.debug('inside the if');
		    	for(Booking_Unit__c thisBookingUnit : newBookingUnitMap.values()){
		    		if(String.isNotBlank(thisBookingUnit.Primary_Buyer_Country__c) && String.isNotBlank(thisBookingUnit.Property_Country__c)){
		    			if(thisBookingUnit.Primary_Buyer_Country__c.equalsIgnoreCase(thisBookingUnit.Property_Country__c)){
			    			thisBookingUnit.Booking_Unit_Type__c = 'Local';
			    		}else{
			    			thisBookingUnit.Booking_Unit_Type__c = 'International';
			    		}
			    		updateBookingUnitList.add(thisBookingUnit);
		    		}
		    	}
	    	}
    	}catch(Exception ex){
    		System.debug('Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage());
    	}
    }
    
    public static void updateBookingUnits(List<Booking_Unit__c> bookingUnitList){
    	
    	User currentUser = getUserDetails();
    	
    	for(Booking_Unit__c BU: bookingUnitList){
    		BU.HR_Employee_ID__c = currentUser.HR_Employee_ID__c;
    		BU.IPMS_Employee_ID__c = currentUser.IPMS_Employee_ID__c;
    		BU.HOS_Name__c = currentUser.HOS_Name__c;
    		BU.Sales_Office__c = currentUser.Sales_Office__c;
    		if(currentUser.ManagerId != null){
	    		BU.Manager_Name__c = currentUser.Manager.Name;
	    		BU.Manager_IPMS_Employee_ID__c = currentUser.Manager.IPMS_Employee_ID__c;
	    		BU.Manager_HR_Employee_ID__c = currentUser.Manager.HR_Employee_ID__c;
    		}
    	}
    }
    
    public static void UpdateSR(List<ID> lstBUIDs){
        //Get all recent Update/Inserted BU
        Set<Id> SRIds = new Set<Id>();
        for(Booking_Unit__c BU : [select id,name,Booking__c,DP_OK__c,Booking__r.Deal_SR__c from Booking_Unit__c where id in : lstBUIDs and Status__c !='Removed'])
        {
            if(BU.Booking__c != null && BU.Booking__r.Deal_SR__c != null){
                SRIds.add(BU.Booking__r.Deal_SR__c);
            }
        }
        //Prepare map of SR ID with its respective Bookings
        Map<Id,List<Booking__c>> mpSRIDBookings = new Map<Id,List<Booking__c>>();
        for(Booking__c b : [select id,(select id,DP_OK__c,name,Token_Paid__c,Registration_Status_Code__c from Booking_Units__r where Status__c !='Removed'),Deal_SR__c from Booking__c where Deal_SR__c in : SRIds])
        {
            if(mpSRIDBookings.containsKey(b.Deal_SR__c)){
                List<Booking__c> tmp = mpSRIDBookings.get(b.Deal_SR__c);
                tmp.add(b);
                mpSRIDBookings.put(b.Deal_SR__c,tmp);
            }
            else{
                List<Booking__c> tmp = new List<Booking__c>();
                tmp.add(b);
                mpSRIDBookings.put(b.Deal_SR__c,tmp);
            }
        }
        List<NSIBPM__Service_Request__c> lstSRtoUpdate = new List<NSIBPM__Service_Request__c>();
        Map<Id,Boolean> mpSRVal = new Map<Id,Boolean>();
        Map<Id,Boolean> mpSRValTokenPaid = new Map<Id,Boolean>();
        mpSRRegStatusCodeLE = new Map<Id,Boolean>();
        mpSRRegStatusCodeAR = new Map<Id,Boolean>();
        //get all SR's for which the bookings units are updated
        for(id srID : mpSRIDBookings.keyset()){
            mpSRVal.put(srID,true);
            mpSRValTokenPaid.put(srID,true);
            mpSRRegStatusCodeLE.put(srID,true);
            mpSRRegStatusCodeAR.put(srID,true);
            //For each sr get all bookings.
            for(Booking__c b : mpSRIDBookings.get(srID))
            {
                //for each booking get all booking units.
                for(Booking_Unit__c bu: b.Booking_Units__r){
                    if(!bu.DP_OK__c){
                        mpSRVal.put(srID,false);
                    }
                    if(!bu.Token_Paid__c){
                        mpSRValTokenPaid.put(srID,false);
                    }
                    if(bu.Registration_Status_Code__c != 'LE'){
                        mpSRRegStatusCodeLE.put(srID,false);
                    }
                    if(bu.Registration_Status_Code__c != 'AR'){
                        mpSRRegStatusCodeAR.put(srID,false);
                    }
                }
            }
        }
        //Update SR's with its field.
        if(mpSRVal != null && !mpSRVal.isempty()){
            List<NSIBPM__Service_Request__c> lstSRs = [select id,name,DP_ok__c,Token_Deposit_Paid_Date_Time__c from NSIBPM__Service_Request__c where id in : mpSRVal.keyset()];
            /*for(id srID : mpSRVal.keyset()){
                
                lstSRtoUpdate.add(new NSIBPM__Service_Request__c(id=srID,DP_ok__c=mpSRVal.get(srID),Token_Deposit_Paid_Date_Time__c= (mpSRValTokenPaid.get(srID))? system.now(): null));
            }*/
            for(NSIBPM__Service_Request__c sr : lstSRs){
                boolean ischange = false;
                NSIBPM__Service_Request__c objsr = new NSIBPM__Service_Request__c();
                if(sr.DP_ok__c != mpSRVal.get(sr.id)){
                    objsr.DP_ok__c = mpSRVal.get(sr.id);
                    ischange=true;
                }
                if(sr.Token_Deposit_Paid_Date_Time__c == null && mpSRValTokenPaid.get(sr.id)){
                    objsr.Token_Deposit_Paid_Date_Time__c= mpSRValTokenPaid.get(sr.id) ? system.now(): null;
                    ischange=true;
                }
                if(ischange){
                    objsr.id = sr.id;
                    lstSRtoUpdate.add(objsr);
                }                               
            }
            update lstSRtoUpdate;
            UpdateStepStatus(mpSRVal.keyset());
        }else if(mpSRRegStatusCodeLE != null && !mpSRRegStatusCodeLE.isempty()){
            updatestepstatus(mpSRRegStatusCodeLE.keyset());
        }
    }
    
    
    Public static void UpdateStepStatus(set<Id> stSRIds){
        //Update any open steps related to DP OK
        List<String> lststepandStpStatusConstants = String.valueof(Label.MapSteptoStepStatus).split(',');
        Map<string,string> mpStepCodeStatusCode = new Map<string,string>();
        
        for(integer i =1;i<= lststepandStpStatusConstants.size()/2 ;i++){
            integer indx = (i*2)-1;
            mpStepCodeStatusCode.put(string.valueof(lststepandStpStatusConstants[indx-1]),string.valueof(lststepandStpStatusConstants[indx]));
                
        } 
        Map<string,Id> mpstatus = new Map<string,Id>();
        Map<id,string> srIdStatusUpdate = new Map<id,string>();
        for(NSIBPM__Status__c stpStatus : [select id,name,NSIBPM__Code__c from NSIBPM__Status__c where NSIBPM__Code__c in : mpStepCodeStatusCode.values()]){
            mpstatus.put(stpStatus.NSIBPM__Code__c,stpStatus.id);
        }
        system.debug('---mpstatus-->'+mpstatus);
        List<NSIBPM__Step__c> lststepstoUpdate = new List<NSIBPM__Step__c>();
        for(NSIBPM__Step__c stp:[SELECT Id, Name,NSIBPM__Status__c,NSIBPM__SR__r.DP_ok__c,NSIBPM__Step_Template__r.NSIBPM__Code__c,NSIBPM__SR__r.id,
                                 NSIBPM__SR__r.Token_Deposit_Paid_Date_Time__c FROM NSIBPM__Step__c where 
                                 NSIBPM__SR__c != null and (NSIBPM__SR__c in : stSRIds) and NSIBPM__SR__r.NSIBPM__SR_Template__c!=null and IsDeleted=false
                                 and NSIBPM__Step_Template__r.NSIBPM__Code__c != null and NSIBPM__Step_Template__r.NSIBPM__Code__c in : mpStepCodeStatusCode.keyset()]){
                                     string statuscode = (mpStepCodeStatusCode.containskey(stp.NSIBPM__Step_Template__r.NSIBPM__Code__c)) ? mpStepCodeStatusCode.get(stp.NSIBPM__Step_Template__r.NSIBPM__Code__c) : '';
                                     id statusID = (statuscode != '' && mpstatus.containskey(statuscode)) ? mpstatus.get(statuscode) : null;
                                     system.debug('--->'+stp.NSIBPM__Step_Template__r.NSIBPM__Code__c+' -- '+statuscode+' -- '+statusID );
                                     if(statusID != null){
                                         if(stp.NSIBPM__SR__r.DP_ok__c == true && stp.NSIBPM__Status__c != statusID && stp.NSIBPM__Step_Template__r.NSIBPM__Code__c == 'DP_OK'){
                                             stp.NSIBPM__Status__c = statusID;
                                             lststepstoUpdate.add(stp);
                                         }
                                         else if(stp.NSIBPM__SR__r.Token_Deposit_Paid_Date_Time__c != null && stp.NSIBPM__Status__c != statusID && stp.NSIBPM__Step_Template__r.NSIBPM__Code__c == 'TOKEN_PAYMENT'){
                                             stp.NSIBPM__Status__c = statusID;
                                             lststepstoUpdate.add(stp);
                                             srIdStatusUpdate.put(stp.NSIBPM__SR__c,label.SR_Status_Token_Deposit_Paid);
                                         }
                                         else if(mpSRRegStatusCodeLE.get(stp.NSIBPM__SR__r.id) && stp.NSIBPM__Status__c != statusID && stp.NSIBPM__Step_Template__r.NSIBPM__Code__c == 'SPA_EXECUTION'){
                                             stp.NSIBPM__Status__c = statusID;
                                             lststepstoUpdate.add(stp);
                                             srIdStatusUpdate.put(stp.NSIBPM__SR__c,label.SPA_EXECUTED);
                                         }
                                     }
                                     system.debug('---lststepstoUpdate DP OK->'+lststepstoUpdate);
                                 }

        
        if(lststepstoUpdate != null && !lststepstoUpdate.isempty()){
            system.debug('---lststepstoUpdate size->'+lststepstoUpdate.size());
            update lststepstoUpdate;
            system.debug('---lststepstoUpdate->'+lststepstoUpdate);
        }
        
        set<Id> SRIdsStepstoCls = new set<Id>();
        for(id sridRej : stSRIds){
            if(mpSRRegStatusCodeAR.containsKey(sridRej) && mpSRRegStatusCodeAR.get(sridRej)){
                srIdStatusUpdate.put(sridRej,label.SR_Status_REJECTED);
                SRIdsStepstoCls.add(sridRej);
            }
        }
        
        if(srIdStatusUpdate != null && !srIdStatusUpdate.isempty()){
            List<NSIBPM__Service_Request__c> lstSRtoUpdate = new List<NSIBPM__Service_Request__c>();
            Map<string,Id> mpStatusCodeStatusid = new Map<string,id>();
            for(NSIBPM__SR_Status__c srSt : [select id,name,NSIBPM__Code__c from NSIBPM__SR_Status__c where NSIBPM__Code__c in : srIdStatusUpdate.values()]){
                mpStatusCodeStatusid.put(srst.NSIBPM__Code__c,srst.id);
            }
            system.debug('---mpStatusCodeStatusid->'+mpStatusCodeStatusid);
            for(id srid : srIdStatusUpdate.keyset()){
                if(srIdStatusUpdate.get(srid) != null && mpStatusCodeStatusid.containskey(srIdStatusUpdate.get(srid))){
                    id SRStatId = mpStatusCodeStatusid.get(srIdStatusUpdate.get(srid));
                    lstSRtoUpdate.add(new NSIBPM__Service_Request__c(id=srID,NSIBPM__Internal_SR_Status__c = SRStatId,NSIBPM__External_SR_Status__c = SRStatId));
                    system.debug('---lstSRtoUpdate SR->'+lstSRtoUpdate);
                }
            }
            if(null != lstSRtoUpdate && !lstSRtoUpdate.isempty()){
                update lstSRtoUpdate;
            }
            
            if(SRIdsStepstoCls != null && !SRIdsStepstoCls.isempty()){
                NSIBPM__Status__c cancelledStatus = [select id from NSIBPM__Status__c  where NSIBPM__Code__c='CANCELLED' LIMIT 1];
                //Get all steps of SR which are Open and set status to Cancelled
                list<NSIBPM__Step__c> getAllsteps = new list<NSIBPM__Step__c>();
                getAllsteps = [select id,NSIBPM__Status__c from NSIBPM__Step__c where NSIBPM__SR__c in : SRIdsStepstoCls and Is_Closed__c=:false];
                if(getAllsteps.size()>0){
                    for(NSIBPM__Step__c stp:getAllsteps){
                        stp.NSIBPM__Status__c = cancelledStatus.id;
                    }
                    update getAllsteps;
                }   
            } 
        }
    }
}