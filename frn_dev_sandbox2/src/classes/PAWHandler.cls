/**
 * Class PAWHandler
 */
public without sharing class PAWHandler implements TriggerInterface {
    public Map<Id,Opportunity> oppMap;
	public Set<Id> vobProfileId;

    // Constructor
    public PAWHandler(){
		vobProfileId = new Set<Id>();
    }

    /**
     * bulkBefore
     */
    public void bulkBefore(){
        set<Id> oppIdSet = new set<Id>();
        for(Pay_Agreement_Worksheet__c paw : (List<Pay_Agreement_Worksheet__c>)Trigger.New){
            oppIdSet.add(paw.Opportunity__c);
        }
        oppMap = new Map<Id,Opportunity>([SELECT Id,Name,StageName FROM Opportunity WHERE Id IN : oppIdSet]);
		for(Profile prf:[SELECT Id FROM Profile WHERE Name Like 'FRN - Verification of Benefits (VOB)%']){
			vobProfileId.add(prf.Id);
		}
    }

    public void bulkAfter(){

    }



    public void beforeInsert(SObject so){
        Pay_Agreement_Worksheet__c pawobj = (Pay_Agreement_Worksheet__c)so;
        if(oppMap.containsKey(pawobj.Opportunity__c) && oppMap.get(pawobj.Opportunity__c).StageName == 'Determination Complete' && vobProfileId.contains(Userinfo.getProfileId())){
            so.addError('Can not create new record as the Opportunity stage is set to Determination Complete.');
        }
    }

    public void beforeUpdate(SObject oldSo, SObject so){

    }

    /**
     * beforeDelete
     */
    public void beforeDelete(SObject so){

    }

    public void afterInsert(SObject so){

    }

    public void afterUpdate(SObject oldSo, SObject so){

    }

    public void afterDelete(SObject so){

    }

    public void afterUndelete(SObject so){

    }

    /**
     * andFinally
     */
    public void andFinally(){

    }
}