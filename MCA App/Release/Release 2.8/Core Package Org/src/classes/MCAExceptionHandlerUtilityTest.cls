@isTest
public with sharing class MCAExceptionHandlerUtilityTest {
   
     static testmethod void catchDMLException(){
         String msgStr;
         Opportunity oppObj = new Opportunity();
         try {
             insert oppObj;
         }catch (Exception exceptionObj) {
             msgStr = MCAExceptionHandlerUtility.getErrorMessage(exceptionObj);
         }         
     }
     
     static testMethod void catchNullpointerException() {
         String msgStr;
         String str;
         try {
             str.toLowerCase();
         }catch (Exception exceptionObj) {
             msgStr = MCAExceptionHandlerUtility.getErrorMessage(exceptionObj);
         }     
     }
     
     static testMethod void catchListException() {
         String msgStr;
         List<Opportunity> listOpp = new List<Opportunity>();
         try {
             listOpp[3].Name = 'testOpp';
         }catch(Exception exceptionObj) {
            msgStr = MCAExceptionHandlerUtility.getErrorMessage(exceptionObj);
         }
     }
     
     static testMethod void catchgenericException() {
         String msgStr;
         Integer a = 10;
         //Account accountObj = [Select Name, Id From Account Where Name = 'Account1'];
         try {
             a= a/0;
             
         }catch(Exception exceptionObj) {
            msgStr = MCAExceptionHandlerUtility.getErrorMessage(exceptionObj);
         }
         
     }
}