public class RecordTypesUtility {

    public static Id recId(String objType, String name) {  
        SObject obj;
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objType);
        if (targetType != null)
        {
            obj = targetType.newSObject();
            Schema.DescribeSObjectResult d = obj.getSObjectType().getDescribe(); 
            if (d != null)
            {
                Map<String,Schema.RecordTypeInfo> rtMap = d.getRecordTypeInfosByName();
                if (rtMap != null) 
                {
                    Schema.RecordTypeInfo rtInfo = rtMap.get(name);
                    if (rtInfo != null) 
                    {
                        return rtInfo.getRecordTypeId();
                    }
                }
            }
        }
        return null;
    }
    
}