global without sharing class OpportunityIOPFinalizeService {
    
    public static Map<String,Map<String,String>> relationshipDetailMap;
    public static Map<String, Map<String, String>> relatedObjectToFieldToValueVap 
            = new Map<String, Map<String, String>>{'Pay_Agreement_Worksheets__r' => new Map<String, String>{'Status__c' => 'Closed'},
                                                   'Quotes'                      => new Map<String, String>{'Status__c' => 'Closed'}
                                                  };
    public Static Map<String, String> objectToFilterClauseMap = new Map<string, String> {'Quotes' => 'WHERE Select_as_Final_Quote__c = true'};
    public static final String FILTER_CLAUSE = ' WHERE ID =:opportunityId';
    public static final String UPDATE_TO_STAGENAME = 'Pending Appointment';
    public static final String RELATED_EVENT_QUERY = 'SELECT Id FROM Events';
    public static final String eventSubject = '\'Appointment - In Person\', \'Appointment – On Phone\', \'Admission\'';
    public static final String eventType = 'Appointment';

    WebService static String triggerOpportunityFinalization(Id opportunityId) {
        Boolean updatedSuccessfulFlag = false;
        Id eventOppAccRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('OPP AC Event').getRecordTypeId();
        String redirectToId;
        relationshipDetailMap = Utils.getRelationshipDetails(Opportunity.SObjectType);
        List<SObject> relatedRecordList = new List<SObject>();
        List<SObject> updatedSObjectList = new List<SObject>();
        String queryStr = 'SELECT Id, StageName';
        String innerQueryStr = '';
        for(String keyObjectItr : relatedObjectToFieldToValueVap.keySet()) {
            innerQueryStr = ', (SELECT Id, ';
            for(String keyFieldItr : relatedObjectToFieldToValueVap.get(keyObjectItr).keySet()) {
                innerQueryStr += keyFieldItr+', ';
            }
            if(innerQueryStr != null && innerQueryStr != '') {
                innerQueryStr = innerQueryStr.removeEnd(', ')+ ' FROM '+keyObjectItr;
                if(objectToFilterClauseMap.containsKey(keyObjectItr)) {
                    innerQueryStr += ' '+objectToFilterClauseMap.get(keyObjectItr)+' ';
                }
                innerQueryStr += ' ) ';
                queryStr += innerQueryStr;
            }
        } 
        DateTime currentTime = System.now();
        queryStr += ', ('+RELATED_EVENT_QUERY+' WHERE RecordTypeId =\''+eventOppAccRecordTypeId+'\' AND Subject = \''+eventType+'\' AND Type IN  ('+eventSubject+') AND EndDateTime >= :currentTime ) ';
        queryStr += ' FROM Opportunity '+FILTER_CLAUSE; 
        List<Opportunity> sourceOpportunityList = ( (List<Opportunity>)Database.query(queryStr) );

        for( Opportunity opportunityItr : sourceOpportunityList ) {
            redirectToId = (String)opportunityItr.Id;
            if(opportunityItr.Quotes.size() > 0 && !opportunityItr.Quotes.isEmpty() ) {
                opportunityItr.StageName = UPDATE_TO_STAGENAME;
                updatedSObjectList.add(opportunityItr);
                for( String keyObjectItr : relatedObjectToFieldToValueVap.keySet()) {
                    relatedRecordList.addAll(opportunityItr.getSobjects( keyObjectItr ));
                    for(SObject sobjectItr : opportunityItr.getSobjects( keyObjectItr )) {
                        for(String keyFieldItr : relatedObjectToFieldToValueVap.get(keyObjectItr).keySet()) {
                            sobjectItr.put( keyFieldItr, relatedObjectToFieldToValueVap.get(keyObjectItr).get(keyFieldItr) );
                            updatedSObjectList.add(sobjectItr);
                        }
                    }
                }
                system.debug('>>> opportunityItr.Events : '+opportunityItr.Events);
                if(opportunityItr.Events.isEmpty() || opportunityItr.Events.size() == 0 )
                    redirectToId = '00U/e?what_id='+(String)opportunityItr.Id+'&retURL=%2F'+(String)opportunityItr.Id+'&RecordType='+eventOppAccRecordTypeId+'&ent=Event';
            }
            else {
                updatedSuccessfulFlag = false;

            }
        }
        try{
            if(!updatedSObjectList.isEmpty()) {
                update updatedSObjectList;
                updatedSuccessfulFlag = true;
            }            
        }
        catch(Exception exObj) {
            updatedSuccessfulFlag = false;
            redirectToId = opportunityId;
        }

        if(updatedSuccessfulFlag) {
            redirectToId += '#Successfull#';
        }
        else {
            redirectToId += '#Failed#';
        }

        return redirectToId;
    }
}