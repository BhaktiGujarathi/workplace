public class AgentSiteHandler {
    
    public static boolean doUpdateAccLogictobeRUN = true;
    
    
    public static void CtrlAgentSiteUpdation(List<Agent_Site__c> lstNewagentSite,Map<Id,Agent_Site__c> mpOldagentSite){
        set<id> staccid = new set<id>();
        set<id> stagntsiteid = new set<id>();
        set<id> stAgentSitesTobeTermintated = new set<id>();
        
        for(Agent_Site__c agntSite : lstNewagentSite){
            Agent_Site__c agsiteOld = mpOldagentSite.get(agntSite.id);
            if(agntSite.Active__c != agsiteOld.Active__c){
                if(agntSite.Agency__c != null){
                    staccid.add(agntSite.Agency__c);
                }
                if(agntSite.name != Label.AgentSiteUAE && agntSite.name != Label.AgentSiteUK){
                    stAgentSitesTobeTermintated.add(agntSite.id);
                }
                stagntsiteid.add(agntSite.id);
            }
            
        }
        Map<id,wrapper> mpAccIDWrapper = new Map<id,wrapper>();
        if(staccid != NULL && !staccid.isEmpty()){
            for(account acc : [select id,name,(select id,name,Active__c from Agent_Sites__r where name =: Label.AgentSiteUAE or name =: Label.AgentSiteUK) from account where id in : staccid]){
                wrapper wp = new wrapper();
                wp.agntSiteCount = acc.Agent_Sites__r.size();
                wp.agentsiteUAEID = null;
                wp.agentsiteUKID = null;
                wp.isUAETerminated = false;
                wp.isUKTerminated = false;
                for(Agent_Site__c agntsitel : acc.Agent_Sites__r){
                    if(agntsitel.name == Label.AgentSiteUAE){
                        wp.agentsiteUAEID = agntsitel.id;
                        wp.isUAETerminated = agntsitel.Active__c ? false : true;
                    }else if(agntsitel.name == Label.AgentSiteUK){
                        wp.agentsiteUKID = agntsitel.id;
                        wp.isUKTerminated = agntsitel.Active__c ? false : true;
                    }
                }
                mpAccIDWrapper.put(acc.id,wp);
            }
        }
        system.debug('--mpAccIDWrapper->'+mpAccIDWrapper);
        /*
        If only one agent site exists for the account and 
        it is either UAE or UK and if requested to be terminated - terminate in salesforce and  invoke the webservice for termination
        
        If both UAE and UK agent sites exist in Salesforce, one is requested to be terminated - 
        only terminate in salesforce - don't invoke webservice for termination
        
        If both UAE and UK agent sites exist in Salesforce, both are  requested to be terminated - 
        terminate in salesforce  and invoke webservice for termination
         */ 
        
        for(id accid : mpAccIDWrapper.keyset()){
            for(id agentsiteid : stagntsiteid){
                wrapper wp = mpAccIDWrapper.containskey(accid) ? mpAccIDWrapper.get(accid) : null;
                if(wp != null && (wp.agentsiteUAEID == agentsiteid || wp.agentsiteUKID == agentsiteid)){
                    //if only one agent site exists and is either uk or uae.
                    if(wp.agntSiteCount == 1) {
                        //if(!string.isEmpty(wp.agentsiteUKID) || !string.isEmpty(wp.agentsiteUAEID)){
                        if( wp.agentsiteUKID != null  || wp.agentsiteUAEID != null ){
                            //if(wp.isUKTerminated || wp.isUAETerminated){
                                system.debug('--inside only one rec');
                                stAgentSitesTobeTermintated.add(agentsiteid);
                            //}
                        }
                    }
                    //both exist and both terminated
                    if(wp.agntSiteCount >= 2){
                        //if(!string.isEmpty(wp.agentsiteUKID) && !string.isEmpty(wp.agentsiteUAEID)){
                        if( wp.agentsiteUKID != null  || wp.agentsiteUAEID != null ){
                            if(wp.isUKTerminated == wp.isUAETerminated){
                                system.debug('--inside both rec');
                                stAgentSitesTobeTermintated.add(agentsiteid);
                            }
                        }
                    }                        
                }    
            }
        }
        List<Id> lstAgencySiteIDsUpdate = new List<Id>();
        lstAgencySiteIDsUpdate.addAll(stAgentSitesTobeTermintated);
        system.debug('----lstAgencySiteIDsUpdate---->'+lstAgencySiteIDsUpdate.size()+' --- '+lstAgencySiteIDsUpdate);
        //system.enqueueJob(new AsyncAgentWebservice (lstAgencySiteIDsUpdate,'Agent Site Updation'));
    }
    
    
    public class wrapper{
        public boolean isUKTerminated {get;set;}
        public boolean isUAETerminated {get;set;}
        public integer agntSiteCount {get;set;}
        public ID agentsiteUAEID {get;set;}
        public ID agentsiteUKID {get;set;}
    }
}