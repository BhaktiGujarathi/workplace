public class myPaymentsController {
    public Id personAccountId{get; set{
            personAccountId = value;  
            
            
            system.debug('\n value is :- '+ value);  
                        system.debug('\n personAccountId is :- '+ personAccountId );
            BookingUnitList();
        }}
    public List<Booking_Unit__c> bookingUnitList {get;set;}
    public List<String> fieldLabels {get;set;}
    public List<String> fieldNames {get;set;}
    
    public myPaymentsController () {
        bookingUnitList = new List<Booking_Unit__c>();
        fieldLabels = new List<String>();
        fieldNames = new List<String>();
        //bookingUnitList();
        FieldLabels();
        FieldNames();
    }
    public void bookingUnitList() {
        bookingUnitList = new List<Booking_Unit__c>();
        String paymentTermFields = '';
        for(Schema.FieldSetMember fieldMember : Schema.SObjectType.Payment_Terms__c.fieldSets.My_Payment_FieldSet.getFields()) {
            if(paymentTermFields != '')
                paymentTermFields += ',';
            paymentTermFields += fieldMember.getFieldPath();
        }
        String query = 'SELECT Name, (SELECT ' + paymentTermFields + ' FROM Payment_Terms_del__r) FROM Booking_Unit__c WHERE Booking__c IN (SELECT Id FROM Booking__c WHERE Account__c = :personAccountId)';
        bookingUnitList = (List<Booking_Unit__c>)Database.query(query);
        //return bookingUnitList;
    }
    public void FieldLabels() {
        List<String> fieldLabelList = new List<String>();
        for(Schema.FieldSetMember fieldMember : Schema.SObjectType.Payment_Terms__c.fieldSets.My_Payment_FieldSet.getFields()) 
            fieldLabelList.add(fieldMember.getLabel());
        //return fieldLabelList;
    }
    public void FieldNames() {
        List<String> fieldNameList = new List<String>();
        for(Schema.FieldSetMember fieldMember : Schema.SObjectType.Payment_Terms__c.fieldSets.My_Payment_FieldSet.getFields()) 
            fieldNameList.add(fieldMember.getFieldPath());
        //return fieldNameList;
    }
}