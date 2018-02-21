/**************************************************************************************************
* Name               : ManageCustomSettingsController                                                 
* Description        : Allow users to configure the Custom setting values                                             
* Created Date       : NSI - Sivasankar                                                                        
* Created By         : 21/Mar/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Sivasankar          21/Mar/2017                                                               
***************************************************************************************************/
public without sharing class ManageCustomSettingsController {
	
    static MetadataService.MetadataPort service = MetadataUtil.getPort();
    private List<Configure_Console__mdt> lstConfigureMetaData;
    public String selectConfigureType {get;set;}
    public String selectedObject {get; set;}
    public String selectedObjectLabel {get; set;}
    public List<FieldWrapper> listField{get;set;}
    public List<SObject> listCustomSettingRecords {get;set;}
    public List<SelectOption> listCustomSettingNames {get;set;}
    public List<MetadataService.CustomLabel> listCustomLabels {get;set;}
    public String mapKeyValues {get;set;}
    public Map<String,List<CustomSettingFieldValues>> mapcustomSettingRecordsWrapper{get;set;}
	public Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	public List<CustomSettingWarpper> listCustomSettingWarpper {get;set;}
	
    public List<CustomLabelsWrapper> listCustomLabelsWrapper {get;set;}
    @TestVisible private static String accessTokenofAdmin = Test.isRunningTest() ? '234532144' : UtilityHelperCls.AcessToken();


    public ManageCustomSettingsController() 
    {	
    	selectConfigureType = 'CustomSettings';
        lstConfigureMetaData = new List<Configure_Console__mdt>([SELECT Value__c,MasterLabel FROM Configure_Console__mdt]);
        listField = new List<FieldWrapper>();
        listCustomSettingRecords = new List<SObject>();
        mapKeyValues = '';
        listCustomSettingWarpper = new List<CustomSettingWarpper>();
        mapcustomSettingRecordsWrapper = new Map<String,List<CustomSettingFieldValues>>();
        listCustomLabels = new List<MetadataService.CustomLabel>();
        listCustomSettingNames = new List<SelectOption>();
        listCustomLabelsWrapper = new List<CustomLabelsWrapper>();
        
        getselectedConfigures();
    }

    public void getselectedConfigures(){
        listCustomSettingNames.clear();
        if(String.isNotBlank(selectConfigureType) && selectConfigureType.containsIgnoreCase('CustomSettings')){
            listCustomSettingNames = getListObejectName();
            listCustomLabels.clear();
            listCustomLabelsWrapper.clear();
        }
        else if(String.isNotBlank(selectConfigureType) && selectConfigureType.containsIgnoreCase('CustomLabels')){
            listField.clear();
            listCustomSettingRecords.clear();
            mapcustomSettingRecordsWrapper.clear();
            //listCustomSettingWarpper.clear();
            listCustomSettingWarpper = new List<CustomSettingWarpper>();

            getcustomLabes();
        }
    }

    public void getcustomLabes(){
        listCustomLabels.clear();
        listCustomLabelsWrapper.clear();
        List<MetadataService.CustomLabel> testcustmlabels = new List<MetadataService.CustomLabel>();
         // Retrieve the custom object metadata
        System.debug('accessTokenofAdmin = '+accessTokenofAdmin);
        service.sessionHeader.sessionId = accessTokenofAdmin;
        String[] configureLabels = new List<String>();
        if(String.isNotBlank(Label.Custom_Labels_to_be_Configured))
            configureLabels = Label.Custom_Labels_to_be_Configured.split(',');
        if(Test.isRunningTest()){
        	MetadataService.CustomLabel lab = new MetadataService.CustomLabel();
        	lab.fullName = 'Activity_Band_Size';
        	lab.categories = 'Inquiry';
        	lab.language ='US_en';
        	lab.shortDescription = 'Test'; 
        	lab.value = '10';
        	testcustmlabels.add(lab);
        }
        if(configureLabels != null && configureLabels.size() > 0)    
        for ( MetadataService.CustomLabel customLabel: Test.isRunningTest() ? testcustmlabels : (List<MetadataService.CustomLabel>) service.readMetadata('CustomLabel',configureLabels).getRecords() ){//new String[] { 'Activity_Band_Size','Performance_Band_Size','Max_Activities','Max_Inquiries'}
            listCustomLabels.add(customLabel);
            CustomLabelsWrapper clw = new CustomLabelsWrapper();
            clw.labelName = customLabel.fullName;
            clw.labelCategory = customLabel.categories;
            clw.labelDescription = customLabel.shortDescription;
            clw.labelValue = customLabel.value;
            listCustomLabelsWrapper.add(clw);
        }
        System.debug('listCustomLabelsWrapper = '+listCustomLabelsWrapper);
    }

    // find all sObjects available in the organization
    public  List<SelectOption> getListObejectName() 
    {
        List<SelectOption> objNames = new List<SelectOption>();
        List<String> entities = new List<String>(schemaMap.keySet());
        entities.sort();
        //for(String name : entities)
        for (Configure_Console__mdt configureData : lstConfigureMetaData)
            objNames.add(new SelectOption(configureData.Value__c,configureData.MasterLabel));
        	//if(name.endsWith('__c') && !name.equalsIgnoreCase('Inquiry__c') && (name.containsIgnoreCase('Inquiry_') || name.containsIgnoreCase('Inquire')))
            //	objNames.add(new SelectOption(name,name.replace('__c','').replace('_',' ')));
        System.debug('objNames = '+objNames);
        if(!objNames.isEmpty()){
            selectedObject = objNames[0].getValue();
            selectedObjectLabel = objNames[0].getLabel().toUpperCase();
            showCustomSettingValues();
        }
        return objNames;
    }

    
    // Find the fields for the selected object
    public void showCustomSettingValues() 
    {
        try{
            listField.clear();
            listCustomSettingRecords.clear();
            mapcustomSettingRecordsWrapper.clear();
            //listCustomSettingWarpper.clear();
            listCustomSettingWarpper = new List<CustomSettingWarpper>();
            String queryString = '';
            mapKeyValues = '';
            selectedObjectLabel = selectedObject.replace('__c','').replace('_',' ').toUpperCase();
            List<CustomSettingFieldValues> lstCustomSettingRecordValues = new List<CustomSettingFieldValues>();
            // Convert to schema.sObjectType
    		//Schema.SObjectType convertType = Schema.getGlobalDescribe().get(selectedObject);
    		System.debug('selectedObject = '+selectedObject);	
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(selectedObject).getDescribe().fields.getMap();
            for(Schema.SObjectField sfield : fieldMap.Values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                if(dfield.getname().endsWith('__c')){
    	            FieldWrapper wObj = new FieldWrapper();
    	            wObj.fieldName = dfield.getLabel ();
    	            wObj.fieldAPIName = dfield.getname();
    	            queryString += dfield.getname()+',';
    	            listField.add(wObj);
                }
            }
            queryString = 'SELECT Id,'+queryString+'Name FROM '+selectedObject;
            System.debug('queryString = '+queryString);
            for(SObject customSetting : Database.query(queryString)){
            	listCustomSettingRecords.add(customSetting);
            	
            	CustomSettingWarpper custWrapper = new CustomSettingWarpper();
            	
            	lstCustomSettingRecordValues = new List<CustomSettingFieldValues>();
            	custWrapper.reocrdID = (String)customSetting.get('Id');
            	
            	CustomSettingFieldValues custSettFieldValues = new CustomSettingFieldValues();
        		custSettFieldValues.fieldLabel = 'Name';
        		custSettFieldValues.fieldAPIName = 'Name';
        		custSettFieldValues.fieldValue = (String)customSetting.get('Name');
        		lstCustomSettingRecordValues.add(custSettFieldValues);
        		
            	for(FieldWrapper fW : listField){
            		CustomSettingFieldValues csFieldValues = new CustomSettingFieldValues();
            		csFieldValues.fieldLabel = fW.fieldName;
            		csFieldValues.fieldAPIName = fW.fieldAPIName;
            		csFieldValues.fieldValue = String.valueOf(customSetting.get(fW.fieldAPIName));
            		lstCustomSettingRecordValues.add(csFieldValues);
            	}
            	
            	custWrapper.listFields = lstCustomSettingRecordValues;
            	listCustomSettingWarpper.add(custWrapper);
            	
            	if(!lstCustomSettingRecordValues.isEmpty() && lstCustomSettingRecordValues.size() > 0){
            		mapcustomSettingRecordsWrapper.put((String)customSetting.get('Id'),lstCustomSettingRecordValues);
            		mapKeyValues += (String.isNotBlank(mapKeyValues) ? ',' : '')+(String)customSetting.get('Id');
            	}
            }
            System.debug('listCustomSettingRecords = '+mapcustomSettingRecordsWrapper);
        }Catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error at '+ex.getLineNumber()+' is '+ex.getMessage()));
        }
    }
    
    public void saveCustomSettings(){
    	try{
            System.debug('selectConfigureType = '+selectConfigureType);
    		System.debug('listCustomSettingWarpper = '+listCustomSettingWarpper);
            System.debug('listCustomLabels = '+listCustomLabels);
            //selectConfigureType = 'CustomSettings';
            if(String.isNotBlank(selectConfigureType) && selectConfigureType.equalsIgnoreCase('CustomSettings')){
        		List<SObject> lstToUpdate = new List<SObject>();
        		Schema.SObjectType convertType = Schema.getGlobalDescribe().get(selectedObject);// Convert to schema.sObjectType
        		Sobject genericObject = convertType.newSObject();// Create an instance of that type
        		
    	    	for (CustomSettingWarpper csRecordId : listCustomSettingWarpper){
    	    		genericObject = convertType.newSObject();
    	    		genericObject.put('Id',csRecordId.reocrdID);
    	    		
    	    		for(CustomSettingFieldValues fieldValues :csRecordId.listFields ){
    	    			if(fieldValues.fieldValue == 'false' || fieldValues.fieldValue == 'true')
    	    				genericObject.put(fieldValues.fieldAPIName,(fieldValues.fieldValue == 'true' ? true:false) );
    	    			else
    	    				genericObject.put(fieldValues.fieldAPIName,fieldValues.fieldValue);
    	    		}
    	    		lstToUpdate.add(genericObject);
    	    	}
    	    	System.debug('lstToUpdate = '+lstToUpdate);
    	    	if(!lstToUpdate.isEmpty()){
    	    		Database.SaveResult[] res = Database.update(lstToUpdate,true);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Records are updated successfully.'));
    	    	}
            } 
            else if(String.isNotBlank(selectConfigureType) && selectConfigureType.containsIgnoreCase('CustomLabels') 
                && listCustomLabels != null && listCustomLabels.size() > 0){
                for(MetadataService.CustomLabel customLabel : listCustomLabels){
                    for( CustomLabelsWrapper wrapper : listCustomLabelsWrapper ){
                        if(wrapper.labelName == customLabel.fullName){
                            customLabel.value = wrapper.labelValue;
                            break;
                        }
                    }
                }
                System.debug('accessTokenofAdmin = '+accessTokenofAdmin);
                service.sessionHeader.sessionId = accessTokenofAdmin;
                if(!Test.isRunningTest())
                	List<MetadataService.SaveResult> results = service.updateMetadata(listCustomLabels);// new MetadataService.Metadata[] { customObject }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Records are updated successfully.'));
            }
    	}Catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error at '+ex.getLineNumber()+' is '+ex.getMessage()));
    	}
    }

    public class FieldWrapper
    {
        public String fieldName {get; set;}
        public String fieldAPIName {get; set;}
    }
    
    public class CustomSettingWarpper {
    	public String reocrdID {get;set;}
    	public List<CustomSettingFieldValues> listFields {get;set;}
    }
    
    public class CustomSettingFieldValues {
    	public String fieldLabel {get;set;}
    	public String fieldAPIName {get;set;}
    	public String fieldValue {get;set;}
    }

    public class CustomLabelsWrapper {
        public String labelName {get;set;}
        public String labelCategory {get;set;}
        public String labelDescription {get;set;}
        public String labelValue {get;set;}
    }   
}