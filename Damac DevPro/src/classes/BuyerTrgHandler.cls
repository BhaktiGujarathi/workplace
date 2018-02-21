/**************************************************************************************************
* Name               : BuyerTrgHandler                                                            *
* Description        : This is the trigger handler class for Buyer object.                                         *
* Created Date       : 16/04/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         Kaavya      16/04/2017                                                              *
**************************************************************************************************/
public class BuyerTrgHandler implements TriggerFactoryInterface  {
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed before update.                       *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeBeforeUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){ 
        List<Buyer__c> updBuyerList = new List<Buyer__c>();
        List<id> PBookingIds = new List<id>();
    	Set<id> JBookingIds = new Set<id>();
        try{
          system.debug('Inside trigger==');
            for(Id thisKey : mapNewRecords.keySet()){
                Buyer__c newBuyer = (Buyer__c)mapNewRecords.get(thisKey);
                Buyer__c oldBuyer = (Buyer__c)mapOldRecords.get(thisKey);
                system.debug('OldBuyer==='+oldBuyer);
                system.debug('NewBuyer==='+newBuyer);
                Boolean PU=false;
                if(newBuyer.Registered__c){
                	//Tracking field changes for Buyer
                	system.debug('Inside if****');
                	//Tracking Address changes
	                if(newBuyer.Address_Line_1__c!= oldBuyer.Address_Line_1__c||newBuyer.Address_Line_2__c!= oldBuyer.Address_Line_2__c||newBuyer.Address_Line_3__c!= oldBuyer.Address_Line_3__c||newBuyer.Address_Line_4__c!= oldBuyer.Address_Line_4__c||newBuyer.City__c!= oldBuyer.City__c||newBuyer.Country__c!= oldBuyer.Country__c){
	                    newBuyer.Address_Changed__c=true;
	                    if(newBuyer.Primary_Buyer__c)   
		                PU=true;	                
	                }    
	                //Tracking Email and Phone no changes
	                if(newBuyer.Email__c!=oldBuyer.Email__c || newBuyer.Phone_Country_Code__c!=oldBuyer.Phone_Country_Code__c||newBuyer.Phone__c!=oldBuyer.Phone__c){
	                	newBuyer.Contact_Changed__c=true;   
	                	if(newBuyer.Primary_Buyer__c)   
		                PU=true;
                    }    
	                //Tracking Name & nationality changes
	                if(newBuyer.Title__c!=oldBuyer.Title__c||newBuyer.First_Name__c!=oldBuyer.First_Name__c || newBuyer.Last_Name__c!=oldBuyer.Last_Name__c||newBuyer.Nationality__c!=oldBuyer.Nationality__c||newBuyer.Organisation_Name__c!=oldBuyer.Organisation_Name__c) {	
	                	newBuyer.Name_Changed__c=true; 
	                	if(newBuyer.Primary_Buyer__c)   
		                PU=true;
	                	if(newBuyer.Title__c!=oldBuyer.Title__c||newBuyer.First_Name__c!=oldBuyer.First_Name__c || newBuyer.Last_Name__c!=oldBuyer.Last_Name__c)
	                		newBuyer.Name_Only_Changed__c=true; 
	                	if(newBuyer.Nationality__c!=oldBuyer.Nationality__c)
	                		newBuyer.Nationality_Changed__c=true;
	                	if(newBuyer.Organisation_Name__c!=oldBuyer.Organisation_Name__c)
	                		newBuyer.Org_Name_Changed__c=true;	
	                }
	                //Tracking Passport details changes if individual and Org registration details if corporate
	                if(newBuyer.Passport_Number__c!= oldBuyer.Passport_Number__c||newBuyer.Place_of_Issue__c!= oldBuyer.Place_of_Issue__c||newBuyer.Passport_Expiry_Date__c!= oldBuyer.Passport_Expiry_Date__c||newBuyer.CR_Registration_Expiry_Date__c!= oldBuyer.CR_Registration_Expiry_Date__c||newBuyer.CR_Registration_Place__c!= oldBuyer.CR_Registration_Place__c){
	                    newBuyer.Passport_Changed__c=true; 	
	                    if(newBuyer.Primary_Buyer__c)   
		                PU=true;
                    }     
	                // if both name & nationality and passport details changes    
	                if(newBuyer.Name_Changed__c && newBuyer.Passport_Changed__c) {
	                	newBuyer.Name_Passport_Changed__c=true;
	                	newBuyer.Name_Changed__c=false;
	                	newBuyer.Passport_Changed__c=false;
	                }
	                if(newBuyer.Primary_Buyer__c && PU ){    
		                PBookingIds.add(newBuyer.Booking__c);
	                }
	                else{ 
	                	// Tracking changes for Joint Buyer
	                	if(newBuyer.Primary_Buyer__c==false && newBuyer.Is_3rd_Party__c==false){
		                	if(newBuyer.Status__c=='Active' && oldBuyer.Status__c=='Active'){
			                	newBuyer.Status__c='Updated';
			                }
			                if(newBuyer.Status__c=='Updated'|| newBuyer.Status__c=='Removed'){
			                	JBookingIds.add(newBuyer.Booking__c);
			                }	
	                	}
	                }
            	}
            }
            //Invoking webservice for Primary Buyer details change
            if(PBookingIds.size()>0)
	        	system.enqueueJob(new AsyncReceiptWebservice (PBookingIds,'Party Update'));
	    	
	    	//Invoking webservice for Joint Buyers changes
	    	if(JBookingIds.size()>0){
	    		List<Id> JBIds = new List<Id>(JBookingIds);    		
	        	system.enqueueJob(new AsyncReceiptWebservice (JBIds,'Joint Buyer'));
	    	}
            
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed before insert.                       *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeBeforeInsertTrigger(List<sObject> BuyerList){ 
    	 Set<id> JBookingIds = new Set<id>();
    	 for(sObject thisSObject : BuyerList){
            Buyer__c newBuyer = ( Buyer__c) thisSObject; 
            if(newBuyer.Registered__c){
                if(newBuyer.Primary_Buyer__c==false){
                	if(newBuyer.Status__c!='Active'){
		                newBuyer.Status__c='New';
		                JBookingIds.add(newBuyer.Booking__c);
                	}
                }
			}
         }
         if(JBookingIds.size()>0){
    		List<Id> JBIds = new List<Id>(JBookingIds);    		
        	system.enqueueJob(new AsyncReceiptWebservice (JBIds,'Joint Buyer'));
    	}
    }
    
    
    // TOBE Implemented
      
    public void executeAfterInsertTrigger(Map<Id, sObject> mapNewRecords){ }
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> oldRecordsMap){ }
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){ }  
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){ }
    public void executeAfterUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){ }
    public void executeBeforeInsertUpdateTrigger(list<sObject> BuyerList,map<Id,sObject> mapOldRecords){ }
     
     
 }