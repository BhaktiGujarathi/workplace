/* 
*  Apex controller for Dynamic FundingApplication Page using Field sets.
*  Revision History: 
* 
*  Version           Author                 Date                 Description 
*  1.0               Ripal Patel            7-July 2015           Initial Draft 
*  Version           Author                 Date                 Description 
*  2.0               Yogesh Mahajan        8-Dec 2015           Remove combination key logic and picklist 
                                                                    to select the contact
*  2.1               Yogesh Mahajan        10-Dec 2015          Added validation for static field
*  2.2               Yogesh Mahajan        1-Jan-2016           Added logic for field set map creation and
                                                                table structure into page. 
*/
public with sharing class FundingApplicationController{ 
    // Constant variable
    private static final String OPPORTUNIY_NAME = 'Opportunity';
    private static final String CUSTOM_SETTING_SEEROR = 'Please Add Custom Setting';
    private static final String CUSTOM_SETTING_ValEEROR = 'Blank / NULL Custom Setting field (Field Name : Number of Column) Not Allowed';
    private static final String CUSTOM_SETTING_FIELDSET = 'FieldSet Name is Invalid';
    private static final String CUSTOM_SETTING_CONTACT = 'Contact API Name is Invalid';
    private static final String SAVE_MSG = 'Records has been Save Successfully.';
    private static final String EMAIL_PDF = 'Email PDF';
    private static final String CREATE_PDF = 'Create PDF';
    private static final String FAX_PDF = 'Fax PDF';
    private static final String DOCUSIGN_PDF = 'Docusign';
    private static final String ROW_PER_COLUMN_ERROR = 'The number of columns must be between 3 and 6';
    private static final String BASE_URL = '/apex/mcaextension1__Funding_Application_Tab?id=';
    // Parameter string names
    private static final String OPPOTUNITY_PARAM = 'id';
    private static final String ACCOUNT_PARAM = 'accId';
    private static final String NEWAPP_PARAM = 'newApplication';
    private static final String ACC_NAME = 'accountName';
    private static final String RETURN_URLVAL = 'rURL';
    
    // Store parameter values
    private String AccId;
    private String oppId;
    private String isNewApplication;
    private String accName;
    private String return_URL;
    
    //Boolean flag for error
    public Boolean isError;
    public Boolean isNewRunSave;
    
    //Variables of opp account and contact for upsert
    private Opportunity oppToUpsert;
    private Account accountToUpsert;
    private List<MCAExtension1__Dynamic_Sections__c> listDynamicSection;
    private List<Schema.FieldSetMember> listFieldMember;
    private Map<String, Contact> mapStringAndCon;
    // Dynamic Query class 
    FundingApplicationUtility fundingApplicationUtility;
    
    // get set variables 
    public List<PageSectionData> listofPageData     {get;set;}
    public Opportunity opportunity                  {get;set;}
    public Integer paramValue                       {get;set;}
    public CongaButtonUrl__c createPDF              {get;set;}
    public CongaButtonUrl__c emailPDF               {get;set;}
    public CongaButtonUrl__c faxPDF                 {get;set;}
    public CongaButtonUrl__c docusign               {get;set;}
    public Boolean showBackOpp                      {get;set;}
    
    public FundingApplicationController() {
        //String hostVal  = ApexPages.currentPage().getHeaders().get('Host');
        emailPDF = CongaButtonUrl__c.getInstance(EMAIL_PDF);
        createPDF = CongaButtonUrl__c.getInstance(CREATE_PDF);
        faxPDF = CongaButtonUrl__c.getInstance(FAX_PDF);
        docusign = CongaButtonUrl__c.getInstance(DOCUSIGN_PDF);
        oppId = ApexPages.currentPage().getParameters().get(OPPOTUNITY_PARAM);
        accId = ApexPages.currentPage().getParameters().get(ACCOUNT_PARAM);
        isNewApplication = ApexPages.currentPage().getParameters().get(NEWAPP_PARAM);
        accName = ApexPages.currentPage().getParameters().get(ACC_NAME);
        isNewRunSave = false;
        if(isNewApplication.contains('true'))
            isNewRunSave = true;
        opportunity = getOppValue();
        accountToUpsert = new Account();
        oppToUpsert = new Opportunity();
        mapStringAndCon = new Map<String, Contact>();
        listFieldMember = new List<Schema.FieldSetMember>();
        showBackOpp = true;
        getCustomSettingVal();
    }// end DemoFundingApplicationController()
    
    // cancel button action
    public PageReference cancel(){
        
        /*String hostVal  = ApexPages.currentPage().getHeaders().get('Host');
        String urlVal = Apexpages.currentPage().getUrl();
        String URLL = 'https://' + hostVal+ urlVal;
        System.debug('---URLL-->'+URLL);*/
        return_URL = ApexPages.currentPage().getParameters().get(RETURN_URLVAL);
        if(isNewRunSave 
            && return_URL != ''){
                return new PageReference(EncodingUtil.urlDecode(return_URL, 'UTF-8'));
        }
        return new PageReference('/'+OppId);
        
        
    }// end cancel
    
    // quick save action
    public PageReference quickSave(){
        List<Schema.FieldSetMember> listFieldSetMem = new List<Schema.FieldSetMember>();
        isError = false;
        // get all wrapper data for procress  
        for(PageSectionData pageSectionData :listofPageData) {
            listFieldSetMem.clear();
            
            // iterate fieldset
            for(Integer mapKey :pageSectionData.mapFieldMember.keySet()) {
                listFieldSetMem.addAll(pageSectionData.mapFieldMember.get(mapKey));
            }//end for
            
            if(pageSectionData.listFieldMember <> null && pageSectionData.listFieldMember.size() > 0)
                listFieldSetMem.addAll(pageSectionData.listFieldMember);
            
            if (listFieldSetMem.size() > 0)
                assignValue(listFieldSetMem, 
                            pageSectionData.oppFieldValue, 
                            pageSectionData.selectedContact, 
                            pageSectionData.ownerValue);
        }// End for
        
         
        // Add account id
        if(accId != null && accId != '')
            accountToUpsert.id = accId;
        
        try{
            // upsert account
            if(accountToUpsert != null && accountToUpsert <> new Account())
                upsert accountToUpsert;
        }catch (Exception ex) {
            isError = true;
            //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage()));
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, McaApp.MCAExceptionHandlerUtility.getErrorMessage(ex)));
        }//End try -catch
        
        // list to contact to upsert
        List<Contact> listConToUpsert = new List<Contact>();
        Contact objContact = new Contact();
        
        for(String keyVal :mapStringAndCon.keySet()) {
            if(mapStringAndCon.get(keyVal) <>  null 
                && mapStringAndCon.get(keyVal) <> new Contact()){
                objContact = mapStringAndCon.get(keyVal);
                if(accountToUpsert <> null)
                    objContact.put('AccountId', accountToUpsert.id);
                listConToUpsert.add(objContact);
            }//End If
        }//end For
        
        try{
            if (listConToUpsert.size() > 0)
                upsert listConToUpsert;
        }catch (Exception ex) {
            isError = true;
            //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage()));
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, McaApp.MCAExceptionHandlerUtility.getErrorMessage(ex)));
        }//End try -catch
        
        Integer count = 0;
        for(String keyVal :mapStringAndCon.keySet()) {
            if(mapStringAndCon.get(keyVal) <>  null 
                && mapStringAndCon.get(keyVal) <> new Contact() 
                && listConToUpsert[count].id <> null){
                    oppToUpsert.put(keyVal.replace('__r','__c'), listConToUpsert[count].id);
                    count++;
            }//End If
        }//End For 
        
        // Assign account lookup
        if(accountToUpsert <> null && accountToUpsert.id <> null)
            oppToUpsert.AccountId = accountToUpsert.id;
        
        //assign oppotunity id
        if(oppId <> null && oppId != '')
            oppToUpsert.id = oppId;
        try{
            if(oppToUpsert <> null && oppToUpsert <> new Opportunity())
                upsert oppToUpsert;
        }catch (Exception ex) {
            isError = true;
            //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage()));
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, McaApp.MCAExceptionHandlerUtility.getErrorMessage(ex)));
        }//End try -catch
        if(oppToUpsert <> null)
            oppId = oppToUpsert.id;
        if(!isError && isNewApplication.contains('true') 
            && isNewRunSave) {
            isNewRunSave = true;
            return new PageReference(BASE_URL+oppId+'&accId='+checkNull(accId)+'&newApplication='+false+'&accountName='+checkNull(accName)+'&rURL='+checkNull(return_URL));
        }
        if(!isError)
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, SAVE_MSG));
        
        return null;
    }// end quickSave
    
    // Check null then send bank values
    public string checkNull(String strValue) {
        return strValue == null ? '' : strValue;
    }//end checkNull()
    // save action
    public PageReference save(){
        try {
            this.quickSave();
            
            PageReference pageRef = new PageReference('/'+oppId);
            pageRef.setRedirect(true);
            
            if(!isError)
                return pageRef;
            else
                return null;
        } catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, McaApp.MCAExceptionHandlerUtility.getErrorMessage(e)));
            //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'Got An Error'+e.getMessage()));
            return null;    
        }// end try - catch
    }// end save
    
    // create map for sections 
    public Map<Integer, List<Schema.FieldSetMember>> createSectionMap(List<Schema.FieldSetMember> listFields, 
                                                                        Integer noRecords, Boolean isContact) {
        Integer mapKey = 1, count = 0;
        //noRecords++;
        listFieldMember = new List<Schema.FieldSetMember>();
        // add field set member into the static section of list
        if(isContact && listFields <> null) {
            Integer forCount = 0, removeCount = 0;
            List<Schema.FieldSetMember> lstRemainingField = new List<Schema.FieldSetMember>();
            lstRemainingField.addAll(listFields);
            for(Schema.FieldSetMember businessField :listFields) {
                if(forCount < noRecords-3) {
                    listFieldMember.add(businessField);
                    lstRemainingField.remove(0);
                    system.debug('lstRemainingField -->'+lstRemainingField);
                    forCount++;
                } else
                    break;
            }// end for
            listFields = new List<Schema.FieldSetMember>();
            if(lstRemainingField <> null && lstRemainingField.size() > 0)
            listFields.addAll(lstRemainingField);
        }//end if
        
        
        
        Map<Integer, List<Schema.FieldSetMember>> mapSectionFields = 
            new Map<Integer, List<Schema.FieldSetMember>>();
        // Fields iteration
        for(Schema.FieldSetMember businessField :listFields) {
            if(count < noRecords && mapSectionFields.get(mapKey) == null) {
                mapSectionFields.put(mapKey, new List<Schema.FieldSetMember>{businessField});
            } else if(count < noRecords ) {
                mapSectionFields.get(mapKey).add(businessField); 
            }//End else - if
            count++;
            if(count >= noRecords) {
                count = 0;
                mapKey++;
            }// end if
        }// End For
        return mapSectionFields;
    }// End createSectionMap()
    
    // get custom setting value and add into page data wrapper
    public void getCustomSettingVal() {
        // Instance of Dynamic Query class 
        fundingApplicationUtility = new FundingApplicationUtility();
        listofPageData = new List<PageSectionData>();
        PageSectionData pageSectionData;
        String query, conId;
        Integer index = 0;
        List<Schema.FieldSetMember> listFields;
        // get all list of custom setting record.
        listDynamicSection = [SELECT id,
                                    Field_Set_API_Name__c,
                                    Header_Name__c,
                                    Number_of_Column__c,
                                    Object_Type__c,
                                    Oppotunity_Contact_API_Name__c,
                                    Sort__c
                            FROM MCAExtension1__Dynamic_Sections__c
                            ORDER BY Sort__c];
        try {
            // procress all the custom setting data
            for(Dynamic_Sections__c dynamicSection :listDynamicSection) {
                listFields = new List<Schema.FieldSetMember>();
                // CHECK FIELDSET 
                try {
                    listFields = Schema.getGlobalDescribe().get(OPPORTUNIY_NAME).getDescribe().FieldSets.getMap().get(dynamicSection.Field_Set_API_Name__c).getFields();
                } catch (Exception e) {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.error, CUSTOM_SETTING_FIELDSET));
                    break;
                }//End try - catch
                
                if(checkNoOFColumn(dynamicSection.Number_of_Column__c) > 6 || checkNoOFColumn(dynamicSection.Number_of_Column__c) < 3) {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.error, ROW_PER_COLUMN_ERROR));
                    break;
                }//end If
                
                if(dynamicSection.Object_Type__c == 'Contact') {
                    try {
                    if(opportunity <> null) 
                        conId = (String)opportunity.get(dynamicSection.Oppotunity_Contact_API_Name__c);
                    mapStringAndCon.put(dynamicSection.Oppotunity_Contact_API_Name__c.replace('__c','__r'), null);
                    } catch(Exception e) {
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.error, CUSTOM_SETTING_CONTACT));
                        break;                      
                    }// end try - catch
                }//End if
                
                if(oppId <> null && !isNewApplication.contains('true')){
                    query = fundingApplicationUtility.generateQuery(OPPORTUNIY_NAME, dynamicSection.Field_Set_API_Name__c);
                    
                    if(query <> null) {
                        PageSectionData = new PageSectionData(index,
                                                            dynamicSection.Header_Name__c,
                                                            createSectionMap(listFields, checkNoOFColumn(dynamicSection.Number_of_Column__c),
                                                                                dynamicSection.Object_Type__c == 'Contact' ? true : false),
                                                            Database.query(oppWhereClause(query, oppId)),
                                                            dynamicSection.Object_Type__c == 'Contact' ? true : false,
                                                            getContactVal(conId),
                                                            conId,
                                                            dynamicSection.Oppotunity_Contact_API_Name__c,
                                                            checkNoOFColumn(dynamicSection.Number_of_Column__c),
                                                            listFieldMember.size() > 0 ? listFieldMember : null,
                                                            accName);
                    } else {
                        PageSectionData = new PageSectionData(index,
                                                            dynamicSection.Header_Name__c,
                                                            createSectionMap(listFields, checkNoOFColumn(dynamicSection.Number_of_Column__c),
                                                                                dynamicSection.Object_Type__c == 'Contact' ? true : false),
                                                            null,
                                                            dynamicSection.Object_Type__c == 'Contact' ? true : false,
                                                            getContactVal(conId),
                                                            conId,
                                                            dynamicSection.Oppotunity_Contact_API_Name__c,
                                                            checkNoOFColumn(dynamicSection.Number_of_Column__c),
                                                            listFieldMember.size() > 0 ? listFieldMember : null,
                                                            accName);
                    }//end else - if
                } else {
                        showBackOpp = false;
                        PageSectionData = new PageSectionData(index,
                                                            dynamicSection.Header_Name__c,
                                                            createSectionMap(listFields, checkNoOFColumn(dynamicSection.Number_of_Column__c),
                                                                                dynamicSection.Object_Type__c == 'Contact' ? true : false),
                                                            null,
                                                            dynamicSection.Object_Type__c == 'Contact' ? true : false,
                                                            new Contact(),
                                                            '-None-',
                                                            dynamicSection.Oppotunity_Contact_API_Name__c,
                                                            checkNoOFColumn(dynamicSection.Number_of_Column__c),
                                                            listFieldMember.size() > 0 ? listFieldMember : null,
                                                            accName);         
                }// end else - if 
                index++;
                // Add wrapper data into list
                listofPageData.add(PageSectionData);
            }//End For
            system.debug('listofPageData -->'+listofPageData);
        }catch(Exception e){
            system.debug('Inside Catch');
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, McaApp.MCAExceptionHandlerUtility.getErrorMessage(e)));
            //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, e.getMessage()));
        }
    }//End getCustomSettingVal()
    
    
    // Add page Message error
    public Integer checkNoOFColumn(Decimal noColumn) {
        if(noColumn != null) {
            return Integer.ValueOf(noColumn);
        } else {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, CUSTOM_SETTING_ValEEROR));
        }
        return 0;
    }//end checkNoOFColumn()
    
    // Picklist to show all contact reltaed to opportunity account.
    public List<SelectOption> getConatactOptions() {
        List<SelectOption> contactOptions = new List<SelectOption>();
        contactOptions.add(new SelectOption('-None-','-None-'));
        contactOptions.add(new SelectOption('New','-New-'));
        for(Contact objContact: relatedContact()) {
            contactOptions.add(new SelectOption(objContact.id, objContact.name));
        }
        return contactOptions;
    }// getCountriesOptions()
    
    // Get Opp values
    public Opportunity getOppValue() {
        if(oppId <> null && oppId != '') {
        return ([SELECT id,
                        McaApp__Owner_1__c,
                        McaApp__Owner_2__c,
                        McaApp__Application__c,
                        McaApp__Credit_Card_Statements__c,
                        AccountId,
                        McaApp__Bank_Statements__c
                FROM Opportunity
                WHERE id = :oppId]);
        }
        return null;
    }// End getOppValue()
    
    // Get Contact
    public Contact getContactVal(String conId) {
        if(conId <> null) {
            return ([SELECT id,
                            Name,
                            Title,
                            FirstName,
                            LastName
                    FROM Contact
                    WHERE Id =: conId]);
        } else 
            return null;
    }//End getContactVal()
    
    //change owner 
    public void changeOwner() {
        String query = '', contcatAPI; 
        System.debug('Change owner');
        //System.debug('listofPageData[paramValue].contactAPIName' + listofPageData[paramValue].contactAPIName);
        // Instance of Dynamic Query class 
        fundingApplicationUtility = new FundingApplicationUtility();
        if(listofPageData[paramValue] <>  null) {
            contcatAPI = (listofPageData[paramValue].contactAPIName).replace('__c','__r.');
            if(listofPageData[paramValue].selectedContact == '-None-' ||
            listofPageData[paramValue].selectedContact == 'New') {
                listofPageData[paramValue].ownerValue = new Contact();
                (listofPageData[paramValue].oppFieldValue).putSObject(contcatAPI.removeEnd('.'), new Contact());
            }else {
                
                listofPageData[paramValue].ownerValue = getContactVal(listofPageData[paramValue].selectedContact);
                query = fundingApplicationUtility.getContactQuery(Schema.getGlobalDescribe().get(OPPORTUNIY_NAME).getDescribe().FieldSets.getMap().get(listDynamicSection[paramValue].Field_Set_API_Name__c).getFields(), 
                        contcatAPI);
                // check query string
                if(query <> null && query != '') {
                    query += ' WHERE Id =\'' + listofPageData[paramValue].selectedContact + '\' ';
                    (listofPageData[paramValue].oppFieldValue).putSObject(contcatAPI.removeEnd('.'), Database.query(query));
                }//End If
            }//End else -if
        }//end If
    }// end changeOwner()
    
    //get list of contact related to account
    public List<Contact> relatedContact() {
        return ([SELECT id,
                        Name
                FROM Contact
                WHERE AccountId =: AccId]);
    }//End relatedContact()
    
    // Add oppid for where clause 
    public String oppWhereClause(String query, String objectID) {
        return query + ' WHERE Id =\'' +objectID+ '\' ' ;
    }//End oppWhereClause()
    
    // Assign value to one object instance
    public void assignValue(List<Schema.FieldSetMember> lstFields, 
                            Opportunity oppValue, 
                            String conID, 
                            Contact objContactStatic) {
        String fieldName = '';
        Map<String, Schema.SObjectField> mapOpp = Schema.SObjectType.Opportunity.fields.getMap();
        Map<String, Schema.SObjectField> mapAccount = Schema.SObjectType.Account.fields.getMap();
        Map<String, Schema.SObjectField> mapContact = Schema.SObjectType.Contact.fields.getMap();
        Contact objContact = new Contact();
        String conAPIName = '';
        try{
            for(Schema.FieldSetMember strField: lstFields) {
                if(strField.getFieldPath().contains('Account.')){
                    if(oppValue.getSObject('Account') <> null) {
                        fieldName = (strField.getFieldPath()).replace('Account.', '');
                        if(mapAccount.get(fieldName).getDescribe().isUpdateable()) {
                            accountToUpsert.put(fieldName, oppValue.getSObject('Account').get(fieldName));
                        }// end if
                    }// End IF
                } else if(mapStringAndCon <> null && mapStringAndCon.keySet() <> null 
                && mapStringAndCon.keySet().contains(strField.getFieldPath().substringBefore('.'))
                && oppValue.getSObject(strField.getFieldPath().substringBefore('.')) <> null) {
                    conAPIName = strField.getFieldPath().substringBefore('.');
                    objContact.put(strField.getFieldPath().substringAfter('.'), 
                        oppValue.getSObject(strField.getFieldPath().substringBefore('.')).get(strField.getFieldPath().substringAfter('.')));
                    
                } else if(mapStringAndCon <> null && mapStringAndCon.keySet() <> null
                && !mapStringAndCon.keySet().contains(strField.getFieldPath().substringBefore('.'))
                && mapOpp.get(strField.getFieldPath()).getDescribe().isUpdateable()) {
                        oppToUpsert.put(strField.getFieldPath(), oppValue.get(strField.getFieldPath()));
                }//End Else - if
            }// End For
            
            // add contact value into map
            if(conAPIName <> '' && objContact <> new Contact() && conID <> '-None-') {
                if(conID <> null && conID <> 'New')
                    objContact.put('Id', conID);
                objContact.put('FirstName', objContactStatic.get('FirstName'));
                objContact.put('LastName', objContactStatic.get('LastName'));
                mapStringAndCon.put(conAPIName, objContact);
            }//end if
        }catch(Exception e){
            isError = true;
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, McaApp.MCAExceptionHandlerUtility.getErrorMessage(e)));
            //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.error,e.getMessage()));
            
        }
    }// End assignValue()
    
    // 
    public PageReference saveRecordBeforeBtnAction(){
        try{
            this.quickSave();
        }catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, McaApp.MCAExceptionHandlerUtility.getErrorMessage(e)));
            //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
        return new PageReference('/'+OppId);
    }//end openConga()
    
    // Wrapper to store section wise data
    public class PageSectionData {
        public Integer indexVal                                         {get;set;}
        public String columnName                                        {get;set;}
        public Map<Integer, List<Schema.FieldSetMember>> mapFieldMember {get;set;}
        public List<Schema.FieldSetMember> listFieldMember              {get;set;}
        public Opportunity oppFieldValue                                {get;set;}
        public Boolean isContactSection                                 {get;set;}
        public Contact ownerValue                                       {get;set;}
        public String selectedContact                                   {get;set;}
        public String contactAPIName;
        public Integer colSpan                                          {get;set;}
        public PageSectionData(Integer indexVal, String columnName, 
                                Map<Integer, List<Schema.FieldSetMember>> mapFieldMember, 
                                Opportunity oppFieldValue, 
                                Boolean isContactSection, 
                                Contact ownerValue,
                                String selectedContact,
                                String contactAPIName,
                                Integer colSpan,
                                List<Schema.FieldSetMember> listFieldMember,
                                String accName) {
            if(oppFieldValue == null) {
                oppFieldValue = new Opportunity();
                oppFieldValue.Account = new Account(name = accName);
                if(contactAPIName <> null && contactAPIName <> '')
                    oppFieldValue.putSObject(contactAPIName.replace('__c','__r'), new Contact());
            }
            this.indexVal = indexVal;
            this.columnName = columnName;
            this.mapFieldMember = mapFieldMember;
            this.oppFieldValue = oppFieldValue;
            this.isContactSection = isContactSection;
            this.ownerValue = ownerValue;
            this.selectedContact = selectedContact;
            this.contactAPIName = contactAPIName;
            this.colSpan = colSpan;
            if(listFieldMember == null)
                this.listFieldMember = new List<Schema.FieldSetMember>();
            this.listFieldMember = listFieldMember;
        }//End PageSectionData()
    }// End Wrapper 
}// End Class