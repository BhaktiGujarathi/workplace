public with sharing class ScoreMetadataService{

    public static Map<String, List<FieldScoreDetailCls>> sectionScoreFieldToFieldsMap;

   public static OpportunityQualityReportMetaData fetchJsonMetadata(String pOpportunityRecordType) {
        sectionScoreFieldToFieldsMap = new Map<String, List<FieldScoreDetailCls>>();

        Document docObj = new Document();
        Quality_Score_Settings__c custom_Obj = Quality_Score_Settings__c.getOrgDefaults();
        String DocIdByCustomSetting = String.ValueOf(custom_Obj.get(pOpportunityRecordType + '_DocId__c'));
        // get document id from custom label
        docObj = [SELECT id, Body
                    FROM Document
                   WHERE Id =: DocIdByCustomSetting ];
        // convert blob to string
        String documentBodyStr = docObj.Body.toString();
        // deserialize the json string
        Map<String, Object> sectionScoreFieldToSectionFieldsMap 
                                            = (Map<String, Object>)JSON.deserializeUntyped(documentBodyStr);

        OpportunityQualityReportMetaData metaData = (OpportunityQualityReportMetaData)JSON.deserialize(documentBodyStr,OpportunityQualityReportMetaData.class);
       return metaData;
     }

    public class OpportunityQualityReportMetaData {
        public List<SectionDetail> opportunity;
    }

    // wrapper class
    public class FieldScoreDetailCls {
        public String objectAPIName                     {set;get;}
        public String lookupRelationName                {set;get;}
        public String fieldAPIName                      {set;get;}
        public String controlObjectAPIName              {set;get;}
        public String controlFieldAPIName               {set;get;}
        public String controlValue                      {set;get;}
        public String fieldScore                        {set;get;}
        public String fieldLabel                        {set;get;}
        public String isConditionallyVisible            {set;get;}
    }

    public class SectionDetail {
        public String sectionAPIName                    {set;get;}
        public String sectionName                       {set;get;}
        public List<FieldScoreDetailCls> sectionFields  {set;get;}
    }
}