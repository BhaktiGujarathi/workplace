public class PrintQuotePDFController {
	public Quote QuoteObj{get;set;}
	public String quoteId;
	
	public PrintQuotePDFController(){
		QuoteObj = new Quote();		 
        quoteId = ApexPages.CurrentPage().getparameters().get('id');
        System.debug('quoteId___________________________ '+quoteId);
		
		if(quoteId != null){
			QuoteObj = [SELECT QuoteNumber,Opportunity.Name,Name,Pay_Agreement_Worksheet__r.Name,Original_Estimate_of_Tx_Costs__c,Type__c,Determination_Script_Read_to_Patient__c,Select_as_Final_Quote__c,Payment_Agreement_Post_Discharge_Amount__c,FRN_Facility__c,Facility_Program__c,Facility_Program__r.Name,FRN_Facility__r.Name,Lifetime_Max__c,Annual_Max__c,Lifetime_Max_Used__c,Annual_Max_Used__c,Lifetime_Max_Remaining__c,Annual_Max_Remaining__c,Co_Pay__c,Out_of_Pocket_Max__c,Co_Pay_Met__c,Out_of_Pocket_Max_Met__c,Co_Pay_Remaining__c,Out_of_Pocket_Max_Remaining__c,Deductible__c,Deductible_Included_in_OOP__c,Deductible_Met__c FROM Quote where Id =: quoteId];			
			System.debug('QuoteObj_________________________ '+QuoteObj);
		}		
		
	}
	
}