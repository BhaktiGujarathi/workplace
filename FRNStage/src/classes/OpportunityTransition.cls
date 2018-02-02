global class OpportunityTransition {
    public static final String TRANSITIONED_TO_IOP = 'Transitioned to IOP';
    public static final String TRANSITIONED_TO_RTC = 'Transitioned to RTC';
    public static final String OPPORTUNITY_STAGE_CLOSED = 'Closed';
    public Static final String STATUS_INPROGRESS = 'In Process';
    public Static SObjectClone opportunityCloneClass = new SObjectClone(Opportunity.SObjectType);


    public class TransitionException extends Exception {}
    
    public static Opportunity markSourceOpportunityTransitioned(  Opportunity opportunity
                                                                , String transitionType
                                                                , Id clonedOpportunityId){
        opportunity.Transitioned_To__c  = clonedOpportunityId;
        opportunity.Close_Reason__c = transitionType;
        opportunity.StageName = OPPORTUNITY_STAGE_CLOSED;
        return opportunity;
    }

    public static Opportunity initializeTransitionedOpportunity(Opportunity opportunity){
        opportunity.Transitioned__c = true;
        opportunity.StageName = STATUS_INPROGRESS;
        opportunity.CloseDate = (Date.today()).addDays(60);
        return opportunity;
    }
    

    /**Transition to IOP Start*/
    // Triggers RTC transition functionality
    // Where RTC is cloned and transitioned to IOP opportunity
    WebService static Id triggerTransitionToIOP(Id opportunityId){

        //pre transition validation
        if( isClosed(opportunityId) == true ){
            throw new TransitionException('Opportunity is closed, cannot be transitioned to IOP');
        }

        //get settings for cloning related records
        //currently transition to IOP and step down to IOP functionality are using same set of meta data 
        //i.e custom setting and fieldsets to decide which fields and related objects to clone

        Map<String, String> relatedRecordNameMap = OpportunityStepDown.getOpportunityRelatedRecordsMap();
        Opportunity clonedOpportunity = (Opportunity)opportunityCloneClass
                                                       .setFieldSet(SObjectType.Opportunity.FieldSets.RTC_Step_Down_Fields_To_Clone)
                                                       .setRelationshipNameSet(relatedRecordNameMap.keySet())
                                                       .setInitializer(new TransitionToIOP_OppInit())
                                                       .setTargetRecordTypeId('Outpatient_Treatment')
                                                       .Clone(opportunityId);

        /*Map<String, String> relatedRecordNameMap = OpportunityStepDown.getOpportunityRelatedRecordsMap();
        Opportunity clonedOpportunity = OpportunityClone.cloneOpportunity(    opportunityId
                                                                            , SObjectType.Opportunity.FieldSets.RTC_Step_Down_Fields_To_Clone
                                                                            , relatedRecordNameMap.keySet()
                                                                            , new  TransitionToIOP_OppInit());*/
        
       //set original iop opportunity as closed as it is now transitioned to RTC
        Opportunity sourceOpportunity = new Opportunity(Id=opportunityId);
        sourceOpportunity = OpportunityTransition.markSourceOpportunityTransitioned(  sourceOpportunity
                                                                                    , OpportunityTransition.TRANSITIONED_TO_IOP
                                                                                    , clonedOpportunity.Id);
        update sourceOpportunity;

        return clonedOpportunity.Id;    
    }

    // Cloned opportunity Initializer class
    public class TransitionToIOP_OppInit implements CloneInitializer {
        public SObject initialize(Id parentId, SObject clonedRecord){
            Opportunity clonedOpportunity = (Opportunity)clonedRecord;
            clonedOpportunity.Transitioned_From__c  = parentId;
            clonedOpportunity.Name  = clonedOpportunity.Name.substringBefore('RTC')
                                        + 'IOP '
                                        + Utils.currentTimeLong();
            //clonedOpportunity.RecordTypeId = opportunityCloneClass.recordTypeMap.get('Outpatient_Treatment');
            initializeTransitionedOpportunity(clonedOpportunity);
            return clonedOpportunity;
        }
    }

    /**Transition to IOP Stop*/


     /**Transition to RTC Start*/

     // Triggers transition to IOP functionality
    // Where original opportunity is cloned and transitioned to RTC opportunity
    WebService static Id triggerTransitionToRTC(Id opportunityId){
        List<SObject> defultChildrenRecords = new List<SObject>();
        if( isClosed(opportunityId) == true ){
            throw new TransitionException('Opportunity is closed, cannot be transitioned to RTC');
        }

        //Id  clonedOpportunityId = cloneOpportunity.cloneOpptyResTreatType(opportunityId);
        Set<String> transitionToRTCRelatedRecords = getTransitionToRTCRelatedRecordsMap();

         Opportunity clonedOpportunity = (Opportunity)opportunityCloneClass
                                                       .setFieldSet(SObjectType.Opportunity.FieldSets.Transition_to_RTC_Fields_To_Clone)
                                                       .setRelationshipNameSet(transitionToRTCRelatedRecords)
                                                       .setInitializer(new TransitionToRTC_OppInit())
                                                       .setTargetRecordTypeId('Residential_Treatment')
                                                       .Clone(opportunityId);

        //set original opportunity as closed as it is now transitioned to RTC
        Opportunity sourceOpportunity = new Opportunity(Id=opportunityId);
        sourceOpportunity = OpportunityTransition.markSourceOpportunityTransitioned(  sourceOpportunity
                                                                                    , OpportunityTransition.TRANSITIONED_TO_RTC
                                                                                    , clonedOpportunity.Id );
        update sourceOpportunity;
        defultChildrenRecords.addAll((List<SObject>) createDiseaseRecordlist(clonedOpportunity.Id));
        defultChildrenRecords.addAll((List<SObject>) createEquipmntRecordlist(clonedOpportunity.Id));
        defultChildrenRecords.addAll((List<SObject>) createMedIssueRecordlist(clonedOpportunity.Id));
        system.debug('>>> defultChildrenRecords : '+defultChildrenRecords);
        system.debug('>>> defultChildrenRecords size : '+defultChildrenRecords.size());
        try {
            insert defultChildrenRecords;
        }
        catch(Exception exObj) {
            system.debug('>>> exObj : '+exObj);
        }
        return clonedOpportunity.Id;
    }


    // Cloned opportunity Initializer class
    public class TransitionToRTC_OppInit implements CloneInitializer{
        public SObject initialize(Id parentId, SObject clonedRecord){
            Opportunity clonedOpportunity = (Opportunity)clonedRecord;
            clonedOpportunity.Name  = clonedOpportunity.Name.substringBefore('IOP')
                                        + 'RTC '
                                        + Utils.currentTimeLong();
            clonedOpportunity.Transitioned_From__c  = parentId;
            clonedOpportunity.Transitioned__c = true;
            //clonedOpportunity.RecordTypeId = opportunityCloneClass.recordTypeMap.get('Residential_Treatment');
            initializeTransitionedOpportunity(clonedOpportunity);

            return clonedOpportunity;
        }
    }

    //get transition to RTC related list names
    public static Set<String> getTransitionToRTCRelatedRecordsMap(){
        Set<String> relationshipToObjectName = new Set<String>();
        
        for(Transition_RTC_Related_Objects_To_Clone__c settingInstance : Transition_RTC_Related_Objects_To_Clone__c.getAll().values()) {
            relationshipToObjectName.add( settingInstance.Opportunity_Relationship_API_Name__c );
        }
        return relationshipToObjectName;
    }

    /**Transition to RTC Stop*/

    //util methods
    public static Boolean isClosed(Id opportunityId){
        
        List<Opportunity> opportunityList = [
            Select isClosed 
              From Opportunity
             WHERE Id = :opportunityId 
             LIMIT 1
        ];

        if( opportunityList.isEmpty() ){
            throw new TransitionException('Error : Opportunity does not exist.');
        }

        return opportunityList[0].isClosed;
    }

    // method to create list of infectious diseases prior to creation of Opportunity
    public static List<Infectious_Disease__c> createDiseaseRecordlist(Id parentOpportunityId) {
        List<Schema.PicklistEntry> diseasestypeList = new List<Schema.PicklistEntry>();
        List<Infectious_Disease__c> diseasesRecordsList = new List<Infectious_Disease__c>();
        diseasestypeList = Infectious_Disease__c.Infectious_Disease__c.getDescribe().getPicklistValues();
        for( Schema.PicklistEntry f : diseasestypeList){
            Infectious_Disease__c diseaseRecord = new Infectious_Disease__c();
            diseaseRecord.Infectious_Disease__c= string.valueof(f.getLabel());
            diseaseRecord.Diagnosed__c= '';
            diseaseRecord.Opportunity__c = parentOpportunityId;
            diseasesRecordsList.add(diseaseRecord);
        }
        system.debug('>>> idWrpList : '+diseasesRecordsList);
        return diseasesRecordsList;
    }
    
    // method to create list of Medical equipment prior to creation of Opportunity
    public static List<Medical_Equipment__c> createEquipmntRecordlist(Id parentOpportunityId) {
        List<Schema.PicklistEntry> equipmntTypeList = new List<Schema.PicklistEntry>();
        equipmntTypeList = Medical_Equipment__c.Equipment_Type__c.getDescribe().getPicklistValues();
        List<Medical_Equipment__c> medEquipmentRecordList = new List<Medical_Equipment__c>();
        for( Schema.PicklistEntry f : equipmntTypeList){
            Medical_Equipment__c medEqipmntRecord = new Medical_Equipment__c();
            medEqipmntRecord.Equipment_Type__c = string.valueof(f.getLabel());
            medEqipmntRecord.Opportunity__c = parentOpportunityId;
            medEquipmentRecordList.add(medEqipmntRecord);
        }
        system.debug('>>> meWrpList : '+medEquipmentRecordList);
        return medEquipmentRecordList;
    }
    
    // method to create list of major medical issues prior to creation of Opportunity
    public static List<Major_Medical_Issue__c> createMedIssueRecordlist(Id parentOpportunityId) {
        List<Schema.PicklistEntry> medIssuestypeList = new List<Schema.PicklistEntry>();
        medIssuestypeList = Major_Medical_Issue__c.Major_Medical_Issue__c.getDescribe().getPicklistValues();
        List<Major_Medical_Issue__c> medIssueRecordList = new List<Major_Medical_Issue__c>();
        for( Schema.PicklistEntry f : medIssuestypeList){
            Major_Medical_Issue__c medIssueRecord = new Major_Medical_Issue__c();
            medIssueRecord.Major_Medical_Issue__c = string.valueof(f.getLabel());
            medIssueRecord.Opportunity__c = parentOpportunityId;
            medIssueRecordList.add(medIssueRecord);
        }
        system.debug('>>> mmiWrpList : '+medIssueRecordList);
        return medIssueRecordList;
    }
}