/**
 *  This class is a helper class for setting default values
 *
 *  Version     Author                      Date(DD/MM/YYYY)            Description
 *  1.0                                                                 Initial draft[]
 *  1.1         Ajinkya Hingne              17/10/2016                  Show default vals when creating new record
 *  1.2         Merul Shah                  07/11/2016                  Added to display arrows
                                                                        for field function
 */
global with sharing class GRIDStipsController
{
    public static Map<String, Schema.SObjectType> globalMap;
    public static Map<String, GRIDTabsSetting__mdt> customMetaDataSettingMap;
    public List<Schema.FieldSetMember> stipsFieldsetList                                {get; set;}
    public Integer stipsBlockSize                                                       {get; set;}
    public Integer stipsOffsetSize                                                      {get; set;}
    public Map<String, Decimal> stipsFieldToSumMap                                      {get; set;}
    public Set<String> stipsFieldSumSet                                                 {get; set;}
    public Integer stipsRecordCount                                                     {get; set;}
    public Integer stipsIndexToRemove                                                   {get; set;}
    public Opportunity opportunity                                                      {get; set;}
    public String stipsSortExpression                                                   {get; set;}
    public String stipsSortFieldApi                                                     {get; set;}
    public string stipsSortDirection                                                    {get; set;}
    public String DestURL                                                               {get; set;}
    public String addAttachmentURL                                                      {get; set;}
    public String opportunityId                                                         {get; set;}
    public String stipsSortExprFieldApi                                                 {get; set;}
    public Boolean stipsIsRefrenceField                                                 {get; set;}
    public String  stipsRefrenceFieldLabel                                              {get; set;}
    public boolean stipsIsDisable                                                       {get; set;}
    // Editall Attribute
    public Boolean stipsEditAllFlag                                                     {get; set;}
    public Boolean displaySortingArrow                                                  {get; set;}
    public String fieldPathResult                                                       {get; set;}
    public Boolean displayBulkUpdateBtn                                                 {get; set;}
    public String errorMsgStips                                                         {get; set;}
    public Boolean isConfirmMsgStips                                                    {get; set;}
    public String currencySymbolStip                                                    {get; set;}
    public String configureSettingStipFromAddress                                       {get; set;}
    // boolean to handle save success message on navigation
    public Boolean stipsPageNavigated;
    public String mcaNamePrefix;
    public String stipsFieldType;
    public Map<Id, Stips__c> stipsFromDbMap;
    public List<StipsWrapper> stipsWrapperLst;
    public List<Stips__c> stipsLst;
    public Set<String> stipsFieldsApiSet;
    public String stipsFieldsString = '';
    public String stipsAggregateQueryStr='';
    public Boolean stipsFirstRun;
    public Boolean stipsSingleErrorOnSave;
    public Boolean stipsIsNewBtnPress;
    public Map<Id, List<String>> mapIDANDListAttach;
    public Set<ID> stipIDset;
    public Boolean stipsEditAll;
    public Boolean stipsStatusToCompleted;

    public GRIDStipsController() {
        if(GRIDOnloadStaticVariable.flipStips()) {
            mcaNamePrefix = ((System.Label.MCANamePrefix == 'McaApp__') ? System.Label.MCANamePrefix : '');
            stipsIsDisable = false;
            opportunityId = Apexpages.currentPage().getParameters().get('id');
            //Opportunity opportunity = new Opportunity();
            if(System.Label.GridStipBulkUpdateBtn == 'true') {
                displayBulkUpdateBtn = true;
            } else {
                displayBulkUpdateBtn = false;
            }
            if(opportunityId == null || opportunityId == '') {
                stipsIsDisable = true;
                if(System.Label.GridStipBulkUpdateBtn == 'false') {
                    displayBulkUpdateBtn = false;
                }
            } else {
                opportunity = [SELECT Id,
                                      Name,
                                      AccountId,
                                      Owner_1__c,
                                      Owner_1__r.Email,
                                      OwnerId,
                                      ISO_Sales_Rep__c,
                                      ISO__r.Email__c,
                                      ISO_Sales_Rep__r.Email
                               FROM Opportunity
                               WHERE Id=:opportunityId ];
                /*if(system.Label.GRIDEmailStips == 'Opportunity Owner')
                {
                    DestURL = '/_ui/core/email/author/EmailAuthor?p3_lkid='
                    +opportunity.Id+'&retURL=%2F'+opportunity.Id
                    +'&template_id='+system.Label.GRIDEmailStipsTemplateId
                    +'&p24='+[select Email, Id From User where Id =: opportunity.OwnerId].Email;
                }
                else
                {
                    DestURL = '/_ui/core/email/author/EmailAuthor?p3_lkid='
                    +opportunity.Id+'&retURL=%2F'
                    +opportunity.Id+'&template_id='+system.Label.GRIDEmailStipsTemplateId
                    +'&p2='+Opportunity.Owner_1__c+'&p2_lkid='+ Opportunity.Owner_1__c;
                }*/
                FO_Email_Settings__c stipsCustmStng = FO_Email_Settings__c.getValues('Email Stips');
                EmailConfig configStng = new EmailConfig();
                errorMsgStips = configStng.validateData(stipsCustmStng, opportunity);
                isConfirmMsgStips = configStng.isConfirmMsg;
                configureSettingStipFromAddress = configStng.fetchOrgWideEmail(stipsCustmStng);
            }
            globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
            displaySortingArrow = true;
            fieldPathResult = '';
            currencySymbolStip = MultiCurrencyHelper.getUserCurrencySymbol();
            stipsEditAll = false;
            stipsFieldType = '';
            stipsSortExpression = 'CreatedDate';
            stipsSortFieldApi = 'CreatedDate';
            stipsSortDirection = 'DESC';
            stipsBlockSize = (Integer)customMetaDataSettingMap.get('Stips').PageSize__c;
            stipsOffsetsize = 0;
            stipsIsNewBtnPress = false;
            stipsPageNavigated = false;
            stipsLst = new List<Stips__c>();
            stipIDset = new Set<ID>();
            stipsFieldSumSet = new Set<String>();
            stipsFieldsApiSet = new set<String>();
            stipsWrapperLst = new List<StipsWrapper>();
            stipsFromDbMap = new Map<Id, Stips__c>();
            stipsFieldToSumMap = new Map<String, Decimal>();
            mapIDANDListAttach = new Map<Id, List<String>>();
            Schema.DescribeSObjectResult stipsDescbResult = globalMap.get(
                customMetaDataSettingMap.get('Stips').Object_API_Name__c
            ).getDescribe();
            stipsFieldsetList = stipsDescbResult.FieldSets.getMap().get(
                customMetaDataSettingMap.get('Stips').Fieldset_Name__c
            ).getFields();

            GRIDUtility.ReferenceFieldWrapper refWrap = new GRIDUtility.ReferenceFieldWrapper(
                stipsFieldsetList, ' ', false
            );
            refWrap = GRIDUtility.isReferenceFieldPresent(refWrap);
            stipsIsRefrenceField= refWrap.isReferenceField;
            stipsRefrenceFieldLabel = refWrap.refrenceFieldLabel;

            if(!stipsIsRefrenceField) {
                stipsAggregateQueryStr = buildStipsAggregateQuery(stipsFieldsetList);
                stipsFieldToSumMap = getStipsFieldSum(stipsAggregateQueryStr);
                stipsFieldsApiSet = buildSetFromFieldListstips(stipsFieldsetList);
                stipsFieldsApiSet.add('Name');
                if(opportunityId != null && opportunityId != '') {
                    stipsLst = getStipsFromDB(
                        opportunityId,
                        stipsBlockSize,
                        stipsOffsetSize,
                        stipsFieldsApiSet,
                        stipsSortExpression,
                        stipsSortDirection
                    );
                }
                stipsFirstRun = true;
            }
            setDisplaySoringArrows(stipsDescbResult, stipsFieldsetList);
        }
        redirectToAddAttachment();
    }

    /**
     * To display sorting arrows for fields whose data type other than longtextares
     */
    public void setDisplaySoringArrows(
            Schema.DescribeSObjectResult descObjResult,
            List<Schema.FieldSetMember> fieldSetList
    ) {
        Map<String, Schema.SObjectField> MAP_OBJECT_FIELD = new Map<String, Schema.SObjectField>();
        for(String fieldName : descObjResult.fields.getMap().keySet()) {
            MAP_OBJECT_FIELD.put(
                descObjResult.fields.getMap().get(fieldName).getDescribe().getName(),
                descObjResult.fields.getMap().get(fieldName)
            );
        }
        for(Schema.FieldSetMember fieldSetMemb : fieldSetList) {
            if(fieldSetMemb.getType() == DisplayType.TextArea) {
                Schema.SObjectField sObjFields = MAP_OBJECT_FIELD.get(fieldSetMemb.getfieldPath());
                Schema.DescribeFieldResult descFieldResult = sObjFields.getDescribe();
                if(descFieldResult.getLength() > 255 ) {
                    displaySortingArrow = false;
                    fieldPathResult = fieldSetMemb.getfieldPath();
                }
            }
            displaySortingArrow = true;
        }
    }

    // redirect to add attachment page
    public void redirectToAddAttachment() {
        addAttachmentURL = '/apex/'+mcaNamePrefix
                          +'oppmultipleattachment?id='+opportunityId
                          +'&retURL=/'+opportunityId+'&accId=&isStips=true&stipID=';
    }

    // method to build a Set of FieldApi name From List of FieldSetMember
    public Set<String> buildSetFromFieldListstips(List<Schema.FieldSetMember> pStipsFieldsetList) {
        for(Schema.FieldSetMember fieldInstance :pStipsFieldsetList) {
            stipsFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference')) {
                String stipsReferenceField = '';
                if(fieldInstance.getfieldPath().contains('__c')) {
                    stipsReferenceField += fieldInstance.getfieldPath().substringBefore('__c')
                        +'__r.Name';
                } else {
                    stipsReferenceField += fieldInstance.getfieldPath().substringBefore('Id')
                        +'.Name';
                }
                stipsFieldsApiSet.add(stipsReferenceField);
            }
        }
        return stipsFieldsApiSet;
    }

    // method to get stips from DB
    public List<Stips__c> getStipsFromDB(
            String pOpportunityId,
            Integer pStipsBlockSize,
            Integer pStipsOffsetSize,
            Set<String> pStipsFieldsApiSet,
            String pStipsSortExpression,
            String pStipsSortDirection) {
        if(pOpportunityId <> null && pOpportunityId <> '') {
            String stipsQueryStr = '';
            stipsFieldsString = MCAUtility.getStringfromSet(pStipsFieldsApiSet, null);
            stipsQueryStr = 'Select ' +stipsFieldsString+
                            ' From Stips__c Where Opportunity__c =:pOpportunityId ORDER BY '
                            +pStipsSortExpression+' '+pStipsSortDirection+ ' NULLS LAST LIMIT '
                            +pStipsBlockSize+' Offset ' +pStipsOffsetSize;
            return database.query(stipsQueryStr);
        }
        return new List<Stips__c>();
    }

    //getter of wrapperList
    public List<StipsWrapper> getStipsWrapperLst() {
        if(stipsFirstRun) {
            stipsWrapperLst = new List<StipsWrapper>();
        }
        if(stipsLst<> null && stipsLst.size() > 0 ) {
            if(stipsFirstRun) {
                //stipsWrapperLst = new List<StipsWrapper>();
                stipIDset.clear();
                for(Stips__c tempStip : stipsLst) {
                    stipIDset.add(tempStip.id);
                }
                getStipRelatedAttachment();
                List<String> lstStipsAttchmntIds;
                for (Integer i = 0; i < stipsLst.size(); i++) {
                    if(mapIDANDListAttach != null && mapIDANDListAttach.size()>0 
                            && mapIDANDListAttach.get(stipsLst[i].id) != null) {
                        lstStipsAttchmntIds =  mapIDANDListAttach.get(stipsLst[i].id);
                        stipsWrapperLst.add(new StipsWrapper(
                            stipsLst[i], 
                            i, stipsEditAllFlag,
                            lstStipsAttchmntIds.size(),
                            lstStipsAttchmntIds)
                        );
                    }else {
                        stipsWrapperLst.add(new StipsWrapper(stipsLst[i], i, stipsEditAllFlag, 0,null));
                    }
                }
                stipsFirstRun = false;
            }
        }
        //stipsFieldToSumMap = getStipsFieldSum(stipsAggregateQueryStr);
        return stipsWrapperLst;
    }

    // get all attachment
    public void getStipRelatedAttachment() {
        mapIDANDListAttach.clear();
        Set<String> attachIds = new Set<String>();
        for(Stips__c stip : [SELECT id
                                  , Attachments_IDs__c
                               FROM Stips__c
                              WHERE Id IN: stipIDset]) {
            /*if(mapIDANDListAttach.get(objStipsAttachment.Id) == null) {
                mapIDANDListAttach.put(
                    objStipsAttachment.Id,
                    objStipsAttachment.Attachments_IDs__c
                );
            } else {
                mapIDANDListAttach.get(objStipsAttachment.Id).add(
                    objStipsAttachment.Attachments_IDs__c
                );
            }*/
            if(String.isNotBlank(stip.Attachments_IDs__c)) {
                attachIds.addAll(stip.Attachments_IDs__c.split(','));
            }
        }
        Map<Id, Attachment> existingAttach = new Map<Id, Attachment>([
            Select Id FROM Attachment WHERE Id IN:attachIds ]);
        
        for(Stips__c stip : [SELECT id
                                  , Attachments_IDs__c
                               FROM Stips__c
                              WHERE Id IN: stipIDset]){
             if(String.isNotBlank(stip.Attachments_IDs__c)) {
                mapIDANDListAttach.put(stip.Id, new List<String>());
                for(String atchId : stip.Attachments_IDs__c.split(',')){
                    if(existingAttach.containsKey(atchId)) {
                        mapIDANDListAttach.get(stip.Id).add(atchId);
                    }
                    
                }
            }
        }
    }

    // method to create new stip
    public void newStips() {
        globalMap = GRIDOnloadStaticVariable.getGlobalMap();
        customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
        Schema.DescribeSObjectResult stipDescbResult = globalMap.get(
            customMetaDataSettingMap.get('Stips').Object_API_Name__c
        ).getDescribe();
        stipsIsNewBtnPress = true;
        if(!stipsEditAll) {
            saveAllStips();
        } else {
            stipsSingleErrorOnSave = false;
        }
        stipsIsNewBtnPress = false;
        if(!stipsSingleErrorOnSave) {
            // to add new record only on first page
            if(stipsOffsetsize <> 0) {
                stipsOffsetsize = 0;
                beginningStips();
            }
            Stips__c stipsNew = new Stips__c();
            DefaultValueHelper.populateValues(stipsNew, stipsFieldsetList, stipDescbResult);
            stipsNew.Status__c = 'Pending';
            stipsNew.Date_Requested__c = system.today();
            stipsNew.Opportunity__c = opportunityId;
            /*need to add at 0th index if list size > 0 else simple add will work*/
            if(stipsWrapperLst.size() > 0 && stipsLst.size() > 0) {
                stipsWrapperLst.add(0,new StipsWrapper(stipsNew, null,true,0,null));
                stipsLst.add(0,stipsNew);
            } else {
                stipsWrapperLst.add(new StipsWrapper(stipsNew, null,true,0,null));
                stipsLst.add(stipsNew);
            }
            // reindexing
            for(Integer i=0; i<stipsWrapperLst.size(); i++) {
                stipsWrapperLst[i].stipsIndex = i;
            }
        }
    }

    //method to delete
    public void deleteStips()
    {
        if(stipsWrapperLst[stipsIndexToRemove].stips.Id != null) {
            try {
                delete stipsWrapperLst[stipsIndexToRemove].stips;
            }
            catch(Exception e) {
                ApexPages.addMessage(new Apexpages.Message(
                    ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
            }
        }
        stipsLst.remove(stipsIndexToRemove);
        stipsWrapperLst.remove(stipsIndexToRemove);
         //refreshStips();
          //re-indexing
        for(Integer i=0;i<stipsWrapperLst.size();i++) {
            stipsWrapperLst[i].stipsIndex = i;
        }
        if(stipsWrapperLst.size() <= 0) {
            refreshStips();
        }
        stipsFieldToSumMap = getStipsFieldSum(stipsAggregateQueryStr);
    }

    // method to refresh
    public void refreshStips()
    {
        stipsLst = getStipsFromDB(
            opportunityId,
            stipsBlockSize,
            stipsOffsetSize,
            stipsFieldsApiSet,
            stipsSortExpression,
            stipsSortDirection
        );
        stipsFieldToSumMap = getStipsFieldSum(stipsAggregateQueryStr);
        stipsFirstRun = true;
    }

    // method to save
    public void saveAllStips()
    {
        String stipsMsgStr = '';
        String stipsSuccessMsgStr ='';
        stipsSingleErrorOnSave = false;
        Boolean stipsIsUpdated = false;
        stipsEditAll = false;
        List<Stips__c> stipsListToUpdate = new List<Stips__c>();
        Map<Integer, Integer> stipsErrorToWraperIndexMap = new map<Integer, Integer>();

        List<Stips__c> stipsTempLst = getStipsFromDB(
            opportunityId,
            stipsBlockSize,
            stipsOffsetsize,
            stipsFieldsApiSet,
            stipsSortExpression,
            stipsSortDirection
        );
        stipsFromDbMap = getStipsMapFromList(stipsTempLst);
        for(StipsWrapper stipsWraperInstance :stipsWrapperLst) {
            Stips__c stipsDBObj = stipsFromDbMap.get(stipsWraperInstance.stips.Id);
            if(stipsDBObj != null) {
                stipsIsUpdated = false;
                for(String stipsFieldInstance :stipsFieldsApiSet) {
                    if(!stipsFieldInstance.contains('.Name')) {
                        stipsIsUpdated  = stipsIsUpdated || 
                            (stipsWraperInstance.stips.get(
                                stipsFieldInstance) != stipsDBObj.get(stipsFieldInstance)
                        );
                    }
                }
            } else {
                if(!stipsIsNewBtnPress) {
                    stipsIsUpdated = true;
                }
            }
            if(stipsIsUpdated) {
                stipsListToUpdate.add(stipsWraperInstance.stips);
                stipsErrorToWraperIndexMap.put(stipsListToUpdate.size()-1, stipsWraperInstance.stipsIndex);
            }
            stipsWraperInstance.stipsEdit = stipsEditAllFlag;
        }
        try {
            if(stipsListToUpdate != null && stipsListToUpdate.size() >0) {
                List<Database.upsertResult> results = Database.upsert(stipsListToUpdate, false);
                for (Integer i =0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) {
                        for (Database.Error err : results[i].getErrors()) {
                             String recordError = err.getMessage();
                             if(!recordError.contains('insufficient access rights on')) {
                                stipsWrapperLst[stipsErrorToWraperIndexMap.get(i)].stipsEdit = true;
                             }
                            stipsSingleErrorOnSave = true;
                            if(results.size() > 1) {
                                stipsMsgStr = stipsMsgStr 
                                    + 'Error Record '+(stipsErrorToWraperIndexMap.get(i)+1)
                                    +' : '+ recordError + '<br />';
                             } else {
                                stipsMsgStr = stipsMsgStr 
                                    + 'Error Record '+(stipsErrorToWraperIndexMap.get(i)+1)
                                    +' : '+ recordError;
                             }
                        }
                    } else if(results[i].isSuccess()) {
                        if(stipsListToUpdate.size() > 1) {
                            stipsSuccessMsgStr = stipsSuccessMsgStr
                                + 'Success Record '
                                +(stipsErrorToWraperIndexMap.get(i)+1)+' : '
                                + 'saved successfully!' + '<br />';
                        } else {
                            stipsSuccessMsgStr = stipsSuccessMsgStr
                                + 'Success Record '
                                +(stipsErrorToWraperIndexMap.get(i)+1)+' : '
                                + 'saved successfully!';
                        }
                        stipsWrapperLst[stipsErrorToWraperIndexMap.get(i)].stipsEdit = stipsEditAllFlag;
                    }
                }
                stipsSuccessMsgStr = stipsSuccessMsgStr.removeEnd('<br />');
                stipsMsgStr = stipsMsgStr.removeEnd('<br />');
                if(stipsSingleErrorOnSave == false && !stipsIsNewBtnPress) {
                    stipsLst = getStipsFromDB(
                        opportunityId,
                        stipsBlockSize,
                        stipsOffsetSize,
                        stipsFieldsApiSet,
                        stipsSortExpression,
                        stipsSortDirection
                    );
                    stipsFieldToSumMap = getStipsFieldSum(stipsAggregateQueryStr);
                    stipsFirstRun = true;
                }
                if(String.isNotBlank(stipsMsgStr) || String.isNotBlank(stipsSuccessMsgStr)) {
                    if(stipsPageNavigated) {
                        //stipsPageNavigated = false;
                        stipsSuccessMsgStr = 'Last changes made by you were saved successfully!';
                    }
                    if(String.isNotBlank(stipsMsgStr)) {
                        
                        if(String.isNotBlank(stipsSuccessMsgStr)) {
                            ApexPages.addMessage(new Apexpages.Message(
                                ApexPages.Severity.Info,stipsMsgStr +'<br/>'
                                + stipsSuccessMsgStr.removeEnd('<br />'))
                            );
                        } else {
                            ApexPages.addMessage(new Apexpages.Message(
                                ApexPages.Severity.Info,stipsMsgStr)
                            );
                        }
                    } else {
                        ApexPages.addMessage(new Apexpages.Message(
                            ApexPages.Severity.Info,stipsSuccessMsgStr)
                        );
                    }
                }
            }
            stipsPageNavigated = false;
        }
        catch (Exception e) {
            ApexPages.addMessage(new Apexpages.Message(
                ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e))
            );
             stipsFirstRun = false;
        }
    }

    // method to edit all stips
    public void editAllStips() {
        stipsFirstRun = false;
        stipsEditAll = true;
        for(Integer i=0; i< stipsWrapperLst.size(); i++) {
            stipsWrapperLst[i].stipsEdit = true;
        }
    }

    // method to build a map of Id-to-Stips from List
    public Map<Id, Stips__c> getStipsMapFromList(List<Stips__c> pStipsLst) {
        stipsFromDbMap.clear();
        for(Stips__c stipsInstance :pStipsLst) {
            stipsFromDbMap.put(stipsInstance.Id, stipsInstance);
        }
        return stipsFromDbMap;
    }

    // method to build dynamic query for SUM and COUNT
    public String buildStipsAggregateQuery(List<Schema.FieldSetMember> pStipsFieldsetList) {
        stipsAggregateQueryStr = 'SELECT ';
        /*
        for(Schema.FieldSetMember fieldInstance :pStipsFieldsetList) {
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency')
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double')
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Integer'))
            {
                stipsAggregateQueryStr += 'SUM('+fieldInstance.getFieldPath()+') '
                +fieldInstance.getFieldPath()+ ', ';
                stipsFieldSumSet.add(fieldInstance.getFieldPath());

            }
            //stipsFieldsApiSet.add(fieldInstance.getfieldPath());
            stipsFieldToSumMap.put(fieldInstance.getFieldPath(), -999.999);
        }*/
        stipsAggregateQueryStr += 'COUNT(Id) stipsCount FROM Stips__c Where Opportunity__c = \''
            +opportunityId+'\'';
        return stipsAggregateQueryStr;
    }

    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getStipsFieldSum(String pStipsAggregateQueryStr) {
        if(opportunityId <> null && opportunityId <> '') {
            List<SObject> stipsSumQueryResult = new List<SObject>();
            stipsSumQueryResult = Database.query(pStipsAggregateQueryStr);
            for(String fieldName :stipsFieldSumSet) {
                if(stipsSumQueryResult[0].get(fieldName) != null) {
                    //stipsFieldToSumMap.put(fieldName, (Decimal)stipsSumQueryResult[0].get(fieldName));
                    stipsFieldToSumMap.put(
                        fieldName,
                        MultiCurrencyHelper.isMultiCurrencyEnabled() ?
                        MultiCurrencyHelper.convertToUserCurrency((Decimal)stipsSumQueryResult[0].get(fieldName))
                        : (Decimal)stipsSumQueryResult[0].get(fieldName)
                    );
                }
            }
            stipsRecordCount = (Integer)stipsSumQueryResult[0].get('stipsCount');
            return stipsFieldToSumMap;
        }
        stipsRecordCount = 0;
        return null;
    }
 
    public void collectStipData() {
        if((Limits.getHeapSize()+
            (ApexPages.currentPage().getParameters().get('data')
            ).length()+(ApexPages.currentPage().getParameters().get('data')).length())< 6000000 ) {
            // Assign value to attachment
            Attachment objAttachment = new Attachment();
            objAttachment.Body= EncodingUtil.base64Decode(
                ApexPages.currentPage().getParameters().get('data').substringAfter('base64,')
            );
            objAttachment.ParentId = ApexPages.currentPage().getParameters().get('id');
            objAttachment.Name = ApexPages.currentPage().getParameters().get('name');
            try {
                insert objAttachment;
                Id stipId =  ApexPages.currentPage().getParameters().get('stipID');
                List<Stips__c> stipsToUpdate = [SELECT 
                                                    Id
                                                  , Attachments_IDs__c
                                                  FROM 
                                                    Stips__c
                                                 WHERE
                                                    Id = :stipId];
                for(Stips__c stip : stipsToUpdate) {
                    if(stip.Id == stipId) {
                        String attachId = objAttachment.id;
                        if(String.isBlank(stip.Attachments_IDs__c)) {
                            stip.Attachments_IDs__c = attachId;
                        } else {
                            stip.Attachments_IDs__c += ','+attachId;
                        }
                    }
                }
                update stipsToUpdate;
                
                stipsLst = getStipsFromDB(
                    opportunityId,
                    stipsBlockSize,
                    stipsOffsetSize,
                    stipsFieldsApiSet,
                    stipsSortExpression,
                    stipsSortDirection
                );
                stipsFirstRun = true;
            }
            catch(Exception e) {
            /*ApexPages.addmessage(new ApexPages.message(
                ApexPages.Severity.ERROR, ApexPages.currentPage().getParameters().get('stipID')));
            ApexPages.addmessage(new ApexPages.message(
                ApexPages.Severity.ERROR, e.getMessage()));
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));*/
                ApexPages.addMessage(new Apexpages.Message(
                    ApexPages.Severity.Info,
                    e.getMessage())
                );
            }
        }else {
            ApexPages.addMessage(new Apexpages.Message(
                ApexPages.Severity.Info,
                'Apex heap size too large, Please use Attach File button to upload the file.'));
        }
    }

    //to get attachments to download from vf page
    @RemoteAction
    global static List<AttachmentResponse> getAttachments(Id oppID, String listAttID) {
        Map<String,Integer> mapCopyCount = new  Map<String,Integer>();
        listAttID = listAttID.remove('[');
        listAttID = listAttID.remove(']');
        listAttID = listAttID.remove(' ');
        List<String> listAtt = listAttID.split(',');
        List<AttachmentResponse> listAttch = new List<AttachmentResponse>();
        for(Attachment objAttach :[SELECT id
                                            , Name
                                            , body
                                    FROM Attachment
                                    WHERE  id IN: listAtt]) {
            listAttch.add(new AttachmentResponse(
                objAttach.Name,
                EncodingUtil.base64Encode(objAttach.body),objAttach.Name.substringAfterLast('.'))
            );
        }
        return listAttch;
    }

    //method for the first page of list to be displayed
    public void beginningStips() {
        stipsPageNavigated = true;
        saveAllStips();
        if(!stipsSingleErrorOnSave) {
            stipsOffsetsize = 0;
            stipsLst = getStipsFromDB(
                opportunityId,
                stipsBlockSize,
                stipsOffsetSize,
                stipsFieldsApiSet,
                stipsSortExpression,
                stipsSortDirection
            );
            stipsFirstRun = true;
        }
    }

    //method for previous page of list to be displayed
    public void previousStips() {
        stipsPageNavigated = true;
        saveAllStips();
        if(!stipsSingleErrorOnSave && stipsBlockSize <= stipsOffsetSize) {
            stipsOffsetSize = stipsOffsetSize - stipsBlockSize;
            stipsLst = getStipsFromDB(
                opportunityId,
                stipsBlockSize,
                stipsOffsetSize,
                stipsFieldsApiSet,
                stipsSortExpression,
                stipsSortDirection
            );
            stipsFirstRun = true;
        }
    }

    //method for next page of list to be displayed
    public void nextStips() {
        stipsPageNavigated = true;
        saveAllStips();
        if(!stipsSingleErrorOnSave && stipsOffsetsize <= stipsRecordCount) {
            stipsOffsetSize = stipsOffsetsize + stipsBlockSize;
            stipsLst = getStipsFromDB(
                opportunityId,
                stipsBlockSize,
                stipsOffsetsize,
                stipsFieldsApiSet,
                stipsSortExpression,
                stipsSortDirection
            );
            stipsFirstRun = true;
        }
    }

    //method for last page of list to be displayed
    public void endStips() {
        stipsPageNavigated = true;
        saveAllStips();
        if(!stipsSingleErrorOnSave && math.mod(stipsRecordCount , stipsBlockSize) == 0) {
            stipsOffsetsize = stipsBlockSize * ((stipsRecordCount/stipsBlockSize)-1);
        } else if (!stipsSingleErrorOnSave && math.mod(stipsRecordCount , stipsBlockSize) != 0) {
            stipsOffsetsize = stipsBlockSize * ((stipsRecordCount/stipsBlockSize));
        }
        //stipsOffsetSize = stipsRecordCount-MAth.mod(stipsRecordCount,stipsBlockSize);
        stipsLst = getStipsFromDB(
            opportunityId,
            stipsBlockSize,
            stipsOffsetSize,
            stipsFieldsApiSet,
            stipsSortExpression,
            stipsSortDirection
        );
        stipsFirstRun = true;
    }

    //method to sort list of Stips
    public void sortStips()
    {
        string stipsRefernceFieldName = '';
        stipsFieldType = Apexpages.currentPage().getParameters().get('stipstypeParam');
        if(stipsFieldType.equalsIgnoreCase('REFERENCE')) {
            if(stipsSortExpression.contains('__c')) {
                stipsRefernceFieldName += stipsSortExpression.substringBefore('__c')+'__r.Name';
            }else {
                stipsRefernceFieldName += stipsSortExpression.substringBefore('Id')+'.Name';
            }
            stipsSortExpression = string.valueOf(stipsRefernceFieldName);
        }
        refreshStips();
    }

    /**
     * Redirect to stip bulk update page when Underwritting is installed in org.
     */
    public pageReference stipBulkUpdate() {
        PageReference pageRef = new PageReference(
            System.Label.GridStipBulkUpdateURL+'id='+opportunityId+'&isConsole=0');
        return pageRef;
    }

    @RemoteAction
    global static String getSenderReceipient(Id oppId) {
        Map<String, Schema.SObjectField> schemaOppFieldMap = Schema.SObjectType.Opportunity.fields.getMap();
        Set<String> stipsFieldsSet = new Set<String>{
            'Owner_1__c', 'ISO__c', 'ISO_Sales_Rep__c','Owner_1__r.Email', 'ISO__r.Email__c' ,
            'ISO_Sales_Rep__r.Email', 'Owner_1__r.Name', 'ISO__r.Name', 'ISO_Sales_Rep__r.Name'
        };
        FO_Email_Settings__c stipsCustmStng = FO_Email_Settings__c.getValues('Email Stips');
        String replyToFieldStips  = stipsCustmStng.Reply_to_Address__c;
        String sendersNameFieldStips = stipsCustmStng.Sender_s_Name__c;
        String queryStringStips = 'SELECT Id ';

        if((schemaOppFieldMap.containsKey(replyToFieldStips) || 
            schemaOppFieldMap.containsKey(replyToFieldStips.remove('McaApp__'))) && 
            !stipsFieldsSet.contains(replyToFieldStips)) {
            queryStringStips += ', '+stipsCustmStng.Reply_to_Address__c;
        }
        if((schemaOppFieldMap.containsKey(sendersNameFieldStips) || 
            schemaOppFieldMap.containsKey(sendersNameFieldStips.remove('McaApp__')) ) && 
            !stipsFieldsSet.contains(sendersNameFieldStips) ) {
            queryStringStips += ', '+stipsCustmStng.Sender_s_Name__c;
        }
        for(String stipFields : stipsFieldsSet) {
            queryStringStips += ', '+stipFields;
        }
        queryStringStips +=' FROM Opportunity WHERE Id =: oppId';
        
        Opportunity opportunity = Database.query(queryStringStips);
        EmailConfig emailCnfg = new EmailConfig();
        //emailCnfg.populateData(stipsCustmStng, opportunity);
        return emailCnfg.populateData(stipsCustmStng, opportunity);
    }

    public class StipsWrapper {
        public Stips__c stips                                    {get;set;}
        public Integer stipsIndex                                {get;set;}
        public Boolean stipsEdit                                 {get;set;}
        public Integer noAttachment                              {get;set;}
        public String noOfAttachmentString                       {get;set;}
        public List<ID> listAttachID                             {get;set;}
        public StipsWrapper(
            Stips__c stipsInstance,
            Integer pStipsIndex,
            Boolean pStipsEdit,
            Integer pNoAttachment,
            List<ID> pListAttachID)
        {
            stips = stipsInstance;
            stipsIndex = pStipsIndex;
            stipsEdit = pStipsEdit;
            noAttachment = pNoAttachment;
            listAttachID = pListAttachID;
            noOfAttachmentString =  noAttachment>1?noAttachment
                +' files':(noAttachment == 1?noAttachment+' file':'');
        }
    }

    // Wrapper to store attchemnt data
    // Note javascript don't no the object structure like Attchement, account, lead
    global class AttachmentResponse {
        public String attName {get;set;}
        public String attchBody {get;set;}
        public String nameExt {get;set;}
        public AttachmentResponse(String attName, String attchBody,String nameExt)
        {
            this.attName = attName;
            this.attchBody = attchBody;
            this.nameExt = nameExt;
        }
    }// end inner class AttachmentResponse
}