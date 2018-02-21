public class CustomerPortalHomeController {
    
    public String srType                                {get;set;}
    public Boolean createTransferOfOwnerShip            {get;set;}
    public Boolean createAdditionalParking              {get;set;}
    public Boolean createComplaint                      {get;set;}
    public Boolean createEarlyHandover                  {get;set;}
    public Boolean createFurniturePackage               {get;set;}
    public Boolean createRentalPool                     {get;set;}
    public Boolean createTitleDeed                      {get;set;}
    public Boolean createUtilityRegistration            {get;set;}
    public Boolean createHandover                       {get;set;}
    public Boolean createProofOfPayment                 {get;set;}
    public String strAccountId                          {get;set;} 
    
    public CustomerPortalHomeController(){
        srType = ApexPages.currentPage().getParameters().get('SRType');
        strAccountId = ApexPages.currentPage().getParameters().get('AccountId');
        system.debug('!!!inside constructor');
        populateCreateSRBoolean();
    }
    
    public void populateCreateSRBoolean(){
        
        createTransferOfOwnerShip = false;
        createAdditionalParking = false;
        createComplaint = false;
        createEarlyHandover = false;
        createFurniturePackage = false;
        createRentalPool = false;
        createTitleDeed = false;
        createUtilityRegistration = false;
        createHandover = false;
        createProofOfPayment = false;
        
        system.debug('!!!!!!!!!!srType'+srType);
        if(srType != null && srType != ''){
            if(srType.equals('TransferOfOwnerShip')){
                createTransferOfOwnerShip = true;
            } else if(srType.equals('AdditionalParking')){
                createAdditionalParking = true;
            } else if(srType.equals('Complaint')){
                createComplaint = true;
            } else if(srType.equals('EarlyHandover')){
                createEarlyHandover = true;
            } else if(srType.equals('FurniturePackage')){
                createFurniturePackage = true;
            } else if(srType.equals('RentalPool')){
                createRentalPool = true;
            } else if(srType.equals('TitleDeed')){
                createTitleDeed = true;
            } else if(srType.equals('UtilityRegistration')){
                createUtilityRegistration = true;
            } else if(srType.equals('Handover')){
                createHandover = true;
            } else if(srType.equals('ProofOfPayment')){
                createProofOfPayment = true;
            } 
        }
        
    }


}