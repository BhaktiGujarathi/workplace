/*
* Test Class for Campaignhandler.
*/
@isTest
private class Campaignhandler_Test {
    @testSetup static void setupData() {
		Recordtype r = [select id,name from recordtype where sobjecttype = 'Campaign__c' order by name asc limit 1];
        List<Constants__c> lstConsts = new List<Constants__c>();    
        List<string> lstTypes = new List<String>{'Campaign','Country','Language','Campaign Category','Campaign Sub Category 1','Campaign Sub Category 2','Month'};
            for(string stType : lstTypes){
                Constants__c obj = new Constants__c();
                if(stType == 'Country'){
					obj.Type__c = stType;
                    obj.Code__c = 'NW';
                    obj.Name__c = 'Norway';
				}
				else if(stType == 'Language'){
                    obj.Type__c = stType;
                    obj.Code__c = 'CZ';
                    obj.Name__c = 'Czech';
                }
                else if(stType == 'Month'){
                    obj.Type__c = stType;
                    obj.Code__c = string.valueof(System.today().month());
                    obj.Name__c = string.valueof(System.today().month());
                }
                else if(stType == 'Campaign'){
					obj.Type__c = stType;
                    obj.Code__c = 'oA';
                    obj.Name__c = 'Outdoor Ads';
				}
                else if(stType == 'Campaign Category'){
					obj.Type__c = stType;
                    obj.Code__c = 'BH';
                    obj.Name__c = 'Billboard/Hoarding';
				}
                else if(stType == 'Campaign Sub Category 1'){
					obj.Type__c = stType;
                    obj.Code__c = 'GHAC';
                    obj.Name__c = 'Garhoud Hoarding / Aviation College';
				}
                else if(stType == 'Campaign Sub Category 2'){
					obj.Type__c = stType;
                    obj.Code__c = 'GHAC';
                    obj.Name__c = 'Replacement';
				}
                lstConsts.add(obj);
            }
        Constants__c obj = new Constants__c();
        obj.Type__c = 'RecordType';
        obj.Code__c = 'codeTest';
        obj.Name__c = r.name;
        lstConsts.add(obj);
		Constants__c obj1 = new Constants__c();
		obj1.Type__c = 'RecordType';
        obj1.Code__c = 'UAE';
        obj1.Name__c = 'United Arab Emirates';
		lstConsts.add(obj1);
        insert lstConsts;
        
        Id RecTypeid = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Standalone').getRecordTypeId();
        Campaign__c c = new Campaign__c();
        c.Campaign_Name__c = 'Standalone';
        C.End_Date__c = system.today();
        C.Marketing_End_Date__c = system.today();
        C.Marketing_Start_Date__c = system.today();
        C.Start_Date__c = system.today();
        insert c;
        
    }
    
    @istest static void test_method1(){
        Test.startTest();
        
        Id RecTypeid = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Conventional').getRecordTypeId();
        Campaign__c cmpgn = new Campaign__c();
        cmpgn.Campaign_Name__c = 'TestCampaign';
        cmpgn.End_Date__c = System.today();
        //cmpgn.Parent_Campaign__c 
        cmpgn.recordtypeid = RecTypeid;
        cmpgn.Campaign_Type_New__c = 'Outdoor Ads';
        cmpgn.Campaign_Category_New__c = 'Billboard/Hoarding';
        cmpgn.Campaign_Sub_Category_1__c = 'Garhoud Hoarding / Aviation College';
        cmpgn.Campaign_Sub_Category_2__c = 'Replacement';
        cmpgn.Country__c = 'Norway';
        cmpgn.City__c = 'Oslo';
        cmpgn.Language__c = 'Czech';
        string strCampaignCode = Campaignhandler.getCampaignCode(cmpgn);
        Campaignhandler.getCode(new List<Campaign__c> {cmpgn});
        
        Campaign__c cmpgn1 = new Campaign__c();
        cmpgn1.Campaign_Name__c = 'TestCampaign';
        cmpgn1.End_Date__c = System.today();
        //cmpgn.Parent_Campaign__c 
        cmpgn1.recordtypeid = RecTypeid;
        cmpgn1.Campaign_Type_New__c = 'Outdoor Ads';
        cmpgn1.Campaign_Category_New__c = 'Billboard/Hoarding';
        cmpgn1.Campaign_Sub_Category_1__c = 'Garhoud Hoarding / Aviation College';
        cmpgn1.Campaign_Sub_Category_2__c = 'Replacement';
        cmpgn1.Country__c = 'United Arab Emirates';
        cmpgn1.City__c = 'Abu Dhabi';
        cmpgn1.Language__c = 'Czech';
        strCampaignCode = Campaignhandler.getCampaignCode(cmpgn1);
        Campaignhandler.getCode(new List<Campaign__c> {cmpgn});
        Test.stopTest();
    }
    
    @istest static void test_method2(){
        Test.startTest();
        Id RecTypeid = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Conventional').getRecordTypeId();
        Campaign__c cmpgn = new Campaign__c();
        cmpgn.Campaign_Name__c = 'TestCampaign';
        cmpgn.End_Date__c = System.today();
        cmpgn.Parent_Campaign__c = [select id,name from Campaign__c limit 1].id;
        cmpgn.recordtypeid = RecTypeid;
        cmpgn.Campaign_Type_New__c = 'Outdoor Ads';
        cmpgn.Campaign_Category_New__c = 'Billboard/Hoarding';
        cmpgn.Campaign_Sub_Category_1__c = 'Garhoud Hoarding / Aviation College';
        cmpgn.Campaign_Sub_Category_2__c = 'Replacement';
        cmpgn.Country__c = 'Norway';
        cmpgn.City__c = 'Oslo';
        cmpgn.Language__c = 'Czech';
        string strCampaignCode = Campaignhandler.getCampaignCode(cmpgn);
        Campaignhandler.getCode(new List<Campaign__c> {cmpgn});
		cmpgn.Old_Campaign__c = false;

        Test.stopTest();
    }
}