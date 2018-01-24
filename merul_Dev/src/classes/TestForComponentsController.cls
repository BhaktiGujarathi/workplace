public class TestForComponentsController {

 public Position__c pos{
  
 get;
 set;
 
 
 }
  
 public pagereference onload()
 {
 
 
 
 pos = [select Apex__c,Status__c,Open_Date__c,name,SampleCand__r.SampleCandDate__c from position__c where id='a009000001ykxt9AAA'];
 
 if(pos.SampleCand__r==null)
 {
 pos.SampleCand__r = new Candidate__c();
 
 }
 return null;
 
 }
 
 
 public TestForComponentsController()
 {
 /*
 pos = [select Apex__c,Status__c,Open_Date__c,name,SampleCand__r.SampleCandDate__c from position__c where id='a009000001ykxt9AAA'];
 
 if(pos.SampleCand__r==null)
 {
 pos.SampleCand__r = new Candidate__c();
 
 }
 
 */
 }
 
 public pagereference save()
 {
 
 
 
 system.debug('$$$$$$   '+ pos.SampleCand__r);
 //update pos;
 return null;
 }
 

 
 
}