/**************************************************************************************************
* Name               : DamacUtility                                                 
* Description        : An Utility class used for the portal                                             
* Created Date       : NSI - Diana                                                                        
* Created By         : 17/Jan/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE             Description                                                       
* 1.0         NSI - Diana          17/Jan/2017                    
* 1.1		  PWC - Durga          01/May/2017			"getDeliveryMode" new method to get the Delivery Modes based on User's Country    
* 1.2		  PWC - Durga		   01/May/2017			"UpdateCustomerStatus" Update the Buyer Account status as Active if SR's DP ok is true          
**************************************************************************************************/
public virtual class DamacUtility {
    /**************************************************************************************************
        Method:         DamacUtility
        Description:   
    **************************************************************************************************/
    public DamacUtility() {}

    /**************************************************************************************************
        Method:         getListViewId
        Description:    Based on the object name and customviewname get the customviewid
    **************************************************************************************************/
    public static string getListViewId(string objectName, string customViewName){

        Database.QueryLocator ql = Database.getQueryLocator('select id from '+objectName);
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(ql);
        System.SelectOption[] listViews = setController.getListViewOptions();
        system.debug('**listViews'+listViews);
        String listViewID = null;
        for(System.SelectOption listView : listViews)
        {
            if(listView.getLabel() == customViewName) 
            {
                listViewID = listView.getValue();
            }
        }    
        System.debug('***listViewID'+listViewID);
        return listViewID;

    }
    
    /*********************************************************************************************
    * @Description : Handle Exception and show an error message on page.                         *
    * @Params      : String                                                                      *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public static void throwError(String severity, String errorMessage){
        for(ApexPages.Severity thisSeverity : ApexPages.Severity.values()){
            if(thisSeverity.name() == severity){
                ApexPages.Message myMsg = new ApexPages.Message(thisSeverity, errorMessage);
                ApexPages.addMessage(myMsg);
                break;
            }
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to get the RecordTypes By IDs OR  Name                                                        
    * @Params      : String objectAPIName = (ex:Account,Agency_PC__c),   
    *                Boolean returnByIdORName = True for By ID false for By Name                                                                      
    * @Return      : Set<String>                                                                      
    *********************************************************************************************/
    public static Set<String> getRecordTypesOfSObject(String objectAPIName,Boolean returnByIdORName){
        Set<String> recTypes = new Set<String>();
        //Generate a map of tokens for the sObjects in your organization
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        
        //Retrieve the describe result for the desired object
        DescribeSObjectResult result = gd.get(objectAPIName).getDescribe();
        
        //Generate a map of tokens for all the Record Types for the desired object
        Map<String,Schema.RecordTypeInfo> recordTypeInfoByName = result.getRecordTypeInfosByName();
        Map<Id,Schema.RecordTypeInfo> recordTypeInfoById = result.getRecordTypeInfosById();
        
        if(returnByIdORName){
            for(String rc:recordTypeInfoById.keySet())
                recTypes.add((String)rc);
            return recTypes;
        }
        else
            return recordTypeInfoByName.keySet();
    }
    
    /*********************************************************************************************
    * @Description : Method to get the RecordTypes By IDs OR  Name                               *                             
    * @Params      : String objectAPIName = (ex:Account,Agency_PC__c), String rtype name.        *  
    * @Return      : Id                                                                          *
    *********************************************************************************************/
    public static Id getRecordTypeId(String objectAPIName, String recordTypeName){
        //Generate a map of tokens for the sObjects in your organization
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        //Retrieve the describe result for the desired object
        if(gd.containsKey(objectAPIName)){
	        DescribeSObjectResult result = gd.get(objectAPIName).getDescribe();
	        //Generate a map of tokens for all the Record Types for the desired object
	        Map<String, Schema.RecordTypeInfo> recordTypeInfoByName = result.getRecordTypeInfosByName();
	        if(recordTypeInfoByName.containsKey(recordTypeName)){
	        	return recordTypeInfoByName.get(recordTypeName).getRecordTypeId();
	        }else{
	        	return null;
	        }
        }else{
        	return null;
        }
    }      
            
    /*********************************************************************************************
    * Description : Method to get the Picklist Values By Object & Field                                                       
    * Params      : String objectAPIName (Ex: User)
    *               String picklistFieldAPI (Ex: Languages_Known__c )
    * Return      : List<String>   
    * Created By  : Pavithra Gajendra
    *********************************************************************************************/
    public static List<String> getPicklistValue(Schema.sObjectType objType,String field ){

        List<String> picklistValue = new List<String>();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe(); 
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        Schema.DescribeFieldResult values = fieldMap.get(field).getDescribe();
        List<Schema.PicklistEntry> val = values.getPicklistValues();
        for(Schema.PicklistEntry objPE: val ){
            picklistValue.add(objPE.value);  
        }           
        return picklistValue;
    }
    
    /*********************************************************************************************
    * Description : Method to get profile details based on the profile name 
    * Params      : String ProfileName (Ex: Property Consultant)
    * Return      : Map<String, Profile>
    * Created By  : Pavithra Gajendra
    *********************************************************************************************/
    public static Map<String, Profile> getProfileDetails(Set<String> profileNamesSet){
    	Map<String, Profile> nameProfileMap = new MaP<String, Profile>();
    	for(Profile thisProfile : [SELECT Id, Name FROM Profile WHERE Name =: profileNamesSet]){
    		nameProfileMap.put(thisProfile.Name, thisProfile);	
    	}
    	return nameProfileMap;
    }

    /*********************************************************************************************
    * Description : Method to get field API Names using fieldset
    * Params      : String fieldSetName, String ObjectName
    * Return      : List<Schema.FieldSetMember>
    *********************************************************************************************/
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
      try{
           Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
           
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
    
            return fieldSetObj.getFields();
      }catch(exception ex){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No Records')); 
          return null;
      }    
    }  

    /*********************************************************************************************
    * Description : Method to capitalize each word in a string for display purpose
    * Params      : String
    * Return      : String
    *********************************************************************************************/
    public static String capitalizeEachWord(String wordToBeCapitalized){
        List<String> splitString = wordToBeCapitalized.split(' ');
            
        String combinedString ='';
        for(String capitalizeString:splitString){
          combinedString=combinedString+' '+capitalizeString.toLowerCase().capitalize();
        }

        return combinedString.trim();   
    }
    
    /*********************************************************************************************
    * Description : Method to get Queue Id
    * Params      : DeveloperName ProfileName (Ex: DAMAC_QUEUE)
    * Return      : Id
    * Created By  : Pavithra Gajendra
    *********************************************************************************************/
    public static Id getQueueId(String developerName){
        Group damacQueue = [SELECT DeveloperName,Email,Id,Name,OwnerId,Type FROM Group WHERE Type = 'Queue' AND DeveloperName =:developerName];
        return damacQueue.Id ;
    }
    
    /*********************************************************************************************
	* @Description : Method to shuffle users.                                                    *
	* @Params      : List<Id>                                                                    *
	* @Return      : List<Id>                                                                    *
	*********************************************************************************************/    
	public static List<Id> shuffleQueue(List<Id> masterList){
		if(!masterList.isEmpty() && masterList.size() > 0){
			Id selectedId = masterList[0]; 
			masterList.remove(0);
			masterList.add(selectedId);	
		}	
		return masterList;
	}
	
	/*********************************************************************************************
	* @Description : Method to split multi select pick lists.                                    *
	* @Params      : String                                                                      *
	* @Return      : Set<String>                                                                 *
	*********************************************************************************************/    
	public static Set<String> splitMutliSelect(String multiSelectValue){
		Set<String> splittedValue = new Set<String>();
		if(multiSelectValue.containsIgnoreCase(';')){
			splittedValue.addAll(multiSelectValue.split(';'));	
		}else{
			splittedValue.add(multiSelectValue);		
		}
		return splittedValue;
	}
 
    /*********************************************************************************************
    * Description : Method to return previous owners of a inquiry record
    * Params      : Record Ids
    * Return      : Map<Id,List<Id>> all owner Ids
    * Created By  : Pavithra Gajendra
    *********************************************************************************************/
    public static Map<Id, Set<Id>> getInquiryOwnerIds(Set<Id> inquiryRecordSet){
        Map<Id, Set<Id>> inquiryOwnersSetMap = new Map<Id, Set<Id>>();
        for(Inquiry__History owners : [SELECT Field, Id, NewValue, OldValue, ParentID 
                                       FROM Inquiry__History 
                                       WHERE Field = 'Owner' AND 
                                             ParentId IN: inquiryRecordSet 
                                       ORDER BY ParentId]){
            String ownerId = String.valueOf(owners.NewValue);
            String userKeyPrefix =  Schema.getGlobalDescribe().get('User').getDescribe().getkeyprefix();
            if(ownerId.startsWith(userKeyPrefix)){
                if(inquiryOwnersSetMap.containsKey(owners.ParentID)){
                    inquiryOwnersSetMap.get(owners.ParentID).add(ID.valueOf(ownerId));
                }else{
                    inquiryOwnersSetMap.put(owners.ParentID,new Set<ID>{Id.valueOf(ownerId)}); 
                }
            }
        }  
        return inquiryOwnersSetMap;
    }

    /*********************************************************************************************
    * @Description : Method to get the object prefix eg., Account:001                                                      
    * @Params      : objectName                                                                    
    * @Return      : String                                                                     
    *********************************************************************************************/
    public static String getObjectPrefix(String objectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
       
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        String keyPrefix = DescribeSObjectResultObj.getKeyPrefix();
        return keyPrefix;
    }
    
	/*********************************************************************************************
	* @Description : Method to get calendar quarter for the asked month.                         *
	* @Params      : Integer                                                                     *
	* @Return      : Integer                                                                     *
	*********************************************************************************************/ 
    public static Integer getQuarterForMonth(Integer monthValue){ 
        if(Math.mod(monthValue, 3) == 0){
            return monthValue/3;  
        }else{
            return monthValue/3 + 1; 
        }        
    }
    
    /*********************************************************************************************
    * @Description : Method to get fields for SOQL query                                         *
    * @Params      : String                                                                      *
    * @Return      : String                                                                      *
    *********************************************************************************************/ 
    public static string getCreatableFieldsSOQL(string objectName){
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
               // if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
              //  }
            }
        }
        // contruction of SOQL
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        // return constrcucted query
        return 'SELECT ' + selects + ' FROM ' + objectName ;
         
    }
    
    /*********************************************************************************************
    * @Description : Method to get the IPMS code for a particular country                        *
    * @Params      : String                                                                      *
    * @Return      : String                                                                      *
    *********************************************************************************************/ 
    public static string getCountryCode(string CountryVal){
    	List<Country_Code_Mapping__c> CClist = Country_Code_Mapping__c.getall().values();
		String IPMSCode='';
		for(Country_Code_Mapping__c CC : CClist){
			if(CC.Country_Name__c==CountryVal)
			IPMSCode=CC.IPMS_Code__c;
		}
		
		return IPMSCode;    	
    }
 	
 	/*********************************************************************************************
    * @Description : Method to get the Delivery Modes of the PC/SPA based on thier Country       *
    * @Params      : String                                                                      *
    * @Return      : list<string>                                                                *
    *********************************************************************************************/ 
    public static list<string> getDeliveryMode(string SalesOffice){//1.1
    	list<string> lstDeliveryModes = new list<string>();
    	map<string,string> MapUniqueDeliveryModes = new map<string,string>();
    		string strQuery = '';
    		if(SalesOffice!=null && SalesOffice!='')
    			strQuery = 'Select Delivery_Mode__c from PC_SPA_Delivery_Mapping__mdt where Sales_Office__c=:SalesOffice';
    		else
    			strQuery = 'Select Delivery_Mode__c from PC_SPA_Delivery_Mapping__mdt limit 1000';
	    	for(PC_SPA_Delivery_Mapping__mdt DM:database.query(strQuery)){
	    		if(MapUniqueDeliveryModes.get(DM.Delivery_Mode__c)==null){
	    			MapUniqueDeliveryModes.put(DM.Delivery_Mode__c,DM.Delivery_Mode__c); 
	    			lstDeliveryModes.add(DM.Delivery_Mode__c);
	    		}
	    	}
    	return lstDeliveryModes;
    }
    
    /*********************************************************************************************
    * @Description : Method to get the Delivery Modes of the PC/SPA based on thier Country       *
    * @Params      : set<string>                                                                      *
    * @Return      :                                                                 *
    *********************************************************************************************/ 
    public static void UpdateCustomerStatus(set<string> setSRIds){//1.2
    	if(setSRIds!=null && setSRIds.size()>0){
    		map<string,Account> MapActiveCustomers = new map<string,Account>();
    		for(Buyer__c BU:[Select Id,Account__c from Buyer__c where Booking__r.Deal_SR__c IN:setSRIds and Account__c!=null limit 50000]){
    			if(MapActiveCustomers.get(BU.Account__c)==null){
    				Account acc = new Account(Id=BU.Account__c,Status__c='Active');
    				MapActiveCustomers.put(acc.Id,acc);
    			}
    		}
    		if(MapActiveCustomers!=null && MapActiveCustomers.size()>0){
				update MapActiveCustomers.values();
    		}
    	}
    }
    
}// End of class.