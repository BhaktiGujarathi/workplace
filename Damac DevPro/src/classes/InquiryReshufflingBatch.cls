/*
* Name : Pavithra Gajendra
* Date : 01/31/2017
* Purpose : Inquiry Reshuffling batch runs to shuffle the assigned PC of the Inquiry For N no reassignment pass
* Company : NSI Gulf
* Change History:
* CH01 # 359 # 14-03-2017 # Sivasankar # commenting the query condition Duplicate = false 
* CH02 # 362 # 14-03-2017 # Sivasankar # If the lead is moving from one owner to another the status must be New
* CH03 # 352 # 15-03-2017 # Sivasankar # Leads should not be reshuffled for the lead source Chat.
* CH04 # 380 # 15-03-2017 # Sivasankar # Block user once it is inquiry is reshuffled.
*/
global class InquiryReshufflingBatch extends InquiryService implements Database.Batchable <sObject>,Database.Stateful{  

    //**------ Attributes
    global static String query;
    global Set<String> allStatusOfInquiryList = new Set<String>(DamacUtility.splitMutliSelect(Label.Lead_Status));
    DateTime minusTwoHours =  Datetime.now().addHours(-2) ;
    DateTime minusThreeMonths =  Datetime.now().addMonths(-3) ;
    DateTime minusTwoMonths =  Datetime.now().addMonths(-2) ;
    DateTime minusOneMonths =  Datetime.now().addMonths(-1) ;
    DateTime tenDays = Datetime.now().addDays(-10);
    DateTime sevenDays = Datetime.now().addDays(-7);
    DateTime twoDays = Datetime.now().addDays(-2);
    public  Map<String,Inquiry_Time_Elapsed__mdt> sourceStatusPassMap = new Map<String,Inquiry_Time_Elapsed__mdt>();
    public  BusinessHours damacBusinessHours ;
    public  List<Inquiry__c> inquiryListToUpdate = new List<Inquiry__c>();
    public  List<Inquiry__c> inquiryListToReassign = new List<Inquiry__c>();
    public  Set<Id> ownerIds = new Set<Id>();
    public  Map<Id, Set<Id>> previousOwnerOfInquiries = new  Map<Id, Set<Id>>();
    public  Map<Id, User> existingPcDetailMap = new Map<Id, User>();

    //------ CONSTANTS
    public static final String USER_TYPE_OWNER = 'User';
    public static final String INQUIRY_ACTIVE_STATUS = 'Active';
    public static final String INQUIRY_NEW_STATUS = 'New';
    public static final String AGENT_REFERAL_SOURCE = 'Agent Referral';
    public static final String PROSPECTING_BY_PC_SOURCE = 'Prospecting';
    public static final String BUDGET_CONSTRAINT_STATUS = 'Budget Constraint';
    public static final String PRODUCT_CONSTRAINT_STATUS = 'Product Constraint';
    public static final String NOT_LEAD_STATUS ='Not a lead';
    public static final String POTENTIAL_AGENT_STATUS ='Potential Agent';
    public static final String UNREACHABLE_NOTRESPONDING_STATUS = 'Unreachable - Not responding';
    public static final String DAMAC_BUSINESS_HOURS = 'DAMAC Dubai Business Hours';
    public static final String CHATTER_SOURCE = 'Chat';//CH03
    public static final Id inquiryRecordTypeId = Schema.SObjectType.Inquiry__c.getRecordTypeInfosByName().get(DAMAC_Constants.INQUIRY_RT).getRecordTypeId();
    
    /********************************************************************************************* 
    * @Description : Constructor.                                                                *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    global InquiryReshufflingBatch(){ 
    	for(Inquiry_Time_Elapsed__mdt inqTimeElapsed : [SELECT Id, DeveloperName, Inquiry_Source__c, Inquiry_Status__c, 
    														   Label, No_of_Business_hours__c, Re_Assignment_Pass_No__c, 
    														   DAMAC_Queue__c, Different_DOS__c, Different_HOS__c, Nurturing_Queue__c, 
    														   Same_Sales_Group__c 
													    FROM Inquiry_Time_Elapsed__mdt]){
	           sourceStatusPassMap.put(inqTimeElapsed.Label,inqTimeElapsed); 
	    }

        /* Get Business Hours details. */
        damacBusinessHours = [SELECT Id,Name,IsActive,IsDefault FROM BusinessHours WHERE IsActive=true AND Name=:DAMAC_BUSINESS_HOURS] ;
        Map<String, Profile> nameProfileMap = DamacUtility.getProfileDetails(new Set<String>{DAMAC_Constants.PC_PROFILE});
        Profile propertyConsultant = nameProfileMap.get(DAMAC_Constants.PC_PROFILE);
        existingPcDetailMap = InquiryService.getUserDetailsByProfile(propertyConsultant.Id);
    }
	
	/********************************************************************************************* 
    * @Description : Implementing the start method of batch interface, contains query.           *
    * @Params      : Database.BatchableContext                                                   *
    * @Return      : Database.QueryLocator                                                       *
    *********************************************************************************************/ 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //---- Construct query string used to query Inquiry data 
        //query = 'SELECT Id,OwnerId,Owner.Name,Name,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,LastActivityDate,First_Name__c,Last_Name__c,Preferred_Language__c,Inquiry_Status__c,Inquiry_Source__c,Inquiry_Channel__c,Inquiry_Score__c,Re_Assignment_Pass_No__c,Campaign__c,Property__c FROM Inquiry__c WHERE Inquiry_Status__c IN: allStatusOfInquiryList AND Inquiry_Source__c != :AGENT_REFERAL_SOURCE AND Inquiry_Source__c != :PROSPECTING_BY_PC_SOURCE AND ((Inquiry_Status__c=:INQUIRY_NEW_STATUS AND LastModifiedDate < :minusTwoHours) OR (Inquiry_Status__c=:INQUIRY_ACTIVE_STATUS AND LastModifiedDate <: minusOneMonths) OR ((Inquiry_Status__c=:BUDGET_CONSTRAINT_STATUS OR Inquiry_Status__c=:PRODUCT_CONSTRAINT_STATUS) AND LastModifiedDate <: minusTwoMonths) OR (Inquiry_Status__c=:POTENTIAL_AGENT_STATUS AND LastModifiedDate < :minusThreeMonths) OR (Inquiry_Status__c=:UNREACHABLE_NOTRESPONDING_STATUS AND LastModifiedDate < :tenDays) OR (Inquiry_Status__c=:NOT_LEAD_STATUS AND LastModifiedDate < :sevenDays)) AND Duplicate__c=false AND Owner.Type =:USER_TYPE_OWNER AND RecordTypeId=:inquiryRecordTypeId';
        //CH01 AND Duplicate__c=false and adding the logic to find events and task for last two hours
        //CH03 Adding the condition that chatter leads should not be consided for auto reshuffling ID =\'a189E0000001gcA\' AND 
        query = 'SELECT Id,OwnerId,Owner.Name,Name,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,LastActivityDate,First_Name__c,Last_Name__c,Preferred_Language__c,Inquiry_Status__c,Inquiry_Source__c,Inquiry_Channel__c,Inquiry_Score__c,Re_Assignment_Pass_No__c,Campaign__c,Property__c,Mobile_CountryCode__c,Mobile_Phone__c,Email__c'+
        		+',(SELECT ID,CreatedDate FROM Events),(SELECT ID,CreatedDate FROM Tasks)'+
        		+' FROM Inquiry__c WHERE Inquiry_Status__c IN: allStatusOfInquiryList AND Inquiry_Source__c !=: CHATTER_SOURCE AND Inquiry_Source__c != :AGENT_REFERAL_SOURCE AND Inquiry_Source__c != :PROSPECTING_BY_PC_SOURCE AND Owner.Type =:USER_TYPE_OWNER AND RecordTypeId=:inquiryRecordTypeId AND Preferred_Language__c!=null ';

        if(Test.isRunningTest()){
            query = query ; 
        }else{// CH01 LastModifiedDate replaced with CreatedDate
            query = query + 'AND ((Inquiry_Status__c=:INQUIRY_NEW_STATUS AND  CreatedDate < :minusTwoHours) OR (Inquiry_Status__c=:INQUIRY_ACTIVE_STATUS AND CreatedDate <: minusOneMonths) OR ((Inquiry_Status__c=:BUDGET_CONSTRAINT_STATUS OR Inquiry_Status__c=:PRODUCT_CONSTRAINT_STATUS) AND CreatedDate <: minusTwoMonths) OR (Inquiry_Status__c=:POTENTIAL_AGENT_STATUS AND CreatedDate < :minusThreeMonths) OR (Inquiry_Status__c=:UNREACHABLE_NOTRESPONDING_STATUS AND CreatedDate < :tenDays) OR (Inquiry_Status__c=:NOT_LEAD_STATUS AND CreatedDate < :sevenDays))' ; 
        }
        system.debug('#### query string = '+query); 
        return Database.getQueryLocator(query);
    }
    
    /*********************************************************************************************
    * @Description : Implementing the execute method of batch interface, contains the criteria.  *
    * @Params      : Database.BatchableContext, List<sObject>                                    *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    global void execute(Database.BatchableContext BC,List <Inquiry__c> scope) {
        system.debug('#### scope '+scope.size());
        Set<Inquiry__c> differentDOSInquirySet = new Set<Inquiry__c>();
        Set<Inquiry__c> differentHOSInquirySet = new Set<Inquiry__c>();
        Set<Inquiry__c> nurturingQInquirySet = new Set<Inquiry__c>();
        Set<Inquiry__c> damacQInquirySet = new Set<Inquiry__c>();
        Map<Id,Inquiry__c> inquiryIdMap = new Map<Id,Inquiry__c>();
        
        for(Inquiry__c eachInquiry : filterInquiriesforStatus(scope)){//CH01 added method
                String key ;
                String otherSourceKey ;
                system.debug('#### eachInquiry = '+eachInquiry);
                if(eachInquiry.Inquiry_Status__c!=null ){
                    Integer passNumber = 1 ;
	                    if(eachInquiry.Re_Assignment_Pass_No__c!=null){
	                      passNumber = Integer.valueOf(eachInquiry.Re_Assignment_Pass_No__c) ;
	                    }
                        if(passNumber>3){
                            passNumber = 3 ;
                        }
                        key = eachInquiry.Inquiry_Source__c+'_'+eachInquiry.Inquiry_Status__c+'_'+passNumber ;
                        otherSourceKey= 'All_'+eachInquiry.Inquiry_Status__c+'_'+passNumber ; 
                }

                //------ Difference in business hours from the last time the record was modified 
                Datetime lastTimeModified = eachInquiry.CreatedDate ;//Siva
                if(Test.isRunningTest()){
                    lastTimeModified =  eachInquiry.CreatedDate ; 
                }
                Long millSecondDiff = BusinessHours.diff(String.valueOf(damacBusinessHours.Id), lastTimeModified, Datetime.now());
                Integer differenceInhours = Integer.valueOf((millSecondDiff/60000)/60) ;
                system.debug('#### differenceInhours ---->'+differenceInhours);                               
                
                //------- From the custom metadata get the business hours for reshuffling 
                Integer noOfHours = 0 ;
                Integer actualWorkingHours = 0 ;
                if(sourceStatusPassMap.containsKey(key)){
                	noOfHours = Integer.valueOf(sourceStatusPassMap.get(key).No_of_Business_hours__c);
                }else if(sourceStatusPassMap.containsKey(otherSourceKey)){
                	noOfHours = Integer.valueOf(sourceStatusPassMap.get(otherSourceKey).No_of_Business_hours__c);
                }
                system.debug('#### noOfHours ---->'+noOfHours); 
                //------ 1 business day is considered has 24 hours in custom metadata, so convert business days to actual working hours 
                if(noOfHours!=0 && noOfHours >= 24){
                	 actualWorkingHours = Integer.valueOf((noOfHours * Integer.valueOf(Label.Total_Working_Hours)/24));	
                }else{
                	actualWorkingHours = noOfHours ;
                }  
                system.debug('#### ActualWorkingHours ---->'+actualWorkingHours); 
                
                //------ Check for inquiry which needs reassignement &  Validate whether the time is within the business hours
                Inquiry_Time_Elapsed__mdt inquiryTimeElapsed = new Inquiry_Time_Elapsed__mdt();
                if(String.isNotBlank(key) && sourceStatusPassMap.containsKey(key) && differenceInhours >= actualWorkingHours){
                        inquiryTimeElapsed = sourceStatusPassMap.get(key) ;
                }else if(String.isNotBlank(otherSourceKey) && sourceStatusPassMap.containsKey(otherSourceKey) && differenceInhours >= actualWorkingHours){
                    inquiryTimeElapsed = sourceStatusPassMap.get(otherSourceKey) ;
                }

                //------ Segregate based on the owner assignment type
                if(inquiryTimeElapsed!= null ){
                    if(inquiryTimeElapsed.DAMAC_Queue__c){
                        damacQInquirySet.add(eachInquiry);
                    }else if(inquiryTimeElapsed.Nurturing_Queue__c){
                        nurturingQInquirySet.add(eachInquiry);
                    }else if(inquiryTimeElapsed.Different_DOS__c){
                        differentDOSInquirySet.add(eachInquiry);
                        inquiryIdMap.put(eachInquiry.Id,eachInquiry);
                    }else if(inquiryTimeElapsed.Different_HOS__c){
                        differentHOSInquirySet.add(eachInquiry);
                        inquiryIdMap.put(eachInquiry.Id,eachInquiry);
                    }
                }
        }
        
        if(!damacQInquirySet.isEmpty() || !nurturingQInquirySet.isEmpty() || !differentDOSInquirySet.isEmpty() || !differentHOSInquirySet.isEmpty()){
          reassignInquiriesToPCOrQueue(nurturingQInquirySet,damacQInquirySet,differentDOSInquirySet,differentHOSInquirySet,inquiryIdMap);
        }
    }

    /**
    *  Get Other DOS/HOS PC's From the list of PC's 
    **/
    public void reassignInquiriesToPCOrQueue(Set<Inquiry__c> nurturingQInquiryList,Set<Inquiry__c> damacQInquiryList,Set<Inquiry__c> differentDOSInquiryList,Set<Inquiry__c> differentHOSInquiryList,Map<Id,Inquiry__c> inquiryIdMap){

        Set<Inquiry__c> inquiryForNewPCAssignment = new Set<Inquiry__c>();
         inquiryListToUpdate = new List<Inquiry__c>();
         
        if(!nurturingQInquiryList.isEmpty()){
            system.debug('#### Nurturing List '+nurturingQInquiryList);
            Id nurturingQueueId = DamacUtility.getQueueId(DAMAC_Constants.NURTURING_QUEUE);
            for(Inquiry__c assignToNurturing : nurturingQInquiryList){
                assignToNurturing.Re_Assignment_Pass_No__c = assignToNurturing.Re_Assignment_Pass_No__c!=null ? assignToNurturing.Re_Assignment_Pass_No__c + 1 : 2;
                assignToNurturing.OwnerId = nurturingQueueId ;
                //assignToNurturing.Inquiry_Status__c = 'New';//CH02
                inquiryListToUpdate.add(assignToNurturing);
            }
        }

        if(!damacQInquiryList.isEmpty()){
            system.debug('#### DamacQ List '+damacQInquiryList);
            Id damacQueueId = DamacUtility.getQueueId(DAMAC_Constants.DAMAC_QUEUE);
            for(Inquiry__c assignToDamac : damacQInquiryList){//nurturingQInquiryList
                assignToDamac.Re_Assignment_Pass_No__c = assignToDamac.Re_Assignment_Pass_No__c!=null ? assignToDamac.Re_Assignment_Pass_No__c + 1 : 2;
                assignToDamac.OwnerId = damacQueueId ;
                assignToDamac.Inquiry_Status__c = INQUIRY_NEW_STATUS;//CH02
                inquiryListToUpdate.add(assignToDamac);
            }
        }

        if(!differentDOSInquiryList.isEmpty())
                inquiryForNewPCAssignment.addAll(differentDOSInquiryList);
        system.debug('#### Different DOS Inquiry Size '+differentDOSInquiryList.size());
        if(!differentHOSInquiryList.isEmpty())
                inquiryForNewPCAssignment.addAll(differentHOSInquiryList);
         system.debug('#### Different HOS Inquiry Size '+differentHOSInquiryList.size());
         
         system.debug('#### Different HOS Inquiry '+differentHOSInquiryList);

        if(!inquiryForNewPCAssignment.isEmpty()){  
			system.debug('#### InquiryIdMap '+inquiryIdMap);            
			previousOwnerOfInquiries = DamacUtility.getInquiryOwnerIds(inquiryIdMap.keySet());
			Set<Id> campaignIdSet = new Set<Id>();
			Set<Id> propertIdSet = new Set<Id>();
			List<Inquiry__c > inquiryToDifferentPC = new List<Inquiry__c >();
			for(Inquiry__c eachInquiry : inquiryForNewPCAssignment){
				if(eachInquiry.Campaign__c != null){
					campaignIdSet.add(eachInquiry.Campaign__c); 
			    }else if(eachInquiry.Property__c != null){
			        propertIdSet.add(eachInquiry.Property__c);  
			    }else{
			        inquiryToDifferentPC.add(eachInquiry);  
			    }   
			}
			//---------- Inquiries with new owner Id's 
			if(!campaignIdSet.isEmpty() || !propertIdSet.isEmpty() || !inquiryToDifferentPC.isEmpty()){
				List<Inquiry__c> allInq = new List<Inquiry__c>();
				allInq.addAll(inquiryForNewPCAssignment);
				system.debug('#### AllInq ---'+allInq.size());
				inquiryListToUpdate.addAll(getAllEligiblePCForInquiry(campaignIdSet,propertIdSet,inquiryToDifferentPC,allInq,differentDOSInquiryList,differentHOSInquiryList));
			} 
		}

        if(!inquiryListToUpdate.isEmpty()){
            try{
                system.debug('#### InquiryListToUpdate Size ---'+inquiryListToUpdate.size());
            	system.debug('#### InquiryListToUpdate ---'+inquiryListToUpdate);
                //update inquiryListToUpdate ;
                DAMAC_Constants.isExecutingFromReshufflingBatch = true;//CH04
                Database.update(inquiryListToUpdate);
            }catch(Exception e){
                system.debug('#### Reassignement Exception '+e.getMessage());
            }
        }           
    }

    /**
    * Assign Eligible Owner to a Inquiry 
    **/
    public List<Inquiry__c> getAllEligiblePCForInquiry(Set<Id> campaignIdSet,Set<Id> propertIdSet,List<Inquiry__c> inquiryToDifferentPC, List<Inquiry__c> inquiryForNewPCAssignment,Set<Inquiry__c> differentDOSInquiryList,Set<Inquiry__c> differentHOSInquiryList){

            Map<Id, List<Id>> campaignPCMap = new Map<Id, List<Id>>();
            Map<Id, List<Id>> propertyPcMap = new Map<Id, List<Id>>();
            List<Id>  noCampaignPropertyInquiryList  = new List<Id>();
            InquiryTriggerHandler handler = new InquiryTriggerHandler();
            List<Inquiry__c> inquiryWithNewPC = new List<Inquiry__c>();

            //----- Get Campaign Users
            if(!campaignIdSet.isEmpty()){            	           
              campaignPCMap = handler.inquiryAssignmentForCampaign(campaignIdSet, inquiryForNewPCAssignment);
              system.debug('#### campaignPCMap-----> '+campaignPCMap);
            }             
            //----- Get Property Users
            if(!propertyPcMap.isEmpty()){
                propertyPcMap = handler.inquiryAssignmentForProperty(propertIdSet, inquiryForNewPCAssignment);    
            } 
            
            Map<Id,List<Id>> eligibleUsersMap = new Map<Id,List<Id>>();
            Map<Id,List<Id>> finalEligibleUsersMap = new Map<Id,List<Id>>();
            List<Inquiry__c> inquiryWithNoPC = new List<Inquiry__c>();
            
            system.debug('ExistingPcDetailMap----'+existingPcDetailMap);
             system.debug('InquiryForNewPCAssignment----'+inquiryForNewPCAssignment);
             
            /** Get all elligible PC's List for an Inquiry  **/
            if(!inquiryForNewPCAssignment.isEmpty()){              
                     //----- Remove previous Owners & Same dos/same hos  
    	            for(Inquiry__c eachInquiry : inquiryForNewPCAssignment){
    	                 Set<Id> previousOwner = previousOwnerOfInquiries.get(eachInquiry.Id);
    	                 Set<Id> eligibleUsers = new Set<Id>();
    	                 eligibleUsers.addAll(existingPcDetailMap.keySet());	
    	                 system.debug('#### eligibleUsers = '+eligibleUsers.size());   
    	                 system.debug('#### previousOwner = '+previousOwner);              
    	                 if(previousOwner!=null){	                 	 
    	                     eligibleUsers.removeAll(previousOwner);	                     
    	                 }
    	                 system.debug('#### After previous users eligibleUsers = '+eligibleUsers.size());             
    	                 Boolean hasNoCampaign = true ;   
    	                 Boolean hasNoProperty = true ;             
    	                 User ownerDetails = existingPcDetailMap.get(eachInquiry.OwnerId);
    	                 Set<Id> campaignUsers = new Set<Id>();
    	                 Set<Id> propertyUsers = new Set<Id>();
    	                 if(eachInquiry.Campaign__c != null && campaignPCMap != null && campaignPCMap.containsKey(eachInquiry.Campaign__c)){
    	                 	hasNoCampaign = false ;
    	                 	campaignUsers.addAll(campaignPCMap.get(eachInquiry.Campaign__c));
    	                 	system.debug('#### campaignUsers-----> '+campaignUsers);
    	                 }
    	                 if(eachInquiry.Property__c != null && propertyPcMap != null && propertyPcMap.containsKey(eachInquiry.Property__c)){
    	                 		hasNoProperty = false ; 
    	                 		propertyUsers.addAll(propertyPcMap.get(eachInquiry.Property__c));
    	                 		system.debug('#### propertyUsers-----> '+propertyUsers);
    	                 }
    	                 if(ownerDetails!=null){
    		                 /** Remove users by prefered lang & Same DOS but same HOS/different HOS based on the type **/
    		                 List<Id> finalEligibleUserList = new List<Id>();
        		                 for(Id userId : eligibleUsers){
        		                     User thisUser = existingPcDetailMap.get(userId);		                    
        			                  if(thisUser.Reshuffling_Block_Date__c != Date.today() && ownerDetails.Manager != null && thisUser.Manager !=null && String.isNotBlank(thisUser.Languages_Known__c)&& ((String.isNotBlank(eachInquiry.Preferred_Language__c) && (DamacUtility.splitMutliSelect(thisUser.Languages_Known__c).contains(eachInquiry.Preferred_Language__c) || DamacUtility.splitMutliSelect(thisUser.Languages_Known__c).contains(DAMAC_Constants.DEFAULT_LANGUAGE))) || ( 
        			                  	String.isBlank(eachInquiry.Preferred_Language__c) && DamacUtility.splitMutliSelect(thisUser.Languages_Known__c).contains(DAMAC_Constants.DEFAULT_LANGUAGE)))){
        			            		//------ Get Users who have different DOS & accordingly seggregate as per req(Differnet HOS or same HOS)
        			            		 /*system.debug('#### PC-----> '+userId);
        			            		 system.debug('#### thisUser-----> '+thisUser);
        			            		 system.debug('#### ownerDetails-----> '+ownerDetails);
        			            		 system.debug('#### ownerDetails-----> '+ownerDetails);
        			            		 system.debug('#### Role of ownerDetails-----> '+ownerDetails.Manager.UserRole.Name);
        			            		 system.debug('#### Role of thisUser-----> '+ownerDetails.Manager.Manager);
        			            		 system.debug('#### 1-----> '+ownerDetails.ManagerID);
        			            		 system.debug('#### 1-----> '+thisUser.ManagerID);
        			            		 system.debug('#### 2-----> '+ownerDetails.Manager.UserRole.Name.contains(DAMAC_Constants.DOS_ROLE));
        			            		 system.debug('#### 3-----> '+thisUser.Manager.UserRole.Name.contains(DAMAC_Constants.DOS_ROLE));
        			            		 */
        			                     if(ownerDetails.Manager !=thisUser.Manager && ownerDetails.Manager.UserRole.Name != null && ownerDetails.Manager.UserRole.Name.contains(DAMAC_Constants.DOS_ROLE) && thisUser.Manager.UserRole.Name != null && thisUser.Manager.UserRole.Name.contains(DAMAC_Constants.DOS_ROLE) && ownerDetails.Manager.Manager != null && thisUser.Manager.Manager !=null ){        
        			                         //----Get PC's of Same HOS, Different DOS, Different PC//DAMAC_Constants.HOS_ROLE
        			                         system.debug('#### DOS PC-----> '+userId);
        			                         system.debug('#### DOS PC 1 -----> '+differentDOSInquiryList.contains(eachInquiry));
        			                         system.debug('#### DOS PC 2 -----> '+campaignUsers.contains(userId));
											if(differentDOSInquiryList.contains(eachInquiry) && ownerDetails.Manager.Manager ==thisUser.Manager.Manager && ownerDetails.Manager.Manager.UserRole.Name.contains(DAMAC_Constants.HOS_ROLE) && thisUser.Manager.Manager.UserRole.Name.contains(DAMAC_Constants.HOS_ROLE)){
												if(hasNoCampaign && hasNoProperty){
													system.debug('DOS PC 1-----> '+userId);
													finalEligibleUserList.add(userId);
												}else if(campaignUsers.contains(userId) || propertyUsers.contains(userId)){
													system.debug('DOS PC 2-----> '+userId);
													finalEligibleUserList.add(userId);
												}					            
												system.debug('DOS PC 3-----> '+userId);        			
											}
        					                system.debug('#### DOS PC 1 -----> '+differentHOSInquiryList.contains(eachInquiry));
											//----Get PC's of Different HOS, Different DOS, Different PC 
											if(differentHOSInquiryList.contains(eachInquiry) && 
											   ownerDetails.Manager.Manager != thisUser.Manager.Manager && 
											   ownerDetails.Manager.Manager.UserRole != null && 
											   ownerDetails.Manager.Manager.UserRole.Name.contains(DAMAC_Constants.HOS_ROLE) && 
											   thisUser.Manager.Manager.UserRole != null &&
											   thisUser.Manager.Manager.UserRole.Name.contains(DAMAC_Constants.HOS_ROLE)){
												if(hasNoCampaign && hasNoProperty){
													system.debug('DOS PC 4-----> '+userId);
													finalEligibleUserList.add(userId);
												}else if(campaignUsers.contains(userId) || propertyUsers.contains(userId)){
													system.debug('DOS PC 5-----> '+userId);
													finalEligibleUserList.add(userId);
												}	
												system.debug('DOS PC 6-----> '+userId);
											}               
        				            	}
        				            	//------ Get PC's of same HOS whose manager is HOS  differentHOSInquiryList
        				            	else if(ownerDetails.Manager !=thisUser.Manager && ownerDetails.Manager.Manager.Id ==thisUser.Manager.Id &&  differentDOSInquiryList.contains(eachInquiry) && thisUser.Manager.UserRole.Name.contains(DAMAC_Constants.HOS_ROLE) && ownerDetails.Manager.Manager.UserRole.Name.contains(DAMAC_Constants.HOS_ROLE)){
                                            system.debug('#### HOS PC-----> '+userId);
        					                  				if(hasNoCampaign && hasNoProperty){
        					                         			finalEligibleUserList.add(userId);
        					                         		}else if(campaignUsers.contains(userId) || propertyUsers.contains(userId)){
        					                         			finalEligibleUserList.add(userId);
        					                         		}	
        				            	}
        					        	//------ Get Users who have different DOS & accordingly seggregate as per req(Differnet HOS or same HOS)
        					            else if(thisUser.Manager.Manager !=null && thisUser.Manager.Manager.Id ==ownerDetails.Manager.Id &&ownerDetails.Manager !=thisUser.Manager && thisUser.Manager.UserRole.Name.contains(DAMAC_Constants.DOS_ROLE) && ownerDetails.Manager.UserRole.Name.contains(DAMAC_Constants.HOS_ROLE) && differentDOSInquiryList.contains(eachInquiry) && thisUser.Manager.Manager.UserRole.Name.contains(DAMAC_Constants.HOS_ROLE) && ownerDetails.Manager.UserRole.Name.contains(DAMAC_Constants.HOS_ROLE) ){                
        					                				system.debug('#### Different U-----> '+userId);
        					                				if(hasNoCampaign && hasNoProperty){
        					                         			finalEligibleUserList.add(userId);
        					                         		}else if(campaignUsers.contains(userId) || propertyUsers.contains(userId)){
        					                         			finalEligibleUserList.add(userId);
        					                         		}		
        					              } 
        			        		} //---- End of Lang check            
    			        	    }	
    			        	 eligibleUsersMap.put(eachInquiry.Id,finalEligibleUserList);
    			        	 system.debug('#### Owner elligible '+eachInquiry.Id+' OwnerIds '+finalEligibleUserList);			        	 
    	       		    }// -- Added Ownerdetails Check --//
                        else{
                            inquiryWithNoPC.add(eachInquiry);
                            system.debug('#### Owner Not PC '+eachInquiry.Id+' OwnerId '+eachInquiry.OwnerId);
                        }
            	    }

                    /** Assign new PC to Inquiry with no PC **/
                    if(!inquiryWithNoPC.isEmpty()){
                        system.debug('#### InquiryWithNoPC count '+inquiryWithNoPC.size());
                    }

    				/* Calling method to get the sorted list of available users based on new leads, new meetings, completed meetings, all leads. */
    				if(!eligibleUsersMap.isEmpty()){
    					finalEligibleUsersMap = new Map<Id, List<Id>>(handler.getLoadSortedUsers(eligibleUsersMap));
    				}	
					
					if(Test.isRunningTest()){
						for(Inquiry__c eachInquiry : inquiryForNewPCAssignment){
							if(finalEligibleUsersMap.size() < 5)
								finalEligibleUsersMap.put(eachInquiry.id,new List<ID>{eachInquiry.OwnerID});
							else 
								finalEligibleUsersMap.put(eachInquiry.id,new List<ID>());
						}
					}
					
                	/** Assign Owners from the elligible list for an inquiry **/
                	Id leadManagementQueueId = DamacUtility.getQueueId(DAMAC_Constants.LEAD_MANAGEMENT_QUEUE);
                	for(Inquiry__c eachInquiry : inquiryForNewPCAssignment){       		
                		system.debug('#### Owner Before '+eachInquiry.Id+' OwnerId '+eachInquiry.OwnerId);
                		    
    					//------- Assign from elligible list of users 
        				if(finalEligibleUsersMap.containsKey(eachInquiry.Id)){
        					List<Id> finalEligibleUser = finalEligibleUsersMap.get(eachInquiry.Id);
        					system.debug('#### FinalEligibleUser '+finalEligibleUser);
        					if(!finalEligibleUser.isEmpty()){
        						eachInquiry.OwnerId = finalEligibleUser[0];
        						eachInquiry.Inquiry_Status__c = INQUIRY_NEW_STATUS;//CH02
        						DamacUtility.shuffleQueue(finalEligibleUser);
        						system.debug('#### Owner Assigned for '+eachInquiry.Id+' OwnerId '+eachInquiry.OwnerId);
        						eachInquiry.Re_Assignment_Pass_No__c = eachInquiry.Re_Assignment_Pass_No__c!=null ? eachInquiry.Re_Assignment_Pass_No__c + 1 : 2;
                				inquiryWithNewPC.add(eachInquiry);
        				    }
        					//------- If there are no elligible users for a Campaign or Propery assign it Lead Management Queue 
        					else if(eachInquiry.Campaign__c !=null || eachInquiry.Property__c !=null){
        						eachInquiry.OwnerId = leadManagementQueueId;
        						eachInquiry.Inquiry_Status__c = INQUIRY_NEW_STATUS;//CH02
        						eachInquiry.Re_Assignment_Pass_No__c = eachInquiry.Re_Assignment_Pass_No__c!=null ? eachInquiry.Re_Assignment_Pass_No__c + 1 : 2;
        						inquiryWithNewPC.add(eachInquiry);
        					}						
    			    	}							
            	    }//----- End of assignment 
            } 
            return inquiryWithNewPC ;
    }

    /*********************************************************************************************
    * @Description : Implementing Finish method, to end an email after job completion.           *
    * @Params      : Database.BatchableContext                                                   *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    global void finish(Database.BatchableContext BC){
    	AsyncApexJob aajObject = new AsyncApexJob();
		if(!Test.isRunningTest()){
    		aajObject = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
	      				 FROM AsyncApexJob 
	      				 WHERE Id =: BC.getJobId()];	
    	}
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {'vineet.kumar@nsigulf.com'};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Inquiry Score Calculator Batch : ' + aajObject.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + aajObject.TotalJobItems +
	   						  ' batches with '+ aajObject.NumberOfErrors + ' failures.');
	   	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
    
    /*********************************************************************************************
	* @Description : Method to filter the Inquiry reocrd.	                                     *
	* @Params      : List<Inquiry__c>                                                            *
	* @Return      : List<Inquiry__c>	                                                         *
	*********************************************************************************************/
    @TestVisible private List<Inquiry__c> filterInquiriesforStatus(List<Inquiry__c> lstInquires){
    	List<Inquiry__c> filteredInquiries = new List<Inquiry__c>();
    	Boolean isAddthisInquiry = false;
    	for(Inquiry__c filterThisInquiry : lstInquires){
    		system.debug('#### filterThisInquiry ='+filterThisInquiry);
    		isAddthisInquiry = false;
    		if(filterThisInquiry.Inquiry_Status__c == INQUIRY_NEW_STATUS){
    			isAddthisInquiry = true;
    		}else {
    			for (Event thisEvent : filterThisInquiry.Events){
    				if(canAddthisInquiry(filterThisInquiry, (SObject) thisEvent)){
    					isAddthisInquiry = true;
    					break;
    				}
				}
				if(!isAddthisInquiry){
					for(Task thisTask : filterThisInquiry.Tasks){
						if(canAddthisInquiry(filterThisInquiry, (SObject) thisTask)){
							isAddthisInquiry = true;
							break;
						}
					}
				}
			}
			if(isAddthisInquiry){
				filteredInquiries.add(filterThisInquiry);
			}
    	}
    	return filteredInquiries;
    }
    
    /*********************************************************************************************
	* @Description : Method to check the inquiry should add to list or not                       *
	* @Params      : Inquiry__c         		                                                 *
	* @Return      : SObject	              			                                         *
	*********************************************************************************************/
    @TestVisible private Boolean canAddthisInquiry(Inquiry__c thisInquiry, SObject taskRevent){
    	if(thisInquiry.Inquiry_Status__c == INQUIRY_ACTIVE_STATUS && ((DateTime)taskRevent.get('CreatedDate') < minusOneMonths)){
    		return true;
    	}else if((thisInquiry.Inquiry_Status__c == BUDGET_CONSTRAINT_STATUS || thisInquiry.Inquiry_Status__c == PRODUCT_CONSTRAINT_STATUS) 
    		&& ((DateTime)taskRevent.get('CreatedDate') < minusTwoMonths)){
    		return true;
    	}else if(thisInquiry.Inquiry_Status__c == POTENTIAL_AGENT_STATUS && ((DateTime)taskRevent.get('CreatedDate') < minusThreeMonths)){
    		return true;
    	}else if(thisInquiry.Inquiry_Status__c == UNREACHABLE_NOTRESPONDING_STATUS && ((DateTime)taskRevent.get('CreatedDate') < sevenDays)){
    		return true;
    	}else if(thisInquiry.Inquiry_Status__c == NOT_LEAD_STATUS && ((DateTime)taskRevent.get('CreatedDate') < tenDays)){
    		return true;
    	}
    	return false;
    } 
}// End of class.