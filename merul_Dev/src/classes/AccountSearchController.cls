public with sharing class AccountSearchController {

public String searchString{get;set;}
public List<Account> lAccount{get;set;}
public Boolean showTable{get;set;}
public String vlimit{get;set;}

public Pagereference search()
{

 
 lAccount = new List<Account>();
 String query ='SELECT Id,name FROM Account WHERE ' +'( Name like \'' + searchString+ '%\') limit '+vlimit;
 lAccount = Database.query(query);
 
 if(lAccount!= null && lAccount.size()!=0)
 showTable = true;
 else
 showTable = false;
 return null;
 

}




}