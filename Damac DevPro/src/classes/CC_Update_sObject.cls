global without sharing class CC_Update_sObject implements NSIBPM.sObjectUpdateable{
    global string UpdatesObject(NSIBPM__Action__c act,NSIBPM__Step__c stp){
        string strResult = 'Success';
        if(stp!=null && stp.Id!=null){
            if(act.NSIBPM__Action_Type__c=='NSIBPM__Service_Request__c'){
                if(stp.NSIBPM__SR__c!=null){
                    NSIBPM__Service_Request__c updateSR = new NSIBPM__Service_Request__c(id=stp.NSIBPM__SR__c);
                    if(act.NSIBPM__Field_Name__c!=null && act.NSIBPM__Field_Type__c!=null && act.NSIBPM__Value_or_Field__c=='Value'){
                        if(act.NSIBPM__Field_Type__c=='DOUBLE'){
                            updateSR.put(act.NSIBPM__Field_Name__c,integer.valueOf(act.NSIBPM__Field_Value__c));
                        }else if(act.NSIBPM__Field_Type__c=='DATE'){
                            if(act.NSIBPM__Field_Value__c!=null && act.NSIBPM__Field_Value__c!='' && act.NSIBPM__Field_Value__c.trim().length()==10){
                                list<string> lstDtVals = new list<String>();
                                lstDtVals = act.NSIBPM__Field_Value__c.split('/');
                                if(lstDtVals!=null && lstDtVals.size()==3){
                                    Date dateval = Date.newInstance(integer.valueOf(lstDtVals[2]),integer.valueOf(lstDtVals[1]),integer.valueOf(lstDtVals[0]));
                                    updateSR.put(act.NSIBPM__Field_Name__c,dateval);
                                }
                            }
                        }else if(act.NSIBPM__Field_Type__c=='BOOLEAN'){
                            boolean bval = false;
                            if(act.NSIBPM__Field_Value__c=='true'){
                                bval = true;
                            }
                            updateSR.put(act.NSIBPM__Field_Name__c,bval);
                        }else{
                            updateSR.put(act.NSIBPM__Field_Name__c,string.valueOf(act.NSIBPM__Field_Value__c));
                        }
                    }else if(act.NSIBPM__Field_Name__c!=null && act.NSIBPM__Field_Type__c!=null && act.NSIBPM__Value_or_Field__c=='Step Field'){
                        if(act.NSIBPM__Field_Value__c!=null && act.NSIBPM__Field_Value__c!=''){
                            updateSR.put(act.NSIBPM__Field_Name__c,stp.get(act.NSIBPM__Field_Value__c));
                        }
                    }
                    try{
                        NSIBPM.RecursiveControlCls.SR_UpdateCtrl = 'SR Updated';
                        update updateSR;
                    }catch(Exception e){
                        strResult = e.getMessage()+'';
                    }
                }
            }else if(act.NSIBPM__Action_Type__c=='NSIBPM__Step__c'){
                NSIBPM__Step__c updatestp = new NSIBPM__Step__c(id=stp.Id);
                if(act.NSIBPM__Field_Name__c!=null && act.NSIBPM__Field_Type__c!=null && act.NSIBPM__Value_or_Field__c=='Value'){
                    if(act.NSIBPM__Field_Type__c=='DOUBLE'){
                        updatestp.put(act.NSIBPM__Field_Name__c,integer.valueOf(act.NSIBPM__Field_Value__c));
                    }else if(act.NSIBPM__Field_Type__c=='DATE'){
                        if(act.NSIBPM__Field_Value__c!=null && act.NSIBPM__Field_Value__c!='' && act.NSIBPM__Field_Value__c.trim().length()==10){
                            list<string> lstDtVals = new list<String>();
                            lstDtVals = act.NSIBPM__Field_Value__c.split('/');
                            if(lstDtVals!=null && lstDtVals.size()==3){
                                Date dateval = Date.newInstance(integer.valueOf(lstDtVals[2]),integer.valueOf(lstDtVals[1]),integer.valueOf(lstDtVals[0]));
                                updatestp.put(act.NSIBPM__Field_Name__c,dateval);
                            }
                        }
                    }else if(act.NSIBPM__Field_Type__c=='BOOLEAN'){
                        boolean bval = false;
                        if(act.NSIBPM__Field_Value__c=='true'){
                            bval = true;
                        }
                        updatestp.put(act.NSIBPM__Field_Name__c,bval);
                    }else{
                        updatestp.put(act.NSIBPM__Field_Name__c,string.valueOf(act.NSIBPM__Field_Value__c));
                    }
                }else if(act.NSIBPM__Field_Name__c!=null && act.NSIBPM__Field_Type__c!=null && act.NSIBPM__Value_or_Field__c=='SR Field'){
                    if(act.NSIBPM__Field_Value__c!=null && act.NSIBPM__Field_Value__c!=''){
                        updatestp.put(act.NSIBPM__Field_Name__c,stp.NSIBPM__SR__r.get(act.NSIBPM__Field_Value__c));
                    }
                }
                try{
                    NSIBPM.RecursiveControlCls.Step_UpdateCtrl = 'Step Updated';
                    update updatestp;
                }catch(Exception e){
                    strResult = e.getMessage()+'';
                }
            }else if(act.NSIBPM__Action_Type__c=='Account'){
                if(stp.NSIBPM__SR__c!=null && stp.NSIBPM__SR__r.NSIBPM__Customer__c!=null){
                    Account updateAcc = new Account(id=stp.NSIBPM__SR__r.NSIBPM__Customer__c);
                    if(act.NSIBPM__Field_Name__c!=null && act.NSIBPM__Field_Type__c!=null && act.NSIBPM__Value_or_Field__c=='Value'){
                        if(act.NSIBPM__Field_Type__c=='DOUBLE'){
                            updateAcc.put(act.NSIBPM__Field_Name__c,integer.valueOf(act.NSIBPM__Field_Value__c));
                        }else if(act.NSIBPM__Field_Type__c=='DATE'){
                            if(act.NSIBPM__Field_Value__c!=null && act.NSIBPM__Field_Value__c!='' && act.NSIBPM__Field_Value__c.trim().length()==10){
                                list<string> lstDtVals = new list<String>();
                                lstDtVals = act.NSIBPM__Field_Value__c.split('/');
                                if(lstDtVals!=null && lstDtVals.size()==3){
                                    Date dateval = Date.newInstance(integer.valueOf(lstDtVals[2]),integer.valueOf(lstDtVals[1]),integer.valueOf(lstDtVals[0]));
                                    updateAcc.put(act.NSIBPM__Field_Name__c,dateval);
                                }
                            }
                        }else if(act.NSIBPM__Field_Type__c=='BOOLEAN'){
                            boolean bval = false;
                            if(act.NSIBPM__Field_Value__c=='true'){
                                bval = true;
                            }
                            updateAcc.put(act.NSIBPM__Field_Name__c,bval);
                        }else{
                            updateAcc.put(act.NSIBPM__Field_Name__c,string.valueOf(act.NSIBPM__Field_Value__c));
                        }
                    }else if(act.NSIBPM__Field_Name__c!=null && act.NSIBPM__Field_Type__c!=null && act.NSIBPM__Value_or_Field__c=='SR Field'){
                        if(act.NSIBPM__Field_Value__c!=null && act.NSIBPM__Field_Value__c!=''){
                            updateAcc.put(act.NSIBPM__Field_Name__c,stp.NSIBPM__SR__r.get(act.NSIBPM__Field_Value__c));
                        }
                    }else if(act.NSIBPM__Field_Name__c!=null && act.NSIBPM__Field_Type__c!=null && act.NSIBPM__Value_or_Field__c=='Step Field'){
                        if(act.NSIBPM__Field_Value__c!=null && act.NSIBPM__Field_Value__c!=''){
                            updateAcc.put(act.NSIBPM__Field_Name__c,stp.get(act.NSIBPM__Field_Value__c));
                        }
                    }
                    try{
                        update updateAcc;
                    }catch(Exception e){
                        strResult = e.getMessage()+'';
                    }
                }
            }else if(act.NSIBPM__Action_Type__c=='Contact'){
                if(stp.NSIBPM__SR__c!=null && stp.NSIBPM__SR__r.NSIBPM__Contact__c!=null){
                    Contact updateContact = new Contact(id=stp.NSIBPM__SR__r.NSIBPM__Contact__c);
                    if(act.NSIBPM__Field_Name__c!=null && act.NSIBPM__Field_Type__c!=null && act.NSIBPM__Value_or_Field__c=='Value'){
                        if(act.NSIBPM__Field_Type__c=='DOUBLE'){
                            updateContact.put(act.NSIBPM__Field_Name__c,integer.valueOf(act.NSIBPM__Field_Value__c));
                        }else if(act.NSIBPM__Field_Type__c=='DATE'){
                            if(act.NSIBPM__Field_Value__c!=null && act.NSIBPM__Field_Value__c!='' && act.NSIBPM__Field_Value__c.trim().length()==10){
                                list<string> lstDtVals = new list<String>();
                                lstDtVals = act.NSIBPM__Field_Value__c.split('/');
                                if(lstDtVals!=null && lstDtVals.size()==3){
                                    Date dateval = Date.newInstance(integer.valueOf(lstDtVals[2]),integer.valueOf(lstDtVals[1]),integer.valueOf(lstDtVals[0]));
                                    updateContact.put(act.NSIBPM__Field_Name__c,dateval);
                                }
                            }
                        }else if(act.NSIBPM__Field_Type__c=='BOOLEAN'){
                            boolean bval = false;
                            if(act.NSIBPM__Field_Value__c=='true'){
                                bval = true;
                            }
                            updateContact.put(act.NSIBPM__Field_Name__c,bval);
                        }else{
                            updateContact.put(act.NSIBPM__Field_Name__c,string.valueOf(act.NSIBPM__Field_Value__c));
                        }
                    }else if(act.NSIBPM__Field_Name__c!=null && act.NSIBPM__Field_Type__c!=null && act.NSIBPM__Value_or_Field__c=='SR Field'){
                        if(act.NSIBPM__Field_Value__c!=null && act.NSIBPM__Field_Value__c!=''){
                            updateContact.put(act.NSIBPM__Field_Name__c,stp.NSIBPM__SR__r.get(act.NSIBPM__Field_Value__c));
                        }
                    }else if(act.NSIBPM__Field_Name__c!=null && act.NSIBPM__Field_Type__c!=null && act.NSIBPM__Value_or_Field__c=='Step Field' ){
                        if(act.NSIBPM__Field_Value__c!=null && act.NSIBPM__Field_Value__c!=''){
                            updateContact.put(act.NSIBPM__Field_Name__c,stp.get(act.NSIBPM__Field_Value__c));
                        }
                    }
                    try{
                        update updateContact;
                    }catch(Exception e){
                        strResult = e.getMessage()+'';
                    }
                }
            }
        }
        return strResult;
    }
}