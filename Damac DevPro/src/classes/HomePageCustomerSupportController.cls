public with sharing class HomePageCustomerSupportController {
    
    public List<multiRowCase> listCases { get; set; }
    public List<multiRowCase> ListOfRedemption1 = new List<multiRowCase>();
    public List<multiRowCase> ListOfRedemption2 = new List<multiRowCase>();
    public List<Case> ListOfRedemptions = new List<Case>();
    public Set<ID> SetOfID = new Set<ID>();
    public map<ID,Case> mapRedemption = new map<ID,Case>();
    public map<ID,Case> MAPOfCase = new  map<ID,Case>();
    public multiRowCase varErrorMEssage{get;set;}
    public Case ObjCNo{get;set;}
    public HomePageCustomerSupportController() {
        LoadData();  
    } 
    public void LoadData() {
        listCases = new List<multiRowCase>();
        Case objRedemption = new Case();
        String strBase64='Pratiksha';
        String u= UserInfo.getUserId();
        for (List<Case> CData : [SELECT C.ID, 
                                             C.Account.Name, 
                                             C.Account.Profile_Picture__c,
                                             C.Subject,
                                             CreatedDate,
                                             Days_Since_Last_Update__c,
                                             Status
                                       FROM Case C
                                       WHERE C.OwnerID  =: u
                                       ORDER BY CreatedDate]) {
             if(!CData.isEmpty()){                            
            for (Case objC : CData) {
                ObjCNo = new Case();    
                multiRowCase MRC = new multiRowCase();
                if(objC.Account.Profile_Picture__c !=null){
                String pic = objC.Account.Profile_Picture__c.substringBetween('<img', 'img>');
              String imgsrc = pic.substringBetween('src="', '"');
              imgsrc = imgsrc.replace('amp;', '');
              MRC.ProfilePicture = imgsrc;
               }  
                MRC.Name = objC.Account.Name;
                MRC.Subject = objC.Subject;
                MRC.StatusVal = objC.Status;
                MRC.Status = 'https://pratikshanarvekar-dev-ed.lightning.force.com/'+objC.ID;
                Decimal NoOFDays = objC.Days_Since_Last_Update__c;
                MRC.NoOFDays = String.Valueof(NoOFDays)+ 'Hrs ago';
                System.debug('...CData..'+CData);
                listCases.add(MRC);
            }
        }
        }
        }
    public class multiRowCase {
        String[] CaseList = new String[]{};
        public String ID {get; set;}
        public String Name { get; set; }
        public String NoOFDays { get; set; }
        public String ProfilePicture { get; set; }
        public String Subject { get; set; }
        public String Status { get; set; }
        public String StatusVal { get; set; }
        public Set<ID> SetOfID = new Set<ID>();
    }
    
}