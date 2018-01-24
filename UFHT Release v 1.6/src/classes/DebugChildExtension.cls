Public with sharing class DebugChildExtension {
   public UFHT__Debug_Child__c rec {get; set;}
   public DebugChildExtension(ApexPages.StandardController con) {
      con.addFields(new list<String>{'Name'});
      rec = (UFHT__Debug_Child__c)con.getRecord();
      
   }
   
   public PageReference updateObj(){
   
       Database.update(rec, false);
       rec.Name = 'Hardik';
       Database.update(rec, false);
       
       return null;
   
   }

}