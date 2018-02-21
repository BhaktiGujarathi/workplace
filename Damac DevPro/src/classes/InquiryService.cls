/*
* Name : Pavithra Gajendra
* Date : 01/22/2017
* Purpose : Inquiry service has all the methods of the Inquiry object
* Company : NSI Gulf
* Change History:
* CH01 # 359 # marking the map key as toUpper Case()
* CH02 # 351 # 15-03-2017 # Sivasankar # Reshuffling Block Date 
* CH03 # 19-03-2017 # Sivasankar # logic for possible matches.

*/
public virtual class InquiryService extends DamacUtility{
    
    public static final String SCORE_1 = 'Hot';
    public static final String SCORE_2 = 'Warm';
    public static final String SCORE_3 = 'Cold';
    
    /*
    * Get User Details based on Profile & available without being on leave
    */ 
    public static Map<Id,User> getUserDetailsByProfile(Id profileId){
        Map<Id,User> userIdDetailsMap = new Map<Id,User>();
        for(User aUser : [SELECT Id, Name, Languages_Known__c, Email, Manager.Email, Leave_Start_Date__c, Extension,//added Extension filed to query
                                 Date_of_Joining__c, Leave_End_Date__c, Sales_office__c,ManagerID, 
                                 Manager.UserRole.Name, Manager.Manager.UserRole.Name,Reshuffling_Block_Date__c 
                          FROM User 
                          WHERE ProfileId=:profileId AND //CH02 Reshuffling_Block_Date__c != TODAY AND //CH02
                                isActive=true AND 
                                ((Leave_Start_Date__c =null AND Leave_End_Date__c =null) OR 
                                 (Leave_Start_Date__c < TODAY AND Leave_End_Date__c < TODAY) OR 
                                 (Leave_Start_Date__c > TODAY AND Leave_End_Date__c > TODAY))]){
            userIdDetailsMap.put(aUser.Id,aUser);
        }
        return userIdDetailsMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to get all campaign related property consultants,                    *
    *                If no property consultants are assigned look for them in parent.            *
    *                If not then it's parent, upto level 4 only.                                 *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<Id, List<User>>                                                         *
    *********************************************************************************************/     
    public Map<Id, List<User>> getAllCampaignUser(Set<Id> campaignIds){
    	Set<Id> campaignIdsSet = new Set<Id>();
        Map<Id, Campaign__c> campaignMap = new Map<Id, Campaign__c>();
        Map<Id, List<User>> campaignUsersMap = new Map<Id, List<User>>();
        Map<Id, List<User>> campaignAssociatedPcsMap = new Map<Id, List<User>>();
        for(Campaign__c thisCampaign : [SELECT Id, Parent_Campaign__c, Parent_Campaign__r.Parent_Campaign__c, 
												 Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__c, 
												 Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__c
										FROM Campaign__c WHERE Id IN: campaignIds]){
        	campaignIdsSet.add(thisCampaign.Id);	
        	if(thisCampaign.Parent_Campaign__c != null){
        		campaignIdsSet.add(thisCampaign.Parent_Campaign__c);	
        	}
        	if(thisCampaign.Parent_Campaign__r.Parent_Campaign__c != null){
        		campaignIdsSet.add(thisCampaign.Parent_Campaign__r.Parent_Campaign__c);	
        	}
        	if(thisCampaign.Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__c != null){
        		campaignIdsSet.add(thisCampaign.Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__c);	
        	}
        	if(thisCampaign.Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__c != null){
        		campaignIdsSet.add(thisCampaign.Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__c);	
        	}
        	campaignMap.put(thisCampaign.Id, thisCampaign);
        }
        
        if(!campaignIdsSet.isEmpty()){
        	for(Assigned_PC__c campaignUser : [SELECT Id, User__c, Campaign__c, User__r.Name,User__r.Reshuffling_Block_Date__c, 
	                                                  User__r.Languages_Known__c, User__r.Email, 
	                                                  User__r.Manager.Email, User__r.Leave_Start_Date__c, 
	                                                  User__r.Leave_End_Date__c, User__r.Sales_office__c, 
	                                                  User__r.Date_of_Joining__c 
	                                           FROM Assigned_PC__c 
	                                           WHERE Campaign__c IN:campaignIdsSet AND 
	                                                 User__r.isActive = true AND 
	                                                ((User__r.Leave_Start_Date__c = null AND User__r.Leave_End_Date__c = null) OR 
	                                                 (User__r.Leave_Start_Date__c < TODAY AND User__r.Leave_End_Date__c < TODAY) OR 
	                                                 (User__r.Leave_Start_Date__c > TODAY AND User__r.Leave_End_Date__c > TODAY))]){
	            User associatedUser = new User(Id = campaignUser.User__c,
	            							   Languages_Known__c = campaignUser.User__r.Languages_Known__c,
	            							   Date_of_Joining__c = campaignUser.User__r.Date_of_Joining__c);
	            if(campaignUsersMap.containskey(campaignUser.Campaign__c)){
	                campaignUsersMap.get(campaignUser.Campaign__c).add(associatedUser);
	            }else{
	                campaignUsersMap.put(campaignUser.Campaign__c, new List<User>{associatedUser});
	            }
	        }		
	        for(Id thisKey : campaignIds){
	       		if(campaignUsersMap.containsKey(thisKey) && !campaignUsersMap.get(thisKey).isEmpty()){
	       			campaignAssociatedPcsMap.put(thisKey, new List<User>(campaignUsersMap.get(thisKey)));	
	       		}else if(campaignMap.containsKey(thisKey) && 
	       				 campaignMap.get(thisKey).Parent_Campaign__c != null && 
	       				 campaignUsersMap.containsKey(campaignMap.get(thisKey).Parent_Campaign__c) && 
	       				!campaignUsersMap.get(campaignMap.get(thisKey).Parent_Campaign__c).isEmpty()){
	       			campaignAssociatedPcsMap.put(thisKey, new List<User>(campaignUsersMap.get(campaignMap.get(thisKey).Parent_Campaign__c)));	
	       		}else if(campaignMap.containsKey(thisKey) && 
	       				 campaignMap.get(thisKey).Parent_Campaign__r.Parent_Campaign__c != null && 
	       				 campaignUsersMap.containsKey(campaignMap.get(thisKey).Parent_Campaign__r.Parent_Campaign__c) &&
	       				!campaignUsersMap.get(campaignMap.get(thisKey).Parent_Campaign__r.Parent_Campaign__c).isEmpty()){
	       			campaignAssociatedPcsMap.put(thisKey, new List<User>(campaignUsersMap.get(campaignMap.get(thisKey).Parent_Campaign__r.Parent_Campaign__c)));	
	       		}else if(campaignMap.containsKey(thisKey) && 
	       				 campaignMap.get(thisKey).Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__c != null &&
	       				 campaignUsersMap.containsKey(campaignMap.get(thisKey).Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__c) && 
	       			    !campaignUsersMap.get(campaignMap.get(thisKey).Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__c).isEmpty()){
	       			campaignAssociatedPcsMap.put(thisKey, new List<User>(campaignUsersMap.get(campaignMap.get(thisKey).Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__c)));	
	       		}else if(campaignMap.containsKey(thisKey) &&
	       				 campaignMap.get(thisKey).Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__c != null &&
	       				 campaignUsersMap.containsKey(campaignMap.get(thisKey).Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__c) && 
	       				!campaignUsersMap.get(campaignMap.get(thisKey).Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__c).isEmpty()){
	       			campaignAssociatedPcsMap.put(thisKey, new List<User>(campaignUsersMap.get(campaignMap.get(thisKey).Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__r.Parent_Campaign__c)));	
	       		}	
	        }
        }
        return campaignAssociatedPcsMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to get PC performance map.                                           *
    * @Params      : Map<Id, List<Id>>                                                           *
    * @Return      : Map<Id, Integer>                                                            *
    *********************************************************************************************/ 
    public Map<Id, Integer> getPcPerformanceMap(Map<Id, List<Id>> parentSortedEligibleUsersMap){
        Decimal highestBookingAmount = 0.0;
        Id DEAL_RECORD_TYPE_ID = DamacUtility.getRecordTypeId('NSIBPM__Service_Request__c', 'Deal');
        Set<Id> pcIdsSet = new Set<Id>();
        Map<Id, Integer> pcPerformanceBandMap = new Map<Id, Integer>(); 
        Map<Id, Decimal> pcBookingAmountMap = new Map<Id, Decimal>(); 
        for(Id thisKey : parentSortedEligibleUsersMap.keySet()){
            pcIdsSet.addAll(parentSortedEligibleUsersMap.get(thisKey)); 
        }
        if(!pcIdsSet.isEmpty()){
            for(NSIBPM__Service_Request__c thisDeal : [SELECT Id, Total_Booking_Amount__c,
                                                              (SELECT Id, Associated_PC__c FROM Deal_Team__r WHERE Associated_PC__c =: pcIdsSet) 
                                                       FROM NSIBPM__Service_Request__c 
                                                       WHERE RecordTypeId =: DEAL_RECORD_TYPE_ID AND 
                                                             Total_Booking_Amount__c != NULL AND 
                                                             Registration_Status__c = 'Approved' AND  
                                                             Registration_Date__c = LAST_90_DAYS AND 
                                                             Doc_ok__c = true AND 
                                                             DP_ok__c = true
                                                       ORDER BY Total_Booking_Amount__c ASC]){
                highestBookingAmount = thisDeal.Total_Booking_Amount__c;
                for(Deal_Team__c thisDealTeamMember : thisDeal.Deal_Team__r){
                    if(pcBookingAmountMap.containsKey(thisDealTeamMember.Associated_PC__c)){
                        pcBookingAmountMap.put(
                            thisDealTeamMember.Associated_PC__c, 
                            pcBookingAmountMap.get(thisDealTeamMember.Associated_PC__c) + (thisDeal.Total_Booking_Amount__c / thisDeal.Deal_Team__r.size()));
                    }else{
                        pcBookingAmountMap.put(thisDealTeamMember.Associated_PC__c, (thisDeal.Total_Booking_Amount__c / thisDeal.Deal_Team__r.size()));   
                    }
                }   
            }   
        }
        /* Calling method to get the PC performance band. */
        return getPcPerformanceBandMap(highestBookingAmount, pcBookingAmountMap);
    }
    
    /*********************************************************************************************
    * @Description : Method to get PC performance band map.                                      *
    * @Params      : Decimal, Map<Id, Decimal>                                                   *
    * @Return      : Map<Id, Integer>                                                            *
    *********************************************************************************************/ 
    public Map<Id, Integer> getPcPerformanceBandMap(Decimal highestBookingAmount, Map<Id, Decimal> pcBookingAmountMap){
        String PERFORMANCE_BAND_SIZE = Label.Performance_Band_Size; 
        Map<Decimal, Decimal> maxMinValuesMap = new Map<Decimal, Decimal>();
        Map<Id, Integer> pcPerformanceBandMap = new Map<Id, Integer>();
        if(PERFORMANCE_BAND_SIZE.isNumeric()){
            for(Integer counter = 0; counter < getLoopCount(highestBookingAmount, PERFORMANCE_BAND_SIZE); counter++){
                maxMinValuesMap.put(Integer.valueOf(PERFORMANCE_BAND_SIZE) * counter, Integer.valueOf(PERFORMANCE_BAND_SIZE) * (counter + 1));  
            }
        }
        for(Id thisKey : pcBookingAmountMap.keySet()){
            for(Decimal thisMinValue : maxMinValuesMap.keySet()){
                if(thisMinValue <= pcBookingAmountMap.get(thisKey) && pcBookingAmountMap.get(thisKey) <= maxMinValuesMap.get(thisMinValue)){
                    pcPerformanceBandMap.put(thisKey, Integer.valueOf(maxMinValuesMap.get(thisMinValue)));  
                }
            }
        }
        return pcPerformanceBandMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to get PC performance band map.                                      *
    * @Params      : Decimal, Map<Id, Decimal>                                                   *
    * @Return      : Map<Id, Integer>                                                            *
    *********************************************************************************************/ 
    public Map<Id, Integer> getPcMeetingBandMap(Integer highestMeetingCount, Map<Id, Integer> pcWithMeetingCount){
        String ACTIVITY_BAND_SIZE = Label.Activity_Band_Size;
        Map<Decimal, Decimal> maxMinValuesMap = new Map<Decimal, Decimal>();
        Map<Id, Integer> pcMeetingBandMap = new Map<Id, Integer>();
        if(ACTIVITY_BAND_SIZE.isNumeric()){
            for(Integer counter = 0; counter < getLoopCount(highestMeetingCount, ACTIVITY_BAND_SIZE); counter++){
                maxMinValuesMap.put(Integer.valueOf(ACTIVITY_BAND_SIZE) * counter, Integer.valueOf(ACTIVITY_BAND_SIZE) * (counter + 1));    
            }
        }
        for(Id thisKey : pcWithMeetingCount.keySet()){
            for(Decimal thisMinValue : maxMinValuesMap.keySet()){
                if(thisMinValue <= pcWithMeetingCount.get(thisKey) && pcWithMeetingCount.get(thisKey) <= maxMinValuesMap.get(thisMinValue)){
                    pcMeetingBandMap.put(thisKey, Integer.valueOf(maxMinValuesMap.get(thisMinValue)));  
                }
            }
        }
        return pcMeetingBandMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to get loop count, based on dynamic band splitting.                  *
    * @Params      : Decimal                                                                     *
    * @Return      : Integer                                                                     *
    *********************************************************************************************/ 
    public Integer getLoopCount(Decimal highestValue, String bandSize){ 
        Integer loopCount = 0;
        if(highestValue != null && String.isNotBlank(bandSize)){
            if(Math.mod(Integer.valueOf(highestValue), Integer.valueOf(bandSize)) == 0){
                loopCount = Integer.valueOf(highestValue)/Integer.valueOf(bandSize);  
            }else{
                loopCount = (Integer.valueOf(highestValue)/Integer.valueOf(bandSize)) + 1; 
            }  
        }   
        return loopCount;
    }
    
    /*********************************************************************************************
    * @Description : Method to upgrade the score one point above the present score.              *
    * @Params      : String                                                                      *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    public String upgradeScore(String presentScore){ 
        if(String.isBlank(presentScore)){
            return SCORE_2;
        }else if(String.isNotBlank(presentScore) && presentScore.equalsIgnoreCase(SCORE_3)){
            return SCORE_2;     
        }else if(String.isNotBlank(presentScore) && presentScore.equalsIgnoreCase(SCORE_2)){
            return SCORE_1; 
        }else{
            return presentScore;
        }   
    }
    
    /*********************************************************************************************
    * @Description : Method to downgrade the score one point above the present score.            *
    * @Params      : String                                                                      *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    public String downgradeScore(String presentScore){
        if(String.isBlank(presentScore)){
            return SCORE_2;
        }else if(String.isNotBlank(presentScore) && presentScore.equalsIgnoreCase(SCORE_1)){
            return SCORE_2;     
        }else if(String.isNotBlank(presentScore) && presentScore.equalsIgnoreCase(SCORE_2)){
            return SCORE_3; 
        }else{
            return presentScore;
        }   
    }
    
    /*********************************************************************************************
    * @Description : Method to get all historical owner Id's of nuturing inquiry records.        *
    * @Params      : List<Id>                                                                    *
    * @Return      : Map<Id, Set<Id>>                                                            *
    *********************************************************************************************/
    public Map<Id, Set<Id>> getNurturingInquiryDetails(Set<Id> nurturingInquiresSet){
        Map<Id, Set<Id>> nurturingInquiryOwnersSetMap = new Map<Id, Set<Id>>();
        for(Inquiry__History owners : [SELECT Field, Id, NewValue, OldValue, ParentID 
                                       FROM Inquiry__History 
                                       WHERE Field = 'Owner' AND 
                                             ParentId IN: nurturingInquiresSet 
                                       ORDER BY ParentId]){
            String ownerId = String.valueOf(owners.NewValue);
            String userKeyPrefix =  Schema.getGlobalDescribe().get('User').getDescribe().getkeyprefix();
            if(ownerId.startsWith(userKeyPrefix)){
                if(nurturingInquiryOwnersSetMap.containsKey(owners.ParentID)){
                    nurturingInquiryOwnersSetMap.get(owners.ParentID).add(ID.valueOf(ownerId));
                }else{
                    nurturingInquiryOwnersSetMap.put(owners.ParentID,new Set<ID>{Id.valueOf(ownerId)}); 
                }
            }
        }  
        return nurturingInquiryOwnersSetMap;
    }   
    
    /*********************************************************************************************
    * @Description : Method to get all matching account based on the unique keys.                *
    * @Params      : Set<String>, Set<String>                                                    *
    * @Return      : Map<String, Account>                                                        *
    *********************************************************************************************/     
    public Map<String, Account> getMatchingAccount(Set<String> allUniquePhoneKeysSet, Set<String> allUniqueMailKeysSet){
        Map<String, Account> existingKeyAccountMap = new Map<String, Account>();
        for(Account thisAccount : [SELECT Id, OwnerId, Phone_Key__c, Email_Key__c, Name 
                                   FROM Account 
                                   WHERE IsPersonAccount = true AND
                                         //Phone_Key__c != null AND 
                                         //Email_Key__c != null AND
                                         //CreatedDate = TODAY AND
                                         (Phone_Key__c IN: allUniqueMailKeysSet OR Email_Key__c IN: allUniqueMailKeysSet)]){
                if(String.isNotBlank(thisAccount.Phone_Key__c) && allUniquePhoneKeysSet.contains(thisAccount.Phone_Key__c.toUpperCase())){
                    existingKeyAccountMap.put(thisAccount.Phone_Key__c.toUpperCase(), thisAccount);//CH01
                }
            
                if(String.isNotBlank(thisAccount.Email_Key__c) && allUniqueMailKeysSet.contains(thisAccount.Email_Key__c.toUpperCase())){
                    existingKeyAccountMap.put(thisAccount.Email_Key__c.toUpperCase(), thisAccount);//CH01
                }
            }
        return existingKeyAccountMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to get all matching inquiry based on the unique keys.                *
    * @Params      : Set<String>, Set<String>                                                    *
    * @Return      : Map<String, Inquiry__c>                                                     *
    *********************************************************************************************/ 
    public Map<String, List<Inquiry__c>> getMatchingInquiry(Set<String> allUniquePhoneKeysSet, Set<String> allUniqueMailKeysSet,Set<ID> campaignID){
        Map<String, List<Inquiry__c>> existingKeyInquiryMap = new Map<String, List<Inquiry__c>>();
        for(Inquiry__c existingInquiry : [SELECT Id, Phone_Unique_key__c, Email_Unique_key__c, Inquiry_Status__c, 
                                                 Campaign__c, Duplicates_Count__c, Inquiry_From_Other_Sources__c, 
                                                 OwnerId, Name, Inquiry_Score__c,(SELECT ID,CreatedDate FROM Tasks ORDER By CreatedDate DESC LIMIT 1),(SELECT ID,CreatedDate FROM Events ORDER By CreatedDate DESC LIMIT 1)
                                          FROM Inquiry__c 
                                          WHERE (Phone_Unique_key__c IN: allUniquePhoneKeysSet OR 
                                                 Email_Unique_key__c IN: allUniqueMailKeysSet) AND 
                                                 Duplicate__c = false Order by CreatedDate ASC
                                          LIMIT : LIMITS.getLimitQueryRows()]){
            //CH01 to Upper Case, CH02 modified the map for duplicate check
            if(String.isNotBlank(existingInquiry.Phone_Unique_key__c) && allUniquePhoneKeysSet.contains(existingInquiry.Phone_Unique_key__c.toUpperCase())){
                if(existingKeyInquiryMap.containsKey(existingInquiry.Phone_Unique_key__c.toUpperCase())){
                    existingKeyInquiryMap.get(existingInquiry.Phone_Unique_key__c.toUpperCase()).add(existingInquiry);
                    if(existingInquiry.Campaign__c != null && campaignID.contains(existingInquiry.Campaign__c))
                        if(existingKeyInquiryMap.containsKey((existingInquiry.Phone_Unique_key__c+''+existingInquiry.Campaign__c).toUpperCase()))
                            existingKeyInquiryMap.get((existingInquiry.Phone_Unique_key__c+''+existingInquiry.Campaign__c).toUpperCase()).add(existingInquiry);
                        else
                            existingKeyInquiryMap.put((existingInquiry.Phone_Unique_key__c+''+existingInquiry.Campaign__c).toUpperCase(),new List<Inquiry__C>{existingInquiry});
                }
                else{ 
                    existingKeyInquiryMap.put(existingInquiry.Phone_Unique_key__c.toUpperCase(),new List<Inquiry__C>{existingInquiry});
                    if(existingInquiry.Campaign__c != null && campaignID.contains(existingInquiry.Campaign__c))
                    existingKeyInquiryMap.put((existingInquiry.Phone_Unique_key__c+''+existingInquiry.Campaign__c).toUpperCase(),new List<Inquiry__C>{existingInquiry});
                }
            }
        
            if(String.isNotBlank(existingInquiry.Email_Unique_key__c) && allUniqueMailKeysSet.contains(existingInquiry.Email_Unique_key__c.toUpperCase())){
                if(existingKeyInquiryMap.containsKey(existingInquiry.Email_Unique_key__c.toUpperCase())){
                    existingKeyInquiryMap.get(existingInquiry.Email_Unique_key__c.toUpperCase()).add(existingInquiry);
                    if(existingInquiry.Campaign__c != null && campaignID.contains(existingInquiry.Campaign__c))
                        if(existingKeyInquiryMap.containsKey((existingInquiry.Email_Unique_key__c+''+existingInquiry.Campaign__c).toUpperCase()))
                            existingKeyInquiryMap.get((existingInquiry.Email_Unique_key__c+''+existingInquiry.Campaign__c).toUpperCase()).add(existingInquiry);
                        else
                            existingKeyInquiryMap.put((existingInquiry.Email_Unique_key__c+''+existingInquiry.Campaign__c).toUpperCase(),new List<Inquiry__C>{existingInquiry});
                }
                else{
                    existingKeyInquiryMap.put(existingInquiry.Email_Unique_key__c.toUpperCase(),new List<Inquiry__C>{existingInquiry});
                    if(existingInquiry.Campaign__c != null && campaignID.contains(existingInquiry.Campaign__c))
                    existingKeyInquiryMap.put((existingInquiry.Email_Unique_key__c+''+existingInquiry.Campaign__c).toUpperCase(),new List<Inquiry__C>{existingInquiry});
                }
            }
        }   
        return existingKeyInquiryMap;
    }
    
    //CH02.Start
    /*********************************************************************************************
    * @Description : Method to return the eligible Inquiry record to map the related Inquiry     *
    * @Params      : Set<String>, Set<String>                                                    *
    * @Return      : Map<String, Inquiry__c>                                                     *
    *********************************************************************************************/
    public Inquiry__c getMatchingInquiryRecord(Inquiry__c thisInquiry,List<Inquiry__c> eligibleInquiryList){
        Inquiry__c matchInq = new Inquiry__c();
        DateTime latestDateOfeligibility = null,latestDateOfMatch = null;
        if(thisInquiry.Campaign__c != null && !eligibleInquiryList.isEmpty() && eligibleInquiryList.size() == 1 )
            return eligibleInquiryList[0];
        for(Inquiry__c eligibleInqury : eligibleInquiryList){
            System.debug('Condition 1 = '+(eligibleInqury.Inquiry_Status__c.containsIgnoreCase(DAMAC_Constants.INQUIRY_ACTIVE_STATUS) || eligibleInqury.Inquiry_Status__c.containsIgnoreCase(DAMAC_Constants.INQUIRY_NEW_STATUS)));
            System.debug('Condition 2 = '+(matchInq.Id != null));
            System.debug('Condition 3 = '+(matchInq.Inquiry_Status__c != eligibleInqury.Inquiry_Status__c && eligibleInqury.Inquiry_Status__c.containsIgnoreCase(DAMAC_Constants.INQUIRY_ACTIVE_STATUS)));
            System.debug('Condition 4 = '+(getLatestDate(matchInq) < getLatestDate(eligibleInqury)));
            //thisInquiry.Campaign__c == null &&
            if(eligibleInqury.Inquiry_Status__c != null &&  
                    (eligibleInqury.Inquiry_Status__c.containsIgnoreCase(DAMAC_Constants.INQUIRY_ACTIVE_STATUS) 
                        || eligibleInqury.Inquiry_Status__c.containsIgnoreCase(DAMAC_Constants.INQUIRY_NEW_STATUS)) 
                    && (matchInq.Id == null 
                    || (matchInq.Inquiry_Status__c != eligibleInqury.Inquiry_Status__c && eligibleInqury.Inquiry_Status__c.containsIgnoreCase(DAMAC_Constants.INQUIRY_ACTIVE_STATUS)) 
                    || (getLatestDate(matchInq) < getLatestDate(eligibleInqury)) )){
                System.debug('matchInq 1= '+eligibleInqury);
                //if(thisInquiry.Campaign__c != null && )
                matchInq = eligibleInqury;
            }
        }
        system.debug('matchInq2 = '+matchInq);
        return matchInq;
    }
    
    /*********************************************************************************************
    * @Description : get the latest date of evets and tasks                                      *
    * @Params      : Set<String>, Set<String>                                                    *
    * @Return      : Map<String, Inquiry__c>                                                     *
    *********************************************************************************************/
    public DateTime getLatestDate(Inquiry__c thisInquiry){
        DateTime latestDateOfeligibilityInquiry = DateTime.newInstance(Date.today(),Time.newInstance(0, 0, 0, 0));
        if(thisInquiry.id != null){
            latestDateOfeligibilityInquiry = ( (thisInquiry.Events.isEmpty() && thisInquiry.Tasks.isEmpty()) ? null : ( (!thisInquiry.Events.isEmpty() && !thisInquiry.Tasks.isEmpty()) ? (thisInquiry.Events[0].CreatedDate < thisInquiry.Tasks[0].CreatedDate ? thisInquiry.Tasks[0].CreatedDate : thisInquiry.Events[0].CreatedDate) : null));
            latestDateOfeligibilityInquiry = (latestDateOfeligibilityInquiry != null ? latestDateOfeligibilityInquiry : (!thisInquiry.Events.isEmpty() ? thisInquiry.Events[0].CreatedDate : null));
            latestDateOfeligibilityInquiry = (latestDateOfeligibilityInquiry != null ? latestDateOfeligibilityInquiry : (!thisInquiry.Tasks.isEmpty() ? thisInquiry.Tasks[0].CreatedDate : null));
        }
        system.debug('latestDateOfeligibilityInquiry = '+latestDateOfeligibilityInquiry);
        return latestDateOfeligibilityInquiry;
    }
    //CH02.End
    /*********************************************************************************************
    * @Description : Method to get all property related PC's.                                    *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<Id, List<User>>                                                         *
    *********************************************************************************************/     
    public Map<Id, List<User>> getAllPropertyUser(Set<Id> propertyIdsSet){
        Map<Id, List<User>> propertyUsersMap = new Map<Id, List<User>>();
        for(Assigned_Property_User__c assignedUser : [SELECT Id, Assigned_User__c, Associated_Property__c, Assigned_User__r.Name, 
                                                              Assigned_User__r.Languages_Known__c, Assigned_User__r.Email, 
                                                              Assigned_User__r.Manager.Email, Assigned_User__r.Leave_Start_Date__c, 
                                                              Assigned_User__r.Leave_End_Date__c, Assigned_User__r.Sales_office__c,
                                                             Assigned_User__r.Date_of_Joining__c,Assigned_User__r.Reshuffling_Block_Date__c 
                                                       FROM Assigned_Property_User__c 
                                                       WHERE Associated_Property__c IN: propertyIdsSet AND //CH02 Assigned_User__r.Reshuffling_Block_Date__c != TODAY AND //CH02
                                                             Assigned_User__r.isActive = true AND 
                                                            ((Assigned_User__r.Leave_Start_Date__c = null AND Assigned_User__r.Leave_End_Date__c = null) OR 
                                                             (Assigned_User__r.Leave_Start_Date__c < TODAY AND Assigned_User__r.Leave_End_Date__c < TODAY) OR 
                                                             (Assigned_User__r.Leave_Start_Date__c > TODAY AND Assigned_User__r.Leave_End_Date__c > TODAY))]){
            User associatedUser = new User();
            associatedUser.Id = assignedUser.Assigned_User__c;
            associatedUser.Languages_Known__c = assignedUser.Assigned_User__r.Languages_Known__c;
            associatedUser.Date_of_Joining__c = assignedUser.Assigned_User__r.Date_of_Joining__c;
            
            if(propertyUsersMap.containskey(assignedUser.Associated_Property__c)){
                propertyUsersMap.get(assignedUser.Associated_Property__c).add(associatedUser);
            }else{
                propertyUsersMap.put(assignedUser.Associated_Property__c, new List<User>{associatedUser});
            }
        }
        return propertyUsersMap ; 
    }
    
    /*********************************************************************************************
    * @Description : Method to query inquiry and meetings based on the owner.                    *
    * @Params      : Map<Id, Integer>, Map<Id, List<Id>>                                         *
    * @Return      : Map<Id, Integer>                                                            *
    *********************************************************************************************/ 
    public static Map<Id, List<Inquiry__c>> getAllUserWithLeadLoad(Map<Id, Integer> userIdsScoreMap){
        Id inquiryRecordTypeId = Schema.SObjectType.Inquiry__c.getRecordTypeInfosByName().get(DAMAC_Constants.INQUIRY_RT).getRecordTypeId();
        Map<Id, List<Inquiry__c>> userAssociatedInquiryListMap = new Map<Id, List<Inquiry__c>>();
        for(Inquiry__c thisInquiry :[SELECT Id, OwnerId, Inquiry_Status__c, 
                                            (SELECT Id, OwnerId, Status__c 
                                             FROM Events 
                                             WHERE ActivityDate = LAST_N_DAYS:90 AND 
                                                   OwnerId IN: userIdsScoreMap.keySet())  
                                     FROM Inquiry__c  
                                     WHERE CreatedDate = LAST_N_DAYS:90 AND
                                           OwnerId IN: userIdsScoreMap.keySet() AND 
                                     	   RecordTypeId =: inquiryRecordTypeId AND
                                           Inquiry_Source_Indexed__c IN: DAMAC_Constants.inquirySourceToInclude AND
                                           (Inquiry_Status_Indexed__c =: DAMAC_Constants.INQUIRY_ACTIVE_STATUS OR
                                            Inquiry_Status_Indexed__c =: DAMAC_Constants.INQUIRY_NEW_STATUS) AND
                                           Duplicate__c = false AND 
                                     	   IsDeleted = false  
                                     LIMIT : 30000]){
            if(userAssociatedInquiryListMap.containsKey(thisInquiry.OwnerId)){
                userAssociatedInquiryListMap.get(thisInquiry.OwnerId).add(thisInquiry);    
            }else{
                userAssociatedInquiryListMap.put(thisInquiry.OwnerId, new List<Inquiry__c>{thisInquiry});       
            }   
        }
        return userAssociatedInquiryListMap; 
    }
    
    /*********************************************************************************************
    * @Description : Wrapper class to implement custom comparison.                               *
    *********************************************************************************************/ 
    public class UserLoadWrapper implements Comparable {
        public Id recordId;
        public Integer newInquiryLoad;
        public Integer performanceScore;
        public Integer tenure;
        public Integer meetingLoad;
        public Integer allInquiryLoad;          
        
        /*********************************************************************************************
        * @Description : Constructor.                                                                *
        * @Params      : void                                                                        *
        * @Return      : void                                                                        *
        *********************************************************************************************/ 
        public UserLoadWrapper(String recordId, Integer newInquiryLoad, Integer performanceScore, 
                               Integer tenure, Integer meetingLoad, Integer allInquiryLoad) {
            this.recordId = recordId;
            this.newInquiryLoad = newInquiryLoad;
            this.performanceScore = performanceScore;
            this.tenure = tenure;
            this.meetingLoad = meetingLoad;
            this.allInquiryLoad = allInquiryLoad;                  
        }
        
        /*********************************************************************************************
        * @Description : Implementing the compareTo method.                                          *
        *                Order of preference :                                                       *
        *                - New Leads                                                                 *
        *                - Performance : Bandas of 500,000                                           *
        *                - Tenure : Bands greated than 6 months and less than 6 months.              *
        *                - Meetings                                                                  *
        *                - All Leads                                                                 *
        * @Params      : Object                                                                      *
        * @Return      : Integer                                                                     *
        *********************************************************************************************/ 
       public Integer compareTo(Object compareTo) {
            UserLoadWrapper compareToExistingUsers = (UserLoadWrapper)compareTo;
            if(newInquiryLoad == compareToExistingUsers.newInquiryLoad){
                if(performanceScore == compareToExistingUsers.performanceScore){
                    if(tenure == compareToExistingUsers.tenure){
                        if(meetingLoad == compareToExistingUsers.meetingLoad){
                            if(allInquiryLoad == compareToExistingUsers.allInquiryLoad){
                                return 0;
                            }else if(allInquiryLoad > compareToExistingUsers.allInquiryLoad){
                                return 1;   
                            }else{
                                return -1;
                            }       
                        }else if(meetingLoad < compareToExistingUsers.meetingLoad){
                            return 1;   
                        }else{
                            return -1;
                        }       
                    }else if(tenure < compareToExistingUsers.tenure){
                        return 1;   
                    }else{
                        return -1;
                    }   
                }else if(performanceScore < compareToExistingUsers.performanceScore){
                    return 1;   
                }else{
                    return -1;
                }       
            }else if(newInquiryLoad > compareToExistingUsers.newInquiryLoad){
                return 1;   
            }else{
                return -1;
            }
        }
    }
    
    //CH03.Start
    /*********************************************************************************************
    * @Description : Method to query the possible matches Inquiries                              *
    * @Params      : Set<String>,Set<String>                                                     *
    * @Return      : Map<String,Inquiry__c>                                                      *
    *********************************************************************************************/
    public Map<String,Inquiry__c> possibleMatchesOfInquiry(Set<String> possibleEmails,Set<String> possibleMobiles){
        Map<String,Inquiry__c> mapPossibleInquiries = new Map<String,Inquiry__c>();
        for(Inquiry__c possibleInquiry : [SELECT Id,Email__c,Mobile_Phone__c 
        								  FROM Inquiry__c 
        								  WHERE Email__c IN:possibleEmails OR 
        								  		Mobile_Phone__c IN:possibleMobiles 
        								  LIMIT : LIMITS.getLimitQueryRows()]){
            if(possibleInquiry.Email__c != null && !mapPossibleInquiries.containsKey(possibleInquiry.Email__c.toUpperCase()))
                mapPossibleInquiries.put(possibleInquiry.Email__c.toUpperCase(),possibleInquiry);
            if(possibleInquiry.Mobile_Phone__c != null && !mapPossibleInquiries.containsKey(possibleInquiry.Mobile_Phone__c))
                mapPossibleInquiries.put(possibleInquiry.Mobile_Phone__c,possibleInquiry);
        }
        return mapPossibleInquiries;
    } 
    //CH03.End    
}// End of class.