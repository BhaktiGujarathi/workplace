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
public with sharing class CreateContractController {

    public String payableWrp { get; set; }
    // Properties
    public String OppId                                   {get; set;}
    public String AccountId                               {get; set;}
    public list<OfferWrapper> offerWrapperList            {get; set;}
    public Contract objContract                           {get; set;}
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
        objContract = new Contract();
        payable = new Payable__c();
        receivable = new Receivable__c();
        payableList = new list<Payable__c>();
        receivableList = new list<Receivable__c>();
        syndicationList = new List<Syndication__c>();
        syndication = new Syndication__c();
        isOfferSelected = false;
        objOpp = new Opportunity(Id = OppId);
        selOfferid = '';
        accList = new list<Account>();
        mOppFieldWrapper = new Map<String,OppFieldWrapper>();
        globalMap = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult descbResultOpp = globalMap.get('Opportunity').getDescribe();
        masterOppFieldSetList = descbResultOpp.FieldSets.getMap().get(system.Label.DEWOppQueryFields).getFields();
        dynamicOppFieldSetList = descbResultOpp.FieldSets.getMap().get(system.Label.DEWDealInfoDetail).getFields();
        summaryOppFieldSetList = descbResultOpp.FieldSets.getMap().get(system.Label.DEWDealInfoSummary).getFields();
        
        mapApiToOppFields = descbResultOpp.fields.getMap();
        objOpp  = refereshOpportunityByID(OppId);
       
        if(objOpp  != null)
        {
            checkAdvCommCall = objOpp.Commission_Engine_Check__c;
            
        }
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
        
        list<Contract> ContractList = new list<Contract>();
        ContractList = [Select Renewal_Eligibility_Percent__c,
                                Renewal_Eligibility_Days_from_funding__c,
                                Anticipated_Renewal_Date__c,
                                Notes__c,
                                Deal_Type__c,
                                Opportunity__c
                                from Contract where Opportunity__c =: OppId LIMIT 1];
        
        if(ContractList.size() > 0)
        objContract = ContractList[0];
        
        if(objOpp.Deal_Entry_Wizard_Check__c)
        {
            wizardType = DEAL_SCREEN;
            isOfferSelected = true;
        }
        else
            wizardType = OFFER_SCREEN;
        
        this.getOffers();
        this.getReceivables();
        this.getSyndication();
    }
    
    // Moved
    public void selectedOffer()
    {
        selOfferid = System.currentPagereference().getParameters().get('offerId');
        
        if(selOfferid != ''){
            isOfferSelected = true;
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please save the records to continue'));
            return;
        }
        
        wizardType = DEAL_SCREEN;
        //Save the offer when the Page changes
        DEWOfferService.quickSaveOffer(offerWrapperList, OppId);
        objOpp = DEWOfferService.selectedOffer(selectedOffer, offerMap, selOfferid, objOpp, objContract, selProgram, selSubmission);
        /*
        //get the offer that is selected and on that basis render the values
        if(!offerMap.isEmpty() && offerMap.containsKey(selOfferid))
        {
            selectedOffer = offerMap.get(selOfferid);
            objOpp.Term_Months__c = selectedOffer.Term_Months__c ;
            objOpp.Holdback_Percentage__c = selectedOffer.Holdback__c;
            objOpp.Schedule__c = selectedOffer.PMT_Schedule__c;
            /*objOpp.Payback_Amount__c = DEWUtility.treateNullAsZero(selectedOffer.Payback_Amt__c);
            objOpp.Funding_Amount__c = DEWUtility.treateNullAsZero(selectedOffer.Amount__c);
            objOpp.Payoff_Amount__c = DEWUtility.treateNullAsZero(selectedOffer.Payoff_Amount__c);
            objOpp.Payment_Amount__c = DEWUtility.treateNullAsZero(selectedOffer.Payment_Amt__c);*/
            /*objOpp.Payback_Amount__c = (selectedOffer.Payback_Amt__c);
            objOpp.Funding_Amount__c = (selectedOffer.Amount__c);
            objOpp.Payoff_Amount__c = (selectedOffer.Payoff_Amount__c);
            objOpp.Payment_Amount__c = (selectedOffer.Payment_Amt__c);
            objContract.Deal_Type__c = selectedOffer.Deal_Type__c;
            objOpp.Deal_Type__c = selectedOffer.Deal_Type__c;
            objOpp.Bank_Name__c = selectedOffer.Funder__c;
            objOpp.Origination_fee__c = selectedOffer.Origination_fee__c;   // added temp
            selSubmission = [select Id, Name, Program__c from Submission__c where Id =: selectedOffer.Submission__c];
            objOpp.Bank_Program__c = selSubmission.Program__c;
            objOpp.Buy_Rate__c = selectedOffer.Buy_Rate__c;
            objOpp.Factor_Rate__c = selectedOffer.Rate__c;
            
            if(objOpp.Bank_Program__c <> null)
            {
                selProgram = [select Id, Name,Payback_Funded__c,Commission_Percentage__c,Renewal_Eligibility__c from Program__c where Id =:selSubmission.Program__c];
                objOpp.Renewal_Eligibility_Percent__c = selProgram.Renewal_Eligibility__c;
                
                if( selProgram.Renewal_Eligibility__c != null && objOpp.Term_Months__c != null)
                {
                    objOpp.Renewal_Eligibility_Days_from_funding__c = (objOpp.Term_Months__c  *  objOpp.Renewal_Eligibility_Percent__c)/100;
                    DateTime dt = System.Now() + ( objOpp.Renewal_Eligibility_Days_from_funding__c * 30.4368);
                    objOpp.Estimated_Renewal_Date__c = Date.newInstance(Dt.year(),Dt.Month(),Dt.day());
                }
            }
        }*/
        
        //this internally sirst save the opp and its related field and then refresh the opp object in the //DEW and its respective wrapper
        this.save();
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
            wizardType = SYNDICATION_SCREEN;
            this.quickSavePayable();
            getSyndication();
        }
        else if(wizardType == SYNDICATION_SCREEN)
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
            wizardType = SYNDICATION_SCREEN;
            syndicationList = DEWSyndicationsService.getSyndicationFromDB(OppId);
          
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
            offerWrapperList.add(new offerWrapper(offer, false));
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
        /*
        if(recCount == 1 || recWizardCount==1)
        {
            recCount = 2;
            recWizardCount = 2;
            for(Receivable__c rec:receivableList)
            {
                if(objOpp.Funding_Amount__c!=null && rec.Payback_Funded__c == 'Funded')
                rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                else if(objOpp.Payback_Amount__c != null && rec.Payback_Funded__c == 'Payback')
                rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                else if(rec.Payback_Funded__c == 'Net Funded Amount')
                rec.Deal_Amount_Used__c = DEWUtility.treateNullAsZero(objOpp.Funding_Amount__c) - DEWUtility.treateNullAsZero(objOpp.Payoff_Amount__c);
                else{
                    if(objOpp.Funding_Amount__c!=null)
                    rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                }
                if(rec.Percentage__c != null && rec.Deal_Amount_Used__c != null)
                rec.Amount__c = rec.Deal_Amount_Used__c * (rec.Percentage__c/100);
            }
        }
        */
       
        receivableAmtTotal = DEWReceivablesService.calculateRecAmtTotal(receivableAmtTotal, receivableList);
       /*if(receivableList.size()>0){
            for(Receivable__c rec:receivableList){
                if(rec.Amount__c!=null)
                receivableAmtTotal = receivableAmtTotal + rec.Amount__c;
            }
        }*/
    }// end of If-getValues = 'populateData'
    
    //moved 
    //Function to get the Payables
    public void getPayables()
    {
        payableAmtTotal =0.00;
        // Query the receivables and display them on the Page
        payableList = DEWPayablesService.getPayablesFromDB(OppId);
        
        // build bridge between Comission engine and MCA App (MCA-739) By Merul
        if(label.ActivateCommissionEngine == 'true')
        {
            String labelString = Label.CommissionEngineClassName;
            checkAdvCommCall = DEWPayablesService.callCommissionCreatePayable(objOpp, 
                                                                              OppId, 
                                                                              labelString,
                                                                              checkAdvCommCall, 
                                                                              payableList);
            /*List<Payable__C> advComPayableList = new List<Payable__C>();
            
            if(objOpp.Deal_Entry_Wizard_Check__c == false && checkAdvCommCall == false )
            {
                //type t = type.forName(Label.CommissionEngineClassName);
                type t = type.forName(labelString);
                if(t != Null)
                {
                    MCAExtensionInterface_version McaExtension = (MCAExtensionInterface_version) t.newinstance();
                    advComPayableList = McaExtension.commissioncal(OppId);
                    if( advComPayableList.size() > 0)
                    {
                        //To indicate the commision call has been made.
                        checkAdvCommCall = true;
                    }
                    payableList.addAll(advComPayableList);
                }
            }*/
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
            /*
            if(objOpp.Deal_Entry_Wizard_Check__c == false && accList.size() > 0 && receivableList.size() >0 && receivableList <> null)
            {
                CommissionPer = DEWUtility.treateNullAsZero(accList[0].Commission_Percentage__c);
                for (integer i=0; i<receivableList.size();i++)
                {
                    if((receivableList[i].Type__c == 'Commission' && accList[0].Payback_Funded__c == 'Commission Revenue') && receivableList[i].Wizard_Check__c == false && objOpp.Deal_Entry_Wizard_Check__c == false && receivableList[i].IsCreatedFromGrid__c == false)
                    {
                        //payableList = DEWPayablesService.addPayable(payableList, receivableList, OppId, CommissionPer, accList, i);
                        payableList.add(new Payable__c(Opportunity__c = OppId,
                                                        Type__c = receivableList[i].Type__c,
                                                        Percentage__c = CommissionPer,
                                                        Payback_Funded__c =accList[0].Payback_Funded__c,
                                                        Due_Date__c = Date.Today()+7,
                                                        Amount_Due__c = receivableList[i].Amount__c * (CommissionPer/100),
                                                        Status__c = 'Open - Needs Review',
                                                        Receivable_Dependency__c = receivableList[i].Id,
                                                        Memo__c = receivableList[i].Memo__c,
                                                        Deal_Amount_Used__c = receivableList[i].Deal_Amount_Used__c,
                                                        Wizard_Check__c = true,
                                                        Account__c = accList[0].Id));
                                                        
                        receivableList[i].Wizard_Check__c = true;
                        
                    }//End If
                    
                    else if((accList[0].Payback_Funded__c == 'Payback'  || accList[0].Payback_Funded__c == 'Funded')
                    && receivableList[i].Wizard_Check__c == false &&
                    objOpp.Deal_Entry_Wizard_Check__c == false && receivableList[i].IsCreatedFromGrid__c == false)
                    {
                        if(payableList.size()>0)
                        {
                            for(Payable__c pay:payableList)
                            {
                                if(pay.Amount_Due__c!=null)
                                payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
                            }
                        }
                        if(payableList.size()<=0 && wizardType != PREVIEW_SCREEN){
                            payableList = DEWPayablesService.addPayableRow(OppId,
                            objOpp,
                            accList,
                            receivableList,
                            payableList);
                        }
                        receivableList[i].Wizard_Check__c = true;
                    }
                    
                    else if(receivableList.size() > 0 && (receivableList[i].Type__c <> null && accList[0].Payback_Funded__c == 'All Revenue')
                    && receivableList[i].Wizard_Check__c == false &&
                    objOpp.Deal_Entry_Wizard_Check__c == false && receivableList[i].IsCreatedFromGrid__c == false)
                    {
                        //ayableList = DEWPayablesService.addPayable(payableList, receivableList, OppId, CommissionPer, accList, i);
                        payableList.add(new Payable__c(Opportunity__c = OppId,
                                                        Type__c = receivableList[i].Type__c,
                                                        Percentage__c = CommissionPer,
                                                        Payback_Funded__c =accList[0].Payback_Funded__c,
                                                        Due_Date__c = Date.Today()+7,
                                                        Amount_Due__c = DEWUtility.treateNullAsZero(receivableList[i].Amount__c) * (CommissionPer/100),
                                                        Status__c = 'Open - Needs Review',
                                                        Receivable_Dependency__c=receivableList[i].Id,
                                                        Memo__c = receivableList[i].Memo__c,
                                                        Deal_Amount_Used__c = receivableList[i].Deal_Amount_Used__c,
                                                        Wizard_Check__c = true,
                                                        Account__c = accList[0].Id));
                                                        
                        receivableList[i].Wizard_Check__c = true;
                    }
                    else
                    {
                        receivableList[i].Wizard_Check__c = true;
                    }
                }
                update receivableList;
            }
            */
            
            /*if(payableList.size()<=0 && wizardType != PREVIEW_SCREEN)
            {
                payableList = DEWPayablesService.addPayableRow(OppId,
                                                                objOpp,
                                                                accList,
                                                                receivableList,
                                                                payableList);
            }*/
            
            if(payCount == 1 || payWizardCount==1)
            {
                payCount = 2;
                payWizardCount = 2;
            }
        }
        
        //For Grand total of Payables
        payableAmtTotal = DEWPayablesService.calculatePayAmtTotal(payableAmtTotal, payableList);
        /*if(payableList.size()>0)
        {
            for(Payable__c pay:payableList){
                if(pay.Amount_Due__c!=null)
                payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
            }
        }
        */
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
        /*syndAmtTotal=0.00;
        if(syndicationList.size()>0)
        {
            for(Syndication__c synd:syndicationList)
            {
                if(synd.Syndication_Amt__c!=null)
                syndAmtTotal = syndAmtTotal + synd.Syndication_Amt__c;
            }
        }*/
       /* if(syndicationList.size()<=0 && wizardType != PREVIEW_SCREEN)
        addRowSyndication();*/
    }
    
    public List<SelectOption> getSubmissionNames()
    {
        List<SelectOption> options = new List<SelectOption>();
        List<Submission__c> submissionlist = new List<Submission__c>();
        submissionlist = [Select Id, Name,Funder__c,Funder__r.Name, Status__c FROM Submission__c where Opportunity__c =: OppId];
        
        for (Integer j=0;j<submissionlist.size();j++){
            String subName = submissionlist[j].Name;
            options.add(new SelectOption(submissionlist[j].Id,submissionlist[j].Funder__r.Name+'-'+submissionlist[j].Status__c+'-('+subName.substring(4,subName.length())+')'));
        }
        return options;
    }
    
    // moved 
    public void addRowOffer(){
        //offerWrapperList = DEWOfferService.addRowOffer(offerWrapperList, OppId);
        offerWrapperList.add(new offerWrapper(new Offer__c(Opportunity__c = OppId), false));
    }
    
    //moved
    public void addRowPayable(){
        /*
        Receivable__c objRec = new Receivable__c();
        if(accList != null && accList.size() > 0 && receivableList != null && receivableList.size()>0 && payableList.size()<=0
        && objOpp.Deal_Entry_Wizard_Check__c == false
        && (accList[0].Payback_Funded__c == 'Payback'  || accList[0].Payback_Funded__c == 'Funded')){
        for(Receivable__c rec : receivableList){
        if(rec.Type__c == 'Commission')
        objRec = rec;
        }
        Account accObj = accList[0];
        payableList.add(new Payable__c( Opportunity__c = OppId,
        Type__c = 'Commission',
        Percentage__c = accList[0].Commission_Percentage__c,
        Payback_Funded__c = accList[0].Payback_Funded__c,
        Due_Date__c = Date.Today()+7,
        Amount_Due__c = (accList[0].Commission_Percentage__c==null ? 0 : (accList[0].Commission_Percentage__c/100)) * (accList[0].Payback_Funded__c!=null && accList[0].Payback_Funded__c=='Payback' ? (objOpp.Payback_Amount__c==null ? 0 : objOpp.Payback_Amount__c) : (objOpp.Funding_Amount__c==null ? 0:objOpp.Funding_Amount__c)),
        Status__c = 'Open - Needs Review',
        Receivable_Dependency__c = objRec.Id,
        Account__c = (accList[0].Id == null ? null : accList[0].ID),//account.Id,
        Deal_Amount_Used__c = objRec.Deal_Amount_Used__c,
        Memo__c = objRec.Memo__c));
        }else{
        payableList.add(new Payable__c(Opportunity__c = OppId));
        }
        */
       
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
        /*if(selProgram != null && receivableList.size()<=0){
            receivableList.add(new Receivable__c(Opportunity__c = OppId, Due_From_Account__c = objOpp.Bank_Name__c,
            Percentage__c = selProgram.Commission_Percentage__c,//selProgram.Commission_Percentage__c,
            Payback_Funded__c =selProgram.Payback_Funded__c,
            
            Amount__c = (selProgram.Commission_Percentage__c==null ? 0 :(selProgram.Commission_Percentage__c/100)) * (selProgram.Payback_Funded__c!=null && selProgram.Payback_Funded__c=='Payback' ? (objOpp.Payback_Amount__c==null ? 0 : objOpp.Payback_Amount__c):(objOpp.Funding_Amount__c==null ? 0 : objOpp.Funding_Amount__c)),
            Due_Date__c = Date.Today()+7,Type__c = 'Commission',Status__c = 'Pending' ));
        }
        else
        {
            receivableList.add(new Receivable__c(Opportunity__c = OppId, Due_From_Account__c = objOpp.Bank_Name__c ));
        }*/
    }
    
    /*****************Merul*******************/
    // moved
    /*public void addRowReceivableForOriginationFeeType()
    {
        //Logic for non repeation of origination fee generation in recevialble screen
        
        DEWReceivablesService.addRowReceivableForOriginationFeeType(receivableList, wizardType, selOfferid, objOpp, PREVIEW_SCREEN, OppId);
        Boolean orignRec = false;
        for(Receivable__c recWizard:receivableList){
            if(recWizard.Type__c == 'Origination fee'){
                orignRec = true;
            }
        }
        
        if(!orignRec && wizardType != PREVIEW_SCREEN && !string.isblank(selOfferId) && objOpp.Account.id!= null && objOpp.Origination_fee__c != null && objOpp.Origination_fee__c != 0 /*&&
        orgFeeOfSelectedOffID != NULL*//*)
        {
            receivableList.add(new Receivable__c(Opportunity__c = OppId,
                                                    Due_From_Account__c = objOpp.Account.id,
                                                    Type__c = 'Origination Fee',
                                                    Amount__c = objOpp.Origination_fee__c
                                                 ));
        }
    }*/
    
    /*****************Merul*******************/
    // moved 
    public void addRowSyndication(){
        DEWSyndicationsService.addRowSyndication(syndicationList, OppId);
        //syndicationList.add(new Syndication__c(Opportunity__c = OppId));
    }
    
    // moved
    public void quickSaveOffer(){
    DEWOfferService.quickSaveOffer(offerWrapperList, OppId);
    this.getOffers();
    /*    try{
            list<Offer__c> Offerlst = new list<Offer__c>();
            List<OfferWrapper> listTempOfferwrap = new List<OfferWrapper>();
            for(OfferWrapper wrapper :  offerWrapperList)
            {
                Offerlst.add(wrapper.offer);
                
            }
            
            Offerlst = DEWUtility.checkSaveAccessForSObject(Offerlst,UserInfo.getUserId());
            if(Offerlst.size() > 0)
            {
                DEWUtility.upsertForSObject(Offerlst);
            }
            DEWOfferService.getOffers();
            
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            wizardType = OFFER_SCREEN;
            //currState = prevState;
        }*/
    }
    
    // moved 
    public void quickSavePayable()
    {
        try{
        payableList = DEWPayablesService.quickSavePayable(payableList,objOpp, OppId);
        /*
            list<Payable__c> lstPayableToUpsert = new list<Payable__c> ();
            list<Payable__c> lstPayableToDisplay = new list<Payable__c> ();
            list<Payable__c> lstPayablesWithNullValueToDelete = new list<Payable__c> ();
            if(payableList.size() > 0 )
            {
                for(Integer i=0; i<payableList.size(); i++)
                {
                    if(!DEWPayablesService.payablesFieldsNullValidator(payableList[i]))
                    {
                        lstPayableToUpsert.add(payableList[i]);
                        lstPayableToDisplay.add(payableList[i]);
                    }
                    else
                    {
                        if(payableList[i].Id != null)
                        lstPayablesWithNullValueToDelete.add(payableList[i]);
                    }
                }
            }
            lstPayableToUpsert = DEWUtility.checkSaveAccessForSObject(lstPayableToUpsert,UserInfo.getUserId());
            DEWUtility.upsertForSObject(lstPayableToUpsert);
            delete lstPayablesWithNullValueToDelete;
            payableList = DEWPayablesService.getPayablesFromDB(OppId); */
            
            payableAmtTotal = DEWPayablesService.calculatePayAmtTotal(payableAmtTotal, payableList);
            
            /*payableAmtTotal = 0.0;
            if(payableList.size()>0)
            {
                for(Payable__c pay:payableList){
                    if(pay.Amount_Due__c!=null)
                    payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
                }
            }*/
            
            
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
           /* list<Receivable__c> lstReceivableToUpsert = new list<Receivable__c> ();
            list<Receivable__c> lstReceivableToDisplay = new list<Receivable__c> ();
            list<Receivable__c> lstReceivableWithNullValueToDelete = new list<Receivable__c> ();
            if(receivableList.size() > 0 )
            {
                for(Integer i=0; i<receivableList.size(); i++)
                {
                    if(!DEWReceivablesService.receivablesFieldsNullValidator(receivableList[i]))
                    {
                        lstReceivableToUpsert.add(receivableList[i]);
                        lstReceivableToDisplay.add(receivableList[i]);
                    }
                    else
                    {
                        if(receivableList[i].Id != null)
                        lstReceivableWithNullValueToDelete.add(receivableList[i]);
                    }
                }//end of for
            }
            lstReceivableToUpsert = DEWUtility.checkSaveAccessForSObject(lstReceivableToUpsert,UserInfo.getUserId());
            DEWUtility.upsertForSObject(lstReceivableToUpsert);
            delete lstReceivableWithNullValueToDelete;
            //Refreshing opportunity from DB.
            objOpp = refereshOpportunityByID(OppId);
            receivableList = lstReceivableToDisplay;*/
            
            receivableAmtTotal = DEWReceivablesService.calculateRecAmtTotal(receivableAmtTotal, receivableList);
            
            /*receivableAmtTotal = 0.0;
            if(receivableList.size()>0)
            {
                for(Receivable__c rec:receivableList)
                {
                    if(rec.Amount__c!=null)
                    receivableAmtTotal = receivableAmtTotal + rec.Amount__c;
                }
            }*/
            
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
        /*list<Syndication__c> lstSyndicationToUpsert = new list<Syndication__c> ();
        list<Syndication__c> lstSyndicationToDisplay = new list<Syndication__c> ();
        list<Syndication__c> lstSyndicationWithNullValueToDelete = new list<Syndication__c> ();
       
            if(syndicationList.size() > 0)
            {
                for(Integer i=0; i<syndicationList.size(); i++)
                {
                    if(!DEWSyndicationsService.syndicationFieldsNullValidator(syndicationList[i]))
                    {
                        lstSyndicationToUpsert.add(syndicationList[i]);
                        lstSyndicationToDisplay.add(syndicationList[i]);
                    }
                    else
                    {
                        if(syndicationList[i].Id != null) {
                            
                            lstSyndicationWithNullValueToDelete.add(syndicationList[i]);
                        }
                    }
                    
                }//end of for
            }
            lstSyndicationToUpsert = DEWUtility.checkSaveAccessForSObject(lstSyndicationToUpsert,UserInfo.getUserId());
            DEWUtility.upsertForSObject(lstSyndicationToUpsert);
            delete lstSyndicationWithNullValueToDelete;
            //this.getSyndication();
            syndicationList = lstSyndicationToDisplay;
            */
            
            syndAmtTotal = DEWSyndicationsService.calculateSynAmtTotal(syndAmtTotal, syndicationList);
            
            /*syndAmtTotal = 0.0;
            if(syndicationList.size()>0)
            {
                for(Syndication__c synd:syndicationList)
                {
                    if(synd.Syndication_Amt__c!=null)
                    syndAmtTotal = syndAmtTotal + synd.Syndication_Amt__c;
                }
            }*/
        }
        catch(Exception e){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            //currState = prevState;
        }
    }
    // moved
    // Delete offer
    public void deleteOffer(){
        try
        {
            string delname = ApexPages.CurrentPage().getParameters().get('delname');
            Integer rowNum = Integer.valueOf(ApexPages.currentPage().getParameters().get('index'));
            DEWOfferService.deleteOffer(delname, rowNum, isOfferSelected, selOfferid, offerWrapperList);
            //this.getOffers();
            
            /*Id offerId;
            if(delname != '' && selOfferid != '' && delname.substring(0,15) == selOfferid.substring(0,15))
            {
                isOfferSelected = false;
            }
            
            list<Offer__c> OfferDeleteList = new list<Offer__c>();
            if( rowNum != null ){
                // remove object from list
                if(offerWrapperList[rowNum-1].offer.Id != null)
                {
                    offerId = offerWrapperList[rowNum-1].offer.Id;
                    set<Id> offIdSet = new set<Id>();
                    offIdSet.add(offerId);
                    if(DEWUtility.checkUserAccessForSobject(offIdSet,UserInfo.getUserId())[0].HasDeleteAccess)
                    {
                        OfferDeleteList.add(offerWrapperList[rowNum-1].offer);
                        offerWrapperList.remove(rowNum-1);
                    }
                }
            }
            if(OfferDeleteList.size() > 0)
            delete OfferDeleteList;
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Insufficient privilege to delete this record'));
            }*/
            
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
        }
    }
    
    //remove payables on click of Delete link
    // moved
    public void deletPayables(){
        /*list<SObject> payableDelList = new list<SObject>();
        list<UserRecordAccess> UserRecordAccessListNullChk = new list<UserRecordAccess>();
        
        try
        {
        rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        payableDelList = DEWUtility.deleteForSObject(payableList,rowNum);
        
        if(payableDelList.size()>0){
        delete payableDelList;
        }
        }
        catch(Exception e){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
        }*/
        
        //rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        // DEWPayablesService.toDeletPayables(payableList,rowNum);
       
       
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
        /*list<Receivable__c> receivableDelList = new list<Receivable__c>();
        list<UserRecordAccess> UserRecordAccessListNullChk = new list<UserRecordAccess>();
        
        try
        {
        rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'))+1;
        receivableDelList = DEWUtility.deleteForSObject(receivableList,rowNum);
        if(receivableDelList.size()>0)
        {
        delete receivableDelList;
        }
        }
        catch(Exception e)
        {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
        
        }*/
        
       // rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'))+1;
       // DEWReceivablesService.toDeletReceivables(receivableList ,rowNum);
       
       
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
        /*list<Syndication__c> syndicationdelList = new list<Syndication__c>();
        try
        {
        rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        syndicationdelList = DEWUtility.deleteForSObject(syndicationList,rowNum);
        
        if(syndicationdelList.size()>0){
        delete syndicationdelList;
        }
        }catch(Exception e){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
        
        }*/
        
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
        }
    }
    
    public void onChangeRenewalEliPer(){
        if( objOpp.Renewal_Eligibility_Percent__c != null && objOpp.Term_Months__c != null){
            objOpp.Renewal_Eligibility_Days_from_funding__c = (objOpp.Term_Months__c  *  objOpp.Renewal_Eligibility_Percent__c)/100;
            DateTime dt = System.Now() + (((objOpp.Term_Months__c  *  objOpp.Renewal_Eligibility_Percent__c)/100) * 30.4368);
            objOpp.Estimated_Renewal_Date__c = Date.newInstance(Dt.year(),Dt.Month(),Dt.day());
        }
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
        /*for(Receivable__c rec : receivableList)
        {
             
                if(rec.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                    rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                else if(rec.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                    rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                else if(rec.Payback_Funded__c == 'Net Funded Amount')
                    rec.Deal_Amount_Used__c = DEWUtility.treateNullAsZero(objOpp.Funding_Amount__c) - DEWUtility.treateNullAsZero(objOpp.Payoff_Amount__c);
               /* else
                {
                    if(objOpp.Payback_Amount__c != null)
                        rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                }*/
                
                /*if(rec.Percentage__c != null)
                    rec.Amount__c = rec.Deal_Amount_Used__c * (rec.Percentage__c/100);
        }
        */
        
        /*if(receivableList.size()>0)
        {
            for(Receivable__c rec:receivableList)
            {
                if(rec.Amount__c!=null)
                receivableAmtTotal = receivableAmtTotal + rec.Amount__c;
            }
        }*/
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
       
        /*if(payableList.size()>0)
        {
            for(Payable__c pay:payableList)
            {
                if(pay.Amount_Due__c!=null)
                payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
            }
        }*/
    }
    // moved
    /*public Decimal calculateNetCommissionRevenue(Opportunity oppObj)
    {
        decimal val = 0.00;
        if(mapApiToOppFields.get(System.Label.MCAFieldTotal_Commissions_Receivable) !=Null  && mapApiToOppFields.get(System.Label.MCACEField_Commissions_Payable_External) != Null)
        {
            String queryStr = 'Select '+System.Label.MCAFieldTotal_Commissions_Receivable+','+System.Label.MCACEField_Commissions_Payable_External+' From Opportunity Where id = \'' +oppObj.Id+'\'';
            List<Opportunity> tempOpp = database.Query(queryStr);
            if(tempOpp != null && tempOpp.size()>0)
            {
                oppObj.put(System.Label.MCAFieldTotal_Commissions_Receivable,tempOpp[0].get(System.Label.MCAFieldTotal_Commissions_Receivable));
                oppObj.put(System.Label.MCACEField_Commissions_Payable_External,tempOpp[0].get(System.Label.MCACEField_Commissions_Payable_External));
                
                val = DEWUtility.treateNullAsZero((Decimal)(oppObj.get(System.Label.MCAFieldTotal_Commissions_Receivable))) - DEWUtility.treateNullAsZero((Decimal)(oppObj.get(System.Label.MCACEField_Commissions_Payable_External)));
            }
        }
        else
            val = 0.00;
        return val;
    }*/
    
    //  moved
    /*public Decimal calculateNetOriginationFees(Opportunity oppObj)
    {
        decimal val = 0.00;
        if(mapApiToOppFields.get(System.Label.MCAField_Total_Origination_Fees_Receivable) !=Null  && mapApiToOppFields.get(System.Label.MCACEField_Origination_Fees_Payable_External) != Null)
        {
            String queryStr = 'Select '+System.Label.MCAField_Total_Origination_Fees_Receivable+','+System.Label.MCACEField_Origination_Fees_Payable_External+' From Opportunity Where id = \'' +oppObj.Id+'\'';
            List<Opportunity> tempOpp = database.Query(queryStr);
            if(tempOpp != Null && tempOpp.size() >0)
            {
                oppObj.put(System.Label.MCAField_Total_Origination_Fees_Receivable,tempOpp[0].get(System.Label.MCAField_Total_Origination_Fees_Receivable));
                oppObj.put(System.Label.MCACEField_Origination_Fees_Payable_External,tempOpp[0].get(System.Label.MCACEField_Origination_Fees_Payable_External));
                
                val = DEWUtility.treateNullAsZero((Decimal)(oppObj.get(System.Label.MCAField_Total_Origination_Fees_Receivable))) - DEWUtility.treateNullAsZero((Decimal)(oppObj.get(System.Label.MCACEField_Origination_Fees_Payable_External)));
            }
        }
        else
            val = 0.00;
        return val;
    }*/
    
    // moved
    public void onChangeRecPercentage()
    {
        String recevableid = System.currentPagereference().getParameters().get('recId');
        receivableAmtTotal = 0.00;
        DEWReceivablesService.onChangeOfRecPercentage(receivableList, objOpp);
        /*if(receivableList.size()>0)
        {
            for(Receivable__c rec:receivableList)
            {
                if(rec.Amount__c!=null)
                    receivableAmtTotal = receivableAmtTotal + rec.Amount__c;
            }
        }*/
        receivableAmtTotal = DEWReceivablesService.calculateRecAmtTotal(receivableAmtTotal, receivableList);
    }
    
    // moved
    public void onChangePayPercentage()
    {
        String payableid = System.currentPagereference().getParameters().get('payId');
        
        DEWPayablesService.onChangeOfPayPercentage(receivableList, payableList, objOpp, mapApiToOppFields);
        /*decimal receivableAmountCommission = 0.00;
        decimal receivableAmountAllRevenue = 0.00;
        decimal receivableOrgFee = 0.00;
        
        for(Receivable__c rec: receivableList)
        {
            if(rec.Amount__c <> null && rec.Type__c == 'Commission'){
                receivableAmountCommission += rec.Amount__c;
            }
            if(rec.Amount__c <> null && rec.Type__c == 'Origination Fee'){
                receivableOrgFee += rec.Amount__c;
            }
            if(rec.Amount__c <> null && rec.Type__c <> null){
                receivableAmountAllRevenue += rec.Amount__c;
            }
        }
       
        for(Payable__c pay : payableList)
        {
            
            if(!pay.Wizard_Check__c)
            {
                //For Funded
                if(pay.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                
                //For Payback
                if(pay.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                pay.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                
                //For Net Funded Amount
                if(pay.Payback_Funded__c == 'Net Funded Amount')
                pay.Deal_Amount_Used__c = DEWUtility.treateNullAsZero(objOpp.Funding_Amount__c) - DEWUtility.treateNullAsZero(objOpp.Payoff_Amount__c);
                
                //For Net Commission Revenue
                if(pay.Payback_Funded__c == 'Net Commission Revenue')
                pay.Deal_Amount_Used__c =  DEWPayablesService.calculateNetCommissionRevenue(objOpp, mapApiToOppFields);
                
                //For Net Origination Fee
                if(pay.Payback_Funded__c == 'Net Origination Fee')
                pay.Deal_Amount_Used__c =  DEWPayablesService.calculateNetOriginationFees(objOpp, mapApiToOppFields);
                
                //For Commision Revenue
                if(pay.Payback_Funded__c == 'Commission Revenue' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = receivableAmountCommission;
                
                //All revenue
                if(pay.Payback_Funded__c == 'All Revenue' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = receivableAmountAllRevenue;
                
                
                if(pay.Deal_Amount_Used__c != null && pay.Percentage__c != null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                
            }*/
            
            /*************Merul*************************/
          //  DEWPayablesService.onChangePayAmountCalculation(receivableList,payableList);
            /*************Merul*************************/
            
       //}
        
        payableAmtTotal =0.00;
        payableAmtTotal = DEWPayablesService.calculatePayAmtTotal(payableAmtTotal, payableList);
       
        /*if(payableList.size()>0)
        {
            for(Payable__c pay:payableList)
            {
                if(pay.Amount_Due__c!=null)
                payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
            }
        }*/
        
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
    // moved
    // to be moved to common utility
   /* public static ReferenceObjectDetail getReferenceObjectDetailOfField(sObject record, String field)
    {
        if(field.contains('.'))
        {
            Integer firstPeriod = field.indexOf('.');
            String nextObjectRefName = field.subString(0, firstPeriod);
            String remainingfieldName = field.subString(firstPeriod + 1, field.length());
            String nextObjectName;
            
            if(nextObjectRefName.endsWithIgnoreCase('__r'))
            nextObjectName=nextObjectRefName.replaceAll('__r','__c');
            else
                nextObjectName = nextObjectRefName+'Id';
            
            return new ReferenceObjectDetail(record.getSObject(nextObjectRefName),
            nextObjectRefName,
            nextObjectName,
            remainingfieldName);
            
        }
        return new ReferenceObjectDetail(null,null,null,null);
    }*/
    
    // moved 
    // method to save opportunity and its related objects
    public void save()
    {
        objOpp = DEWOpportunityService.save(objOpp, dynamicOppFieldSetList, wizardType, DEAL_SCREEN, OppId, mOppFieldWrapper, oppFieldWrap);
        
        mOppFieldWrapper = CreateContractController.refereshDisplayOfOpportuntiyWrapper(dynamicOppFieldSetList,
                                                                    objOpp,
                                                                    oppFieldWrap,
                                                                    mOppFieldWrapper);
        /*try
        {
            // Saving Main Opportunity field
            list<Opportunity> oppList1 = new  list<Opportunity>();
            // objOpp.AccountId = AccountId;
            oppList1.add(objOpp);
            oppList1 = DEWUtility.checkSaveAccessForSObject(oppList1,userinfo.getUserId());
            if(oppList1.size() > 0 )
            {
                DEWUtility.upsertForSObject(oppList1);
            }
            
            // Saving Related object field of opportunity.
            List<Sobject> lOppRelatedSObjectToUpdate = new List<Sobject>();
            Set<Sobject> sOppRelatedSObject = new Set<Sobject>();
            
            for (FieldSetMember memberInsatnce : dynamicOppFieldSetList)
            {
                ReferenceObjectDetail refObjDetail = DEWUtility.getReferenceObjectDetailOfField(objOpp,memberInsatnce.getFieldPath());
                if(refObjDetail.recSObject != null)
                {
                    sOppRelatedSObject.add(refObjDetail.recSObject);
                }
            }
            //Collection of all the related object to update with opportunity.
            lOppRelatedSObjectToUpdate.addAll(sOppRelatedSObject);
            if(lOppRelatedSObjectToUpdate.size() > 0)
            {
                DEWUtility.upsertForSObject(lOppRelatedSObjectToUpdate);
            }
            
            //Refreshing opportunity from DB.
            objOpp = refereshOpportunityByID(OppId);
            
            // display opportunity based on oppFieldWrapper
            mOppFieldWrapper = refereshDisplayOfOpportuntiyWrapper(dynamicOppFieldSetList,
                                                                    objOpp,
                                                                    oppFieldWrap,
                                                                    mOppFieldWrapper);
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            wizardType = DEAL_SCREEN;
        }*/
    }
    
    public void refreshOppWrapperMap()
    {
        //this internally first save the opp and its related field and then refresh the opp object in the
        //DEW and its respective wrapper
        this.save();
    }
    
    public PageReference cancel()
    {
        objopp.Deal_Entry_Wizard_Check__c = true;
        
        try
        {
            upsert objopp;
        }
        catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
        }
        return new PageReference('/'+OppId);
    }

    //Commented the code because the functionality of MCA-841 is depricated
    /*  public void saveOnTabChange (String pState)
    {
      
        if(pState == RECEIVABLE_SCREEN){
        quickSaveReceivable();
        }
        if(pState == PAYABLE_SCREEN) {
        quickSavePayable();
        }
        if(pState == SYNDICATION_SCREEN) {
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
        /*if(currState == Null)
        {
        currState = WizardType;
        }
        else
        {
        prevState = currState;
        currState = WizardType;
        saveOnTabChange(prevState);
        
        }*/
        
        if(!isOfferSelected)
        isOfferSelected = false;
        if(wizardType == PREVIEW_SCREEN)
        {
            /*getPayables();
            getReceivables();
            getSyndication();*/
            
             payableList = DEWPayablesService.getPayablesFromDB(OppId);
             receivableList = DEWReceivablesService.getReceivablesFromDB(OppId);
             syndicationList =  DEWSyndicationsService.getSyndicationFromDB(OppId);
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
        if(wizardType == SYNDICATION_SCREEN)
        {
            syndicationList =  DEWSyndicationsService.getSyndicationFromDB(OppId);
           
        }
    }
    
    public string getbaseUrlOrg(){
        return MCAStringConstant.baseUrlOrg;
    }
    
    // moved
    // method to combine 2 different fieldset for building a dynamic query
    /*public String buildQueryStringForOpportunity(Id pOppId,
    List<Schema.FieldSetMember> masterOppFieldSetList,
    List<Schema.FieldSetMember> dynamicOppFieldSetList,
    List<Schema.FieldSetMember> summaryOppFieldSetList)
    {
        Set<String> fieldsSet = new Set<String>();
        for(Schema.FieldSetMember loopInstance :dynamicOppFieldSetList)
        {
            if(!fieldsSet.contains(loopInstance.getfieldPath()))
            {
                fieldsSet.add(loopInstance.getfieldPath());
            }
        }
        
        for(Schema.FieldSetMember loopInstance :masterOppFieldSetList )
        {
            if(!fieldsSet.contains(loopInstance.getfieldPath()))
            {
                fieldsSet.add(loopInstance.getfieldPath());
            }
        }
        for(Schema.FieldSetMember loopInstance :summaryOppFieldSetList)
        {
            if(!fieldsSet.contains(loopInstance.getfieldPath()))
            {
                fieldsSet.add(loopInstance.getfieldPath());
            }
        }
        
        String fieldsString = DEWUtility.getStringfromSet(fieldsSet, null);
        String queryStr = 'Select ' +fieldsString+ 'FROM Opportunity WHERE Id =\''+pOppId+'\'';
        return queryStr;
    } */

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
    
    //Wrapper Classes
    public class OfferWrapper
    {
        public Offer__c offer                     {get; set;}
        public boolean isSelected                 {get; set;}
        public OfferWrapper(Offer__c pOffer, Boolean pIsSelected)
        {
            offer = pOffer;
            isSelected = pIsSelected;
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