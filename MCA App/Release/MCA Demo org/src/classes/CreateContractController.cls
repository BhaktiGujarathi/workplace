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
   // public String  payableAccSel                   {get; set;}
    public list<Syndication__c> syndicationList           {get; set;}
    public Syndication__c syndication                     {get; set;}
    public Decimal payableAmtTotal                        {get;set;}
    public Decimal receivableAmtTotal                     {get;set;}
    public Decimal syndAmtTotal                           {get;set;}
    public Decimal syndFeeTotal                           {get;set;}
    public String selOfferid                              {get;set;} 
    public String submission                              {get; set;}
    public Integer recCount=0;
    public Integer recWizardCount=0;
    public Integer payCount=0;
    public Integer payWizardCount=0;
    public Integer comm;  //Created by Sri
    //Private variables
    private map<ID, Offer__c> offerMap;
    private String ContractName;
    private String Stage;
    public Submission__c selSubmission;
    public Program__c selProgram;
    //private String selOfferid ;
    public string prevOfferid;
    public string wizardType                              {get;set;}
    public Integer rowNum                                 {get;set;}
    public Static Final String OFFER_SCREEN ='Offer';
    public Static Final String DEAL_SCREEN ='Deal';     
    public Static Final String RECEIVABLE_SCREEN ='Receivable'; 
    public Static Final String PAYABLE_SCREEN ='Payable';
    public Static Final String SYNDICATION_SCREEN ='Syndication';
    public Static Final String PREVIEW_SCREEN ='Preview';
   /* public string productType                             {get;set;}
    public string productSelection                        {get;set;}
    public boolean fieldSet1Visibility                    {get;set;}
    public boolean fieldSet2Visibility                   {get;set;}*/
    public string recordTypeId                        {get;set;}
    public string newFlag                   {get;set;}
    public decimal receivableCount = 0.00;
    public decimal payableCount = 0.00;
    public list<Account> accList ;
    public decimal CommissionPer ;
    
    
   // public String renderingService {get;set;}        
    public CreateContractController(){
        OppId = ApexPages.currentPage().getParameters().get('Id');
        Stage = ApexPages.currentPage().getParameters().get('stage');
        AccountId = ApexPages.currentPage().getParameters().get('accId');
        //ContractName = ApexPages.currentPage().getParameters().get('name');
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
        
        /*string flag = '';
        CreateACH__c objAch = CreateACH__c.getValues('RecordTypeId');
        if(objAch != null)
        recordTypeId = objAch.Value__c;
        CreateACH__c objAch1 = CreateACH__c.getValues('Show/Hide_Flag');
        if(objAch1 != null)
        flag = objAch1.Value__c;
        newFlag = flag.toUpperCase();
        system.debug('****newFlag****'+newFlag);*/
        //wizardType = OFFER_SCREEN;
        
        //Nachiket 1.1
        accList = new list<Account>();
        
    } 
    
    //Function Called on init to populate all the data in the Tables
    public void populateData(){
        objOpp = [Select Name,Account.Name,Bank_Name__c,StageName,
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
                         Date_Contract_Signed__c,
                         Estimated_Renewal_Date__c,
                         Funded_Notes__c,
                         Total_Syndication_Amount__c,
                         Renewal_Eligibility_Percent__c,
                         Renewal_Eligibility_Days_from_funding__c ,
                         Account.Commission_Percentage__c,
                         Origination_Fee__c     // added temp
                  from Opportunity where Id =: OppId];
        system.debug('***objOpp***'+objOpp);
        //Nachiket 1.9
        accList = [Select Id,
                          Commission_Percentage__c,
                          User__c,
                          Payback_Funded__c,
                          Type
                   From Account Where User__c =: objOpp.OwnerId LIMIT 1];
        
        system.debug('****accList***'+accList);
        
        ContractName = objOpp.Name;
        
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
        //this.getPayables();
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
            objOpp.Origination_fee__c = selectedOffer.Origination_fee__c;   // added temp
            selSubmission = [select Id, Name, Program__c from Submission__c where Id =: selectedOffer.Submission__c];
            objOpp.Bank_Program__c = selSubmission.Program__c;
            system.debug('**selSubmission*'+selSubmission);
            if(objOpp.Bank_Program__c <> null){
                selProgram = [select Id, Name,Payback_Funded__c,Commission_Percentage__c,Renewal_Eligibility__c from Program__c where Id =:selSubmission.Program__c];
                objOpp.Renewal_Eligibility_Percent__c = selProgram.Renewal_Eligibility__c;
                
                if( selProgram.Renewal_Eligibility__c != null && objOpp.Term_Months__c != null)
                {
                objOpp.Renewal_Eligibility_Days_from_funding__c = (objOpp.Term_Months__c  *  objOpp.Renewal_Eligibility_Percent__c)/100;
                System.debug('######Renewal_Eligibility_Days_from_funding__c'+objOpp.Renewal_Eligibility_Days_from_funding__c);
                DateTime dt = System.Now() + ( objOpp.Renewal_Eligibility_Days_from_funding__c * 30.4368);
                objOpp.Estimated_Renewal_Date__c = Date.newInstance(Dt.year(),Dt.Month(),Dt.day());
                }
                
            }
            system.debug('**selProgram*'+selProgram);
            if(selectedOffer.Payback_Amt__c != null && selectedOffer.Amount__c!= null)
                objOpp.Factor_Rate__c = selectedOffer.Payback_Amt__c / selectedOffer.Amount__c;
                
        }
    }
    
    //Function called on click of Next button, it will redirect to next Screen
    public void next(){
        if(wizardType == OFFER_SCREEN)
            wizardType = DEAL_SCREEN;
        else if(wizardType == DEAL_SCREEN){
            wizardType = RECEIVABLE_SCREEN;
            system.debug('*****Inside Deal Screen****');
             ++recCount;
            this.save();
            system.debug('####inside next###');
            
            getReceivables();
            
            addRowReceivableForOriginationFeeType();
        }   
        else if(wizardType == RECEIVABLE_SCREEN){
            wizardType = PAYABLE_SCREEN;   
            system.debug('*****Inside Receivable Screen****');
            ++payCount; 
            //upsert receivableList;
            
            this.quickSaveReceivable();
            getPayables();
           // addRowPayableForOriginationFeeType();
        }
        else if(wizardType == PAYABLE_SCREEN){
            wizardType = SYNDICATION_SCREEN;    
            system.debug('*****Inside Payable Screen****');
            //upsert payableList;
            //this.quickSaveReceivable();
            this.quickSavePayable();
            
        }
        else if(wizardType == SYNDICATION_SCREEN){
            wizardType = PREVIEW_SCREEN;    
            system.debug('*****Inside Syndication Screen****');
            //upsert syndicationList;
            this.quickSaveSyndication();
        }
    }
    
    //Function called on click of Previous button, it will redirect to previous Screen
    public void previous(){
        if(wizardType == PREVIEW_SCREEN)
            wizardType = SYNDICATION_SCREEN;
        else if(wizardType == SYNDICATION_SCREEN){
            system.debug('*****Inside Syndication Screen****');
            wizardType = PAYABLE_SCREEN;
            this.quickSaveSyndication();
        }
        else if(wizardType == PAYABLE_SCREEN){
            wizardType = RECEIVABLE_SCREEN;
            system.debug('*****Inside Payable Screen****');
           // this.quickSaveReceivable();
            this.quickSavePayable();
            
        }
        else if(wizardType == RECEIVABLE_SCREEN){
            wizardType = DEAL_SCREEN;
            system.debug('*****Inside Receivable Screen****');
            this.quickSaveReceivable();
        }
        else if(wizardType == DEAL_SCREEN){
            wizardType = OFFER_SCREEN;
            system.debug('*****Inside Deal Screen****');
            this.save();
        }
       // system.debug('**wizardType**'+wizardType);
    }
    
    public void getOffers(){
        offerMap = new map<ID, Offer__c>([Select Opportunity__c,Name,Payment_Amt__c,Term_Months__c,Deal_Type__c,
                                                 PMT_Schedule__c,Holdback__c,Funder__c,Payback_Amt__c,Amount__c,Rate__c,
                                                 Submission__c,Status__c,Origination_fee__c
                                                 from Offer__c  where Opportunity__c =: OppId]);
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
        system.debug('@@@@getReceivables@@@');
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
                                     Deal_Amount_Used__c,
                                     Opportunity__c,
                                     Opportunity__r.Commission_Percentage__c,
                                     Due_From_Account__c,
                                     Due_From_Account__r.Commission_Percentage__c,
                                     Wizard_Check__c,
                                     Amount_Due__c,
                                     IsCreatedFromGrid__c 
                              from Receivable__c where Opportunity__c =: OppId ];
        system.debug('@@@@'+receivableList);
       
       system.debug('@@@receivableList'+receivableList.size());
      /* if(receivableList.size()<=0 && wizardType != PREVIEW_SCREEN)
       {addRowReceivableForOriginationFeeType();}*/
       // {addRowReceivable();}
         system.debug('@@@@recCount@@@'+recCount);
        if(recCount == 1 || recWizardCount==1){
            recCount = 2;
            recWizardCount = 2;
            for(Receivable__c rec:receivableList)
            {
                if(objOpp.Funding_Amount__c!=null && rec.Payback_Funded__c == 'Funded')
                    rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                else if(objOpp.Payback_Amount__c != null && rec.Payback_Funded__c == 'Payback')
                    rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                else{
                    if(objOpp.Funding_Amount__c!=null)
                        rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                }
                if(rec.Percentage__c != null)
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
    public void getPayables(){
        payableAmtTotal =0.00;
        // Query the receivables and display them on the Page
        //if(payableList == null)
        system.debug('****OppId***'+OppId);
        payableList = [Select Name,
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
                          from Payable__c where Opportunity__c =: OppId ];
         
       
         system.debug('****payableAmtTotal After****'+payableAmtTotal);
        //Nachiket 1.1
        if(objOpp.Deal_Entry_Wizard_Check__c == false && accList.size() > 0 && receivableList.size() >0 && receivableList <> null){
        	
	        CommissionPer = (accList[0].Commission_Percentage__c == null ? 0.00 : accList[0].Commission_Percentage__c);
	        
	        for (integer i=0; i<receivableList.size();i++){
	            if((receivableList[i].Type__c == 'Commission' && accList[0].Payback_Funded__c == 'Commission Revenue') && receivableList[i].Wizard_Check__c == false && objOpp.Deal_Entry_Wizard_Check__c == false && receivableList[i].IsCreatedFromGrid__c == false){
	                        system.debug('****Enter in Loop1****'+CommissionPer);
	                            payableList.add(new Payable__c(Opportunity__c = OppId,
	                                                           Type__c = receivableList[i].Type__c,
	                                                           Percentage__c = CommissionPer,//accList[0].Commission_Percentage__c,
	                                                           Payback_Funded__c =accList[0].Payback_Funded__c,
	                                                           Due_Date__c = Date.Today()+7,
	                                                           Amount_Due__c = receivableList[i].Amount__c * (CommissionPer/100),//receivableList[i].Amount_Due__c,//(account.Commission_Percentage__c==null ? 0 : (account.Commission_Percentage__c/100)) * (account.Payback_Funded__c!=null && account.Payback_Funded__c=='Payback' ? (objOpp.Payback_Amount__c==null ? 0 : objOpp.Payback_Amount__c) : (objOpp.Funding_Amount__c==null ? 0:objOpp.Funding_Amount__c)),
	                                                           Status__c = 'Open - Needs Review',
	                                                           Receivable_Dependency__c = receivableList[i].Id,
	                                                           Memo__c = receivableList[i].Memo__c,
	                                                           Deal_Amount_Used__c = receivableList[i].Deal_Amount_Used__c,
	                                                           Wizard_Check__c = true,
	                                                           //Account__c = receivableList[i].Due_From_Account__c)); 
	                                                           Account__c = accList[0].Id));
	                                                           system.debug('****payableList in Loop1****'+payableList);
	                            receivableList[i].Wizard_Check__c = true;
	                            
	            }//End If
	            
	            else if((accList[0].Payback_Funded__c == 'Payback'  || accList[0].Payback_Funded__c == 'Funded')
	                      && receivableList[i].Wizard_Check__c == false &&
	                objOpp.Deal_Entry_Wizard_Check__c == false && receivableList[i].IsCreatedFromGrid__c == false){
	                            system.debug('****Enter in Loop3****');
	                              if(payableList.size()>0){
	                                for(Payable__c pay:payableList){
	                                    if(pay.Amount_Due__c!=null)
	                                        payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
	                                }
	                           }
	                           if(payableList.size()<=0 && wizardType != PREVIEW_SCREEN){
	                            addRowPayable();  
	                           }
	                                                           
	                            receivableList[i].Wizard_Check__c = true;
	                           
	            }//End Else If
	            
	            else if((receivableList[i].Type__c <> null && accList[0].Payback_Funded__c == 'All Revenue')
	                      && receivableList[i].Wizard_Check__c == false &&
	                objOpp.Deal_Entry_Wizard_Check__c == false && receivableList[i].IsCreatedFromGrid__c == false){
	               
	                        system.debug('****Enter in Loop4****');
	                        system.debug('*****receivableList[i].Wizard_Check__c****'+receivableList[i].Wizard_Check__c);
	                            payableList.add(new Payable__c(Opportunity__c = OppId,
	                                                           Type__c = receivableList[i].Type__c,
	                                                           Percentage__c = CommissionPer,//accList[0].Commission_Percentage__c,
	                                                           Payback_Funded__c =accList[0].Payback_Funded__c,
	                                                           Due_Date__c = Date.Today()+7,
	                                                           Amount_Due__c = receivableList[i].Amount__c * (CommissionPer/100),//receivableList[i].Amount_Due__c,//(account.Commission_Percentage__c==null ? 0 : (account.Commission_Percentage__c/100)) * (account.Payback_Funded__c!=null && account.Payback_Funded__c=='Payback' ? (objOpp.Payback_Amount__c==null ? 0 : objOpp.Payback_Amount__c) : (objOpp.Funding_Amount__c==null ? 0:objOpp.Funding_Amount__c)),
	                                                           Status__c = 'Open - Needs Review',
	                                                           Receivable_Dependency__c=receivableList[i].Id,
	                                                           Memo__c = receivableList[i].Memo__c,
	                                                           Deal_Amount_Used__c = receivableList[i].Deal_Amount_Used__c,
	                                                           Wizard_Check__c = true,
	                                                           //Account__c = receivableList[i].Due_From_Account__c)); 
	                                                           Account__c = accList[0].Id));
	                                                           system.debug('****payableList in Loop4****'+payableList);
	                            receivableList[i].Wizard_Check__c = true;
	                            
	            }//End Else If
	            
	            else{
	                receivableList[i].Wizard_Check__c = true;
	                system.debug('****receivableList[i].Wizard_Check__c****'+receivableList[i].Wizard_Check__c);
	                
	            }
	         }//End For
	       }//End if
	       system.debug('******payableList After Loop***'+payableList);
	       if(payableList.size()>0){
		        for(Payable__c pay:payableList){    
		            system.debug('******pay.Amount_Due__c***'+pay.Amount_Due__c);
		            if(pay.Amount_Due__c!=null)
		                payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
		        }
	       }
	       if(payableList.size()<=0 && wizardType != PREVIEW_SCREEN)
		        addRowPayable();  
		        if(payCount == 1 || payWizardCount==1){
		            payCount = 2;
		            payWizardCount = 2;
		       
		   }//end of if
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
                                    Syndication_Percentage__c,
                                    Profit_Amount__c,
                                    //Syndication_Fee__c,
                                    //Syndication_per__c,
                                    Syndicated_By__c,
                                    Repayment_Amt__c,
                                    Memo__c
                          from Syndication__c where Opportunity__c =: OppId ];
        system.debug('@@@@'+syndicationList);
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
        if(accList != null && receivableList.size()>0 && payableList.size()<=0 && objOpp.Deal_Entry_Wizard_Check__c == false 
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
    
    
    /*****************Merul*******************/
    
     public void addRowReceivableForOriginationFeeType(){
     	
        //fetching Account of Merchant Record type
        Boolean orignRec = false; 
        for(Receivable__c recWizard:receivableList){
			 if(recWizard.Type__c == 'Origination fee'){
			    orignRec  = true;
			 }
        }
            
        if(!orignRec && wizardType != PREVIEW_SCREEN && !string.isblank(selOfferId) && objOpp.Account.id!= null){
                   
              ID RecordTypeId = [select id,recordtypeid from account where id=:objOpp.Account.id limit 1][0].recordtypeid;
              if(RecordTypeId !=null){
                   String recordTypeName = [select id,name from recordtype where id=:RecordTypeId].name;
                   if(recordTypeName == 'Merchant'){    
                        receivableList.add(new Receivable__c(Opportunity__c = OppId, Due_From_Account__c = objOpp.Account.id,Type__c = 'Origination Fee',Amount__c = [select Origination_fee__c from offer__c where id=:selOfferId].Origination_fee__c));
                   }  
              }
        }
    }
    
     /*****************Merul*******************/
    public void addRowSyndication(){
        syndicationList.add(new Syndication__c(Opportunity__c = OppId));            
    }
    
    public void quickSaveOffer(){
        try{
            list<Offer__c> Offerlst = new list<Offer__c>(); 
            for(OfferWrapper wrapper :  offerWrapperList){
                system.debug('***wrapper***'+wrapper);
                //system.debug('***wrapper***'+wrapper.offer['Submission__c']);
                Offerlst.add(wrapper.offer);
            }
            system.debug('***Offerlst***'+Offerlst);
            upsert Offerlst;
             system.debug('***Offerlst-after upsert***'+Offerlst);
            this.getOffers();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));       
            wizardType = OFFER_SCREEN;
        }
    }
    
    public void quickSavePayable(){
        try{
            system.debug('payableList****In QuickSave'+payableList);
            list<Payable__c> lstPayableToUpsert = new list<Payable__c> ();
            
            if(payableList.size() > 0 ){    
                system.debug('payableList****In QuickSave if'+payableList);
                for(Integer i=0; i<payableList.size(); i++){
                    if(payableList[i].Type__c == null && payableList[i].Amount_Due__c == null &&
                            payableList[i].Percentage__c == null && payableList[i].Payback_Funded__c == null &&
                            payableList[i].Account__c == null && payableList[i].Due_Date__c == null &&
                            payableList[i].Status__c == null && payableList[i].Memo__c == null &&
                            payableList[i].Receivable_Dependency__c == null ){
                            payableList.remove(i);
                            //upsert receivableList[i];
                     }
                    else{
                    	lstPayableToUpsert.add(payableList[i]);
                        //upsert payableList[i];
                    }
                }//end of for
            }
            
            upsert lstPayableToUpsert;
            this.getPayables();
            
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
            wizardType = PAYABLE_SCREEN;    
        }
    }
    
    public void quickSaveReceivable(){
        try{
            //Amount__c = Percentage__c * (selProgram.Payback_Funded__c='Payback' ? objOpp.Payback_Amount__c:   Funding_Amount__c)
            system.debug('*****receivableList in Quick Save****'+receivableList);
            list<Receivable__c> lstReceivableToUpsert = new list<Receivable__c> ();
            if(receivableList.size() > 0 ){
                for(Integer i=0; i<receivableList.size(); i++){
                    if(receivableList[i].Type__c == null && receivableList[i].Amount__c == null && 
                        receivableList[i].Percentage__c == null &&  receivableList[i].Payback_Funded__c == null && receivableList[i].Deal_Amount_Used__c == null && 
                        receivableList[i].Due_Date__c == null && receivableList[i].Status__c == null && receivableList[i].Memo__c == null ){
                            receivableList.remove(i);
                            //upsert receivableList[i];
                    }
                    else{
                       lstReceivableToUpsert.add(receivableList[i]);
                    }
                }//end of for
                upsert lstReceivableToUpsert;
            }
            
            this.getReceivables();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));   
            wizardType = RECEIVABLE_SCREEN;
        }
    }
    
    public void quickSaveSyndication(){
    	list<Syndication__c> lstSyndicationToUpsert = new list<Syndication__c> ();
        try{
            if(syndicationList.size() > 0){
                for(Integer i=0; i<syndicationList.size(); i++){
                    if(syndicationList[i].Syndication_Amt__c == null &&
                         syndicationList[i].Servicing_Fee__c == null && syndicationList[i].Deal_Funding_Amount__c == null &&
                         syndicationList[i].Servicing_Bank__c == null && syndicationList[i].Syndication_Percentage__c == null && 
                         syndicationList[i].Profit_Amount__c == null &&
                         syndicationList[i].Anticipated_Term_Months__c == null && syndicationList[i].Disbursment_Schedule__c == null &&
                         syndicationList[i].ROR_per__c == null && syndicationList[i].Syndicated_By__c == null && syndicationList[i].Memo__c == null){
                            syndicationList.remove(i);
                        }
                        else{
                        	lstSyndicationToUpsert.add(syndicationList[i]);
                            //upsert syndicationList[i];
                        }
                }//end of for
                
                upsert lstSyndicationToUpsert;
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
                system.debug('@@'+rowNum);
                system.debug('payableList'+payableList);
                if(payableList[rowNum-1].Id != null)
                    payableDelList.add(payableList[rowNum-1]);
                payableList.remove(rowNum-1); 
                system.debug('@@'+payableList);
            }
            if(payableDelList.size()>0){
                delete payableDelList;
            }
            this.quickSavePayable();
           //getPayables();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));       
        }    
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
            system.debug('%%%'+receivableList);
            this.quickSaveReceivable();
           //getReceivables();
            //getPayables();
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
           this.quickSaveSyndication();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));       
            
        }
     }
     
     public void onChangeBankProgram(){
        system.debug('@@@onChangeBankProgram'+selProgram);
        system.debug('@@@onChangeBankProgram1111'+objOpp.Bank_Program__c);
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
            //DateTime dt = System.Now() + ((objOpp.Term_Months__c  *  objOpp.Renewal_Eligibility_Percent__c) * 30.00);
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
     
     public void onChangeRecPaybackFunded(){
        String recevableid = System.currentPagereference().getParameters().get('recId');
        receivableAmtTotal = 0.00;
        system.debug('***recevableid'+recevableid);
        system.debug('***receivableList'+receivableList);
        for(Receivable__c rec : receivableList){
              system.debug('***rec**'+rec);
             if(rec.Id == null){
                system.debug('***insidefor2***'+rec);
                if(rec.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                    rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                else if(rec.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                    rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                /*else
                {
                    if(objOpp.Payback_Amount__c != null)
                        rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                }*/
                    
                if(rec.Percentage__c != null && rec.Deal_Amount_Used__c != null)
                    rec.Amount__c = rec.Deal_Amount_Used__c * (rec.Percentage__c/100);
            }           
            else if(rec.Id != null && recevableid != '' && rec.Id == recevableid ){
           
                system.debug('***recevableid-if**'+rec.Payback_Funded__c);
                if(rec.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                    rec.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                else if(rec.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                    rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                else{
                    if(objOpp.Payback_Amount__c != null)
                        rec.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                }
                    
                if(rec.Percentage__c != null)
                    rec.Amount__c = rec.Deal_Amount_Used__c * (rec.Percentage__c/100);
            }
        }      
        
        if(receivableList.size()>0){
            for(Receivable__c rec:receivableList){
                if(rec.Amount__c!=null)
                receivableAmtTotal = receivableAmtTotal + rec.Amount__c;
            }
       } 
     }
     
     public void onChangePayPaybackFunded(){
        String payableid = System.currentPagereference().getParameters().get('payId');
        system.debug('***payableid'+payableid);
        system.debug('***receivableList'+receivableList);
        //Nachiket 1.3
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
        system.debug('***receivableAmountCommission***'+receivableAmountCommission+'***receivableAmountAllRevenue***'+receivableAmountAllRevenue);
        //Nachiket 1.3
        for(Payable__c pay : payableList){
            system.debug('****pay***'+pay);
            if(pay.Id == null && pay.Wizard_Check__c == false){
                system.debug('***payableid-if**'+pay.Payback_Funded__c);
                if(pay.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                    pay.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                else if(pay.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                    pay.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
               /* else
                {
                    if(objOpp.Payback_Amount__c != null)
                        pay.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                }*/
                    
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null){
                    pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                }
                
            }
            else if(pay.Id != null && payableid != '' && pay.Id == payableid && pay.Wizard_Check__c == false){
           
                system.debug('***payableid-if**'+pay.Payback_Funded__c);
                if(pay.Payback_Funded__c == 'Funded' && objOpp.Funding_Amount__c != null)
                    pay.Deal_Amount_Used__c = objOpp.Funding_Amount__c;
                else if(pay.Payback_Funded__c == 'Payback' && objOpp.Payback_Amount__c != null)
                    pay.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                else{
                    if(objOpp.Payback_Amount__c != null)
                        pay.Deal_Amount_Used__c = objOpp.Payback_Amount__c;
                }
                    
                if(pay.Percentage__c != null)
                    pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }   
            //Nachiket 1.3
            if(pay.Id == null && pay.Wizard_Check__c == false){
                system.debug('***payableid-if**'+pay.Payback_Funded__c);
                if(pay.Payback_Funded__c == 'Commission Revenue' && objOpp.Funding_Amount__c != null)
                    pay.Deal_Amount_Used__c = receivableAmountCommission;
                                  
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null){
                    pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                }
            }
            
            else if(pay.Id != null && payableid != '' && pay.Id == payableid && pay.Wizard_Check__c == false){
           
                system.debug('***payableid-if**'+pay.Payback_Funded__c);
                if(pay.Payback_Funded__c == 'Commission Revenue' && objOpp.Funding_Amount__c != null)
                    pay.Deal_Amount_Used__c = receivableAmountCommission;
                
                if(pay.Percentage__c != null)
                    pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }   
            
            if(pay.Id == null && pay.Wizard_Check__c == false){
                system.debug('***payableid-if**'+pay.Payback_Funded__c);
                if(pay.Payback_Funded__c == 'All Revenue' && objOpp.Funding_Amount__c != null)
                    pay.Deal_Amount_Used__c = receivableAmountAllRevenue;
                                  
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null){
                    pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                }
                
            }
            
            else if(pay.Id != null && payableid != '' && pay.Id == payableid && pay.Wizard_Check__c == false){
           
                system.debug('***payableid-if**'+pay.Payback_Funded__c);
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
                system.debug('******pay.Amount_Due__c***'+pay.Amount_Due__c);
                if(pay.Amount_Due__c!=null)
                    payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
            }
        }
     }
     
     public void onChangeRecPercentage(){
        String recevableid = System.currentPagereference().getParameters().get('recId');
        receivableAmtTotal = 0.00;
        system.debug('***recevableid'+recevableid);
        for(Receivable__c rec : receivableList){
            if(rec.Id != null && recevableid != '' && rec.Id == recevableid){
                system.debug('***recevableid-if**'+rec.Payback_Funded__c);
                if(rec.Deal_Amount_Used__c != null && rec.Percentage__c != null)
                    rec.Amount__c = rec.Deal_Amount_Used__c * (rec.Percentage__c/100);
            }
            if(rec.Id == null)
            {
                if(rec.Deal_Amount_Used__c != null && rec.Percentage__c != null)
                    rec.Amount__c = rec.Deal_Amount_Used__c * (rec.Percentage__c/100);
            }
            
        }   
        
        if(receivableList.size()>0){
            for(Receivable__c rec:receivableList){
                if(rec.Amount__c!=null)
                receivableAmtTotal = receivableAmtTotal + rec.Amount__c;
            }
       } 
        
     }
     
     
     public void onChangeAmountCalculation(List<receivable__c> receivableList,List<payable__c> payableList){
        decimal receivableOrgFee =0.00;
        for(Receivable__c rec:receivableList){
        
              if(rec.Amount__c <> null && rec.Type__c == 'Origination Fee'){
                    receivableOrgFee += rec.Amount__c;
               }
            
        }
           // return receivableOrgFee;
           
       system.debug('####### payableList.size()'+payableList.size());
        for(Payable__c pay : payableList){
	        system.debug('$$$$$$$   pay-----'+ pay);
	        if(pay.Payback_Funded__c!=null /*&& pay.Type__c!= null*/ && pay.Percentage__c!=null){
	            if(/*pay.Id == null &&*/ pay.Wizard_Check__c == false && pay.Payback_Funded__c == 'Origination Fee' /*&& pay.Type__c== 'Origination Fee'*/){
	               system.debug('###### in payable %'+pay.Percentage__c);
	                pay.Amount_Due__c = receivableOrgFee * (pay.Percentage__c/100);
	            }
	        }
	         system.debug('$$$$$$$   pay.Amount_Due__c'+ pay.Amount_Due__c);
        }   
     }
     
     public void onChangePayPercentage(){
        String payableid = System.currentPagereference().getParameters().get('payId');
        system.debug('***payableid'+payableid);

        system.debug('***receivableList'+receivableList);
        //Nachiket 1.3
        decimal receivableAmountCommission = 0.00;
        decimal receivableAmountAllRevenue = 0.00;
        decimal receivableOrgFee =0.00;
       
       
        for(Receivable__c rec:receivableList){
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
        system.debug('***receivableAmountCommission***'+receivableAmountCommission+'***receivableAmountAllRevenue***'+receivableAmountAllRevenue);
        //Nachiket 1.3
       
        for(Payable__c pay : payableList){
            if(pay.Id != null && payableid != '' && pay.Id == payableid && pay.Wizard_Check__c == false){
                system.debug('***payableid-if**'+pay.Payback_Funded__c);
                if(pay.Deal_Amount_Used__c != null && pay.Percentage__c != null)
                    pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }
            if(pay.Id == null && pay.Wizard_Check__c == false)
            {
                if(pay.Deal_Amount_Used__c != null && pay.Percentage__c != null)
                    pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }

            //Nachiket 1.3
            if(pay.Id == null && pay.Wizard_Check__c == false){
                system.debug('***payableid-if**'+pay.Payback_Funded__c);
                if(pay.Payback_Funded__c == 'Commission Revenue' && objOpp.Funding_Amount__c != null)
                    pay.Deal_Amount_Used__c = receivableAmountCommission;
                                  
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null){
                    pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                }
            }
            
            else if(pay.Id != null && payableid != '' && pay.Id == payableid && pay.Wizard_Check__c == false){
           
                system.debug('***payableid-if**'+pay.Payback_Funded__c);
                if(pay.Payback_Funded__c == 'Commission Revenue' && objOpp.Funding_Amount__c != null)
                    pay.Deal_Amount_Used__c = receivableAmountCommission;
                
                if(pay.Percentage__c != null)
                    pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }   
            
            if(pay.Id == null && pay.Wizard_Check__c == false){
                system.debug('***payableid-if**'+pay.Payback_Funded__c);
                if(pay.Payback_Funded__c == 'All Revenue' && objOpp.Funding_Amount__c != null)
                    pay.Deal_Amount_Used__c = receivableAmountAllRevenue;
                                  
                if(pay.Percentage__c != null && pay.Deal_Amount_Used__c <> null){
                    pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
                }
            }
            
            else if(pay.Id != null && payableid != '' && pay.Id == payableid && pay.Wizard_Check__c == false){
           
                system.debug('***payableid-if**'+pay.Payback_Funded__c);
                if(pay.Payback_Funded__c == 'All Revenue' && objOpp.Funding_Amount__c != null)
                    pay.Deal_Amount_Used__c = receivableAmountAllRevenue;
                
                if(pay.Percentage__c != null)
                    pay.Amount_Due__c = pay.Deal_Amount_Used__c * (pay.Percentage__c/100);
            }   
            ////Nachiket 1.3 End
            
        /*************Merul*************************/
        this.onChangeAmountCalculation(receivableList,payableList);
        /*************Merul*************************/
       
            
             /******************************************Merul***********************************************************************************/ 
           /* if(pay.Id == null && pay.Wizard_Check__c == false && pay.Payback_Funded__c == 'Origination Fee' && pay.Type__c== 'Origination Fee')
            {
               system.debug('###### in payable %'+pay.Percentage__c);
                pay.Amount_Due__c = receivableOrgFee * (pay.Percentage__c/100);
                      
            }*/
            /******************************************Merul***********************************************************************************/ 

        }   
        
        payableAmtTotal =0.00;
        if(payableList.size()>0){
            for(Payable__c pay:payableList){    
                system.debug('******pay.Amount_Due__c***'+pay.Amount_Due__c);
                if(pay.Amount_Due__c!=null)
                    payableAmtTotal = payableAmtTotal + pay.Amount_Due__c;
            }
        }
     }
            
    
    public void save(){
        try{
            objContract.Opportunity__c = objOpp.Id;
            objOpp.AccountId = AccountId;
           // objOpp.Deal_Entry_Wizard_Check__c = true;
            //objOpp.Estimated_Renewal_Date__c = objContract.Anticipated_Renewal_Date__c;
            objContract.AccountId = AccountId; 
            objContract.Name = ContractName;
            objContract.Notes__c = objOpp.Funded_Notes__c;
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
        // Decimal summaryReceivableOriginationFee = 0;
        // Decimal summaryPayableOriginationFee = 0;
        objopp.Deal_Entry_Wizard_Check__c = true;
        getReceivables();
        //system.debug('%%%%%%% '+receivableList.size());
       
        try{
           // objopp.Total_Origination_Fees_Receivable__c = summaryReceivableOriginationFee;
           // objopp.Total_Origination_Fees_Payable__c = summaryPayableOriginationFee ;
            upsert objopp;
        }
        catch(exception e){
            
        }
        quickSaveReceivable();
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
            ++recWizardCount;
            system.debug('***wizardType REC***'+wizardType);
            addRowReceivableForOriginationFeeType();
            //getReceivables();
        }
         if(wizardType == PAYABLE_SCREEN)
         {
            ++payWizardCount;
            system.debug('***wizardType pay***'+wizardType);
            getPayables();
           // addRowPayableForOriginationFeeType();
         }
         if(wizardType == SYNDICATION_SCREEN)
            getSyndication();   
    }
}