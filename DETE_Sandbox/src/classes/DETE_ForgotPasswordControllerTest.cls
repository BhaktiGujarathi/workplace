/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DETE_ForgotPasswordControllerTest {

     static testMethod void myUnitTest() {
     	User user;
        Account ac;
		Contact con;
     	//User thisUser = [SELECT Id FROM User WHERE firstname='Sachin' AND IsActive=: true Limit 1];
     	
         Id p = [select id from profile where name='Customer Community Login User'].id;
         //Id roleId = [Select u.Name, u.Id From UserRole u limit 1].id;
         ac = new Account(name ='Grazitti') ;
         insert ac; 
         con = new Contact(LastName ='testCon',AccountId = ac.Id);
         insert con; 
        
         user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true, ContactId = con.Id,               
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com',PortalRole = 'Manager'); //,UserRoleId = roleId
       
        insert user;
        //User user = DETE_DataFactory.getUSerRecord(true);
      system.runas(user){
     // User user = DETE_DataFactory.getUSerRecord(true);
      DETE_ForgotPasswordController controller = new DETE_ForgotPasswordController();
      controller.usernameStr= '';  
      controller.forgotPassword();
      
      controller.usernameStr= 'tester@noemail.com';  
      controller.forgotPassword();
      
      controller.usernameStr= 'teste';  
      controller.forgotPassword();
      controller.closeError();
      }
      //Test.stopTest();
     }
      /*@IsTest(SeeAllData=true) public static void testForgotPasswordController() {
      // Instantiate a new controller with all parameters in the page
      DETE_ForgotPasswordController controller = new DETE_ForgotPasswordController();
      controller.usernameStr = 'test@salesforce.com';       
    
      //System.assertEquals(controller.forgotPassword(),null); 
    }*/
}