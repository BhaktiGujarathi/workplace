public with sharing class PaymentsProcessFieldMappingController {

    public static final Map<Integer,String> COLUMN_INDEX = new Map<Integer,String>{ 1 => 'A',2 => 'B',3 => 'C',4 => 'D',5 => 'E',6 => 'F',7 => 'G',8 => 'H',9 => 'I',10 => 'J',11 => 'K',12 => 'L',13 => 'M',14 => 'N',15 => 'O',16 => 'P',17 => 'Q',18 => 'R',19 => 'S',20 => 'T',21 => 'U',22 => 'V',23 => 'W',24 => 'X',25 => 'Y',26 => 'Z' } ;

    public MappingsWrapper[] mappings { get; set; }
    public Processor_Integration__c processorIntegration { get; set; }
    public Boolean editMode { get; set; }
    public String idDeleteMapping { get; set; }
    
    private final static String OBJECT_NAME = 'Payment__c';
    
    
    public PaymentsProcessFieldMappingController() {
        mappings = new MappingsWrapper[]{};
        editMode = false;
    }
    
    
    public PageReference init() {
        queryProcessorIntegration();
        if (processorIntegration == null) {
            return  new PageReference('/a0g');
        }
        queryMappings();
        return null;
    }
    
    
    public void addNewFieldMapping() {
    	Processor_Field_Mapping__c entity = new Processor_Field_Mapping__c();
    	entity.Processor_Name__c = processorIntegration.Id;
        MappingsWrapper newEntity = new MappingsWrapper(entity);
        newEntity.edit = true;
        mappings.add(newEntity);
        editMode = true;
    }
    
    
    public void editFieldMapping() {
    	editMode = true;
        for (MappingsWrapper e : mappings) {
            e.edit = true;
        }
    }
    

    public void deleteFieldMapping() {
    	delete [SELECT Id FROM Processor_Field_Mapping__c WHERE Id = : idDeleteMapping];
        mappings = new MappingsWrapper[]{};
        editMode = false;
        queryMappings();
    }
    
    
    public void save() {
        Processor_Field_Mapping__c [] updateMappings = new Processor_Field_Mapping__c[]{};
        for (MappingsWrapper mw : mappings) {
        	if (mw.edit) {
	         	if (mw.columnIndex > 0) {
		            mw.mapping.Index__c = mw.columnIndex;
		            mw.mapping.Field_Name__c = mw.fieldName;
		            mw.mapping.Field_Label__c = mw.fieldLabel;
		            mw.edit = false;
		            updateMappings.add(mw.mapping);
	        	}
	        	else {
	        		mw.error = true;
	        		editMode = true;
	        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'There was an error saving your mapping. Please review'));
	        	}
        	}
        }
        if (!updateMappings.isEmpty()) {
        	editMode = false;
            upsert updateMappings;
            mappings = new MappingsWrapper[]{};
            queryMappings();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Schema mapping saved correctly'));
        }
    }
    
    
    public void cancel() {
    	for (MappingsWrapper e : mappings) {
    		e.edit = false;
    	}
    	mappings = new MappingsWrapper[]{};
    	queryMappings();
    	editMode = false;
    }
    
    
    public void queryProcessorIntegration() {
        for (Processor_Integration__c pi : [SELECT Id 
                                                 , Name
                                            FROM Processor_Integration__c 
                                            WHERE Id = :ApexPages.currentPage().getParameters().get('id')]) {
            processorIntegration = pi;
        }
    }
    
    
    public void queryMappings() {
        for (Processor_Field_Mapping__c e : [SELECT Id
                                                  , Index__c
                                                  , Field_Name__c
                                                  , Field_Label__c
                                                  , Processor_Name__c 
                                                  , Index_Field_Label__c
                                             FROM Processor_Field_Mapping__c
                                             WHERE Processor_Name__c = :processorIntegration.Id])  {
            mappings.add(new MappingsWrapper(e));
        }
    }
    
    
    public class MappingsWrapper {
        public Processor_Field_Mapping__c mapping { get; set; }
        public Integer columnIndex { get; set; }
        public String fieldName { get; set; }
        public String fieldLabel { get; set; }
        public String processorsName { get; set; }
        public Boolean edit { get; set; }
        public Boolean error { get; set; }
        public Boolean selected { get; set; }

        
        public MappingsWrapper(Processor_Field_Mapping__c mapping) {
            this.mapping = mapping;
            columnIndex = Integer.valueOf(mapping.Index__c);
            fieldName = mapping.Field_Name__c;
            if (mapping.Field_Name__c != null) {
            	fieldLabel = getLabel(mapping.Field_Name__c);
            }
            processorsName = mapping.Processor_Name__c;
            error = false;
            edit = false;
        }
        
        private String getLabel(String fieldName) {
        	Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(OBJECT_NAME).getDescribe().fields.getMap();
            
            for (Schema.SObjectField sField : fieldMap.Values()) {
                Schema.DescribeFieldResult field = sField.getDescribe();
                if ((field.getType() != Schema.DisplayType.Address) && field.getName() == fieldName) {
                    return field.getLabel();
                }
            }
            return '';
        }
        
        public SelectOption[] getObjectFields() {
            SelectOption[] options = new SelectOption[]{ };
            options.add(new SelectOption('', '--None--'));
            
            /*options.add(new SelectOption('Name', 'Payment Setup Name'));
            options.add(new SelectOption('Holdback__c', 'Holback (%)'));
            options.add(new SelectOption('Total_RePayment__c', 'Total Repayment'));
            options.add(new SelectOption('Merchant_Id__c', 'Merchant Id'));
            */
            
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(OBJECT_NAME).getDescribe().fields.getMap();   
            for (Schema.SObjectField sField : fieldMap.Values()) {
                Schema.DescribeFieldResult relatedField = sField.getDescribe();
                if (relatedField.isCustom() && relatedField.isAccessible() && (relatedField.getType() != Schema.DisplayType.Address)) {
                   options.add(new SelectOption(relatedField.getName(), relatedField.getLabel()));
                }
            } 
            options.sort();
            return options;
        }
        
        
        public String getColumnIndexLetter() {
            if (COLUMN_INDEX.containsKey(columnIndex)) {
                return COLUMN_INDEX.get(columnIndex);
            }
            return '';
        }
    }
}