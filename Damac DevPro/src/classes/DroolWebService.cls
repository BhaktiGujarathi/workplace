/**************************************************************************************************
* Name               : DroolWebService                                                   *
* Description        : This is a controller class for Drool Web services                      *
* Created Date       : 24/06/2017                                                                 *
* Created By         : Naresh Kaneriya                                                                        *
                                    *
**************************************************************************************************/

public class DroolWebService{
 
  public static final Integer Constvalue=-999999;
  public static List<DH_PromotionsWrapper> finalWrap{get;set;}
  public static Map<id,List<selectOption>> optMap{get;set;}
  public static String CampaignName ;
  public static List<DH_PromotionsWrapper> plist=new  List<DH_PromotionsWrapper>();
  
 /***********************************************************************************************
    * @Description : Method to Call Drool Web Services 
    * @Params      : List<DH_PromotionsWrapper> 
    * @Return      : List<DH_PromotionsWrapper>                                                                           
 ************************************************************************************************/
    
  public static List<DH_PromotionsWrapper> createRequestData(UtilityWrapperManager availableInventoriesList){
        
        Set<Id> InventoryId =  new Set<Id>();
        List<Campaign_Inventory__c> CamList = new List<Campaign_Inventory__c>();  
        List<DH_RequestWrapper.cls_demo_project1_InOutObject> unitsList=new  List<DH_RequestWrapper.cls_demo_project1_InOutObject>();
        system.debug('...availableInventoriesList...'+availableInventoriesList);
        if(availableInventoriesList.ibwList!=null&&availableInventoriesList.ibwList.size()>0){
        
          for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory:availableInventoriesList.ibwList){
                if(thisInventory.isSelected&&thisInventory.selectedInventory.Id!=null){
                    InventoryId.add(thisInventory.selectedInventory.Id);
                 }
              }
            
             if(!InventoryId.isEmpty()){
                 for(Campaign_Inventory__c Cam : [select Id , Inventory__c , Campaign__r.Campaign_Name__c  from Campaign_Inventory__c where  Inventory__c =: InventoryId ]){
                     CamList.add(Cam);
                 }
             }
       
            for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory:availableInventoriesList.ibwList){
                
                if(thisInventory.isSelected&&thisInventory.selectedInventory.Id!=null){
                    
                    system.debug('#### selected inventory createRequestData= '+thisInventory.selectedInventory);
                    system.debug('#### selected inventory bookingUnit createRequestData= '+thisInventory.bookingUnit);
                    DH_RequestWrapper.cls_demo_project1_InOutObject reqEle=new  DH_RequestWrapper.cls_demo_project1_InOutObject();
                    reqEle.productType = thisInventory.selectedInventory.CurrencyIsoCode ;
                    reqEle.dateofBooking=system.now().format('YYYY-MM-dd');
                    reqEle.projectName=!string.isBlank(thisInventory.selectedInventory.Property_Name__c)?thisInventory.selectedInventory.Property_Name__c:'null';
                    reqEle.buildingName=thisInventory.selectedInventory.Building_Location__r.Name!=null?thisInventory.selectedInventory.Building_Location__r.Name:'null';
                    reqEle.bedroomType=!string.isBlank(thisInventory.selectedInventory.Bedroom_Type__c)?thisInventory.selectedInventory.Bedroom_Type__c:'null';
                    reqEle.numberofBedrooms=!string.isBlank(thisInventory.selectedInventory.IPMS_Bedrooms__c)?(thisInventory.selectedInventory.IPMS_Bedrooms__c.equalsIgnoreCase('Studio')?'1':thisInventory.selectedInventory.IPMS_Bedrooms__c):'null';
                    reqEle.cunstructionStatus=!string.isBlank(thisInventory.selectedInventory.Property_Status__c)?thisInventory.selectedInventory.Property_Status__c:'null';
                    //reqEle.area=Integer.valueof(thisInventory.selectedInventory.Area_Sqft_2__c) ;
                    reqEle.area=thisInventory.selectedInventory.Area_Sqft_2__c!=null?Integer.valueof(thisInventory.selectedInventory.Area_Sqft_2__c):0;
                    // reqEle.price=Integer.valueof(thisInventory.selectedInventory.Special_Price__c) ;
                    reqEle.price=thisInventory.selectedInventory.Special_Price__c!=null?Integer.valueof(thisInventory.selectedInventory.Special_Price__c):0;
                    
                    // reqEle.agent=   String.valueof(availableInventoriesList.dealRecord.Agent_Name__r.Name) != null ?  availableInventoriesList.dealRecord.Agent_Name__r.Name : 'null' ;             
                    reqEle.agent='null';
                    reqEle.pcId=UserInfo.getName();
                    reqEle.unitIdCN=!string.isBlank(thisInventory.selectedInventory.Unit__c)?thisInventory.selectedInventory.Unit__c:'null';
                    reqEle.marketingProject=!string.isBlank(thisInventory.selectedInventory.Marketing_Name__c)?thisInventory.selectedInventory.Marketing_Name__c:'null';
                    reqEle.views=!string.isBlank(thisInventory.selectedInventory.View_Type__c)?thisInventory.selectedInventory.View_Type__c:'null';
                    reqEle.floor=!string.isBlank(thisInventory.selectedInventory.Floor__c)?thisInventory.selectedInventory.Floor__c:'null';
                    reqEle.category=!string.isBlank(thisInventory.selectedInventory.Unit_Type__c)?thisInventory.selectedInventory.Unit_Type__c:'null';
                    reqEle.subCategory=!string.isBlank(thisInventory.selectedInventory.Brand__c)?thisInventory.selectedInventory.Brand__c:'null';
                    reqEle.inventoryThreshold=0;
                    reqEle.customerthresholdValue=0;
                   //reqEle.region=!string.isBlank(thisInventory.jointBuyerList[0].Country__c)?thisInventory.jointBuyerList[0].Country__c:'null';
                   // reqEle.residence=!string.isBlank(thisInventory.jointBuyerList[0].City__c)?thisInventory.jointBuyerList[0].City__c:'null';
                     
                    if(!thisInventory.jointBuyerList.isEmpty()){
                   for(Buyer__c buyer :thisInventory.jointBuyerList){
                       if(buyer.Primary_Buyer__c == true){
                        reqEle.region=!string.isBlank(buyer.Country__c)?buyer.Country__c:'null';
                        reqEle.residence=!string.isBlank(buyer.City__c)?buyer.City__c:'null';
                        } 
                        
                        else{
                        reqEle.region='null';
                        reqEle.residence='null';  
                       }
                      }
                    }
                    else{
                        reqEle.region='null';
                        reqEle.residence='null';
                    }
                   if(!CamList.isEmpty()){
                      for(Campaign_Inventory__c C : CamList){
                          if(C.Inventory__c == thisInventory.selectedInventory.Id){
                          reqEle.campaignNameInput=!string.isBlank(C.Campaign__r.Campaign_Name__c)? C.Campaign__r.Campaign_Name__c:'null';
                          break;
                         }
                       }
                     }
                 else{
                    reqEle.campaignNameInput= 'null';
                   }
                    reqEle.noofUnits=0;
                    reqEle.totalArea=0;
                    reqEle.totalDealValue=0;
                    reqEle.noofUnitsInput=0;
                    // add new Parameter
                    reqEle.schemeId=6;
                    reqEle.noofunitsinputPN=2;
                    reqEle.totalAreaPN=0;
                    reqEle.totalDealValuePN=0;
                    reqEle.promoIdPN=4;
                    unitsList.add(reqEle);
                }
            }
        }
        DH_RequestWrapper.cls_object inout=new  DH_RequestWrapper.cls_object();
        
        inout.demo_project1_InOutObject=unitsList;
        
        DH_RequestWrapper.cls_insert inst=new  DH_RequestWrapper.cls_insert();
        
        inst.object_1=inout;
        
        inst.out_identifier='InOutObject';
        DH_RequestWrapper.cls_commands cmnd=new  DH_RequestWrapper.cls_commands();
        cmnd.insert_1=inst;
        List<DH_RequestWrapper.cls_commands> cmndList=new  List<DH_RequestWrapper.cls_commands>();
        cmndList.add(cmnd);
        DH_RequestWrapper rw1=new  DH_RequestWrapper();
        rw1.commands=cmndList;
        system.debug(rw1);
        string body=JSON.serialize(rw1);
        system.debug(body);
        List<DH_ResponseWrapper> respWrapList=new  List<DH_ResponseWrapper>();
        if(!string.isBlank(body)){
            body=body.contains('demo_project1_InOutObject') ? body.replace('demo_project1_InOutObject','demo.project1.InOutObject') : body;
            body=body.contains('object_1') ? body.replace('object_1','object') : body;
            body=body.contains('insert_1') ? body.replace('insert_1','insert'): body;
            system.debug('Request body for Drool***'+body);
            respWrapList=DH_DroolCalloutService.getResponse(body);
        }
        system.debug('Response body for Drool::::'+respWrapList);
        if(respWrapList!=null){
                    for(DH_ResponseWrapper rw:respWrapList){
                            DH_PromotionsWrapper p=new  DH_PromotionsWrapper();
                            List<SelectOption> promOptions=new  List<SelectOption>();
                            List<SelectOption> campOptions=new  List<SelectOption>();
                            List<SelectOption> schmOptions=new  List<SelectOption>();
                            
                            
                            List<DH_PromotionsWrapper.optionWrapper> optOptions=new  List<DH_PromotionsWrapper.optionWrapper>();
                            //Promotion options
                            promOptions.add(new  SelectOption('','-- Select Promotion -- '));
                            if(rw.discountPercentPN.isNumeric()&&Integer.Valueof(rw.discountPercentPN)!=Constvalue&&string.isnotblank(rw.promoNamePN))promOptions.add(new  SelectOption(rw.discountPercentPN,rw.promoNamePN+' - '+'Discount '+rw.discountPercentPN+' '+'%'));
                            if(rw.discountPSF_PN.isNumeric()&&Integer.Valueof(rw.discountPSF_PN)!=Constvalue&&string.isnotblank(rw.promoNamePN))promOptions.add(new  SelectOption(rw.discountPSF_PN,rw.promoNamePN+' - '+'Discount '+rw.discountPSF_PN+' '+'psf'+' '+rw.productType));
                            if(rw.discountFlatPN.isNumeric()&&Integer.Valueof(rw.discountFlatPN)!=Constvalue&&string.isnotblank(rw.promoNamePN))promOptions.add(new  SelectOption(rw.discountFlatPN,rw.promoNamePN+' - '+'Discount '+rw.discountFlatPN+' '+'flat'+' '+rw.productType));
                            if(string.isnotblank(rw.giftPN)&&string.isnotblank(rw.promoNamePN))promOptions.add(new  SelectOption(rw.giftPN,rw.promoNamePN+' - '+'Gift '+rw.giftPN));
                            if(string.isnotblank(rw.inLeuPN)&&string.isnotblank(rw.promoNamePN))promOptions.add(new  SelectOption(rw.inLeuPN,rw.promoNamePN+'-'+'In lieu of Gift '+rw.inLeuPN));
                            if(string.isnotblank(rw.waiverPN)&&string.isnotblank(rw.promoNamePN))promOptions.add(new  SelectOption(rw.waiverPN,rw.promoNamePN+' - '+'Waiver '+rw.waiverPN));
                            if(string.isBlank(rw.discountPercentPN)&&!string.isBlank(rw.promoNamePN)&&string.isBlank(rw.discountPSF_PN)&&string.isBlank(rw.discountFlatPN)&&string.isBlank(rw.giftPN)&&string.isBlank(rw.inLeuPN)&&string.isBlank(rw.waiverPN))promOptions.add(new  SelectOption(rw.promoNamePN,rw.promoNamePN));
                                
                            //Campaign options
                            campOptions.add(new  SelectOption('','-- Select Campaign -- '));
                            if(rw.discountPercentCN.isNumeric()&&Integer.Valueof(rw.discountPercentCN)!=Constvalue&&string.isnotblank(rw.campName))campOptions.add(new  SelectOption(rw.discountPercentCN,rw.campName+' - '+'Discount '+rw.discountPercentCN+' '+'%'));
                            if(rw.discountPSF_CN.isNumeric()&&Integer.Valueof(rw.discountPSF_CN)!=Constvalue&&string.isnotblank(rw.campName))campOptions.add(new  SelectOption(rw.discountPSF_CN,rw.campName+' - '+'Discount '+rw.discountPSF_CN+' '+'psf'+' '+rw.productType));
                            if(rw.discountFlatCN.isNumeric()&&Integer.Valueof(rw.discountFlatCN)!=Constvalue&&string.isnotblank(rw.campName))campOptions.add(new  SelectOption(rw.discountFlatCN,rw.campName+' - '+'Discount '+rw.discountFlatCN+' '+'flat'+' '+rw.productType));
                            if(string.isnotblank(rw.giftCN)&&string.isnotblank(rw.campName))campOptions.add(new  SelectOption(rw.giftCN,rw.campName+' - '+'Gift '+rw.giftCN));
                            if(string.isnotblank(rw.inLeuCN)&&string.isnotblank(rw.campName))campOptions.add(new  SelectOption(rw.inLeuCN,rw.campName+' - '+'In lieu of Gift '+rw.inLeuCN));
                            if(string.isnotblank(rw.waiverCN)&&string.isnotblank(rw.campName))campOptions.add(new  SelectOption(rw.waiverCN,rw.campName+' - '+'Waiver '+rw.waiverCN));
                            if(string.isBlank(rw.discountPercentCN)&&!string.isBlank(rw.campName)&&string.isBlank(rw.discountPSF_CN)&&string.isBlank(rw.discountFlatCN)&&string.isBlank(rw.giftCN)&&string.isBlank(rw.inLeuCN)&&string.isBlank(rw.waiverCN))campOptions.add(new  SelectOption(rw.campName,rw.campName));

                            //schemen options
                            schmOptions.add(new  SelectOption('','-- Select Scheme -- '));
                            if(rw.discountPercentSN.isNumeric()&&Integer.Valueof(rw.discountPercentSN)!=Constvalue&&string.isnotblank(rw.promoNameSN))schmOptions.add(new  SelectOption(rw.discountPercentSN,rw.promoNameSN+' - '+'Discount '+rw.discountPercentSN+' '+'%'));
                            if(rw.discountFlatSN.isNumeric()&&Integer.Valueof(rw.discountPSF_SN)!=Constvalue&&string.isnotblank(rw.promoNameSN))schmOptions.add(new  SelectOption(rw.discountPSF_SN,rw.promoNameSN+' - '+'Discount '+rw.discountPSF_SN+' '+'psf'+' '+rw.productType));
                            if(rw.discountFlatCN.isNumeric()&&Integer.Valueof(rw.discountFlatSN)!=Constvalue&&string.isnotblank(rw.promoNameSN))schmOptions.add(new  SelectOption(rw.discountFlatSN,rw.promoNameSN+' - '+'Discount '+rw.discountFlatSN+' '+'flat'+' '+rw.productType));
                            if(string.isnotblank(rw.giftSN)&&string.isnotblank(rw.promoNameSN))schmOptions.add(new  SelectOption(rw.giftSN,rw.promoNameSN+' - '+'Gift '+rw.giftSN));
                            if(string.isnotblank(rw.inLeuSN)&&string.isnotblank(rw.promoNameSN))schmOptions.add(new  SelectOption(rw.inLeuSN,rw.promoNameSN+' - '+'In lieu of Gift '+rw.inLeuSN));
                            if(string.isnotblank(rw.waiverSN)&&string.isnotblank(rw.promoNameSN))schmOptions.add(new  SelectOption(rw.waiverSN,rw.promoNameSN+' - '+'Waiver '+rw.waiverSN));
                            if(string.isBlank(rw.discountPercentSN)&&!string.isBlank(rw.promoNameSN)&&string.isBlank(rw.discountPSF_SN)&&string.isBlank(rw.discountFlatSN)&&string.isBlank(rw.giftSN)&&string.isBlank(rw.inLeuSN)&&string.isBlank(rw.waiverSN))schmOptions.add(new  SelectOption(rw.promoNameSN,rw.promoNameSN));
                            
                            //Option options
                            /*
                            if(string.isnotblank(rw.option1Id))optOptions.add(loadOptionData(rw.option1Name,rw.option1Id,rw.option1Price));
                            if(string.isnotblank(rw.option2Id))optOptions.add(loadOptionData(rw.option2Name,rw.option2Id,rw.option2Price));
                            if(string.isnotblank(rw.option3Id))optOptions.add(loadOptionData(rw.option3Name,rw.option3Id,rw.option3Price));
                            if(string.isnotblank(rw.option4Id))optOptions.add(loadOptionData(rw.option4Name,rw.option4Id,rw.option4Price));
                            if(string.isnotblank(rw.option5Id))optOptions.add(loadOptionData(rw.option5Name,rw.option5Id,rw.option5Price));
                            if(string.isnotblank(rw.option6Id))optOptions.add(loadOptionData(rw.option6Name,rw.option6Id,rw.option6Price));
                            */
                            
                             
                            if(string.isnotblank(rw.option1Id)){
                                    if(rw.option1Price.isNumeric() && Integer.Valueof(rw.option1Price)!=Constvalue && string.isnotblank(rw.option1Name)){
                                        optOptions.add(loadOptionData(rw.option1Name+' - '+rw.option1Price+' '+rw.productType,rw.option1Id,rw.option1Price));
                                }else if(rw.discountPercentOP1.isNumeric() && Integer.Valueof(rw.discountPercentOP1)!=Constvalue && string.isnotblank(rw.option1Name)){
                                     optOptions.add(loadOptionData(rw.option1Name+' - '+'Discount '+rw.discountPercentOP1+' '+'%',rw.option1Id,rw.discountPercentOP1));
                              }else if(rw.discountFlatOP1.isNumeric() && Integer.Valueof(rw.discountFlatOP1)!=Constvalue && string.isnotblank(rw.option1Name)){
                                      optOptions.add(loadOptionData(rw.option1Name+' - '+'Discount '+rw.discountFlatOP1+' '+'flat'+' '+rw.productType,rw.option1Id,rw.discountFlatOP1));
                              }else if(rw.discountPSF_OP1.isNumeric() && Integer.Valueof(rw.discountPSF_OP1)!=Constvalue && string.isnotblank(rw.option1Name)){
                             optOptions.add(loadOptionData(rw.option1Name+' - '+'Discount '+rw.discountPSF_OP1+' '+'psf'+' '+rw.productType,rw.option1Id,rw.discountPSF_OP1));
                            }
                         }
                         
                         if(string.isnotblank(rw.option2Id)){
                                    if(rw.option2Price.isNumeric() && Integer.Valueof(rw.option2Price)!=Constvalue && string.isnotblank(rw.option2Name)){
                                        optOptions.add(loadOptionData(rw.option2Name+' - '+rw.option2Price+' '+rw.productType,rw.option2Id,rw.option2Price));
                                }else if(rw.discountPercentOP2.isNumeric() && Integer.Valueof(rw.discountPercentOP2)!=Constvalue && string.isnotblank(rw.option2Name)){
                                     optOptions.add(loadOptionData(rw.option2Name+' - '+'Discount '+rw.discountPercentOP2+' '+'%',rw.option2Id,rw.discountPercentOP2));
                              }else if(rw.discountFlatOP2.isNumeric() && Integer.Valueof(rw.discountFlatOP2)!=Constvalue && string.isnotblank(rw.option2Name)){
                                      optOptions.add(loadOptionData(rw.option2Name+' - '+'Discount '+rw.discountFlatOP2+' '+'flat'+' '+rw.productType,rw.option2Id,rw.discountFlatOP2));
                              }else if(rw.discountPSF_OP2.isNumeric() && Integer.Valueof(rw.discountPSF_OP2)!=Constvalue && string.isnotblank(rw.option2Name)){
                             optOptions.add(loadOptionData(rw.option2Name+' - '+'Discount '+rw.discountPSF_OP2+' '+'psf'+' '+rw.productType,rw.option2Id,rw.discountPSF_OP2));
                            }
                         }
                            
                            
                         if(string.isnotblank(rw.option3Id)){
                                    if(rw.option3Price.isNumeric() && Integer.Valueof(rw.option3Price)!=Constvalue && string.isnotblank(rw.option3Name)){
                                        optOptions.add(loadOptionData(rw.option3Name+' - '+rw.option3Price+' '+rw.productType,rw.option3Id,rw.option3Price));
                                }else if(rw.discountPercentOP3.isNumeric() && Integer.Valueof(rw.discountPercentOP3)!=Constvalue && string.isnotblank(rw.option3Name)){
                                     optOptions.add(loadOptionData(rw.option3Name+' - '+'Discount '+rw.discountPercentOP3+' '+'%',rw.option3Id,rw.discountPercentOP3));
                              }else if(rw.discountFlatOP3.isNumeric() && Integer.Valueof(rw.discountFlatOP3)!=Constvalue && string.isnotblank(rw.option3Name)){
                                      optOptions.add(loadOptionData(rw.option3Name+' - '+'Discount '+rw.discountFlatOP3+' '+'flat'+' '+rw.productType,rw.option3Id,rw.discountFlatOP3));
                              }else if(rw.discountPSF_OP3.isNumeric() && Integer.Valueof(rw.discountPSF_OP3)!=Constvalue && string.isnotblank(rw.option3Name)){
                             optOptions.add(loadOptionData(rw.option3Name+' - '+'Discount '+rw.discountPSF_OP3+' '+'psf'+' '+rw.productType,rw.option3Id,rw.discountPSF_OP3));
                            }
                         }   
                         
                         
                         
                         if(string.isnotblank(rw.option4Id)){
                                    if(rw.option4Price.isNumeric() && Integer.Valueof(rw.option4Price)!=Constvalue && string.isnotblank(rw.option4Name)){
                                        optOptions.add(loadOptionData(rw.option4Name+' - '+rw.option4Price+' '+rw.productType,rw.option4Id,rw.option4Price));
                                }else if(rw.discountPercentOP4.isNumeric() && Integer.Valueof(rw.discountPercentOP4)!=Constvalue && string.isnotblank(rw.option4Name)){
                                     optOptions.add(loadOptionData(rw.option4Name+' - '+'Discount '+rw.discountPercentOP4+' '+'%',rw.option4Id,rw.discountPercentOP4));
                              }else if(rw.discountFlatOP4.isNumeric() && Integer.Valueof(rw.discountFlatOP4)!=Constvalue && string.isnotblank(rw.option4Name)){
                                      optOptions.add(loadOptionData(rw.option4Name+' - '+'Discount '+rw.discountFlatOP4+' '+'flat'+' '+rw.productType,rw.option4Id,rw.discountFlatOP4));
                              }else if(rw.discountPSF_OP4.isNumeric() && Integer.Valueof(rw.discountPSF_OP4)!=Constvalue && string.isnotblank(rw.option4Name)){
                             optOptions.add(loadOptionData(rw.option4Name+' - '+'Discount '+rw.discountPSF_OP4+' '+'psf'+' '+rw.productType,rw.option4Id,rw.discountPSF_OP4));
                            }
                         }
                         
                         
                         if(string.isnotblank(rw.option5Id)){
                                    if(rw.option5Price.isNumeric() && Integer.Valueof(rw.option5Price)!=Constvalue && string.isnotblank(rw.option5Name)){
                                        optOptions.add(loadOptionData(rw.option5Name+' - '+rw.option5Price+' '+rw.productType,rw.option5Id,rw.option5Price));
                                }else if(rw.discountPercentOP5.isNumeric() && Integer.Valueof(rw.discountPercentOP5)!=Constvalue && string.isnotblank(rw.option5Name)){
                                     optOptions.add(loadOptionData(rw.option5Name+' - '+'Discount '+rw.discountPercentOP5+' '+'%',rw.option5Id,rw.discountPercentOP5));
                              }else if(rw.discountFlatOP5.isNumeric() && Integer.Valueof(rw.discountFlatOP5)!=Constvalue && string.isnotblank(rw.option5Name)){
                                      optOptions.add(loadOptionData(rw.option5Name+' - '+'Discount '+rw.discountFlatOP5+' '+'flat'+' '+rw.productType,rw.option5Id,rw.discountFlatOP5));
                              }else if(rw.discountPSF_OP5.isNumeric() && Integer.Valueof(rw.discountPSF_OP5)!=Constvalue && string.isnotblank(rw.option5Name)){
                             optOptions.add(loadOptionData(rw.option5Name+' - '+'Discount '+rw.discountPSF_OP5+' '+'psf'+' '+rw.productType,rw.option5Id,rw.discountPSF_OP5));
                            }
                         }
                         
                         if(string.isnotblank(rw.option6Id)){
                                    if(rw.option6Price.isNumeric() && Integer.Valueof(rw.option6Price)!=Constvalue && string.isnotblank(rw.option6Name)){
                                        optOptions.add(loadOptionData(rw.option6Name+' - '+rw.option6Price+' '+rw.productType,rw.option6Id,rw.option6Price));
                                }else if(rw.discountPercentOP6.isNumeric() && Integer.Valueof(rw.discountPercentOP6)!=Constvalue && string.isnotblank(rw.option6Name)){
                                     optOptions.add(loadOptionData(rw.option6Name+' - '+'Discount '+rw.discountPercentOP6+' '+'%',rw.option6Id,rw.discountPercentOP6));
                              }else if(rw.discountFlatOP6.isNumeric() && Integer.Valueof(rw.discountFlatOP6)!=Constvalue && string.isnotblank(rw.option6Name)){
                                      optOptions.add(loadOptionData(rw.option6Name+' - '+'Discount '+rw.discountFlatOP6+' '+'flat'+' '+rw.productType,rw.option6Id,rw.discountFlatOP6));
                              }else if(rw.discountPSF_OP6.isNumeric() && Integer.Valueof(rw.discountPSF_OP6)!=Constvalue && string.isnotblank(rw.option6Name)){
                             optOptions.add(loadOptionData(rw.option6Name+' - '+'Discount '+rw.discountPSF_OP6+' '+'psf'+' '+rw.productType,rw.option6Id,rw.discountPSF_OP6));
                            }
                         }
                            
                            //push the data into main wrapper
                            p.TokenAmountApprovalStatus = '';
                            p.NetPrice = 0.0;
                            p.templateIdSN=rw.templateIdSN;
                            p.templateIdCN=rw.templateIdCN;
                            p.templateIdPN=rw.templateIdPN;
                            p.templateIdOP=rw.templateIdOP;
                            p.templateIdOP1=rw.templateIdOP1;
                            p.templateIdOP2=rw.templateIdOP2;
                            p.templateIdOP3=rw.templateIdOP3;
                            p.templateIdOP4=rw.templateIdOP4;
                            p.templateIdOP5=rw.templateIdOP5;
                            p.promotionOptions=promOptions;
                            p.campaignOptions=campOptions;
                            p.schemeOptions=schmOptions;
                            p.optionOptions=optOptions;
                            p.productType=rw.productType;
                            //addddded
                            p.unitID = rw.unitIdCN;
                            plist.add(p);
                }
            }else{
                for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory:availableInventoriesList.ibwList){
                        system.debug('Response Inside The Body at ELSE:'+respWrapList);
                        DH_PromotionsWrapper p=new  DH_PromotionsWrapper();
                        List<SelectOption> promOptions=new  List<SelectOption>();
                        List<SelectOption> campOptions=new  List<SelectOption>();
                        List<SelectOption> schmOptions=new  List<SelectOption>();
                        List<DH_PromotionsWrapper.optionWrapper> optOptions=new  List<DH_PromotionsWrapper.optionWrapper>();
                        
                        //Promotion options
                        promOptions.add(new  SelectOption('Drool Exception','-- Select Promotion -- '));
                        //Campaign options
                        campOptions.add(new  SelectOption('','-- Select Campaign -- '));
                        //schemen options
                        schmOptions.add(new  SelectOption('','-- Select Scheme -- '));
                        //Option options
                        optOptions.add(loadOptionData('','',''));
                        ////////////////////////////////////////////////////////////////////////
                        //push the data into main wrapper
                        p.TokenAmountApprovalStatus = '';
                        p.NetPrice = 0.0;
                        p.templateIdSN='';
                        p.templateIdCN='';
                        p.templateIdPN='';
                        p.templateIdOP='';
                        p.templateIdOP1='';
                        p.templateIdOP2='';
                        p.templateIdOP3='';
                        p.templateIdOP4='';
                        p.templateIdOP5='';
                        p.promotionOptions=promOptions;
                        p.campaignOptions=campOptions;
                        p.schemeOptions=schmOptions;
                        p.optionOptions=optOptions;
                        p.productType='Exception';
                        plist.add(p);
                }   
        
        }
        if(plist!=null&&!plist.isEmpty()){
            finalWrap=new  List<DH_PromotionsWrapper>();
            integer count=0;
            if(availableInventoriesList.ibwList!=null&&availableInventoriesList.ibwList.size()>0){
                for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory:availableInventoriesList.ibwList){
                    if(thisInventory.isSelected&&thisInventory.selectedInventory.Id!=null){
                        if((plist.get(count).unitID).equalsIgnoreCase(thisInventory.selectedInventory.Unit__c)){
                            plist.get(count).id=thisInventory.selectedInventory.Id;
                            count++;
                        }   
                    }
                }
                finalWrap.addAll(plist);
            }
        }
        return finalWrap ;
    }
    public static DH_PromotionsWrapper.optionWrapper loadOptionData(string name,string id,string price){
        DH_PromotionsWrapper.optionWrapper o=new  DH_PromotionsWrapper.optionWrapper();
        o.Name=name;
        o.Id=id;
        o.Price=price;
        return o;
    }
    
    
    
   /***********************************************************************************************
    * @Description : Method to Save Option Record
    * @Params      : List<Option__c>    
    * @Return      : List<Option__c>
    *Message : As Discuss with Vinit    we are sending Hardcode  TemplateIdPN Id 
 ************************************************************************************************/    
      
    
    public static  List<Option__c> SaveOption(String AllOption ){
      Option__c  NullObj =  new Option__c ();
     OptionWrapper objOptionWrapper  = new OptionWrapper();
     List<Option__c> optUpdate = new List<Option__c>();
     List<String> UnitIdList = new List<String>();
      List<String> DealSr = new List<String>();
    
      List<Booking_Unit__c> BUList = new List<Booking_Unit__c>();
     List<OptionWrapper.cls_items> OptionClsItem = new List<OptionWrapper.cls_items>();
     
     system.debug('objOptionWrapper ############# '+AllOption);
     objOptionWrapper = OptionWrapper.parse(AllOption);
    
     try{
          if(objOptionWrapper != null){
              if(!objOptionWrapper.items.isEmpty()){
              for(OptionWrapper.cls_items  Obj : objOptionWrapper.items){
                   OptionClsItem.add(Obj);
                     if(!String.isBlank(Obj.unitIDRef))
                         UnitIdList.add(Obj.unitIDRef);
                     
                        if(!String.isBlank(Obj.dealSR))
                         DealSr.add(Obj.dealSR);
                     
              }
             }
          }
     
            for(Booking_Unit__c B : [SELECT id ,Deal__c ,Booking__r.Deal_SR__r.Name  , Unit_Location__c ,(Select Id , Booking_Unit__c From Options__r),Inventory__r.Unit__c  FROM Booking_Unit__c Where 
                                           Unit_Location__c =: UnitIdList and Booking__r.Deal_SR__r.Name =:DealSr Order By CreatedDate DESC ]){
                   BUList.add(B);
         }
 
     System.debug('All UnitID for Booking------------- '+UnitIdList); 
     System.debug('All DealSr for Booking------------- '+DealSr);
     System.debug('All Booking Unit ------------- '+BUList);               
     if(OptionClsItem != null && BUList != null){
       for(OptionWrapper.cls_items  Obj : OptionClsItem){  
              for(Booking_Unit__c BU : BUList){
    if(Obj.unitIDRef.equalsIgnoreCase(BU.Unit_Location__c) &&  Obj.DealSr.equalsIgnoreCase(BU.Booking__r.Deal_SR__r.Name)){
       
        if(string.isBlank(Obj.TokenAmountApprovalStatus) || (!Obj.TokenAmountApprovalStatus.equalsIgnoreCase('Approved'))){
          
                 if(!BU.Options__r.isEmpty()){
                 
                  for(Option__c existinOpt : BU.Options__r){
                     System.debug('Exsting Option---------------- '+BU.Options__r);
                     existinOpt.CurrencyIsoCode =  !String.isBlank(Obj.currencyCode ) ? Obj.currencyCode : '' ;    
                     existinOpt.UnitID__c  =  !String.isBlank(Obj.unitIDRef) ? Obj.unitIDRef : '' ;
                     existinOpt.PromotionName__c  = (!String.isBlank(Obj.promotionName) && !String.isBlank(Obj.promotionValue)) ?  Obj.promotionName +' - '+Obj.promotionValue : (!String.isBlank(Obj.promotionName)) ? Obj.promotionName : '' ;
                     existinOpt.OptionsName__c  = (!String.isBlank(Obj.optionsName) && !String.isBlank(Obj.optionsValue)) ?  Obj.optionsName +' - '+Obj.optionsValue : (!String.isBlank(Obj.optionsName)) ? Obj.optionsName : '' ;
                     existinOpt.CampaignName__c    = (!String.isBlank(Obj.campaignName) && !String.isBlank(Obj.campaignValue)) ?  Obj.campaignName +' - '+Obj.campaignValue : (!String.isBlank(Obj.campaignName)) ? Obj.campaignName : '' ;
                     existinOpt.SchemeName__c    = (!String.isBlank(Obj.schemeName) && !String.isBlank(Obj.schemeValue)) ?  Obj.schemeName +' - '+Obj.schemeValue : (!String.isBlank(Obj.schemeName)) ? Obj.schemeName : '' ;
                     existinOpt.TemplateIdSN__c  = !String.isBlank(Obj.templateIdSN) ?  Obj.templateIdSN : ''   ;
                     existinOpt.TemplateIdCN__c  = !String.isBlank(Obj.templateIdCN) ? Obj.templateIdCN : ''   ; 
                     
                     existinOpt.TemplateIdPN__c  = !String.isBlank(Obj.templateIdPN) ? Obj.templateIdPN : ''  ;
                     existinOpt.TemplateIdOP__c  = !String.isBlank(Obj.templateIdOP) ? Obj.templateIdOP : ''   ;  
                     existinOpt.Net_Price__c= !String.isBlank(Obj.netPriceVal)? Double.valueof(Obj.netPriceVal) : 0.00 ;
                     existinOpt.CM_Price_Per_Sqft__c= !String.isBlank(Obj.CMPricePerSqftAfter) ? Double.valueOf(Obj.CMPricePerSqftAfter) : 0.00 ;
                     existinOpt.TemplateIdOP1__c  = !String.isBlank(Obj.templateIdOP1) ? Obj.templateIdOP1 : ''   ;
                     existinOpt.TemplateIdOP2__c  = !String.isBlank(Obj.templateIdOP2) ? Obj.templateIdOP2 : ''  ;
                     existinOpt.TemplateIdOP3__c  = !String.isBlank(Obj.templateIdOP3) ? Obj.templateIdOP3 : ''  ;
                     existinOpt.TemplateIdOP4__c  = !String.isBlank(Obj.templateIdOP4) ? Obj.templateIdOP4 : ''   ;
                     existinOpt.TemplateIdOP5__c  = !String.isBlank(Obj.templateIdOP5) ? Obj.templateIdOP5 : ''    ;   
                                 
                     optUpdate.add(existinOpt);
                  }
                 }
                
              else if(BU.Options__r.isEmpty()){
                 
                     System.debug('New Option---------------- '+BU.Options__r);
                     Option__c newOpt=  new Option__c();
                     newOpt.Booking_Unit__c = BU.Id;
                     newOpt.CurrencyIsoCode =  !String.isBlank(Obj.currencyCode ) ? Obj.currencyCode : '' ; 
                     newOpt.UnitID__c  =  !String.isBlank(Obj.unitIDRef) ? Obj.unitIDRef : '' ;
                     newOpt.PromotionName__c = (!String.isBlank(Obj.promotionName) && !String.isBlank(Obj.promotionValue)) ?  Obj.promotionName +' - '+Obj.promotionValue : (!String.isBlank(Obj.promotionName)) ? Obj.promotionName : '' ;
                     newOpt.OptionsName__c = (!String.isBlank(Obj.optionsName) && !String.isBlank(Obj.optionsValue)) ?  Obj.optionsName +' - '+Obj.optionsValue : (!String.isBlank(Obj.optionsName)) ? Obj.optionsName : '' ;
                     newOpt.CampaignName__c = (!String.isBlank(Obj.campaignName) && !String.isBlank(Obj.campaignValue)) ?  Obj.campaignName +' - '+Obj.campaignValue : (!String.isBlank(Obj.campaignName)) ? Obj.campaignName : '' ;
                     newOpt.SchemeName__c = (!String.isBlank(Obj.schemeName) && !String.isBlank(Obj.schemeValue)) ?  Obj.schemeName +' - '+Obj.schemeValue : (!String.isBlank(Obj.schemeName)) ? Obj.schemeName : '' ;
                    
                     newOpt.TemplateIdSN__c  = !String.isBlank(Obj.templateIdSN) ?  Obj.templateIdSN : ''   ;
                     newOpt.TemplateIdCN__c  = !String.isBlank(Obj.templateIdCN) ? Obj.templateIdCN : ''   ; 
                    
                     newOpt.TemplateIdPN__c  = !String.isBlank(Obj.templateIdPN) ? Obj.templateIdPN : ''  ;
                     newOpt.TemplateIdOP__c  = !String.isBlank(Obj.templateIdOP) ? Obj.templateIdOP : ''   ;  
                     newOpt.Net_Price__c= !String.isBlank(Obj.netPriceVal)? Double.valueof(Obj.netPriceVal) : 0.00 ;
                     newOpt.CM_Price_Per_Sqft__c= !String.isBlank(Obj.CMPricePerSqftAfter) ? Double.valueOf(Obj.CMPricePerSqftAfter) : 0.00 ;
                     newOpt.TemplateIdOP1__c  = !String.isBlank(Obj.templateIdOP1) ? Obj.templateIdOP1 : ''   ;
                     newOpt.TemplateIdOP2__c  = !String.isBlank(Obj.templateIdOP2) ? Obj.templateIdOP2 : ''  ;
                     newOpt.TemplateIdOP3__c  = !String.isBlank(Obj.templateIdOP3) ? Obj.templateIdOP3 : ''  ;
                     newOpt.TemplateIdOP4__c  = !String.isBlank(Obj.templateIdOP4) ? Obj.templateIdOP4 : ''   ;
                     newOpt.TemplateIdOP5__c  = !String.isBlank(Obj.templateIdOP5) ? Obj.templateIdOP5 : ''    ;
               
                     optUpdate.add(newOpt);
                  }
              }
           }
        }
      }
     }
      
       System.debug('All Option insert---------- '+optUpdate );
      if(!optUpdate.isEmpty()){
        
          System.debug('Inside The Option Save Loop-------   '+optUpdate );
          upsert optUpdate ;
          System.debug('All Option inserted---------- '+optUpdate );
      }
      
      
    }
    
    catch(Exception Ex){
       System.debug('Option::Line Number::::::: '+Ex.getLineNumber());
       System.debug('Option::Message:::::: '+Ex.getMessage());
        
    }
        return optUpdate ;   
    }
  
    
 /***********************************************************************************************
    * @Description : Method to Retrun All Parameter Comes from Drool Web Service
    * @Params      : List<DH_PromotionsWrapper>         
    * @Return      : List<DH_PromotionsWrapper>                                                                           *
 ************************************************************************************************/  
  public static Map<id,DH_PromotionsWrapper>  createOptionsMapforInventories(List<DH_PromotionsWrapper> promList1){
    
    Map<id,DH_PromotionsWrapper> promMapTemp=new Map<id,DH_PromotionsWrapper>();
    
    optMap=new Map<id,List<selectoption>>();
   if(promList1 != null ){
       System.debug('promList1 mList11'+' '+promList1);
       
  for(DH_PromotionsWrapper d:promList1){
    if(!string.isBlank(d.TokenAmountApprovalStatus) && d.TokenAmountApprovalStatus.equalsIgnoreCase('Approved')){
  
    
          promMapTemp.put(d.id,d);
          optMap.put(d.id,new List<selectoption>());
          List<DH_PromotionsWrapper.optionWrapper> opw=new List<DH_PromotionsWrapper.optionWrapper>();
          opw=d.optionOptions;
            for(DH_PromotionsWrapper.optionWrapper o:opw){
               if(!String.isBlank(o.Price) && !String.isBlank(o.Name) && !optMap.isEmpty()){     
              optMap.get(d.id).add(new selectoption(o.Price,o.Name));
            }
         }
    }else{
          promMapTemp.put(d.id,d);
          optMap.put(d.id,new List<selectoption>());
          List<DH_PromotionsWrapper.optionWrapper> opw=new List<DH_PromotionsWrapper.optionWrapper>();
          opw=d.optionOptions;
            
            if(!optMap.isEmpty())
            optMap.get(d.id).add(new SelectOption('', '-- Select Option -- '));
            for(DH_PromotionsWrapper.optionWrapper o:opw){
               if(!String.isBlank(o.Price) && !String.isBlank(o.Name)){     
              optMap.get(d.id).add(new selectoption(o.Price,o.Name));
            }
         }
    }
    }
  }
    return promMapTemp;
    
  }
    
    
 /***********************************************************************************************
    * @Description : Method to Retrun All the selectOption which is Come from Drool Web service
    * @Params      : Map<id,List<selectOption>>   
    * @Return      : Map<id,List<selectOption>>                                                                           *
 ************************************************************************************************/ 
  public static Map<id,List<selectOption>> createOptionsForOptMap(List<DH_PromotionsWrapper> promList1){
    
    Map<id,DH_PromotionsWrapper> promMapTemp=new Map<id,DH_PromotionsWrapper>();
    optMap=new Map<id,List<selectoption>>();
   if(promList1 != null ){
       System.debug('promList1 mList11111'+' '+promList1);
       
  for(DH_PromotionsWrapper d:promList1){
    if(!string.isBlank(d.TokenAmountApprovalStatus) && d.TokenAmountApprovalStatus.equalsIgnoreCase('Approved')) {
         promMapTemp.put(d.id,d);
          optMap.put(d.id,new List<selectoption>());
          List<DH_PromotionsWrapper.optionWrapper> opw=new List<DH_PromotionsWrapper.optionWrapper>();
          opw=d.optionOptions;

            for(DH_PromotionsWrapper.optionWrapper o:opw){
               if(!String.isBlank(o.Price) && !String.isBlank(o.Name) && !optMap.isEmpty() ){     
              optMap.get(d.id).add(new selectoption(o.Price,o.Name));
            }
         }
    }else{
        promMapTemp.put(d.id,d);
          optMap.put(d.id,new List<selectoption>());
          List<DH_PromotionsWrapper.optionWrapper> opw=new List<DH_PromotionsWrapper.optionWrapper>();
          opw=d.optionOptions;
            
            if(!optMap.isEmpty())
            optMap.get(d.id).add(new SelectOption('', '-- Select Option -- '));
            for(DH_PromotionsWrapper.optionWrapper o:opw){
               if(!String.isBlank(o.Price) && !String.isBlank(o.Name)){     
              optMap.get(d.id).add(new selectoption(o.Price,o.Name));
            }
         }
    }
    }
  }
    return optMap;
    
  }
   /***********************************************************************************************
    * @Description : Method to Retrun All the selectOption 
    * @Params      :  Map<String ,Option__c>  
    * @Return      :  Map<String ,Option__c>                                                                          *
 ************************************************************************************************/ 
        Public static Map<String ,Option__c> getOptionDetails(Set<Id> BookingId){
               Map<String ,Option__c> MapOption = new Map<String ,Option__c>(); 
               for(Option__c  opt :[select UnitID__c , 
                                    CampaignName__c ,
                                    Booking_Unit__c ,
                                    PromotionName__c, SchemeName__c ,CM_Price_Per_Sqft__c  from Option__c where Booking_Unit__c =: BookingId]){
                 
                 MapOption.put(opt.Id ,opt);
             }
             return MapOption ;
        }
  
  
  
  
   /***********************************************************************************************
    * @Description : Method to Call Drool Web Services And Get Saved Option Data
    * @Params      : List<DH_PromotionsWrapper> , List<option__c>
    * @Return      : List<DH_PromotionsWrapper>                                                                           *
 ************************************************************************************************/
  public static List<DH_PromotionsWrapper> createRequestDataApproved(UtilityWrapperManager availableInventoriesList, List<option__c> optionList){
       System.debug('createRequestDataApproved-------------------');
       List<DH_RequestWrapper.cls_demo_project1_InOutObject> unitsList=new  List<DH_RequestWrapper.cls_demo_project1_InOutObject>();
       Set<Id> InventoryId =  new Set<Id>();
        List<Campaign_Inventory__c> CamList = new List<Campaign_Inventory__c>();  
        
        system.debug('...availableInventoriesList...'+availableInventoriesList);
        if(availableInventoriesList.ibwList!=null&&availableInventoriesList.ibwList.size()>0){
            
             for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory:availableInventoriesList.ibwList){
                if(thisInventory.isSelected&&thisInventory.selectedInventory.Id!=null){
                    InventoryId.add(thisInventory.selectedInventory.Id);
                 }
              }
            
             if(!InventoryId.isEmpty()){
                 for(Campaign_Inventory__c Cam : [select Id , Inventory__c , Campaign__r.Campaign_Name__c  from Campaign_Inventory__c where  Inventory__c =: InventoryId ]){
                     CamList.add(Cam);
                 }
             }
       
       
            for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory:availableInventoriesList.ibwList){
                
                if(thisInventory.isSelected&&thisInventory.selectedInventory.Id!=null){
                 
                    system.debug('#### selected inventory createRequestData= '+thisInventory.selectedInventory);
                    system.debug('#### selected inventory bookingUnit createRequestData= '+thisInventory.bookingUnit);
                    DH_RequestWrapper.cls_demo_project1_InOutObject reqEle=new  DH_RequestWrapper.cls_demo_project1_InOutObject();
                    
                    reqEle.dateofBooking=system.now().format('YYYY-MM-dd');
                    reqEle.productType = thisInventory.selectedInventory.CurrencyIsoCode ;
                    reqEle.projectName=!string.isBlank(thisInventory.selectedInventory.Property_Name__c)?thisInventory.selectedInventory.Property_Name__c:'null';
                    reqEle.buildingName=thisInventory.selectedInventory.Building_Location__r.Name!=null?thisInventory.selectedInventory.Building_Location__r.Name:'null';
                    reqEle.bedroomType=!string.isBlank(thisInventory.selectedInventory.Bedroom_Type__c)?thisInventory.selectedInventory.Bedroom_Type__c:'null';
                    reqEle.numberofBedrooms=!string.isBlank(thisInventory.selectedInventory.IPMS_Bedrooms__c)?(thisInventory.selectedInventory.IPMS_Bedrooms__c.equalsIgnoreCase('Studio')?'1':thisInventory.selectedInventory.IPMS_Bedrooms__c):'null';
                    reqEle.cunstructionStatus=!string.isBlank(thisInventory.selectedInventory.Property_Status__c)?thisInventory.selectedInventory.Property_Status__c:'null';
                    //reqEle.area=Integer.valueof(thisInventory.selectedInventory.Area_Sqft_2__c) ;
                    reqEle.area=thisInventory.selectedInventory.Area_Sqft_2__c!=null?Integer.valueof(thisInventory.selectedInventory.Area_Sqft_2__c):0;
                    // reqEle.price=Integer.valueof(thisInventory.selectedInventory.Special_Price__c) ;
                    reqEle.price=thisInventory.selectedInventory.Special_Price__c!=null?Integer.valueof(thisInventory.selectedInventory.Special_Price__c):0;
                    
                    // reqEle.agent=   String.valueof(availableInventoriesList.dealRecord.Agent_Name__r.Name) != null ?  availableInventoriesList.dealRecord.Agent_Name__r.Name : 'null' ;             
                    reqEle.agent='null';
                    reqEle.pcId=UserInfo.getName();
                    reqEle.unitIdCN=!string.isBlank(thisInventory.selectedInventory.Unit__c)?thisInventory.selectedInventory.Unit__c:'null';
                    reqEle.marketingProject=!string.isBlank(thisInventory.selectedInventory.Marketing_Name__c)?thisInventory.selectedInventory.Marketing_Name__c:'null';
                    reqEle.views=!string.isBlank(thisInventory.selectedInventory.View_Type__c)?thisInventory.selectedInventory.View_Type__c:'null';
                    reqEle.floor=!string.isBlank(thisInventory.selectedInventory.Floor__c)?thisInventory.selectedInventory.Floor__c:'null';
                    reqEle.category=!string.isBlank(thisInventory.selectedInventory.Unit_Type__c)?thisInventory.selectedInventory.Unit_Type__c:'null';
                    reqEle.subCategory=!string.isBlank(thisInventory.selectedInventory.Brand__c)?thisInventory.selectedInventory.Brand__c:'null';
                    reqEle.inventoryThreshold=0;
                    reqEle.customerthresholdValue=0;
                   //reqEle.region=!string.isBlank(thisInventory.jointBuyerList[0].Country__c)?thisInventory.jointBuyerList[0].Country__c:'null';
                   // reqEle.residence=!string.isBlank(thisInventory.jointBuyerList[0].City__c)?thisInventory.jointBuyerList[0].City__c:'null';
                      if(!thisInventory.jointBuyerList.isEmpty()){
                   for(Buyer__c buyer :thisInventory.jointBuyerList){
                       if(buyer.Primary_Buyer__c == true){
                        reqEle.region=!string.isBlank(buyer.Country__c)?buyer.Country__c:'null';
                        reqEle.residence=!string.isBlank(buyer.City__c)?buyer.City__c:'null';
                        } 
                        
                        else{
                        reqEle.region='null';
                        reqEle.residence='null';  
                       }
                      }
                    }
                    else{
                        reqEle.region='null';
                        reqEle.residence='null';
                    }
                       if(!CamList.isEmpty()){
                      for(Campaign_Inventory__c C : CamList){
                          if(C.Inventory__c == thisInventory.selectedInventory.Id){
                          reqEle.campaignNameInput=!string.isBlank(C.Campaign__r.Campaign_Name__c)? C.Campaign__r.Campaign_Name__c:'null';
                          break;
                         }
                       }
                     }
                 else{
                    reqEle.campaignNameInput= 'null';
                   }
                    reqEle.noofUnits=0;
                    reqEle.totalArea=0;
                    reqEle.totalDealValue=0;
                    reqEle.noofUnitsInput=0;
                    // add new Parameter
                    reqEle.schemeId=6;
                    reqEle.noofunitsinputPN=2;
                    reqEle.totalAreaPN=0;
                    reqEle.totalDealValuePN=0;
                    reqEle.promoIdPN=4;
                    unitsList.add(reqEle);
                }
            }
        }
        DH_RequestWrapper.cls_object inout=new  DH_RequestWrapper.cls_object();
        
        inout.demo_project1_InOutObject=unitsList;
        
        DH_RequestWrapper.cls_insert inst=new  DH_RequestWrapper.cls_insert();
        
        inst.object_1=inout;
        
        inst.out_identifier='InOutObject';
        DH_RequestWrapper.cls_commands cmnd=new  DH_RequestWrapper.cls_commands();
        cmnd.insert_1=inst;
        List<DH_RequestWrapper.cls_commands> cmndList=new  List<DH_RequestWrapper.cls_commands>();
        cmndList.add(cmnd);
        DH_RequestWrapper rw1=new  DH_RequestWrapper();
        rw1.commands=cmndList;
        string body=JSON.serialize(rw1);
        List<DH_ResponseWrapper> respWrapList=new  List<DH_ResponseWrapper>();
        if(!string.isBlank(body)){
            body=body.replace('demo_project1_InOutObject','demo.project1.InOutObject');
            body=body.replace('object_1','object');
            body=body.replace('insert_1','insert');
            system.debug('Request body for Drool***'+body);
            respWrapList=DH_DroolCalloutService.getResponse(body);
        }
        system.debug('Response body for Drool::::'+respWrapList);
        if(!respWrapList.isEmpty() && respWrapList!=null){
            system.debug('Response Inside The Body:'+respWrapList);
            Integer ipot = 0;
            for(DH_ResponseWrapper rw:respWrapList){
            
                system.debug('Response Inside The Body optionList:'+ optionList.get(ipot));
                DH_PromotionsWrapper p=new  DH_PromotionsWrapper();
                List<SelectOption> promOptions=new  List<SelectOption>();
                List<SelectOption> campOptions=new  List<SelectOption>();
                List<SelectOption> schmOptions=new  List<SelectOption>();
                
                
                List<DH_PromotionsWrapper.optionWrapper> optOptions=new  List<DH_PromotionsWrapper.optionWrapper>();
                //Promotion options
                 for(option__c opList:optionList){
              
                 if(!String.isBlank(rw.unitIdCN) && !String.isBlank(opList.UnitID__c)){
               
                    if((rw.unitIdCN).equalsIgnoreCase(opList.UnitID__c)){
                        if(string.isnotblank(opList.PromotionName__c)){
                            promOptions.add(new  SelectOption(String.valueOf(opList.Net_Price__c),opList.PromotionName__c));
                        }else{
                            promOptions.add(new  SelectOption(String.valueOf(opList.Net_Price__c),''));
                        }
                        
                        //Campaign options
                        if(string.isnotblank(opList.CampaignName__c)){
                            campOptions.add(new  SelectOption('',opList.CampaignName__c));
                        }else{
                            campOptions.add(new  SelectOption('',''));
                        }
                         
                        //schemen options
                        if(string.isnotblank(opList.SchemeName__c)){
                            schmOptions.add(new  SelectOption('',opList.SchemeName__c));
                        }else{
                            schmOptions.add(new  SelectOption('',''));
                        }
                       
                        //Option options
                        if(string.isnotblank(opList.OptionsName__c)){
                            //promOptions.add(new  SelectOption('',opList.OptionsName__c));
                            if(string.isnotblank(opList.OptionsName__c))optOptions.add(loadOptionData(opList.OptionsName__c,opList.OptionsName__c,opList.OptionsName__c));
                        }else{
                            //promOptions.add(new  SelectOption('',''));
                            optOptions.add(loadOptionData('','',''));
                        }
                        
                        p.TokenAmountApprovalStatus = 'Approved';
                        p.NetPrice = opList.Net_Price__c;   
                        
                    }
                    }
                }
                //Option options
                //if(string.isnotblank(rw.option1Id))optOptions.add(loadOptionData(rw.option1Name,rw.option1Id,rw.option1Price));
                
                //push the data into main wrapper
                p.templateIdSN=rw.templateIdSN;
                p.templateIdCN=rw.templateIdCN;
                p.templateIdPN=rw.templateIdPN;
                p.templateIdOP=rw.templateIdOP;
                p.templateIdOP1=rw.templateIdOP1;
                p.templateIdOP2=rw.templateIdOP2;
                p.templateIdOP3=rw.templateIdOP3;
                p.templateIdOP4=rw.templateIdOP4;
                p.templateIdOP5=rw.templateIdOP5;
                p.promotionOptions=promOptions;
                p.campaignOptions=campOptions;
                p.schemeOptions=schmOptions;
                p.optionOptions=optOptions;
                p.unitID = rw.unitIdCN;
                plist.add(p);
                ipot++;
            }
        }
        if(plist!=null&&!plist.isEmpty()){
            finalWrap=new  List<DH_PromotionsWrapper>();
            integer count=0;
            if(availableInventoriesList.ibwList!=null&&availableInventoriesList.ibwList.size()>0){
                for(UtilityWrapperManager.InventoryBuyerWrapper thisInventory:availableInventoriesList.ibwList){
                    if(thisInventory.isSelected&&thisInventory.selectedInventory.Id!=null){
                        if((plist.get(count).unitID).equalsIgnoreCase(thisInventory.selectedInventory.Unit__c)){
                            plist.get(count).id=thisInventory.selectedInventory.Id;
                            count++;
                        }
                    }
                }
                finalWrap.addAll(plist);
            }
        }
        return finalWrap ;
    }   
}