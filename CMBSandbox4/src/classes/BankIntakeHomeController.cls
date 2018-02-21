public with sharing class BankIntakeHomeController {


    public Id bankId {get; set;}
    public Bank__c bank {get; set;}
    public ProgramWrapper[] programs {get; set;}
    public ProgramWrapper selectedProgram {get; set;}

    public String stage {get; set;}
    public String newProgram {get; set;}

    public String password {get; set;}
    public String email {get; set;}

    public String recordMd5 {get; set;}
    public Boolean showModal {get; set;}

    public BankIntakeHomeController() {

        init();

        if (ApexPages.currentPage().getParameters().containsKey('id')) {

            bankId = ApexPages.currentPage().getParameters().get('id');
            loadBank();

            if (ApexPages.currentPage().getParameters().containsKey('email')) {

                email = ApexPages.currentPage().getParameters().get('email');
            }

        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Malformed URL. Please Review.'));
            stage = '';
        }
    }

    public PageReference login() {


        String bankEmail = email;
        if (bankEmail != null) {
            bankEmail = bankEmail.trim();
        }

        if ((bank != null) && (bankEmail == bank.Email__c) && (password == bank.Password__c)) {

            stage = 'BANK';
            bank.Last_Login__c = Datetime.now();
            update bank;
        }
        else {

            init();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Credentials do not match.'));

        }

        return null;
    }

    public PageReference addProgram() {

        Program__c program = new Program__c();
        program.External_Bank__c = bank.Id;

        String md5Coded = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(String.valueOf(Datetime.now()))));

        programs.add(new ProgramWrapper(program, md5Coded));
        showModal = false;
        newProgram = md5Coded;

        return showDetailsActionInitial();
    }

    public PageReference save() {

        upsert bank;
        Program__c[] programsToUpsert = new Program__c[] {};

        for (ProgramWrapper program :programs) {

            Program__c p = program.record;

            if (!program.states.isEmpty()) {
                p.Restricted_States__c = program.states[0];

                for (Integer i = 1; i < program.states.size(); i ++) {

                    p.Restricted_States__c += ';' + program.states[i];
                }
            }
            programsToUpsert.add(p);
        }

        if (!programsToUpsert.isEmpty()) {
            upsert programsToUpsert;
        }


        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Save Completed'));
        showModal = false;
        return null;
    }

    public Boolean getHasErrorMessages() {

        return ApexPages.hasMessages(ApexPages.severity.ERROR);
    }

    public Boolean getHasSuccessMessages() {

        return ApexPages.hasMessages(ApexPages.severity.CONFIRM);
    }

    private void init() {

        stage = 'AUTH';
        //stage = 'BANK';
        email = null;
        password = null;
        showModal = false;
        programs = new ProgramWrapper[] {};
        selectedProgram = null;
        recordMd5 = null;
    }

    private void loadBank() {

        Bank__c[] banks = new Bank__c[] {};
        banks = [SELECT
                        Name,
                        Bank_Id__c,
                        Billing_City__c,
                        Billing_Postal_Code__c,
                        Billing_State__c,
                        Billing_Street__c,
                        Email__c,
                        Phone__c,
                        Website__c,
                        Password__c,
                        Send_Welcome_Email__c,
                        Bank_Contact_Name__c,
                        Bank_Contact_Email__c,
                        Bank_Contact_Phone__c,
                        Last_Login__c,

                        (SELECT
                            Name,
                            Restricted_States__c,
                            Site_Inspection__c,
                            Login_to_Bank_Required__c,
                            Trade_References__c,
                            Min_Avg_Daily_Bal__c,
                            Transaction_Count__c,
                            Ownership_Percentage_Requirement__c,
                            Percentage_Net_After_Payoff__c,
                            Closing_Cost_Policy__c,
                            Fees__c,
                            Years_in_Business__c,
                            Min_Credit_Score__c,
                            Min_Monthly_Deposits__c,
                            Minimum_Deposit_Count__c,
                            Min_Monthly_CC_Avg__c,
                            Commission_Percentage__c,
                            Restricted_Industry_List__c,
                            Preferred_Programs__c,
                            Max_Amount__c,
                            Notes__c,
                            Payback_Funded_Renewals__c,
                            Funding_Amt_of_Monthly_Gross_Sales__c,
                            Payback_Funded__c,
                            Max_No_NSFs__c,
                            Allow_Syndication__c,
                            Submission_Email__c,
                            Minimum_Advance__c,
                            Max_Holdback_Percentage__c,
                            Commission_on_Renewal__c,
                            Factor_Rate_6_Months__c,
                            Factor_Rate_12_Months__c
                        FROM Programs__r)

                    FROM Bank__c WHERE Id = :bankId];

        System.debug('Programs__r ' + banks[0].Programs__r);
        if (!banks.isEmpty()) {

            bank = banks[0];

            Datetime dt = Datetime.now();
            for (Program__c program :banks[0].Programs__r) {

                String md5Coded = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(String.valueOf(dt))));
                programs.add(new ProgramWrapper(program, md5Coded));
                dt = dt.addHours(1);
            }
        }
    }

    public SelectOption[] getStates() {

        Schema.DescribeFieldResult result = Program__c.Restricted_States__c.getDescribe();
        List<Schema.PicklistEntry> elems = result.getPicklistValues();

        SelectOption[] states = new SelectOption[] {};

        states.add(new SelectOption('', '-NONE-'));

        for (Schema.PicklistEntry elem :elems) {

            states.add(new SelectOption(elem.getLabel(), elem.getLabel()));
        }

        return states;
    }

    public PageReference saveModalAction() {

        upsert selectedProgram.record;
        showModal = false;

        return null;
    }

    public PageReference showDetailsAction() {

        for (ProgramWrapper wrapper :programs) {

            if (recordMd5 == wrapper.md5) {

                selectedProgram = wrapper;
                showModal = true;
                break;
            }
        }

        return null;
    }

    public PageReference showDetailsActionInitial() {

        for (ProgramWrapper wrapper :programs) {

            if (newProgram == wrapper.md5) {

                selectedProgram = wrapper;
                showModal = true;
                break;
            }
        }

        return null;
    }

    public class ProgramWrapper {

        public Program__c record {get; set;}
        public String[] states {get; set;}
        public String md5 {get; set;}

        public ProgramWrapper(Program__c program, String md5) {

            record = program;
            this.md5 = md5;
            states = new String[] {};

            if (program.Restricted_States__c != null) {
                states = program.Restricted_States__c.split(';');
            }
        }

    }



}