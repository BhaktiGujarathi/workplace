public with sharing class OpportunityAuditOnInsert {


  public Set<ID> sOfOppID;
  
  public void onOpportunityInsertAuditTrailRecord(){
  
        
       sOfOppID = new Set<ID>();
       for(Opportunity newOpp: (List<Opportunity>) trigger.new){
       
           sOfOppID.add(newOpp.id);
       }
       system.debug('@@@@@@ calling future');
       
       OpportunityOnInsertFutureClass.onAfterInsertFutureCall(sOfOppID);
       
  
  }
}