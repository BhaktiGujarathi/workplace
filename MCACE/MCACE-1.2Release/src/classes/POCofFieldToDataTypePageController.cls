public with sharing class POCofFieldToDataTypePageController {
     public Map<String, Schema.SObjectType> mapObjectToType = Schema.getGlobalDescribe(); 
     public List<SelectOption> fieldList;
     public String selectedField {get; set;}
     public String dataType {get; set;}
     public Sobject opportunityObj {get; set;}
     public String fieldType {get; set;}
     public Boolean fieldFlag {get; set;}
     public String operator {get; set;}
     
     public POCofFieldToDataTypePageController() {
         fieldList = new List<SelectOption>();
         fieldFlag = false;
         opportunityObj = mapObjectToType.get('Opportunity').newSobject();
     }
     
     public List<SelectOption> getFieldList() {
         fieldList.clear();
         for(String field : mapObjectToType.get('opportunity').getDescribe().fields.getMap().keyset()){   
            fieldList.add(new selectOption(field , field));
         }
         return  fieldList;
     }
     public void getdatatype() {
         fieldFlag = true;
         
     }
     
     public void save() {
         MCACE__Commission_Rule_Entry__c ruleEntryObj = new MCACE__Commission_Rule_Entry__c();
         ruleEntryObj.MCACE__Commission_Rule__c = 'a0U370000002Bfx';
         ruleEntryObj.Name = 'abc';
         ruleEntryObj.MCACE__Field_API__c = ''+selectedField;
         ruleEntryObj.MCACE__Operator__c = ''+operator;
         ruleEntryObj.MCACE__Text__c = ''+opportunityObj.get(selectedField);
         system.debug('>>>'+ruleEntryObj);
         insert ruleEntryObj;
     }
     
}