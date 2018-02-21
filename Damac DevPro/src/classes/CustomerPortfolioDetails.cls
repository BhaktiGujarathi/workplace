/* Class Functionality : It is wrapper used to store Customer Portfolio Information
* Revision History: 
* Version     Author                Date             Description.
* 1.1         Eternus Solutions     10/08/2017       Initial Draft
*/
public with sharing class CustomerPortfolioDetails 
{
  
  public String strUnitName {get;set;}
  public String strProjectName {get;set;}
  public String strNoOfBedRooms {get;set;}
  public String strValue {get;set;}
  public String strCurrentPricePerSqFts {get;set;}
  public String strStatus {get;set;}
  public String strAnticipatedDate {get;set;}
  public String strTotalOverDue {get;set;}
  public String strNextPayment {get;set;}
}