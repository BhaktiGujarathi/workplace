@isTest
public class ReservationHandlerTest {
        private static testMethod  void ReservationHandler_test(){	
		Default_Pricebook__c pricebookName = new Default_Pricebook__c(Name = 'FRN Price Book',Default_Pricebook_Name__c = 'FRN Price Book');
		insert pricebookName;
		
		Pricebook2 prod = new Pricebook2(Name = pricebookName.Default_Pricebook_Name__c);
		insert prod;
		
		Account acc = new Account();
		acc.Name = 'test';
		insert acc;
		
		Contact con = new Contact();
		con.LastName = 'test';
		con.AccountId = acc.Id;
		con.Social_Security_Number__c = 'test#';
		insert con;
		
		Opportunity opp = new Opportunity();
		opp.StageName = 'Prospecting';
		opp.Name = 'test';
		opp.Have_You_Attended_Anger_Mgmt_Class__c = 'Yes';
		opp.CloseDate = System.today();
		insert opp;          
		
		Product2 p2 = new Product2(Auto_Add_to_Quote_Line_Items__c = true, Name = 'Car Service', Family = 'Insurance Cost');
		insert p2;
		
		Id pbId = Test.getStandardPricebookId();
		PricebookEntry pbe = new PricebookEntry(Pricebook2id=pbId,Product2id=p2.Id,unitprice=1.0, isActive=true);
		insert pbe;
		System.debug('prod ::>'+prod);
		PricebookEntry pbe1 = new PricebookEntry(Pricebook2id=prod.Id,Product2id=p2.Id,unitprice=1.0, isActive=true);
		insert pbe1;		
		
		Quote quo = new Quote();
		quo.Name = 'test';
		quo.opportunityId = opp.Id;
		quo.FRN_Facility__c = acc.Id;
		quo.Insurance_Company__c = acc.Id;
		quo.Pricebook2Id= prod.Id;
		quo.Insurance_Company_Contract_Type__c = 'In Network';
		insert quo; 
		
		QuoteLineItem qli = new QuoteLineItem();
		qli.QuoteId = quo.Id;
		qli.PriceBookentryId = pbe1.id;
		qli.Product2Id = p2.id;
		qli.Quantity = 1;
		qli.Auto_Added__c = true;
		qli.UnitPrice = 10;
		insert qli;
		
		Trip__c tp = new Trip__c(Patient__c = con.id, Opportunity__c = opp.id);
		insert tp;
		
		Id RecRTId = Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Airfare').getRecordTypeId();
		Reservation__c rc = new Reservation__c(RecordTypeID = RecRTId, Trip__c = tp.id, Rate__c = 10,Departure_Airport__c = 'PDX',Arrival_Airport__c = 'DEN', Total_Amount_Charged__c = 20);
		insert rc;
		update rc;
		delete rc;
		undelete rc;
		
		/* RecRTId = Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Car Service').getRecordTypeId();
		Reservation__c rc1 = new Reservation__c(RecordTypeID = RecRTId, Trip__c = tp.id, Rate__c = 10, Total_Amount_Charged__c = 20);
		insert rc1; 
		delete rc1;
		undelete rc1;		
		update rc1;
			
		ApexPages.StandardController sc2 = new ApexPages.StandardController(rc1);
            ReservationHandler Rh = new ReservationHandler();
			Rh.bulkAfter();
			Rh.afterInsert(rc1);
			Rh.afterUpdate(rc, rc1);
			Rh.afterUndelete(rc1);
			Rh.andFinally();
			Rh.processQLI(rc1);
			Rh.createQLI('Car Service', quo.Id ,rc1); */
	}
}