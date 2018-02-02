// Class which contains useful utility methods required across classes
public class Utils {

    public static final String OBJECTNAME = 'RELATIONSHIP_OBJECT';
    public static final String FIELDNAME =  'RELATIONSHIP_FIELD';
    public static final String QUERY_TEMPLATE  = 'SELECT {0} FROM {1} {2}';
    public static final String NESTED_QUERY    = '({0})';
    public static final String COMMA_SEPARATOR = ', ';
    public static final String FIELD_ID        = 'Id';

    //cache holders
    public static Map<String, Schema.SObjectType> GLOBALDESCRIBE;
    //Sobject wise relationships details
    public static Map<String, Map<String,Map<String,String>> > objectWiseRelationshipMap;


    //cache methods
    public static Schema.SObjectType getSObjectType(String objectName){
        //lazy load
        if(null == GLOBALDESCRIBE){
            GLOBALDESCRIBE = Schema.getGlobalDescribe();
        }

        return GLOBALDESCRIBE.get(objectName);
    }

    //static initializers
    static {
        objectWiseRelationshipMap = new Map<String, Map<String,Map<String,String>> >();
    }


    //Util methods start

    //Gerate query for all fields in the fieldset and all fields from the related objects
    //relatedRelationshipNames is a map of 
    // Relationshipname => Related ObjectName
    public static String generateQuery(  Schema.sObjectType fromObject
                                , Schema.FieldSet fieldSet
                                , Set<String> relationshipNameSet
                                , String whereClause
                                ){
        
        List<String> queryFieldList;

        if( fieldSet != null ){
            queryFieldList =  getFieldListFor(fieldSet);
        } else {
            queryFieldList =  getFieldListFor(fromObject);
        }
                            
        //generate nestedQueryClauses
        if( null != relationshipNameSet ){
           queryFieldList.addAll( getInnerQueryList(fromObject,relationshipNameSet) );
        }

        String query = generateQuery(''+fromObject, queryFieldList, whereClause);

        return query;    
    }

    public static List<String> getInnerQueryList(Schema.sObjectType fromObject,Set<String> relationshipNameSet){
        List<String> queryFieldList = new List<String>();
        String objectName;
        List<String> relatedFieldList;
        String relatedQuery;

        Map<String,Map<String,String>> relationDetailsMap = getRelationshipDetails(fromObject); 

        System.debug('relationDetailsMap='+relationDetailsMap.keySet());

        Map<String,String> relationshipDetailMap;
        for( String relationshipName : relationshipNameSet ){
            relationshipName      = relationshipName!=null ? relationshipName.toLowerCase() : null;
            relationshipDetailMap = relationDetailsMap.get(relationshipName);

            if(  relationshipDetailMap ==  null ){
                System.debug('relationshipDetailMap is null for '+relationshipName);
                continue;
            }

            objectName = relationshipDetailMap.get('RELATIONSHIP_OBJECT');
            relatedFieldList = getFieldListFor(getSObjectType(objectName));

            relatedQuery = generateQuery(     relationshipName
                                            , relatedFieldList
                                            , '');
            relatedQuery = String.format(NESTED_QUERY,new String[]{relatedQuery});
            queryFieldList.add(relatedQuery);
        }
        return queryFieldList;
    }

    // for child objects with specific fields
    public static List<String> getInnerQueryList( Schema.sObjectType fromObject, 
                                                  Map<String, List<String>> relationshipNameToListOfFieldNameMap
                                                ){
        List<String> queryFieldList = new List<String>();
        String objectName;
        List<String> relatedFieldList;
        String relatedQuery;
        Map<String,Map<String,String>> relationDetailsMap = getRelationshipDetails(fromObject); 

        Map<String,String> relationshipDetailMap;
        for( String relationshipName : relationshipNameToListOfFieldNameMap.keySet() ){
            String relationNameStr = '';
            relationNameStr      = relationshipName!=null ? relationshipName : null;
            relationshipDetailMap = relationDetailsMap.get(relationNameStr.toLowerCase());

            if(  relationshipDetailMap ==  null ){
                System.debug('relationshipDetailMap is null for '+relationshipName);
                continue;
            }

            relatedFieldList = relationshipNameToListOfFieldNameMap.get(relationshipName);
            relatedQuery = generateQuery(     relationshipName
                                            , relatedFieldList
                                            , '');
            relatedQuery = String.format(NESTED_QUERY,new String[]{relatedQuery});
            queryFieldList.add(relatedQuery);
        }
        return queryFieldList;
    }

    //generate query for fields within a field set
    public static String generateQuery(       Schema.sObjectType fromObject
                                            , Schema.FieldSet fieldSet
                                            , String whereClause){
        
        return generateQuery(''+fromObject, getFieldListFor(fieldSet), whereClause);
    }

    //generate query for fieldnames passed in
    public static String generateQuery(       String fromObject
                                            , List<String> fieldNameSet
                                            , String whereClause){

        //sanity check
        whereClause = whereClause == null ? '' : whereClause;

        //local variables
        String queryFieldsClause = '';
      
        for(String fieldName : fieldNameSet) {
            //if not first time here, add a ,
            if(false == String.isBlank(queryFieldsClause)){
                queryFieldsClause += COMMA_SEPARATOR;
            }

            queryFieldsClause += fieldName;
        }

        //Corner cases if no fields in the field set field set
        //1
        if( true == String.isBlank(queryFieldsClause) ){
            queryFieldsClause += FIELD_ID;
        }

        String query = String.format(QUERY_TEMPLATE, new String[]{ 
              queryFieldsClause
            , ''+fromObject 
            , whereClause
        });

        return query;
    }

