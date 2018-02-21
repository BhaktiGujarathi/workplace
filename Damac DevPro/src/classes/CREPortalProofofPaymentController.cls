public class CREPortalProofofPaymentController{

    public String srType                                {get;set;}
    public Boolean createAdditionalParking              {get;set;}
    public Boolean createAssignmentRequest              {get;set;}
    public Boolean createAOPT                           {get;set;}
    public Boolean createBouncedCheque                  {get;set;}
    public Boolean createFundTransfer                   {get;set;}
    public Boolean createFurniturePackage               {get;set;}
    public Boolean createMortgage                       {get;set;}
    public Boolean createPenaltyWaiver                  {get;set;}
    public Boolean createProofOfPayment                 {get;set;}
    public Boolean createRefunds                        {get;set;}
    public Boolean createCOCD                           {get;set;}
    public Boolean createEarlyHandover                  {get;set;}
    public Boolean createNOCforVisa                     {get;set;}
    public Boolean createComplaint                      {get;set;}
    public Boolean createRentalPool                     {get;set;}
    public Boolean createTitleDeed                      {get;set;}
    public Boolean createPlotHandover                   {get;set;}

    public Boolean createRentalPoolTermination          {get;set;}
    public Boolean createRentalPoolAssignment           {get;set;}

    public Boolean home                                 {get;set;}
    public List<Account> accountsList                   {get;set;}
    public list<SelectOption> listAccountOptions        {get;set;}
    public Id selectedAccountId                         {get;set;}
    public Boolean isAccountSelected                    {get;set;}
    public Boolean createHandover                       {get;set;}
    public Map<Id,Account> mapIdAccount                 {get;set;}
    public Account account                              {get;set;}
    public string strAccountId                          {get;set;}
    public Account objAccount                           {get;set;}// account object to display details for AOPT process
    

    public CREPortalProofofPaymentController(DashboardController dashboardController){
        init();
    }

    public CREPortalProofofPaymentController(){
        init();
    }

    public void init(){
        srType = ApexPages.currentPage().getParameters().get('SRType');
        strAccountId = ApexPages.currentPage().getParameters().get('AccountId');
        system.debug('strAccountId'+strAccountId);
        populateCreateSRBoolean();
        accountsList = new List<Account>();
        mapIdAccount= new Map<Id,Account>();
        account = new Account();
        isAccountSelected = false;

        listAccountOptions = new list <SelectOption>();
        listAccountOptions.add(new SelectOption('', '--NONE--'));
        List<Account> listAccount = [SELECT Name, Id, Organisation_Name__c,Salutation
                                        ,IsPersonAccount,PersonEmail,Phone,Nationality__pc,Party_Type__c,SLA__c 
                                     FROM Account
                                     ORDER BY Name
                                     LIMIT 250
                                    ];
        for (Account account: listAccount) {
            listAccountOptions.add(new SelectOption(account.Id, account.Name));
            mapIdAccount.put(account.Id,account);
        }
        // fetch account details for AOPT process
        getCustomerPortfolio();
    }
    
    public void populateCreateSRBoolean(){
        
        createAdditionalParking = false;
        createAssignmentRequest = false;
        createNOCforVisa = false;
        createAOPT = false;
        createBouncedCheque = false;
        createFundTransfer = false;
        createFurniturePackage = false;
        createMortgage = false;
        createPenaltyWaiver = false;
        createProofOfPayment = false;
        createRefunds = false;
        createCOCD = false;
        createEarlyHandover = false;
        createComplaint = false;
        createRentalPool = false;
        createTitleDeed = false;
        createHandover = false;
        createRentalPoolTermination = false;
        createRentalPoolAssignment = false;
        createPlotHandover = false;
        home = false;
        
        system.debug('srType$$$$$'+srType);
        if(srType != null && srType != ''){
            if(srType.equals('AdditionalParking')){
                createAdditionalParking = true;
            } else if(srType.equals('AssignmentRequest')){
                createAssignmentRequest = true;
            } else if(srType.equals('AOPT')){
                createAOPT = true;
            } else if(srType.equals('BouncedCheque')){
                createBouncedCheque = true;
            } else if(srType.equals('FundTransfer')){
                createFundTransfer = true;
            } else if(srType.equals('FurniturePackage')){
                createFurniturePackage = true;
            } else if(srType.equals('Mortgage')){
                createMortgage = true;
            } else if(srType.equals('PenaltyWaiver')){
                createPenaltyWaiver = true;
            } else if(srType.equals('ProofOfPayment')){
                createProofOfPayment = true;
            } else if(srType.equals('Refunds')){
                createRefunds = true;
            } else if(srType.equals('COCD')){
                createCOCD = true;
            } else if(srType.equals('EarlyHandover')){
                createEarlyHandover = true;
            } else if(srType.equals('NOCVisa')){
                createNOCforVisa = true;
            } else if(srType.equals('Complaint')){
                createComplaint = true;
            } else if(srType.equals('Home')){
                home = true;
            } else if(srType.equals('RentalPool')){
                createRentalPool = true;
            } else if(srType.equals('TitleDeed')){
                createTitleDeed = true;
            } else if(srType.equals('Handover')){
                createHandover = true;
            } else if(srType.equals('RentalPoolTermination')){
                createRentalPoolTermination = true;
            } else if(srType.equals('RentalPoolAssignment')){
                createRentalPoolAssignment = true;
            } else if(srType.equals('PlotHandover')){
                createPlotHandover = true;
            }
        } else {
            home = true;
        }
        
    }

    public void selectAccount(){
        if(selectedAccountId != null){
            isAccountSelected = true;
            account = mapIdAccount.get(selectedAccountId);
        } else {
            isAccountSelected = false;
        }
    }

  // method used to retrieve customer portfolio details
  public void getCustomerPortfolio()
  {
  if(strAccountId != null){
        objAccount = [ SELECT Id,Name,Title__c
                      ,PersonTitle,PersonMobilePhone
                      ,PersonEmail,FirstName,LastName
                      ,MiddleName,Party_ID__c,Nationality__pc
                      ,Party_Type__c,Passport_Number__c,CR_Number__c,
                      Organisation_Name__c
                      FROM Account WHERE ID = : strAccountId ];
      }
  }

}