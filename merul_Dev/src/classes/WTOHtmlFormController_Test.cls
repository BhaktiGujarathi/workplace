@isTest(seeAllData = false)
public  class WTOHtmlFormController_Test
{

    static testmethod void WTOHtmlFormControllerOnload()
    {
      System.currentPagereference().getParameters().put('objectName' ,'infydisdespune__WTOTestObject__c' );
      System.currentPagereference().getParameters().put('returnURL' ,'https://www.google.com' );
      System.currentPagereference().getParameters().put('name' ,'Test1' );
      System.currentPagereference().getParameters().put('testforcheckbox__c' ,'1' );
      System.currentPagereference().getParameters().put('testforcurrency__c' ,'23' );
      System.currentPagereference().getParameters().put('testfordate__c' ,'12/12/2014' );
      System.currentPagereference().getParameters().put('testfordatetime__c' ,'11/6/2014 12:00 AM' );
      System.currentPagereference().getParameters().put('testforemail__c' ,'merulkumarshah@ymail.com' );
      System.currentPagereference().getParameters().put('testfornumber__c' ,'45' );
      System.currentPagereference().getParameters().put('testforpercentage__c' ,'56' );
      System.currentPagereference().getParameters().put('testforphone__c' ,'9393875678' );
      System.currentPagereference().getParameters().put('testforpicklist__c' ,'1' );
      System.currentPagereference().getParameters().put('testforpicklistmulti__c' ,'1;2;3' );
      System.currentPagereference().getParameters().put('testfortext__c' ,'testing for text' );
      System.currentPagereference().getParameters().put('testfortextarea__c' ,'testing for text area' );
      System.currentPagereference().getParameters().put('testfortextarealong__c' ,'testing for text area long' );
      System.currentPagereference().getParameters().put('testfortextarearich__c' ,'testing for text area rich' );
      System.currentPagereference().getParameters().put('submit' ,'submit' );
      
      
       System.Test.startTest();
       WTOHtmlFormController WTOHFCObj= new WTOHtmlFormController();
       WTOHFCObj.onload();
       System.Test.stopTest();
  }
  
      

}