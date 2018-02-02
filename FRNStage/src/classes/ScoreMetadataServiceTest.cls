@isTest
private class ScoreMetadataServiceTest {
     @testSetup static void setupTestData() {

        Document rtcDocumentObj = new Document();
        String bodyStr = '{"opportunity":[{"sectionAPIName":"QLT_FRN_Facility_Information_Score__c",'
                       + '"sectionName": "FRN Facility Information", "sectionFields":[{"objectAPIName"'
                       + ':"Opportunity", "lookupRelationName": "", "fieldAPIName":"Readmit__c",'
                       + '"controlObjectAPIName" :"", "controlFieldAPIName":"","controlValue": "",'
                       + '"fieldScore":"1","fieldLabel":"Readmit","isConditionallyVisible" : "false"'
                       + '},{"objectAPIName":"Opportunity","lookupRelationName":"","fieldAPIName"'+
                       + ':"Most_Recent_FRN_Facility__c","controlObjectAPIName" : "Opportunity",'
                       + '"controlFieldAPIName":"Readmit__c","controlValue": "Yes","fieldScore": "1",'
                       + '"fieldLabel":"Most Recent FRN Facility","isConditionallyVisible":"true"'
                       + '},{"objectAPIName":"Opportunity","lookupRelationName":"","fieldAPIName"'
                       + ': "Relapse_Date__c","controlObjectAPIName":"Opportunity","controlFieldAPIName"'
                       + ':"Readmit__c","controlValue": "Yes","fieldScore": "1","fieldLabel":"Relapse Date",'
                       + '"isConditionallyVisible":"true"},{"objectAPIName":"Medical_Equipment__r",'
                       + '"lookupRelationName":"","fieldAPIName":"Equipment_Type__c","controlObjectAPIName"'
                       + ':"","controlFieldAPIName":"","controlValue":"","fieldScore":"1","fieldLabel":'
                       + '"Equipment Type","isConditionallyVisible":"false"},{"objectAPIName":'
                       + '"Medical_Equipment__r","lookupRelationName":"","fieldAPIName":'
                       + '"Currently_Using_Equipment__c","controlObjectAPIName":"Opportunity","controlFieldAPIName"'
                       + ':"Readmit__c","controlValue":"Yes","fieldScore":"1","fieldLabel":"Currently Using Equipment",'
                       + '"isConditionallyVisible":"false"},{"objectAPIName":"Medical_Equipment__r","lookupRelationName" '
                       + ':"","fieldAPIName":"Details__c","controlObjectAPIName":"Medical_Equipment__c",'
                       + '"controlFieldAPIName":"Currently_Using_Equipment__c","controlValue":"Yes","fieldScore"'
                       + ':"1","fieldLabel": "Details","isConditionallyVisible" : "true"}]}]}';

        rtcdocumentObj = OpportunityScoreTestDataFactory.createDocumentRecord(rtcdocumentObj,
                                                                            bodyStr,
                                                                            'rtcJson',
                                                                            'rtcJson',
                                                                            'json',
                                                                            true,
                                                                            UserInfo.getUserId());
        insert rtcdocumentObj;

        Quality_Score_Settings__c custom_Obj = new Quality_Score_Settings__c();
        custom_Obj.Residential_Treatment_DocId__c = rtcdocumentObj.Id;
        custom_Obj.Refer_Out_Only_DocId__c = rtcdocumentObj.Id;
        custom_Obj.Outpatient_Treatment_DocId__c = rtcdocumentObj.Id;
        custom_Obj.SetupOwnerId = UserInfo.getOrganizationId();
        insert custom_Obj;
    }
    @isTest
    static void fetchRTCJsonMetadataTest() {        
        ScoreMetadataService.fetchJsonMetadata('Residential_Treatment');
    }

    @isTest
    static void fetchIOPJsonMetadataTest() {        
        ScoreMetadataService.fetchJsonMetadata('Outpatient_Treatment');
    }

    @isTest
    static void fetchROOJsonMetadataTest() {        
        ScoreMetadataService.fetchJsonMetadata('Refer_Out_Only');
    }

    static testMethod void wrapperTest() { 
        ScoreMetadataService.FieldScoreDetailCls cls = new ScoreMetadataService.FieldScoreDetailCls();
        cls.objectAPIName = 'objectAPIName__c';
        cls.lookupRelationName = 'lookupRelationName__c';
        cls.fieldAPIName  = 'fieldAPIName__c';
        cls.controlObjectAPIName = 'controlObjectAPIName__c';
        cls.controlFieldAPIName = 'controlFieldAPIName__c';
        cls.controlValue = 'controlValue__c';
        cls.fieldScore = 'fieldScore__c';
        cls.fieldLabel = 'fieldLabel__c';
        cls.isConditionallyVisible = 'isConditionallyVisible__c';

        ScoreMetadataService.SectionDetail sd = new ScoreMetadataService.SectionDetail();
        sd.sectionAPIName = 'sectionAPIName__c';
        sd.sectionName = 'sectionName__c'; 
        sd.sectionFields = new List<ScoreMetadataService.FieldScoreDetailCls>();
    } 
}