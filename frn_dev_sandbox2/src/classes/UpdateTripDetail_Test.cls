@isTest
public class UpdateTripDetail_Test{
	//testmethod
    static testmethod void test1(){

        Default_Pricebook__c pricebookName = new Default_Pricebook__c(Name = 'FRN Price Book',Default_Pricebook_Name__c = 'FRN Price Book');
		insert pricebookName;

		RecordType conRT = [select id from  RecordType where SobjectType='Contact' AND Name='Patient'];
		Contact con = new contact(Lastname = 'Test',RecordTypeId = conRT.id);
		insert con;

		RecordType oppRt = [select id from  RecordType where SobjectType='Opportunity' AND Name='Outpatient Treatment'];
		Opportunity opp = new Opportunity (Name = 'TestOpp', CloseDate = System.today(),StageName = '1. Prospecting',Contact__c = con.id,Probability = 10,RecordTypeId = oppRt.id);
		insert opp;

		RecordType accRT = [select id from  RecordType where SobjectType='Account' AND Name='Patient Account'];
		Account acc = new Account(Name = 'test',RecordTypeId = accRT.id );
		insert acc;

		Facility_Program__c FP = new Facility_Program__c(Name = 'test', FRN_Facility__c=acc.id);
		insert FP;
		Pay_Agreement_Worksheet__c PAW = new Pay_Agreement_Worksheet__c(Opportunity__c = opp.id,Deductible__c = 100, Facility_Program__c =FP.id,FRN_Facility__c=acc.id);
		insert PAW;

		Pricebook2 pb = new Pricebook2();
		pb.Name= 'FRN Price Book';
		pb.IsActive= true;
		insert pb;

		Id pricebookId = Test.getStandardPricebookId();

		Product2 pr = new Product2();
		pr.Name= 'Airfare';
		pr.Family= 'Insurance Cost Determination';
		pr.Available_to_Collect_at__c= 'Intake';
		pr.Sort_order__c= 1;
		pr.Payment_Application_Order__c= 1;
		pr.IsActive= true;
		insert pr;

		Product2 pr1 = new Product2();
		pr1.Name= 'Car Service';
		pr1.Family= 'Insurance Cost';
		pr1.Available_to_Collect_at__c= 'Intake';
		pr1.Sort_order__c= 2;
		pr1.Payment_Application_Order__c= 2;
		pr1.IsActive= true;
		insert pr1;

		Quote Q = new Quote(Name = 'Test',OpportunityId = opp.id,Pricebook2Id= pricebookId);
		insert Q;

		PricebookEntry pbe = new PricebookEntry();
		pbe.Pricebook2Id= pricebookId;
		pbe.Product2Id= pr.Id;
		pbe.IsActive= true;
		pbe.UnitPrice= 10;
		insert pbe;

		PricebookEntry pbe1 = new PricebookEntry();
		pbe1.Pricebook2Id= pricebookId;
		pbe1.Product2Id= pr1.Id;
		pbe1.IsActive= true;
		pbe1.UnitPrice= 11;
		insert pbe1;

		Quote qu = new Quote(Name = 'Test',OpportunityId = opp.id, Pricebook2Id= pricebookId );
		insert qu;

		Trip__c tp = new Trip__c(Patient__c = con.id, Opportunity__c = opp.id);
		insert tp;

		List<Reservation__c> resList = new List<Reservation__c>();
		Id RecRTId = Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Airfare').getRecordTypeId();
		Reservation__c rc = new Reservation__c(RecordTypeID = RecRTId, Trip__c = tp.id, Rate__c = 10, Total_Amount_Charged__c = 20);
		resList.add(rc);
		Reservation__c rc1 = new Reservation__c(RecordTypeID = RecRTId, Trip__c = tp.id, Rate__c = 10, Total_Amount_Charged__c = 20);
		resList.add(rc1);

		Id RecRTId1 = Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Car Service').getRecordTypeId();
		Reservation__c rc2 = new Reservation__c(RecordTypeID = RecRTId1, Trip__c = tp.id, Rate__c = 10, Total_Amount_Charged__c = 20);
		resList.add(rc2);
		Reservation__c rc3 = new Reservation__c(RecordTypeID = RecRTId1, Trip__c = tp.id, Rate__c = 10, Total_Amount_Charged__c = 20);
		resList.add(rc3);

		insert resList;

		QuoteLineItem qli1 = new QuoteLineItem(QuoteId = q.Id, PriceBookEntryId = pbe1.Id, Quantity = 1, UnitPrice = 100);
        insert qli1;

		QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = 100);
        insert qli;

