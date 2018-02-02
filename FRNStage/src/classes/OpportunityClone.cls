/*Opportunity Clone functionality used by Step Down Functionality*/ 
public class OpportunityClone {
        
        public static final String CONTEXT_STEPDOWNTO_IOP   = 'StepDownToIOP';
        public static final String CONTEXT_TRANSITIONTO_IOP = 'TransitionToIOP';
        public static final String CONTEXT_TRANSITIONTO_RTC = 'TransitionToRTC';
        public static final String STATUS_INPROGRESS        = 'In Process';

        //get recordtypeids for all opportunity records
        public static final Map<String, Id> opportunityRecordTypeMap = Utils.getRecordTypeMapForObjectGeneric(Opportunity.SObjectType);
        public static final Map<String,Map<String,String>> opportunityRelationshipDetailMap = Utils.getRelationshipDetails(Opportunity.SObjectType);

        public static final String FILTER_CLAUSE = ' WHERE ID IN :recordIdList';
        public static CloneConfig config; 

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

        //clone opportunity base on source record id and fieldset
        // context : New opportunity is initialized based on the context passed, 
        // which specifies the buisness process the cloning is used in current context.
        public static Opportunity cloneOpportunity(   Id recordId
                                                    , Schema.FieldSet fieldSet
                                                    , Set<String> relationshipNameSet
                                                    , OpportunityCloneInitializer initializer){
            Map<Id,Opportunity> clonedOpportunityMap = cloneOpportunityList(new Id[]{recordId} ,fieldSet,relationshipNameSet,initializer);
            return clonedOpportunityMap.get(recordId);
        }

        public static Map<Id,Opportunity> cloneOpportunityList(  List<Id> recordIdList
                                                            , Schema.FieldSet fieldSet
                                                            , Set<String> relationshipNameSet
                                                            , OpportunityCloneInitializer initializer){
            //sanity checks, allow injecting config variable from external context
            config = config==null ? new CloneConfig() : config;

            //source id verses cloned opportunity map
            Map<Id,Opportunity> clonedOpportunityMap = new Map<Id,Opportunity>();
            //generate select for the opportunity and passed  fieldset

            String query = Utils.generateQuery(   Opportunity.sObjectType
                                                , fieldSet
                                                , relationshipNameSet
                                                , FILTER_CLAUSE
            );

            Map<Id,Opportunity> sourceOpportunityMap = new Map<Id,Opportunity>( (List<Opportunity>)Database.query(query) ) ; 
        
            
            for ( Opportunity opportunityRecord : sourceOpportunityMap.values() ){  
                clonedOpportunityMap.put(   opportunityRecord.Id, 
                                            opportunityRecord.clone(  config.preserveId
                                                                    , config.isDeepClone
                                                                    , config.preserveReadonlyTimestamps
                                                                    , config.preserveAutonumber) 
                );
            }

            if( initializer != null ){
                for(Id parentOpportunityId : clonedOpportunityMap.keySet()){
                    Opportunity clonedOpportunity = clonedOpportunityMap.get(parentOpportunityId);
                    clonedOpportunity = initializer.initializeOpportunity(parentOpportunityId, clonedOpportunity);
                }
            }

            if( false == clonedOpportunityMap.isEmpty() ){
                insert clonedOpportunityMap.values();
            }

            List<SObject> clonedRelatedRecordList = new List<SObject>();

            //clone related records
            Opportunity sourceOpportunity;
            Opportunity clonedOpportunity;
            Map<Integer,List<SObject>> dataToInsertMap = new Map<Integer,List<SObject>>();
            String fieldName;
            Integer relationShipCount=0;    
            Integer bucketNumber     =0;
                
            for(Id parentId :  recordIdList ){
                sourceOpportunity = sourceOpportunityMap.get(parentId);
                clonedOpportunity = clonedOpportunityMap.get(parentId);
                
                relationShipCount = 0;
                
                for( String relationName : relationshipNameSet ){
                    //this code is required to make sure single bucket has records of at max 10 different relationships
                    //only, as salesforce does not allow dml insert on generic list containing data from more than 10 different objects
                    ++relationShipCount;
                    bucketNumber      = Integer.valueOf(relationShipCount/10);
                    if(dataToInsertMap.get(bucketNumber)==null){
                        dataToInsertMap.put(bucketNumber,new List<SObject>());
                    }
                    
                    
                    clonedRelatedRecordList = sourceOpportunity.getsObjects(relationName);

                    if( null != clonedRelatedRecordList ){

                        for(SObject clonedRecord :  clonedRelatedRecordList.deepClone() ){
                            fieldName = opportunityRelationshipDetailMap.get(relationName).get('RELATIONSHIP_FIELD');
                            clonedRecord.put(fieldName,clonedOpportunity.Id);
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
            
            return clonedOpportunityMap;
        }

    }