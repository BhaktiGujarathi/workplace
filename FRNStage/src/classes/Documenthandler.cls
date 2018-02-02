public without sharing class Documenthandler
    implements TriggerInterface
{
    public list<Opportunity> opplist;
    public Map<Id, Id> Oppmap;
// Constructor
    public Documenthandler()
    {
     opplist = new list<Opportunity>();
     Oppmap = new Map<Id, Id>();
    }
    
    public void bulkBefore()
    {
        set<Id> oppId = new set<Id>();
        for(Document__c doc : (list<Document__c>)trigger.new){
            oppId.add(doc.Opportunity__c);
            system.debug('oppId----'+oppId);
        }
        opplist = [select Id, Contact__c from Opportunity where Id=:oppId];
        system.debug('opplist---'+opplist);
        for(Opportunity opp:opplist){
            Oppmap.put(opp.Id, opp.Contact__c);
            system.debug('Oppmap-----'+Oppmap);
        }
    }
    public void bulkAfter()
    {
      
    }
    
    public void beforeInsert(SObject so)
    {
     Document__c doc1 = (Document__c)so;
      if(doc1.Opportunity__c!=null){
         doc1.Patient__c = Oppmap.get(doc1.Opportunity__c);
         system.debug('doc1---'+doc1);
     } 
    }
 
    public void beforeUpdate(SObject oldSo, SObject so)
    {
     Document__c doc1 = (Document__c)so;
     if(doc1.Opportunity__c!=null){
         doc1.Patient__c = Oppmap.get(doc1.Opportunity__c);
         system.debug('doc1---'+doc1);
     } 
    }
    
    public void beforeDelete(SObject so)
    {
       
    }
 
    public void afterInsert(SObject so)
    {
       
    }
 
    public void afterUpdate(SObject oldSo, SObject so)
    {
     
    }

    public void afterDelete(SObject so)
    {
    }
 
    public void afterUndelete(SObject so)
    {
    }
 
   
    public void andFinally()
    {   
      
    }
}