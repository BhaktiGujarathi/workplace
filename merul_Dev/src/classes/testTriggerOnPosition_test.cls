@isTest(seeAllData = false)
public with sharing class testTriggerOnPosition_test {


static testMethod void test1()
{

  infydisdespune__Position__C vPosition = new  infydisdespune__Position__C(name = 'test',infydisdespune__Testrequired__c='test',infydisdespune__TestRequired2__c='test',infydisdespune__Max_Pay__c=12323);
  
  system.Test.startTest();
  insert vPosition;
  system.Test.stopTest();

  system.assertEquals(true,[SELECT id,infydisdespune__Apex__c FROM infydisdespune__Position__C WHERE id=:vPosition.id].infydisdespune__Apex__c	);
}

}