    //Supporting methods
    public static List<String> getFieldListFor(Schema.FieldSet fieldSet){
        List<String> fieldNameSet = new List<String>();
        for(Schema.FieldSetMember fieldSetMember : fieldSet.getFields()) {
            fieldNameSet.add(fieldSetMember.getFieldPath());
        }
        return fieldNameSet;
    }

    public static List<String> getFieldListFor(Schema.sObjectType fromObject){
        system.debug('fromObject='+fromObject);
        List<String> fieldNameSet = new List<String>();
        Schema.DescribeFieldResult dfr;
        for(Schema.SObjectField fieldInstance : fromObject.getDescribe().fields.getMap().values()) {
            dfr = fieldInstance.getDescribe();
            //@TODO TO remove as all fields should be cloned
            //if( dfr.isAccessible() ){
                fieldNameSet.add( dfr.getname() );
            //}
        }
        return fieldNameSet;
    }

    public static Boolean startsWith(String sourceString, String character){
        //sanity
        if( sourceString == null ){
            return false;
        }
        return sourceString.trim().startsWith(character);
    } 

    public static Map<String,Map<String,String>> getRelationshipDetails(Schema.SObjectType parentSobjectType){
        
        Map<String,Map<String,String>> relationDetailsMap = objectWiseRelationshipMap.get(''+parentSobjectType);
        //if in cache return immediately
        if( null != relationDetailsMap ){
            return relationDetailsMap;
        } else {
           relationDetailsMap  = new Map<String,Map<String,String>>();
        }
        
        Schema.DescribeSObjectResult describeResult = parentSobjectType.getDescribe();
        String fieldName;
        Map<String,String> detailsMap;
        String childRelationshipName;
        for(Schema.ChildRelationship childRelationship : describeResult.getChildRelationships()){
            
            childRelationshipName = childRelationship.getRelationshipName();

            if( childRelationshipName == null )
                continue;
            
            //objectname    
            detailsMap = new Map<String,String>();
            detailsMap.put(Utils.OBJECTNAME, ''+childRelationship.getChildSObject());
            //field
            fieldName = childRelationship.getField().getDescribe().getName();
            detailsMap.put(Utils.FIELDNAME, fieldName);

            childRelationshipName = childRelationshipName.toLowerCase();
            relationDetailsMap.put( childRelationshipName, detailsMap );
        }

        objectWiseRelationshipMap.put(''+parentSobjectType,relationDetailsMap);

        return relationDetailsMap;
    }


    //record type details utility methods
    //Record types cache
    private static Map<Schema.SObjectType,Map<String,Id>> rtypesCache;
    private static List<sObject> results;
    static {
        rtypesCache = new Map<Schema.SObjectType,Map<String,Id>>();//convenient map, formatted from results.
        results = new List<sObject>();//contains all recordtypes retrieved via SOQL
    }

    // Returns a map of active, user-available RecordType IDs for a given SObjectType,
    // keyed by each RecordType's unique, unchanging DeveloperName 
    public static Map<String, Id> getRecordTypeMapForObjectGeneric(Schema.SObjectType token) {
        // Do we already have a result? 
        Map<String, Id> mapRecordTypes = rtypesCache.get(token);
        // If not, build a map of RecordTypeIds keyed by DeveloperName
        if (mapRecordTypes == null) {
            mapRecordTypes = new Map<String, Id>();
            rtypesCache.put(token,mapRecordTypes);
        } else {
        // If we do, return our cached result immediately!
        return mapRecordTypes;
        }

        // Get the Describe Result
        Schema.DescribeSObjectResult obj = token.getDescribe();


        //Check if we already queried all recordtypes.
        if (results == null || results.isEmpty()) {
        // Obtain ALL Active Record Types
        // (We will filter out the Record Types that are unavailable
        // to the Running User using Schema information)
            String soql = 'SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE IsActive = TRUE';
            try {
                results = Database.query(soql);
            } catch (Exception ex) {
                results = new List<SObject>();
            }
        }

        // Obtain the RecordTypeInfos for this SObjectType token
        Map<Id,Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosByID();
        // Loop through all of the Record Types we found,
        // and weed out those that are unavailable to the Running User
        for (SObject rt : results) { 
            if (recordTypeInfos.get(rt.Id) != null) {
                if (recordTypeInfos.get(rt.Id).isAvailable()) {
                    // This RecordType IS available to the running user,
                    //      so add it to our map of RecordTypeIds by DeveloperName
                    mapRecordTypes.put(String.valueOf(rt.get('DeveloperName')),rt.Id);
                }
                else {
                    System.debug('The record type ' + rt.get('DeveloperName') + ' for object ' + rt.get('sObjectType') + ' is not availiable for the user.');
                }
            }
        }

        return mapRecordTypes;
    }

    public static String currentTimeLong(){
        return System.now().format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID());
    }


    public static Boolean isIOP(Opportunity opportunity){
        return isOpportunityOfType(opportunity, 'Outpatient_Treatment');
    }

    public static Boolean isOpportunityOfType(Opportunity opportunity, String recordTypeDevName){
        return opportunity.RecordType.DeveloperName == recordTypeDevName;
    }

    public static Boolean isOpportunityId(Id recordId){
        return Schema.Opportunity.SObjectType ==  recordId.getSobjectType();
    }


    public static Boolean isPAWId(Id recordId){
        return Schema.Pay_Agreement_Worksheet__c.SObjectType ==  recordId.getSobjectType();
    }
}