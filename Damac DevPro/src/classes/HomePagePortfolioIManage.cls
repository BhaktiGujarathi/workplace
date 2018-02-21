/*Pratiksha Narvekar
*/


public with sharing class HomePagePortfolioIManage {
        public List<multiRowAccount> listAccounts { get; set; }
    public List<multiRowAccount> ListOfRedemption1 = new List<multiRowAccount>();
    public List<multiRowAccount> ListOfRedemption2 = new List<multiRowAccount>();
    public List<Account> ListOfRedemptions = new List<Account>();
    public Set<ID> SetOfID = new Set<ID>();
    public map<ID,Account> mapRedemption = new map<ID,Account>();
    public map<ID,Account> MAPOfAccount = new  map<ID,Account>();
    public multiRowAccount varErrorMEssage{get;set;}
    public Account ObjAccNo{get;set;}
    public HomePagePortfolioIManage() {
        LoadData();  
    } 
    public void LoadData() {
        listAccounts = new List<multiRowAccount>();
        Account objRedemption = new Account();
        String strBase64='Pratiksha';
        for (List<Account> AccData : [SELECT Acc.ID, 
                                             Acc.Name, 
                                             Acc.Profile_Picture__c,
                                             CLASS__c,
                                             Units__c,
                                             Whats_Next__c,
                                             Value__c,
                                             Support_status__c,
                                             WORTH__c,
                                             SLASerialNumber__c,
                                             CreatedDate
                                       FROM Account Acc
                                       ORDER BY CreatedDate]) {
            for (Account objAcc : AccData) {
                ObjAccNo = new Account();    
                multiRowAccount MRC = new multiRowAccount();
                if(objAcc.Profile_Picture__c != null){
                String pic = objAcc.Profile_Picture__c.substringBetween('<img', 'img>');
                String imgsrc = pic.substringBetween('src="', '"');
                imgsrc = imgsrc.replace('amp;', '');
                MRC.ProfilePicture = imgsrc;
               }    
               if(objAcc.CLASS__c != null){
                //MRC.ClassName = objAcc.CLASS__c;
                String pic2 = objAcc.CLASS__c.substringBetween('<img', '/>');
               String imgsrc2 = pic2.substringBetween('src="', '"');
                //imgsrc2 = imgsrc2.replace('amp;', '');
                MRC.ClassName = 'https://pratikshanarvekar-dev-ed--c.ap2.visual.force.com'+imgsrc2;
               }     
                MRC.ID = objAcc.ID;
                MRC.Name = objAcc.Name;
                MRC.NameLink = 'https://pratikshanarvekar-dev-ed.my.salesforce.com/'+objAcc.ID; 
                MRC.WORTH = objAcc.WORTH__c;
                MRC.Units = objAcc.Units__c;
                MRC.Value = objAcc.Value__c;
                MRC.WhatsNext = objAcc.Whats_Next__c;
                MRC.SupportStatus = objAcc.Support_status__c;                
                System.debug('...AccData..'+AccData);
                listAccounts.add(MRC);
            }
        }
        }
    public class multiRowAccount {
        String[] AccountList = new String[]{};
        public String ID {get; set;}
        public String ProfilePicture { get; set; }
        public String Name { get; set; }
        public String NameLink { get; set; }
        public String WORTH { get; set; }
        public String ClassName { get; set;}
        public Decimal Units{ get; set; }
        public String Value { get; set; }
        public String WhatsNext { get; set; }
        public String SupportStatus { get; set; }
        public Set<ID> SetOfID = new Set<ID>();
    }
}