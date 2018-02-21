@isTest
private class OnDeckClientTest {
	
	private static void sendPreQualTest(){
		TestUtils.createSettings();
        OnDeckClient odc = new OnDeckClient();
        
        ////////////////BUSINESSDATA////////////////
        OnDeckClient.BusinessData bd = TestUtils.createBusinessData();
        if (bd.getIsSuccess()){
            System.assert(bd.getPrequalAmountDecimal() == 1);
        }
        
        ////////////////SENDPREQUAL////////////////
        OnDeckClient.ResponseData response = odc.sendPrequal(bd);
        if (response.isTestSuccess()){
            System.Assert(response.status == 'OK');
            System.Assert(response.code == 500);
            System.Assert(bd.Prequalified == 'true');
            System.Assert(bd.URL == 'https://online.ondeckcapital.com?ref=f137bafd-8f0a-494a-8033-5004e962d740');
            System.Assert(bd.BusinessID == 'f137bafd-8f0a-494a-8033-5004e962d740');
            
        }
        System.Assert(!response.isSuccess());
	}
	
	public static testMethod void sendSubmitTest(){
        TestUtils.createSettings();
        OnDeckClient odc = new OnDeckClient();
        OnDeckClient.BusinessData bd = TestUtils.createBusinessData();
        OnDeckClient.ResponseData response = odc.sendPrequal(bd);
        Test.startTest();
        response = odc.sendSubmit(bd);
        Test.stopTest();
        if (response.isTestSuccess()){
            System.Assert(response.status == 'OK');
            System.Assert(response.code == 500);
            System.assert(bd.decisionStatus == 'approved');
            System.assert(bd.CompanyName == 'Legal Name (***Test Only***)');
            System.assert(bd.BusinessID == 'f137bafd-8f0a-494a-8033-5004e962d740');
            System.assert(bd.ApplicationNumber == '407821');
        }
        System.Assert(!response.isSuccess());
    }

    public static testMethod void failure() {
        try{
            OnDeckClient odc = new OnDeckClient();
        }
        catch (Exception ex){
            System.Assert(ex.getMessage().contains('No API Credentials defined for this Bank'));
        }
        
        OnDeckClient.BusinessData bd = new OnDeckClient.BusinessData();
        System.Assert(bd.getPrequalAmountDecimal() == 0);
    }
}