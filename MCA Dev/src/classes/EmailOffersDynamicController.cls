/**
**  Version     Author          Date(dd/mm/yyyy)        Description
**  1.0         Merul S         21/01/2017              Initial Draft[]
**  1.1         Ajinkya H       23/03/2017              Get Field Set from Custom Setting
**
*/

public with sharing class EmailOffersDynamicController {

    public List<Offer__c> offers;
    public FO_Email_Settings__c emailOfferCstmStngFieldSet;
    public List<Schema.FieldSetMember> offrFieldsetList     {get; set;}
    public Id OpportunityId                                 {get;set;}

    //Constructor
    public EmailOffersDynamicController() {
        offers = new List<Offer__c>();
        offrFieldsetList = new List<Schema.FieldSetMember>();
        //offrFieldsetList = SObjectType.Offer__c.FieldSets.EmailOffers.getFields();
    }

    /**
     * Getter for offers
    */
    public List<Offer__c> getoffers() {
        List<schema.fieldSetMember> offerFieldsFromFieldSet = getOfferFieldSetList();
        String query = 'SELECT ';
        for(Schema.FieldSetMember fieldAPI : offerFieldsFromFieldSet) {
            if(fieldAPI.getFieldPath() != 'Id') {
                query += fieldAPI.getFieldPath() + ', ';
            }
        }
        query += 'Id '
                + ' FROM Offer__c Where Opportunity__c =:OpportunityId '
                + ' AND Send__c = true';
        offers = Database.query(query);
        return offers;
    }

    /**
     * To get fields from field set and field set name is stored in custom setting
     */
    private List<schema.fieldSetMember> getOfferFieldSetList() {
        emailOfferCstmStngFieldSet = FO_Email_Settings__c.getValues('Email Offers');
        schema.FieldSet offerFieldSet;
        if(emailOfferCstmStngFieldSet.Object_API_Name_for_Field_Set__c == 'Offer__c') {
            offerFieldSet = Schema.getGlobalDescribe().
                    get(emailOfferCstmStngFieldSet.Object_API_Name_for_Field_Set__c)
                    .getDescribe().FieldSets.getMap()
                    .get(emailOfferCstmStngFieldSet.Field_Set_API_Name__c);
            if(offerFieldSet != null) {
                offrFieldsetList = offerFieldSet.getFields();
            }
        }
        return offrFieldsetList;
    }
}