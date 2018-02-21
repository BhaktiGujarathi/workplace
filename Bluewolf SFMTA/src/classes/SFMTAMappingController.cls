global without sharing class SFMTAMappingController{
    public Case currentCase {get;set;}
    public User currentUser {get;set;}

    public String profileName {get;set;}
    public Boolean isBikeParking {get;set;}
    public Boolean isColorCurb {get;set;}
    public Boolean isTempSign {get;set;}
    public Boolean isStreetClosure {get;set;}
    public Boolean isReadOnly {get;set;}
    public String isInternal {get;set;}

    public SFMTAMappingController(ApexPages.StandardController controller){
        String caseNum      = apexpages.currentpage().getparameters().get('caseNumber');
        String userId       = apexpages.currentpage().getparameters().get('userId');   
        isInternal          = apexpages.currentpage().getparameters().get('internal');   

        if(String.isNotBlank(caseNum) && String.isNotBlank(userId)){
            this.currentCase = SFMTAMappingSubController.GetCaseByCaseNumber(caseNum);
            this.currentUser = UserServices.GetUserById(userId);
            this.profileName = (this.currentUser.Profile.Name == 'System Administrator') ? 'Admin': 'Citizen';

            if(currentCase.RecordType.Name == 'Bike Parking'){
                this.isBikeParking      = true;
            }
            else if(currentCase.RecordType.Name == 'Color Curbs' || currentCase.RecordType.Name == 'Driveway Red Tip'){
                this.isColorCurb        = true;
                this.isReadOnly         = false;
            }
            else if(currentCase.RecordType.Name == 'Temporary Signs'){
                this.isTempSign         = true;
                this.isReadOnly         = false;
            }
            else if(currentCase.RecordType.Name == 'Special Events' || currentCase.RecordType.Name == 'Block Party'){
                this.isStreetClosure    = true;
                this.isReadOnly         = false;
            }  
            else if(currentCase.RecordType.Name == 'Special Events Read-Only' || currentCase.RecordType.Name == 'Block Party Read-Only'){
                //possibly make this so it is read only output
                this.isStreetClosure    = true;
                this.isReadOnly         = true;
            }
            else{
                System.debug('No Record Type');
            }
        }
    }
}