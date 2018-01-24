public with sharing class testForActionSupportController {

public boolean showPOPUP{get;set;}
public datetime datePicker{get;set;}
Integer count = 0;
                        
    public PageReference incrementCounter() {
            count++;
            return null;
    }
                    
    public Integer getCount() {
        return count;
    }

public void popUp()
{

showPOPUP=true;
}

public void closepopup()
{

showPOPUP=false;
}
}