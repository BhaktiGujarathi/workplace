@isTest
public class Oppcontroller_Test{
		static testMethod void test1(){
		
		Opportunity opp =  new Opportunity (Name = 'TestOpp', CloseDate = System.today(), StageName = '1. Prospecting');
            INSERT opp;  
			ApexPages.StandardController  sc = new ApexPages.StandardController(opp); 
			Oppcontroller opp1 = new Oppcontroller(sc);
			opp1.valsText='1. Prospecting:1. Prospecting';
			opp1.reload();
			 
		
	
		}
		

}