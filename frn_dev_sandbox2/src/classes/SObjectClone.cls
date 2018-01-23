public with sharing class SObjectClone {

    public final Map<String, Id> recordTypeMap;
    public Map<String,Map<String,String>> relationshipDetailMap;
    public Schema.SObjectType objectType;
    public Schema.FieldSet fieldSet;
    public Set<String> relationshipNameSet;
    public CloneInitializer initializer;
    public Id cloneRecordTypeId;

    public static final String FILTER_CLAUSE = ' WHERE ID IN :recordIdList';
    public CloneConfig config; 

    public class CloneConfig {
        //clone config
        public Boolean preserveId;
        public Boolean isDeepClone;
        public Boolean preserveReadonlyTimestamps;
        public Boolean preserveAutonumber;

        //default values
        public CloneConfig(){ 
            this.preserveId                 = false;
            this.isDeepClone                = true;
            this.preserveReadonlyTimestamps = false;
            this.preserveAutonumber         = false;
        }
    }

    //initialize cloner for a particular type
    public SObjectClone(Schema.SObjectType targetObject) {
        recordTypeMap = Utils.getRecordTypeMapForObjectGeneric(targetObject);
        relationshipDetailMap = Utils.getRelationshipDetails(targetObject);
        objectType=targetObject;
    }

    public SObjectClone setCloneConfig(CloneConfig config){
        this.config = config;
        return this;
    }

    public SObjectClone setFieldSet(Schema.FieldSet fieldSet){
        this.fieldSet = fieldSet;
        return this;
    }

    public SObjectClone setRelationshipNameSet(Set<String> relationshipNameSet){
        this.relationshipNameSet = relationshipNameSet;
        return this;
    }
    public SObjectClone setInitializer(CloneInitializer initializer){
        this.initializer = initializer;
        return this;
    }

    public SObjectClone setTargetRecordTypeId(String targetRecordTypeDevName){
        this.cloneRecordTypeId = recordTypeMap.get(targetRecordTypeDevName);
        return this;
    }


    //clone SObject base on source record id and fieldset
    // context : New SObject is initialized based on the context passed, 
    // which specifies the buisness process the cloning is used in current context.
    public SObject clone(Id recordId){        
        Map<Id,SObject> clonedMap = cloneSObjectList(new Id[]{recordId});
        return clonedMap.get(recordId);
    }

    public Map<Id,SObject> cloneSObjectList(List<Id> recordIdList){
            //sanity checks, allow injecting config variable from external context
            config = config==null ? new CloneConfig() : config;

            //source id verses cloned SObject map
            Map<Id,SObject> clonedSObjectMap = new Map<Id,SObject>();
            //generate select for the SObject and passed  fieldset

            String query = Utils.generateQuery(objectType,
                                               fieldSet,
                                               relationshipNameSet,
                                               FILTER_CLAUSE );

            Map<Id,SObject> sourceSObjectMap = new Map<Id,SObject>( (List<SObject>)Database.query(query) ); 
        
            
            for ( SObject SObjectRecord : sourceSObjectMap.values() ){  
                clonedSObjectMap.put( SObjectRecord.Id, 
                                      SObjectRecord.clone(config.preserveId,
                                                          config.isDeepClone,
                                                          config.preserveReadonlyTimestamps,
                                                          config.preserveAutonumber));
            }

            if( initializer != null ){
                for(Id parentSObjectId : clonedSObjectMap.keySet()){
                    SObject clonedSObject = clonedSObjectMap.get(parentSObjectId);
                    system.debug('>>> cloneRecordTypeId : '+cloneRecordTypeId);
                    clonedSObject.put('RecordTypeId',cloneRecordTypeId);
                    clonedSObject = initializer.initialize(parentSObjectId, clonedSObject);
                }
            }

            if( false == clonedSObjectMap.isEmpty() ){
                insert clonedSObjectMap.values();
            }

            List<SObject> clonedRelatedRecordList = new List<SObject>();

            //clone related records
            SObject sourceSObject;
            SObject clonedSObject;
            Map<Integer,List<SObject>> dataToInsertMap = new Map<Integer,List<SObject>>();
            String fieldName;
            Integer relationShipCount=0;    
            Integer bucketNumber     =0;
            Map<String,String> relationFieldDetailsMap;
                
            for(Id parentId :  recordIdList ){
                sourceSObject = sourceSObjectMap.get(parentId);
                clonedSObject = clonedSObjectMap.get(parentId);
                
                relationShipCount = 0;
                
                for(String relationName : relationshipNameSet ){
                    
                    if( relationName == null )
                        continue;

                    relationFieldDetailsMap = relationshipDetailMap.get(relationName.toLowerCase());

                    if( relationShipDetailMap == null )
                        continue;

                    //this code is required to make sure single bucket has records of at max 10 different relationships
                    //only, as salesforce does not allow dml insert on generic list containing data from more than 10 different objects
                    ++relationShipCount;
                    bucketNumber      = Integer.valueOf(relationShipCount/10);
                    if(dataToInsertMap.get(bucketNumber)==null){
                        dataToInsertMap.put(bucketNumber,new List<SObject>());
                    }
                    
                    clonedRelatedRecordList = sourceSObject.getsObjects(relationName);

                    if( null != clonedRelatedRecordList ){

                        for(SObject clonedRecord :  clonedRelatedRecordList.deepClone() ){
                            fieldName = relationFieldDetailsMap.get('RELATIONSHIP_FIELD');
                            clonedRecord.put(fieldName,clonedSObject.Id);
                            dataToInsertMap.get(bucketNumber).add(clonedRecord);
                        }
                    }
                }
            }

            //insert related records
            for( Integer key : dataToInsertMap.keySet() ){
                if( null != dataToInsertMap.get(key) && false == dataToInsertMap.get(key).isEmpty() ){
                    insert dataToInsertMap.get(key);
                }
            }
            
            return clonedSObjectMap;
        }

}