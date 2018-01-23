@isTest
private class AccountSearchControllerTest 
{
 
    Static testMethod void AccountSearchController_Test()
    {
        account acc = new account();
        acc.name='test';
        acc.Priority_Step_Down__c=true;
        acc.shippingstreet='SM City North EDSA';
        acc.shippingcity='new york';
        acc.shippingstate='California';
        acc.shippingpostalcode='012345';
        acc.phone= '(123) 456-7890';
        acc.type='Prospect';
        acc.low_cost__c=false;
        acc.Type_of_Treatment_Offered__c='Dual Diagnosis';
        acc.Disorder_Treatment_and_Specialization__c='Addiction';
        acc.patient_sex__c='Female';
        acc.ram_hit_list__c=true;
        acc.enabled__c=true;
        acc.do_not_refer__c=false;
        insert acc;
        List<String> stracc = new List<String>();
        List<String> stracc1 = new List<String>();
        //stracc.add('str');
        stracc1.add('str');
        Apexpages.currentPage().getParameters().put('shippingcity',acc.shippingcity);
        Apexpages.currentPage().getParameters().put('shippingstate',acc.shippingstate);
        Apexpages.currentPage().getParameters().put('shippingpostalcode',acc.shippingpostalcode);
        Apexpages.currentPage().getParameters().put('Accreditation','test');
        Apexpages.currentPage().getParameters().put('facility_type','test');
        Apexpages.currentPage().getParameters().put('private_practice','test');
        Apexpages.currentPage().getParameters().put('patient_sex','test');
        Apexpages.currentPage().getParameters().put('age_and_population','test');
        Apexpages.currentPage().getParameters().put('levels_of_care','test');
        Apexpages.currentPage().getParameters().put('Type_of_Treatment_Offered','test');
        Apexpages.currentPage().getParameters().put('Disorder_Treatment_and_Specialization','test');
        Apexpages.currentPage().getParameters().put('Mothers_with_Children','test');
        Apexpages.currentPage().getParameters().put('Public_Funded_Ins','test');
        Apexpages.currentPage().getParameters().put('Insurance_List','null');
        Apexpages.currentPage().getParameters().put('Community_Partner','test');
        Apexpages.currentPage().getParameters().put('ParentText','test');
        
        AccountSearchController accs = new AccountSearchController();
            accs.runSearch();
            accs.toggleSort();
            accs.debugSoql = 'test';
            stracc = accs.Accreditation;
            stracc = accs.facility_type;
            stracc = accs.private_practice;
            stracc = accs.patient_sex;
            stracc = accs.age_and_population;
            stracc = accs.levels_of_care;
            stracc = accs.Type_of_Treatment_Offered;
            stracc = accs.Disorder_Treatment_and_Specialization;
            stracc =accs.Mothers_with_Children;
            stracc = accs.Public_Funded_Ins;
            stracc = accs.Insurance_List;
            stracc = accs.Community_Partner;
            string sss = accs.ParentText;
    }
    
}