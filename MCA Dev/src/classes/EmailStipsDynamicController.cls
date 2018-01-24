/**
 *  Version     Author          Date(DD/MM/YYYY)        Description
 *  1.0                                                 Initial Draft[]
 *  1.1         Ajinkya H       23/03/2017              Get Field Set from Custom Setting
*/
public with sharing class EmailStipsDynamicController {
    public List<Stips__c> stips;
    public FO_Email_Settings__c emailStipCstmStngFieldSet;
    public Id OpportunityId                                 {get;set;}
    public List<schema.fieldSetMember> listSipsFieldSet     {get;set;}

    //Constructor
    public EmailStipsDynamicController() {
        listSipsFieldSet = new List<schema.FieldSetMember>();
        stips = new List<Stips__c>();
    }

    /**
     * To get Stips field data in Query which is used in send email functionality.
     */
    public List<Stips__c> getStips() {
        List<schema.fieldSetMember> stipFieldsFromFieldSet = getStipFieldSetList();
        String Query;
        Query = 'SELECT ';
        for(Schema.FieldSetMember stipsField : stipFieldsFromFieldSet) {
            if(stipsField.getFieldPath() != 'Id') {
                query += stipsField.getFieldPath() + ', ';
            }
        }
        String whereCondition = '';
        Map<String,Schema.SObjectField>  fieldsMap=  sObjectType.Stips__c.fields.getMap();
        if(fieldsMap.containsKey(System.Label.FO_Email_Stip_Checkbox_API_Name)) {
            whereCondition =  ' AND '+System.Label.FO_Email_Stip_Checkbox_API_Name+' = true';
        }
        Query += ' Id FROM Stips__c WHERE Opportunity__c =:OpportunityId '
              + whereCondition;
        stips = database.query(Query);
        return stips;
    }

    /**
     * To get fields from field set and field set name is stored in custom setting
     */
    private List<schema.fieldSetMember> getStipFieldSetList() {
        emailStipCstmStngFieldSet = FO_Email_Settings__c.getValues('Email Stips');
        schema.FieldSet stipFieldSet;
        if(emailStipCstmStngFieldSet.Object_API_Name_for_Field_Set__c == 'Stips__c') {
            stipFieldSet = Schema.getGlobalDescribe().
                    get(emailStipCstmStngFieldSet.Object_API_Name_for_Field_Set__c)
                    .getDescribe().FieldSets.getMap()
                    .get(emailStipCstmStngFieldSet.Field_Set_API_Name__c);
            if(stipFieldSet != null) {
                listSipsFieldSet = stipFieldSet.getFields();
            }
        }
        return listSipsFieldSet;
    }
}