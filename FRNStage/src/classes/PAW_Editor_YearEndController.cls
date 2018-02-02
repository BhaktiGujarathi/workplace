public class PAW_Editor_YearEndController {

    public PAW_YearEnd_Controller primaryController   { set; get; }
    public PAW_YearEnd_Controller secondaryController { set; get; }
    public MetaData meta                              { set; get; }
    public SummarizedDataCls summarizedData           { set; get; }
    //current year can be overridden externally for test classes, edge cases etc.
    //else it will default current actual calendar year
    public String currentYear                         { set; get; }
    public Boolean yearEndMode = PAW_YearEnd_Config.fetch().Year_End_Mode_Enabled__c;

    public class MetaData {
        String recordId;
        String isClone;
        String quoteId;
        Boolean isOpportunity;
        Boolean isPAW;
        Id primaryId;
        public Id secondaryId {set; get;}
        public String primaryYear    {set; get;}
        public String secondaryYear  {set; get;}
        public Boolean hasSecondary {set; get;}
    }

    public PAW_Editor_YearEndController() {

	}

    /*
        1. Identify primary paw, on the basis of current year
        2. Populate benefit dropdown based on the year.
        3. Benefit -> Opportunity Id
        4.
    */

    public PageReference initialize(){
        //extract and initialize url parameters
        meta = meta == null ? new MetaData() : meta;
        meta = initializeParameters ( meta );
        meta = initializeDefaultYearMeta ( meta );

        if ( true == meta.isOpportunity ) {
            if(yearEndMode) {
                meta.secondaryId = meta.recordId;
            }
            meta.primaryId = meta.recordId;
        } else if ( true == meta.isPAW ) {
            //logic to find primary and secondary
            meta = populatePAWIds( meta );
        }

        primaryController = new PAW_YearEnd_Controller()
                                .setRecordId( meta.primaryId )
                                .setYear( meta.primaryYear )
                                .setIsPrimary( true )
                                .setMetaData( meta )
                                .init();

        secondaryController = new PAW_YearEnd_Controller()
                                    .setRecordId( meta.secondaryId )
                                    .setYear( meta.secondaryYear )
                                    .setIsPrimary( false )
                                    .setMetaData( meta )
                                    .init();

        if( secondaryController.recordId != null ) {
            meta.hasSecondary = true;
        } else {
            meta.hasSecondary = false;
        }

        refereshSummarizedData();
        return redirectIfLocked();
    }

    public PageReference redirectIfLocked(){
        //@TODO To check if redirect is required
        return null;
    }

    public Pay_Agreement_Worksheet__c getPayAgreementWorksheet(Id recordId){
        List<Pay_Agreement_Worksheet__c> payAgreementWorksheetList = [
            SELECT Related_Year__c
                 , For_Year__c
                 , Related_Pay_Agreement_Worksheet__c
              FROM Pay_Agreement_Worksheet__c
             WHERE Id = :recordId
        ];
        return payAgreementWorksheetList.isEmpty() ? null : payAgreementWorksheetList.get(0);
    }

    // Util methods
    public MetaData initializeParameters ( MetaData meta ) {

        meta.recordId = Apexpages.currentpage().getparameters().get('id'); //Opportunity Id or PAW id
        meta.isClone = Apexpages.currentpage().getparameters().get('Clone'); // counter offer from quote
        meta.quoteId = Apexpages.currentpage().getparameters().get('quoteId'); // counter offer from quote

        if( ! String.isBlank( meta.recordId ) ) {
            meta.isOpportunity = Utils.isOpportunityId(meta.recordId);
            meta.isPAW         = Utils.isPAWId(meta.recordId);
        }
        return meta;
    }

    public MetaData populatePAWIds( MetaData meta ){

        if( ! meta.isPAW ) {
            return meta;
        }

        Pay_Agreement_Worksheet__c payAgreementWorksheet = getPayAgreementWorksheet(meta.recordId);
        if ( payAgreementWorksheet.For_Year__c == currentYear() ) {
            meta.primaryId     = meta.recordId;
            meta.secondaryId   = payAgreementWorksheet.Related_Pay_Agreement_Worksheet__c;
            meta.primaryYear   = currentYear();
        } else {
            meta.primaryId     = payAgreementWorksheet.Related_Pay_Agreement_Worksheet__c;
            meta.secondaryId   = meta.recordId;
            meta.secondaryYear = payAgreementWorksheet.For_Year__c;
        }

        if ( payAgreementWorksheet.Related_Pay_Agreement_Worksheet__c == null ) {
            meta.hasSecondary = false;
        } else {
            meta.hasSecondary = true;
        }

        return meta;
    }

    public MetaData initializeDefaultYearMeta(MetaData meta){
        meta.primaryYear    =  currentYear();
        meta.secondaryYear  =  String.valueOf( System.Today().year() + 1 );
        return meta;
    }

    public String currentYear(){
        return currentYear == null ? String.valueOf( System.Today().year() )  : currentYear ;
    }

    public PAW_Editor_YearEndController getThis() {
        return this;
    }

    public SummarizedDataCls refereshSummarizedData() {
        summarizedData = new SummarizedDataCls();
        if( primaryController.wrprObj.pyAgrmntWrksht != null
        &&  secondaryController.wrprObj.pyAgrmntWrksht != null ) {
            summarizedData.totalPatientContribution =
                                    treatNullAsZero(primaryController.wrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c) +
                                    treatNullAsZero(secondaryController.wrprObj.pyAgrmntWrksht.Total_Patient_Contribution__c);
            summarizedData.totalEIV = treatNullAsZero(primaryController.wrprObj.totalInsCoResp) +
                                    treatNullAsZero(secondaryController.wrprObj.totalInsCoResp);
            summarizedData.totalRevenue = treatNullAsZero(primaryController.wrprObj.pyAgrmntWrksht.Total_Revenue__c) +
                                    treatNullAsZero(secondaryController.wrprObj.pyAgrmntWrksht.Total_Revenue__c);
            summarizedData.totalDailyRevenue = treatNullAsZero(primaryController.wrprObj.pyAgrmntWrksht.Daily_Revenue__c) +
                                    treatNullAsZero(secondaryController.wrprObj.pyAgrmntWrksht.Daily_Revenue__c);
            summarizedData.totalCopay = treatNullAsZero(primaryController.wrprObj.totalCoPayAmt) +
                                    treatNullAsZero(secondaryController.wrprObj.totalCoPayAmt);
        }

        return summarizedData;
    }

    public PageReference saveRecords() {
        String primaryPAWRecordId = Apexpages.currentPage().getParameters().get('primaryPAWRecordId');
        String secondaryPAWRecordId = Apexpages.currentPage().getParameters().get('secondaryPAWRecordId');
        if(meta.hasSecondary) {
            List<Pay_Agreement_Worksheet__c> savePAWList = new List<Pay_Agreement_Worksheet__c>();

            //System.assert(false,''+primaryPAWRecordId+'--'+secondaryPAWRecordId);
            system.debug('>>> primaryPAWRecordId : '+primaryPAWRecordId);
            if(!String.isBlank(primaryPAWRecordId) && !String.isBlank(secondaryPAWRecordId)) {
                Pay_Agreement_Worksheet__c primaryPayAgreementWorksheet =  new Pay_Agreement_Worksheet__c(Id=primaryPAWRecordId);
                savePAWList.add(primaryPayAgreementWorksheet);

                Pay_Agreement_Worksheet__c secondaryPayAgreementWorksheet;
                if( false == String.isBlank(secondaryPAWRecordId) ){
                    secondaryPayAgreementWorksheet =  new Pay_Agreement_Worksheet__c(Id=secondaryPAWRecordId);
                    primaryPayAgreementWorksheet.Related_Pay_Agreement_Worksheet__c = secondaryPAWRecordId;
                    secondaryPayAgreementWorksheet.Related_Pay_Agreement_Worksheet__c = primaryPAWRecordId;
                    savePAWList.add(secondaryPayAgreementWorksheet);
                }
                //@TODO validate why fails in case of update @Bhakti
                if(!savePAWList.isEmpty()) {
                    update savePAWList;
                }
            }
            
        }
        PageReference orderPage;
        if(!String.isBlank(primaryPAWRecordId)) {
            orderPage = new PageReference('/'+primaryPAWRecordId);
            orderPage.setRedirect(true);
            return orderPage;
        }
        else 
            orderPage = new PageReference('/apex/paw_editor_yearend?Id='+meta.recordId);
            orderPage.setRedirect(true);
            return null;
    }

    public void rerenderMethod() {

    }

    public Decimal treatNullAsZero(Decimal valueInstance) {
        return valueInstance == null ? 0.0 : valueInstance;
    }

    public class SummarizedDataCls {
        public Decimal totalPatientContribution    {get; set;}
        public Decimal totalEIV                    {get; set;}
        public Decimal totalRevenue                {get; set;}
        public Decimal totalDailyRevenue           {get; set;}
        public Decimal totalCopay                  {get; set;}
        public SummarizedDataCls() {
            totalPatientContribution = 0.0;
            totalEIV = 0.0;
            totalRevenue = 0.0;
            totalDailyRevenue = 0.0;
            totalCopay = 0.0;
        }
    }
}