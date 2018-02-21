trigger OfferTrigger on McaApp__Offer__c (after insert, after update) {
	/*Id recordTypeId = [SELECT id from RecordType where DeveloperName ='Active_Program_Master'].Id;
    if(trigger.isInsert){
	    set<Id> setnewProgMasterId = new set<Id>();
	    for(McaApp__Offer__c offer: (list<McaApp__Offer__c>)trigger.new){
	    	system.debug('111111111111'+offer.Program_Master__c);
	        setnewProgMasterId.add(offer.Program_Master__c);
	    }
	    
	    list<ProgramMaster__c> lstProgramMaster = [Select Id, Name,Active__c, (select Id from Offers__r) 
	                                                            From ProgramMaster__c where Id IN: setnewProgMasterId];
	    for(ProgramMaster__c pgmMaster: lstProgramMaster){
	        if(pgmMaster.Offers__r.size()>0){
	            pgmMaster.RecordTypeId = recordTypeId;
	        }
	    }
	    system.debug('2222222222'+lstProgramMaster);
	    update lstProgramMaster;
    }
    if(trigger.isUpdate){
        set<Id> setProgMasterId;
        for(McaApp__Offer__c offer: (list<McaApp__Offer__c>)trigger.new){
            setProgMasterId.add(offer.Program_Master__c);
        }
        for(McaApp__Offer__c offer: (list<McaApp__Offer__c>)trigger.old){
            setProgMasterId.add(offer.Program_Master__c);
        }
        
        list<ProgramMaster__c> lstProgramMaster = [Select Id, Name,Active__c, (select Id from Offers__r) 
                                                                From ProgramMaster__c where Id IN: setProgMasterId];
        for(ProgramMaster__c pgmMaster: lstProgramMaster){
            if(pgmMaster.Offers__r.size()>0){
                pgmMaster.RecordTypeId = recordTypeId;
            }
            if(pgmMaster.Offers__r.size()==0 && pgmMaster.RecordTypeId == recordTypeId){
                pgmMaster.RecordTypeId = null;
            }
        }
        update lstProgramMaster;
    }*/
}