		UpdateTripDetail.updateQLIs(''+qu.Id);
    }

    static testmethod void testCreateMissingQuoteLineItems(){
        Default_Pricebook__c pricebookName = new Default_Pricebook__c(Name = 'FRN Price Book',Default_Pricebook_Name__c = 'FRN Price Book');
		insert pricebookName;

		RecordType conRT = [select id from  RecordType where SobjectType='Contact' AND Name='Patient'];
		Contact con = new contact(Lastname = 'Test',RecordTypeId = conRT.id);
		insert con;

		RecordType oppRt = [select id from  RecordType where SobjectType='Opportunity' AND Name='Outpatient Treatment'];
		Opportunity opp = new Opportunity (Name = 'TestOpp', CloseDate = System.today(),StageName = '1. Prospecting',Contact__c = con.id,Probability = 10,RecordTypeId = oppRt.id);
		insert opp;

		RecordType accRT = [select id from  RecordType where SobjectType='Account' AND Name='Patient Account'];
		Account acc = new Account(Name = 'test',RecordTypeId = accRT.id );
		insert acc;

		Facility_Program__c FP = new Facility_Program__c(Name = 'test', FRN_Facility__c=acc.id);
		insert FP;
		Pay_Agreement_Worksheet__c PAW = new Pay_Agreement_Worksheet__c(Opportunity__c = opp.id,Deductible__c = 100, Facility_Program__c =FP.id,FRN_Facility__c=acc.id);
		insert PAW;

		Pricebook2 pb = new Pricebook2();
		pb.Name= 'FRN Price Book';
		pb.IsActive= true;
		insert pb;

		Id pricebookId = Test.getStandardPricebookId();

		Product2 pr = new Product2();
		pr.Name= 'Airfare';
		pr.Family= 'Insurance Cost Determination';
		pr.Available_to_Collect_at__c= 'Intake';
		pr.Sort_order__c= 1;
		pr.Payment_Application_Order__c= 1;
		pr.IsActive= true;
		pr.Auto_Add_to_Quote_Line_Items__c = true;
		insert pr;

		Product2 pr1 = new Product2();
		pr1.Name= 'Car Service';
		pr1.Family= 'Insurance Cost';
		pr1.Available_to_Collect_at__c= 'Intake';
		pr1.Sort_order__c= 2;
		pr1.Payment_Application_Order__c= 2;
		pr1.IsActive= true;
		pr1.Auto_Add_to_Quote_Line_Items__c = true;
		insert pr1;

		Quote Q = new Quote(Name = 'Test',OpportunityId = opp.id,Pricebook2Id= pricebookId);
		insert Q;


		//create standard pricebook entries

		PricebookEntry pbeStandard = new PricebookEntry();
		pbeStandard.Pricebook2Id= pricebookId;
		pbeStandard.Product2Id= pr.Id;
		pbeStandard.IsActive= true;
		pbeStandard.UnitPrice= 10;
		insert pbeStandard;

		PricebookEntry pbe1Standard = new PricebookEntry();
		pbe1Standard.Pricebook2Id= pricebookId;
		pbe1Standard.Product2Id= pr1.Id;
		pbe1Standard.IsActive= true;
		pbe1Standard.UnitPrice= 11;
		insert pbe1Standard;

		//create custom pricebook entry

		PricebookEntry pbe = new PricebookEntry();
		pbe.Pricebook2Id= pb.Id;
		pbe.Product2Id= pr.Id;
		pbe.IsActive= true;
		pbe.UnitPrice= 10;
		insert pbe;

		PricebookEntry pbe1 = new PricebookEntry();
		pbe1.Pricebook2Id= pb.Id;
		pbe1.Product2Id= pr1.Id;
		pbe1.IsActive= true;
		pbe1.UnitPrice= 11;
		insert pbe1;

		Quote qu = new Quote(Name = 'Test',OpportunityId = opp.id, Pricebook2Id= pricebookId );
		insert qu;

		Trip__c tp = new Trip__c(Patient__c = con.id, Opportunity__c = opp.id);
		insert tp;

		List<Reservation__c> resList = new List<Reservation__c>();
		Id RecRTId = Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Airfare').getRecordTypeId();
		Reservation__c rc = new Reservation__c(RecordTypeID = RecRTId, Trip__c = tp.id, Rate__c = 10, Total_Amount_Charged__c = 20);
		resList.add(rc);
		Reservation__c rc1 = new Reservation__c(RecordTypeID = RecRTId, Trip__c = tp.id, Rate__c = 10, Total_Amount_Charged__c = 20);
		resList.add(rc1);

		Id RecRTId1 = Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Car Service').getRecordTypeId();
		Reservation__c rc2 = new Reservation__c(RecordTypeID = RecRTId1, Trip__c = tp.id, Rate__c = 10, Total_Amount_Charged__c = 20);
		resList.add(rc2);
		Reservation__c rc3 = new Reservation__c(RecordTypeID = RecRTId1, Trip__c = tp.id, Rate__c = 10, Total_Amount_Charged__c = 20);
		resList.add(rc3);

		insert resList;

		QuoteLineItem qli1 = new QuoteLineItem(QuoteId = q.Id, PriceBookEntryId = pbe1.Id, Quantity = 1, UnitPrice = 100);
        //insert qli1;

		QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = 100);
        //insert qli;

		UpdateTripDetail.updateQLIs(''+qu.Id);
    }

}