global with sharing class BankDirectoryBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful { 

	private BankDirectoryController.BankWrapper[] banks;
	
	public static final Integer BATCH_SIZE = 50;
	
	
    public BankDirectoryBatch() {}


	public BankDirectoryBatch(BankDirectoryController.BankWrapper[] b) {
		this.banks = b;
	}


	global Iterable<sObject> start(Database.BatchableContext bc) {
		
		if (banks == null) {
            BankDirectoryController cls = new BankDirectoryController();
            banks = cls.getAllBanks();
        }

        Task[] result = new Task[] {};

        for (Integer i = 0; i < banks.size(); i++) {
            result.add(new Task(Subject=String.valueOf(i)));
        }

        return result;
	}
	
	
	global void execute(Database.BatchableContext bc, sObject[] scope) {
		Task[] result = (Task []) scope;
        System.Savepoint sp = Database.setSavepoint();
        
        try {
        	BankDirectoryController.BankWrapper[] banksList = new BankDirectoryController.BankWrapper[]{};
            for (Task elem :result) {
                 banksList.add(banks.get(Integer.valueOf(elem.Subject)));
            }
            system.debug(banksList.size());
            importBanks(banksList);
            
        }
        catch (Exception ex) {
        	Database.rollback(sp);
        }
	}
	
	
    global void finish(Database.BatchableContext bc) {
    	Admin_Bank_Directory_Settings__c bankDirectorySettings = Admin_Bank_Directory_Settings__c.getOrgDefaults();
    	bankDirectorySettings.Import_Job_Id__c = null;
    	upsert bankDirectorySettings;
    }
    
    
    private void importBanks(BankDirectoryController.BankWrapper[] insertBanks) {
        Admin_Bank_Directory_Settings__c bankDirectorySettings = Admin_Bank_Directory_Settings__c.getOrgDefaults();

        Account[] accounts = new Account[]{};
        
        for (BankDirectoryController.BankWrapper bw : insertBanks) {
            if (bw.selected) {
                Account a = new Account(Id = bw.auxOppty.AccountId);
                a.Bank_Id__c = bw.bankId;   
                a.Name = bw.name;
                a.Phone = bw.phone;
                a.Email__c = bw.email;
                a.Website = bw.website;
                a.BillingStreet = bw.billingStreet;
                a.BillingCity = bw.billingCity;
                a.BillingState = bw.billingState;
                a.BillingPostalCode = bw.billingPostalCode;

                if (bankDirectorySettings.Account_Record_Type_Id__c != null &&
                    a.Id == null) {
                    a.RecordTypeId = bankDirectorySettings.Account_Record_Type_Id__c;
                }

                accounts.add(a);

                bw.auxOppty.Account = a;
                bw.accountName = a.Name;
            }
        }

        if (!accounts.isEmpty()) {
            upsert accounts;

            Program__c[] programs = new Program__c[]{};
            Map<String, Program__c> programsMap = queryPrograms(insertBanks);
            
            for (BankDirectoryController.BankWrapper bw : insertBanks) {
                if (bw.selected) {
                    bw.auxOppty.AccountId = bw.auxOppty.Account.Id;
    
                    for (BankDirectoryController.ProgramWrapper pw : bw.programs) {
                        Program__c p = getProgram(programsMap, pw);
                        
                        p.Bank__c = bw.auxOppty.AccountId;
                        pw.auxProgram = p;
                        programs.add(p);
                    }
                }
            }

            if (!programs.isEmpty()) {
                upsert programs;

                Required_Documents__c[] requiredDocuments = new Required_Documents__c[]{};
                
                Map<String, Required_Documents__c> requiredDocumentsMap = queryRequiredDocuments(insertBanks);

                for (BankDirectoryController.BankWrapper bw : insertBanks) {
                    if (bw.selected) {
                        for (BankDirectoryController.ProgramWrapper pw : bw.programs) {
                            for (BankDirectoryController.RequiredDocumentWrapper rdw : pw.requiredDocuments) {
                                
                                Required_Documents__c rd = requiredDocumentsMap.get(rdw.sfdcId);
                                if (rd == null) {
                                    rd = new Required_Documents__c(Id = rdw.sfdcId);
                                }
                                rd.Required_Document_Id__c = rdw.requiredDocumentId;
                                rd.Name = rdw.name;
                                
                                if (rd.Id == null) {
                                    rd.Program__c = pw.auxProgram.Id;
                                }
    
                                requiredDocuments.add(rd);
                            }
                        }
                    }
                }

                if (!requiredDocuments.isEmpty()) {
                    upsert requiredDocuments;
                }
            }
        }
    }
    
    
    private Program__c getProgram(Map<String, Program__c> programsMap, BankDirectoryController.ProgramWrapper pw) {
        Program__c p = programsMap.get(pw.sfdcId);
                        
        if (p == null) {
            p = new Program__c(Id = pw.sfdcId);
        }
        
        p.Program_Id__c = pw.programId;
        p.Name = pw.name;
        p.BK_Policy__c = pw.bKPolicy;
        p.Funding_Amt_of_Monthly_Gross_Sales__c = pw.fundingAmtofMonthlyGrossSales;
        p.Max_Amount__c = pw.maxAmount;
        p.Max_No_NSFs__c = pw.maxNoNSFs;
        p.Methods_of_Repayment__c = pw.methodsOfRepayment;
        p.Min_Avg_Daily_Bal__c = pw.minAvgDailyBal;
        p.Credit_Score__c = pw.creditScore;
        //p.Min_Credit_Score__c = pw.minCreditScore;
        p.Minimum_Deposit_Count__c = pw.minimumDepositCount;
        p.Min_Monthly_CC_Avg__c = pw.minMonthlyCCAvg;
        p.Min_Monthly_Deposits__c = pw.minMonthlyDeposits;
        p.Years_in_Business__c = pw.yearsInBusiness;
        p.Minimum_Advance__c = pw.minimumAdvance;
        p.Notes__c = pw.notes;
        p.Ownership_Percentage_Requirement__c = pw.ownershipPercentageRequirement;
        p.Percentage_Net_After_Payoff__c = pw.percentageNetAfterPayoff;
        p.Restricted_Industry_List__c = pw.restrictedIndustryList;
        p.Restricted_States__c = pw.restrictedStates;
        p.Site_Inspection__c = pw.siteInspection;
        p.Submission_Email__c = pw.submissionEmail;
        p.Tax_Lean_Policy__c = pw.taxLeanPolicy;
        p.Trade_References__c = pw.tradeReferences;
        p.Transaction_Count__c = pw.transactionCount;
        p.Turnaround_Time__c = pw.turnAroundTime;
        p.Directory_Status__c = pw.Status;
        
        return p;
    }
    
    private Map<String, Program__c> queryPrograms(BankDirectoryController.BankWrapper[] insertBanks) {
        Map<String, Program__c> programs = new Map<String, Program__c> ();
        String[] programIds = new String[]{};
        
        for (BankDirectoryController.BankWrapper bw : insertBanks) {
            if (bw.selected) {
                for (BankDirectoryController.ProgramWrapper pw : bw.programs) {
                    programIds.add(pw.sfdcId);                  
                }
            }
        }
        
        Integer i = 1;
        for (Program__c prog : [SELECT Id
                                     , Program_Id__c
                                     , Name
                                     , Submission_Email__c
                                     , Credit_Score__c
                                     , Commission_Percentage__c
                                     , Years_in_Business__c
                                     , Max_No_NSFs__c
                                  FROM Program__c 
                                 WHERE Id IN : programIds]) {
            programs.put(prog.Id, prog);
            i++;
        }
        return programs;
    }
    
    
    private Map<String, Required_Documents__c> queryRequiredDocuments(BankDirectoryController.BankWrapper[] insertBanks) {
        Map<String, Required_Documents__c> documents = new Map<String, Required_Documents__c>();
        String[] documentIds = new String[]{};
        
        for (BankDirectoryController.BankWrapper bw : insertBanks) {
            if (bw.selected) {
                for (BankDirectoryController.ProgramWrapper pw : bw.programs) {
                    for (BankDirectoryController.RequiredDocumentWrapper rdw : pw.requiredDocuments) {
                        documentIds.add(rdw.sfdcId);
                    }
                }
            }
        }
        
        for (Required_Documents__c doc : [SELECT Id
                                                , Name
                                                , Program__c
                                                , Required_Document_Id__c
                                             FROM Required_Documents__c
                                            WHERE Id IN : documentIds]) {
            
            documents.put(doc.Id, doc);
        }
        
        return documents;
    }
}