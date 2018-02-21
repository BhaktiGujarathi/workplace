/*
 *   Description - Controller for CreateContract Page.
 * 
 *   Date        - 31/03/2014
 *
 *   Created by  - Sneha P.
 */
public with sharing class CreateContractController {
    
    // Properties
    public String OppId                                   {get; set;}
    public String AccountId                               {get;set;}
    public list<OfferWrapper> offerWrapperList            {get; set;}
    public Contract objContract                           {get;set;}
    public Opportunity objOpp                             {get;set;}
    public Offer__c selectedOffer                         {get; set;}
    public boolean isOfferSelected                        {get; set;}
    public list<Receivable__c> receivableList             {get; set;}
    public list<Payable__c> payableList                   {get; set;}
    public Receivable__c receivable                       {get; set;}
    public Payable__c payable                             {get; set;}
    public list<Syndication__c> syndicationList           {get; set;}
    public Syndication__c syndication                     {get; set;}
    public Decimal payableAmtTotal                        {get;set;}
    public Decimal receivableAmtTotal                     {get;set;}
    public Decimal syndAmtTotal                           {get;set;}
    public Decimal syndFeeTotal                           {get;set;}
    public String selOfferid                              {get;set;} 
    public String submission                              {get; set;}
    //Private variables
    private map<Id, Offer__c> offerMap;
    private String ContractName;
    private String Stage;
    public Submission__c selSubmission;
    public Program__c selProgram;
    //private String selOfferid ;
    public string prevOfferid;
    public string wizardType                              {get;set;}
    public Integer rowNum{get;set;}
    public Static Final String OFFER_SCREEN ='Offer';
    public Static Final String DEAL_SCREEN ='Deal';     
    public Static Final String RECEIVABLE_SCREEN ='Receivable'; 
    public Static Final String PAYABLE_SCREEN ='Payable';
    public Static Final String SYNDICATION_SCREEN ='Syndication';
    public Static Final String PREVIEW_SCREEN ='Preview';
    
    public CreateContractController(){
        OppId = ApexPages.currentPage().getParameters().get('Id');
        Stage = ApexPages.currentPage().getParameters().get('stage');
        AccountId = ApexPages.currentPage().getParameters().get('accId');
        ContractName = ApexPages.currentPage().getParameters().get('name');
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
        //wizardType = OFFER_SCREEN;
    } 
    
    //Function Called on init to populate all the data in the Tables
    public void populateData(){
        
        objOpp = [Select Name,Bank_Name__c,StageName,
                         Funding_Amount__c,
                         Payback_Amount__c,
                         Bank_Program__c,
                         Term_Months__c,
                         Factor_Rate__c,
                         Deal_Type__c,
                         Deal_Entry_Wizard_Check__c,
                         Holdback_Percentage__c,
                         Payment_Amount__c,
                         Schedule__c,
                         OwnerId ,
                         Contract_Requested_Date__c,
                         Date_Funded__c,
                         Date_Contract_Signed__c
                  from Opportunity where Id =: OppId];
        
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
            
        //objOpp.Date_Contract_Signed__c = system.today();
        
        if(objOpp.Payment_Amount__c != null && objOpp.Funding_Amount__c != null)
            objOpp.Factor_Rate__c = objOpp.Payment_Amount__c / objOpp.Funding_Amount__c;
            
         /* if(selectedOffer.Payment_Amt__c != null && selectedOffer.Amount__c!= null)
            objOpp.Factor_Rate__c = selectedOffer.Payment_Amt__c / selectedOffer.Amount__c;*/
                  
        if(objOpp.Deal_Entry_Wizard_Check__c){
            wizardType = DEAL_SCREEN;
            isOfferSelected = true;
        }
        else
            wizardType = OFFER_SCREEN;
        
        this.getOffers();
        this.getPayables();
        this.getReceivables();
        this.getSyndication();
    }
    
    public void selectedOffer(){
        selOfferid = System.currentPagereference().getParameters().get('offerId');  
        
        if(selOfferid != ''){
            isOfferSelected = true;
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please save the records to continue'));        
            return;
        }
        //Save the offer when the Page changes
        this.quickSaveOffer();
        
        wizardType = DEAL_SCREEN;
        //get the offer that is selected and on that basis render the values
        if(!offerMap.isEmpty() && offerMap.containsKey(selOfferid)) {
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
            selSubmission = [select Id, Name, Program__c from Submission__c where Id =: selectedOffer.Submission__c];
            objOpp.Bank_Program__c = selSubmission.Program__c;
            selProgram = [select Id, Name,Payback_Funded__c,Commission_Percentage__c from Program__c where Id =:selSubmission.Program__c];
            if(selectedOffer.Payback_Amt__c != null && selectedOffer.Amount__c!= null)
                objOpp.Factor_Rate__c = selectedOffer.Payback_Amt__c / selectedOffer.Amount__c;
                
        }
    }
    
    //Function called on click of Next button, it will rdirect to next Screen
    public void next(){
        if(wizardType == OFFER_SCREEN)
            wizardType = DEAL_SCREEN;
        else if(wizardType == DEAL_SCREEN){
            wizardType = RECEIVABLE_SCREEN;
            this.save();
            getReceivables();
        }   
        else if(wizardType == RECEIVABLE_SCREEN){
            wizardType = PAYABLE_SCREEN;    
            //upsert receivableList;
            this.quickSaveReceivable();
            getPayables();
        }
        else if(wizardType == PAYABLE_SCREEN){
            wizardType = SYNDICATION_SCREEN;    
            //upsert payableList;
            this.quickSavePayable();
        }
        else if(wizardType == SYNDICATION_SCREEN){
            wizardType = PREVIEW_SCREEN;    
            //upsert syndicationList;
            this.quickSaveSyndication();
        }
    }
    
    //Function called on click of Previous button, it will redirect to previous Screen
    public void previous(){
        if(wizardType == PREVIEW_SCREEN)
            wizardType = SYNDICATION_SCREEN;
        else if(wizardType == SYNDICATION_SCREEN){
            wizardType = PAYABLE_SCREEN;
            this.quickSaveSyndication();
        }
        else if(wizardType == PAYABLE_SCREEN){
            wizardType = RECEIVABLE_SCREEN;
            this.quickSavePayable();
        }
        else if(wizardType == RECEIVABLE_SCREEN){
            wizardType = DEAL_SCREEN;
            this.quickSaveReceivable();
        }
        else if(wizardType == DEAL_SCREEN){
            wizardType = OFFER_SCREEN;
            this.save();
        }
       // system.debug('**wizardType**'+wizardType);
    }
    
    public void getOffers(){
        offerMap = new map<Id, Offer__c>([Select Opportunity__c,Name,Payment_Amt__c,Term_Months__c,Deal_Type__c,
                                                 PMT_Schedule__c,Holdback__c,Funder__c,Payback_Amt__c,Amount__c,Rate__c,
                                                 Submission__c,Status__c
                                                             from Offer__c 
                                                             where Opportunity__c =: OppId]);
        offerWrapperList.clear();
        for(Offer__c offer : offerMap.values()){
            /*if(!offerMap.isEmpty() && offerMap.size() == 1){
                selOfferid = offer.Id;
            }*/
            offerWrapperList.add(new offerWrapper(offer, false));
        }
         if(offerWrapperList.size() == 0){
            addRowOffer();
        }
    }
    
    //Function to get the Receivables
    public void getReceivables(){
        // Query the receivables and display them on the Page
        receivableAmtTotal=0.00;
        //if(receivableList == null)
            receivableList = [Select Name,
                                     Memo__c,
                                     Type__c,
                                     Status__c,
                                     Amount__c,
                                     Due_Date__c,
                                     Percentage__c,
                                     Payback_Funded__c,
                                     Opportunity__c,
                                     Opportunity__r.Commission_Percentage__c,
                                     Due_From_Account__c
                              from Receivable__c where Opportunity__c =: OppId ];
        if(receivableList.size()>0){
            for(Receivable__c rec:receivableList){
                if(rec.Amount__c!=null)
                receivableAmtTotal = receivableAmtTotal + rec.Amount__c;
            }
       }
       if(receivableList.size()<=0 && wizardType != PREVIEW_SCREEN)
        addRowReceivable();
    }
    
    //Function to get the Receivables
    public void getPayables(){
        payableAmtTotal =0.00;
        // Query the receivables and display them on the Page
        //if(payableList == null)
        payableList = [Select Name,
                                 Memo__c,
                                 Type__c,
                                 Status__c,
                                 Due_Date__c,
                                 Amount_Due__c,
                                 Opportunity__c,
                                 Payback_Funded__c,
                                 Account__c,
                                 Percentage__c,
                                 Receivable_Dependency__c
                          from Payable__c where Opportunity__c =: OppId ];
         if(payableList.size()>0){
            for(Payable__c pay:payableList){
                if(pay.Amount_Due__c!=null)
                    payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
            }
       }
       if(payableList.size()<=0 && wizardType != PREVIEW_SCREEN)
        addRowPayable();  
    }
    
    //Function to fetch Syndication records
    public void getSyndication(){
        syndAmtTotal=0.00;
        syndFeeTotal=0.00;
        // Query the receivables and display them on the Page
        //if(syndicationList == null)
        syndicationList = [Select Name,
                                    Commission_Fee__c,
                                    ROR_per__c,
                                    Disbursment_Schedule__c,
                                    Servicing_Fee__c,
                                    Servicing_Bank__c,
                                    Opportunity__c,
                                    Anticipated_Term_Months__c,
                                    Syndication_Amt__c,
                                    Deal_Funding_Amount__c,
                                    Syndication_per__c,
                                    Syndicated_By__c,
                                    Repayment_Amt__c,
                                    Memo__c
                          from Syndication__c where Opportunity__c =: OppId ];
        if(syndicationList.size()>0){
            for(Syndication__c synd:syndicationList){
                if(synd.Syndication_Amt__c!=null)
                syndAmtTotal = syndAmtTotal + synd.Syndication_Amt__c;
                if(synd.Servicing_Fee__c!=null)
                syndFeeTotal = syndFeeTotal + synd.Servicing_Fee__c;
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
      //options.add(new SelectOption('--None--','--None--'));
      for (Integer j=0;j<submissionlist.size();j++)
      {
        String subName = submissionlist[j].Name;
          options.add(new SelectOption(submissionlist[j].Id,submissionlist[j].Funder__r.Name+'-'+submissionlist[j].Status__c+'-('+subName.substring(4,subName.length())+')'));
      }
      return options;
    }
    public void addRowOffer(){
        offerWrapperList.add(new offerWrapper(new Offer__c(Opportunity__c = OppId), false));
        
    } 
    
    public void addRowPayable(){
        
        Account account; 
        
        for (Account a : [select Id, Name, Commission_Percentage__c,Payback_Funded__c from Account where User__c =: objOpp.OwnerId]) {
            account = a;
        }
        
        system.debug('**account'+account);
        Receivable__c objRec = new Receivable__c();
        //Amount__c = Percentage__c * (selProgram.Payback_Funded__c ? objOpp.Payback_Amount__c: Funding_Amount__c)
        if(account != null && receivableList.size()>0 && payableList.size()<=0)
        {
            for(Receivable__c rec : receivableList){
                if(rec.Type__c == 'Commission')
                objRec = rec;
            }
            payableList.add(new Payable__c(Opportunity__c = OppId,Type__c = 'Commission',
                                            Percentage__c = account.Commission_Percentage__c,
                                            Payback_Funded__c =account.Payback_Funded__c,
                                            Due_Date__c = Date.Today()+7,
                                            Amount_Due__c = (account.Commission_Percentage__c==null ? 0 : (account.Commission_Percentage__c/100)) * (account.Payback_Funded__c!=null && account.Payback_Funded__c=='Payback' ? (objOpp.Payback_Amount__c==null ? 0 : objOpp.Payback_Amount__c) : (objOpp.Funding_Amount__c==null ? 0:objOpp.Funding_Amount__c)),
                                            Status__c = 'Open - Needs Review',
                                            Receivable_Dependency__c=objRec.Id,
                                            Account__c = account.Id)); 
        }else{
        payableList.add(new Payable__c(Opportunity__c = OppId));        }    
    }
    
    public void addRowReceivable(){

        if(selProgram != null && receivableList.size()<=0){
        receivableList.add(new Receivable__c(Opportunity__c = OppId, Due_From_Account__c = objOpp.Bank_Name__c,
                                Percentage__c = selProgram.Commission_Percentage__c,//selProgram.Commission_Percentage__c,
                                    Payback_Funded__c =selProgram.Payback_Funded__c,
                                    Amount__c = (selProgram.Commission_Percentage__c==null ? 0 :(selProgram.Commission_Percentage__c/100)) * (selProgram.Payback_Funded__c!=null && selProgram.Payback_Funded__c=='Payback' ? (objOpp.Payback_Amount__c==null ? 0 : objOpp.Payback_Amount__c):(objOpp.Funding_Amount__c==null ? 0 : objOpp.Funding_Amount__c)),
                                    Due_Date__c = Date.Today()+7,Type__c = 'Commission',Status__c = 'Pending' ));    
        }
        else{
            receivableList.add(new Receivable__c(Opportunity__c = OppId, Due_From_Account__c = objOpp.Bank_Name__c )); 
        }      
    }
    
    public void addRowSyndication(){
        syndicationList.add(new Syndication__c(Opportunity__c = OppId));            
    }
    
    public void quickSaveOffer(){
        try{
            list<Offer__c> Offerlst = new list<Offer__c>(); 
            for(OfferWrapper wrapper :  offerWrapperList){
                //system.debug('***wrapper***'+wrapper.offer['Submission__c']);
                Offerlst.add(wrapper.offer);
            }
            upsert Offerlst;
            this.getOffers();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));       
            wizardType = OFFER_SCREEN;
        }
    }
    
    public void quickSavePayable(){
        try{
            if(payableList.size() > 0 )
            {
                for(Integer i=0; i<payableList.size(); i++)
                {
                    if(payableList[i].Type__c == null && payableList[i].Amount_Due__c == null &&
                            payableList[i].Percentage__c == null && payableList[i].Payback_Funded__c == null &&
                            payableList[i].Account__c == null && payableList[i].Due_Date__c == null &&
                            payableList[i].Status__c == null && payableList[i].Memo__c == null &&
                            payableList[i].Receivable_Dependency__c == null )
                        {
                            payableList.remove(i);
                            //upsert receivableList[i];
                        }
                        else
                            upsert payableList[i];
                }//end of for
            }
            this.getPayables();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
            wizardType = PAYABLE_SCREEN;    
        }
    }
    
    public void quickSaveReceivable(){
        try{
            //Amount__c = Percentage__c * (selProgram.Payback_Funded__c='Payback' ? objOpp.Payback_Amount__c:   Funding_Amount__c)
            if(receivableList.size() > 0 )
            {
                for(Integer i=0; i<receivableList.size(); i++)
                {
                    if(receivableList[i].Type__c == null && receivableList[i].Amount__c == null && 
                        receivableList[i].Percentage__c == null &&  receivableList[i].Payback_Funded__c == null && 
                        receivableList[i].Due_Date__c == null && receivableList[i].Status__c == null && receivableList[i].Memo__c == null)
                        {
                            receivableList.remove(i);
                            //upsert receivableList[i];
                        }
                        else
                            upsert receivableList[i];
                }//end of for
            }
                //upsert receivableList;
            //Fetch the Recently updated Values
            this.getReceivables();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));   
            wizardType = RECEIVABLE_SCREEN;
        }
    }
    
    public void quickSaveSyndication(){
        try{
            if(syndicationList.size() > 0)
            {
                for(Integer i=0; i<syndicationList.size(); i++)
                {
                    if(syndicationList[i].Syndication_Amt__c == null &&
                         syndicationList[i].Servicing_Fee__c == null && syndicationList[i].Deal_Funding_Amount__c == null &&
                         syndicationList[i].Servicing_Bank__c == null && syndicationList[i].Syndication_per__c == null &&
                         syndicationList[i].Anticipated_Term_Months__c == null && syndicationList[i].Disbursment_Schedule__c == null &&
                         syndicationList[i].ROR_per__c == null && syndicationList[i].Syndicated_By__c == null && syndicationList[i].Memo__c == null)
                        {
                            syndicationList.remove(i);
                            //upsert receivableList[i];
                        }
                        else
                            upsert syndicationList[i];
                }//end of for
            }
            this.getSyndication();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));   
            wizardType = SYNDICATION_SCREEN;
        }
    }
    
    public void deleteOffer(){
        try{
            string delname = ApexPages.CurrentPage().getParameters().get('delname');
            Integer rowNum = Integer.valueOf(ApexPages.currentPage().getParameters().get('index'));
            
            if(delname != '' && selOfferid != '' && delname.substring(0,15) == selOfferid.substring(0,15)){
                isOfferSelected = false;    
            }
             
            list<Offer__c> OfferList = new list<Offer__c>();
            if( rowNum != null ){
                // remove object from list
                if(offerWrapperList[rowNum-1].offer.Id != null)
                    OfferList.add(offerWrapperList[rowNum-1].offer);
                offerWrapperList.remove(rowNum-1);
            }
            if(OfferList.size() > 0)
                delete OfferList;   
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));       
        }   
    }
    
    //remove payables on click of Delete link
     public void deletPayables(){
        
        this.quickSavePayable();
        list<Payable__c> payableDelList = new list<Payable__c>();
        
        try{
            rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
            //payableList.remove(rowNum-1); 
            if( rowNum != null  && payableList.size() >=  (rowNum-1)){
                if(payableList[rowNum-1].Id != null)
                    payableDelList.add(payableList[rowNum-1]);
                payableList.remove(rowNum-1); 
            }
            if(payableDelList.size()>0){
                delete payableDelList;
            }
           // getPayables();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));       
        }    
        /*string delname = ApexPages.CurrentPage().getParameters().get('delname');
        if( delname != null ){
            for(Integer i=0; i<payableList.size(); ++i){
                if(payableList[i].Name == delname)
                // remove object from list
                payableList.remove(i);
            }
        }*/
     }
     
      //remove receivables on click of Delete link
     public void deletReceivables(){
        
        //this.quickSaveReceivable();
        list<Receivable__c> receivableDelList = new list<Receivable__c>();
        try{
            rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
            if( rowNum != null && receivableList.size() >=  (rowNum-1)){
                if(receivableList[rowNum-1].Id != null)
                    receivableDelList.add(receivableList[rowNum-1]);
                receivableList.remove(rowNum-1); 
            }
            if(receivableDelList.size()>0){
                delete receivableDelList;
            }
            //this.quickSaveReceivable();
            //getReceivables();
            getPayables();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));       
        }   
     }
     
    //remove syndications on click of Delete link     
     public void deletSyndications(){
     
        this.quickSaveSyndication();
        list<Syndication__c> syndicationdelList = new list<Syndication__c>();
        try{
            rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
            if( rowNum != null && syndicationList.size() >=  (rowNum-1)){
                if(syndicationList[rowNum-1].Id != null)
                    syndicationdelList.add(syndicationList[rowNum-1]);
                syndicationList.remove(rowNum-1); 
            }
            if(syndicationdelList.size()>0){
                delete syndicationdelList;
            }
           // getSyndication();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));       
            
        }
     }
    
    public void save(){
        try{
            objContract.Opportunity__c = objOpp.Id;
            objOpp.AccountId = AccountId;
            objOpp.Deal_Entry_Wizard_Check__c = true;
            objContract.AccountId = AccountId; 
            objContract.Name = ContractName;
            objContract.ContractTerm = Integer.valueOf(objOpp.Term_Months__c) ;
            objContract.StartDate = system.today();
            objContract.Stage__c = (Stage == system.label.CreateContract_StageFunded ) ? 
                                      system.label.CreateContract_StageFunded : 
                                        system.label.CreateContract_InitialStage;
            String dealType = objOpp.Deal_Type__c; 
           // if(offerMap == null)
            //objContract.Deal_Type__c = dealType;
            
            upsert objContract;
            update objOpp;
            
            //TODO : On Save it should redirect to Commission Screen so set the Pg to 3
           //wizardType = RECEIVABLE_SCREEN;
        }catch(Exception e){
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
             wizardType = DEAL_SCREEN;
        }
    }
    
    public PageReference cancel(){
        return new PageReference('/'+OppId);
    }
                
    public class OfferWrapper{
        public Offer__c offer                     {get; set;}
        public boolean isSelected                 {get; set;}
        public OfferWrapper(Offer__c pOffer, Boolean pIsSelected){
            offer = pOffer;
            isSelected = pIsSelected;
        }
    }
    
    public void changeWizard(){
        if(!isOfferSelected)
            isOfferSelected = false;
        if(wizardType == PREVIEW_SCREEN){
            getPayables();
            getReceivables();
            getSyndication();
        }
        if(wizardType == RECEIVABLE_SCREEN)
        {
            getReceivables();
        }
         if(wizardType == PAYABLE_SCREEN)
            getPayables();
         if(wizardType == SYNDICATION_SCREEN)
            getSyndication();   
    }
}