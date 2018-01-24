public with sharing class BankDirectoryController {
    private static final String CONSUMER_KEY = '3MVG9ahGHqp.k2_w6slxY00RhQCW0KyvSy7qSIf3AC7K7jY9H5jB4jIzPttOQz6vrRe9ZAWEqYDt_X.vwIoah';
    private static final String CONSUMER_SECRET = '5262272345805254521';
    private static final String USER = 'cabenaim@gmail.com.sandbox2';
    private static final String PASS = '101henry';
    private static final Boolean IS_SANDBOX = true;
    
    transient BankWrapper[] banks;
    public Boolean processingBanks { get; set; }
    public Admin_Bank_Directory_Settings__c bankDirectorySettings { get; set; }
    
    private String  accessToken;
    private String  sfdcInstanceUrl;


    public BankDirectoryController() {
    	processingBanks = false;
    	bankDirectorySettings = Admin_Bank_Directory_Settings__c.getOrgDefaults();
    	
    	
        String uri = 'https://' + (IS_SANDBOX ? 'test' : 'login') + '.salesforce.com/services/oauth2/token';
        String clientId  = EncodingUtil.urlEncode(CONSUMER_KEY,'UTF-8');
        String clientSecret = EncodingUtil.urlEncode(CONSUMER_SECRET,'UTF-8');
        String username = EncodingUtil.urlEncode(USER,'UTF-8');
        String password = EncodingUtil.urlEncode(PASS,'UTF-8');

        String body = 'grant_type=password' + '&client_id=' + clientId + '&client_secret=' + clientSecret + '&username=' + username + '&password=' + password; 

        HttpResponse hRes = send(uri, 'POST', body);
        
        if (hRes.getStatusCode() != 200)  {
            throw new BankDirectoryException('[HTTP-01] OAuth 2.0 access token request error. Verify username, password, consumer key, consumer secret, isSandbox? ' + ' StatusCode=' + hRes.getStatusCode() + ' statusMsg=' + hRes.getStatus());
        }

        Map<String,String> res = (Map<String,String>) JSON.deserialize(hRes.getBody(),Map<String,String>.class);

        this.accessToken       = res.get('access_token'); 
        this.sfdcInstanceUrl   = res.get('instance_url');   
    }


    private HttpResponse send(String uri, String httpMethod, String body) {
        Http h = new Http();
        HttpRequest hRqst = new HttpRequest();
        hRqst.setEndpoint(uri);
        hRqst.setMethod(httpMethod);
        hRqst.setTimeout(12000); 
        hRqst.setHeader('oid', String.valueOf(UserInfo.getOrganizationId()));
        
        if (body != null) {
            hRqst.setBody(body);       
        }

        if (this.accessToken != null) {
            hRqst.setHeader('Authorization','Bearer ' + this.accessToken);
        }
        return h.send(hRqst);
    }   
    
    
    private List<object> query(Integer offset) {
        PageReference pr = new PageReference(this.sfdcInstanceUrl + '/services/apexrest/bankservice');
        pr.getParameters().put('offset', String.valueOf(offset)); 
        String uri = pr.getUrl();               
        HttpResponse hRes = send(uri, 'GET', null);
        if (hRes.getStatusCode() != 200) {
            throw new BankDirectoryException('[HTTP-02] Error in parameters ' + uri + ' StatusCode=' + hRes.getStatusCode() + ' statusMsg=' + hRes.getStatus());
        }
        system.debug('\n\nBody >> ' + hRes.getBody());
        
        List<object> response = (List<object>) JSON.deserializeUntyped(hRes.getBody());
        system.debug('\n\nResponse >> ' + response);
        return response;
    }       
    
    
    private Set<String> getsObjectDescribe() {
        Set<String> sObjectDescribe = new Set<String> ();
        
        PageReference pr = new PageReference(this.sfdcInstanceUrl + '/services/data/v30.0/sobjects/Program__c/describe/');
        String uri = pr.getUrl();
        HttpResponse hRes = send(uri, 'GET', null);
        
        Map<String,object> response = (Map<String,object>) JSON.deserializeUntyped(hRes.getBody());
        
        List<object> fields = (List<object>) response.get('fields');
        for (object o : fields) {
            Map<String,object> r = (Map<String,object>) o;
            if (!sObjectDescribe.contains(String.valueOf(r.get('name'))) && String.valueOf(r.get('name')) != 'Id') {
                sObjectDescribe.add(String.valueOf(r.get('name')));
            }
        }
        return sObjectDescribe;
    }
    
    
    public BankWrapper[] getBanks() {
    	if (banks == null) {
    	   queryBanks();
    	}
    	
    	return banks;
    }


    public void queryBanks() {
        queryBanks(false);
    }


    public void queryBanks(Boolean forceStart) {
    	if (bankDirectorySettings.Import_Job_Id__c == null || forceStart) {
    	    processingBanks = false;
	        Set<String> sObjectDescribe = getsObjectDescribe();
	        String programQuery = 'Id';
	        for (String s : sObjectDescribe) {
	            programQuery += ', ' + s;
	        }
	        
	        banks = new BankWrapper[]{};
	        recursiveQuery(0);
    	}
    	else {
    	    processingBanks = true;
    	}
    }	
        

    private void recursiveQuery(Integer page) {        
    	

        Map<String,BankWrapper> bankMap = new Map<String,BankWrapper>();
        Map<String,ProgramWrapper> programMap = new Map<String,ProgramWrapper>();
        Map<String,RequiredDocumentWrapper> requiredDocumentsMap = new Map<String,RequiredDocumentWrapper>();
        
        for (object o : query(page)) {
            Map<String,object> r = (Map<String,object>) o;

            BankWrapper bw = new BankWrapper();
            bw.bankId = String.valueOf(r.get('bankId'));
            bw.name = String.valueOf(r.get('name'));
            bw.phone = String.valueOf(r.get('phone'));
            bw.email = String.valueOf(r.get('email'));
            bw.website = String.valueOf(r.get('website'));
            bw.billingStreet = String.valueOf(r.get('billingStreet'));
            bw.billingCity = String.valueOf(r.get('billingCity'));
            bw.billingState = String.valueOf(r.get('billingState'));
            bw.billingPostalCode = String.valueOf(r.get('billingPostalCode'));

            if (r.get('programs') != null) {
                for (object co : (object[]) r.get('programs')) {
                    Map<String,object> c = (Map<String,object>) co;
                    ProgramWrapper pw = setProgram(c);
                    bw.programs.add(pw);
                    
                    for (object doc : (object[]) c.get('requiredDocuments')) {
                    	Map<String,object> d = (Map<String,object>) doc;
                    	RequiredDocumentWrapper rdw = new RequiredDocumentWrapper();
	                    rdw.requiredDocumentId = String.valueOf(d.get('requiredDocumentId'));
	                    rdw.name = String.valueOf(d.get('name'));
	                    pw.requiredDocuments.add(rdw);
	                    requiredDocumentsMap.put(rdw.requiredDocumentId, rdw);
                    }
                    
                    programMap.put(pw.programId, pw);
                }
            }

            banks.add(bw);
            bankMap.put(bw.bankId, bw);
        }

        banks.sort();

        for (Account a : [select Bank_Id__c, Name, (select Program_Id__c from Programs__r where Program_Id__c != null) from Account where Bank_Id__c = :bankMap.keySet() and Bank_Id__c != null]) {
            
            if (bankMap.get(a.Bank_Id__c) != null) {
                bankMap.get(a.Bank_Id__c).auxOppty.AccountId = a.Id;
                bankMap.get(a.Bank_Id__c).accountName = a.Name;

                for (Program__c p : a.Programs__r) {
                    if (programMap.get(p.Program_Id__c) != null) {
                        programMap.get(p.Program_Id__c).sfdcId = p.Id;
                    }
                }
            }   
        }

        for (Required_Documents__c rd : [select Required_Document_Id__c from Required_Documents__c where Required_Document_Id__c != null]) {
            if (requiredDocumentsMap.get(rd.Required_Document_Id__c) != null) {
                requiredDocumentsMap.get(rd.Required_Document_Id__c).sfdcId = rd.Id;
            }
        }

        for (BankWrapper bw : banks) {
            if (bw.getStatus() == 'New') {
                bw.selected = true;
            }
        }
        
        if (!bankMap.isEmpty()) {
            page += 100;
            recursiveQuery(page);
        }
    }
    
    
    public void importBanks() {
    	bankDirectorySettings.Import_Job_Id__c = Database.executeBatch(new BankDirectoryBatch(banks), BankDirectoryBatch.BATCH_SIZE);
    	upsert bankDirectorySettings;
    	processingBanks = true;
    }
    
    
    private ProgramWrapper setProgram(Map<String,object> c) {
    	ProgramWrapper pw = new ProgramWrapper();
        pw.programId = String.valueOf(c.get('programId'));
        pw.name = String.valueOf(c.get('name'));
        
        pw.bKPolicy = String.valueOf(c.get('bkPolicy'));
        pw.fundingAmtofMonthlyGrossSales = Double.valueOf(c.get('fundingAmtofMonthlyGrossSales'));
        pw.maxAmount = Double.valueOf(c.get('maxAmount'));
        pw.maxNoNSFs = Double.valueOf(c.get('maxNoNSFs'));
        pw.methodsOfRepayment = String.valueOf(c.get('methodsOfRepayment'));
        pw.minAvgDailyBal = Double.valueOf(c.get('minAvgDailyBal'));
        pw.creditScore = Double.valueOf(c.get('creditScore'));
        pw.minCreditScore = Double.valueOf(c.get('minCreditScore'));
        pw.minimumDepositCount = Double.valueOf(c.get('minimumDepositCount'));
        pw.minMonthlyCCAvg = Double.valueOf(c.get('minMonthlyCCAvg'));
        pw.minMonthlyDeposits = Double.valueOf(c.get('minMonthlyDeposits'));
        pw.yearsInBusiness = Integer.valueOf(c.get('yearsInBusiness'));
        pw.minimumAdvance = Double.valueOf(c.get('minimumAdvance'));
        pw.notes = String.valueOf(c.get('notes'));
        pw.ownershipPercentageRequirement = Double.valueOf(c.get('ownershipPercentageRequirement'));
        pw.percentageNetAfterPayoff = Double.valueOf(c.get('percentageNetAfterPayoff'));
        pw.restrictedIndustryList = String.valueOf(c.get('restrictedIndustryList'));
        pw.restrictedStates = String.valueOf(c.get('restrictedStates'));
        pw.siteInspection = Boolean.valueOf(c.get('siteInspection'));
        pw.submissionEmail = String.valueOf(c.get('submissionEmail'));
        pw.taxLeanPolicy = String.valueOf(c.get('taxLeanPolicy'));
        pw.tradeReferences = String.valueOf(c.get('tradeReferences'));
        pw.transactionCount = Double.valueOf(c.get('transactionCount'));
        pw.turnAroundTime = Double.valueOf(c.get('turnAroundTime'));
        pw.Status = String.valueOf(c.get('programDirectoryStatus'));
    	return pw;
    }
    
    
    public BankWrapper[] getAllBanks() {
        queryBanks(true);

        for (BankWrapper bw : banks) {
            bw.selected = true;
        }

        return banks;
    }



    public class BankWrapper implements Comparable {
        public Boolean selected { get; set; }
        public String bankId { get; set; }
        public String name { get; set; }
        public String email { get; set; }
        public String phone { get; set; }
        public String website { get; set; }
        public String billingStreet { get; set; }
        public String billingCity { get; set; }
        public String billingState { get; set; }
        public String billingPostalCode { get; set; }
        public String accountName { get; set; }
        public String accountURL { get; set; }

        public Opportunity auxOppty { get; set; }
        public ProgramWrapper[] programs { get; set; }

        public BankWrapper() {
            selected = false;
            auxOppty = new Opportunity();
            programs = new ProgramWrapper[]{};
        } 


        public String getStatus() {
            if (auxOppty.AccountId == null) {
                return 'New';
            }
            else {
                return 'Synced';
            }
        }


        public Integer compareTo(Object o) {
            BankWrapper compare = (BankWrapper) o;

            if (name == compare.name) { return 0; }
            if (name >  compare.name) { return 1; }
            return -1;
        }
    }



    public class ProgramWrapper {
        public String programId { get; set; }
        public String name { get; set; }
        public String bKPolicy { get; set; }
        public Double fundingAmtofMonthlyGrossSales { get; set; }
        public Double maxAmount { get; set; }
        public Double maxNoNSFs { get; set; }
        public String methodsOfRepayment { get; set; }
        public Double minAvgDailyBal { get; set; }
        public Double creditScore { get; set; }
        public Double minCreditScore { get; set; }
        public Double minimumDepositCount { get; set; }
        public Double minMonthlyCCAvg { get; set; }
        public Double minMonthlyDeposits { get; set; }
        public Integer yearsInBusiness { get; set; }
        public Double minimumAdvance { get; set; }
        public String notes { get; set; }
        public Double ownershipPercentageRequirement { get; set; }
        public Double percentageNetAfterPayoff { get; set; }
        public String restrictedIndustryList { get; set; }
        public String restrictedStates { get; set; }
        public Boolean siteInspection { get; set; }
        public String submissionEmail { get; set; }
        public String taxLeanPolicy { get; set; }
        public String tradeReferences { get; set; }
        public Double transactionCount { get; set; }
        public Double turnAroundTime { get; set; }
        public String Status {get; set; }
        
        public String sfdcId { get; set; }
        public Program__c auxProgram { get; set; }
        public RequiredDocumentWrapper[] requiredDocuments { get; set; }

        public ProgramWrapper() {
            requiredDocuments = new RequiredDocumentWrapper[]{};
        }
    }



    public class RequiredDocumentWrapper {
        public String requiredDocumentId { get; set; }
        public String name { get; set; }
        public String sfdcId { get; set; }
    }



    public class BankDirectoryException extends Exception {}
}