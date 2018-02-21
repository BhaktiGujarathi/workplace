Public without sharing class ManageAgencySites{
   
    public static void insertAgencySites(string srCountrySale,Id AccntID) {
        List<Agent_Site__c> lstAgentSitestoInsert = new List<Agent_Site__c>();
        List<Id> lstAgencySiteIDs = new List<Id>();
        if(srCountrySale != null){
            String strCtrySale = srCountrySale;
            for(string strSite : strCtrySale.split(';')){
                Agent_Site__c objsite = new Agent_Site__c();
                objsite.Start_Date__c = system.today();
                //objsite.Service_Request__c = ObjSR.id;
                objsite.Active__c = true;
                objsite.Name = strSite;
                objsite.Agency__c =AccntID;
                lstAgentSitestoInsert.add(objsite);   
            }
            if(lstAgentSitestoInsert != null && !lstAgentSitestoInsert.isempty()){
                insert lstAgentSitestoInsert;
                for(Agent_Site__c objsite :  lstAgentSitestoInsert){
                    lstAgencySiteIDs.add(objsite.id);
                }
                //system.enqueueJob(new AsyncAgentWebservice (lstAgencySiteIDs,'Agent Site Creation'));
            }
        }
    }
    public static void UpdateAgencySites(string srCountrySale,Id AccntID) {
        List<Id> lstAgencySiteIDsUpdated = new List<Id>();
        List<Id> lstAgencySiteIDsInserted = new List<Id>();
        List<Agent_Site__c> lstAgentSites = [select id,name,Start_Date__c,Active__c,Agency__c,End_Date__c,Reinstated_Date__c from Agent_Site__c where Agency__c =: AccntID];
        Map<string,Agent_Site__c> mpAgentSites = new Map<String,Agent_Site__c>();
        List<Agent_Site__c> lstAgentSitestoUpdate = new List<Agent_Site__c>();
        List<Agent_Site__c> lstAgentSitestoInsert = new List<Agent_Site__c>();
        if(lstAgentSites != null && !lstAgentSites.isempty() && srCountrySale != null){
            for(Agent_Site__c objas : lstAgentSites){
                mpAgentSites.put(objas.name,objas);
            }
            Map<string,integer> newCntrySales = new Map<string,integer>();
            //If a country is added.
            for(string strSite : srCountrySale.split(';')){
                Agent_Site__c objsite = new Agent_Site__c();
                if(!mpAgentSites.containskey(strSite)){
                    objsite.Start_Date__c = system.today();
                    objsite.Active__c = true;
                    objsite.Name = strSite;
                    objsite.Agency__c = AccntID;
                    lstAgentSitestoInsert.add(objsite);
                }
                //deactivated country added back
                else if(mpAgentSites.containskey(strSite) && !mpAgentSites.get(strSite).Active__c){
                    objsite = mpAgentSites.get(strSite);
                    //objsite.Start_Date__c = system.today();
                    objsite.Reinstated_Date__c = system.today();
                    objsite.End_Date__c = null;
                    objsite.Active__c = true;
                    lstAgentSitestoUpdate.add(objsite);
                }
                newCntrySales.put(strSite,1);
            }
            //If a country is removed
            for(string existingCtrySaleValue : mpAgentSites.keyset()){
                //If a site is removed
                if(!newCntrySales.containskey(existingCtrySaleValue)){
                    //If site removed exists in database (else new record has to be created which has been already handled.)
                    if(mpAgentSites.containskey(existingCtrySaleValue)){
                        Agent_Site__c objsite = mpAgentSites.get(existingCtrySaleValue);
                        objsite.End_Date__c = system.today();
                        objsite.Active__c = false;
                        lstAgentSitestoUpdate.add(objsite);
                    }
                }
            }
            if(lstAgentSitestoUpdate != null && !lstAgentSitestoUpdate.isempty()){
                upsert lstAgentSitestoUpdate;
                for(Agent_Site__c objsite :  lstAgentSitestoUpdate){
                    lstAgencySiteIDsUpdated.add(objsite.id);
                }
                //system.enqueueJob(new AsyncAgentWebservice (lstAgencySiteIDsUpdated,'Agent Site Updation'));
            }
            if(lstAgentSitestoInsert != null && !lstAgentSitestoInsert.isempty()){
                upsert lstAgentSitestoInsert;
                for(Agent_Site__c objsite :  lstAgentSitestoInsert){
                    lstAgencySiteIDsInserted.add(objsite.id);
                }
                //system.enqueueJob(new AsyncAgentWebservice (lstAgencySiteIDsInserted,'Agent Site Creation'));
            }
            
        }
        else{
            insertAgencySites(srCountrySale,AccntID);
        }
    }
}