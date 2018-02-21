/*
*  Controller for create Contract Page
*
*  Revision History:
*
*  Version        Author                       Date                Description
*  1.0            Sneha P                      31/03/2014          Initial Draft
*  1.1            Nachiket Deshpande           18/03/2015          Added commission split functionility.
*  1.2            Merul S                      21/01/2016          1. Refactored and restrucured the code.
*                                                                  2. Introduced the Wrapper structure to respect OWD and permissions.
*                                                                  3. Make Deal Info Section as dynamic.
*/
public with sharing class CreateContractController 
{

    private static final String IS_CONSOLE_PARAM = 'isConsole';
    public String payableWrp { get; set; }
    // Properties
    public String OppId                                   {get; set;}
    public String AccountId                               {get; set;}
    public list<OfferWrapper> offerWrapperList            {get; set;}
    //public Contract objContract                           {get; set;}
    public Opportunity objOpp                             {get; set;}
    public Offer__c selectedOffer                         {get; set;}
    public boolean isOfferSelected                        {get; set;}
    public list<Receivable__c> receivableList             {get; set;}
    public list<Payable__c> payableList                   {get; set;}
    public Receivable__c receivable                       {get; set;}
    public Payable__c payable                             {get; set;}
    public list<Syndication__c> syndicationList           {get; set;}
    public Syndication__c syndication                     {get; set;}
    public Decimal payableAmtTotal                        {get; set;}
    public Decimal receivableAmtTotal                     {get; set;}
    public Decimal syndAmtTotal                           {get; set;}
    public Decimal syndFeeTotal                           {get; set;}
    public String selOfferid                              {get; set;}
    public string recordTypeId                            {get; set;}
    public string newFlag                                 {get; set;}
    public string wizardType                              {get; set;}
    public Integer rowNum                                 {get; set;}
    public OppFieldWrapper oppFieldWrap                   {get; set;}
    public Map<String,OppFieldWrapper> mOppFieldWrapper   {get; set;}
    public Boolean showHeader                             {get; set;}
    public Boolean isInConsole                            {get; set;}
    public Integer recCount = 0;
    public Integer recWizardCount = 0;
    public Integer payCount = 0;
    public Integer payWizardCount = 0;
    public Boolean checkAdvCommCall;
    
    // made map public from being private
    public map<ID, Offer__c> offerMap;
    private String Stage;
    public String currState;
    public String queryString = '';
    public String prevState;
    public Submission__c selSubmission;
    public Program__c selProgram;
    public Static Final String OFFER_SCREEN ='Offer';
    public Static Final String DEAL_SCREEN ='Deal';
    public Static Final String RECEIVABLE_SCREEN ='Receivable';
    public Static Final String PAYABLE_SCREEN ='Payable';
    public Static Final String SYNDICATION_SCREEN ='Syndication';
    public Static Final String PREVIEW_SCREEN ='Preview';
    public list<Account> accList ;
    public decimal CommissionPer ;
    public list<Opportunity> opportunityList = new list<Opportunity>();
    public Map<String, Schema.SObjectType> globalMap;
    public Map<String, Schema.SObjectField> mapApiToOppFields;
    public List<Schema.FieldSetMember> masterOppFieldSetList  {get; set;}
    public List<Schema.FieldSetMember> dynamicOppFieldSetList {get; set;}
    public List<Schema.FieldSetMember> summaryOppFieldSetList  {get; set;}
    public string tempStr {get; set;}
    public String syndicationVisibleLabel                     {get; set;}
    
    public String offerIndex {get; set;}
 
    public list<PayableWrapper> payableWrapperList
    {
        get
        {
              payableWrapperList.clear();
              return this.buildPayableWrapper(payableList,UserInfo.getuserID());
        }
        set; 
    }
    
    public list<ReceivableWrapper> receivableWrapperList
    {
        get
        {
              return this.buildReceivableWrapper(receivableList,UserInfo.getuserID());
        }
        set; 
    }
    
    public list<SyndicationWrapper> SyndicationWrapperList
    {
        get
        {
              return this.buildSyndicationWrapper(syndicationList,UserInfo.getuserID());
        }
        set; 
    }

    public CreateContractController()
    {
        payableWrapperList = new list<PayableWrapper>();
        OppId = ApexPages.currentPage().getParameters().get('Id');
        Stage = ApexPages.currentPage().getParameters().get('stage');
        AccountId = ApexPages.currentPage().getParameters().get('accId');
        offerWrapperList = new list<OfferWrapper>();
        //objContract = new Contract();
        payable = new Payable__c();
        receivable = new Receivable__c();
        payableList = new list<Payable__c>();
        receivableList = new list<Receivable__c>();
        syndicationList = new List<Syndication__c>();
        syndication = new Syndication__c();
        isOfferSelected = false;
        objOpp = new Opportunity(Id = OppId);
        selOfferid = '';
        isInConsole
            = ApexPages.currentPage().getParameters().get(IS_CONSOLE_PARAM) == '1' ? true : false;
        accList = new list<Account>();
        mOppFieldWrapper = new Map<String,OppFieldWrapper>();
        globalMap = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult descbResultOpp = globalMap.get('Opportunity').getDescribe();
        masterOppFieldSetList = descbResultOpp.FieldSets.getMap().get(system.Label.DEWOppQueryFields).getFields();
        dynamicOppFieldSetList = descbResultOpp.FieldSets.getMap().get(system.Label.DEWDealInfoDetail).getFields();
        summaryOppFieldSetList = descbResultOpp.FieldSets.getMap().get(system.Label.DEWDealInfoSummary).getFields();
//start FO - 1310
        syndicationVisibleLabel = System.Label.DEWSyndicationVisible;
//end FO - 1310        
        mapApiToOppFields = descbResultOpp.fields.getMap();
        objOpp  = refereshOpportunityByID(OppId);
       
        if(objOpp  != null)
        {
            checkAdvCommCall = objOpp.Commission_Engine_Check__c;
            
        }
        configureHeaderVisibility();
        // display opportunity based on oppFieldWrapper
        mOppFieldWrapper = refereshDisplayOfOpportuntiyWrapper(dynamicOppFieldSetList,
                                                                objOpp,
                                                                oppFieldWrap,
                                                                mOppFieldWrapper);
    }
    
    //Function Called on init to populate all the data in the Tables
    public void populateData()
    {
        accList  =  [Select Id,
                            Commission_Percentage__c,
                            User__c,
                            Payback_Funded__c,
                            Type
                            From Account Where User__c =: objOpp.OwnerId LIMIT 1];
        
        /*list<Contract> ContractList = new list<Contract>();
        ContractList = [Select Renewal_Eligibility_Percent__c,
                                Renewal_Eligibility_Days_from_funding__c,
                                Anticipated_Renewal_Date__c,
                                Notes__c,
                                Deal_Type__c,
                                Opportunity__c
                                from Contract where Opportunity__c =: OppId LIMIT 1];
        
        if(ContractList.size() > 0)
        objContract = ContractList[0];
        */
        if(objOpp.Deal_Entry_Wizard_Check__c)
        {
            wizardType = DEAL_SCREEN;
            isOfferSelected = true;
        }
        else
        {
            wizardType = OFFER_SCREEN;
        }
        this.getOffers();
        this.getReceivables();
        this.getSyndication();
    }
    
    // Moved
    public void selectedOffer()
    {
        selOfferid = System.currentPagereference().getParameters().get('offerId');
        offerIndex = System.currentPagereference().getParameters().get('offerIndex');
        string priorOffrStatusValue = '';

        if(selOfferid != ''){
            isOfferSelected = true;
            priorOffrStatusValue = offerWrapperList[Integer.valueOf(offerIndex)].offer.Status__c;
            offerWrapperList[Integer.valueOf(offerIndex)].offer.Status__c = 'Chosen';
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please save the records to continue'));
            return;
        }
        
        //wizardType = DEAL_SCREEN;
        //Save the offer when the Page changes
        DEWOfferService.quickSaveOffer(offerWrapperList, OppId);
        if(DEWOfferService.isError == false)
        {
            objOpp = DEWOfferService.selectedOffer(selectedOffer, offerMap, selOfferid, objOpp, /*objContract,*/ selProgram, selSubmission);
            wizardType = DEAL_SCREEN;
        }
        else
        {
            offerWrapperList[Integer.valueOf(offerIndex)].offer.Status__c = priorOffrStatusValue;
        }
        
        //this internally sirst save the opp and its related field and then refresh the opp object in the //DEW and its respective wrapper
       // this.save();
    }
    
    //Function called on click of Next button, it will redirect to next Screen
    public void next()
    {
        if(wizardType == OFFER_SCREEN)
        {
         wizardType = DEAL_SCREEN;
         quickSaveOffer();
        }
        else if(wizardType == DEAL_SCREEN)
        {
            wizardType = RECEIVABLE_SCREEN;
            ++recCount;
            this.save();
            getReceivables();
            DEWReceivablesService.addRowReceivableForOriginationFeeType(receivableList, wizardType, selOfferid, objOpp, PREVIEW_SCREEN, OppId);
        }
        else if(wizardType == RECEIVABLE_SCREEN)
        {
          
                wizardType = PAYABLE_SCREEN;
                ++payCount;
                this.quickSaveReceivable();
                getPayables();
            
            
        }
        else if(wizardType == PAYABLE_SCREEN)
        {
            //--------- FO-1310 -------------
            //if(syndicationVisibleLabel.equalsIgnoreCase('true'))
            if(System.label.DEWSyndicationVisible.equalsIgnoreCase('true'))
            {
                wizardType = SYNDICATION_SCREEN;
                this.quickSavePayable();
                getSyndication();
            }
            else 
            {   
                wizardType = PREVIEW_SCREEN;
                this.quickSavePayable();
                receivableList = DEWReceivablesService.getReceivablesFromDB(OppId);
                //syndicationList = DEWSyndicationsService.getSyndicationFromDB(OppId);
                payableList = DEWPayablesService.getPayablesFromDB(OppId);
            }
             //--------- FO-1310 -------------
                
        }
        else if(wizardType == SYNDICATION_SCREEN) //&& syndicationVisibleLabel == 'true')
        {
            wizardType = PREVIEW_SCREEN;
            this.quickSaveSyndication();
            receivableList = DEWReceivablesService.getReceivablesFromDB(OppId);
            syndicationList = DEWSyndicationsService.getSyndicationFromDB(OppId);
            payableList = DEWPayablesService.getPayablesFromDB(OppId);
        }
    }
    
    //Function called on click of Previous button, it will redirect to previous Screen
    public void previous()
    {
        if(wizardType == PREVIEW_SCREEN)
        {
            //if(syndicationVisibleLabel.equalsIgnoreCase('true'))
            if(System.label.DEWSyndicationVisible.equalsIgnoreCase('true'))
            {
                wizardType = SYNDICATION_SCREEN;
                syndicationList = DEWSyndicationsService.getSyndicationFromDB(OppId);
            }
            else 
            {
                wizardType = PAYABLE_SCREEN;
                payableList = DEWPayablesService.getPayablesFromDB(OppId);
            }
        }
        else if(wizardType == SYNDICATION_SCREEN)
        {
            wizardType = PAYABLE_SCREEN;
            this.quickSaveSyndication();
            payableList = DEWPayablesService.getPayablesFromDB(OppId);
        }
        else if(wizardType == PAYABLE_SCREEN)
        {
            wizardType = RECEIVABLE_SCREEN;
            this.quickSavePayable();
            receivableList = DEWReceivablesService.getReceivablesFromDB(OppId);
        }
        else if(wizardType == RECEIVABLE_SCREEN)
        {
            wizardType = DEAL_SCREEN;
            this.quickSaveReceivable();
            //Refreshing opportunity from DB.
            objOpp = refereshOpportunityByID(OppId);
        }
        else if(wizardType == DEAL_SCREEN){
            wizardType = OFFER_SCREEN;
            this.save();
        }
        
    }
    
    // moved
    public void getOffers()
    {
        offerMap = new map<ID, Offer__c>([Select id,Opportunity__c,Name,Payment_Amt__c,Term_Months__c,Deal_Type__c,
                                                PMT_Schedule__c,Holdback__c,Funder__c,Payback_Amt__c,Amount__c,Rate__c,
                                                Submission__c,Status__c,Origination_fee__c,Buy_Rate__c,Expected__c,
                                                Payback_Funded__c,Referral_Payout__c,Details__c,Payoff_Amount__c,Net_Funded_Amount__c
                                                from Offer__c  where Opportunity__c =: OppId]);
        
       // DEWOfferService.getOffers(offerMap, OppId, offerWrapperList);
       
        offerWrapperList.clear();
        for(Offer__c offer : offerMap.values()){
            offerWrapperList.add(new offerWrapper(offer, false, offerWrapperList.size()));
        }
        if(offerWrapperList.size() == 0){
            DEWOfferService.addRowOffer(OppId);
        }
    }
    
    //moved 
    //Function to get the Receivables
    public void getReceivables()
    {
        // Query the receivables and display them on the Page
        receivableAmtTotal=0.00;
        //if(receivableList == null)
        receivableList = DEWReceivablesService.getReceivablesFromDB(OppId);
        DEWReceivablesService.getReceivables(recCount, recWizardCount, receivableList, objOpp);
        
       
        receivableAmtTotal = DEWReceivablesService.calculateRecAmtTotal(receivableAmtTotal, receivableList);
       
    }// end of If-getValues = 'populateData'
    
    //moved 
    //Function to get the Payables
    public void getPayables()
    {
        payableAmtTotal =0.00;
        // Query the receivables and display them on the Page
        payableList = DEWPayablesService.getPayablesFromDB(OppId);
        
        // build bridge between Comission engine and MCA App (MCA-739) By Merul
        if(label.ActivateCommissionEngine == 'true' && objOpp.Commission_Engine_Check__c == false)
        {
            
            String labelString = Label.CommissionEngineClassName;
            checkAdvCommCall = DEWPayablesService.callCommissionCreatePayable(objOpp, 
                                                                              OppId, 
                                                                              labelString,
                                                                              checkAdvCommCall, 
                                                                              payableList);
            
        }
        else
        {
            //Nachiket 1.1
           
            DEWPayablesService.standardSplitCreatePayable(objOpp, 
                                                          OppId, 
                                                          accList, 
                                                          receivableList, 
                                                          CommissionPer, 
                                                          payableList, 
                                                          wizardType, 
                                                          PREVIEW_SCREEN);
            
            
            if(payCount == 1 || payWizardCount==1)
            {
                payCount = 2;
                payWizardCount = 2;
            }
        }
        
        //For Grand total of Payables
        payableAmtTotal = DEWPayablesService.calculatePayAmtTotal(payableAmtTotal, payableList);
        
        //To make mark on opportunity to call CE in future
        if(checkAdvCommCall)
        {
            objOpp.Commission_Engine_Check__c = true;
            update objOpp;
        }
    }
    
    
    //Function to fetch Syndication records
    public void getSyndication()
    {
        
        syndFeeTotal=0.00;
        // Query the receivables and display them on the Page
        syndicationList = DEWSyndicationsService.getSyndicationFromDB(OppId);
        syndAmtTotal = DEWSyndicationsService.calculateSynAmtTotal(syndAmtTotal, syndicationList);
        
    }
    
    public List<SelectOption> getSubmissionNames()
    {
        List<SelectOption> options = new List<SelectOption>();
        List<Submission__c> submissionlist = new List<Submission__c>();
        submissionlist = [SELECT Id, Name, Funder__c, Funder__r.Name 
                          FROM Submission__c 
                          WHERE Opportunity__c =: OppId
                          Order by CreatedDate DESC
                         ];
        
        for (Integer j=0;j<submissionlist.size();j++){
            String subName = submissionlist[j].Name;
            options.add(new SelectOption(submissionlist[j].Id,submissionlist[j].Funder__r.Name+'-('+subName.substring(4,subName.length())+')'));
        }
        return options;
    }
    
    // moved 
    public void addRowOffer(){
        //offerWrapperList = DEWOfferService.addRowOffer(offerWrapperList, OppId);
        offerWrapperList.add(new offerWrapper(new Offer__c(Opportunity__c = OppId), false, offerWrapperList.size()));
    }
    
    //moved
    public void addRowPayable()
    {
        payableList = DEWPayablesService.addPayableRow(OppId,
                                                        objOpp,
                                                        accList,
                                                        receivableList,
                                                        payableList);
    }
    
    // moved
    public void addRowReceivable()
    {
        DEWReceivablesService.addRowReceivable(selProgram, receivableList, objOpp, OppId);
        
    }
    
   
    // moved 
    public void addRowSyndication(){
        DEWSyndicationsService.addRowSyndication(syndicationList, OppId);
        //syndicationList.add(new Syndication__c(Opportunity__c = OppId));
    }
    
    // moved
    public void quickSaveOffer()
    {
        try
        {
            DEWOfferService.quickSaveOffer(offerWrapperList, OppId);
            this.getOffers();
        }
         catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            wizardType = PAYABLE_SCREEN;
            
        }
    
    }
    
    // moved 
    public void quickSavePayable()
    {
        try
        {
        payableList = DEWPayablesService.quickSavePayable(payableList,objOpp, OppId);
        payableAmtTotal = DEWPayablesService.calculatePayAmtTotal(payableAmtTotal, payableList);
            
           
            //Refreshing opportunity from DB.
            objOpp = refereshOpportunityByID(OppId); 
        
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            wizardType = PAYABLE_SCREEN;
            
        }
    }
    
    // moved
    public void quickSaveReceivable()
    {
        
        try{
        receivableList = DEWReceivablesService.quickSaveReceivable(receivableList, objOpp, OppId);
        receivableAmtTotal = DEWReceivablesService.calculateRecAmtTotal(receivableAmtTotal, receivableList);
        objOpp = refereshOpportunityByID(OppId);
        }
        catch(DmlException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            wizardType = RECEIVABLE_SCREEN;
        }
    }
    
    // moved 
    public void quickSaveSyndication()
    {
         try
        {
            syndicationList = DEWSyndicationsService.quickSaveSyndication(syndicationList, objOpp, OppId);
            syndAmtTotal = DEWSyndicationsService.calculateSynAmtTotal(syndAmtTotal, syndicationList);
            
            
        }
        catch(Exception e){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            //currState = prevState;
        }
    }
    // moved
    // Delete offer
    public void deleteOffer()
    {
        try
        {
            string delname = ApexPages.CurrentPage().getParameters().get('delname');
            Integer rowNum = Integer.valueOf(ApexPages.currentPage().getParameters().get('index'));
            DEWOfferService.deleteOffer(delname, rowNum, isOfferSelected, selOfferid, offerWrapperList);
           
            
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
        }
    }
    
    //remove payables on click of Delete link
    // moved
    public void deletPayables()
    {
        
       
        try
        {
            Integer rowPayNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        
            // need to check with the permission
            if(payableWrapperList[rowPayNum].objPayable.id == null)
            {
            
                 payableList.remove(rowPayNum );
            }
            else
            {
                payable__c tempPay = payableWrapperList[rowPayNum].objPayable;
                payableList.remove(rowPayNum );
                
                delete tempPay;
            }
            
            payableAmtTotal = DEWPayablesService.calculatePayAmtTotal(payableAmtTotal, payableList);
            
          }catch(Exception e)
          {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
        
          }  
       
    }
    
    // moved
    //remove receivables on click of Delete link
    public void deletReceivables(){
        
       
       try
        {
         
            Integer rowRecNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
            // need to check with the permission
            if(receivableWrapperList[rowRecNum].objReceivable.id == null)
            {
            
                  receivableList.remove(rowRecNum);
            }
            else
            {
                receivable__c tempRecObj = receivableList[rowRecNum];
                 receivableList.remove(rowRecNum);
              
                delete tempRecObj ;
                
            }
           
            
            receivableAmtTotal = DEWReceivablesService.calculateRecAmtTotal(receivableAmtTotal, receivableList);
            
            
          }catch(Exception e)
          {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
        
          } 
       
      
        
    }
    
    // moved
    //remove syndications on click of Delete link
    public void deletSyndications()
    {
        
        
        try
        {
            Integer rowSyncNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
           
            // need to check with the permission
            if(SyndicationWrapperList[rowSyncNum ].objSyndication.id == null)
            {
            
                 syndicationList.remove(rowSyncNum);
                 
            }
            else
            {
                Syndication__c tempSyncObj = syndicationList[rowSyncNum];
                syndicationList.remove(rowSyncNum );
               
                delete tempSyncObj ;
                
            }
            syndAmtTotal = DEWSyndicationsService.calculateSynAmtTotal(syndAmtTotal, syndicationList);
            
          }catch(Exception e)
          {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
        
          }  
        
       
       // DEWSyndicationsService.toDeletSyndications(syndicationList,rowNum);
        
        
    }
    
    public void onChangeBankProgram()
    {
        if(objOpp.Bank_Program__c <> null)
        {
            selProgram = [select Id, Name,Payback_Funded__c,Commission_Percentage__c,Renewal_Eligibility__c from Program__c where Id =:objOpp.Bank_Program__c];
            
            objOpp.Renewal_Eligibility_Percent__c = selProgram.Renewal_Eligibility__c;
            if( selProgram.Renewal_Eligibility__c != null && objOpp.Term_Months__c != null)
            {
                objOpp.Renewal_Eligibility_Days_from_funding__c = (objOpp.Term_Months__c  *  objOpp.Renewal_Eligibility_Percent__c)/100;
                DateTime dt = System.Now() + (objOpp.Renewal_Eligibility_Days_from_funding__c * 30.4368);
                objOpp.Estimated_Renewal_Date__c = Date.newInstance(Dt.year(),Dt.Month(),Dt.day());
            }
        }
    }
    
    public void onChangeTermMonth(){
        if( objOpp.Renewal_Eligibility_Percent__c != null && objOpp.Term_Months__c != null){
            objOpp.Renewal_Eligibility_Days_from_funding__c = (objOpp.Term_Months__c  *  objOpp.Renewal_Eligibility_Percent__c)/100;
            DateTime dt = System.Now() + (((objOpp.Term_Months__c  *  objOpp.Renewal_Eligibility_Percent__c)/100) * 30.4368);
            objOpp.Estimated_Renewal_Date__c = Date.newInstance(Dt.year(),Dt.Month(),Dt.day());
            system.debug('>>>1 objOpp.Estimated_Renewal_Date__c : '+objOpp.Estimated_Renewal_Date__c);
        }
        system.debug('>>>2 objOpp.Estimated_Renewal_Date__c : '+objOpp.Estimated_Renewal_Date__c);
    }
    
    public void onChangeRenewalEliPer(){
        if( objOpp.Renewal_Eligibility_Percent__c != null && objOpp.Term_Months__c != null){
            objOpp.Renewal_Eligibility_Days_from_funding__c = (objOpp.Term_Months__c  *  objOpp.Renewal_Eligibility_Percent__c)/100;
            DateTime dt = System.Now() + (((objOpp.Term_Months__c  *  objOpp.Renewal_Eligibility_Percent__c)/100) * 30.4368);
            objOpp.Estimated_Renewal_Date__c = Date.newInstance(Dt.year(),Dt.Month(),Dt.day());
            system.debug('>>>3 objOpp.Estimated_Renewal_Date__c : '+objOpp.Estimated_Renewal_Date__c);
        }
        system.debug('>>>4 objOpp.Estimated_Renewal_Date__c : '+objOpp.Estimated_Renewal_Date__c);
    }
    
    /*public void onChangeType(){
        
        DEWPayablesService.onChangePayAmountCalculation(receivableList,payableList);
        
    }*/
    // moved
    public void onChangeRecPaybackFunded()
    {
        String recevableid = System.currentPagereference().getParameters().get('recId');
        
        DEWReceivablesService.onChangeOfRecPaybackFunded(receivableList, objOpp);
        receivableAmtTotal = 0.00;
        
        receivableAmtTotal = DEWReceivablesService.calculateRecAmtTotal(receivableAmtTotal, receivableList);
        
    }
    
    // moved
    public void onChangePayPaybackFunded()
    {
        String payableid = System.currentPagereference().getParameters().get('payId');
        DEWPayablesService.onChangeOfPayPaybackFunded(receivableList, 
                                                     payableList, 
                                                     objOpp, 
                                                     mapApiToOppFields);
        
        payableAmtTotal =0.00;
        payableAmtTotal = DEWPayablesService.calculatePayAmtTotal(payableAmtTotal, payableList);
       
        
    }
   
    
    public void onChangeRecPercentage()
    {
        String recevableid = System.currentPagereference().getParameters().get('recId');
        receivableAmtTotal = 0.00;
        DEWReceivablesService.onChangeOfRecPercentage(receivableList, objOpp);
        receivableAmtTotal = DEWReceivablesService.calculateRecAmtTotal(receivableAmtTotal, receivableList);
    }
    
    // moved
    public void onChangePayPercentage()
    {
        String payableid = System.currentPagereference().getParameters().get('payId');
        
        DEWPayablesService.onChangeOfPayPercentage(receivableList, payableList, objOpp, mapApiToOppFields);
        
        payableAmtTotal =0.00;
        payableAmtTotal = DEWPayablesService.calculatePayAmtTotal(payableAmtTotal, payableList);
       
        
    }
    
    public Static Map<String,OppFieldWrapper> refereshDisplayOfOpportuntiyWrapper(List<Schema.FieldSetMember> dynamicOppFieldSetList,
                                                                                    Sobject sObjectRec,
                                                                                    OppFieldWrapper  oppFieldWrap,
                                                                                    Map<String,OppFieldWrapper> mOppFieldWrapper)
    {
        for(Schema.FieldSetMember memberInsatnce : dynamicOppFieldSetList)
        {
            String field = memberInsatnce.fieldPath;
            if(field.contains('.'))
            {
                
                ReferenceObjectDetail refObjDetail= DEWUtility.getReferenceObjectDetailOfField(sObjectRec,field);
                if(sObjectRec.get(refObjDetail.sObjectName) == null)
                {
                    oppFieldWrap = new OppFieldWrapper(null,memberInsatnce.label,memberInsatnce.fieldPath,true,false);
                }
                else
                {
                    oppFieldWrap = new OppFieldWrapper(null,memberInsatnce.label,memberInsatnce.fieldPath,false,false);
                }
            }
            else
            {
                oppFieldWrap = new OppFieldWrapper(null,memberInsatnce.label,memberInsatnce.fieldPath,false,(memberInsatnce.type==Schema.DisplayType.REFERENCE)?true:false);
            }
            
            mOppFieldWrapper.put(memberInsatnce.fieldPath,oppFieldWrap);
        }
        
        return mOppFieldWrapper;
        
    }
   
    public void save()
    {
      system.debug('objOpp : '+objOpp);
      try
      {
            onChangeTermMonth();
            onChangeRenewalEliPer();
            objOpp = DEWOpportunityService.save(objOpp, dynamicOppFieldSetList, wizardType, DEAL_SCREEN, OppId, mOppFieldWrapper, oppFieldWrap);
            
            mOppFieldWrapper = CreateContractController.refereshDisplayOfOpportuntiyWrapper(dynamicOppFieldSetList,
                                                                        objOpp,
                                                                        oppFieldWrap,
                                                                        mOppFieldWrapper);
       }
       catch(Exception e)
       {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
       }
    }
    
    public void refreshOppWrapperMap()
    {
    
      try
      {
        //this internally first save the opp and its related field and then refresh the opp object in the
        //DEW and its respective wrapper
        
        this.save();
       }
       catch(Exception e)
       {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
       }  
       
    }
    
    public PageReference cancel()
    {
        /*objopp.Deal_Entry_Wizard_Check__c = true;
        
        try
        {
            upsert objopp;
        }
         catch(exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
        }*/
        //return new PageReference('/'+OppId);
        return RedirectionHelper.getOpportunityDetailUrl(OppId, isInConsole);
    }
    
    // method to finish the DEW functionality and check the Deal_Entry_Wizard_Check__c checkbox
    public PageReference finish()
    {
        objopp.Deal_Entry_Wizard_Check__c = true;
        
        try
        {
            upsert objopp;
        }
         catch(exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
        }
        //return new PageReference('/'+OppId);
        return RedirectionHelper.getOpportunityDetailUrl(OppId, isInConsole);
    }

    //Commented the code because the functionality of MCA-841 is depricated
    /*  public void saveOnTabChange (String pState)
    {
      
        if(pState == RECEIVABLE_SCREEN)
        {
         quickSaveReceivable();
        }
        if(pState == PAYABLE_SCREEN) 
        {
         quickSavePayable();
        }
        if(pState == SYNDICATION_SCREEN) 
        {
         quickSaveSyndication();
        }
        if(pState == DEAL_SCREEN) {
        save();
        }
        if(pState == OFFER_SCREEN) {
        DEWOfferService.quickSaveOffer(offerWrapperList, OppId);
        }
        
    }*/
    
    public void changeWizard()
    {

        if(!isOfferSelected)
        isOfferSelected = false;
        if(wizardType == PREVIEW_SCREEN)
        {
            //if(syndicationVisibleLabel.equalsIgnoreCase('true'))
            if(System.label.DEWSyndicationVisible.equalsIgnoreCase('true'))
            {
                payableList = DEWPayablesService.getPayablesFromDB(OppId);
                receivableList = DEWReceivablesService.getReceivablesFromDB(OppId);
                syndicationList =  DEWSyndicationsService.getSyndicationFromDB(OppId);
            }
            else 
            {
                payableList = DEWPayablesService.getPayablesFromDB(OppId);
                receivableList = DEWReceivablesService.getReceivablesFromDB(OppId);
            }
        }
        if(wizardType == RECEIVABLE_SCREEN)
        {
            ++recWizardCount;
            receivableList = DEWReceivablesService.getReceivablesFromDB(OppId);
            
        }
        if(wizardType == PAYABLE_SCREEN)
        {
            ++payWizardCount;
            payableList = DEWPayablesService.getPayablesFromDB(OppId);
            payableAmtTotal = 0.0;
            if(payableList.size()>0)
            {
                for(Payable__c pay:payableList){
                    if(pay.Amount_Due__c!=null)
                    payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
                }
            }
           
        }
        if(wizardType == SYNDICATION_SCREEN && System.label.DEWSyndicationVisible.equalsIgnoreCase('true'))
        {
            syndicationList =  DEWSyndicationsService.getSyndicationFromDB(OppId);
           
        }   
    }
    
    public string getbaseUrlOrg(){
        return MCAStringConstant.baseUrlOrg;
    }
    
   

    public Opportunity refereshOpportunityByID(Id OppId)
    {
        List<Opportunity> opportunityTempList = database.query(DEWOpportunityService.buildQueryStringForOpportunity(
                                                                                            oppId,
                                                                                            masterOppFieldSetList,
                                                                                            dynamicOppFieldSetList, 
                                                                                            summaryOppFieldSetList));
        if(opportunityTempList != null && opportunityTempList .size() > 0 )
        {
            return opportunityTempList[0];
        }
        return null;
    }

    // Method to set header visibility
    private void configureHeaderVisibility()
    {
        // Hide header when page is opened from console
        showHeader = !isInConsole;
    }

    //Wrapper Classes
    public class OfferWrapper
    {
        public Offer__c offer                     {get; set;}
        public boolean isSelected                 {get; set;}
        public Integer index                      {get; set;}
        public OfferWrapper(Offer__c pOffer, Boolean pIsSelected, Integer pIndex)
        {
            offer = pOffer;
            isSelected = pIsSelected;
            index = pIndex;
        }
    }
    
    public class OppFieldWrapper
    {
        public Id oppId {get;set;}
        public String fieldPathStr{get;set;}
        public String fieldlabel{get;set;}
        public Boolean isReadonly {get;set;}
        public Boolean isLookup {get;set;}
        
        public OppFieldWrapper(Id oppId,String fieldlabel,String fieldPathStr,Boolean isReadonly,Boolean isLookup)
        {
            
            this.oppId = oppId;
            this.fieldPathStr = fieldPathStr;
            this.fieldlabel = fieldlabel;
            this.isReadonly = isReadonly;
            this.isLookup = isLookup;
        }
    }
    
    public class ReferenceObjectDetail
    {
        public sObject recSObject {get;set;}
        public String  sObjectName{get;set;}
        public String  sObjectRefName{get;set;}
        public String  fieldApi{get;set;}
        
        public ReferenceObjectDetail(sObject recSObject,String  sObjectRefName,String  sObjectName,String  fieldApi)
        {
            this.recSObject = recSObject;
            this.sObjectName = sObjectName;
            this.fieldApi = fieldApi;
        }
    }
    
    public class PayableWrapper
    {
        public Payable__c objPayable {get;set;}
        public Boolean hasReadAccess {get;set;}
        public Boolean hasEditAccess {get;set;}
        public Boolean isReadOnVF{get;set;}
        public Integer index{get;set;}
        
        public PayableWrapper(Integer index,
                                    Payable__c objPayable,
                                    Boolean hasReadAccess,
                                    Boolean hasEditAccess,
                                    Boolean isReadOnVF)
        {
            this.index = index;
            this.objPayable = objPayable;
            this.hasReadAccess=hasReadAccess;
            this.hasEditAccess=hasEditAccess;
            this.isReadOnVF=isReadOnVF;
        }
    }
    
    public class ReceivableWrapper
    {
        public Receivable__c objReceivable {get;set;}
        public Boolean hasReadAccess {get;set;}
        public Boolean hasEditAccess {get;set;}
        public Boolean isReadOnVF{get;set;}
        public Integer index{get;set;}
        
        public ReceivableWrapper(Integer index,
                                    Receivable__c objReceivable,
                                    Boolean hasReadAccess,
                                    Boolean hasEditAccess,
                                    Boolean isReadOnVF)
        {
            this.index = index;
            this.objReceivable = objReceivable;
            this.hasReadAccess=hasReadAccess;
            this.hasEditAccess=hasEditAccess;
            this.isReadOnVF=isReadOnVF;
        }
    }
    
    public class SyndicationWrapper
    {
        public Syndication__c objSyndication {get;set;}
        public Boolean hasReadAccess {get;set;}
        public Boolean hasEditAccess {get;set;}
        public Boolean isReadOnVF{get;set;}
        public Integer index{get;set;}
        
        public SyndicationWrapper(Integer index,
                                   Syndication__c objSyndication,
                                    Boolean hasReadAccess,
                                    Boolean hasEditAccess,
                                    Boolean isReadOnVF)
        {
            this.index = index;
            this.objSyndication = objSyndication;
            this.hasReadAccess=hasReadAccess;
            this.hasEditAccess=hasEditAccess;
            this.isReadOnVF=isReadOnVF;
        }
    }
    
    // All Wrapper builder.
    
    
    public list<ReceivableWrapper> buildReceivableWrapper(List<Receivable__c> receivableList, Id userId)
    {
        map<Id,ReceivableWrapper> currentRecMap = new map<Id,ReceivableWrapper>();
        list<ReceivableWrapper> finalRecList = new list<ReceivableWrapper>();
        list<ReceivableWrapper> nullRecList = new list<ReceivableWrapper>();
        list<UserRecordAccess> listUserRecordAccess = new list<UserRecordAccess>();
        list<Receivable__c> tempRecLst = new list<Receivable__c>();
        for(Receivable__c tempRec : receivableList)
        {
            if(tempRec .Id == NULL)
            {
                nullRecList.add(new ReceivableWrapper(0,tempRec,true,true,true));
            }
            else
            {
                currentRecMap.put(tempRec.Id,new ReceivableWrapper(0,tempRec,false,false,false));
            }
        }
        
        if(currentRecMap != NULL && currentRecMap.size() > 0)
        {
            listUserRecordAccess = DEWUtility.checkUserAccessForSobject(currentRecMap.keySet(),userId);
            for(UserRecordAccess objUserAccess : listUserRecordAccess)
            {
                ReceivableWrapper recWrp = currentRecMap.get(objUserAccess.RecordId);
                recWrp.hasReadAccess = objUserAccess.HasReadAccess;
                recWrp.hasEditAccess = objUserAccess.HasEditAccess;
                recWrp.isReadOnVF = objUserAccess.HasReadAccess && objUserAccess.HasEditAccess;
                //finalRecList.add(recWrp);
            }
        }
        finalRecList.addAll(currentRecMap.Values());
        finalRecList.addAll(nullRecList);
        
         //Indexing
        Integer indexRec = 0;
        for(ReceivableWrapper recWrp : finalRecList)
        {
            recWrp.index = indexRec ;
            indexRec ++;
            
        }
        return finalRecList;
    }
 
    public list<PayableWrapper> buildPayableWrapper(List<Payable__c> payableList, Id userId)
    {
        map<Id,PayableWrapper> currentPayMap = new map<Id,PayableWrapper>();
        list<PayableWrapper> finalPayList = new list<PayableWrapper>();
        list<PayableWrapper> nullPayList = new list<PayableWrapper>();
        list<UserRecordAccess> listUserRecordAccess = new list<UserRecordAccess>();
        
        for(Payable__c tempPay : payableList)
        {
            
            if(tempPay.Id == NULL)
            {
                nullPayList.add(new PayableWrapper(0,tempPay,true,true,true));
            }
            else
            {
                currentPayMap.put(tempPay.Id,new PayableWrapper(0,tempPay,false,false,false));
            }
        }
        
        if(currentPayMap != NULL && currentPayMap.size() > 0)
        {
            listUserRecordAccess = DEWUtility.checkUserAccessForSobject(currentPayMap.keySet(),userId);
            for(UserRecordAccess objUserAccess : listUserRecordAccess)
            {
                PayableWrapper payWrp = currentPayMap.get(objUserAccess.RecordId);
                payWrp.hasReadAccess = objUserAccess.HasReadAccess;
                payWrp.hasEditAccess = objUserAccess.HasEditAccess;
                payWrp.isReadOnVF = objUserAccess.HasReadAccess && objUserAccess.HasEditAccess;
               // finalPayList.add(payWrp);
            }
        }
        finalPayList.addAll(currentPayMap.Values());
        finalPayList.addAll(nullPayList);
        
         //Indexing
        Integer indexPay = 0;
        for(PayableWrapper payWrp : finalPayList)
        {
            payWrp.index = indexPay;
            indexPay++;
           
        }
        return finalPayList;
    } 
    
    public list<SyndicationWrapper> buildSyndicationWrapper(List<Syndication__c> syndicationList, Id userId)
    {
        map<Id,SyndicationWrapper> currentSycMap = new map<Id,SyndicationWrapper>();
        list<SyndicationWrapper> finalSycList = new list<SyndicationWrapper>();
        list<SyndicationWrapper> nullSycList = new list<SyndicationWrapper>();
        list<UserRecordAccess> listUserRecordAccess = new list<UserRecordAccess>();
        
        for(Syndication__c tempSyc : syndicationList)
        {
            if(tempSyc.Id == NULL)
            {
                nullSycList.add(new SyndicationWrapper(0,tempSyc,true,true,true));
            }
            else
            {
                currentSycMap.put(tempSyc.Id,new SyndicationWrapper(0,tempSyc,false,false,false));
            }
        }
        
        if(currentSycMap != NULL && currentSycMap.size() > 0)
        {
            listUserRecordAccess = DEWUtility.checkUserAccessForSobject(currentSycMap.keySet(),userId);
            for(UserRecordAccess objUserAccess : listUserRecordAccess)
            {
                SyndicationWrapper sycWrp = currentSycMap.get(objUserAccess.RecordId);
                sycWrp.hasReadAccess = objUserAccess.HasReadAccess;
                sycWrp.hasEditAccess = objUserAccess.HasEditAccess;
                sycWrp.isReadOnVF = objUserAccess.HasReadAccess && objUserAccess.HasEditAccess;
                //finalSycList.add(sycWrp);
            }
        }
        finalSycList.addAll(currentSycMap.Values());
        finalSycList.addAll(nullSycList);
        
        //Indexing
        Integer indexSynch = 0;
        for(SyndicationWrapper sycWrp : finalSycList)
        {
            sycWrp.index = indexSynch;
            indexSynch++;
            
        }
        return finalSycList;
    }
}