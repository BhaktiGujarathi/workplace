@isTest
private class ScoreCalculationSchedulerTest {
	
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
        custom_Obj.Cron_Expression_For_Batch__c = '00:30';
        insert custom_Obj;
    }

    static testMethod void batchTest() { 
        Test.startTest();
            ScoreCalculationScheduler.scheduleScore();
        Test.stopTest();
    }
	
}