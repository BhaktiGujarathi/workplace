/*
* Name : Pavithra Gajendra
* Date : 01/19/2017
* Purpose : Handler to assign the Inquiry & check for duplicates . 
* Company : NSI Gulf
* Change History:
* CH01 # 337 # 13-03-2017 # Sivasankar # Adding logic to mask the mobile numbers
* CH02 # 362 # 13-03-2017 # Sivasankar # When Owner is changed then the status should be New
* CH03 # 380 # 15-03-2017 # Sivasankar # Update the User Block date
* CH04 # 352 # 15-03-2017 # Sivasankar # Chatter lead can't be auto assigned.
* CH05 # Enhancement # 15-03-2017 # Sivasankar # Popuate the Assigned To, Assigned By and Assigned Date
* CH06 # 351 # 18-03-2017 # Sivasankar # modifying the duplicate logic.
* CH07 # 04-06-2017 # Sivasankar # adding the logic for associated Campaign
* CH08 # 20-05-2017 # Rahul # Added method to roll up Inquiry count on parent marketing campaign
*/
public without sharing class InquiryTriggerHandler extends InquiryService implements TriggerFactoryInterface{ 
    
    public static Boolean loggedInUserPC = false ; 
    public static Boolean runAssignment = true ; 
    public List<Inquiry__c> inquiryToUpdate ; 
    public static Boolean noPCForCampaignOrProperty = false ;
    public static Map<Id,Date> userToTenureMap = new Map<Id,Date>();
    public static Boolean isAssignedToPopulated = false; 
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed before update.                       *
    * @Params      : Map<Id, sObject>, Map<Id, sObject>                                          *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeBeforeUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){
        try{
            system.debug('#### before Update trigger');
            system.debug(mapNewRecords.values());
            /*Masking the Mobile numbers */
            encryptMobileNumbers((List<Inquiry__c>)mapNewRecords.values());//CH01
            /*Update Score */
            updateInquiryScoreOnStatusChange((List<Inquiry__c>) mapNewRecords.values(),(Map<Id, Inquiry__c>) mapOldRecords);
            //CH05 update the Assigned fields
            updateAssignedFields((List<Inquiry__c>)mapNewRecords.values(),mapOldRecords);
            //Maping the Inquiry Status and source to Indexed fields.
            for(Inquiry__c thisInquiry: (List<Inquiry__c>) mapNewRecords.values()){
                thisInquiry.Inquiry_Status_Indexed__c = thisInquiry.Inquiry_Status__c;
                thisInquiry.Inquiry_Source_Indexed__c = thisInquiry.Inquiry_Source__c;
            }
            UpdateInquirySource((List<Inquiry__c>)mapNewRecords.values(), mapOldRecords);
        }catch(Exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception Message = '+ex.getMessage());  
        }
    }
    public void executeBeforeInsertUpdateTrigger(list<sObject> lstNewRecords, Map<Id,sObject> mapOldRecords){}
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed before insert.                       *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeBeforeInsertTrigger(List<sObject> lstNewRecords){ 
        try{
            system.debug('#### before insert trigger');
            system.debug(lstNewRecords);
            /*Masking the Mobile numbers */
            encryptMobileNumbers((List<Inquiry__c>)lstNewRecords);//CH01
            /* Check for duplicate check and run the corresponding assignment rules. */
            inquiryDuplicateCheckAndAssignment(lstNewRecords);
            //CH05 update the Assigned fields
            updateAssignedFields((List<Inquiry__c>)lstNewRecords,new Map<Id, sObject>());
            //Maping the Inquiry Status and source to Indexed fields.
            for(Inquiry__c thisInquiry: (List<Inquiry__c>)lstNewRecords){
                thisInquiry.Inquiry_Status_Indexed__c = thisInquiry.Inquiry_Status__c;
                thisInquiry.Inquiry_Source_Indexed__c = thisInquiry.Inquiry_Source__c;
            }
            UpdateInquirySource((List<Inquiry__c>)lstNewRecords, new Map<Id, sObject>());
        }catch(Exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception Message = '+ex.getMessage());  
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed after insert.                        *
    * @Params      : Map<Id, sObject>                                                            *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeAfterInsertTrigger(Map<Id, sObject> mapNewRecords){
        try{
            system.debug('#### after insert trigger');
            system.debug(mapNewRecords.values());
            /* Calling method to create campaign members on inquiry creation. */
            //createCampaignMembers(mapNewRecords);   
            rollupInquiry(mapNewRecords);
        }catch(Exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception Message = '+ex.getMessage());  
        }
    }
    
    /*********************************************************************************************
    * @Description : Create campaign member record when a inquiry is created.                    *
    * @Params      : Map<Id, ID> Id - Key -Campaign Id  , ID - Matching Inquiry ID               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private void createCampaignMembers(Map<ID,ID> mapOfAssociatedCampaign){
        List<Campaign_Member__c> campaignMember = new List<Campaign_Member__c>();
        for(ID campaignkey : mapOfAssociatedCampaign.keySet())
            campaignMember.add(new Campaign_Member__c(Campaign__c = campaignkey, Inquiry__c = mapOfAssociatedCampaign.get(campaignkey)) );
        if(!campaignMember.isEmpty())
            insert campaignMember;
    }
    
    /*********************************************************************************************
    * @Description : Check duplicate inquiry and route the corresponding assignment rule.        *
    * @Params      : List<Inquiry__c>                                                            *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible public List<Inquiry__c> inquiryDuplicateCheckAndAssignment(List<Inquiry__c> newInquiryList){
        inquiryToUpdate = new  List<Inquiry__c>();
        Set<String> allUniquePhoneKeysSet = new Set<String>();
        Set<String> allUniqueMailKeysSet = new Set<String>();
        Set<ID> campaignIDs = new Set<ID>();//CH06
        Set<String> setMobilePhones = new Set<String>();//CH07
        Set<String> setEmails = new Set<String>();//CH07
        
        Map<Id, Set<Id>> nurturingInquiryOwnersSetMap;
        userToTenureMap = new Map<Id,Date>();
        Id inquiryRecordTypeId   = Schema.SObjectType.Inquiry__c.getRecordTypeInfosByName().get(DAMAC_Constants.INQUIRY_RT).getRecordTypeId();
        for(Inquiry__c thisInquiry : newInquiryList){ 
            if(thisInquiry.RecordTypeId == inquiryRecordTypeId){
                /* Calling method to update the Email and Phone unique keys on the inquiry. */
                thisInquiry = updateUniqueKeys(thisInquiry);  
                if(String.isNotBlank(thisInquiry.First_name__c) && String.isNotBlank(thisInquiry.Last_name__c)){
                    if(String.isNotBlank(thisInquiry.Mobile_CountryCode__c) && String.isNotBlank(thisInquiry.Mobile_Phone__c)){
                        thisInquiry.Phone_Unique_key__c = thisInquiry.First_name__c+'__'+thisInquiry.Last_name__c+'__'+thisInquiry.Mobile_CountryCode__c+'__'+thisInquiry.Mobile_Phone__c;  
                        setMobilePhones.add(thisInquiry.Mobile_Phone__c);//CH07
                    }
                    if(String.isNotBlank(thisInquiry.Email__c)){
                        thisInquiry.Email_Unique_key__c = thisInquiry.First_name__c+'__'+thisInquiry.Last_name__c+'__'+thisInquiry.Email__c;    
                        setEmails.add(thisInquiry.Email__c);//CH07
                    }   
                }        
                
                if(String.isNotBlank(thisInquiry.Phone_Unique_key__c)){
                    allUniquePhoneKeysSet.add(thisInquiry.Phone_Unique_key__c.toUpperCase());
                }
                if(String.isNotBlank(thisInquiry.Email_Unique_key__c)){
                    allUniqueMailKeysSet.add(thisInquiry.Email_Unique_key__c.toUpperCase());        
                }
                //CH06
                if(thisInquiry.Campaign__c != null){
                    campaignIDs.add(thisInquiry.Campaign__c);
                }
                //CH06
            } 
        }
        system.debug('#### allUniquePhoneKeysSet = '+allUniquePhoneKeysSet);
        system.debug('#### allUniqueMailKeysSet = '+allUniqueMailKeysSet);
        system.debug('#### campaignIDs = '+campaignIDs);    
        if(!allUniquePhoneKeysSet.isEmpty() || !allUniqueMailKeysSet.isEmpty()){
            /* Calling method to fetch existing inquiry with matching phone and email keys. */
            Map<String, List<Inquiry__c>> existingKeyInquiryMap = getMatchingInquiry(allUniquePhoneKeysSet, allUniqueMailKeysSet,campaignIDs);//CH06 changed the type
            /* Calling method to fetch existing account with matching phone and email keys. */
            Map<String, Account> existingKeyAccountMap = getMatchingAccount(allUniquePhoneKeysSet, allUniqueMailKeysSet);  
            system.debug('#### existingKeyInquiryMap = '+existingKeyInquiryMap);
            system.debug('#### existingKeyAccountMap = '+existingKeyAccountMap); 
            
            //CH07
            //Map<String,Inquiry__c> mapPossibleInquiryMatches = possibleMatchesOfInquiry(setEmails,setMobilePhones);
            //for(Inquiry__c thisPossinleInquiry : newInquiryList){
            //  if(thisPossinleInquiry.Email__c != null && mapPossibleInquiryMatches.containsKey(thisPossinleInquiry.Email__c.toUpperCase())){
            //      thisPossinleInquiry.Related_Inquiry__c = mapPossibleInquiryMatches.get(thisPossinleInquiry.Email__c.toUpperCase()).Id;
            //  }
            //  else if(thisPossinleInquiry.Mobile_Phone__c != null && mapPossibleInquiryMatches.containsKey(thisPossinleInquiry.Mobile_Phone__c))
            //      thisPossinleInquiry.Related_Inquiry__c = mapPossibleInquiryMatches.get(thisPossinleInquiry.Mobile_Phone__c).Id;
            //}
            //CH07
            
            //CH07.Start
            System.debug('!@campaignIDs = '+campaignIDs);
            Map<ID,List<User>> campaingUsers = getAllCampaignUser(campaignIDs);
            system.debug('#### campaignUsersMap = '+campaingUsers);
            List<Inquiry__c> newInquiriesList = new List<Inquiry__c>();
            Map<ID,ID> mapToCreateAssociatedCampaigns = new Map<ID,ID>();
            Id damacQueueId = DamacUtility.getQueueId(DAMAC_Constants.DAMAC_QUEUE);
            List<Inquiry__c> updateMatchingInquiryList = new List<Inquiry__c>();
            for(Inquiry__c thisInquiry : newInquiryList){
                Boolean removeInquiryFromOriginallist = false;
                if(thisInquiry.Campaign__c != null && campaingUsers.containsKey(thisInquiry.Campaign__c)){
                    List<Inquiry__c> lstmatchingInquiries = (existingKeyInquiryMap.containsKey((thisInquiry.Phone_Unique_key__c).toUpperCase()) ? 
                        existingKeyInquiryMap.get((thisInquiry.Phone_Unique_key__c).toUpperCase()) : existingKeyInquiryMap.containsKey((thisInquiry.Email_Unique_key__c).toUpperCase()) ? 
                        existingKeyInquiryMap.get((thisInquiry.Email_Unique_key__c).toUpperCase()) : new List<Inquiry__c>());
                    Inquiry__c matchInquiry = getMatchingInquiryRecord(thisInquiry,lstmatchingInquiries);
                    System.debug('!@thisInquiry = '+thisInquiry);
                    System.debug('!@matchInquiry = '+matchInquiry);
                    System.debug('!@Campaign Users = '+campaingUsers.get(thisInquiry.Campaign__c));
                    for(User thisUser : campaingUsers.get(thisInquiry.Campaign__c)){
                        System.debug('!@# thisUser = '+thisUser);
                        if(matchInquiry.OwnerID == thisUser.id){
                            removeInquiryFromOriginallist = true;
                            thisInquiry.OwnerID = damacQueueId;
                            mapToCreateAssociatedCampaigns.put(thisInquiry.Campaign__c,matchInquiry.Id);
                            checkDuplicateInquiry(thisInquiry, matchInquiry);
                            /* Calling method to set values on the existing inquiry. */
                            matchInquiry = updateExistingMatchingInquiry(matchInquiry, thisInquiry); 
                            updateMatchingInquiryList.add(matchInquiry);
                            break;
                        }
                    }
                }
                if(!removeInquiryFromOriginallist)
                    newInquiriesList.add(thisInquiry);
            }
            system.debug('updateMatchingInquiryList = '+updateMatchingInquiryList);
            system.debug('mapToCreateAssociatedCampaigns = '+mapToCreateAssociatedCampaigns);
            system.debug('newInquiryList = '+newInquiryList.size());
            system.debug('newInquiriesList = '+newInquiriesList.size());
            if(!updateMatchingInquiryList.isEmpty()){
                TriggerFactoryCls.setBYPASS_UPDATE_TRIGGER();
                system.debug('#### Flag here = '+TriggerFactoryCls.getBYPASS_UPDATE_TRIGGER());
                update updateMatchingInquiryList;
                TriggerFactoryCls.resetBYPASS_UPDATE_TRIGGER();
            }
            if(!mapToCreateAssociatedCampaigns.isEmpty() && mapToCreateAssociatedCampaigns.size() > 0 ){
                createCampaignMembers(mapToCreateAssociatedCampaigns);
            }
            //CH07.End
            /* For handling nurturing inquiries. */
            Set<Id> nurturingInquiresSet = new Set<Id>();
            for(String existingKey : existingKeyInquiryMap.keySet()){
                for(Inquiry__c thisInquiry : existingKeyInquiryMap.get(existingKey))
                    if(String.isNotBlank(thisInquiry.Inquiry_Status__c) && 
                       thisInquiry.Inquiry_Status__c.equalsIgnoreCase(DAMAC_Constants.NURTURING_STATUS)){
                        nurturingInquiresSet.add(thisInquiry.Id);
                    }   
            }
            if(!nurturingInquiresSet.isEmpty()){
                nurturingInquiryOwnersSetMap = getNurturingInquiryDetails(nurturingInquiresSet); 
                system.debug('Nurturing Inquiry '+nurturingInquiryOwnersSetMap);
            }
            /* Calling method to run assignment rule for inquiry without any match. */
            inquiryAssignment(newInquiriesList, existingKeyAccountMap, existingKeyInquiryMap, nurturingInquiryOwnersSetMap);//CH07 Changing the newInquiryList to newInquiriesList
        } 

        return inquiryToUpdate ; 
    }
    
    /*********************************************************************************************
    * @Description : Inquiry Assignment rule for no match:                                       *
    *                - If campaign exists, fetch the associated PC's for assignment.             *
    *                - If property exists, fetch the associated PC's for assignment.             *
    *                - If none of the above exists, get all the available PC's for assignment.   *
    * @Params      : List<Inquiry__c>                                                            *
    * @Return      : void                                                                        *
    *********************************************************************************************/      
    @TestVisible private void inquiryAssignment(List<Inquiry__c> newInquiryList, 
                                                Map<String, Account> existingKeyAccountMap, 
                                                Map<String, List<Inquiry__c>> existingKeyInquiryMap, //CH06 changed the type
                                                Map<Id, Set<Id>> nurturingInquiryOwnersSetMap){
        Set<Id> campaignIdSet = new Set<Id>();
        Set<Id> propertIdSet = new Set<Id>();
        Map<Id, List<Id>> campaignMasterAssignmentMap;
        Map<Id, List<Id>> propertyMasterAssignmentMap;
        List<Id> noCampaignPropertyMasterList;
        List<Inquiry__c> inquiryWithBlankCampaignOrProperty = new List<Inquiry__c>();
        List<Inquiry__c> updateMatchingInquiryList = new List<Inquiry__c>();
        Id damacQueueId = DamacUtility.getQueueId(DAMAC_Constants.DAMAC_QUEUE);
        Id leadManagementQueueId = DamacUtility.getQueueId(DAMAC_Constants.LEAD_MANAGEMENT_QUEUE);
        Map<String, Profile> nameProfileMap = getProfileDetails(new Set<String>{DAMAC_Constants.PC_PROFILE, DAMAC_Constants.RECEPTIONIST_PROFILE, DAMAC_Constants.LEAD_MANAGEMENT_TEAM_PROFILE}); 
        Profile propertyConsultant = nameProfileMap.get(DAMAC_Constants.PC_PROFILE);
        Profile receptionist = nameProfileMap.get(DAMAC_Constants.RECEPTIONIST_PROFILE);
        Profile leadsManagement = nameProfileMap.get(DAMAC_Constants.LEAD_MANAGEMENT_TEAM_PROFILE);
        Map<String,Inquire_Score__c> inquiryScore = Inquire_Score__c.getAll(); 
        try{
            for(Inquiry__c thisInquiry : newInquiryList){
                if(UserInfo.getProfileId() == propertyConsultant.Id){
                    //thisInquiry.Inquiry_Source__c = DAMAC_Constants.PROSPECTING_BY_PC_SOURCE;
                }
                
                if(UserInfo.getProfileId() != propertyConsultant.Id && 
                   UserInfo.getProfileId() != receptionist.Id && 
                   UserInfo.getProfileId() != leadsManagement.Id){
                    if(thisInquiry.Campaign__c != null){
                        campaignIdSet.add(thisInquiry.Campaign__c); 
                    }else if(thisInquiry.Property__c != null){
                        propertIdSet.add(thisInquiry.Property__c);  
                    }else{
                        inquiryWithBlankCampaignOrProperty.add(thisInquiry);    
                    } 
                    if( thisInquiry.Inquiry_Source__c == DAMAC_Constants.PROSPECTING_BY_PC_SOURCE || 
                        thisInquiry.Inquiry_Source__c == DAMAC_Constants.AGENT_REFERAL_STATUS || 
                        thisInquiry.Inquiry_Source__c == DAMAC_Constants.CUSTOMER_REFERAL_STATUS ||
                       (thisInquiry.Inquiry_Source__c == DAMAC_Constants.STANDS_SOURCE && 
                        thisInquiry.OwnerID != Label.Ilead_IntegrationUserID)){ //Added condtion to run the the assignment for Ileads){  
                        runAssignment = false ; 
                    }
                }else{
                    loggedInUserPC = true ; 
                    system.debug('User logged in is PC '+loggedInUserPC);
                }
            }   
            
            /* Calling method for campaign assignment. */
            if(!campaignIdSet.isEmpty()){
                /* Calling method to get the list of available PC's under a campaign. */
                campaignMasterAssignmentMap = new Map<Id, List<Id>>(inquiryAssignmentForCampaign(campaignIdSet, newInquiryList));   
            }
            /* Calling method for property assignment. */
            if(!propertIdSet.isEmpty()){
                /* Calling method to get the list of available PC's under a property. */
                propertyMasterAssignmentMap = new Map<Id, List<Id>>(inquiryAssignmentForProperty(propertIdSet, newInquiryList)); 
            }
            /* Calling method for no campaign or property available. */
            if(!inquiryWithBlankCampaignOrProperty.isEmpty() || noPCForCampaignOrProperty){
                if(noPCForCampaignOrProperty){
                    inquiryWithBlankCampaignOrProperty = newInquiryList ;
                }
                /* Calling method to get the list of available PC's under a property. */
                noCampaignPropertyMasterList = inquiryAssignmentForNoCampaignOrProperty(propertyConsultant.Id, inquiryWithBlankCampaignOrProperty);
            }
            /* Auto assigning owner. */
            for(Inquiry__c thisInquiry : newInquiryList){
                if(thisInquiry.Inquiry_Source__c != 'Chat'){//CH04
                    /* Assign score to inquiry based on the source. */
                    if(inquiryScore.containsKey(thisInquiry.Inquiry_Source__c)){
                        thisInquiry.Inquiry_score__c = inquiryScore.get(thisInquiry.Inquiry_Source__c).Lead_Score__c;
                    }else{
                        thisInquiry.Inquiry_score__c = DAMAC_Constants.INQUIRY_SCORE_DEFAULT ;
                    }
                    System.debug('log 1');
                    if(thisInquiry.Campaign__c != null && campaignMasterAssignmentMap != null && campaignMasterAssignmentMap.containsKey(thisInquiry.Campaign__c)){
                         /* Calling method for campaign available. */
                        List<Id> eligibleUsersList = campaignMasterAssignmentMap.get(thisInquiry.Campaign__c);
                        if(eligibleUsersList.isEmpty()){
                            eligibleUsersList = noCampaignPropertyMasterList;
                        }
                        if(eligibleUsersList != null && eligibleUsersList.size() > 0){
                            /* Calling method to assign the owner. */
                            List<Id> returnedUsersList = assignInquiryOwner(thisInquiry, 
                                                                            existingKeyAccountMap, 
                                                                            existingKeyInquiryMap, 
                                                                            nurturingInquiryOwnersSetMap, 
                                                                            eligibleUsersList, 
                                                                            damacQueueId, 
                                                                            updateMatchingInquiryList);
                            /* Calling method to re-queue this assigned user to the end of the queue, to avoid excessive loading of this user. */
                            campaignMasterAssignmentMap.put(thisInquiry.Campaign__c, returnedUsersList);
                        }else if(!loggedInUserPC && runAssignment){
                            thisInquiry.OwnerId = leadManagementQueueId ;
                            thisInquiry.Inquiry_Status__c = DAMAC_Constants.INQUIRY_NEW_STATUS;//CH02
                        }       
                    }else if(thisInquiry.Property__c != null && propertyMasterAssignmentMap != null && propertyMasterAssignmentMap.containsKey(thisInquiry.Property__c)){
                        /* Calling method for property available. */
                        List<Id> eligibleUsersList = propertyMasterAssignmentMap.get(thisInquiry.Property__c);
                        System.debug('log Property '+eligibleUsersList.size());
                        if(eligibleUsersList != null && eligibleUsersList.size() > 0){
                            /* Calling method to assign the owner. */
                            List<Id> returnedUsersList = assignInquiryOwner(thisInquiry, 
                                                                            existingKeyAccountMap, 
                                                                            existingKeyInquiryMap, 
                                                                            nurturingInquiryOwnersSetMap, 
                                                                            eligibleUsersList, 
                                                                            damacQueueId, 
                                                                            updateMatchingInquiryList);
                            /* Calling method to re-queue this assigned user to the end of the queue, to avoid excessive loading of this user. */
                            propertyMasterAssignmentMap.put(thisInquiry.Property__c, returnedUsersList);
                        }else if(!loggedInUserPC && runAssignment){
                            thisInquiry.OwnerId = leadManagementQueueId ;
                            thisInquiry.Inquiry_Status__c = DAMAC_Constants.INQUIRY_NEW_STATUS;//CH02
                        }   
                    }else{
                        List<Id> eligibleUsersList = noCampaignPropertyMasterList;
                        if(loggedInUserPC){
                                eligibleUsersList = new List<Id>{UserInfo.getUserId()};
                        }
                        system.debug('eligibleUsersList '+eligibleUsersList);
                        if(eligibleUsersList != null && eligibleUsersList.size() > 0 ){
                            /* Calling method to assign the owner. */
                            List<Id> returnedUsersList = assignInquiryOwner(thisInquiry, 
                                                                            existingKeyAccountMap, 
                                                                            existingKeyInquiryMap, 
                                                                            nurturingInquiryOwnersSetMap, 
                                                                            eligibleUsersList, 
                                                                            damacQueueId, 
                                                                            updateMatchingInquiryList);
                            /* Calling method to re-queue this assigned user to the end of the queue, to avoid excessive loading of this user. */
                            if(noCampaignPropertyMasterList !=null && !noCampaignPropertyMasterList.isEmpty()){
                                noCampaignPropertyMasterList.clear();
                                noCampaignPropertyMasterList.addAll(returnedUsersList); 
                            }
                            
                        }else if(!loggedInUserPC && runAssignment){
                            thisInquiry.OwnerId = leadManagementQueueId ;
                            thisInquiry.Inquiry_Status__c = DAMAC_Constants.INQUIRY_NEW_STATUS;//CH02
                        }       
                    }
                    inquiryToUpdate.add(thisInquiry);
                }
            }
        }Catch(Exception ex){
            trigger.new[0].addError('Exception at line number: '+ex.getLineNumber()+' is '+ex.getMessage());
        }
        
    }
    
    /*********************************************************************************************
    * @Description : Method to assign the owner to an inquiry.                                   *
    *                - Get the list of eligible users based on language,                         *
    *                     PC's under assigned campaign if exists or                              *
    *                     PC's under assigned property if exists or                              *
    *                     All available PC's in the system.                                      *
    *                   - If an Account match is found :                                         *
    *                       - If the existing matching account's owner is in the eligble list,   *
    *                         assign the account's owner to the new duplicate inquiry.           *
    *                       - If not the assigning the owner from the eligible list.             *
    *                   - If an Inquiry match is found :                                         *
    *                       - If the existing matching inquiry's owner is in the eligble list,   *
    *                         assign the DAMAC Queue to the new duplicate inquiry.               *
    *                       - If not the assigning the owner from the eligible list.             *  
    * @Params      : Inquiry__c, Map<String, Account>, Map<String, Inquiry__c>, List<Id>, Id     *
    * @Return      : List<Id>                                                                    *
    *********************************************************************************************/
    @TestVisible private List<Id> assignInquiryOwner(Inquiry__c thisInquiry, 
                                                     Map<String, Account> existingKeyAccountMap, 
                                                     Map<String, List<Inquiry__c>> existingKeyInquiryMap, 
                                                     Map<Id, Set<Id>> nurturingInquiryOwnersSetMap, 
                                                     List<Id> eligibleUsersList, 
                                                     Id damacQueueId, 
                                                     List<Inquiry__c> updateMatchingInquiryList){
        Set<Id> eligibleUsersSet = new Set<Id>(eligibleUsersList);
        system.debug('#### existingKeyAccountMap = '+existingKeyAccountMap);
        system.debug('#### existingKeyInquiryMap = '+existingKeyInquiryMap);
        System.debug('@@thisInquiry = '+thisInquiry);
        
        List<Inquiry__c> matchingInquiry = 
                (existingKeyInquiryMap.containsKey((thisInquiry.Phone_Unique_key__c+''+(thisInquiry.Campaign__c != null ? (String)thisInquiry.Campaign__c : '')).toUpperCase()) ? 
                    existingKeyInquiryMap.get((thisInquiry.Phone_Unique_key__c+''+(thisInquiry.Campaign__c != null ? (String)thisInquiry.Campaign__c : '')).toUpperCase()) : existingKeyInquiryMap.containsKey((thisInquiry.Email_Unique_key__c+''+(thisInquiry.Campaign__c != null ? (String)thisInquiry.Campaign__c : '')).toUpperCase()) ? 
                    existingKeyInquiryMap.get((thisInquiry.Email_Unique_key__c+''+(thisInquiry.Campaign__c != null ? (String)thisInquiry.Campaign__c : '')).toUpperCase()) : new List<Inquiry__c>());//CH06
        System.debug('###matchingInquiry = '+matchingInquiry);
        if(existingKeyAccountMap.containsKey(thisInquiry.Phone_Unique_key__c.toUpperCase()) || 
           existingKeyAccountMap.containsKey(thisInquiry.Email_Unique_key__c.toUpperCase())){
            Account matchingAccount = 
                existingKeyAccountMap.containsKey(thisInquiry.Phone_Unique_key__c.toUpperCase()) ? 
                    existingKeyAccountMap.get(thisInquiry.Phone_Unique_key__c.toUpperCase()) : 
                    existingKeyAccountMap.get(thisInquiry.Email_Unique_key__c.toUpperCase());
            
            if(matchingAccount != null){
                /* Calling method to set values on the new duplicate inquiry. */
                //if(thisInquiry.OwnerID == matchingAccount.OwnerID)//CH06
                //List<Inquiry__c> matchingInquiry = 
                //(existingKeyInquiryMap.containsKey((thisInquiry.Phone_Unique_key__c+''+(thisInquiry.Campaign__c != null ? thisInquiry.Campaign__c : '')).toUpperCase()) ? 
                //  existingKeyInquiryMap.get((thisInquiry.Phone_Unique_key__c+''+(thisInquiry.Campaign__c != null ? thisInquiry.Campaign__c : '')).toUpperCase()) : existingKeyInquiryMap.containsKey((thisInquiry.Email_Unique_key__c+''+(thisInquiry.Campaign__c != null ? thisInquiry.Campaign__c : '')).toUpperCase()) ? 
                //  existingKeyInquiryMap.get((thisInquiry.Email_Unique_key__c+''+(thisInquiry.Campaign__c != null ? thisInquiry.Campaign__c : '')).toUpperCase()) : null);//CH06
                System.debug('@@@matchingInquiry = '+matchingInquiry);
                Inquiry__c matchInquiry = getMatchingInquiryRecord(thisInquiry,matchingInquiry);//CH06
                System.debug('@@@matchInquiry = '+matchInquiry);
                thisInquiry = checkDuplicateAccount(thisInquiry, matchingAccount,matchInquiry);
                    
                if(!loggedInUserPC && runAssignment){
                    if(eligibleUsersSet.contains(matchingAccount.OwnerId)){
                        thisInquiry.OwnerId = matchingAccount.OwnerId;
                        thisInquiry.Inquiry_Status__c = DAMAC_Constants.INQUIRY_NEW_STATUS;//CH02
                    }else{
                        thisInquiry.OwnerId = eligibleUsersList[0];
                        thisInquiry.Inquiry_Status__c = DAMAC_Constants.INQUIRY_NEW_STATUS;//CH02
                        /* If user assigned from the eligible list, reshuffle it. */
                        return shuffleQueue(eligibleUsersList);
                    } 
                }
            }
        }else if(!matchingInquiry.isEmpty() && matchingInquiry.size() > 0 && (existingKeyInquiryMap.containsKey(thisInquiry.Phone_Unique_key__c.toUpperCase()) || 
                 existingKeyInquiryMap.containsKey(thisInquiry.Email_Unique_key__c.toUpperCase()))){
            
            System.debug('###matchingInquiry = '+matchingInquiry);
            Inquiry__c matchInquiry = getMatchingInquiryRecord(thisInquiry,matchingInquiry);//CH06
            System.debug('###matchInquiry = '+matchInquiry);
            if(matchInquiry != null && matchInquiry.Id != null){
                /* Calling method to set values on the new duplicate inquiry. */
                //if(thisInquiry.OwnerID == matchingInquiry.OwnerID)//CH06
                    thisInquiry = checkDuplicateInquiry(thisInquiry, matchInquiry);
                /* Calling method to set values on the existing inquiry. */
                matchInquiry = updateExistingMatchingInquiry(matchInquiry, thisInquiry); 
                updateMatchingInquiryList.add(matchInquiry);
                if(!updateMatchingInquiryList.isEmpty()){
                    TriggerFactoryCls.setBYPASS_UPDATE_TRIGGER();
                    system.debug('#### Flag here = '+TriggerFactoryCls.getBYPASS_UPDATE_TRIGGER());
                    update updateMatchingInquiryList;
                    TriggerFactoryCls.resetBYPASS_UPDATE_TRIGGER();
                }
                /* Assigning the PC to an inquiry. 
                   - If duplicate found with the nurturing inquiry, don't assign to any of existing nurturing inquiry owners. 
                   - Else If matching owner is existing in the eligible list, assign to damac queue. 
                   - Else follow the default assignment approach. 
                */
                if(!loggedInUserPC && runAssignment){
                    if(String.isNotBlank(matchInquiry.Inquiry_Status__c) && 
                       matchInquiry.Inquiry_Status__c.equalsIgnoreCase(DAMAC_Constants.NURTURING_STATUS)){
                        /* Get the nurturing owners set. */
                        Set<Id> nurturingOwnersSet = nurturingInquiryOwnersSetMap.containsKey(matchInquiry.Id) ? nurturingInquiryOwnersSetMap.get(matchInquiry.Id) : new Set<Id>();
                        Set<Id> nonNurturingMatchingOwnersSet = new Set<Id>(eligibleUsersList);
                        nonNurturingMatchingOwnersSet.removeAll(nurturingOwnersSet);
                        List<Id> nonNurturingMatchingOwnersList = new List<Id>(nonNurturingMatchingOwnersSet);
                        List<Id> nurturingOwnersList = new List<Id>(nurturingOwnersSet);
                        if(!nonNurturingMatchingOwnersList.isEmpty()){
                            thisInquiry.OwnerId = nonNurturingMatchingOwnersList[Math.mod(Math.abs(Crypto.getRandomLong().intValue()), nonNurturingMatchingOwnersList.size())];
                        }else{
                            thisInquiry.OwnerId = nurturingOwnersList[Math.mod(Math.abs(Crypto.getRandomLong().intValue()), nurturingOwnersList.size())];   
                        }
                    }else if(eligibleUsersSet.contains(matchInquiry.OwnerId)){
                        thisInquiry.OwnerId = damacQueueId;
                        thisInquiry.Inquiry_Status__c = DAMAC_Constants.INQUIRY_NEW_STATUS;//CH02
                    }else{
                        thisInquiry.OwnerId = eligibleUsersList[0];
                        thisInquiry.Inquiry_Status__c = DAMAC_Constants.INQUIRY_NEW_STATUS;//CH02
                        /* If user assigned from the eligible list, reshuffle it. */
                        return shuffleQueue(eligibleUsersList);
                    }
                }
            }//CH06
            else if(!loggedInUserPC && runAssignment){
                /* If no inquiry match found. */
                thisInquiry.OwnerId = eligibleUsersList[0];
                thisInquiry.Inquiry_Status__c = DAMAC_Constants.INQUIRY_NEW_STATUS;//CH02
                /* If user assigned from the eligible list, reshuffle it. */
                return shuffleQueue(eligibleUsersList);
            }
            //CH06
        }else if(!loggedInUserPC && runAssignment){
            /* If no inquiry match found. */
            thisInquiry.OwnerId = eligibleUsersList[0];
            thisInquiry.Inquiry_Status__c = DAMAC_Constants.INQUIRY_NEW_STATUS;//CH02
            /* If user assigned from the eligible list, reshuffle it. */
            return shuffleQueue(eligibleUsersList);
        }
        return eligibleUsersList;
    }
    
    /*********************************************************************************************
    * @Description : Method to update values on the existing inquiry.                            *
    *                - Update if a new source is added.                                          *
    *                - Update if a duplicate count.                                              *
    *                - Update if a inquiry score.                                                *
    * @Params      : Inquiry__c, Inquiry__c                                                      *
    * @Return      : Inquiry__c                                                                  *
    *********************************************************************************************/  
    private Inquiry__c updateExistingMatchingInquiry(Inquiry__c existingInquiry, Inquiry__c duplicateNewInquiry){
        if(existingInquiry != null && String.isNotBlank(existingInquiry.Inquiry_From_Other_Sources__c) && 
           String.isNotBlank(duplicateNewInquiry.Inquiry_Source__c) && 
           !existingInquiry.Inquiry_From_Other_Sources__c.containsIgnoreCase(duplicateNewInquiry.Inquiry_Source__c)){
            existingInquiry.Inquiry_From_Other_Sources__c = existingInquiry.Inquiry_From_Other_Sources__c + ';' + duplicateNewInquiry.Inquiry_Source__c;
        }else{
            existingInquiry.Inquiry_From_Other_Sources__c = duplicateNewInquiry.Inquiry_Source__c;  
        }
        existingInquiry.Duplicates_Count__c = existingInquiry.Duplicates_Count__c != null ? existingInquiry.Duplicates_Count__c + 1 : 1;
        existingInquiry.Inquiry_Score__c = upgradeScore(existingInquiry.Inquiry_Score__c);
        system.debug('#### Update existingInquiry = '+existingInquiry);
        return existingInquiry;
    }
    
    
    /*********************************************************************************************
    * @Description : Check the inquiry duplicate with Account:                                   *
    *                - Set the duplicate flag                                                    *
    *                - Set the inquiry score.                                                    *
    * @Params      : Inquiry__c, Account                                                         *
    * @Return      : Inquiry__c                                                                  *
    *********************************************************************************************/    
    public Inquiry__c checkDuplicateAccount(Inquiry__c newInquiry, Account matchingAccount,Inquiry__c matchInquiry){
        newInquiry.Duplicate__c = (matchInquiry != null && matchInquiry.id != null) ? true : false;
        newInquiry.Related_Inquiry__c = (matchInquiry != null && matchInquiry.id != null) ? matchInquiry.id : null;
        newInquiry.Associated_Customer__c = matchingAccount.Id;  
        if(String.isNotBlank(newInquiry.Inquiry_Source__c) && 
           Account_settings__c.getInstance(newInquiry.Inquiry_Source__c) != null && 
           Account_settings__c.getInstance(newInquiry.Inquiry_Source__c).Inquiry_score__c != null){
            newInquiry.Inquiry_score__c = Account_settings__c.getInstance(newInquiry.Inquiry_Source__c).Inquiry_score__c;   
        }    
        return newInquiry; 
    }
    
    /*********************************************************************************************
    * @Description : Check the inquiry duplicate with Inquiry:                                   *
    *                - Set the duplicate flag                                                    *
    *                - Set the inquiry score.                                                    *
    * @Params      : Inquiry__c                                                                  *
    * @Return      : Inquiry__c                                                                  *
    *********************************************************************************************/      
    @TestVisible private Inquiry__c checkDuplicateInquiry(Inquiry__c newInquiry, Inquiry__c matchingInquiry){
        newInquiry.Duplicate__c = true; 
        newInquiry.Related_Inquiry__c = matchingInquiry.Id ;  
        if(String.isNotBlank(newInquiry.Inquiry_Status__c)){
            if(newInquiry.Inquiry_Status__c.equalsIgnoreCase(DAMAC_Constants.NURTURING_STATUS) && 
               Nurture_settings__c.getInstance(newInquiry.Inquiry_Source__c) != null && 
               Nurture_settings__c.getInstance(newInquiry.Inquiry_Source__c).Inquiry_score__c != null){
                newInquiry.Inquiry_score__c = Nurture_settings__c.getInstance(newInquiry.Inquiry_Source__c).Inquiry_score__c;
            }else {
                newInquiry.Inquiry_score__c = matchingInquiry.Inquiry_score__c; 
            }
        }
        
        
        return newInquiry;
    }
    
    /*********************************************************************************************
    * @Description : Method to handle assignment for inquiry with campaign.                      * 
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<Id, List<Id>>                                                           *
    *********************************************************************************************/ 
    public Map<Id, List<Id>> inquiryAssignmentForCampaign(Set<Id> campaignIdSet, List<Inquiry__c> newInquiryList){
        Map<Id, List<User>> userPreferredLanguageMap = new Map<Id, List<User>>(); 
        Map<Id, List<Id>> campaignUserSortedByLoad;
        /* Calling method to fetch the list of available PC's under a campaign. */
        Map<Id, List<User>> campaignUsersMap = getAllCampaignUser(campaignIdSet);
        system.debug('#### campaignUsersMap = '+campaignUsersMap);
        for(Inquiry__c thisInquiry : newInquiryList){
            if(thisInquiry.Campaign__c != null && campaignUsersMap.containsKey(thisInquiry.Campaign__c)){
                for(User thisUser : campaignUsersMap.get(thisInquiry.Campaign__c)){
                    /* Filtering users those speak inquiry's selected language, or english. */
                    //((String.isNotBlank(thisUser.Languages_Known__c) && String.isNotBlank(thisInquiry.Preferred_Language__c) && 
                    //    splitMutliSelect(thisUser.Languages_Known__c).contains(thisInquiry.Preferred_Language__c)) ||
                    //   (String.isNotBlank(thisUser.Languages_Known__c) && 
                    //      String.isBlank(thisInquiry.Preferred_Language__c) && 
                    //    thisUser.Languages_Known__c.contains(DAMAC_Constants.DEFAULT_LANGUAGE)))
                    /* Removing the default language condition from below, 
                       because of a re-opened ticket where the is inquiry getting assigned to english speaking PC,
                       even though the selected inquiry language is non-english and there are non-english speaking PC's under the campaign. */
                    //  || splitMutliSelect(thisUser.Languages_Known__c).contains(DAMAC_Constants.DEFAULT_LANGUAGE)
                    if(String.isNotBlank(thisUser.Languages_Known__c) && 
                        ((String.isNotBlank(thisInquiry.Preferred_Language__c) && 
                         (splitMutliSelect(thisUser.Languages_Known__c).contains(thisInquiry.Preferred_Language__c))) ||
                         (String.isBlank(thisInquiry.Preferred_Language__c) && 
                          thisUser.Languages_Known__c.contains(DAMAC_Constants.DEFAULT_LANGUAGE)))){
                        if(userPreferredLanguageMap.containsKey(thisInquiry.Campaign__c)){
                            userPreferredLanguageMap.get(thisInquiry.Campaign__c).add(thisUser);    
                        }else{ 
                            userPreferredLanguageMap.put(thisInquiry.Campaign__c, new List<User>{thisUser});
                        }
                        if(thisUser.Date_of_Joining__c != null){
                            userToTenureMap.put(thisUser.Id, thisUser.Date_of_Joining__c);  
                        }
                    }   
                }
                /* If the campaign users language doesn't match with any then add all the PC. */ 
                List<User> campaignUserIds = new List<User>(userPreferredLanguageMap.get(thisInquiry.Campaign__c));
                if(campaignUserIds.isEmpty()){
                    List<User> campaignUsersList = new List<User>(campaignUsersMap.get(thisInquiry.Campaign__c)) ;
                    if(campaignUsersList.isEmpty()){
                        noPCForCampaignOrProperty = true ; 
                    }else{
                        userPreferredLanguageMap.put(thisInquiry.Campaign__c, campaignUsersList);
                    }
                    if(campaignUsersList.size()<2){
                       noPCForCampaignOrProperty = true ;  
                    }
                }       
            }else{
               noPCForCampaignOrProperty = true ;  
            } 
        }
        system.debug('#### userPreferredLanguageMap = '+userPreferredLanguageMap);
        /* Getting users with load date :  Lead, Meeting. */
        if(!userPreferredLanguageMap.isEmpty()){
            campaignUserSortedByLoad = new Map<Id, List<Id>>(getUserWithLoad(userPreferredLanguageMap));
        }else{
            campaignUserSortedByLoad = new Map<Id, List<Id>>(); 
        } 
        return campaignUserSortedByLoad;
    }
    
    /*********************************************************************************************
    * @Description : Method to handle assignment for inquiry with property.                      * 
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<Id, List<Id>>                                                           *
    *********************************************************************************************/ 
    public Map<Id, List<Id>> inquiryAssignmentForProperty(Set<Id> propertyIdList, List<Inquiry__c> newInquiryList){
        Map<Id, List<Id>> userSortedByMeetingLoad;  
        Map<Id, List<User>> userPreferredLanguageMap = new Map<Id, List<User>>(); 
        /* Calling method to fetch the list of available PC's under a campaign. */
        Map<Id, List<User>> propertyUsersMap = getAllPropertyUser(propertyIdList);  
        for(Inquiry__c thisInquiry : newInquiryList){
            if(thisInquiry.Property__c != null && propertyUsersMap.containsKey(thisInquiry.Property__c)){
                for(User thisUser : propertyUsersMap.get(thisInquiry.Property__c)){
                    /* Filtering users those speak inquiry's selected language, or english. */
                    if((String.isNotBlank(thisUser.Languages_Known__c) &&  
                        String.isNotBlank(thisInquiry.Preferred_Language__c) && 
                        splitMutliSelect(thisInquiry.Preferred_Language__c).contains(thisUser.Languages_Known__c)) ||
                       (String.isNotBlank(thisUser.Languages_Known__c) && 
                        String.isBlank(thisInquiry.Preferred_Language__c) && 
                        thisUser.Languages_Known__c.equalsIgnoreCase(DAMAC_Constants.DEFAULT_LANGUAGE))){
                        if(userPreferredLanguageMap.containsKey(thisInquiry.Property__c)){
                            userPreferredLanguageMap.get(thisInquiry.Property__c).add(thisUser);    
                        }else{
                            userPreferredLanguageMap.put(thisInquiry.Property__c, new List<User>{thisUser});
                        }
                        if(thisUser.Date_of_Joining__c != null){
                            userToTenureMap.put(thisUser.Id, thisUser.Date_of_Joining__c);  
                        }
                    }   
                }   
                /* If the Property users language doesn't match with any then add all the PC. */
                List<User> propertyUserIds = new List<User>(userPreferredLanguageMap.get(thisInquiry.Property__c));
                if(propertyUserIds.isEmpty()){
                    List<User> campaignUsersList = new List<User>(propertyUsersMap.get(thisInquiry.Campaign__c)) ;
                    if(campaignUsersList.isEmpty()){
                        noPCForCampaignOrProperty = true ; 
                    }else{
                        userPreferredLanguageMap.put(thisInquiry.Campaign__c, campaignUsersList);
                    }
                }   
            }else{
               noPCForCampaignOrProperty = true ;  
            } 
        }
        system.debug('#### userPreferredLanguageMap = '+userPreferredLanguageMap);
        /* Getting users with load date :  Lead, Meeting. */
        if(!userPreferredLanguageMap.isEmpty()){
            userSortedByMeetingLoad = new Map<Id, List<Id>>(getUserWithLoad(userPreferredLanguageMap));
        }else{
            userSortedByMeetingLoad = new Map<Id, List<Id>>();  
        } 
        return userSortedByMeetingLoad;
    }
    
    /*********************************************************************************************
    * @Description : Method to handle assignment for inquiry without any campaign or property.   *
    * @Params      : Id                                                                          *
    * @Return      : Inquiry__c                                                                  *
    *********************************************************************************************/      
    @TestVisible public List<Id> inquiryAssignmentForNoCampaignOrProperty(Id pcProfileId, List<Inquiry__c> newInquiryList){
        Map<Id, Integer> userIdsScoreMap = new Map<Id, Integer>();
        List<Id> userIdsList = new List<Id>();
        Map<Id, List<Id>> parentSortedEligibleUsersMap = new Map<Id, List<Id>>();
        /* Calling method to get the list of all the available PC's in the system. */
        Map<Id, User> existingPcDetailMap = getUserDetailsByProfile(pcProfileId);
        for(Inquiry__c thisInquiry : newInquiryList){    
            for(User thisUser : existingPcDetailMap.values()){
                /* Filtering users those speak inquiry's selected language, if no language selected on inquiry go for english. */
                if((String.isNotBlank(thisUser.Languages_Known__c) &&  
                    String.isNotBlank(thisInquiry.Preferred_Language__c) && 
                    splitMutliSelect(thisUser.Languages_Known__c).contains(thisInquiry.Preferred_Language__c)) ||
                   (String.isNotBlank(thisUser.Languages_Known__c) && 
                    String.isBlank(thisInquiry.Preferred_Language__c) && 
                    thisUser.Languages_Known__c.contains(DAMAC_Constants.DEFAULT_LANGUAGE))){
                    userIdsScoreMap.put(thisUser.Id, 0);
                    if(parentSortedEligibleUsersMap.containsKey(thisInquiry.Id)){
                        parentSortedEligibleUsersMap.get(thisInquiry.Id).add(thisUser.Id);
                    }else{
                        parentSortedEligibleUsersMap.put(thisInquiry.Id, new List<Id>{thisUser.Id});    
                    }
                    if(thisUser.Date_of_Joining__c !=null){
                        userToTenureMap.put(thisUser.Id, thisUser.Date_of_Joining__c);
                    }
                }   
            }   
            /* If there are no preferred language speaking user, go for english speaking users. */
            if(userIdsScoreMap.isEmpty()){
                for(User thisUser : existingPcDetailMap.values()){
                    if((String.isNotBlank(thisUser.Languages_Known__c) && 
                        String.isNotBlank(thisInquiry.Preferred_Language__c) && 
                        !splitMutliSelect(thisUser.Languages_Known__c).contains(thisInquiry.Preferred_Language__c))){ 
                        userIdsScoreMap.put(thisUser.Id, 0);
                        if(parentSortedEligibleUsersMap.containsKey(thisInquiry.Id)){
                            parentSortedEligibleUsersMap.get(thisInquiry.Id).add(thisUser.Id);
                        }else{
                            parentSortedEligibleUsersMap.put(thisInquiry.Id, new List<Id>{thisUser.Id});    
                        }
                        if(thisUser.Date_of_Joining__c !=null){
                            userToTenureMap.put(thisUser.Id, thisUser.Date_of_Joining__c);
                        }   
                    }
                }   
            }
        }
        /* Getting users with load date :  Lead, Meeting. */ 
        if(!userIdsScoreMap.isEmpty()){
            /* Get users with active lead. */
            //Map<Id, List<Inquiry__c>> userAssociatedInquiryListMap = getAllUserWithLeadLoad(userIdsScoreMap);
            system.debug('parentSortedEligibleUsersMap = '+parentSortedEligibleUsersMap);
            if(!parentSortedEligibleUsersMap.isEmpty()){
                /* Calling method to get the sorted list of available users. */
                parentSortedEligibleUsersMap = new Map<Id, List<Id>>(getLoadSortedUsers(parentSortedEligibleUsersMap));
                if(parentSortedEligibleUsersMap != null && !parentSortedEligibleUsersMap.isEmpty()){
                    for(Id thisKey : parentSortedEligibleUsersMap.keySet()){
                        userIdsList.addAll(parentSortedEligibleUsersMap.get(thisKey));    
                    }   
                }
            }
        }   
        return userIdsList; 
    }
    
    /*********************************************************************************************
    * @Description : Method to get available user based on the assigned campaign or property.    *
    * @Params      : Map<Id, List<User>>                                                         *
    * @Return      : Map<Id, List<Id>>                                                           *
    *********************************************************************************************/    
    public Map<Id, List<Id>> getUserWithLoad(Map<Id, List<User>> userPreferredLanguageMap){
        Map<Id, List<Id>> parentSortedEligibleUsersMap = new Map<Id, List<Id>>();
        Map<Id, Integer> userIdsScoreMap = new Map<Id, Integer>();
        for(Id thisKey : userPreferredLanguageMap.keySet()){
            for(User thisAssociatedUser : userPreferredLanguageMap.get(thisKey)){
                if(parentSortedEligibleUsersMap.containsKey(thisKey)){
                    parentSortedEligibleUsersMap.get(thisKey).add(thisAssociatedUser.Id);
                }else{
                    parentSortedEligibleUsersMap.put(thisKey, new List<Id>{thisAssociatedUser.Id}); 
                }
                userIdsScoreMap.put(thisAssociatedUser.Id, 0);
            }   
        }
        system.debug('#### parentSortedEligibleUsersMap = '+parentSortedEligibleUsersMap);
        if(!userIdsScoreMap.isEmpty()){
            /* Get users with active lead. */
            //Map<Id, List<Inquiry__c>> userAssociatedInquiryListMap = getAllUserWithLeadLoad(userIdsScoreMap);
            /* Calling method to get the sorted list of available users. */
            if(!parentSortedEligibleUsersMap.isEmpty()){
                parentSortedEligibleUsersMap = new Map<Id, List<Id>>(getLoadSortedUsers(parentSortedEligibleUsersMap));
            }       
        }
        return parentSortedEligibleUsersMap;    
    }
    
    /*********************************************************************************************
    * @Description : Method to get available user sorted by load.                                *
    * @Params      : Map<Id, Integer>, Map<Id, Set<Id>>                                          *
    * @Return      : Map<Id, List<Id>>                                                           *
    *********************************************************************************************/ 
    public Map<Id, List<Id>> getLoadSortedUsers(Map<Id, List<Id>> parentSortedEligibleUsersMap){
        Map<Id, Integer> pcWithNewMeetingCount = new Map<Id, Integer>();
        Map<Id, Integer> pcWithCompletedMeetingCount = new Map<Id, Integer>();
        Map<Id, Integer> pcWithNewLeadCount = new Map<Id, Integer>();
        Map<Id, Integer> pcWithAllLeadCount = new Map<Id, Integer>();
        Map<Id, Integer> pcPerformanceBandMap = new Map<Id, Integer>(); 
        Map<Id, Integer> pcMeetingBandMap = new Map<Id, Integer>();
        Integer highestMeetingCount = 0;
        for(PCInquiryCounter__c thisValue : [SELECT Id, Name, All_Inquiry_Count__c, New_Inquiry_Count__c, 
                                                    New_Meeting_Count__c, Completed_Meeting_Count__c, 
                                                    Owner_Name__c 
                                             FROM PCInquiryCounter__c
                                             ORDER BY Completed_Meeting_Count__c ASC]){
            highestMeetingCount = Integer.valueOf(thisValue.Completed_Meeting_Count__c);
            pcWithNewMeetingCount.put(thisValue.Name, Integer.valueOf(thisValue.New_Meeting_Count__c));
            pcWithCompletedMeetingCount.put(thisValue.Name, Integer.valueOf(thisValue.Completed_Meeting_Count__c));
            pcWithNewLeadCount.put(thisValue.Name, Integer.valueOf(thisValue.New_Inquiry_Count__c));
            pcWithAllLeadCount.put(thisValue.Name, Integer.valueOf(thisValue.All_Inquiry_Count__c));
        }
        system.debug('#### pcWithCompletedMeetingCount = '+pcWithCompletedMeetingCount);
        system.debug('#### pcWithNewMeetingCount = '+pcWithNewMeetingCount);
        system.debug('#### pcWithAllLeadCount = '+pcWithAllLeadCount);
        system.debug('#### userToTenureMap = '+userToTenureMap);
        system.debug('#### pcWithNewLeadCount = '+pcWithNewLeadCount);
        if(parentSortedEligibleUsersMap != null){
            /* Calling method to get the pc and performance band map. */
            pcPerformanceBandMap = getPcPerformanceMap(parentSortedEligibleUsersMap); 
            system.debug('#### pcPerformanceBandMap = '+pcPerformanceBandMap);
            /* Calling method to get the pc and meeting band map. */
            pcMeetingBandMap = getPcMeetingBandMap(highestMeetingCount, pcWithCompletedMeetingCount);
            system.debug('#### pcMeetingBandMap = '+pcMeetingBandMap);
            for(Id thisKey : parentSortedEligibleUsersMap.keySet()){ 
                List<UserLoadWrapper> ulwObjectList = new List<UserLoadWrapper>();
                for(Id thisEligibleUser : parentSortedEligibleUsersMap.get(thisKey)){
                    system.debug('#### thisEligibleUser = '+thisEligibleUser);
                    /* Value hardcoded till the fetching field is decided. */ 
                    if((!pcWithNewMeetingCount.containsKey(thisEligibleUser) || 
                       (pcWithNewMeetingCount.containsKey(thisEligibleUser) && 
                        pcWithNewMeetingCount.get(thisEligibleUser) < Integer.valueOf(Label.Max_Activities))) && 
                       (!pcWithAllLeadCount.containsKey(thisEligibleUser) || 
                       (pcWithAllLeadCount.containsKey(thisEligibleUser) && 
                        pcWithAllLeadCount.get(thisEligibleUser) < Integer.valueOf(Label.Max_Inquiries)))){
                        ulwObjectList.add(new UserLoadWrapper(thisEligibleUser, 
                                                              pcWithNewLeadCount.containsKey(thisEligibleUser) ? pcWithNewLeadCount.get(thisEligibleUser) : 0,
                                                              pcPerformanceBandMap.containsKey(thisEligibleUser) ? pcPerformanceBandMap.get(thisEligibleUser) : Integer.valueOf(Label.Performance_Band_Size), 
                                                              userToTenureMap.containsKey(thisEligibleUser) && userToTenureMap.get(thisEligibleUser).monthsBetween(system.today()) > 6 ? 1 : 0, 
                                                              pcMeetingBandMap.containsKey(thisEligibleUser) ? pcMeetingBandMap.get(thisEligibleUser) : Integer.valueOf(Label.Activity_Band_Size), 
                                                              pcWithAllLeadCount.containsKey(thisEligibleUser) ? pcWithAllLeadCount.get(thisEligibleUser) : 0));
                    }
                }
                /* Sorting the wrapper, implemented using the comparable wrapper class. */
                system.debug('#### Wrapper before sorting = '+ulwObjectList);
                ulwObjectList.sort();
                system.debug('#### Wrapper after sorting = '+ulwObjectList);
                List<Id> sortedUserIdsList = new List<Id>();
                for(UserLoadWrapper thisUlwObject : ulwObjectList){ 
                    sortedUserIdsList.add(thisUlwObject.recordId);             
                }
                parentSortedEligibleUsersMap.put(thisKey, new List<Id>(sortedUserIdsList));
            }
        }
        return parentSortedEligibleUsersMap;  
    }
    
    /*********************************************************************************************
    * @Description : Method to update phone and email unique keys on the inquiry.                *
    * @Params      : Inquiry__c                                                                  *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private Inquiry__c updateUniqueKeys(Inquiry__c newInquiryRecord){
        newInquiryRecord.Phone_Unique_key__c = newInquiryRecord.First_name__c+'__'+newInquiryRecord.Last_name__c+'__'+ newInquiryRecord.Mobile_CountryCode__c+'__'+newInquiryRecord.Mobile_Phone__c;
        newInquiryRecord.Email_Unique_key__c = newInquiryRecord.First_name__c+'__'+newInquiryRecord.Last_name__c+'__'+newInquiryRecord.Email__c;  
        return newInquiryRecord;
    }
    
    /**
     *  Update Inquiry Score when status changes  
     * */
    public void updateInquiryScoreOnStatusChange(List<Inquiry__c> newListInquiry, Map<Id,Inquiry__c> mapOldInquiryRecords){
        
        Map<String,Inquiry_Score_Changes__c> inquiryScoreChangeMap = Inquiry_Score_Changes__c.getAll(); 
        Map<String,String> inquiryStatusToCustomStatus = new Map<String,String>();
        
        inquiryStatusToCustomStatus.put('Product Constraint','PC');
        inquiryStatusToCustomStatus.put('Budget Constraint','BC');
        inquiryStatusToCustomStatus.put('Unreachable - Invalid Contact Details','InvalidCon');
        inquiryStatusToCustomStatus.put('Unreachable - Not responding','NotResponding');
        inquiryStatusToCustomStatus.put('Existing Active Customers','ExistingCust');
        
        for(Inquiry__c newInquiry: newListInquiry){
            System.debug('@#! Debug for the Status = '+newInquiry);
            if(newInquiry.OwnerID != mapOldInquiryRecords.get(newInquiry.Id).OwnerID){//CH02
                newInquiry.Inquiry_Status__c = DAMAC_Constants.INQUIRY_NEW_STATUS; //CH02
            }
            if(newInquiry.Inquiry_Status__c != mapOldInquiryRecords.get(newInquiry.Id).Inquiry_Status__c){
                String currentStatus = inquiryStatusToCustomStatus.containsKey(newInquiry.Inquiry_Status__c) ? inquiryStatusToCustomStatus.get(newInquiry.Inquiry_Status__c) : newInquiry.Inquiry_Status__c ;
                String previousStatus = mapOldInquiryRecords.get(newInquiry.Id).Inquiry_Status__c ; 
                previousStatus = inquiryStatusToCustomStatus.containsKey(previousStatus) ? inquiryStatusToCustomStatus.get(previousStatus) : previousStatus ;
                String statusKey = previousStatus+'>>'+currentStatus ;
                 system.debug('Status Key---'+statusKey);
                 system.debug('Status Key val---'+inquiryScoreChangeMap.get(statusKey.trim()));
                if(inquiryScoreChangeMap.containsKey(statusKey)){
                    String newScore = inquiryScoreChangeMap.get(statusKey).Inquiry_Score__c ;
                    newInquiry.Inquiry_Score__c = newScore.trim();
                    system.debug('NewScore '+newScore);
                }
            }
        }
    }
    
    // TOBE Implemented.
    public void executeBeforeDeleteTrigger(Map<Id, sObject> mapOldRecords){}
    public void executeAfterUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){
        //CH03
        if(DAMAC_Constants.isExecutingFromReshufflingBatch){
            reshufflingBlockUser(mapNewRecords,mapOldRecords);
        }
        Map<Id, SObject> updateCampaignRecordsMap = new Map<Id, SObject>();
        for(Id thisKey : mapNewRecords.keySet()){
        	Inquiry__c newInquiry = (Inquiry__c) mapNewRecords.get(thisKey);
        	Inquiry__c oldInquiry = (Inquiry__c) mapOldRecords.get(thisKey);		
        	if(newInquiry.Campaign__c != oldInquiry.Campaign__c){
        		updateCampaignRecordsMap.put(thisKey,  mapNewRecords.get(thisKey));			
        	}
        }
        if(!updateCampaignRecordsMap.isEmpty()){
        	/* Calling method to update the roll-up count of inquiry on campaign, only if the campaign is updated.*/
        	rollupInquiry(updateCampaignRecordsMap);	
        }
    }
    public void executeAfterDeleteTrigger(Map<Id, sObject> mapOldRecords){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){}
    
    //CH05.Start
    /*********************************************************************************************
    * @Description : Method to mask the mobile number and encrypt them accordingly               *
    * @Params      : List<Inquiry__c>                                                            *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @Testvisible private void updateAssignedFields(List<sObject> newRecords, Map<Id, sObject> mapOldRecords){
        
        String userKeyPrefix =  Schema.getGlobalDescribe().get('User').getDescribe().getkeyprefix();
        if(!isAssignedToPopulated)
        for(Inquiry__c thisInquiry : (List<Inquiry__c>)newRecords){
            String ownerIDVal = thisInquiry.OwnerID;
            thisInquiry.Assigned_To__c = (trigger.isInsert ? (ownerIDVal.startsWith(userKeyPrefix) ?  ownerIDVal : null) : (thisInquiry.OwnerID != mapOldRecords.get(thisInquiry.id).get('OwnerID') && ownerIDVal.startsWith(userKeyPrefix)) ? ownerIDVal : null);
            thisInquiry.Assigned_By__c = userinfo.getuserid();
            thisInquiry.Assigned_Date__c = DateTime.now();
            isAssignedToPopulated = true;
        }
    }
    //CH05.End
    
    //CH03.Start
    /*********************************************************************************************
    * @Description : Method to mask the mobile number and encrypt them accordingly               *
    * @Params      : List<Inquiry__c>                                                            *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @Testvisible private void reshufflingBlockUser(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){
        
        List<User> updateUsersWithBlockDate = new List<User>();
        Set<ID> setUserIDs = new Set<ID>();
        String userKeyPrefix =  Schema.getGlobalDescribe().get('User').getDescribe().getkeyprefix();
        for(Inquiry__c thisInquiry : (List<Inquiry__c>)mapNewRecords.values()){
            if(thisInquiry.OwnerID != mapOldRecords.get(thisInquiry.id).get('OwnerID') && ((String)mapOldRecords.get(thisInquiry.id).get('OwnerID')).startsWith(userKeyPrefix) && !setUserIDs.contains((ID) mapOldRecords.get(thisInquiry.id).get('OwnerID'))){
                setUserIDs.add((ID) mapOldRecords.get(thisInquiry.id).get('OwnerID'));
                updateUsersWithBlockDate.add(new User(Id =(ID) mapOldRecords.get(thisInquiry.id).get('OwnerID'),Reshuffling_Block_Date__c = Date.today()));
            }
        }
        
        if(!updateUsersWithBlockDate.isEmpty())
            Database.update(updateUsersWithBlockDate,false);
    }
    //CH03.End
    
    //CH01.Start
    /*********************************************************************************************
    * @Description : Method to mask the mobile number and encrypt them accordingly               *
    * @Params      : List<Inquiry__c>                                                            *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @Testvisible private void encryptMobileNumbers(List<Inquiry__c> newListInquiry){
        //iterate the Inquiries for masking
        for(Inquiry__c inquiry: newListInquiry){
            Id inquiryRecordTypeId   = Schema.SObjectType.Inquiry__c.getRecordTypeInfosByName().get(DAMAC_Constants.INQUIRY_CIL_RT).getRecordTypeId();
            if(inquiry.RecordTypeId != inquiryRecordTypeId && !validateMobileNumbers(inquiry)){
                inquiry.Mobile_Phone__c =( String.isBlank(inquiry.Mobile_Phone__c) ? ( String.isBlank(inquiry.Mobile_CountryCode__c) && String.isBlank(inquiry.Mobile_Phone_Encrypt__c) ? '' : ((String.isNotBlank(inquiry.Mobile_Phone_Encrypt__c) && (Trigger.isInsert || inquiry.Mobile_Phone__c == null)) ? (inquiry.Mobile_CountryCode__c.subStringAfter(':')).trim()+''+inquiry.Mobile_Phone_Encrypt__c : inquiry.Mobile_Phone__c)) : inquiry.Mobile_Phone__c);
                inquiry.Mobile_Phone_2__c =( String.isBlank(inquiry.Mobile_Phone_2__c) ? ( String.isBlank(inquiry.Mobile_Country_Code_2__c) && String.isBlank(inquiry.Mobile_Phone_Encrypt_2__c) ? '' :  ((String.isNotBlank(inquiry.Mobile_Phone_Encrypt_2__c) && (Trigger.isInsert || inquiry.Mobile_Phone_2__c == null)) ? (inquiry.Mobile_Country_Code_2__c.subStringAfter(':')).trim()+''+inquiry.Mobile_Phone_Encrypt_2__c : inquiry.Mobile_Phone_2__c)) : inquiry.Mobile_Phone_2__c);
                inquiry.Mobile_Phone_3__c =( String.isBlank(inquiry.Mobile_Phone_3__c) ? ( String.isBlank(inquiry.Mobile_Country_Code_3__c) && String.isBlank(inquiry.Mobile_Phone_Encrypt_3__c) ? '' :  ((String.isNotBlank(inquiry.Mobile_Phone_Encrypt_3__c) && (Trigger.isInsert || inquiry.Mobile_Phone_3__c == null)) ? (inquiry.Mobile_Country_Code_3__c.subStringAfter(':')).trim()+''+inquiry.Mobile_Phone_Encrypt_3__c : inquiry.Mobile_Phone_3__c)) : inquiry.Mobile_Phone_3__c);
                inquiry.Mobile_Phone_4__c =( String.isBlank(inquiry.Mobile_Phone_4__c) ? ( String.isBlank(inquiry.Mobile_Country_Code_4__c) && String.isBlank(inquiry.Mobile_Phone_Encrypt_4__c) ? '' : ((String.isNotBlank(inquiry.Mobile_Phone_Encrypt_4__c) && (Trigger.isInsert || inquiry.Mobile_Phone_4__c == null)) ? (inquiry.Mobile_Country_Code_4__c.subStringAfter(':')).trim()+''+inquiry.Mobile_Phone_Encrypt_4__c : inquiry.Mobile_Phone_4__c)) : inquiry.Mobile_Phone_4__c);
                inquiry.Mobile_Phone_5__c =( String.isBlank(inquiry.Mobile_Phone_5__c) ? ( String.isBlank(inquiry.Mobile_Country_Code_5__c) && String.isBlank(inquiry.Mobile_Phone_Encrypt_5__c) ? '' :  ((String.isNotBlank(inquiry.Mobile_Phone_Encrypt_5__c) && (Trigger.isInsert || inquiry.Mobile_Phone_5__c == null)) ? (inquiry.Mobile_Country_Code_5__c.subStringAfter(':')).trim()+''+inquiry.Mobile_Phone_Encrypt_5__c : inquiry.Mobile_Phone_5__c)) : inquiry.Mobile_Phone_5__c);
                //Encrypting Mobile and storing it on the record.
                System.debug('Before Encryption = '+inquiry);
                inquiry.Mobile_Phone_Encrypt__c = UtilityHelperCls.encryptMobile(inquiry.Mobile_Phone__c);
                inquiry.Mobile_Phone_Encrypt_2__c = UtilityHelperCls.encryptMobile(inquiry.Mobile_Phone_2__c);
                inquiry.Mobile_Phone_Encrypt_3__c = UtilityHelperCls.encryptMobile(inquiry.Mobile_Phone_3__c);
                inquiry.Mobile_Phone_Encrypt_4__c = UtilityHelperCls.encryptMobile(inquiry.Mobile_Phone_4__c);
                inquiry.Mobile_Phone_Encrypt_5__c = UtilityHelperCls.encryptMobile(inquiry.Mobile_Phone_5__c);
                System.debug('After Encryption = '+inquiry);
            }
        }
    }
    
    
    /*********************************************************************************************
    * @Description : Method to validate the mobile number and country code values                *
    * @Params      : List<Inquiry__c>                                                            *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private Boolean validateMobileNumbers(Inquiry__c inquiry){
        Boolean isError = false;
        if(String.isNotBlank(inquiry.Mobile_CountryCode__c) && String.isBlank(inquiry.Mobile_Phone_Encrypt__c)){
             inquiry.Mobile_Phone_Encrypt__c.addError('Mobile Phone can\'t be blank if country code is selected.');
             isError = true;
        }
        if (String.isBlank(inquiry.Mobile_CountryCode__c) && String.isNotBlank(inquiry.Mobile_Phone_Encrypt__c)){
            inquiry.Mobile_CountryCode__c.addError('Mobile Country Code can\'t be blank if Mobile Phone is Populated.');
            isError = true;
        }
        if(String.isNotBlank(inquiry.Mobile_Country_Code_2__c) && String.isBlank(inquiry.Mobile_Phone_Encrypt_2__c)){
             inquiry.Mobile_Phone_Encrypt_2__c.addError('Mobile Phone 2 can\'t be blank if country code 2 is selected.');
             isError = true;
        }
        if (String.isBlank(inquiry.Mobile_Country_Code_2__c) && String.isNotBlank(inquiry.Mobile_Phone_Encrypt_2__c)){
            inquiry.Mobile_Country_Code_2__c.addError('Mobile Country Code can\'t be blank if Mobile Phone 2 is Populated.');
            isError = true;
        }
        if(String.isNotBlank(inquiry.Mobile_Country_Code_3__c) && String.isBlank(inquiry.Mobile_Phone_Encrypt_3__c)){
             inquiry.Mobile_Phone_Encrypt_3__c.addError('Mobile Phone 3 can\'t be blank if country code 3 is selected.');
             isError = true;
        }
        if (String.isBlank(inquiry.Mobile_Country_Code_3__c) && String.isNotBlank(inquiry.Mobile_Phone_Encrypt_3__c)){
            inquiry.Mobile_Country_Code_3__c.addError('Mobile Country Code can\'t be blank if Mobile Phone 3 is Populated.');
            isError = true;
        }
        if(String.isNotBlank(inquiry.Mobile_Country_Code_4__c) && String.isBlank(inquiry.Mobile_Phone_Encrypt_4__c)){
             inquiry.Mobile_Phone_Encrypt_4__c.addError('Mobile Phone 4 can\'t be blank if country code 4 is selected.');
             isError = true;
        }
        if (String.isBlank(inquiry.Mobile_Country_Code_4__c) && String.isNotBlank(inquiry.Mobile_Phone_Encrypt_4__c)){
            inquiry.Mobile_Country_Code_4__c.addError('Mobile Country Code can\'t be blank if Mobile Phone 4 is Populated.');
            isError = true;
        }
        if(String.isNotBlank(inquiry.Mobile_Country_Code_5__c) && String.isBlank(inquiry.Mobile_Phone_Encrypt_5__c)){
             inquiry.Mobile_Phone_Encrypt_5__c.addError('Mobile Phone 5 can\'t be blank if country code 5 is selected.');
             isError = true;
        }
        if (String.isBlank(inquiry.Mobile_Country_Code_5__c) && String.isNotBlank(inquiry.Mobile_Phone_Encrypt_5__c)){
            inquiry.Mobile_Country_Code_5__c.addError('Mobile Country Code can\'t be blank if Mobile Phone 5 is Populated.');
            isError = true;
        }
        return isError;
    }
    
    /*********************************************************************************************
    * @Description : Updates Inquiry Source based on recordtype of Campaign if it exists.        *
    * @Params      : Map<Id, sObject>, Map<Id, sObject>                                          *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    
    private void UpdateInquirySource(List<Inquiry__c> lstNewRecords, Map<Id, sObject> mapOldRecords){
        system.debug('update inquiry source');
        Set<Id> campaignIds = new Set<Id>();
        Map<Id, Campaign__c> campaignMap = new Map<Id, Campaign__c>();
        Id roadshowRt = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Roadshows').getRecordTypeId();
        Id digitalRt = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Digital').getRecordTypeId();
        Id standaloneRt = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Standalone').getRecordTypeId();
        Id conventionalRt = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Conventional').getRecordTypeId();
        Id salesEventsRt = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Sales Events').getRecordTypeId();
        List<Inquiry__c> inquiryList = new List<Inquiry__c>();
        if(!lstNewRecords.isEmpty()){
            for(Inquiry__c thisInquiry : lstNewRecords){
                if(thisInquiry.Campaign__c!=null){
                	campaignIds.add(thisInquiry.Campaign__c);
                }
            }
        }
        
        if(!campaignIds.isEmpty()){
            for(Campaign__c thisCampaign : [SELECT Id, Name, RecordTypeId, Campaign_Type_New__c FROM Campaign__c WHERE Id in: campaignIds]){
                campaignMap.put(thisCampaign.Id, thisCampaign);
            }
        }
        if(!lstNewRecords.isEmpty()){
            for(Inquiry__c thisInquiry : lstNewRecords){
                if(thisInquiry.Campaign__c != null && (thisInquiry.Inquiry_Source__c == null || thisInquiry.Inquiry_Source__c != '')){
                    system.debug(campaignMap.get(thisInquiry.Campaign__c));
                    system.debug(campaignMap.get(thisInquiry.Campaign__c).RecordTypeId);
                    if(campaignMap.get(thisInquiry.Campaign__c).RecordTypeId == roadshowRt){
                        thisInquiry.Inquiry_Source__c = 'Roadshow/Exhibition';
                    }else if(campaignMap.get(thisInquiry.Campaign__c).RecordTypeId == digitalRt){
                        thisInquiry.Inquiry_Source__c = 'Digital';
                    }else if(campaignMap.get(thisInquiry.Campaign__c).RecordTypeId == standaloneRt){
                        thisInquiry.Inquiry_Source__c = 'Direct';
                    }else if(campaignMap.get(thisInquiry.Campaign__c).RecordTypeId == conventionalRt){
                        if(campaignMap.get(thisInquiry.Campaign__c).Campaign_Type_New__c =='Stands'){
                            thisInquiry.Inquiry_Source__c = 'Stands';
                        } else if(campaignMap.get(thisInquiry.Campaign__c).Campaign_Type_New__c =='Referral'){
                            thisInquiry.Inquiry_Source__c = 'Other Referrals';
                        }
                    }else if(campaignMap.get(thisInquiry.Campaign__c).RecordTypeId == salesEventsRt){
                        thisInquiry.Inquiry_Source__c = 'Roadshow/Exhibition';
                    }
                }
                system.debug(thisInquiry.Inquiry_Source__c);
            }
        }
    }
    
    /*********************************************************************************************
    * @Description : Roll up Number of Inquiries attached to a campaign on the campaign Object   *
    * @Params      : Map<Id, sObject>, Map<Id, sObject>                                          *
    * @Return      : void                                                                        *
    *********************************************************************************************/      
    public void rollupInquiry(Map<Id, sObject> mapNewRecords){
        
        Set<id> campaignIds = new Set<id>();
        Map<String, Campaign__c> campaignMap; 
        List<Inquiry__c> inquiryList = new List<Inquiry__c>();
        system.debug(mapNewRecords);
        try{
            if(Trigger.isInsert || Trigger.isUpdate){
                for(Inquiry__c thisInquiry: (List<Inquiry__c>)mapNewRecords.values()){ 
                    system.debug(thisInquiry);
                    if(thisInquiry.Campaign__c != null){
                        system.debug(thisInquiry.Campaign__c);
                        system.debug(thisInquiry.Campaign__r.Name);
                        campaignIds.add(thisInquiry.Campaign__c);
                    }
                }
            } 
            
            campaignMap = new Map<String, Campaign__c>([SELECT Id, Total_No_of_Leads__c FROM Campaign__c WHERE Id in: campaignIds]);
            system.debug(campaignMap);
            
            AggregateResult[] aggrQuery = [SELECT Campaign__c campaignId, COUNT(Id) counter FROM Inquiry__c WHERE Campaign__c in: campaignIds GROUP BY Campaign__c];
            system.debug(aggrQuery);
            
            if(aggrQuery!=null){
                for(AggregateResult ar: aggrQuery){
                    if(ar.get('campaignId') != null){
                        Campaign__c thisCampaign = campaignMap.get(String.valueOf(ar.get('campaignId'))); 
                        thisCampaign.Total_No_of_Leads__c = (Decimal)(ar.get('counter'));
                        campaignMap.put(String.valueOf(ar.get('campaignId')), thisCampaign);
                    }
                }           
            }
            if(!campaignMap.isEmpty()){
                update campaignMap.values();
            }   
        }catch(Exception ex){
            System.debug('Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage());
        }
    }
}// End of class.