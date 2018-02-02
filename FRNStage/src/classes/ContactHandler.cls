/**
 * Class ContactHandler
 *
 * Trigger Handler for the Contact SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class ContactHandler implements TriggerInterface {
    Map<Id,Contact> conMap;
    Map<Id,List<opportunity>> conOpportunityMap;
    List<Opportunity> updateoppList;
    // Constructor
    public ContactHandler(){
        conMap = new Map<Id,Contact>();
        updateoppList = new  List<Opportunity>();
        conOpportunityMap = new Map<Id,List<opportunity>>();
    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){        
        
    }
 
    public void bulkAfter(){
        set<Id> conId = new set<Id>();
        for(Contact con:(List<Contact>)trigger.new){
            conMap.put(con.Id,con);
        }
        if(conMap.size()>0){
            List<Opportunity> oppList;
            for(Opportunity opp : [select id, Contact__c,RecordType.Name,CreatedDate from Opportunity where Contact__c IN: conMap.keyset()]){
                oppList = new List<Opportunity>();
                if(conOpportunityMap.containsKey(opp.Contact__c)){
                    conOpportunityMap.get(opp.Contact__c).add(opp);
                }else{
                    oppList.add(opp);
                    
                    conOpportunityMap.put(opp.Contact__c,oppList);
                }
                System.debug('conOpportunityMap :: >>'+conOpportunityMap);
            }
        }
        
        
    }
        
    
 
    public void beforeInsert(SObject so){        
                                  
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
                   
    }
 
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so){
       
    }
 
    public void afterInsert(SObject so){ 
        
    }
 
    public void afterUpdate(SObject oldSo, SObject so){ 
        Contact con = (Contact)so;
        Contact oldcon = (Contact)oldSo;
        String firstName = '';
        String LastName = '';
        String MiddleName = '';
        System.debug('con ::>>'+con.LastName);
        System.debug('conOpportunityMap :: >>'+conOpportunityMap);
        if(con.FirstName!=null){
            firstName = con.FirstName;
        }if(con.MiddleName!=null){
            MiddleName = con.MiddleName;
        }if(con.LastName!=null){
            LastName = con.LastName;
        }
        if(conOpportunityMap.containskey(con.id)){
            opportunity oppl;
            for(opportunity opp: conOpportunityMap.get(con.id)){
                oppl = new opportunity();
                oppl.Id = opp.Id;
                if(opp.RecordType.Name == 'Residential Treatment'){
                    oppl.Name = firstName+' '+MiddleName+' '+LastName +' '+'RTC'+' '+opp.CreatedDate.format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID());
                }else if(opp.RecordType.Name == 'Outpatient Treatment'){
                    oppl.Name = firstName+' '+MiddleName+' '+LastName +' '+'IOP'+' '+opp.CreatedDate.format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID());
                }else if(opp.RecordType.Name == 'Refer Out Only'){
                    oppl.Name = firstName+' '+MiddleName+' '+LastName +' '+'ROO'+' '+opp.CreatedDate.format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID());
                }
                
                updateoppList.add(oppl);
            }
            System.debug('updateoppList :: >>'+updateoppList);
        }
       
    }

    public void afterDelete(SObject so){
        
    }
 
    public void afterUndelete(SObject so){
        
    }
 
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally(){
        System.debug('updateoppList :: >>'+updateoppList);
       if(updateoppList.size()>0){
           update updateoppList;
       }
    }
}