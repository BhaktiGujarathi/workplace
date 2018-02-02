@isTest
public class OpportunityLineItemHandlerTest{
    
    public static TestMethod void OpportunityLineItemHandler_UnitTest(){   
        Id pricebookId = Test.getStandardPricebookId();

        //Create your product
        Product2 prod = new Product2(
             Name = 'Residential Treatment',
             ProductCode = 'Pro-X',
             isActive = true
        );
        insert prod;

        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
             Pricebook2Id = pricebookId,
             Product2Id = prod.Id,
             UnitPrice = 100.00,
             IsActive = true
        );      
        insert pbEntry;
        
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId();
        Opportunity opp= new Opportunity();
        opp.Name='test';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        opp.RecordTypeId = oppRecordTypeId;
        opp.PriceBook2Id = pricebookId;
        insert opp; 
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
             OpportunityId = opp.Id,
             Quantity = 5,
             PricebookEntryId = pbEntry.Id,
             TotalPrice = 2 * pbEntry.UnitPrice
        );
        insert oli;
        
        OpportunityLineItem oli1 = new OpportunityLineItem(
             OpportunityId = opp.Id,
             Quantity = 5,
             PricebookEntryId = pbEntry.Id,
             TotalPrice = 2 * pbEntry.UnitPrice
        );
        insert oli1;
        OpportunityLineItemHandler oLIH = new OpportunityLineItemHandler();
        oLIH.bulkBefore();
        oLIH.beforeDelete(oli);
        oLIH.beforeUpdate(oli, oli1);
        oLIH.beforeInsert(oli);
        oLIH.afterInsert(oli);
        oLIH.afterUpdate(oli, oli1);
        oLIH.afterDelete(oli);
        oLIH.afterUndelete(oli);        
    }

}