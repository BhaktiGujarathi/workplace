/* 
 *  Description - Parses the merge fields from email template
 *   
 *  Date(dd-mm-yyyy) - 21-12-2015
 *  
 *  Created by - Shraddha P.
 */
public with sharing class EmailTemplateParser {
    set<String> mergeFields = new set<String>();
    map<String, set<String>> objFieldAPI;
    Id oppId;
    public EmailTemplateParser(Id pOppId){
        oppId = pOppId;
    }
    public map<Id, map<String, String>> parseEmailBody(String pEmailBody, String pSubject, set<Id> pSetPrograms){
        system.debug('???????????'+pEmailBody);
        //Map of object and its set of fields
        objFieldAPI = new map<String, set<String>>();
        for(String str: pEmailBody.split('\\{!'))
        {
            system.debug('11111111111'+str);
            if(str.contains('}')){
                String mergeField = str.substringBefore('}');
                
                if(objFieldAPI.containsKey(mergeField.substringBefore('.'))){
                    set<String> setFields = objFieldAPI.get(mergeField.substringBefore('.'));
                    setFields.add(mergeField.substringAfter('.'));
                    objFieldAPI.put(mergeField.substringBefore('.'), setFields);
                    mergeFields.add(mergeField);
                    system.debug('444444444444'+objFieldAPI);
                }else{
                    //set<String> setFields = new set<String>();
                    if(mergeField.substringAfter('.') != '' && mergeField.substringBefore('.') != ''){
                        objFieldAPI.put(mergeField.substringBefore('.'), new set<String>{mergeField.substringAfter('.')});
                        mergeFields.add(mergeField);
                    }
                    system.debug('5555555555555'+objFieldAPI);
                }
            }
        }
        parseEmailSubject(pSubject);
        system.debug('%%%%%%%%%%%'+objFieldAPI);
        DynamicQueryGenerator query = new DynamicQueryGenerator(oppId);
        map<Id, map<String, String>> mapSObject = query.queryBuild(mergeFields, objFieldAPI,pSetPrograms);
        return mapSObject;
    }

    public void parseEmailSubject(String pSubject){
        for(String str: pSubject.split('\\{!'))
        {
            system.debug('11111111111'+str);
            if(str.contains('}')){
                String mergeField = str.substringBefore('}');
                
                if(objFieldAPI.containsKey(mergeField.substringBefore('.'))){
                    set<String> setFields = objFieldAPI.get(mergeField.substringBefore('.'));
                    setFields.add(mergeField.substringAfter('.'));
                    objFieldAPI.put(mergeField.substringBefore('.'), setFields);
                    mergeFields.add(mergeField);
                    system.debug('444444444444'+objFieldAPI);
                }else{
                    //set<String> setFields = new set<String>();
                    if(mergeField.substringAfter('.') != '' && mergeField.substringBefore('.') != ''){
                        objFieldAPI.put(mergeField.substringBefore('.'), new set<String>{mergeField.substringAfter('.')});
                        mergeFields.add(mergeField);
                    }
                    system.debug('5555555555555'+objFieldAPI);
                }
            }
        }
    }
    //replace merge fields
    public String createMessageBody(Program__c program, map<Id, map<String, String>> mapSObject, String pEmailBody, String pSubject){
        system.debug('111111111111'+program);
        for(String s : mergeFields){
        system.debug('DDDDDDDDDDDDDDD'+s+s.substringBefore('.'));
            if(s.substringBefore('.') == 'Program__c' || s.substringBefore('.') == 'Program__r'){
                system.debug('eeeeeeeeee'+pEmailBody+'eeee'+mapSObject);
                system.debug('235678900'+mapSObject.get(program.Id));
                system.debug('3333'+ mapSObject.get(program.Id).containsKey(s));
                if(pEmailBody.contains('{!'+s +'}') && mapSObject.get(program.Id).containsKey(s))
                    pEmailBody = pEmailBody.replace('{!'+s +'}', mapSObject.get(program.Id).get(s));
                if(pSubject.contains('{!'+s +'}') && mapSObject.get(program.Id).containsKey(s))
                    pSubject = pSubject.replace('{!'+s +'}', mapSObject.get(program.Id).get(s));
            }
            else if(s.substringBefore('.') == 'Opportunity'){
                system.debug('6666666666');
                if(pEmailBody.contains('{!'+s +'}') && mapSObject.get(oppId).containsKey(s))
                    pEmailBody = pEmailBody.replace('{!'+s +'}', mapSObject.get(oppId).get(s));
                if(pSubject.contains('{!'+s +'}') && mapSObject.get(oppId).containsKey(s))
                    pSubject = pSubject.replace('{!'+s +'}', mapSObject.get(oppId).get(s));
            }
            else{
                system.debug('7777777777777');
            }
        }
        system.debug('22233333'+pEmailBody+'11111'+pSubject);
        return pEmailBody + '######' + pSubject;
    }
}