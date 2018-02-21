public with sharing class DynamicQueryGenerator {
    Id oppId;
    public DynamicQueryGenerator(Id pOppId){
        oppId = pOppId;
    }

    public map<Id, map<String, String>> queryBuild(set<String> mergeFields, map<String, set<String>> pObjFieldAPI, set<Id> pSetPrograms){
        String query;
        system.debug('mergeFields111'+mergeFields);
        //map of object name and related query
        Map<String,list<String>> mapQuery = new Map<String,list<String>>();
        //map of record id, merge field & its value
        map<Id, map<String, String>> mapSObject = new map<Id, map<String, String>>();
        system.debug('pObjFieldAPI$$$$'+pObjFieldAPI);
        for(String objName:pObjFieldAPI.keySet()){
                query = 'SELECT ';
                for(String fieldName : pObjFieldAPI.get(objName)){
                   if(fieldName.contains('.')){
                       String str = fieldName.substringBefore('.');
                       str = str.endsWith('__r')?str.replace('__r','__c'):str;
                       query += (str=='Account'&& objName.contains('Opportunity'))?'AccountId':str;
                       query += ', ';
                   }
                    query += fieldName + ', ';
                }
                query += 'Id';
                if(objName.endsWith('__r'))
                    query += ' FROM ' + objName.replace('__r', '__c');
                else
                    query += ' FROM ' + objName;
                system.debug('000000000'+pSetPrograms);
                if(objName.contains('Program')){
                    for(Id pId : pSetPrograms){
                    system.debug('0000011111'+pId );
                        String pQuery = query + ' WHERE Id =\'' + pId +'\'';
                        if(mapQuery!=null && mapQuery.containskey(objName)){
                            list<string> lstString = mapQuery.get(objName);
                            lstString.add(pQuery);
                            mapQuery.put(objName, lstString);
                        }else{
                            mapQuery.put(objName, new list<String>{pQuery});
                        }                       
                            
                    }
                 }
                if(objName.contains('Opportunity')){
                    query += ' WHERE Id =\'' + oppId +'\'' ;
                    if(mapQuery!=null && mapQuery.containskey(objName)){
                            list<string> lstString = mapQuery.get(objName);
                            lstString.add(query);
                            mapQuery.put(objName, lstString);
                        }else{
                            mapQuery.put(objName, new list<String>{query});
                        }  
                    //mapQuery.put(objName, query);
                }
        }
        system.debug('!!!!!!!!!!!'+mapQuery);
        try{
            for(String key: mapQuery.keyset()){
                for(String q : mapQuery.get(key)){
                    system.debug('11111222222'+q);
                    sObject rec = Database.query(q);
                    map<String, String> innermap;
                    for(String field:mergeFields){
                        system.debug('11133333'+field);
                        if(field.contains('.') && field.substringBefore('.') == key){
                        if(rec != null && mapSObject.containsKey(rec.id)){
                            innermap = mapSObject.get(rec.id);
                            if(field.contains('.'))
                            {
                                String fieldAfter = field.substringAfter('.');
                                if(fieldAfter.contains('.')){
                                    String fieldBefore = fieldAfter.substringBefore('.');
                                    //fieldAfter = fieldAfter.endsWith('__r')?fieldAfter.replace('__r','__c'):fieldAfter;
                                    //Sobject SitEduTestEvent=rec.getSObject(''+fieldBefore+'');
                                    innermap.put(field, getValue(rec.getSObject(''+fieldBefore+''), fieldAfter.substringAfter('.')));
                                    system.debug('XXXXXXXXXXXXXXXX'+innermap);
                                    mapSObject.put(getValue(rec, 'Id'),innermap);
                                }
                                else{
                                   innermap.put(field, getValue(rec, field.substringAfter('.')));
                                   mapSObject.put(getValue(rec, 'Id'),innermap);
                                }
                            }
                        }else{
                            innermap = new  map<String, String>();
                            if(field.contains('.'))
                            {
                                String fieldAfter = field.substringAfter('.');
                                if(fieldAfter.contains('.')){
                                    String fieldBefore = fieldAfter.substringBefore('.');
                                    innermap.put(field, getValue(rec.getSObject(''+fieldBefore+''), fieldAfter.substringAfter('.')));
                                    system.debug('XXXXXXXXXXXXXXXX'+innermap);
                                    mapSObject.put(getValue(rec, 'Id'),innermap);
                                }
                                else{
                                   innermap.put(field, getValue(rec, field.substringAfter('.')));
                                   system.debug('4576890'+rec.get(field.substringAfter('.')));
                                   mapSObject.put(getValue(rec, 'Id'),innermap);
                                }
                            }
                        }
                        }
                    //system.debug('1111111111122222222'+rec.getSObjectType().getDescribe().getChildRelationships().getField('Owner_1__c'));
                    }
                }
            }
        }catch(Exception e){
            if(e.getMessage() != '' && e.getMessage() != null && e.getMessage().contains('Invalid Field')){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Put proper field in email template.'));
            }
        }
        system.debug('55555555555555'+mapSObject);
        return mapSObject;
    }
    private static String getValue(SObject o, String fieldName){
        system.debug('@@@1111555555'+o);
        system.debug('1111555555'+fieldName);
        return (o!= null && o.get(fieldName) != null) ? String.valueOf(o.get(''+fieldName)+'') : '';
}
}