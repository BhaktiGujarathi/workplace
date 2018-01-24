public class testForStdCntrExtension {

    private final Account acct;
    public string abd
    { 
        get {
            system.debug('getmethod '+abd); 
            return abd;
        }
        set { 
            system.debug('setmethodfirst'+ abd);
           
        }
    }
    
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public testForStdCntrExtension(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
    }

    public String getGreeting() {
        return 'Hello ' + acct.name + ' (' + acct.id + ')';
    }
    
   
    
     public String testButton() {
     
     
       system.debug('@@@@@@ '+abd);
        return abd;
    }
}