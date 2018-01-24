public class DEWOfferService
{
    public CreateContractController DEWControlr = new CreateContractController();
    public static Boolean isError = false;


    public static void addRowOffer(Id OppId){
        if(new CreateContractController().offerWrapperList.size() > 0) {
            new CreateContractController().offerWrapperList.add(0,
                new CreateContractController.offerWrapper(
                new Offer__c(Opportunity__c = OppId),
                false,
                new CreateContractController().offerWrapperList.size())
            );
        } else {
            new CreateContractController().offerWrapperList.add(
                new CreateContractController.offerWrapper(
                new Offer__c(Opportunity__c = OppId),
                false,
                new CreateContractController().offerWrapperList.size())
            );
        }
    }

    /*public static void getOffers(map<ID, Offer__c> offerMap, Id OppId, List<CreateContractController.OfferWrapper> offerWrapperList)
    {
        offerWrapperList.clear();
        for(Offer__c offer : offerMap.values()){
            offerWrapperList.add(new CreateContractController.offerWrapper(offer, false));
        }
        if(offerWrapperList.size() == 0){
            DEWOfferService.addRowOffer(OppId);
        }
    }*/

    public static void quickSaveOffer(
            List<CreateContractController.OfferWrapper> offerWrapperList, Id OppId
    ){
        list<Offer__c> Offerlst = new list<Offer__c>();
        List<CreateContractController.OfferWrapper> listTempOfferwrap = new List<CreateContractController.OfferWrapper>();
        for(CreateContractController.OfferWrapper wrapper :  offerWrapperList)
        {
            //wrapper.offer.Status__c = 'Chosen';
            Offerlst.add(wrapper.offer);
        }

        Offerlst = DEWUtility.checkSaveAccessForSObject(Offerlst,UserInfo.getUserId());
        if(Offerlst.size() > 0)
        {
            DEWUtility.upsertForSObject(Offerlst);
        }
           // new CreateContractController().getOffers();
    }

    // Delete offer
    public static void deleteOffer(String delname, Integer rowNum, Boolean isOfferSelected,
    String selOfferid, List<CreateContractController.OfferWrapper>  offerWrapperList)
    {
        Id offerId;
        if(delname != '' && selOfferid != '' && delname.substring(0,15) == selOfferid.substring(0,15)) {
            isOfferSelected = false;
        }
        list<Offer__c> OfferDeleteList = new list<Offer__c>();
        if( rowNum != null ) {
            // remove object from list
            if(offerWrapperList[rowNum-1].offer.Id != null) {
                offerId = offerWrapperList[rowNum-1].offer.Id;
                set<Id> offIdSet = new set<Id>();
                offIdSet.add(offerId);
                if(DEWUtility.checkUserAccessForSobject(offIdSet,UserInfo.getUserId())[0].HasDeleteAccess) {
                    OfferDeleteList.add(offerWrapperList[rowNum-1].offer);
                    offerWrapperList.remove(rowNum-1);
                }
                else {
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.Error,'Insufficient privilege to delete this record')
                    );
                }
            }
            else {
                offerWrapperList.remove(rowNum-1);
            }
        }
        if(OfferDeleteList.size() > 0) {
            delete OfferDeleteList;
        }
    }

    public static Opportunity selectedOffer(
        Offer__c selectedOffer,
        map<ID, Offer__c> offerMap,
        String selOfferid,
        Opportunity objOpp,
        /*Contract objContract,*/
        Program__c selProgram,
        Submission__c selSubmission)
    {
        //get the offer that is selected and on that basis render the values
        if(!offerMap.isEmpty() && offerMap.containsKey(selOfferid))
        {
            selectedOffer = offerMap.get(selOfferid);
            system.debug('$$$$$$$$   '+selectedOffer);
            objOpp.Term_Months__c = selectedOffer.Term_Months__c ;
            objOpp.Holdback_Percentage__c = selectedOffer.Holdback__c;
            objOpp.Schedule__c = selectedOffer.PMT_Schedule__c;
            /*objOpp.Payback_Amount__c = DEWUtility.treateNullAsZero(selectedOffer.Payback_Amt__c);
            objOpp.Funding_Amount__c = DEWUtility.treateNullAsZero(selectedOffer.Amount__c);
            objOpp.Payoff_Amount__c = DEWUtility.treateNullAsZero(selectedOffer.Payoff_Amount__c);
            objOpp.Payment_Amount__c = DEWUtility.treateNullAsZero(selectedOffer.Payment_Amt__c);*/
            objOpp.Payback_Amount__c = (selectedOffer.Payback_Amt__c);
            objOpp.Funding_Amount__c = (selectedOffer.Amount__c);
            objOpp.Payoff_Amount__c = (selectedOffer.Payoff_Amount__c);
            objOpp.Payment_Amount__c = (selectedOffer.Payment_Amt__c);
            //objContract.Deal_Type__c = selectedOffer.Deal_Type__c;
            objOpp.Deal_Type__c = selectedOffer.Deal_Type__c;
            objOpp.Bank_Name__c = selectedOffer.Funder__c;
            objOpp.Origination_fee__c = selectedOffer.Origination_fee__c;   // added temp
            selSubmission = [select Id, Name, Program__c from Submission__c where Id =: selectedOffer.Submission__c];
            objOpp.Bank_Program__c = selSubmission.Program__c;
            objOpp.Buy_Rate__c = selectedOffer.Buy_Rate__c;
            objOpp.Factor_Rate__c = selectedOffer.Rate__c;

            if(objOpp.Bank_Program__c <> null)
            {
                selProgram = [select Id, Name,Payback_Funded__c,Commission_Percentage__c,Renewal_Eligibility__c
                    from Program__c where Id =:selSubmission.Program__c];
                objOpp.Renewal_Eligibility_Percent__c = selProgram.Renewal_Eligibility__c;

                if( selProgram.Renewal_Eligibility__c != null && objOpp.Term_Months__c != null)
                {
                    objOpp.Renewal_Eligibility_Days_from_funding__c = (objOpp.Term_Months__c  *  objOpp.Renewal_Eligibility_Percent__c)/100;
                    DateTime dt = System.Now() + ( objOpp.Renewal_Eligibility_Days_from_funding__c * 30.4368);
                    objOpp.Estimated_Renewal_Date__c = Date.newInstance(Dt.year(),Dt.Month(),Dt.day());
                }
            }
        }
        return  objOpp;
    }
}