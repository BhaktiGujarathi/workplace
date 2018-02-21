public with sharing class PreventProgramMasterOperation {

   Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('ProgramMaster__c'.toLowerCase()).getDescribe().Fields.getMap();
   
   Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Active_Program_Master'].Id;
   
   List<ProgramMaster__c> lstToUpdate;

   public void cloneAllField(ProgramMaster__c targetObj, ProgramMaster__c sourceObj) {

        for (String field : fMap.keySet()) {

            Schema.SObjectField SObjfield = fMap.get(field);

            if (SObjfield.getDescribe().isUpdateable()) {

               targetObj.put(field, sourceObj.get(field) );
               system.debug('***** targetObj ****' + targetObj);
            }
        }
    }

    public void preventProgramMaster() {

        system.debug('***** preventProgramMaster ****');
        Map<Id,ProgramMaster__c> mapProgramMaster;
       /* if(trigger.isInsert){
            mapProgramMaster = new Map<Id,ProgramMaster__c>([Select Id, Name,Active__c, (select Id from Offers__r)
                                                            From ProgramMaster__c
                                                            where Id IN: trigger.newMap.keyset()]);
            lstToUpdate = new list<ProgramMaster__c>();
            for(ProgramMaster__c pgmMaster: (List<ProgramMaster__c>)Trigger.new){
                if(mapProgramMaster.get(pgmMaster.Id).Offers__r.size()>0 ){
                    pgmMaster.RecordTypeId = recordTypeId;
                    lstToUpdate.add(pgmMaster);
                }
            }
            try{
                update lstToUpdate;
            }catch(Exception e){}

        }*/

        if (trigger.isUpdate) {

	        mapProgramMaster = new Map<Id,ProgramMaster__c>(   [SELECT Id, Name,Active__c, (SELECT Id FROM Offers__r)
    	                                                        FROM ProgramMaster__c
    	                                                        WHERE Id IN: trigger.newMap.keyset()]);

            system.debug('***** mapProgramMaster ****' + mapProgramMaster);

	        for (ProgramMaster__c pgmMaster : (List<ProgramMaster__c>)Trigger.new) {

	            if (mapProgramMaster.get(pgmMaster.Id).Offers__r.size()>0 ) {

	                if (((ProgramMaster__c)trigger.newMap.get(pgmMaster.Id)).Active__c == true) {

	                    if (pgmMaster.Active__c == ((ProgramMaster__c)trigger.oldMap.get(pgmMaster.Id)).Active__c) {

	                        trigger.newMap.get(pgmMaster.Id).addError('This Program Master cannot be modified since it is already associated with an Offer.');
                        }
	                    else {

	                        cloneAllField(pgmMaster,(ProgramMaster__c)trigger.oldMap.get(pgmMaster.Id));
	                        pgmMaster.Active__c = true;
	                    }
	                }
	            }
	        }
        }
        else if (Trigger.isdelete) {

         	mapProgramMaster = new Map<Id,ProgramMaster__c>(  [SELECT Id, Name,Active__c, (SELECT Id FROM Offers__r)
                                                                FROM ProgramMaster__c
                                                                WHERE Id IN: trigger.oldMap.keyset()]);

            for (ProgramMaster__c pgmMaster : (List<ProgramMaster__c>)Trigger.old) {

                if (mapProgramMaster.get(pgmMaster.Id).Offers__r.size() > 0 && mapProgramMaster.get(pgmMaster.Id).Active__c != false) {

                    trigger.oldMap.get(pgmMaster.Id).addError('This Program Master cannot be deleted since it is already associated with an Offer.');
                }
            }
        }
    }
}