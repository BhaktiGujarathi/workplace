public with sharing class RecordScoreCalculationService {
    //public static final Map<String, List<ScoreMetadataService.FieldScoreDetailCls>> sectionScoreFieldToFieldsMap;
    public static ScoreMetadataService.OpportunityQualityReportMetaData metaData;
    public static final String OPPORTUNITYOBJECT = 'Opportunity';
    public static final String NEEDRECALCULATIONFIELD = 'Needs_Score_Recalculation__c';
    public static final Integer DEFAULT_BATCH_SIZE = 100;
    public static final String NOTEQUALOPERATOR = '!';
    public static final String MULTIVALUEOPERATOR = ';';
    public static Decimal sectionExpectedScore = 0;
    public static Decimal totalExpectedScore = 0;
    public static Decimal totalActualScore = 0;
    public static final List<String> additionalOppoFieldList =
                                        new List<String>{'Total_Opportunity_Score__c'
                                                        ,'Last_Score_Recalculated_DateTime__c'
                                                        ,'Id'
                                                        ,'Name'
                                                        ,'RecordTypeId'
                                                        ,'RecordType.DeveloperName'
                                                        ,'Height_Dependency__c'
                                                        ,'Weight_Dependency__c'};

    //wrapper classes start

    // wrapper for quality report component
    public class QualityReport {
        public Id targetOpportunityId;
        public String label;
        public String fieldAPiName;
        public Decimal scoreValue;
        public Decimal expectedScore;
        public Boolean isDependent;
        public Boolean isOpportunityField;
        public List<QualityReport> qualityReportList;

        public QualityReport(Id pTargetOpportunityId,
                             String pFieldAPiName,
                             Decimal pScoreValue,
                             Decimal pExpectedScore,
                             Boolean pIsDependent,
                             Boolean pIsOpportunityField
                             ) {
            targetOpportunityId = pTargetOpportunityId;
            fieldAPiName = pFieldAPiName;
            scoreValue = pScoreValue;
            expectedScore = pExpectedScore;
            isDependent = pIsDependent;
            isOpportunityField = pIsOpportunityField;
        }

        public QualityReport setLabel(String labelParam){
            this.label = labelParam;
            return this;
        }
    }

    // wrapper for score of each opportunity
    public class ScoreResult {
        QualityReport qualityReport;
        Opportunity opportunityRecord;
        Boolean isToRecalculate;

        public ScoreResult(QualityReport pQualityReport,
                           Opportunity pOpportunityRecord,
                           Boolean pIsToRecalculate) {
            qualityReport = pQualityReport;
            opportunityRecord = pOpportunityRecord;
            isToRecalculate = pIsToRecalculate;
        }
    }
    //wrapper classes stop

    // method to be called from batch 
    // opportunity id and recordtype will be passes as parameters.
    public static ScoreMetadataService.OpportunityQualityReportMetaData getOpportunityScoreMetadata(
                                                                    String pOpportunityRecordType) {
        metaData = ScoreMetadataService.fetchJsonMetadata(pOpportunityRecordType);
        
        return metaData;
    }
    
    // method to be called from page
    public static List<QualityReport> getOpportunityScore(Id pOpportunityId, String pOpportunityRecordType) {
        List<QualityReport> qualityReportList = new List<QualityReport>();
        metaData = ScoreMetadataService.fetchJsonMetadata(pOpportunityRecordType);
        qualityReportList = getOpportunityQualityScore(pOpportunityId, pOpportunityRecordType, metaData);
        return qualityReportList;
    }
    
     
    public static List<QualityReport> getOpportunityQualityScore(
                                                        Id pOpportunityId, 
                                                        String pOpportunityRecordType, 
                                                        ScoreMetadataService.OpportunityQualityReportMetaData metaData) {
    
        Map<String, List<String>> objectNameToListOfFieldsMap = new Map<String, List<String>>();
        List<String>  opportunityFieldList = new List<String>();
        List<Opportunity> opportunityList;
        List<Opportunity> toUpdateOpportunityList = new List<Opportunity>();
        List<QualityReport> qualityReportList = new List<QualityReport>();
       
        objectNameToListOfFieldsMap = getQueryFieldSet();
        if(objectNameToListOfFieldsMap.containsKey(OPPORTUNITYOBJECT)) {
            opportunityFieldList = objectNameToListOfFieldsMap.remove(OPPORTUNITYOBJECT);
        } 
        opportunityFieldList.addAll(additionalOppoFieldList);
        String opportunityQueryString = prepareQueryAndGetOpportunityRecord(pOpportunityId,
                                                                            objectNameToListOfFieldsMap,
                                                                            opportunityFieldList); 
        if(!String.isBlank(opportunityQueryString)) {
            opportunityList = Database.query(opportunityQueryString);
        }

        if(!opportunityList.isEmpty() && opportunityList != null) {
            for(Opportunity opportunityIterator : opportunityList) {
                ScoreResult scoreResultInstance;
                scoreResultInstance = calculateScoreForRecord(opportunityIterator);
                if(scoreResultInstance.isToRecalculate) {
                    toUpdateOpportunityList.add(scoreResultInstance.opportunityRecord);
                }
               qualityReportList.add(scoreResultInstance.qualityReport);
            }
        }
        if(!toUpdateOpportunityList.isEmpty()) {
            Boolean allOrNothing;
            Database.upsert(toUpdateOpportunityList, allOrNothing=false);
        }
        return qualityReportList;
    }

    // method to calculate the score
    // method to calculate the score
    public static ScoreResult calculateScoreForRecord(Opportunity pOpportunityInstance) {
        ScoreResult opportunityScoreResult;
        Opportunity scoreUpdatedOpportunity = new Opportunity();
        Decimal opportunityScorePercentage = 0.0;
        List<SObject> relatedChildRecords;
        Boolean isToRecalculate = false;
        Decimal totalExpectedScore = 0;
        Decimal totalActualScore = 0;
        scoreUpdatedOpportunity = pOpportunityInstance;
        QualityReport opportunityQualityReport = new QualityReport(
                                                pOpportunityInstance.Id,
                                                pOpportunityInstance.Name,
                                                (pOpportunityInstance.Total_Opportunity_Score__c==null
                                                ? 0
                                                : pOpportunityInstance.Total_Opportunity_Score__c),
                                                0,
                                                false,
                                                false);
        opportunityQualityReport.qualityReportList = new List<QualityReport>();
        
        // for each section 
        for ( ScoreMetadataService.SectionDetail section  : metaData.opportunity ) 
        {
            String sectionScoreField = (section.sectionAPIName != null ? section.sectionAPIName : '');
            QualityReport sectionQualityReport;
            List<QualityReport> fieldQualityReportList = new List<QualityReport>();
            Decimal sectionActualScore = 0;
            Decimal sectionExpectedScore = 0;
            Decimal scorePercentage = 0.00;
            
            // for each field
            for(ScoreMetadataService.FieldScoreDetailCls fieldDetailInstance : section.sectionFields )
            {
                Decimal scoreDecimalValue = 0.0;
                Decimal expectedScoreDecimalValue = 0.0;
                Boolean isDependent = Boolean.valueOf(fieldDetailInstance.isConditionallyVisible);
                Boolean isOpportunityField = true;
                String fieldValueStr = '';
                String controllingFieldValue = '';
                String relationShipName = '';
                Boolean isNotOperatorUsed = false;
                Boolean isMultiValue = false;
                List<String> fieldValueList = new List<String>();
                Set<String> fieldValueSet = new Set<String>();
                
                // if the value in controlling field should not be equal to controlling value
                if(String.valueOf(fieldDetailInstance.controlValue).contains(NOTEQUALOPERATOR)) {
                    isNotOperatorUsed = true;
                    fieldValueStr = String.valueOf(fieldDetailInstance.controlValue).substringAfter(NOTEQUALOPERATOR);
                }
                else {
                    fieldValueStr = String.valueOf(fieldDetailInstance.controlValue);
                }
                // if the conrolling field value is semicolan seperated value
                if(fieldValueStr.contains(MULTIVALUEOPERATOR)){
                    isMultiValue = true;
                    fieldValueList = fieldValueStr.split(MULTIVALUEOPERATOR);
                    fieldValueSet.addAll(fieldValueList);
                }
                
                // get Object api name for the current field
                relationShipName = fieldDetailInstance.objectAPIName;
                // if current field is from child record
                if (!relationShipName.equalsIgnorecase(OPPORTUNITYOBJECT)) 
                {
                    isOpportunityField = false;
                    relatedChildRecords = new List<SObject>();
                    relatedChildRecords = ( List<SObject> )pOpportunityInstance.getSObjects( relationShipName );
                    // if there are records of child object
                    if(relatedChildRecords != null && !relatedChildRecords.isEmpty()) 
                    {
                        sectionExpectedScore += (Decimal.ValueOf(fieldDetailInstance.fieldScore)*relatedChildRecords.size());
                        expectedScoreDecimalValue = (Decimal.ValueOf(fieldDetailInstance.fieldScore)*relatedChildRecords.size());
                        isDependent = Boolean.valueOf(fieldDetailInstance.isConditionallyVisible);
                        // for each child object
                        for( SObject sobjectInstance : relatedChildRecords) 
                        {
                            // if the score of current field is dependent on other controlling field
                            if(fieldDetailInstance.controlFieldAPIName != ''  && fieldDetailInstance.controlValue != '') 
                            {
                                controllingFieldValue = '';                                                            
                                String sObjectAPI = String.valueOf(sobjectInstance.getSobjectType());
                                // if the controlling field is same sobject
                                if(sObjectAPI.equalsIgnoreCase(fieldDetailInstance.controlObjectAPIName)) 
                                {
                                    controllingFieldValue = String.valueOf(sobjectInstance.get(fieldDetailInstance.controlFieldAPIName));
                                } // end if the controlling field is same sobject
                                // if controlling field is Opportunity
                                else if(fieldDetailInstance.controlObjectAPIName.equalsIgnoreCase(OPPORTUNITYOBJECT))
                                {
                                    controllingFieldValue = String.valueOf(pOpportunityInstance.get(fieldDetailInstance.controlFieldAPIName));
                                } // end if controlling field is Opportunity

                                system.debug('>>> isNotOperatorUsed : '+isNotOperatorUsed);
                                system.debug('>>> fieldDetailInstance.controlFieldAPIName :'+fieldDetailInstance.controlFieldAPIName);
                                system.debug('>>> controllingFieldValue : '+controllingFieldValue);
                                system.debug('>>> fieldValueStr : '+fieldValueStr);
                                system.debug('>>> fieldDetailInstance.fieldAPIName : '+fieldDetailInstance.fieldAPIName);
                                system.debug('>>> sobjectInstance.get(fieldDetailInstance.fieldAPIName) : '+sobjectInstance.get(fieldDetailInstance.fieldAPIName));
                                system.debug('>>> fieldValueSet : '+fieldValueSet);
                                if((!isNotOperatorUsed && ((controllingFieldValue != fieldValueStr) 
                                                           || (!fieldValueSet.isEmpty() && !fieldValueSet.contains(fieldValueStr))))
                                || (isNotOperatorUsed && ((controllingFieldValue == fieldValueStr)
                                                           || (!fieldValueSet.isEmpty() && fieldValueSet.contains(fieldValueStr))))) 
                                {
                                    system.debug('>>> if');
                                    // if controlling field on saME object
                                    // and controlling field.value != controlling value
                                    sectionExpectedScore = sectionExpectedScore - Decimal.ValueOf(fieldDetailInstance.fieldScore);
                                    expectedScoreDecimalValue = expectedScoreDecimalValue - Decimal.ValueOf(fieldDetailInstance.fieldScore);
                                    isDependent = (isDependent && true);
                                }
                                else if ((isNotOperatorUsed && ((controllingFieldValue != fieldValueStr) 
                                                             || (!fieldValueSet.isEmpty() && !fieldValueSet.contains(fieldValueStr))))
                                     || (!isNotOperatorUsed && ((controllingFieldValue == fieldValueStr)
                                                             || (!fieldValueSet.isEmpty() && fieldValueSet.contains(fieldValueStr)))))
                                {
                                    system.debug('>>> else if');
                                    // if controlling field on saME object
                                    // and controlling feild.value == controlling value
                                    if(sobjectInstance.get(fieldDetailInstance.fieldAPIName) != null)
                                    {
                                        system.debug('>>> in');
                                        sectionActualScore += Decimal.ValueOf(fieldDetailInstance.fieldScore);
                                        scoreDecimalValue += Decimal.ValueOf(fieldDetailInstance.fieldScore);
                                    }
                                    isDependent = (isDependent && false);
                                }
                            } // end if the score of current field is dependent on other controlling field
                            else if(fieldDetailInstance.controlFieldAPIName == '' && fieldDetailInstance.controlValue == '') 
                            {
                                if(sobjectInstance.get(fieldDetailInstance.fieldAPIName) != null) 
                                {
                                    sectionActualScore += Decimal.ValueOf(fieldDetailInstance.fieldScore);
                                    scoreDecimalValue += Decimal.ValueOf(fieldDetailInstance.fieldScore);
                                }
                                isDependent = (isDependent && false);
                            }
                            isToRecalculate = checkIfNeedsRecalcualtion(isToRecalculate, sobjectInstance);
                        } // end for each child object
                    } // end if there are records of child object
                    else {
                        if(fieldDetailInstance.controlObjectAPIName.equalsIgnoreCase(OPPORTUNITYOBJECT)) 
                        {
                            if(String.valueOf(pOpportunityInstance.get(fieldDetailInstance.controlFieldAPIName)) 
                                                        == String.valueOf(fieldDetailInstance.controlValue)) 
                            {
                                isDependent = (isDependent && false);
                                sectionExpectedScore += (Decimal.ValueOf(fieldDetailInstance.fieldScore));
                            }
                        }
                    }
                } // end if current field is from child record
                // if the current field is from Opportuntiy itself
                else if (relationShipName.equalsIgnorecase(OPPORTUNITYOBJECT))
                {
                    sectionExpectedScore += Decimal.ValueOf(fieldDetailInstance.fieldScore);
                    expectedScoreDecimalValue = Decimal.ValueOf(fieldDetailInstance.fieldScore);
                    isOpportunityField = true;
                    if(fieldDetailInstance.controlFieldAPIName != '' && fieldDetailInstance.controlValue != '' ) 
                    {
                        controllingFieldValue = String.valueOf(pOpportunityInstance.get(fieldDetailInstance.controlFieldAPIName));
                        if(controllingFieldValue != fieldDetailInstance.controlValue) 
                        {
                            sectionExpectedScore = sectionExpectedScore - Decimal.ValueOf(fieldDetailInstance.fieldScore);
                            isDependent = (isDependent && true);
                        } 
                        else if((controllingFieldValue == fieldDetailInstance.controlValue)
                            || (isNotOperatorUsed && (controllingFieldValue != fieldDetailInstance.controlValue))) 
                        {
                            if(pOpportunityInstance.get(fieldDetailInstance.fieldAPIName) != null ) 
                            {
                                sectionActualScore += Decimal.ValueOf(fieldDetailInstance.fieldScore);
                                scoreDecimalValue += Decimal.ValueOf(fieldDetailInstance.fieldScore);
                            }
                            isDependent = (isDependent && false);
                        }
                    }
                    else if(fieldDetailInstance.controlFieldAPIName == '' 
                     && fieldDetailInstance.controlValue == '' 
                     && fieldDetailInstance.lookupRelationName == '') 
                    {
                        if(pOpportunityInstance.get(fieldDetailInstance.fieldAPIName) != null ) 
                        {
                            sectionActualScore += Decimal.ValueOf(fieldDetailInstance.fieldScore);
                            scoreDecimalValue += Decimal.ValueOf(fieldDetailInstance.fieldScore);
                        }
                        isDependent = (isDependent && false);
                    }
                    else if(fieldDetailInstance.controlFieldAPIName == '' 
                     && fieldDetailInstance.controlValue == '' 
                     && fieldDetailInstance.lookupRelationName != '') 
                    {
                        Contact parentContact = (Contact) pOpportunityInstance.getSObject('Contact__r');
                        if(parentContact!=null && parentContact.get(fieldDetailInstance.fieldAPIName.substringAfter('__r.')) != null )
                        {
                            if( fieldDetailInstance.fieldScore !=null ){
                                sectionActualScore += Decimal.ValueOf(fieldDetailInstance.fieldScore);
                                scoreDecimalValue += Decimal.ValueOf(fieldDetailInstance.fieldScore);
                            }
                        }
                        isDependent = (isDependent && false);
                    }
                    isToRecalculate = checkIfNeedsRecalcualtion(isToRecalculate, pOpportunityInstance);
                } // end if the current field is from Opportuntiy itself
                fieldQualityReportList.add(new QualityReport(pOpportunityInstance.Id,
                                                             fieldDetailInstance.fieldAPIName,
                                                             scoreDecimalValue,
                                                             expectedScoreDecimalValue,
                                                             isDependent,
                                                             isOpportunityField)
                                            .setLabel( fieldDetailInstance.fieldLabel )
                                            );
            } // end for each field
            if(sectionActualScore != 0 && sectionExpectedScore != 0)
                scorePercentage = sectionActualScore.divide(sectionExpectedScore, 2);
            totalActualScore   += sectionActualScore;
            totalExpectedScore += sectionExpectedScore;
            scoreUpdatedOpportunity.put(sectionScoreField, (scorePercentage*100));
            sectionQualityReport = new QualityReport(pOpportunityInstance.Id,
                                                     sectionScoreField,
                                                     (scorePercentage*100),
                                                     totalExpectedScore,
                                                     false,
                                                     false);
            sectionQualityReport.label = section.sectionName;
            sectionQualityReport.qualityReportList = new List<QualityReport>();
            sectionQualityReport.qualityReportList = fieldQualityReportList;
            opportunityQualityReport.qualityReportList.add(sectionQualityReport);
        } // end for each section 
        if ( totalExpectedScore!= 0 ) {
            opportunityScorePercentage = totalActualScore.divide(totalExpectedScore, 2) *100;
        }

        //update wrapper to display on the user interface
        opportunityQualityReport.fieldAPiName = 'opportunity';
        opportunityQualityReport.scoreValue   = opportunityScorePercentage ;

        //update the record
        scoreUpdatedOpportunity.put('Last_Score_Recalculated_DateTime__c', System.now());
        scoreUpdatedOpportunity.put('Total_Opportunity_Score__c', (opportunityScorePercentage));

        opportunityScoreResult = new ScoreResult(opportunityQualityReport,
                                                 scoreUpdatedOpportunity,
                                                 isToRecalculate);
        
        return opportunityScoreResult;
    }

    //utility methods
    // method to prepare the field set for dynamic query
    public static Map<String, List<String>> getQueryFieldSet() {

        Map<String, List<String>> objectNameToListOfFieldsMap = new Map<String, List<String>>();
        List<String> fieldNameList;
        for(ScoreMetadataService.SectionDetail section : metaData.opportunity) {

            fieldNameList = new List<String>();
            for(ScoreMetadataService.FieldScoreDetailCls wraperInstance : section.sectionFields ) {
                fieldNameList = new List<String>();
                if(objectNameToListOfFieldsMap.containsKey(String.valueOf(wraperInstance.objectAPIName))) {
                    fieldNameList = objectNameToListOfFieldsMap.get(wraperInstance.objectAPIName);
                }

                fieldNameList.add(wraperInstance.fieldAPIName);
                objectNameToListOfFieldsMap.put(wraperInstance.objectAPIName, fieldNameList);
            }
        }
        for(String objectInstance : objectNameToListOfFieldsMap.keySet()) {
            fieldNameList = new List<String>();
            fieldNameList = objectNameToListOfFieldsMap.get(objectInstance);
            fieldNameList.add(NEEDRECALCULATIONFIELD);
            objectNameToListOfFieldsMap.put(objectInstance, fieldNameList);
        }

        return objectNameToListOfFieldsMap;
    }

    // prepare a dynamic query from field set for all objects
    public static String prepareQueryAndGetOpportunityRecord(Id pOpportunityId, 
                                                             Map<String, List<String>> pObjectNameToListOfFieldsMap,
                                                             List<String>  pOpportunityFieldList) {
        String finalQueryStr = '';
        pOpportunityFieldList.addAll(Utils.getInnerQueryList(Opportunity.SObjectType, pObjectNameToListOfFieldsMap));

        finalQueryStr = Utils.generateQuery(OPPORTUNITYOBJECT,
                                            pOpportunityFieldList,
                                            'WHERE Id =:pOpportunityId');
        return finalQueryStr;
    }

    public static Boolean checkIfNeedsRecalcualtion(Boolean pIsToRecalculate,
                                                    SObject pChildRecord) {

        return (pIsToRecalculate || boolean.valueOf(pChildRecord.get(NEEDRECALCULATIONFIELD)));
    }
    
    public static Integer getBatchSize() {
        Quality_Score_Settings__c qualityScoreObj = Quality_Score_Settings__c.getOrgDefaults();
        Integer batchSize = qualityScoreObj.Batch_Size__c != null 
                          ? Integer.ValueOf(qualityScoreObj.Batch_Size__c) 
                          : DEFAULT_BATCH_SIZE;

        return batchSize; 
    }
}