/*
* Queueable class to create/update Building/Floor/Unit based on inventory record. 
*/
public class InventoryQueueable implements Queueable{
    
    public list<Inventory__c> lstinv {get;set;}
    List<Inv_Fld_Mapping__c> CS = Inv_Fld_Mapping__c.getall().values();
    Map<string,Id> mpExtIDpID = new Map<string,Id>();
    Map<Id,Inventory__c> lstINVtoUpdate = new Map<Id,Inventory__c>();    
    
    
    public InventoryQueueable(list<Inventory__c> invs){
        this.lstinv = invs;
    }
    
    public void execute(QueueableContext context) {
        try{
            //Get all External id field values related to building/floor and unit.
            set<string> stExtId = new set<String>();
            for(Inventory__c inv : lstinv){
                if(inv.Unit_ID__c != null)
                    stExtId.add(inv.Unit_ID__c);
                if(inv.Floor_ID__c != null)
                    stExtId.add(inv.Floor_ID__c);
                if(inv.Building_ID__c != null)
                    stExtId.add(inv.Building_ID__c);
            }
            //Prepare a map of externalid of location to location object
            Map<string,Location__c> mpExtIDLoc = new Map<string,Location__c>();
            for(Location__c loc : [select id,name,recordtypeid,recordtype.name,Location_ID__c from location__c where Location_ID__c  in : stExtId]){
                if(loc.Location_ID__c != null)
                    mpExtIDLoc.put(loc.Location_ID__c,loc);
            }
            
            //Prepare a map of recordtype name and recordtype ids for location object.
            Map<string,id> mpRT = new Map<string,Id>();
            for(Recordtype r : [select id,name from recordtype where sobjecttype = 'Location__c']){
                mpRT.put(r.name,r.id);
            }
            
            //Prepare Building location records.
            List<Location__c> lstLocations = new List<Location__c>();
            for(Inventory__c inv : lstinv){
                //Loop through only if external id is not null
                if(inv.Building_ID__c != null){
                    Location__c lcBuilding = new Location__c();
                    //For Update map the id
                    if(mpExtIDLoc.containskey(inv.Building_ID__c) && mpExtIDLoc.get(inv.Building_ID__c).id != null)
                        lcBuilding.id = mpExtIDLoc.get(inv.Building_ID__c).id;
                    lcBuilding.recordtypeid = mpRT.get('Building');
                    lcBuilding.Location_Type__c = 'Building';
                    //Loop through custom settings for field mapping.
                    for (Inv_Fld_Mapping__c mapping : CS) {
                        //Check if custom setting records are related to building
                        if(mapping.Is_Building__c){
                            system.debug('-mapping.Field_API_Name__c->'+mapping.Field_API_Name__c +'---inv.get(mapping.Inv_Field_API_Name__c)--->'+inv.get(mapping.Inv_Field_API_Name__c));
                            if(mapping.Is_Number_Conversion_Req__c){
                                lcBuilding.put(mapping.Field_API_Name__c, integer.valueof(inv.get(mapping.Inv_Field_API_Name__c)));
                            }
                            else{
                                lcBuilding.put(mapping.Field_API_Name__c, inv.get(mapping.Inv_Field_API_Name__c));
                            }
                        }
                    }
                    lstLocations.add(lcBuilding);
                }
            }
            
            //Insert all Buildings and map back to inventory.
            if(lstLocations != null && !lstLocations.isempty()){
                //the lstLocations can contain duplicates so to remove the duplicates prepare a map based on external id
                Map<string,Location__c> mplocationstoUpsert = new Map<string,Location__c>();
                for(Location__c loc : lstLocations){
                    mplocationstoUpsert.put(string.valueof(loc.Location_ID__c),loc);
                }
                //Upsert the values based on map values.
                upsert mplocationstoUpsert.values() Location_ID__c;
                //to map back building id on inventory prepare a map based on external id and building id
                for(Location__c loc : mplocationstoUpsert.values()){
                    if(loc.Location_ID__c != null){
                        mpExtIDpID.put(string.valueof(loc.Location_ID__c),loc.id);
                    }
                }
                //Update the inventory Building_Location__c field
                for(Inventory__c inv : lstinv){
                    //if building location field is null update building location field on inventory
                    if(mpExtIDpID.containskey(inv.Building_ID__c) && inv.Building_Location__c == null){
                        if(lstINVtoUpdate.containskey(inv.id)){
                            Inventory__c invt = lstINVtoUpdate.get(inv.id);
                            invt.Building_Location__c = mpExtIDpID.get(inv.Building_ID__c);
                            lstINVtoUpdate.put(inv.id,invt);
                        }
                        else{
                            lstINVtoUpdate.put(inv.id,new Inventory__c(id = inv.id,Building_Location__c = mpExtIDpID.get(inv.Building_ID__c)));
                        }
                    }
                }
            }
            
            //reinitialize to prepare floor records.
            lstLocations = new List<Location__c>();
            //Prepare Floor location records.
            for(Inventory__c inv : lstinv){
                //Loop through only if external id is not null
                if(inv.Floor_ID__c != null){
                    Location__c lcFloor = new Location__c();
                    lcFloor.recordtypeid = mpRT.get('Floor');
                    lcFloor.Location_Type__c = 'Floor';
                    //For Update map the id
                    if(mpExtIDLoc.containskey(inv.Floor_ID__c) && mpExtIDLoc.get(inv.Floor_ID__c).id != null)
                        lcFloor.id = mpExtIDLoc.get(inv.Floor_ID__c).id;
                    //Update the building lookup on floor record
                    if(lstINVtoUpdate.containskey(inv.id) && lstINVtoUpdate.get(inv.id).Building_Location__c != null)
                        lcFloor.Building_Number__c = lstINVtoUpdate.get(inv.id).Building_Location__c;
                    //Loop through custom settings for field mapping.
                    for (Inv_Fld_Mapping__c mapping : CS) {
                        //Check if custom setting records are related to floor
                        system.debug('-mapping.Field_API_Name__c->'+mapping.Field_API_Name__c +'---inv.get(mapping.Inv_Field_API_Name__c)--->'+inv.get(mapping.Inv_Field_API_Name__c));
                        if(mapping.Is_Floor__c){
                            if(mapping.Is_Number_Conversion_Req__c){
                                lcFloor.put(mapping.Field_API_Name__c, integer.valueof(inv.get(mapping.Inv_Field_API_Name__c)));
                            }
                            else{
                                lcFloor.put(mapping.Field_API_Name__c, inv.get(mapping.Inv_Field_API_Name__c));
                            }
                        }
                    }
                    lstLocations.add(lcFloor);
                }
            }
            
            //Insert all Floor and map back to inventory.
            if(lstLocations != null && !lstLocations.isempty()){
                //the lstLocations can contain duplicates so to remove the duplicates prepare a map based on external id
                Map<string,Location__c> mplocationstoUpsert = new Map<string,Location__c>();
                for(Location__c loc : lstLocations){
                    mplocationstoUpsert.put(string.valueof(loc.Location_ID__c),loc);
                }
                //Upsert the values based on map values.
                upsert mplocationstoUpsert.values() Location_ID__c;
                //to map back floor id on inventory prepare a map based on external id and floor id
                for(Location__c loc : lstLocations){
                    if(loc.Location_ID__c != null){
                        mpExtIDpID.put(string.valueof(loc.Location_ID__c),loc.id);
                    }
                }
                //Update the inventory Floor_Location__c field
                for(Inventory__c inv : lstinv){
                    //if floor location field is null update floor location field on inventory
                    if(mpExtIDpID.containskey(inv.Floor_ID__c) && inv.Floor_Location__c == null){
                        if(lstINVtoUpdate.containskey(inv.id)){
                            Inventory__c invt = lstINVtoUpdate.get(inv.id);
                            invt.Floor_Location__c = mpExtIDpID.get(inv.Floor_ID__c);
                            lstINVtoUpdate.put(inv.id,invt);
                        }
                        else{
                            lstINVtoUpdate.put(inv.id,new Inventory__c(id = inv.id,Floor_Location__c = mpExtIDpID.get(inv.Floor_ID__c)));
                        }
                    }
                }
            }
            
            //reinitialize to prepare floor records.
            lstLocations = new List<Location__c>();
            //Prepare Building location records.
            for(Inventory__c inv : lstinv){
                //Loop through only if external id is not null
                if(inv.Unit_ID__c != null){
                    Location__c lcUnit = new Location__c();
                    lcUnit.recordtypeid = mpRT.get('Unit');
                    lcUnit.Location_Type__c = 'Unit';
                    //For Update map the id
                    if(mpExtIDLoc.containskey(inv.Unit_ID__c) && mpExtIDLoc.get(inv.Unit_ID__c).id != null)
                        lcUnit.id = mpExtIDLoc.get(inv.Unit_ID__c).id;
                    //Update the Floor lookup on Unit record
                    if(lstINVtoUpdate.containskey(inv.id) && lstINVtoUpdate.get(inv.id).Floor_Location__c != null)
                        lcUnit.Floor_Number__c = lstINVtoUpdate.get(inv.id).Floor_Location__c;
                    //Loop through custom settings for field mapping.
                    for (Inv_Fld_Mapping__c mapping : CS) {
                        //Check if custom setting records are related to floor
                        system.debug('-mapping.Field_API_Name__c->'+mapping.Field_API_Name__c +'---inv.get(mapping.Inv_Field_API_Name__c)--->'+inv.get(mapping.Inv_Field_API_Name__c));
                        if(mapping.Is_Unit__c){
                            if(mapping.Is_Number_Conversion_Req__c){
                                lcUnit.put(mapping.Field_API_Name__c, integer.valueof(inv.get(mapping.Inv_Field_API_Name__c)));
                            }
                            else{
                                lcUnit.put(mapping.Field_API_Name__c, inv.get(mapping.Inv_Field_API_Name__c));
                            }
                        }
                    }
                    lstLocations.add(lcUnit);
                }
            }
            
            //Insert all Units and map back to inventory.
            if(lstLocations != null && !lstLocations.isempty()){
                //the lstLocations can contain duplicates so to remove the duplicates prepare a map based on external id
                Map<string,Location__c> mplocationstoUpsert = new Map<string,Location__c>();
                for(Location__c loc : lstLocations){
                    mplocationstoUpsert.put(string.valueof(loc.Location_ID__c),loc);
                }
                //Upsert the values based on map values.
                upsert mplocationstoUpsert.values() Location_ID__c;
                //to map back unit id on inventory prepare a map based on external id and unit id
                for(Location__c loc : lstLocations){
                    if(loc.Location_ID__c != null){
                        mpExtIDpID.put(string.valueof(loc.Location_ID__c),loc.id);
                    }
                }
                //Update the inventory Floor_Location__c field
                for(Inventory__c inv : lstinv){
                    //if unit location field is null update unit location field on inventory
                    if(mpExtIDpID.containskey(inv.Unit_ID__c) && inv.Unit_Location__c == null){
                        if(lstINVtoUpdate.containskey(inv.id)){
                            Inventory__c invt = lstINVtoUpdate.get(inv.id);
                            invt.Unit_Location__c = mpExtIDpID.get(inv.Unit_ID__c);
                            lstINVtoUpdate.put(inv.id,invt);
                        }
                        else{
                            lstINVtoUpdate.put(inv.id,new Inventory__c(id = inv.id,Unit_Location__c = mpExtIDpID.get(inv.Unit_ID__c)));
                        }
                    }
                }
            }
            //Update the Inventory
            if(!lstINVtoUpdate.values().isempty()){
                 List<Inventory__c> lstInventoUpdate = [select id,name,Unit_ID__c,Floor_ID__c,Building_ID__c,Unit_Location__c,Floor_Location__c,Building_Location__c from Inventory__c where id in : lstINVtoUpdate.keyset() for update];
                for(Inventory__c inv : lstInventoUpdate){
                    if(mpExtIDpID.containskey(inv.Unit_ID__c))
                    	inv.Unit_Location__c = mpExtIDpID.get(inv.Unit_ID__c);
                    if(mpExtIDpID.containskey(inv.Floor_ID__c))
                    	inv.Floor_Location__c = mpExtIDpID.get(inv.Floor_ID__c);
                    if(mpExtIDpID.containskey(inv.Building_ID__c))
                    	inv.Building_Location__c = mpExtIDpID.get(inv.Building_ID__c);
                }
                //update lstINVtoUpdate.values();
                DAMAC_Constants.skip_InventoryTrigger = TRUE; 
                update lstInventoUpdate;
            }
        }
        catch(exception ex){
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
}