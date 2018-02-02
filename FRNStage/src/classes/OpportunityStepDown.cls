global without sharing class OpportunityStepDown {

    //Step Down Button Code For Versioning Purpose
    /**
        {!REQUIRESCRIPT("/soap/ajax/20.0/connection.js")}
        {!REQUIRESCRIPT("/soap/ajax/10.0/apex.js")}
    
        var isLockedFlag = sforce.apex.execute("RecordLockUtility", "checkIsLocked", { 
            pRecordId: "{!Opportunity.Id}" 
        });

        if(isLockedFlag == "false") { 
            try {
                var oppty = new sforce.SObject("Opportunity");
                oppty.id = "{!Opportunity.Id}";
                var opportunityId = sforce.apex.execute("OpportunityStepDown","triggerRTCStepDown", {opportunityId:"{!Opportunity.Id}"});
                console.log('Returned Id ='+opportunityId);    
                window.open('/'+opportunityId,"_self");
            } catch(e) { 
                console.log('Exception=',e);
                alert("Error during step down");
            }
        }else { 
            alert('Record is locked.'); 
        }

    **/

    public Static final String STR_ADMITTED_STAGE = 'Admitted';
    public Static final String STATUS_INPROGRESS = 'In Process';
    public Static SObjectClone opportunityCloneClass = new SObjectClone(Opportunity.SObjectType);

    // Triggers RTC step down functionality
    // Where RTC is cloned to IOP opportunity
    /*WebService static Id triggerRTCStepDown(Id opportunityId){
        Opportunity sourceOpportunity = new Opportunity();
        if(opportunityId != null) {
            sourceOpportunity = [SELECT id,
                                        StageName
                                   FROM Opportunity
                                  WHERE id =: opportunityId];
        }
        if((sourceOpportunity.StageName).equalsIgnoreCase(STR_ADMITTED_STAGE)) {
            //get settings for cloning related records
            Map<String, String> relatedRecordNameMap = getOpportunityRelatedRecordsMap();
            Opportunity clonedOpportunity = OpportunityClone.cloneOpportunity(    opportunityId
                                                                                , SObjectType.Opportunity.FieldSets.RTC_Step_Down_Fields_To_Clone
                                                                                , relatedRecordNameMap.keySet()
                                                                                , new StepDownToIOP_OppInit() );
            return clonedOpportunity.Id;
        }
        else {
            throw new RTCStepDownException('The source opportunity is not in Admitted stage');
            return null;
        }
    }
*/

    WebService static Id triggerRTCStepDown(Id opportunityId){
        Opportunity sourceOpportunity = new Opportunity();
        if(opportunityId != null) {
            sourceOpportunity = [SELECT id,
                                        StageName
                                   FROM Opportunity
                                  WHERE id =: opportunityId];
        }
        if((sourceOpportunity.StageName).equalsIgnoreCase(STR_ADMITTED_STAGE)) {
            //get settings for cloning related records
            //SObjectClone cloneClass = new SObjectClone(Opportunity.SObjectType);
            Map<String, String> relatedRecordNameMap = getOpportunityRelatedRecordsMap();
            Opportunity clonedOpportunity = (Opportunity)opportunityCloneClass
                                                        .setFieldSet(SObjectType.Opportunity.FieldSets.RTC_Step_Down_Fields_To_Clone)
                                                        .setRelationshipNameSet(relatedRecordNameMap.keySet())
                                                        .setInitializer(new StepDownToIOP_OppInit())
                                                        .setTargetRecordTypeId('Outpatient_Treatment')
                                                        .clone(opportunityId);

            return clonedOpportunity.Id;
        }
        else {
            throw new RTCStepDownException('The source opportunity is not in Admitted stage');
            return null;
        }
    }

    public static Map<String, String> getOpportunityRelatedRecordsMap(){
        Map<String, String> relationshipToObjectNameMap = new Map<String, String>();
        
        Map<String, StepDown_Related_Objects_To_Clone__c> objectsToCloneMap = StepDown_Related_Objects_To_Clone__c.getAll();

        for(StepDown_Related_Objects_To_Clone__c settingInstance : objectsToCloneMap.values()) {

            if(!relationshipToObjectNameMap.containsKey(settingInstance.Opportunity_Relationship_API_Name__c)) {
                relationshipToObjectNameMap.put(settingInstance.Opportunity_Relationship_API_Name__c, 
                                                settingInstance.Name);
            }
        }
        return relationshipToObjectNameMap;
    }

    public class StepDownToIOP_OppInit implements CloneInitializer{
        public SObject initialize(Id parentId, SObject clonedRecord){
            Opportunity clonedOpportunity = (Opportunity)clonedRecord;
            clonedOpportunity.Name  = clonedOpportunity.Name.substringBefore('RTC')
                                        + 'IOP '
                                        + System.now().format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID());
            clonedOpportunity.StageName = STATUS_INPROGRESS;
            clonedOpportunity.Step_Down__c = true;
            clonedOpportunity.Transferring_Facility__c = clonedOpportunity.FRN_Facility_Selected__c;
            clonedOpportunity.put('FRN_Facility_Selected__c', '');
            clonedOpportunity.CloseDate = (Date.today()).addDays(60);
            clonedOpportunity.RecordTypeId = opportunityCloneClass.recordTypeMap.get('Outpatient_Treatment');
            return clonedOpportunity;
        }
    }

    // custom exception for step down
    public class RTCStepDownException extends Exception {

    }
}