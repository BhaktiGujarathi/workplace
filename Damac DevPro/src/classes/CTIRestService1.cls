/**************************************************************************************************
* Name               : CTIRestService1                                                 
* Description        :                                              
* Created Date       :                                                                      
* Created By         :                                                            
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     		AUTHOR                    DATE           Description                                                         
* 1.0         
* 1.1 #413 #415   	NSI-Sivasankar            23-03-2017
* 1.2 #411   		NSI-Sivasankar            23-03-2017
* 1.3 #434          NSI-Sivasankar            26-03-2017     Adding the Campaign language filters
***************************************************************************************************/
@RestResource(urlMapping='/CTIRestService1/*')
global class CTIRestService1 {
    public static Boolean isDuplicateFound = false;
    global class RequestHandler{
       	public string callingNumber {get;set;}
        public string calledNumber {get;set;}
        public List<String> pcExt {get;set;}
        public RequestHandler(){
            this.callingNumber = '';
            this.calledNumber = '';
            this.pcExt = new List<String>();
        }
    }
    
    global class ResponseHandler{
        public List<String> pcList {get; set;}
        public Integer flag;
        public Integer errorCode;
        public string errorStatus;
        public ResponseHandler(){
            this.pcList = new List<String>();
            this.flag = 0;
            this.errorCode = 200;
            this.errorStatus = 'Successful';
        }
    }
    
    @HttpPost
    global static ResponseHandler getCallingpcList(){  
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        ResponseHandler result = new ResponseHandler();
        Map<Id, String> pcExtMap = new Map<Id, String>();
        Date todayDate = Date.today();
        Map<Id, String> mapCampaignLanguage = new Map<Id, String>();//V1.3
        Map<Id, List<User>> campaignAssociatedPcMap = new Map<Id, List<User>>();
        Map<String, Boolean> mapUsersEligibleForBreak = new Map<String, Boolean>();
        try{
            RequestHandler req = (RequestHandler)JSON.deserializeStrict(request.requestBody.toString(), RequestHandler.class);
            system.debug('#### Rest Request = '+req);
            Set<Id> campaignIdsSet = new Set<Id>();

            for(JO_Campaign_Virtual_Number__c thisRecord : [SELECT Id, Related_Campaign__c, Related_Virtual_Number__c, Related_Virtual_Number__r.Name
            												FROM JO_Campaign_Virtual_Number__c 
															WHERE Related_Virtual_Number__r.Name =: req.calledNumber 
                                                                AND Related_Campaign__r.Marketing_Start_Date__c <=: todayDate 
                                                                AND Related_Campaign__r.Marketing_End_Date__c >=: todayDate]){//V1.1 Adding the date filters to get active campaign only
            	System.debug('!@#thisRecord = '+thisRecord);
            	campaignIdsSet.add(thisRecord.Related_Campaign__c);	
                
            }
            
            //V1.1.Start
            result.pcList = checkforDuplicateLeadOrAccount(req.pcExt,req.callingNumber);
            //V1.1.End
            System.debug('#@!!campaignIdsSet = '+campaignIdsSet);
            System.debug('isDuplicateFound = '+isDuplicateFound);
            System.debug('result.pcList = '+result.pcList);

            if(!campaignIdsSet.isEmpty() && !isDuplicateFound ){ 
            	for(Campaign__c thisCampaign : [SELECT Id, Campaign_Name__c, Language__c,//V1.3
							            			   (SELECT Id, User__c, User__r.Name, User__r.Extension,User__r.Eligible_for_break__c,//adding Eligible for Break field
							            			   		   User__r.Languages_Known__c, User__r.Date_of_Joining__c
							            				FROM Assigned_PCs__r 
							            			    WHERE User__r.Extension IN: req.pcExt
                                                            AND Start_Date__c <=: todayDate
                                                            AND End_Date__c >=: todayDate ) 
												 FROM Campaign__c 
												 WHERE Campaign__c.Id IN: campaignIdsSet]){
            		List<User> userList = new List<User>();
            		
            		for(Assigned_PC__c assignedPC : thisCampaign.Assigned_PCs__r){
            			//if(!assignedPC.User__r.Eligible_for_break__c){//Eligible for Break or not
            				mapUsersEligibleForBreak.put(assignedPC.User__r.Extension,assignedPC.User__r.Eligible_for_break__c);
                            pcExtMap.put(assignedPC.User__c, assignedPC.User__r.Extension);	
                			User associatedUser = new User();
    						associatedUser.Id = assignedPC.User__c;
    						associatedUser.Extension = assignedPC.User__r.Extension;
    						associatedUser.Languages_Known__c = assignedPC.User__r.Languages_Known__c;
    						associatedUser.Date_of_Joining__c = assignedPC.User__r.Date_of_Joining__c;
    						
    						if(String.isBlank(thisCampaign.Language__c) 
                            || (assignedPC.User__r.Languages_Known__c != null && (assignedPC.User__r.Languages_Known__c.containsIgnoreCase(thisCampaign.Language__c)
                            || assignedPC.User__r.Languages_Known__c.containsIgnoreCase(DAMAC_Constants.DEFAULT_LANGUAGE)))){//V1.3
    							userList.add(associatedUser);	
                        	}
            			//}
            		}
            		System.debug('userList = '+userList.size());
            		System.debug('mapUsersEligibleForBreak = '+mapUsersEligibleForBreak);
            		
            		mapCampaignLanguage.put(thisCampaign.Id,thisCampaign.Language__c);
            		campaignAssociatedPcMap.put(thisCampaign.Id, userList);
            	}	
            }

            if(!campaignAssociatedPcMap.isEmpty() && !pcExtMap.isEmpty()){
            	//result.pcList = getSortedPcsList(pcExtMap, campaignAssociatedPcMap);//V1.2
            	List<String> campaignLanguageUsers = new List<String>();//V1.3
            	List<String> defaultLanguageUsers = new List<String>();//V1.3

            	for(String extNumber : getSortedPcsList(pcExtMap, campaignAssociatedPcMap)){//V1.2 
            		//V1.3.Start
            		for(ID campaignID : campaignAssociatedPcMap.keySet()){
            			if(mapCampaignLanguage != null && mapCampaignLanguage.containsKey(campaignID) 
            				&& mapCampaignLanguage.get(campaignID) != null){
            				for(User campaignUser : campaignAssociatedPcMap.get(campaignID)){
            					if(campaignUser.Languages_Known__c.containsIgnoreCase(mapCampaignLanguage.get(campaignID)) && extNumber == campaignUser.Extension ){
            						campaignLanguageUsers.add(extNumber);
            					}
            				}
        				}
            		}
            		defaultLanguageUsers.add(extNumber);
            		//V1.3.End
            	}
            	System.debug('@#@#campaignLanguageUsers = '+campaignLanguageUsers);
                System.debug('@#@#defaultLanguageUsers = '+defaultLanguageUsers);
                Set<String> setExtNumbers = new Set<String>();
            	for(String extNumber : (campaignLanguageUsers != null && campaignLanguageUsers.size() > 0 ? campaignLanguageUsers: defaultLanguageUsers)){
            		if(!setExtNumbers.contains(extNumber) && 
            			mapUsersEligibleForBreak != null && 
            			mapUsersEligibleForBreak.containsKey(extNumber) && 
            			!mapUsersEligibleForBreak.get(extNumber)){
            				
                        result.pcList.add(extNumber);
                        setExtNumbers.add(extNumber);
                    }
            		if(result.pcList.size() == 3){ break;}
            	}
            	System.debug('@#@#Before result.pcList = '+result.pcList);
            	if(result.pcList.size() <= 1)
            	for(String extNumber : (campaignLanguageUsers != null && campaignLanguageUsers.size() > 0 ? campaignLanguageUsers: defaultLanguageUsers)){
            		if(!setExtNumbers.contains(extNumber)){
                        result.pcList.add(extNumber);
                        setExtNumbers.add(extNumber);
                    }
            		if(result.pcList.size() == 3){ break;}
            	}
            	System.debug('@#@#After result.pcList = '+result.pcList);
            	/*if(result.pcList != null && result.pcList.size() > 1){
            		result.flag = 1;	
            	}*/	
            } 
			System.debug('result.pcList = '+result.pcList.size());
            if(result.pcList != null && result.pcList.size() > 1){
                result.flag = 1;    
            }

            system.debug(req.pcExt);
            system.debug(req.calledNumber);
            system.debug(result.pcList);
        }catch (exception ex) {
            result.errorCode = 400;
            result.errorStatus = ex.getMessage();
        }
        Log__c incomingRequest = new Log__c(Description__c= JSON.serialize(request.requestBody),Type__c='CTIRestService1-Request');
        Log__c outgoingResponse = new Log__c(Description__c= JSON.serialize(result),Type__c='CTIRestService1-Response');
        List<Log__c> lstLog = new List<Log__c>();
        lstLog.add(incomingRequest);
        lstLog.add(outgoingResponse);
        insert lstLog;
        System.debug('Response result = '+result);
        return result;
    }
    
    private static List<String> getSortedPcsList(Map<Id, String> pcExtMap, Map<Id, List<User>> campaignAssociatedPcMap){
    	system.debug('#### pcExtMap = '+pcExtMap);
    	system.debug('#### campaignAssociatedPcMap = '+campaignAssociatedPcMap);
    	List<String> eligiblePcsSortedList = new List<String>();
    	/* Calling method to get the list of inquiry associated to the PC. */
    	InquiryTriggerHandler itObject = new InquiryTriggerHandler();
    	Map<Id, List<Id>> campaignUserSortedByLoad = itObject.getUserWithLoad(campaignAssociatedPcMap);
    	system.debug('#### campaignUserSortedByLoad = '+campaignUserSortedByLoad);
    	for(Id thisKey : campaignUserSortedByLoad.keySet()){
    		for(Id sortedPcsId : campaignUserSortedByLoad.get(thisKey)){
    			if(pcExtMap.containsKey(sortedPcsId)){
    				eligiblePcsSortedList.add(pcExtMap.get(sortedPcsId));		
    			}
    		}	
    	}
    	system.debug('#### eligiblePcsSortedList = '+eligiblePcsSortedList);
    	return eligiblePcsSortedList;
    	
    }

    //V1.1.Start
    @Testvisible private static List<String> checkforDuplicateLeadOrAccount(List<String> lstPcExt,String callingNumber){
        List<String> userExtNos = new List<String>();
        Set<String> setPcExt = new Set<String>(lstPcExt);
        if(String.isNotblank(callingNumber)){
            callingNumber = '%'+callingNumber+'%';

            Map<String, Profile> nameProfileMap = DamacUtility.getProfileDetails(new Set<String>{DAMAC_Constants.PC_PROFILE});
            Profile propertyConsultant = nameProfileMap.get(DAMAC_Constants.PC_PROFILE);
            Map<Id,User> mapPCUsers = InquiryService.getUserDetailsByProfile(propertyConsultant.Id);
            System.debug('setPcExt = '+setPcExt);
            //Check the calling customer is already existed or not
            for( Account existingCustomer : [SELECT Id,OwnerId  
                                             FROM Account 
                                                WHERE IsPersonAccount = true AND Owner.Extension IN: lstPcExt 
                                                    AND (PersonAssistantPhone LIKE:callingNumber OR PersonHomePhone LIKE:callingNumber 
                                                        OR PersonMobilePhone LIKE:callingNumber OR PersonOtherPhone LIKE: callingNumber
                                                        OR Phone LIKE:callingNumber OR Mobile__c LIKE: callingNumber 
                                                        OR Send_SMS_to_Mobile__c LIKE: callingNumber OR Telephone__c LIKE:callingNumber ) ]) {
                System.debug('== existingCustomer = '+existingCustomer);
                System.debug('== 1 = '+(mapPCUsers != null));
                System.debug('== 2 = '+(!mapPCUsers.isEmpty()));
                System.debug('== 3 = '+(mapPCUsers.containsKey(existingCustomer.OwnerId)));
                System.debug('== 3 = '+(mapPCUsers.get(existingCustomer.OwnerId).Extension != null));
                System.debug('== 4 = '+(setPcExt.contains(mapPCUsers.get(existingCustomer.OwnerId).Extension)));
                
                if(mapPCUsers != null && !mapPCUsers.isEmpty() && mapPCUsers.containsKey(existingCustomer.OwnerId)
                    && mapPCUsers.get(existingCustomer.OwnerId).Extension != null && setPcExt.contains(mapPCUsers.get(existingCustomer.OwnerId).Extension))
                    userExtNos.add(mapPCUsers.get(existingCustomer.OwnerId).Extension);
                isDuplicateFound = true;
            }
            System.debug('callingNumber= '+callingNumber);
            //if the list is empty then only execute the below logic
            if(userExtNos.isEmpty()){
                Inquiry__c tempEligibleInquiry = new Inquiry__c();
                InquiryService InquiryServiceObj = new InquiryService();
                Id inquiryRecordTypeId = Schema.SObjectType.Inquiry__c.getRecordTypeInfosByName().get(DAMAC_Constants.INQUIRY_RT).getRecordTypeId();
                for(Inquiry__c eligibleInqury : [SELECT Id, Inquiry_Status__c, Campaign__c,OwnerID,// OwnerId,Owner.Extension,
                                                     (SELECT ID,CreatedDate FROM Tasks ORDER By CreatedDate DESC LIMIT 1),
                                                     (SELECT ID,CreatedDate FROM Events ORDER By CreatedDate DESC LIMIT 1)
                                              FROM Inquiry__c 
                                              WHERE Duplicate__c = false AND 
                                                (Inquiry_Status__c =: DAMAC_Constants.INQUIRY_ACTIVE_STATUS OR
                                                 Inquiry_Status__c =: DAMAC_Constants.INQUIRY_NEW_STATUS) 
                                                 //AND Inquiry_Source__c !=: DAMAC_Constants.PROSPECTING_BY_PC_SOURCE 
                                                 //AND Inquiry_Source__c !=: DAMAC_Constants.AGENT_REFERAL_STATUS 
                                                 AND RecordTypeId =: inquiryRecordTypeId //AND Owner.Extension IN:lstPcExt 
                                                    AND (Mobile_Phone__c LIKE :callingNumber  OR Mobile_Phone_2__c LIKE :callingNumber  
                                                    OR Mobile_Phone_3__c LIKE :callingNumber OR Mobile_Phone_4__c LIKE :callingNumber 
                                                    OR Mobile_Phone_5__c LIKE :callingNumber)  
                                              Order by CreatedDate ASC]){
                    System.debug('eligibleInqury = '+eligibleInqury);
                    if( eligibleInqury.Inquiry_Status__c != null 
                        && (eligibleInqury.Inquiry_Status__c.containsIgnoreCase(DAMAC_Constants.INQUIRY_ACTIVE_STATUS) 
                            || eligibleInqury.Inquiry_Status__c.containsIgnoreCase(DAMAC_Constants.INQUIRY_NEW_STATUS)) 
                        && (tempEligibleInquiry.Id == null 
                            || (tempEligibleInquiry.Inquiry_Status__c != eligibleInqury.Inquiry_Status__c 
                                && eligibleInqury.Inquiry_Status__c.containsIgnoreCase(DAMAC_Constants.INQUIRY_ACTIVE_STATUS)) 
                            || (InquiryServiceObj.getLatestDate(tempEligibleInquiry) < InquiryServiceObj.getLatestDate(eligibleInqury)) )){

                        tempEligibleInquiry = eligibleInqury;

                    }
                }
                System.debug('tempEligibleInquiry = '+tempEligibleInquiry);
                System.debug('mapPCUsers = '+mapPCUsers);
                if(tempEligibleInquiry.id != null) { 
                    isDuplicateFound = true;
                    if(mapPCUsers != null && !mapPCUsers.isEmpty() && mapPCUsers.containsKey(tempEligibleInquiry.OwnerId)
                    && mapPCUsers.get(tempEligibleInquiry.OwnerId).Extension != null && setPcExt.contains(mapPCUsers.get(tempEligibleInquiry.OwnerId).Extension)){
                        userExtNos.add(mapPCUsers.get(tempEligibleInquiry.OwnerId).Extension);
                    }
                }
                //Create the follow up task when user missed the call
                if(isDuplicateFound && userExtNos.isEmpty() && userExtNos.size() == 0 && tempEligibleInquiry != null && tempEligibleInquiry.id != null){
		        	Task duplicateFollowUpTask = new Task(Subject='Call',OwnerID=tempEligibleInquiry.OwnerID,Task_Due_Date__c=System.now().addHours(2),WhatID=tempEligibleInquiry.id,Description='You have missed the call',Type='Call',Status='Not Started');
		        	insert duplicateFollowUpTask;
		        }
            }
        }
        
        System.debug('userExtNos = '+userExtNos);
        
        return userExtNos;
    }
    //V1.1.End
}// End of class.