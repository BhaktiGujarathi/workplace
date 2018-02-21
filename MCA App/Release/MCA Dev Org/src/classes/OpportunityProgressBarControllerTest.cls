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
private class OpportunityProgressBarControllerTest {
    
    static testMethod void myUnitTest() {                       
        // TO DO: implement unit test
        Test.startTest();
        Opportunity objOppo = new Opportunity(Name='TestOpp', CloseDate = System.today(), 
                                              StageName='Prospecting', payment_Amount__c = 100, 
                                              Funding_Amount__c =50);
        insert objOppo; 
        objOppo.StageName = 'Application Sent';
        update objOppo;
        system.debug('$$$$$$$$$$$$$$$objOppo[0].Id '+objOppo.Id);
        Test.stopTest();
        
        
       Apexpages.Pagereference P = Page.OpportunityProgressBar;
        P.getParameters().put('Id', objOppo.Id);
        test.setCurrentPage(P);
        ApexPages.StandardController sc = new ApexPages.StandardController(objOppo);
        OpportunityProgressBarController controller = new OpportunityProgressBarController(sc);
        //Integer val = controller.testmethods(10);
        //System.assertEquals(13,val);
    }
}