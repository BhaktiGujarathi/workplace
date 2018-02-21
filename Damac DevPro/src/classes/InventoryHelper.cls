/*
 * From Inventory Create/Update Properties.
 */ 
public class InventoryHelper {
    
    /*
     *Method to Create/Update Property Records
     */ 
    public static void createRec(List<Inventory__c> lstinv){
        try{ 
            set<integer> stPropertyIds = new set<integer>();
            //Get all property id fields into a set.
            for(Inventory__c inv : lstinv){
                if(inv.Property_ID__c != null && inv.Property_ID__c.isNumeric())
                	stPropertyIds.add(integer.valueof(inv.Property_ID__c));
            }
            //If any existing properties get them into a map based on key property id (external id field)
            Map<String,Property__c> mpProperties = new Map<string,Property__c>();
            if(stPropertyIds != null && !stPropertyIds.isempty()){
                for(Property__c p : [select id,name,Property_ID__c from Property__c where Property_ID__c in: stPropertyIds]){
                    if(p.Property_ID__c != null){
                        mpProperties.put(string.valueof(p.Property_ID__c),p);
                    }
                }
            }
            
            Map<Id,Inventory__c> lstINVtoUpdate = new Map<Id,Inventory__c>();
            List<Inv_Fld_Mapping__c> CS = Inv_Fld_Mapping__c.getall().values();
            
            //From the given inventories prepare the properties needs to be inserted.
            //In case of update of a property provide its ID based on the map mpProperties
            List<Property__c> lstproperty = new List<Property__c>();
            for(Inventory__c inv : lstinv){
                //Loop through only if external id is not null
                if(inv.Property_ID__c != null){
                    Property__c prpNew = new Property__c();
                    //For Update map the id
                    if(mpProperties.containskey(inv.Property_ID__c) && mpProperties.get(inv.Property_ID__c).id != null)
                    	prpNew.id = mpProperties.get(inv.Property_ID__c).id;
                    //Loop through custom settings for field mapping.
                    for (Inv_Fld_Mapping__c mapping : CS) {
                        //Check if custom setting records are related to property
                        if(mapping.Is_Property__c){
                            if(mapping.Is_Number_Conversion_Req__c){
                                prpNew.put(mapping.Field_API_Name__c, integer.valueof(inv.get(mapping.Inv_Field_API_Name__c)));
                            }
                            else{
                                prpNew.put(mapping.Field_API_Name__c, inv.get(mapping.Inv_Field_API_Name__c));
                            }
                        }
                    }
                    lstproperty.add(prpNew);
                }
            }
            
            //Insert all properties and map back to inventory.
            Map<string,Id> mpExtIDpID = new Map<string,Id>();
            if(lstproperty != null && !lstproperty.isempty()){
                //the lstproperty can contain duplicates so to remove the duplicates prepare a map based on external id
                Map<string,Property__c> mpPropertiestoUpsert = new Map<string,Property__c>();
                for(Property__c prop : lstproperty){
                    mpPropertiestoUpsert.put(string.valueof(prop.Property_ID__c),prop);
                }
                //Upsert the values based on map values.
                upsert mpPropertiestoUpsert.values() Property_ID__c;
                //to map back property id on inventory prepare a map based on external id and property id
                for(Property__c prop : mpPropertiestoUpsert.values()){
                    if(prop.Property_ID__c != null){
                        mpExtIDpID.put(string.valueof(prop.Property_ID__c),prop.id);
                    }
                }
                //Update the inventory property field
                for(Inventory__c inv : lstinv){
                    //if property field is null update property field on inventory
                    if(mpExtIDpID.containskey(inv.Property_ID__c) && inv.Property__c == null){
						lstINVtoUpdate.put(inv.id,new Inventory__c(id = inv.id,Property__c = mpExtIDpID.get(inv.Property_ID__c)));
                    }
                }
            }
            //Update the Inventory
            if(!lstINVtoUpdate.values().isempty()){
                List<Inventory__c> lstInventoUpdate = [select id,name,Property__c,Property_ID__c from Inventory__c where id in : lstINVtoUpdate.keyset() for update];
                for(Inventory__c inv : lstInventoUpdate){
                    inv.Property__c = mpExtIDpID.get(inv.Property_ID__c);
                }
                DAMAC_Constants.skip_InventoryTrigger = TRUE;
                update lstInventoUpdate;
                //update lstINVtoUpdate.values();
            }
            //Repeat the process for Building/Floor and Unit respectively.
            System.enqueueJob(new InventoryQueueable(lstinv));
        }
        catch(exception ex){
            system.debug('Exception -->'+ex.getMessage());
            set<id> stInvIds = new set<id>();
            for(Inventory__c inv : lstinv){
                stInvIds.add(inv.id);
            }
            List<Inventory__c> lstInventoUpdate = [select id,name,Error__c from Inventory__c where id in : stInvIds for update];
            for(Inventory__c inv : lstInventoUpdate){
                inv.Error__c = ex.getMessage();
            }
            DAMAC_Constants.skip_InventoryTrigger = TRUE;
            update lstInventoUpdate;
        }
        
    }
    
    /********************************************************************************************* 
    * @Description : Method to reflect the latest inventory status on the booking unit.          *
    * @Params      : Map<Id, Inventory__c>, Map<Id, Inventory__c>                                *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public static void updateAssociatedBookingUnits(Map<Id, Inventory__c> newRecordsMap, Map<Id, Inventory__c> oldRecordsMap){
    	Map<Id, Inventory__c> statusModifiedInventoryMap = new Map<Id, Inventory__c>();
    	List<Booking_Unit__c> updateBookingUnitsList = new List<Booking_Unit__c>();
    	try{
	    	for(Id thisKey: newRecordsMap.keySet()){
	    		Inventory__c newInventoryRecord = newRecordsMap.get(thisKey);
	    		Inventory__c oldInventoryRecord = oldRecordsMap.get(thisKey);
	    		if(newInventoryRecord != null && oldInventoryRecord != null && 
	    		   newInventoryRecord.Status__c != null && oldInventoryRecord.Status__c != null &&
	    		   newInventoryRecord.Status__c != oldInventoryRecord.Status__c){
	    			statusModifiedInventoryMap.put(newInventoryRecord.Id, newInventoryRecord);	
	    		}
	    	}	
	    	if(!statusModifiedInventoryMap.isEmpty()){
	    		for(Booking_Unit__c thisBookingUnit : [SELECT Id, Unit_s_Current_Status__c, Inventory__c 
	    											   FROM Booking_Unit__c 
	    											   WHERE Inventory__c IN: statusModifiedInventoryMap.keySet()]){
	    			if(statusModifiedInventoryMap.containsKey(thisBookingUnit.Inventory__c) && 
	    			   String.isNotBlank(statusModifiedInventoryMap.get(thisBookingUnit.Inventory__c).Status__c)){
	    				thisBookingUnit.Unit_s_Current_Status__c = statusModifiedInventoryMap.get(thisBookingUnit.Inventory__c).Status__c;
	    				updateBookingUnitsList.add(thisBookingUnit);		
	    			}
	    		}	
	    		if(!updateBookingUnitsList.isEmpty()){
	    			update updateBookingUnitsList;	
	    		}
	    	}
    	}catch(exception ex){
            system.debug('Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage());
        }
    }
}// End of class.