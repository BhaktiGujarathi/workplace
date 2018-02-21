trigger trg_AgentSite on Agent_Site__c (after insert,before update,after update) {
    List<Id> lstAgencySiteIDsInsert = new List<Id>();
    List<Id> lstAgencySiteIDsUpdate = new List<Id>();
    set<id> accCountryofSaleModify = new set<id>();
    
    //Before Update
    if(trigger.isupdate && trigger.isbefore){
        for(Agent_Site__c agntSite : trigger.new){
            //old value null and new value not null
            if(agntSite.End_Date__c != trigger.oldmap.get(agntSite.id).End_Date__c && trigger.oldmap.get(agntSite.id).End_Date__c == null){
                agntSite.Active__c = false;
            }
            //new value null and old value not null
            else if(agntSite.End_Date__c != trigger.oldmap.get(agntSite.id).End_Date__c && agntSite.End_Date__c == null){
                agntSite.Active__c = true;
            }                
        }
    }
    
    //After Update
    if(trigger.isafter && trigger.isupdate){
        system.debug('-->AfterUpdate');
        accCountryofSaleModify = new set<id>();
        set<id> staccid = new set<id>();
        list<Agent_Site__c> agnttoConsider = new List<Agent_Site__c>();
        for(Agent_Site__c agntSite : trigger.new){
            Agent_Site__c agsiteOld = trigger.oldmap.get(agntSite.id);
            if(agntSite.Active__c != agsiteOld.Active__c){
                if(agntSite.Agency__c != null){
                	staccid.add(agntSite.Agency__c);
                    agnttoConsider.add(agntSite);
                }
                lstAgencySiteIDsUpdate.add(agntSite.id);
                accCountryofSaleModify.add(agntSite.Agency__c);
            }
        }
        system.debug('-->accCountryofSaleModify'+accCountryofSaleModify);
    }
    
    //After Insert
    //On insert update to IPMS
    if(trigger.isafter){
        if(trigger.isinsert){
            for(Agent_Site__c agntSite : trigger.new){
                lstAgencySiteIDsInsert.add(agntSite.id);
            }
        }
    }
    
    //Update the country of sale on to account
    if(accCountryofSaleModify != null && !accCountryofSaleModify.isempty() && AgentSiteHandler.doUpdateAccLogictobeRUN){
        List<Account> lstAcc = [select id,Country_of_Sale__c,Blacklisted__c,Terminated__c,(select id,name,Start_Date__c,IsAccountBlackListedTerminated__c,Active__c,Agency__c,End_Date__c,Reinstated_Date__c from Agent_Sites__r where Active__c = true) from account where id in : accCountryofSaleModify];
        system.debug('-->lstAcc'+lstAcc);
        if(lstAcc != null && !lstAcc.isempty()){
            List<Account> lstAcctoUpdate = new List<Account>();
            for(Account acc : lstAcc){
                system.debug('-->acc.Agent_Sites__r'+acc.Agent_Sites__r.size());
                if(acc.Agent_Sites__r != null && !acc.Agent_Sites__r.isempty()){
                    account locacc = new account(id = acc.id);
                    set<string> stAgencySites = new set<string>();
                    for(Agent_Site__c agSite : acc.Agent_Sites__r){
                       stAgencySites.add(agSite.name);
                    }
                    List<string> lstAgencySites = new List<string>();
                    lstAgencySites.addall(stAgencySites);
                    system.debug('-->lstAgencySites'+lstAgencySites);
                    locacc.Country_of_Sale__c = string.join(lstAgencySites,';');
                    system.debug('-->locacc.Country_of_Sale__c'+locacc.Country_of_Sale__c);
                    if(locacc.Country_of_Sale__c != null && !String.isEmpty(locacc.Country_of_Sale__c))
                    	lstAcctoUpdate.add(locacc);
                }
            }
            if(lstAcctoUpdate != null && !lstAcctoUpdate.isempty()){
                update lstAcctoUpdate;
                system.debug('-->lstAcctoUpdate'+lstAcctoUpdate);
            }
        }
    }
    
    if(lstAgencySiteIDsInsert != null && !lstAgencySiteIDsInsert.isempty()){
        system.debug('----lstAgencySiteIDsInsert---->'+lstAgencySiteIDsInsert.size()+' --- '+lstAgencySiteIDsInsert);
        system.enqueueJob(new AsyncAgentWebservice (lstAgencySiteIDsInsert,'Agent Site Creation'));
    }
    if(lstAgencySiteIDsUpdate != null && !lstAgencySiteIDsUpdate.isempty()){ 
        AgentSiteHandler.CtrlAgentSiteUpdation(trigger.new,trigger.oldmap);
        //system.enqueueJob(new AsyncAgentWebservice (lstAgencySiteIDsUpdate,'Agent Site Updation'));
    }
        
}