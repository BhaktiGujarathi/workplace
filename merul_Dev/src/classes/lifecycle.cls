public with sharing class lifecycle {

    private final Account acct;
    Integer EmpAdd;

    public lifecycle(myController controller) {
        this.acct = (Account)controller.getAccount();
         system.debug('@@@@@@ extension constructor');    
    }

    public String getGreeting() {
        return acct.name + ' Current Information';
    }
     
     public PageReference save1() {
            system.debug('@@@@@@ extension save method');   
           
            return null;
      }  
    public void resetEmp() {
        acct.numberofemployees = 10;
        update acct;
    }
    

}