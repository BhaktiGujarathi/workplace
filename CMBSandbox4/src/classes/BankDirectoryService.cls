@RestResource(urlMapping = '/bankservice/*')
global with sharing class BankDirectoryService {

    private static final String API_TOKEN = '3MVG9ahGHqp.k2_w6slxY00RhQCW0KyvSy7qSIf3AC7K7jY9H5jB4jIzPttOQz6vrRe9ZAWEqYDt_X.vwIoah5262272345805254521';

    private static RestRequest restRequest;
    private static RestResponse restResponse;
    private static Bank[] banks;

    @HttpGet
    global static Bank[] doGet() {
    	banks = new Bank[]{};
        restRequest = RestContext.request;
        restResponse = RestContext.response;
        
        Map<String, String> parameters = restRequest.params;
        
        if (isValidRequest()) {  
            restResponse.statusCode = 200;   
            try {
            	Integer offset = Integer.valueOf(parameters.get('offset'));
            	query(offSet);
            }
            catch (Exception ex) {
            	restResponse.statusCode = 500;
            }
        }
        else { 
            restResponse.statusCode = 401;
        }
        return banks;
    }    


    public static Bank[] doGet(Integer offset) {
        banks = new Bank[]{};
        query(offSet); 
        return banks;
    }
    

    private static Boolean isValidRequest() {
        String oid = restRequest.headers.get('oid');
        String apiKey = restRequest.headers.get('apiKey');
        String apiToken = restRequest.headers.get('apiToken');

        if (apiToken == API_TOKEN) {
            return true;
        }

        return false;
    }


    public static void queryBanks(Integer offSet) {
    	banks = new Bank[]{};
    	
    	query(offSet);
    }
    
    
    private static void query(Integer paging) {
    	Set <String> bankIds = new Set <String>();
    	Map <String, Program__c[]> programsMap = new Map<String, Program__c[]>();
    	
        Bank__c[] objectBanks = [SELECT Name
                                      , Id
                                      , Billing_City__c
                                      , Billing_Postal_Code__c
                                      , Billing_State__c
                                      , Billing_Street__c
                                      , Email__c
                                      , Phone__c
                                      , Website__c 
                                      , Bank_Id__c
                                   FROM Bank__c
                                  WHERE API_Exposed__c = true
                                  LIMIT 100 
                                 OFFSET :paging];
        
        for (Bank__c b : objectBanks) {
        	bankIds.add(b.Id);
        }
        
        Program__c[] objectPrograms = [select Name
                                            , BK_Policy__c
                                            , External_Bank__c
                                            , Funding_Amt_of_Monthly_Gross_Sales__c
                                            , Max_Amount__c
                                            , Max_No_NSFs__c
                                            , Min_Avg_Daily_Bal__c
                                            , Methods_of_Repayment__c
                                            , Credit_Score__c
                                            , Min_Credit_Score__c
                                            , Minimum_Deposit_Count__c
                                            , Min_Monthly_CC_Avg__c
                                            , Min_Monthly_Deposits__c
                                            , Years_in_Business__c
                                            , Minimum_Advance__c
                                            , Notes__c
                                            , Ownership_Percentage_Requirement__c
                                            , Percentage_Net_After_Payoff__c
                                            , Program_Id__c
                                            , Program_Directory_Status__c
                                            , Restricted_Industry_List__c
                                            , Restricted_States__c
                                            , Site_Inspection__c
                                            , Submission_Email__c
                                            , Tax_Lean_Policy__c
                                            , Trade_References__c
                                            , Transaction_Count__c
                                            , Turnaround_Time__c
                                            , (select Name
                                                    , Required_Document_Id__c
                                                    , Program__c
                                                 from Required_Documents__r)
                                         from Program__c
                                        where External_Bank__c in :bankIds];
        
        
        for (Program__c p : objectPrograms) {
        	if (programsMap.containsKey(p.External_Bank__c)) {
        		programsMap.get(p.External_Bank__c).add(p);
        	}
        	else {
        		programsMap.put(p.External_Bank__c, new Program__c[]{p});
        	}
        }
        
        
        Bank bank;
        Program program;
        RequiredDocument document;
        for (Bank__c b : objectBanks) {
        	bank = new Bank(b);
        	if (programsMap.containsKey(b.Id)) {
	        	for (Program__c p : programsMap.get(b.Id)) {
	        		program = new Program(p);
	        		for (Required_Documents__c doc : p.Required_Documents__r) {
	        			document = new RequiredDocument(doc);
	        			program.requiredDocuments.add(document);
	        		}
	        		bank.programs.add(program);
	        	}
        	}
        	
        	banks.add(bank);
        }
    }
}