/**************************************************************************************************
* Name               : DH_RequestWrapper *
* Description        : This Wrapper Class  used To set Request To Drool Engine                     *
* Created Date       :                                                               *
* Created By         : UnKnow                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE          COMMENTS                                              *

  1.1         Naresh(Accely)    20/06/2017    Add  New Parameter i.e schemeId 
                                                                                            *
**************************************************************************************************/



public class DH_RequestWrapper {
  
  public cls_commands[] commands;
  public class cls_commands {
    public cls_insert insert_1;
  }
  public class cls_insert {
  
    public String out_identifier;  //InOutObject
    public cls_object object_1;
  }
  public class cls_object {
    public cls_demo_project1_InOutObject[] demo_project1_InOutObject;
  }
  public class cls_demo_project1_InOutObject {
    public String dateofBooking;  //2017-05-28
    public String marketingProject;  //Mar1
    public String projectName{get;set;}  //Project2
    public String buildingName;  //Buil2
    public string bedroomType;  //2
    public string numberofBedrooms;  //2
    public String views;  //Sea
    public String  floor;  //40
    public String category;  //Villa
    public String subCategory;  //null
    public String cunstructionStatus;  //Completed
    public integer area;  //15
    public integer inventoryThreshold;  //8
    public integer customerthresholdValue;  //10
    public integer price;  //35000
    public String residence;  //Mumbai
    public String region;  //India
    public String agent;  //Agn1
    public String pcId;  //1
    public String unitIdCN;  //1
    public integer noofUnits;  //5
    public integer totalArea;  //25000
    public integer noofUnitsInput;  //1
    public integer totalDealValue;  //20000
    public integer schemeId;  //6
    public integer noofunitsinputPN;  //2
    public integer totalAreaPN;  //0
    public integer totalDealValuePN;  //0
    public integer promoIdPN;  //4
    public String productType;  //4
    public String campaignNameInput;  //Villa
  }
  //public static fromJSON parse(String json){
  //  return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
  //}
    
}