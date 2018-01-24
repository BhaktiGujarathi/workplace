public class testCustAttributeJqueryExt {

public List<Account> lAcc{get;set;}
    public testCustAttributeJqueryExt() {
    
         lAcc = new List<Account>();

        lAcc = [select name from Account];

    }


}