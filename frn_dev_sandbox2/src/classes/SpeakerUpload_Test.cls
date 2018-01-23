@isTest
public class SpeakerUpload_Test{
 static testMethod void Test1(){
  RecordType rc = [select id from  RecordType where SobjectType='Speaker__c' AND Name='Default Application'];
  Speaker__c s = new Speaker__c(name = 'Test');
  insert s;  
  SubmitSpeakerController SSC = new SubmitSpeakerController();
  SpeakerUpload SU = new SpeakerUpload(SSC);
		  SU.saveSpeaker();
    }
	
}