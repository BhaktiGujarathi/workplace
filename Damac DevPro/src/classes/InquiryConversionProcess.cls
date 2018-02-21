/*
Description:Class to Convert Inquiry to Person/Business Account and Person/Business Contact and Copy all the Actvities of an Enquiry to rescprctive Account created
Developed by PwC ME
*/
public with sharing class InquiryConversionProcess{
    
    public static void convertInquiry(Set<id> InquiryIds){ 
    	//Savepoint sp = Database.SetSavepoint();
    	String queryString;
    	String businessContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('DAMAC Contact').getRecordTypeId();
    	String businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
    	String personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    	List<account> newAccounts = new List<account>(); 
    	List<Buyer__c> updateBuyersList = new List<Buyer__c>();  
    	Set<Inquiry__c> SetConsToCreate = new Set<Inquiry__c>(); 
    	Set<Id> ownerIdsSet = new Set<Id>();
    	Map<String,Inquiry_Conversion_Mapping__c> custSettMapping = new Map<String,Inquiry_Conversion_Mapping__c>();
        try{
            queryString = 'SELECT Name, Company__c, Inquiry_Status__c, Associated_Customer__c';
            //Query All other Fields to Map from Inquiry to Account and Activity
            custSettMapping = Inquiry_Conversion_Mapping__c.getall();
            system.debug('MAPPING>>>>'+custSettMapping);
            // Form Query String
            for(String s:custSettMapping.keySet()){
                queryString += (queryString==''?'':',')+s;
            }
            queryString += ' ,(SELECT Id FROM Buyers__r) FROM Inquiry__c where id=: InquiryIds';
            system.debug('FINAL STRING'+queryString);
            List<Inquiry__c> Inquiries = Database.query(queryString);
            system.debug('Inquiries>>>'+Inquiries);
            for(Inquiry__c i:Inquiries){   
            	ownerIdsSet.add(i.ownerId);
            	if(String.isBlank(i.Associated_Customer__c)){ 
	                Account newAccount = new Account(); 
	                for(String s:custSettMapping.keySet()){ 
	                	if(String.isBlank(i.Organisation_Name__c)){                
		                    String accFld = custSettMapping.get(s).Person_Account_Field_Name__c;	                    
		                    if(String.isNotBlank(accFld)){
		                    	system.debug('ACC FLD---'+AccFld+'>>>>'+i.get(s));
		                    	newAccount.put(accFld,i.get(s));  
		                    }
		                    newAccount.put('RecordtypeId', personAccountRecordTypeId);
	                	}else{
	                		String accFld = custSettMapping.get(s).Business_Account_Field_Name__c;	                    
		                    if(String.isNotBlank(accFld)){
		                    	system.debug('ACC FLD---'+AccFld+'>>>>'+i.get(s));
		                    	newAccount.put(accFld,i.get(s));
		                    }
		                    newAccount.put('RecordtypeId',businessAccountRecordTypeId);
		                    SetConsToCreate.add(i);
	                	}
	                }
	                newAccounts.add(newAccount);
            	}
        	}
        	if(!newAccounts.isEmpty()){
        		insert newAccounts; 	
        		/* Calling method to create account team. */ 
        		createAccountTeam(newAccounts, ownerIdsSet);
        	}
        	
	        system.debug('newAccount ID-->>'+newAccounts);
	        Map<id,id> mapInqAccUpdate = new Map<id,id>();
	        Set<id> accountids = new Set<id>();
	        for(Account a:newAccounts){ 
	            accountids.add(a.id);
	            mapInqAccUpdate.put(a.Inquiry__c,a.id);
	        }
	        
	        // Create Contacts for Business Accounts
	        if(SetConsToCreate.size() > 0){
	        	List<contact> newContacts = new List<contact>();	        
		        for(Inquiry__c inq:SetConsToCreate){
		        	contact newCon = new contact();
		        	newCon.recordTypeId = businessContactRecordTypeId;
		        	for(String s:custSettMapping.keySet()){ 
	        			String conFld = custSettMapping.get(s).Business_contact_Field_Name__c;
	        			if(conFld != null){
		        			newCon.put(conFld,inq.get(s));
		        			newCon.put('AccountId',mapInqAccUpdate.get(inq.id));  
	        			}      			
		        	}
		        	newContacts.add(newcon);
		        }
		        insert newContacts;
	        }
	        
	        /* Update inquiry record. */
	        for(Inquiry__c i:Inquiries){
	        	i.Associated_Customer__c = mapInqAccUpdate.get(i.id);
	        	i.Inquiry_Status__c = 'Closed Won';
	        	i.By_Pass_Validation__c = true;
	        	for(Buyer__c thisBuyer : i.Buyers__r){
	        		Buyer__c buyerRecord = new Buyer__c();
		        	buyerRecord.Id = thisBuyer.Id;
		        	buyerRecord.Account__c = mapInqAccUpdate.get(i.id);
		        	updateBuyersList.add(buyerRecord);	
	        	}
	        }
	        update Inquiries;    
	        /* Updating buyer's account info. */    
	        if(!updateBuyersList.isEmpty()){
	        	update updateBuyersList;	
	        }
	        //Clone activities
	        cloneActivities(accountids,InquiryIds);        
        }catch(exception ex){
        	 system.debug('Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage());  
        }
    }// End of Method
    
    /*********************************************************************************************
    * @Description : Method to create account teams.                                             *
    * @Params      : List<Account>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    private static void createAccountTeam(List<Account> convertedAccountList, Set<Id> ownerIdsSet){
        List<AccountTeamMember> insertAccountTeamRecords = new List<AccountTeamMember>();
        /* Calling method to get team members map. */
        Map<Id, Set<Id>> userTeamMembersMap = getTeamMembers(ownerIdsSet);
        for(Account thisAccount : convertedAccountList){
        	for(Id thisTeamMember : userTeamMembersMap.get(thisAccount.OwnerId)){
        		AccountTeamMember atRecord = new AccountTeamMember();
	            atRecord.AccountId = thisAccount.Id;
	            atRecord.AccountAccessLevel = 'Read';
	            atRecord.ContactAccessLevel = 'Read';
	            atRecord.CaseAccessLevel = 'None';
	            atRecord.OpportunityAccessLevel = 'None';
	            atRecord.UserId = thisTeamMember;
	            insertAccountTeamRecords.add(atRecord); 	
        	}
        }   
        if(!insertAccountTeamRecords.isEmpty()){
            insert insertAccountTeamRecords; 
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to get team members.                                                 *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<Id, Set<Id>>                                                            *
    *********************************************************************************************/
    private static Map<Id, Set<Id>> getTeamMembers(Set<Id> ownerIdsSet){
    	Map<Id, Set<Id>> userTeamMembersMap = new Map<Id, Set<Id>>();
    	for(User thisUser : [SELECT Id, ManagerId, Manager_Role__c, Manager.Manager_Role__c, 
    								Manager.ManagerId, Manager.Manager.ManagerId 
    						 FROM User 
    						 WHERE Id IN: ownerIdsSet]){
            Set<Id> userManagerIdsSet = new Set<Id>{thisUser.Id};
            if(thisUser.ManagerId != null && String.isNotBlank(thisUser.Manager_Role__c) && 
               (thisUser.Manager_Role__c.containsIgnoreCase('DOS') || 
               (thisUser.Manager.Manager_Role__c.containsIgnoreCase('HOS')))){
                userManagerIdsSet.add(thisUser.ManagerId);
            }
            if(thisUser.Manager.ManagerId != null && String.isNotBlank(thisUser.Manager.Manager_Role__c) && 
               thisUser.Manager.Manager_Role__c.containsIgnoreCase('HOS')){ 
            	userManagerIdsSet.add(thisUser.Manager.ManagerId);
            }
    		userTeamMembersMap.put(thisUser.Id, new Set<Id>(userManagerIdsSet));	 
    	}	
    	return userTeamMembersMap;
    }
       
    // Clone Activities 
    public static void cloneActivities(Set<id> parentIds,Set<id> InquiryIds){
        try{                        
            // Get all the Updatable Fields from Task
            // Store all Updatable Fields in the Map
            Map<String,String> updatableTaskFields = new Map<String,String>();
            Map<String, Schema.SObjectField> mapTaskFields = Schema.SObjectType.Task.fields.getMap();
            for(String fieldName : mapTaskFields.keySet()) {
                if(mapTaskFields.get(fieldName).getDescribe().isUpdateable()) {
                    updatableTaskFields.put(fieldName , fieldName);
                }
            }   
            system.debug('updatableTaskFields-->'+updatableTaskFields);
            String queryString;
            queryString = 'SELECT id';
            for(String s:updatableTaskFields.keySet()){
                queryString += (queryString==''?'':',')+s;
            }
            queryString += ' FROM Task where Whatid=:InquiryIds';
            system.debug('FINAL STRING'+queryString);
            List<task> tasksToClone = new List<task>();
            tasksToClone = Database.query(queryString);
            system.debug('tasksToClone--->'+tasksToClone);
            
            // Map to hold key as Inquiry Id and value as Account id
            Map<id,id> mapInqAcc = new Map<id,id>();
            List<account> accids = [select id,Inquiry__c from Account where id IN:parentIds];
            for(Account a:accids){
                mapInqAcc.put(a.Inquiry__c,a.id);
            }
            
            //Map to hold Inquiry and its respective Tasks
            Map<id,Set<task>> mapInqTasks = new Map<id,Set<task>>();
            for(task t:tasksToClone){
                if(mapInqTasks.containskey(t.whatid) ){
                    Set<task> tasks = mapInqTasks.get(t.whatid);
                    tasks.add(t);
                    mapInqTasks.put(t.whatid,tasks);
                }else{
                    mapInqTasks.put(t.whatid,new Set<task> {t});
                }   
            }
            
            // Populate same map with key as Account id 
            for(id i:mapInqTasks.keySet()){             
                mapInqTasks.put(mapInqAcc.get(i),mapInqTasks.get(i));
            }
            
            List<task> newTasksToInsert = new List<task>();
            for(String str : mapInqTasks.keySet()){
                if(str != null && str.subString(0,3) == '001'){
                    for(task newTask:mapInqTasks.get(str)){
                        task newtaskcl = new task();
                        newtaskcl = newTask.clone(false);   
                        newtaskcl.whatid = str;
                        newTasksToInsert.add(newTaskcl);
                    }
                }
            }
            insert newTasksToInsert;
        }catch(exception ex){
        	 system.debug('Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage());      
        }
    }// End of Method   
}// End of class.