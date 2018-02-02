@isTest
public class ReservationTrigger_Test{
    static testmethod void test1(){
		Opportunity opp = new Opportunity(Name = 'Test Opportunity',StageName='Prospecting', CloseDate= Date.today());
		insert opp;
		Trip__c tr = new Trip__c(Opportunity__c = opp.Id);
		insert tr;
		Reservation__c res = new Reservation__c(Trip__c = tr.Id);
		insert res;

    }
}