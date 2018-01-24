@isTest
public with sharing class UsersWithHotSkillsControllerTest {
	
	private static final BOOLEAN BOOLEANFALSE = false;
	private static final BOOLEAN BOOLEANTRUE  = true;
	
	
	static testMethod void unitTestOne() {
		User testUser = DETE_DataFactory.getUSerRecord(BOOLEANTRUE);
		System.assertNotEquals(null, testUser.Id);
		
		List<Technology__c> techList = new List<Technology__c>();
		techList.addAll(DETE_DataFactory.getHotTechnologyRecords(BOOLEANTRUE));
		techList.addAll(DETE_DataFactory.getGeneralTechnologyRecords(BOOLEANTRUE));
		
		for(Technology__c techObj : techList) {
			System.assertNotEquals(null, techObj.Id);
		}
		
		List<Knowledges__c> knowledgeList = new List<Knowledges__c>(DETE_DataFactory.getKnowledges(BOOLEANTRUE));
		
		for(Knowledges__c knowledgeObj : knowledgeList) {
			System.assertNotEquals(null, knowledgeObj.Id);
		}
		
		UsersWithHotSkillsController usersWithHotSkillsControllerObj = new UsersWithHotSkillsController();
		
		usersWithHotSkillsControllerObj.selectedContacts.add('Accounting software');
		usersWithHotSkillsControllerObj.selectedContacts.add('Spreadsheet software');
		usersWithHotSkillsControllerObj.selectedContacts.add('Facilities management software');
		usersWithHotSkillsControllerObj.selectedContacts.add('The MathWorks MatLAB');
		usersWithHotSkillsControllerObj.selectedContacts.add('SAS software');
		usersWithHotSkillsControllerObj.selectedContacts.add('Minitab software');
		
		usersWithHotSkillsControllerObj.save();
	}
}