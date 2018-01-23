@istest
public class AccountSearchTest {
 static testMethod void testMethod1() 
 {
 Account testAccount = new Account();
 testAccount.Name='TestAccountSearch' ;
 testAccount.type='Prospect' ;
 testAccount.shippingcity ='Nashville' ;
 testAccount.shippingstate ='Tennessee' ;
 testAccount.shippingpostalcode ='37209' ;
 testAccount.Accreditation__c ='Joint Commission' ;
 testAccount.facility_type__c ='Free Standing Facility' ;
 testAccount.private_practice__c ='Interventionist' ;
 testAccount.patient_sex__c ='All' ;
 testAccount.age_and_population__c ='Adult' ;
 testAccount.levels_of_care__c ='Residential' ;
 testAccount.Type_of_Treatment_Offered__c ='Substance Abuse' ;
 testAccount.Disorder_Treatment_and_Specialization__c ='Pain Management' ;
 testAccount.Mothers_with_Children__c ='Not Offered' ;
 testAccount.Public_Funded_Ins__c ='Medicare' ;
 testAccount.Insurance_List__c = 'BCBS';
 testAccount.Community_Partner__c = 'Black Bear Lodge';
 testAccount.Phone = '(120) 555-0173';
 //testAccount.ParentID = '001j000000Nq0fW';
 insert testAccount;
    
 Test.StartTest(); 

  PageReference pageRef = Page.Patient_Matchmaker;
  pageRef.getParameters().put('shippingcity', 'Nashville');
  pageRef.getParameters().put('shippingstate', 'Tennessee');
  pageRef.getParameters().put('shippingpostalcode', '37209');
  pageRef.getParameters().put('Accreditation', 'Joint Commission');
  pageRef.getParameters().put('facility_type', 'Free Standing Facility');
  pageRef.getParameters().put('private_practice', 'Interventionist');
  pageRef.getParameters().put('patient_sex', 'All');
  pageRef.getParameters().put('age_and_population', 'Adult');
  pageRef.getParameters().put('levels_of_care', 'Residential');
  pageRef.getParameters().put('Type_of_Treatment_Offered', 'Substance Abuse');
  pageRef.getParameters().put('Disorder_Treatment_and_Specialization', 'Pain Managemnt');
  pageRef.getParameters().put('Mothers_with_Children', 'Not Offered');
  pageRef.getParameters().put('Public_Funded_Ins', 'Medicare');
  pageRef.getParameters().put('Insurance_List', 'BCBS');
  pageRef.getParameters().put('Community_Partner', 'Black Bear Lodge');
  pageRef.getParameters().put('ParentText', 'Universal Health');
  Test.setCurrentPage(pageRef);
  AccountSearchController testAcct = new AccountSearchController();
     System.assert(testAcct.runSearch() == null);
     String testdebugsoql = testAcct.debugSoql;
     
     testAcct.toggleSort();
     System.assertequals(testAcct.sortDir, 'asc');
     
     List<String> testAccreditation = new List<String>();
     testAccreditation = testAcct.Accreditation;
     System.assertEquals(testAccreditation[0], 'CARF');
     List<String> testfacilities = new List<String>();
     testfacilities = testAcct.facility_type;
     System.assertEquals(testfacilities[0], 'Free Standing Facility');
     List<String> testprivate_practice = new List<String>();
     testprivate_practice = testAcct.private_practice;
     System.assertEquals(testprivate_practice[0], 'Couples and Family');
     List<String> testpatient_sex = new List<String>();
     testpatient_sex = testAcct.patient_sex;
     System.assertEquals(testpatient_sex[0], 'All');
     List<String> testage_and_population = new List<String>();
     testage_and_population = testAcct.age_and_population;
     System.assertEquals(testage_and_population[0], 'Adolescent');
     List<String> testlevels_of_care = new List<String>();
     testlevels_of_care = testAcct.levels_of_care;
     System.assertEquals(testlevels_of_care[0], 'None Specified');
     List<String> testType_of_Treatment_Offered = new List<String>();
     testType_of_Treatment_Offered = testAcct.Type_of_Treatment_Offered;
     System.assertEquals(testType_of_Treatment_Offered[0], 'Dual Diagnosis');
     List<String> testDisorder_Treatment_and_Specialization = new List<String>();
     testDisorder_Treatment_and_Specialization = testAcct.Disorder_Treatment_and_Specialization;
     System.assertEquals(testDisorder_Treatment_and_Specialization[0], 'Addiction');
     List<String> testMothers_with_Children = new List<String>();
     testMothers_with_Children = testAcct.Mothers_with_Children;
     System.assertEquals(testMothers_with_Children[0], 'Men with children');
     List<String> testPublic_Funded_Ins = new List<String>();
     testPublic_Funded_Ins = testAcct.Public_Funded_Ins;
     System.assertEquals(testPublic_Funded_Ins[0], 'Mass Health');
     List<String> testInsurance_List = new List<String>();
     testInsurance_List = testAcct.Insurance_List;
     System.assertEquals(testInsurance_List[0], '1st Medical Network');
     List<String> testCommunity_Partner = new List<String>();
     testCommunity_Partner = testAcct.Community_Partner;
     System.assertEquals(testCommunity_Partner[0], 'Black Bear Lodge');
     
     testacct.sortfield = 'badfield';
     testacct.runQuery();  
 Test.StopTest();
 }
}