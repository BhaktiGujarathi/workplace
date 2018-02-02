@isTest
public class TextSearchControllerTest{
static testMethod void Test(){
	
	Account acc = new Account();
	acc.name = 'test';
	insert acc;
	
	
	Contact con = new Contact();
	con.firstname = 'testing';
	con.lastname = 'test';
	insert con;
	
	TextSearchController obj = new TextSearchController();
	ApexPages.currentPage().getParameters().put('name','test'); 
	String s = obj.getJSON();
}
}