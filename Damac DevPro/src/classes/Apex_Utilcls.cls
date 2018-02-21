public without sharing class Apex_Utilcls {
    public static set<string> getAllsObjectFields(String strObjectName){
        return null;
    }
    public static string getAllFieldsSOQL(String strObjectName){
        string strSOQL = 'Select Id,Name';
        map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(strObjectName.toLowerCase()).getDescribe().fields.getMap();
        if(fieldMap != null){
            for(Schema.SObjectField f : fieldMap.values()){
                Schema.DescribeFieldResult fd = f.getDescribe();
                if(fd.getName().toLowerCase()!='id' && fd.getName().toLowerCase()!='name'){//fd.isCustom()
                    strSOQL = strSOQL+','+fd.getName();
                }
            }
        }
        strSOQL = strSOQL+' from '+strObjectName;
        system.debug('strSOQL===>'+strSOQL);
        return strSOQL;
    }
    public static string getCustomFieldSOQL(String strObjectName){
        string strSOQL = 'Select Id,Name';
        map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(strObjectName.toLowerCase()).getDescribe().fields.getMap();
        if(fieldMap != null){
            for(Schema.SObjectField f : fieldMap.values()){
                Schema.DescribeFieldResult fd = f.getDescribe();
                if(fd.isCustom()){
                    strSOQL = strSOQL+','+fd.getName();
                }
            }
        }
        strSOQL = strSOQL+' from '+strObjectName;
        system.debug('strSOQL===>'+strSOQL);
        return strSOQL;
    }
    
    public static string getRandNo(integer len){
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        
        while (randStr.length() < len) {
             Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
             randStr += chars.substring(idx, idx+1);
        }
       
        return randStr;
    }
    
    
}