/*
*  Controller for create Contract Page
*
*  Revision History:
*
*  Version        Author                       Date                Description
*  1.0            Sneha P                      31/03/2014          Initial Draft
*  1.1            Nachiket Deshpande           18/03/2015          Added commission split functionility.
*/
public with sharing class CreateContractController {
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
    public Integer recCount = 0;
    public Integer recWizardCount = 0;
    public Integer payCount = 0;
    public Integer payWizardCount = 0;
    public Boolean checkAdvCommCall;
    private map<ID, Offer__c> offerMap;
    private String Stage;
    public String currState;
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
    public Map<String, Schema.SObjectField> mapStringToObjectFields = new Map<String, Schema.SObjectField>();
    // public String renderingService {get;set;}
    public CreateContractController()
    {
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
        // checkAdvCommCall = false;
        objOpp = new Opportunity(Id = OppId);
        selOfferid = '';
        //Nachiket 1.1
        accList = new list<Account>();
    }
    
    //Function Called on init to populate all the data in the Tables
    public void populateData()
    {
        mapStringToObjectFields = Schema.SObjectType.opportunity.fields.getMap();
        opportunityList = getOpportunityFromDB(OppId);
        
        if(opportunityList != null && opportunityList.size() > 0 )
        {
            objOpp = opportunityList[0];
            checkAdvCommCall = objOpp.Commission_Engine_Check__c;
        }
        
        //Nachiket 1.9
        accList = [Select Id,
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
        this.quickSaveOffer();
        
        
        
        //get the offer that is selected and on that basis render the values
        if(!offerMap.isEmpty() && offerMap.containsKey(selOfferid))
        {
            selectedOffer = offerMap.get(selOfferid);
            objOpp.Term_Months__c = selectedOffer.Term_Months__c ;
            objOpp.Holdback_Percentage__c = selectedOffer.Holdback__c;
            objOpp.Schedule__c = selectedOffer.PMT_Schedule__c;
            objOpp.Payback_Amount__c = selectedOffer.Payback_Amt__c;
            objOpp.Funding_Amount__c = selectedOffer.Amount__c;
            objOpp.Payment_Amount__c = selectedOffer.Payment_Amt__c;
            objContract.Deal_Type__c = selectedOffer.Deal_Type__c;
            objOpp.Deal_Type__c = selectedOffer.Deal_Type__c;
            objOpp.Bank_Name__c = selectedOffer.Funder__c;
            objOpp.Origination_fee__c = selectedOffer.Origination_fee__c;   // added temp
            selSubmission = [select Id, Name, Program__c from Submission__c where Id =: selectedOffer.Submission__c];
            objOpp.Bank_Program__c = selSubmission.Program__c;
            objOpp.Buy_Rate__c = selectedOffer.Buy_Rate__c;
            objOpp.Payoff_Amount__c = selectedOffer.Payoff_Amount__c;
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
            
            
        }
    }
    
    //Function called on click of Next button, it will redirect to next Screen
    public void next()
    {
        if(wizardType == OFFER_SCREEN)
        wizardType = DEAL_SCREEN;
        else if(wizardType == DEAL_SCREEN)
        {
            wizardType = RECEIVABLE_SCREEN;
            ++recCount;
            this.save();
            getReceivables();
            addRowReceivableForOriginationFeeType();
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
            
        }
        else if(wizardType == SYNDICATION_SCREEN)
        {
            wizardType = PREVIEW_SCREEN;
            
            this.quickSaveSyndication();
        }
    }
    
    //Function called on click of Previous button, it will redirect to previous Screen
    public void previous()
    {
        if(wizardType == PREVIEW_SCREEN)
        {
            wizardType = SYNDICATION_SCREEN;
            syndicationList = getSyndicationFromDB(OppId);
        }
        else if(wizardType == SYNDICATION_SCREEN)
        {
            wizardType = PAYABLE_SCREEN;
            this.quickSaveSyndication();
            payableList = getPayablesFromDB(OppId);
        }
        else if(wizardType == PAYABLE_SCREEN)
        {
            wizardType = RECEIVABLE_SCREEN;
            this.quickSavePayable();
            receivableList = getReceivablesFromDB(OppId);
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
    
    public void getOffers()
    {
        offerMap = new map<ID, Offer__c>([Select id,Opportunity__c,Name,Payment_Amt__c,Term_Months__c,Deal_Type__c,
        PMT_Schedule__c,Holdback__c,Funder__c,Payback_Amt__c,Amount__c,Rate__c,
        Submission__c,Status__c,Origination_fee__c,Buy_Rate__c,Expected__c,
        Payback_Funded__c,Referral_Payout__c,Details__c,Payoff_Amount__c,Net_Funded_Amount__c
        from Offer__c  where Opportunity__c =: OppId]);
        offerWrapperList.clear();
        for(Offer__c offer : offerMap.values()){
            
            offerWrapperList.add(new offerWrapper(offer, false));
        }
        if(offerWrapperList.size() == 0){
            addRowOffer();
        }
    }
    
    //Function to get the Receivables
    public void getReceivables()
    {
        // Query the receivables and display them on the Page
        receivableAmtTotal=0.00;
        //if(receivableList == null)
        receivableList = getReceivablesFromDB(OppId);
        
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
                rec.Deal_Amount_Used__c = treateNullAsZero(objOpp.Funding_Amount__c) - treateNullAsZero(objOpp.Payoff_Amount__c);
                else{
                    if(objOpp.Funding_Amount__c!=null)
                    rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                }
                if(rec.Percentage__c != null && rec.Deal_Amount_Used__c != null)
                rec.Amount__c = rec.Deal_Amount_Used__c * (rec.Percentage__c/100);
            }
        }
        
        if(receivableList.size()>0){
            for(Receivable__c rec:receivableList){
                if(rec.Amount__c!=null)
                receivableAmtTotal = receivableAmtTotal + rec.Amount__c;
            }
        }
    }// end of If-getValues = 'populateData'
    
    //Function to get the Payables
    public void getPayables()
    {
        payableAmtTotal =0.00;
        // Query the receivables and display them on the Page
        payableList = getPayablesFromDB(OppId);
        
        // build bridge between Comission engine and MCA App (MCA-739) By Merul
        if(label.ActivateCommissionEngine == 'true')
        {
            List<Payable__C> advComPayableList = new List<Payable__C>();
            if(objOpp.Deal_Entry_Wizard_Check__c == false && checkAdvCommCall == false )
            {
                type t = type.forName(Label.CommissionEngineClassName);
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
            }
        }
        else
        {
            
            //Nachiket 1.1
            if(objOpp.Deal_Entry_Wizard_Check__c == false && accList.size() > 0 && receivableList.size() >0 && receivableList <> null){
                
                CommissionPer = (accList[0].Commission_Percentage__c == null ? 0.00 : accList[0].Commission_Percentage__c);
                
                for (integer i=0; i<receivableList.size();i++)
                {
                    if((receivableList[i].Type__c == 'Commission' && accList[0].Payback_Funded__c == 'Commission Revenue') && receivableList[i].Wizard_Check__c == false && objOpp.Deal_Entry_Wizard_Check__c == false && receivableList[i].IsCreatedFromGrid__c == false)
                    {
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
                    objOpp.Deal_Entry_Wizard_Check__c == false && receivableList[i].IsCreatedFromGrid__c == false){
                       
                        if(payableList.size()>0)
                        {
                            for(Payable__c pay:payableList)
                            {
                                if(pay.Amount_Due__c!=null)
                                payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
                            }
                        }
                        if(payableList.size()<=0 && wizardType != PREVIEW_SCREEN){
                            addRowPayable();
                        }
                        
                        receivableList[i].Wizard_Check__c = true;
                        
                    }
                    
                    else if(receivableList.size() > 0 && (receivableList[i].Type__c <> null && accList[0].Payback_Funded__c == 'All Revenue')
                    && receivableList[i].Wizard_Check__c == false &&
                    objOpp.Deal_Entry_Wizard_Check__c == false && receivableList[i].IsCreatedFromGrid__c == false){
                        
                        payableList.add(new Payable__c(Opportunity__c = OppId,
                        Type__c = receivableList[i].Type__c,
                        Percentage__c = CommissionPer,
                        Payback_Funded__c =accList[0].Payback_Funded__c,
                        Due_Date__c = Date.Today()+7,
                        Amount_Due__c = treateNullAsZero(receivableList[i].Amount__c) * (CommissionPer/100),
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
            
            if(payableList.size()<=0 && wizardType != PREVIEW_SCREEN)
            {
                addRowPayable();
            }
            
            if(payCount == 1 || payWizardCount==1)
            {
                payCount = 2;
                payWizardCount = 2;
            }
            
        }
        
        
        
        //For Grand total of Payables
        if(payableList.size()>0)
        {
            for(Payable__c pay:payableList){
                if(pay.Amount_Due__c!=null)
                payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
            }
        }
        
        
        //To make mark on opportunity to call CE in future
        if(checkAdvCommCall)
        {
            objOpp.Commission_Engine_Check__c = true;
            update objOpp;
            
        }
        
        
    }
    
    //Function to fetch Syndication records
    public void getSyndication(){
        syndAmtTotal=0.00;
        syndFeeTotal=0.00;
        // Query the receivables and display them on the Page
        syndicationList = getSyndicationFromDB(OppId);
        
        if(syndicationList.size()>0)
        {
            for(Syndication__c synd:syndicationList)
            {
                if(synd.Syndication_Amt__c!=null)
                syndAmtTotal = syndAmtTotal + synd.Syndication_Amt__c;
            }
        }
        if(syndicationList.size()<=0 && wizardType != PREVIEW_SCREEN)
        addRowSyndication();
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
    public void addRowOffer(){
        offerWrapperList.add(new offerWrapper(new Offer__c(Opportunity__c = OppId), false));
    }
    
    public void addRowPayable(){
        
        Receivable__c objRec = new Receivable__c();
        
        
        //Amount__c = Percentage__c * (selProgram.Payback_Funded__c ? objOpp.Payback_Amount__c: Funding_Amount__c)
        if(accList != null && accList.size() > 0 && receivableList != null && receivableList.size()>0 && payableList.size()<=0 && objOpp.Deal_Entry_Wizard_Check__c == false
        && (accList[0].Payback_Funded__c == 'Payback'  || accList[0].Payback_Funded__c == 'Funded')){
            for(Receivable__c rec : receivableList){
                if(rec.Type__c == 'Commission')
                objRec = rec;
            }
            payableList.add(new Payable__c( Opportunity__c = OppId,Type__c = 'Commission',
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
    }
    
    public void addRowReceivable()
    {
        
        
        if(selProgram != null && receivableList.size()<=0){
            receivableList.add(new Receivable__c(Opportunity__c = OppId, Due_From_Account__c = objOpp.Bank_Name__c,
            Percentage__c = selProgram.Commission_Percentage__c,//selProgram.Commission_Percentage__c,
            Payback_Funded__c =selProgram.Payback_Funded__c,
            
            Amount__c = (selProgram.Commission_Percentage__c==null ? 0 :(selProgram.Commission_Percentage__c/100)) * (selProgram.Payback_Funded__c!=null && selProgram.Payback_Funded__c=='Payback' ? (objOpp.Payback_Amount__c==null ? 0 : objOpp.Payback_Amount__c):(objOpp.Funding_Amount__c==null ? 0 : objOpp.Funding_Amount__c)),
            Due_Date__c = Date.Today()+7,Type__c = 'Commission',Status__c = 'Pending' ));
        }
        else
        {
            receivableList.add(new Receivable__c(Opportunity__c = OppId, Due_From_Account__c = objOpp.Bank_Name__c ));
        }
    }
    
    
    /*****************Merul*******************/
    
    public void addRowReceivableForOriginationFeeType()
    {
        
        
        
        //Logic for non repeation of origination fee generation in recevialble screen
        Boolean orignRec = false;
        for(Receivable__c recWizard:receivableList){
            if(recWizard.Type__c == 'Origination fee'){
                orignRec = true;
            }
        }
        
        if(!orignRec && wizardType != PREVIEW_SCREEN && !string.isblank(selOfferId) && objOpp.Account.id!= null && objOpp.Origination_fee__c != null && objOpp.Origination_fee__c != 0 /*&&
        orgFeeOfSelectedOffID != NULL*/)
        {
            
            receivableList.add(new Receivable__c(Opportunity__c = OppId,
            // Due_From_Account__c = objOpp.Account.id,
            Due_From_Account__c = objOpp.Account.id,
            Type__c = 'Origination Fee',
            //Amount__c = orgFeeOfSelectedOffID
            Amount__c = objOpp.Origination_fee__c
            ));
            
            
        }
        
    }
    
    /*****************Merul*******************/
    public void addRowSyndication(){
        syndicationList.add(new Syndication__c(Opportunity__c = OppId));
    }
    public void quickSaveOffer(){
        try{
            list<Offer__c> Offerlst = new list<Offer__c>();
            List<OfferWrapper> listTempOfferwrap = new List<OfferWrapper>();
            for(OfferWrapper wrapper :  offerWrapperList)
            {
                
                Offerlst.add(wrapper.offer);
                
            }
            
            Offerlst = checkSaveAccessForSObject(Offerlst,UserInfo.getUserId());
            
            if(Offerlst.size() > 0)
            {
                this.upsertForSObject(Offerlst);
            }
            
            this.getOffers();
            
            
        }catch(Exception e){
            /*if(e.getMessage().contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY'))
            {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Insufficient privilege to save this record '));
            }
            else
            {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
            }*/
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            
            
            wizardType = OFFER_SCREEN;
            //currState = prevState;
        }
    }
    
    
    public void quickSavePayable()
    {
        try{
            list<Payable__c> lstPayableToUpsert = new list<Payable__c> ();
            list<Payable__c> lstPayableToDisplay = new list<Payable__c> ();
            list<Payable__c> lstPayablesWithNullValueToDelete = new list<Payable__c> ();
            if(payableList.size() > 0 )
            {
                for(Integer i=0; i<payableList.size(); i++)
                {
                    if(!payablesFieldsNullValidator(payableList[i]))
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
            lstPayableToUpsert = checkSaveAccessForSObject(lstPayableToUpsert,UserInfo.getUserId());
            this.upsertForSObject(lstPayableToUpsert);
            delete lstPayablesWithNullValueToDelete;
            payableList = lstPayableToDisplay;
            
            payableAmtTotal = 0.0;
            if(payableList.size()>0)
            {
                for(Payable__c pay:payableList){
                    if(pay.Amount_Due__c!=null)
                    payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
                }
            }
            
            
            //Refreshing opportunity from DB.
            objOpp = refereshOpportunityByID(OppId);
            
            //added to prevent adv commision call once payables are generated from CE.
            /* if(checkAdvCommCall)
            {
            objOpp.Commission_Engine_Check__c = true;
            update objOpp;
            
            }*/
            
            
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
            wizardType = PAYABLE_SCREEN;
            //currState = prevState;
        }
    }
    
    public void quickSaveReceivable()
    {
        try{
            list<Receivable__c> lstReceivableToUpsert = new list<Receivable__c> ();
            list<Receivable__c> lstReceivableToDisplay = new list<Receivable__c> ();
            list<Receivable__c> lstReceivableWithNullValueToDelete = new list<Receivable__c> ();
            if(receivableList.size() > 0 )
            {
                for(Integer i=0; i<receivableList.size(); i++)
                {
                    if(!receivablesFieldsNullValidator(receivableList[i]))
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
            lstReceivableToUpsert = checkSaveAccessForSObject(lstReceivableToUpsert,UserInfo.getUserId());
            this.upsertForSObject(lstReceivableToUpsert);
            delete lstReceivableWithNullValueToDelete;
            
            //Refreshing opportunity from DB.
            objOpp = refereshOpportunityByID(OppId);
            
            receivableList = lstReceivableToDisplay;
            receivableAmtTotal = 0.0;
            if(receivableList.size()>0)
            {
                for(Receivable__c rec:receivableList)
                {
                    if(rec.Amount__c!=null)
                    receivableAmtTotal = receivableAmtTotal + rec.Amount__c;
                }
            }
            
        }
        catch(DmlException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            wizardType = RECEIVABLE_SCREEN;
            
        }
    }
    
    
    
    public void quickSaveSyndication()
    {
        
        list<Syndication__c> lstSyndicationToUpsert = new list<Syndication__c> ();
        list<Syndication__c> lstSyndicationToDisplay = new list<Syndication__c> ();
        list<Syndication__c> lstSyndicationWithNullValueToDelete = new list<Syndication__c> ();
        try
        {
            if(syndicationList.size() > 0)
            {
                for(Integer i=0; i<syndicationList.size(); i++)
                {
                    if(!syndicationFieldsNullValidator(syndicationList[i]))
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
            lstSyndicationToUpsert = checkSaveAccessForSObject(lstSyndicationToUpsert,UserInfo.getUserId());
            this.upsertForSObject(lstSyndicationToUpsert);
            delete lstSyndicationWithNullValueToDelete;
            //this.getSyndication();
            syndicationList = lstSyndicationToDisplay;
            syndAmtTotal = 0.0;
            if(syndicationList.size()>0)
            {
                for(Syndication__c synd:syndicationList)
                {
                    if(synd.Syndication_Amt__c!=null)
                    syndAmtTotal = syndAmtTotal + synd.Syndication_Amt__c;
                }
            }
        }
        catch(Exception e){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            //currState = prevState;
        }
    }
    // Delete offer
    
    public void deleteOffer(){
        try
        {
            string delname = ApexPages.CurrentPage().getParameters().get('delname');
            Integer rowNum = Integer.valueOf(ApexPages.currentPage().getParameters().get('index'));
            Id offerId;
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
                    if(checkUserAccessForSobject(offIdSet,UserInfo.getUserId())[0].HasDeleteAccess)
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
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
        }
    }
    
    
    //remove payables on click of Delete link
    
    public void deletPayables(){
        list<SObject> payableDelList = new list<SObject>();
        list<UserRecordAccess> UserRecordAccessListNullChk = new list<UserRecordAccess>();
        
        try
        {
            rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
            payableDelList = deleteForSObject(payableList,rowNum);
            
            if(payableDelList.size()>0){
                delete payableDelList;
            }
            
            
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
        }
    }
    
    //remove receivables on click of Delete link
    public void deletReceivables(){
        list<Receivable__c> receivableDelList = new list<Receivable__c>();
        list<UserRecordAccess> UserRecordAccessListNullChk = new list<UserRecordAccess>();
        
        try
        {
            rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'))+1;
            receivableDelList = deleteForSObject(receivableList,rowNum);
            if(receivableDelList.size()>0)
            {
                delete receivableDelList;
            }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            
        }
    }
    
    //remove syndications on click of Delete link
    public void deletSyndications()
    {
        
        list<Syndication__c> syndicationdelList = new list<Syndication__c>();
        try
        {
            rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
            syndicationdelList = deleteForSObject(syndicationList,rowNum);
            
            if(syndicationdelList.size()>0){
                delete syndicationdelList;
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
            
        }
    }
    
    public void onChangeBankProgram(){
        if(objOpp.Bank_Program__c <> null){
            selProgram = [select Id, Name,Payback_Funded__c,Commission_Percentage__c,Renewal_Eligibility__c from Program__c where Id =:objOpp.Bank_Program__c];
            
            objOpp.Renewal_Eligibility_Percent__c = selProgram.Renewal_Eligibility__c;
            if( selProgram.Renewal_Eligibility__c != null && objOpp.Term_Months__c != null){
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
    
    public void onChangeType(){
        /*************Merul*************************/
        this.onChangeAmountCalculation(receivableList,payableList);
        /*************Merul*************************/
    }
    
    public void onChangeRecPaybackFunded()
    {
        String recevableid = System.currentPagereference().getParameters().get('recId');
        receivableAmtTotal = 0.00;
        for(Receivable__c rec : receivableList)
        {
            
            if(rec.Id == null)
            {
                if(rec.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                else if(rec.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                else if(rec.Payback_Funded__c == 'Net Funded Amount')
                rec.Deal_Amount_Used__c = treateNullAsZero(objOpp.Funding_Amount__c) - treateNullAsZero(objOpp.Payoff_Amount__c);
                if(rec.Percentage__c != null && rec.Deal_Amount_Used__c != null)
                rec.Amount__c = rec.Deal_Amount_Used__c * (rec.Percentage__c/100);
            }
            else if(rec.Id != null && recevableid != '' && rec.Id == recevableid ){
                
                if(rec.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                else if(rec.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                else if(rec.Payback_Funded__c == 'Net Funded Amount')
                rec.Deal_Amount_Used__c = treateNullAsZero(objOpp.Funding_Amount__c) - treateNullAsZero(objOpp.Payoff_Amount__c);
                else
                {
                    if(objOpp.Payback_Amount__c != null)
                    rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                }
                
                if(rec.Percentage__c != null)
                rec.Amount__c = rec.Deal_Amount_Used__c * (rec.Percentage__c/100);
            }
        }
        
        if(receivableList.size()>0)
        {
            for(Receivable__c rec:receivableList){
                if(rec.Amount__c!=null)
                receivableAmtTotal = receivableAmtTotal + rec.Amount__c;
            }
        }
        
        
    }
    
    public void onChangePayPaybackFunded()
    {
        String payableid = System.currentPagereference().getParameters().get('payId');
        decimal receivableAmountCommission = 0.00;
        decimal receivableAmountAllRevenue = 0.00;
        
        for(Receivable__c rec:receivableList){
            if(rec.Amount__c <> null && rec.Type__c == 'Commission'){
                receivableAmountCommission += rec.Amount__c;
            }
            if(rec.Amount__c <> null && rec.Type__c <> null){
                receivableAmountAllRevenue += rec.Amount__c;
            }
            
        }
        //Nachiket 1.3
        for(Payable__c pay : payableList)
        {
            if(pay.Id == null && pay.Wizard_Check__c == false)
            {
                if(pay.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                else if(pay.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                pay.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                else if(pay.Payback_Funded__c == 'Net Funded Amount')
                pay.Deal_Amount_Used__c = treateNullAsZero(objOpp.Funding_Amount__c) - treateNullAsZero(objOpp.Payoff_Amount__c);
                else if(pay.Payback_Funded__c == 'Net Commission Revenue')
                {
                    pay.Deal_Amount_Used__c = calculateNetCommissionRevenue(objOpp);
                    
                }
                else if(pay.Payback_Funded__c == 'Net Origination Fee')
                {
                    pay.Deal_Amount_Used__c = calculateNetOriginationFees(objOpp);
                    
                }
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null){
                    pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                }
                
            }
            else if(pay.Id != null && payableid != '' && pay.Id == payableid && pay.Wizard_Check__c == false)
            {
                
                if(pay.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                else if(pay.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                pay.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                else if(pay.Payback_Funded__c == 'Net Funded Amount')
                pay.Deal_Amount_Used__c = treateNullAsZero(objOpp.Funding_Amount__c) - treateNullAsZero(objOpp.Payoff_Amount__c);
                else if(pay.Payback_Funded__c == 'Net Commission Revenue')
                {
                    pay.Deal_Amount_Used__c = calculateNetCommissionRevenue(objOpp);
                    
                }
                else if(pay.Payback_Funded__c == 'Net Origination Fee')
                {
                    
                    pay.Deal_Amount_Used__c = calculateNetOriginationFees(objOpp);
                    
                }
                
                else
                {
                    if(objOpp.Payback_Amount__c != null)
                    pay.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                }
                
                if(pay.Percentage__c != null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }
            
            
            //Nachiket 1.3
            if(pay.Id == null && pay.Wizard_Check__c == false)
            {
                if(pay.Payback_Funded__c == 'Commission Revenue' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = receivableAmountCommission;
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null){
                    pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                }
            }
            
            else if(pay.Id != null && payableid != '' && pay.Id == payableid && pay.Wizard_Check__c == false){
                
                if(pay.Payback_Funded__c == 'Commission Revenue' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = receivableAmountCommission;
                
                if(pay.Percentage__c != null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }
            
            if(pay.Id == null && pay.Wizard_Check__c == false)
            {
                if(pay.Payback_Funded__c == 'All Revenue' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = receivableAmountAllRevenue;
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null){
                    pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                }
                
            }
            
            else if(pay.Id != null && payableid != '' && pay.Id == payableid && pay.Wizard_Check__c == false){
                if(pay.Payback_Funded__c == 'All Revenue' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = receivableAmountAllRevenue;
                
                if(pay.Percentage__c != null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }
            ////Nachiket 1.3 End
            
            /*************Merul*************************/
            this.onChangeAmountCalculation(receivableList,payableList);
            /*************Merul*************************/
            
        }
        payableAmtTotal =0.00;
        if(payableList.size()>0){
            for(Payable__c pay:payableList){
                if(pay.Amount_Due__c!=null)
                payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
            }
        }
        
    }
    
    public Decimal calculateNetCommissionRevenue(Opportunity oppObj) {
        decimal val = 0.00;
        if(mapStringToObjectFields.get(System.Label.MCAFieldTotal_Commissions_Receivable) !=Null  && mapStringToObjectFields.get(System.Label.MCACEField_Commissions_Payable_External) != Null)
        {
            
            
            String queryStr = 'Select '+System.Label.MCAFieldTotal_Commissions_Receivable+','+System.Label.MCACEField_Commissions_Payable_External+' From Opportunity Where id = \'' +oppObj.Id+'\'';
            List<Opportunity> tempOpp = database.Query(queryStr);
            if(tempOpp != null && tempOpp.size()>0)
            {
                oppObj.put(System.Label.MCAFieldTotal_Commissions_Receivable,tempOpp[0].get(System.Label.MCAFieldTotal_Commissions_Receivable));
                oppObj.put(System.Label.MCACEField_Commissions_Payable_External,tempOpp[0].get(System.Label.MCACEField_Commissions_Payable_External));
                
                val = treateNullAsZero((Decimal)(oppObj.get(System.Label.MCAFieldTotal_Commissions_Receivable))) - treateNullAsZero((Decimal)(oppObj.get(System.Label.MCACEField_Commissions_Payable_External)));
            }
        }
        else
            val = 0.00;
        return val;
    }
    
    public Decimal calculateNetOriginationFees(Opportunity oppObj)
    {
        decimal val = 0.00;
        if(mapStringToObjectFields.get(System.Label.MCAField_Total_Origination_Fees_Receivable) !=Null  && mapStringToObjectFields.get(System.Label.MCACEField_Origination_Fees_Payable_External) != Null)
        {
            String queryStr = 'Select '+System.Label.MCAField_Total_Origination_Fees_Receivable+','+System.Label.MCACEField_Origination_Fees_Payable_External+' From Opportunity Where id = \'' +oppObj.Id+'\'';
            List<Opportunity> tempOpp = database.Query(queryStr);
            if(tempOpp != Null && tempOpp.size() >0)
            {
                oppObj.put(System.Label.MCAField_Total_Origination_Fees_Receivable,tempOpp[0].get(System.Label.MCAField_Total_Origination_Fees_Receivable));
                oppObj.put(System.Label.MCACEField_Origination_Fees_Payable_External,tempOpp[0].get(System.Label.MCACEField_Origination_Fees_Payable_External));
                
                val = treateNullAsZero((Decimal)(oppObj.get(System.Label.MCAField_Total_Origination_Fees_Receivable))) - treateNullAsZero((Decimal)(oppObj.get(System.Label.MCACEField_Origination_Fees_Payable_External)));
            }
        }
        else
            val = 0.00;
        return val;
    }
    
    public void onChangeRecPercentage()
    {
        String recevableid = System.currentPagereference().getParameters().get('recId');
        receivableAmtTotal = 0.00;
        for(Receivable__c rec : receivableList){
            if(rec.Id != null && recevableid != '' && rec.Id == recevableid){
                if(rec.Deal_Amount_Used__c != null && rec.Percentage__c != null)
                rec.Amount__c = rec.Deal_Amount_Used__c * (rec.Percentage__c/100);
            }
            if(rec.Id == null)
            {
                if(rec.Deal_Amount_Used__c != null && rec.Percentage__c != null)
                rec.Amount__c = rec.Deal_Amount_Used__c * (rec.Percentage__c/100);
            }
            
        }
        
        if(receivableList.size()>0)
        {
            for(Receivable__c rec:receivableList)
            {
                if(rec.Amount__c!=null)
                receivableAmtTotal = receivableAmtTotal + rec.Amount__c;
            }
        }
        
    }
    
    
    public void onChangeAmountCalculation(List<receivable__c> receivableList,List<payable__c> payableList)
    {
        decimal receivableOrgFee =0.00;
        for(Receivable__c rec:receivableList)
        {
            
            if(rec.Amount__c <> null && rec.Type__c == 'Origination Fee')
            {
                receivableOrgFee += rec.Amount__c;
            }
            
        }
        
        for(Payable__c pay : payableList)
        {
            if(pay.Payback_Funded__c!=null /*&& pay.Type__c!= null*/ && pay.Percentage__c!=null)
            {
                if(/*pay.Id == null &&*/ pay.Wizard_Check__c == false && pay.Payback_Funded__c == 'Origination Fee' /*&& pay.Type__c== 'Origination Fee'*/)
                {
                    pay.Amount_Due__c = receivableOrgFee * (pay.Percentage__c/100);
                }
            }
        }
        
    }
    
    
    
    public void onChangePayPercentage()
    {
        String payableid = System.currentPagereference().getParameters().get('payId');
        //Nachiket 1.3
        decimal receivableAmountCommission = 0.00;
        decimal receivableAmountAllRevenue = 0.00;
        decimal receivableOrgFee =0.00;
        
        
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
        //Nachiket 1.3
        
        for(Payable__c pay : payableList)
        {
            
            if(pay.Id != null && payableid != '' && pay.Id == payableid && pay.Wizard_Check__c == false)
            {
                if(pay.Deal_Amount_Used__c != null && pay.Percentage__c != null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }
            if(pay.Id == null && pay.Wizard_Check__c == false)
            {
                if(pay.Deal_Amount_Used__c != null && pay.Percentage__c != null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }
            
            
            //For Funded
            if(pay.Id == null && pay.Wizard_Check__c == false)
            {
                
                
                
                if(pay.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                
            }
            else if(pay.Id != null && payableid != '' &&    pay.Id == payableid && pay.Wizard_Check__c == false)
            {
                
                if(pay.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }
            
            
            //For Payback
            if(pay.Id == null && pay.Wizard_Check__c == false)
            {
                if(pay.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                pay.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                
            }
            else if(pay.Id != null && payableid != '' &&    pay.Id == payableid && pay.Wizard_Check__c == false)
            {
                
                if(pay.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                pay.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }
            
            
            
            //For Net Funded Amount
            if(pay.Id == null && pay.Wizard_Check__c == false)
            {
                if(pay.Payback_Funded__c == 'Net Funded Amount')
                pay.Deal_Amount_Used__c = treateNullAsZero(objOpp.Funding_Amount__c) - treateNullAsZero(objOpp.Payoff_Amount__c);
                
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                
            }
            else if(pay.Id != null && payableid != '' &&    pay.Id == payableid && pay.Wizard_Check__c == false)
            {
                
                if(pay.Payback_Funded__c == 'Net Funded Amount')
                pay.Deal_Amount_Used__c = treateNullAsZero(objOpp.Funding_Amount__c) - treateNullAsZero(objOpp.Payoff_Amount__c);
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }
            
            
            
            //For Net Commission Revenue
            if(pay.Id == null && pay.Wizard_Check__c == false)
            {
                if(pay.Payback_Funded__c == 'Net Commission Revenue')
                pay.Deal_Amount_Used__c =  calculateNetCommissionRevenue(objOpp);
                
                
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                
            }
            else if(pay.Id != null && payableid != '' &&    pay.Id == payableid && pay.Wizard_Check__c == false)
            {
                
                if(pay.Payback_Funded__c == 'Net Commission Revenue')
                pay.Deal_Amount_Used__c =  calculateNetCommissionRevenue(objOpp);
                
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }
            
            
            
            //For Net Origination Fee
            if(pay.Id == null && pay.Wizard_Check__c == false)
            {
                if(pay.Payback_Funded__c == 'Net Origination Fee')
                pay.Deal_Amount_Used__c =  calculateNetOriginationFees(objOpp);
                
                
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                
            }
            else if(pay.Id != null && payableid != '' &&    pay.Id == payableid && pay.Wizard_Check__c == false)
            {
                
                if(pay.Payback_Funded__c == 'Net Origination Fee')
                pay.Deal_Amount_Used__c =  calculateNetOriginationFees(objOpp);
                
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }
            
            
            //Nachiket 1.3
            //For Commision Revenue
            if(pay.Id == null && pay.Wizard_Check__c == false)
            {
                if(pay.Payback_Funded__c == 'Commission Revenue' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = receivableAmountCommission;
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                
            }
            else if(pay.Id != null && payableid != '' &&    pay.Id == payableid && pay.Wizard_Check__c == false)
            {
                
                if(pay.Payback_Funded__c == 'Commission Revenue' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = receivableAmountCommission;
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }
            
            
            //All revenue
            if(pay.Id == null && pay.Wizard_Check__c == false)
            {
                if(pay.Payback_Funded__c == 'All Revenue' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = receivableAmountAllRevenue;
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                
            }
            
            else if(pay.Id != null && payableid != '' && pay.Id == payableid && pay.Wizard_Check__c == false)
            {
                
                if(pay.Payback_Funded__c == 'All Revenue' && objOpp.Funding_Amount__c != null)
                pay.Deal_Amount_Used__c = receivableAmountAllRevenue;
                
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null)
                pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }
            ////Nachiket 1.3 End
            
            
            
            /*************Merul*************************/
            this.onChangeAmountCalculation(receivableList,payableList);
            /*************Merul*************************/
        }
        
        payableAmtTotal =0.00;
        if(payableList.size()>0)
        {
            for(Payable__c pay:payableList)
            {
                if(pay.Amount_Due__c!=null)
                payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
            }
        }
        
        
    }
    
    public void save()
    {
        try
        {
            
            list<Opportunity> oppList1 = new  list<Opportunity>();
            objOpp.AccountId = AccountId;
            oppList1.add(objOpp);
            
            oppList1 = checkSaveAccessForSObject(oppList1,userinfo.getUserId());
            if(oppList1.size() > 0 )
            {
                this.upsertForSObject(oppList1);
                
                //Refreshing opportunity from DB.
                objOpp = refereshOpportunityByID(OppId);
                
            }
            
            
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            wizardType = DEAL_SCREEN;
        }
        
        
    }
    
    public PageReference cancel()
    {
        objopp.Deal_Entry_Wizard_Check__c = true;
        /* if(checkAdvCommCall)
        {
        objOpp.Commission_Engine_Check__c = true;
        
        } */
        
        // getReceivables();
        try
        {
            upsert objopp;
        }
        catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            
        }
        //quickSaveReceivable();
        return new PageReference('/'+OppId);
    }
    
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
    
    
    //Commented the code because the functionality of MCA-841 is depricated
    public void saveOnTabChange (String pState)
    {
        /*
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
        quickSaveOffer();
        }
        */
    }
    
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
        if(wizardType == PREVIEW_SCREEN){
            getPayables();
            getReceivables();
            getSyndication();
        }
        if(wizardType == RECEIVABLE_SCREEN)
        {
            ++recWizardCount;
            receivableList = getReceivablesFromDB(OppId);
            //getReceivables();
            
        }
        if(wizardType == PAYABLE_SCREEN)
        {
            ++payWizardCount;
            payableList = getPayablesFromDB(OppId);
            //getPayables();
        }
        if(wizardType == SYNDICATION_SCREEN)
        {
            syndicationList =  getSyndicationFromDB(OppId);
            // getSyndication();
        }
        
        
    }
    
    
    public list<sObject> checkSaveAccessForSObject(List<sObject> SObjectList, Id userId )
    {
        map<Id,sObject> currentSObjectMap = new map<Id,sObject>();
        list<sObject> finalSObjectList = new list<sObject>();
        list<UserRecordAccess> listUserRecordAccess = new list<UserRecordAccess>();
        
        for(sObject obj : SObjectList)
        {
            if(obj.get('Id') != NULL)
            {
                currentSObjectMap.put((ID)obj.get('Id'),obj);
            }
            else
            {
                finalSObjectList.add(obj);
            }
        }
        
        if(currentSObjectMap != NULL && currentSObjectMap.size() > 0)
        {
            listUserRecordAccess = checkUserAccessForSobject(currentSObjectMap.keySet(),userId);
            for(UserRecordAccess objUserAccess : listUserRecordAccess)
            {
                if(objUserAccess.HasReadAccess && objUserAccess.HasEditAccess )
                finalSObjectList.add(currentSObjectMap.get(objUserAccess.RecordId));
            }
        }
        return finalSObjectList;
    }
    
    
    
    //For checking user's CRUDVM access of SObject
    public list<UserRecordAccess> checkUserAccessForSobject(Set<ID> IdSet, Id userId )
    {
        list<UserRecordAccess> listUserRecordAccess = new list<UserRecordAccess>();
        listUserRecordAccess = [SELECT RecordId,
        HasReadAccess,
        HasEditAccess,
        HasDeleteAccess
        FROM   UserRecordAccess
        WHERE UserId =: userId AND
        RecordId IN : IdSet];
        return listUserRecordAccess;
    }//End checkUserAccessSobject
    
    
    //For checking payables fields null value
    public Boolean payablesFieldsNullValidator(Payable__c objPayable){
        if(objPayable.Type__c == null && objPayable.Amount_Due__c == null &&
        objPayable.Percentage__c == null &&
        objPayable.Payback_Funded__c == null &&
        objPayable.Account__c == null && objPayable.Due_Date__c == null &&
        objPayable.Status__c == null && objPayable.Memo__c == null &&
        objPayable.Receivable_Dependency__c == null ){
            return true;
        }
        return false;
    }
    
    //For checking receivales fields null value
    public Boolean receivablesFieldsNullValidator(Receivable__c objReceivable){
        if(objReceivable.Type__c == null && objReceivable.Amount__c == null &&
        objReceivable.Percentage__c == null &&
        objReceivable.Payback_Funded__c == null &&
        objReceivable.Deal_Amount_Used__c == null &&
        objReceivable.Due_Date__c == null &&
        objReceivable.Status__c == null && objReceivable.Memo__c == null )
        {
            return true;
        }
        return false;
    }
    
    //For checking Syndication fields null value
    public Boolean syndicationFieldsNullValidator(Syndication__c objSyndication)
    {
        if(objSyndication.Syndication_Amt__c == null &&
        
        objSyndication.Commission_Fee__c == null &&
        objSyndication.Deal_Funding_Amount__c == null &&
        objSyndication.Servicing_Bank__c == null &&
        objSyndication.Syndication_Percentage__c == null &&
        objSyndication.Profit_Amount__c == null &&
        objSyndication.Anticipated_Term_Months__c == null &&
        objSyndication.Disbursment_Schedule__c == null &&
        objSyndication.ROR_per__c == null &&
        objSyndication.Syndicated_By__c == null && objSyndication.Memo__c == null)
        {
            return true;
        }
        return false;
    }
    
    public void upsertForSObject(list<SObject> sobjectList)
    {
        list<Sobject > lstSobjectToInsert = new list<Sobject >();
        list<Sobject > lstSobjectToUpdate = new list<Sobject >();
        
        for(Sobject sObj:sobjectList )
        {
            if(sObj.id == null)
            {
                lstSobjectToInsert.add(sObj);
            }
            else
            {
                lstSobjectToUpdate.add(sObj);
            }
        }
        
        try
        {
            if(!lstSobjectToInsert.isEmpty())
            insert lstSobjectToInsert;
            
            if(!lstSobjectToUpdate.isEmpty())
            update lstSobjectToUpdate;
            
        }
        Catch(SObjectException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
        }
        
    }
    
    public list<SObject> deleteForSObject(list<SObject> SObjectList,Integer rowNum){
        list<SObject> sObjectDelList = new list<SObject>();
        list<UserRecordAccess> UserRecordAccessListNullChk = new list<UserRecordAccess>();
        set<Id> sObjectIdSet = new set<Id>();
        Boolean hasDeleteAccess;
        //rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        
        if( rowNum != null  && SObjectList.size() >=  (rowNum-1))
        {
            if(SObjectList[rowNum-1].Id == null)
            {
                SObjectList.remove(rowNum-1);
            }
            else
            {
                sObjectIdSet.add(SObjectList[rowNum-1].Id);
                // user delete permission from user accress tab
                UserRecordAccessListNullChk = checkUserAccessForSobject(sObjectIdSet,UserInfo.getUserId());
                if(UserRecordAccessListNullChk.size() > 0)
                hasDeleteAccess = UserRecordAccessListNullChk[0].HasDeleteAccess;
                if(hasDeleteAccess)
                {
                    sObjectDelList.add(SObjectList[rowNum-1]);
                    SObjectList.remove(rowNum-1);
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Insufficient privilege to delete this record'));
                }
            }
        }
        return sObjectDelList;
        
    }
    
    public string getbaseUrlOrg(){
        return MCAStringConstant.baseUrlOrg;
    }
    public list<Payable__c> getPayablesFromDB(Id oppId)
    {
        list<Payable__c> payableListFromDB = [Select Name,
        Memo__c,
        Type__c,
        Status__c,
        Due_Date__c,
        Amount_Due__c,
        Opportunity__c,
        Payback_Funded__c,
        Deal_Amount_Used__c,
        Account__c,
        Account__r.type,
        Payee_Type__c,
        Percentage__c,
        Receivable_Dependency__c,
        Wizard_Check__c,
        IsCreatedFromGrid__c
        from Payable__c where Opportunity__c =: oppId];
        return payableListFromDB;
        
    }
    public list<Receivable__c> getReceivablesFromDB(Id oppId)
    {
        list<Receivable__c> receivablesListFromDB = [Select Name,
        Memo__c,
        Type__c,
        Status__c,
        Amount__c,
        Due_Date__c,
        Percentage__c,
        Payback_Funded__c,
        Deal_Amount_Used__c,
        Opportunity__c,
        Opportunity__r.Commission_Percentage__c,
        Due_From_Account__c,
        Due_From_Account__r.Commission_Percentage__c,
        Wizard_Check__c,
        Amount_Due__c,
        IsCreatedFromGrid__c
        from Receivable__c where Opportunity__c =: oppId];
        return receivablesListFromDB;
        
    }
    public list<Syndication__c> getSyndicationFromDB(Id oppId)
    {
        list<Syndication__c> syndicationListFromDB = [Select Name,
        Commission_Fee__c,
        ROR_per__c,
        Disbursment_Schedule__c,
        Servicing_Bank__c,
        Opportunity__c,
        Anticipated_Term_Months__c,
        Syndication_Amt__c,
        Deal_Funding_Amount__c,
        Syndication_Percentage__c,
        Profit_Amount__c,
        Syndicated_By__c,
        Repayment_Amt__c,
        Memo__c
        from Syndication__c where Opportunity__c =: OppId ];
        return syndicationListFromDB;
        
    }
    
    
    
    
    public list<Opportunity> getOpportunityFromDB(Id oppId)
    {
        return [Select Name,Account.Name,
        Bank_Name__c,
        StageName,
        Funding_Amount__c,
        Payback_Amount__c,
        Bank_Program__c,
        Term_Months__c,
        Total_Commissions_Receivable__c,
        Total_Origination_Fees_Receivable__c,
        Factor_Rate__c,
        Deal_Type__c,
        Deal_Entry_Wizard_Check__c,
        Holdback_Percentage__c,
        Payment_Amount__c,
        Schedule__c,
        OwnerId ,
        Contract_Requested_Date__c,
        Date_Funded__c,
        Date_Contract_Signed__c,
        Estimated_Renewal_Date__c,
        Funded_Notes__c,
        Total_Syndication_Amount__c,
        Renewal_Eligibility_Percent__c,
        Renewal_Eligibility_Days_from_funding__c ,
        Commission_Engine_Check__c,
        Account.Commission_Percentage__c,
        Buy_Rate__c,
        Net_Funded_Amount__c,
        Payoff_Amount__c,
        Origination_Fee__c
        FROM Opportunity
        WHERE Id =: OppId];
        
        
    }
    
    
    
    
    public Opportunity refereshOpportunityByID(Id OppId)
    {
        List<Opportunity> opportunityTempList = getOpportunityFromDB(OppId);
        if(opportunityTempList != null && opportunityTempList .size() > 0 )
        {
            return opportunityTempList[0];
        }
        
        return null;
    }
    
    
    public decimal treateNullAsZero(Decimal pValue)
    {
        return (pValue == null) ?  0.00 : pValue  ;
    }
}