public class POC_TestController {

    

   

public String caseId{get;set;}
public String caseNo{get;set;}
public String inputValue{get;set;}
public String inputValue1{get;set;}
public List<Integer> listItem=new List<Integer>();

    public String getCaseId() {
        return caseId;
    }

public List<Integer> getListItem() {
        return listItem;
    }


  
     


public void onLoad()
{

caseId=apexpages.currentpage().getparameters().get('caseid');
caseNo=apexpages.currentpage().getparameters().get('caseno');


}


public void search()
{


    custActionHistory__c cah=new custActionHistory__c(RelatedCase__c=caseId,Comments__c='Pressed Submit Button',Title__c='Main Section');
    insert cah;

    Integer j=integer.valueof(inputValue);
    
    
    for(Integer i=0;i<j;i++)
    {
    
    listItem.add(i);
    
    
    }

}


public void Button1()
{


    custActionHistory__c cah=new custActionHistory__c(RelatedCase__c=caseId,Comments__c='Pressed ActionButton1',Title__c=apexpages.currentpage().getparameters().get('title'));
    insert cah;


}


public void Button2()
{


    custActionHistory__c cah=new custActionHistory__c(RelatedCase__c=caseId,Comments__c='Pressed ActionButton2',Title__c=apexpages.currentpage().getparameters().get('title'));
    insert cah;


}


public void save(){}

public void submit(){}

}