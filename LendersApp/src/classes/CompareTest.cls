@isTest
private class CompareTest {

	public static CompareUtils comparator = new CompareUtils();

	//compare(sObject record, String fieldName, String operator, String value) {}

	@isTest static void testCompareBoolean() {

		Opportunity opp = new Opportunity();
		opp.McaApp__App_Received__c = true;
		comparator.compare(opp, 'McaApp__App_Received__c', 'equals', 'true');
		comparator.compare(opp, 'McaApp__App_Received__c', 'greater', 'true');
		comparator.compare(opp, 'McaApp__App_Received__c', 'lower', 'true');
		comparator.compare(opp, 'McaApp__App_Received__c', 'lower equal', 'true');
		comparator.compare(opp, 'McaApp__App_Received__c', 'greater equal', 'true');
		comparator.compare(opp, 'McaApp__App_Received__c', 'not equals', 'true');
		comparator.compare(opp, 'McaApp__App_Received__c', 'contains', 'true');
		comparator.compare(opp, 'McaApp__App_Received__c', 'none', 'true');
	}

	@isTest static void testCompareDate() {

		Opportunity opp = new Opportunity();
		opp.CloseDate = Date.valueOf('2013-05-05');

		comparator.compare(opp, 'CloseDate', 'equals', '2013-05-05');
		comparator.compare(opp, 'CloseDate', 'greater', '2013-05-05');
		comparator.compare(opp, 'CloseDate', 'lower', '2013-05-05');
		comparator.compare(opp, 'CloseDate', 'lower equal', '2013-05-05');
		comparator.compare(opp, 'CloseDate', 'greater equal', '2013-05-05');
		comparator.compare(opp, 'CloseDate', 'not equals', '2013-05-05');
		comparator.compare(opp, 'CloseDate', 'contains', '2013-05-05');
		comparator.compare(opp, 'CloseDate', 'none', '2013-05-05');
	}
	@isTest static void testCompareDateTime() {
		
		Opportunity opp = new Opportunity();
		opp.Date_Applied__c = Datetime.valueOf('2013-05-05 05:05:05');

		comparator.compare(opp, 'Date_Applied__c', 'equals', '10-14-2011 11:46:00');
		comparator.compare(opp, 'Date_Applied__c', 'greater', '10-14-2011 11:46:00');
		comparator.compare(opp, 'Date_Applied__c', 'lower', '10-14-2011 11:46:00');
		comparator.compare(opp, 'Date_Applied__c', 'lower equal', '10-14-2011 11:46:00');
		comparator.compare(opp, 'Date_Applied__c', 'greater equal', '10-14-2011 11:46:00');
		comparator.compare(opp, 'Date_Applied__c', 'not equals', '10-14-2011 11:46:00');
		comparator.compare(opp, 'Date_Applied__c', 'contains', '10-14-2011 11:46:00');
		comparator.compare(opp, 'Date_Applied__c', 'none', '10-14-2011 11:46:00');
	}
	@isTest static void testCompareDouble() {

		Opportunity opp = new Opportunity();
		opp.AdjustedMonthlyCCSales__c = 2.5;

		comparator.compare(opp, 'AdjustedMonthlyCCSales__c', 'equals', '2.5');
		comparator.compare(opp, 'AdjustedMonthlyCCSales__c', 'greater', '2.5');
		comparator.compare(opp, 'AdjustedMonthlyCCSales__c', 'lower', '2.5');
		comparator.compare(opp, 'AdjustedMonthlyCCSales__c', 'lower equal', '2.5');
		comparator.compare(opp, 'AdjustedMonthlyCCSales__c', 'greater equal', '2.5');
		comparator.compare(opp, 'AdjustedMonthlyCCSales__c', 'not equals', '2.5');
		comparator.compare(opp, 'AdjustedMonthlyCCSales__c', 'contains', '2.5');
		comparator.compare(opp, 'AdjustedMonthlyCCSales__c', 'none', '2.5');
	}
	@isTest static void testCompareString() {

		Opportunity opp = new Opportunity();
		opp.Interviewee__c = 'CMB';

		comparator.compare(opp, 'Interviewee__c', 'equals', 'CMB');
		comparator.compare(opp, 'Interviewee__c', 'greater', 'CMB');
		comparator.compare(opp, 'Interviewee__c', 'lower', 'CMB');
		comparator.compare(opp, 'Interviewee__c', 'lower equal', 'CMB');
		comparator.compare(opp, 'Interviewee__c', 'greater equal', 'CMB');
		comparator.compare(opp, 'Interviewee__c', 'not equals', 'CMB');
		comparator.compare(opp, 'Interviewee__c', 'contains', 'CMB');
		comparator.compare(opp, 'Interviewee__c', 'none', 'CMB');
	}


}