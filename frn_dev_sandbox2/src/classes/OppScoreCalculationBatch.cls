public class OppScoreCalculationBatch implements Database.Batchable<sObject>, Database.Stateful{
	Set<Id> opportunityIdSet = new Set<Id>();
    List<String> sObjectsToQueryList = new List<String>();
    Set<String> oppStageToExcludeSet = new Set<String> {'Referred Out','No activity within 30 Days','Closed'};
    List<Opportunity_Quality_Score_Setting__mdt> opportunityQualityScoreObjectSettingList;
	Map<String, Opportunity_Quality_Score_Setting__mdt> opportunityQualityScoreObjectSettingDBMap;
	Opportunity_Quality_Score_Setting__mdt opportunitySetting;
    Integer objectIterator = 0;
    Id referOutReordTypeId = getRefeOutRecordTypeId();

    public OppScoreCalculationBatch() {
        opportunityQualityScoreObjectSettingList
                    				  = new List<Opportunity_Quality_Score_Setting__mdt>();
        opportunityQualityScoreObjectSettingList = [SELECT DeveloperName,
														  Label,
		 												  Opportunity_Relationship_Field_API__c
												     FROM Opportunity_Quality_Score_Setting__mdt];
        opportunitySetting = new Opportunity_Quality_Score_Setting__mdt();
        opportunityQualityScoreObjectSettingDBMap = new Map<String, Opportunity_Quality_Score_Setting__mdt>();

        for(Opportunity_Quality_Score_Setting__mdt settingInstance : opportunityQualityScoreObjectSettingList) {
        	if(settingInstance.DeveloperName.equalsIgnoreCase('Opportunity')) {
        		opportunitySetting = settingInstance;
        		sObjectsToQueryList.add(settingInstance.DeveloperName);
        	} else {
        		opportunityQualityScoreObjectSettingDBMap.put(settingInstance.DeveloperName,
        										              settingInstance);
        	}
        }

        sObjectsToQueryList.addAll(opportunityQualityScoreObjectSettingDBMap.KeySet());
		opportunityQualityScoreObjectSettingDBMap.put(opportunitySetting.DeveloperName, opportunitySetting);
        
        System.debug('sObjectsToQueryList='+sObjectsToQueryList);
        System.debug('opportunityQualityScoreObjectSettingDBMap='+opportunityQualityScoreObjectSettingDBMap);
        
    }

	public Database.QueryLocator start(Database.BatchableContext BC){
		//List<SObject> sobjectList = new List<SObject>();
		//List<Id> opportunityIdList = new List<Id>();
		//String querystr = '';
        //String recordtypeIdStr = '';
        System.debug('Start : Counter='+objectIterator);

        return Database.getQueryLocator(getQuery());
	}


    public void execute(Database.BatchableContext BC, List<SObject> sobjectList){
        
        System.debug('Execute Start : Counter='+objectIterator);
        
        //requery to avoid race conditions
        sobjectList   = Database.query(getQuery(sobjectList));
        
        System.debug('Processing Records ='+sobjectList.size());
        
        Set<Id> scope = extractOpportunityIdSet(sobjectList);

        System.debug('Processing Opportunity Records ='+scope.size());
        
   		List<Opportunity> opportunityList = [SELECT id,
   													RecordType.DeveloperName
   											   FROM Opportunity
   											  WHERE Id IN :scope
											    AND RecordTypeId != :referOutReordTypeId
                                            	AND StageName NOT IN :oppStageToExcludeSet];

   		List<RecordScoreCalculationService.QualityReport> qualityReportList = new List<RecordScoreCalculationService.QualityReport>();

   		if(opportunityList != null){
   			for(Opportunity opportunityInstance : opportunityList) {
   				qualityReportList = RecordScoreCalculationService.getOpportunityScore(
	   											opportunityInstance.id,
	   											opportunityInstance.RecordType.DeveloperName);
   			}
   		}
        
        System.debug('Execute Stop : Counter='+objectIterator);
   	}

   	public void finish(Database.BatchableContext BC){
        if( objectIterator <  sObjectsToQueryList.size()-1 ){
            objectIterator++;
            Database.executeBatch(this, RecordScoreCalculationService.getBatchSize());
        }

   	}
    


    //util methods
    private String getCurrentOpportunityField(){
        String opportunityRelationsFieldStr = (opportunityQualityScoreObjectSettingDBMap.get(sObjectsToQueryList[objectIterator]).Opportunity_Relationship_Field_API__c != null
                                            ?  opportunityQualityScoreObjectSettingDBMap.get(sObjectsToQueryList[objectIterator]).Opportunity_Relationship_Field_API__c
                                            :  '');
        return opportunityRelationsFieldStr;
    }

    
    private String getCurrentObject(){    
        String objectNameStr = (opportunityQualityScoreObjectSettingDBMap.get(sObjectsToQueryList[objectIterator]).Label != null
                             ?  opportunityQualityScoreObjectSettingDBMap.get(sObjectsToQueryList[objectIterator]).Label
                             :  '');
        
       	System.debug('objectIterator'+objectIterator);
        System.debug('Current Object'+objectNameStr);
        return objectNameStr;
    }

    //extract parent opportunity id set for current object
    private Set<Id> extractOpportunityIdSet(List<SObject> sobjectList){
        Set<Id> scopeIdSet = new Set<Id>();
        for(SObject sObjectInstance : sobjectList) {
            Object idObject = sObjectInstance.get(getCurrentOpportunityField());

            if( idObject == null )
                continue;

            Id opportunityId = String.valueOf(idObject);
            //if already processed skip it.
            if(! opportunityIdSet.contains( opportunityId ) ) {
                scopeIdSet.add(opportunityId);
                opportunityIdSet.add(opportunityId);
            }
        }
        return scopeIdSet;
    }

    public String getQuery(){
        return getQuery(null);
    }

    public String getQuery(List<SObject> sobjectList){
        
        String opportunityRelationsFieldStr  = getCurrentOpportunityField();
        
        String opportunityRelationObjectName;
        
        if( opportunityRelationsFieldStr.indexOf('__c') != -1 ) {
        	opportunityRelationObjectName = opportunityRelationsFieldStr.replace('__c', '__r');
        } else if( opportunityRelationsFieldStr.endsWith('Id')  ){
            opportunityRelationObjectName = opportunityRelationsFieldStr.replace('Id', '');
        }
        
        String objectNameStr = getCurrentObject();

        System.debug('Current Object='+objectNameStr);
        System.debug('Opportunity Id Set '+opportunityIdSet);
        
        String querystr = ' SELECT '+opportunityRelationsFieldStr
                         +' FROM '+objectNameStr
                         +' WHERE Needs_Score_Recalculation__c = true' 
                         +' AND '+opportunityRelationsFieldStr+' != null'
            			 +' AND '+opportunityRelationsFieldStr+' NOT IN :opportunityIdSet';
        
		
        /*if(objectNameStr.equalsIgnoreCase('Opportunity')) {
            querystr += ' AND '+Label.OpportunityQualityScoreClause;
        } else if( String.isBlank(opportunityRelationObjectName) == false ){
           querystr  += ' AND '+opportunityRelationObjectName+'.RecordTypeId != :referOutReordTypeId';
        }*/
	
        if( String.isBlank(opportunityRelationObjectName) == false ){
           querystr  += ' AND '+opportunityRelationObjectName+'.RecordTypeId != :referOutReordTypeId';
           querystr  += ' AND '+opportunityRelationObjectName+'.StageName NOT IN :oppStageToExcludeSet';
        }
        querystr += ' AND '+Label.OpportunityQualityScoreClause;
        
        if( sobjectList !=null ){
            querystr += ' AND Id IN :sobjectList '; 
        }
        
        System.debug('Current Object Query='+querystr);

        return querystr;
    }

    public Id getRefeOutRecordTypeId(){
        return Schema.getGlobalDescribe().get('Opportunity')
                                 .getDescribe()
                                 .getRecordTypeInfosByName()
                                 .get('Refer Out Only').getRecordTypeId();
    }
}