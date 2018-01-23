@isTest
private class RecordScoreCalculationServiceTest {

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

        Id rtcRecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName(
                                                                        'Opportunity',
                                                                        'Residential Treatment');
        Opportunity rtcOpportunityObj = new Opportunity();
        rtcOpportunityObj = OpportunityScoreTestDataFactory.createOpportunityRecord(rtcOpportunityObj,
                                                                                    rtcRecordTypeId,
                                                                                    'Alumini',
                                                                                    'rtcOpportunity');
        insert rtcOpportunityObj;

        Medical_Equipment__c medEquip = new Medical_Equipment__c();
        medEquip.Opportunity__c = rtcOpportunityObj.Id;
        insert medEquip;

        Quality_Score_Settings__c custom_Obj = new Quality_Score_Settings__c();
        custom_Obj.Residential_Treatment_DocId__c = rtcdocumentObj.Id;
        custom_Obj.SetupOwnerId = UserInfo.getOrganizationId();
        insert custom_Obj;
    }
    
    static testMethod void getOpportunityScoreMetadataTest() { 
        Opportunity objOpp_Test = [SELECT Id , RecordType.DeveloperName FROM Opportunity LIMIT 1];
        Test.startTest();
            ScoreMetadataService.OpportunityQualityReportMetaData metadata = 
                  RecordScoreCalculationService.getOpportunityScoreMetadata(objOpp_Test.RecordType.DeveloperName);
        Test.stopTest();
        System.assert(metadata != null);
    }

    static testMethod void getOpportunityQualityScoreTest() {
        Opportunity objOpp_Test = [SELECT Id , RecordType.DeveloperName FROM Opportunity LIMIT 1];
        ScoreMetadataService.OpportunityQualityReportMetaData metadata = 
                                                       new ScoreMetadataService.OpportunityQualityReportMetaData();
        metadata = RecordScoreCalculationService.getOpportunityScoreMetadata(objOpp_Test.RecordType.DeveloperName);
        Test.startTest();
            RecordScoreCalculationService.getOpportunityQualityScore(objOpp_Test.Id, 
                                        objOpp_Test.RecordType.DeveloperName,
                                        metadata);
        Test.stopTest();
    }

    static testMethod void getOpportunityScoreTest() {
        Opportunity objOpp_Test = [SELECT Id , RecordType.DeveloperName FROM Opportunity LIMIT 1];
        ScoreMetadataService.OpportunityQualityReportMetaData metadata = 
                                                       new ScoreMetadataService.OpportunityQualityReportMetaData();
        metadata = RecordScoreCalculationService.getOpportunityScoreMetadata(objOpp_Test.RecordType.DeveloperName);
        Test.startTest();
            RecordScoreCalculationService.getOpportunityScore(objOpp_Test.Id, 
                                        objOpp_Test.RecordType.DeveloperName);
        Test.stopTest();
    }
}