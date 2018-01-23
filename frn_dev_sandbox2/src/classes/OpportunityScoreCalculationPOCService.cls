public with sharing class OpportunityScoreCalculationPOCService {
	public static Map<String, List<FieldScoreDetailCls>> sectionScoreFieldToFieldsMap;
    public static final String OBJECTAPINAMESTR = 'objectAPIName';
    public static final String FIELDAPINAMESTR = 'fieldAPIName';
    public static final String CONTROLFIELDAPINAMESTR = 'controlFieldAPIName';
    public static final String CONTROLEVALUESTR = 'controlValue';
    public static final String FIELDSCORESTR = 'fieldScore';

    // 015g0000001GFDW
    public Static void getJsonStruff() {
        Document docObj = new Document();
        docObj = [SELECT id, Body 
                    FROM Document
                   WHERE Id = '015g0000001GFDW'];
        system.debug('>>> docObj : '+docObj);
        system.debug('>>> docObj.body : '+docObj.Body.toString());
        String documentBody = docObj.Body.toString();
        Map<String, Object> map1 = (Map<String, Object>)JSON.deserializeUntyped(documentBody);
        List<FieldScoreDetailCls> fieldScoreDetailList = new List<FieldScoreDetailCls>();
        For(String keyStr : map1.KeySet()){
            system.debug('>>> Key : '+keyStr);
            system.debug('>>> value : '+map1.get(keyStr));
            List<Object> sectionFieldobjectList = (List<Object>)map1.get(keyStr);
            fieldScoreDetailList.clear();
            for(Object objectInstance : sectionFieldobjectList) {
                system.debug('>>> objectInstance : '+(FieldScoreDetailCls)objectInstance);
                /*FieldScoreDetailCls newWrapper = new FieldScoreDetailCls();
                newWrapper.objectAPIName = objectInstance.get('objectAPIName');
                newWrapper.fieldAPIName = objectInstance.get('fieldAPIName');
                newWrapper.controlFieldAPIName = objectInstance.get('controlFieldAPIName');
                newWrapper.controlValue = objectInstance.get('controlValue');
                newWrapper.fieldScore = objectInstance.get('fieldScore');
                fieldScoreDetailList.add(newWrapper);
                system.debug('>>> newWrapper : '+newWrapper);*/
            }

            //sectionScoreFieldToFieldsMap.put(keyStr,fieldScoreDetailList);
        }
        system.debug('>>> sectionScoreFieldToFieldsMap : '+sectionScoreFieldToFieldsMap);
        
    }

    // wrapper class
    public Class FieldScoreDetailCls{
        public String objectAPIName;
        public String fieldAPIName;
        public String controlFieldAPIName;
        public String controlValue;
        public String fieldScore;   
    }
}