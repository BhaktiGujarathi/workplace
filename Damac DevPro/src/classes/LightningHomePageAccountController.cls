/*
*    Description : 
*
*    Version       Date            Author               Description
*    1.0           30-07-2017      Pratiksha Narvekar   Initial Draft
*/

public class LightningHomePageAccountController {
    public List<multiRowAccount> listAccounts { get; set; }
    public List<multiRowAccount> ListOfRedemption1 = new List<multiRowAccount>();
    public List<multiRowAccount> ListOfRedemption2 = new List<multiRowAccount>();
    public List<Account> ListOfRedemptions = new List<Account>();
    public Set<ID> SetOfID = new Set<ID>();
    public map<ID,Account> mapRedemption = new map<ID,Account>();
    public map<ID,Account> MAPOfAccount = new  map<ID,Account>();
    public multiRowAccount varErrorMEssage{get;set;}
    public Account ObjAccNo{get;set;}
    public LightningHomePageAccountController() {
        LoadData();  
    } 
    public void LoadData() {
        listAccounts = new List<multiRowAccount>();
        Account objRedemption = new Account();
        String strBase64='Pratiksha';
        for (List<Account> AccData : [SELECT Acc.ID, 
                                             Acc.Name, 
                                             Acc.Profile_Picture__c,
                                             Acc.Date_Of_Birth__c,
                                             Acc.Date_Of_Anniversary__c,
                                             CreatedDate
                                       FROM Account Acc
                                       WHERE Acc.Date_Of_Birth__c  = Today
                                       OR    Acc.Date_Of_Anniversary__c  = Today
                                       ORDER BY CreatedDate]) {
            for (Account objAcc : AccData) {
                ObjAccNo = new Account();    
                multiRowAccount MRC = new multiRowAccount();
                if(objAcc.Profile_Picture__c !=''){
                String pic = objAcc.Profile_Picture__c.substringBetween('<img', 'img>');
                String imgsrc = pic.substringBetween('src="', '"');
                imgsrc = imgsrc.replace('amp;', '');
                //PageReference page = new PageReference(imgsrc);
                //Blob imgblob;
                /*if (Test.IsRunningTest())
                {
                   imgblob=Blob.valueOf('UNIT.TEST');
                }
                else
                {
                    imgblob = page.getContent();
                }
                strBase64  = EncodingUtil.base64Encode(imgblob); */
                MRC.ProfilePicture = imgsrc;
               }  
                MRC.ID = 'https://pratikshanarvekar-dev-ed.lightning.force.com/'+objAcc.ID;
                MRC.Name = objAcc.Name;
                if(objAcc.Date_Of_Birth__c == System.Today()){
                    MRC.DOB ='Wish her on her birthday';
                }
                if(objAcc.Date_Of_Anniversary__c == System.Today()){
                    MRC.DOA = 'Send him bouquet on his wedding anniversary';
                }
                System.debug('...AccData..'+AccData);
                listAccounts.add(MRC);
            }
        }
        }
    public class multiRowAccount {
        String[] AccountList = new String[]{};
        public String ID {get; set;}
        public String Name { get; set; }
        public String ProfilePicture { get; set; }
        public String DOB { get; set; }
        public String DOA { get; set; }
        public Set<ID> SetOfID = new Set<ID>();
    }
}